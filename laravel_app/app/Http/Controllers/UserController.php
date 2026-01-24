<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Events\Verified;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Spatie\OneTimePasswords\Models\OneTimePassword;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

use function Illuminate\Log\log;

class UserController extends Controller
{
    /**
     * Login a user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function login(Request $request) : JsonResponse
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $credentials['email'])->first();

        if (!$user) {  // Utilisateur non trouvé
            return response()->json([
                // 'success' => false,
                'message' => 'Indentifiants incorrects',
            ], Response::HTTP_FORBIDDEN);
        }

        if (Hash::check($credentials['password'], $user->password)) {
//            $code = Str::padLeft(random_int(0, 999999), 6, '0');
//            $twilio = new Client();
//            $message = "Votre code de vérification Exam Manager est : " . $code;
//
//            $response = $twilio->messages->create(
//                "+2290161555657", // To
//                [
//                    "from" => "+16184278032",
//                    "body" => $message,
//                ]
//            )->toArray();
//
//            $otp = OTP::create([
//                'user_id' => $user->id,
//                'code' => Crypt::encrypt($code),
//            ]);

            if (!$user->hasVerifiedEmail()) {
                return response()->json([
                    // 'success' => false,
                    'message' => 'Email non vérifié. Veuillez vérifier votre boîte mail et cliquer sur le lien de vérification.',
                    'status' => 'email_not_verified',
                ], Response::HTTP_FORBIDDEN);
            }

            $user->sendOneTimePassword();

            return response()->json([
                'success' => true,
                'message' => 'OTP envoyé. Vérifiez votre boîte mail',
            ]);
        }
        return response()->json([
            // 'success' => false,
            'message' => 'Identifiants incorrects',
        ], Response::HTTP_FORBIDDEN);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validatedData = $request->validate([
            'otp' => 'required|numeric',
        ]);

        $otp = OneTimePassword::query()
            ->where('password', $validatedData['otp'])
            ->where('authenticatable_type', 'App\Models\User')
            ->first();

        if ($otp) {
            $user = User::find($otp->authenticatable_id);
            if (!$user->hasVerifiedEmail()) {
                return response()->json([
                    // 'success' => false,
                    'message' => 'Email non vérifié',
                ], Response::HTTP_FORBIDDEN);
            }

            $result = $user->consumeOneTimePassword($otp->password);
            if ($result->isOk()) {
                Auth::login($user);
                return response()->json([
                    'success' => true,
                    'message' => 'Connexion réussie',
                    'token' => $user->createToken('API-Token')->plainTextToken,
                    'data' => [
                        'user' => $user,
                    ],
                ]);
            }

            return response()->json([
//              'success' => false,
                'message' => $result->validationMessage()
            ], Response::HTTP_UNAUTHORIZED);
        }

        return response()->json([
//            'success' => false,
            'message' => 'OTP invalide',
        ], Response::HTTP_UNAUTHORIZED);
    }

    /**
     * Logout current user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function logout(Request $request) : JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Déconnexion réussie.'
        ]);
    }

    /**
     * Register a new user.
     *
     * @param Request $request
     * @return JsonResponse
     * @throws Throwable
     */
    public function register(Request $request) : JsonResponse
    {
        $validatedData = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
        ]);

        $validatedData['password'] = Hash::make($validatedData['password']);
        $user = User::create($validatedData);
        event(new Registered($user));

        return response()->json([
            'success' => true,
            'message' => 'Utilisateur créé avec succès'
        ],201);
    }

    public function getAuthenticatedUser() : JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => "Utilisateur authentifié récupéré avec succès",
            'data' => Auth::user()->load('actor'),
        ]);
    }

    public function getUsers() : JsonResponse
    {
        if ( Auth::user()->role != 'admin' ) {
            abort(Response::HTTP_FORBIDDEN, "Vous n'êtes pas autorisé à exécuter cette action");
        }
        return response()->json([
            'success' => true,
            'message' => 'Utilisateurs récupérés avec succès',
            'data' => User::all()->where('role', 'user')->loadMissing('actor'),
        ]);
    }

    public function verifyUserEmail(Request $request) : RedirectResponse
    {
        $user = User::find($request->route('id'));
        if (! $user->hasVerifiedEmail()) {
            $user->markEmailAsVerified();
            event(new Verified($user));
        }

        return redirect()->route('email.success');
    }


    public function sendEmailVerificationNotification(Request $request) : JsonResponse
    {
        $validatedData = $request->validate(['email' => 'required|string|email|exists:users,email']);

        $user = User::where('email', $validatedData['email'])->first();

        if ( $user->hasVerifiedEmail() ) {
            return response()->json([
                // 'success' => false,
                'message' => 'Email déjà vérifié',
                'status' => 'email_already_verified'
            ], Response::HTTP_BAD_REQUEST);
        }

        $user->sendEmailVerificationNotification();

        return response()->json([
            'success' => true,
            'message' => 'Lien de vérification renvoyé'
        ]);
    }

    public function forgotPassword(Request $request) : JsonResponse
    {
        $request->validate(['email' => 'required|email']);
    
        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::ResetLinkSent) {
            return response()->json([
                'success' => true,
                'message' => __($status)
            ]);
        }
        log('Password Reset Mailing Error : ' . __($status));
        return response()->json([
            // 'success' => false,
            'message' => __($status)
        ], Response::HTTP_BAD_REQUEST);
    }


    public function resetPassword(Request $request) : JsonResponse
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
        ]);
    
        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ])->setRememberToken(Str::random(60));
    
                $user->save();
    
                event(new PasswordReset($user));
            }
        );

        if ($status === Password::PasswordReset) {
            return response()->json([
                'success' => true,
                'message' => __($status)
            ]);
        }
        log('Password Reseting Error : ' . __($status));
        return response()->json([
            // 'success' => false,
            'message' => __($status)
        ], Response::HTTP_BAD_REQUEST);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }

//    public function noticeEmailVerification( Request $request ) : JsonResponse
//    {
//        return response()->json([
////            'success' => false,
//            'message' => "Veuillez vérifier votre email a préalable"
//        ], 403);
//    }
}
