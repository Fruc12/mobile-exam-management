<?php

namespace App\Http\Controllers;

use App\Models\Actor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\Response;

class ActorController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        if ( Auth::user()->role != 'admin' ) {
            abort(Response::HTTP_FORBIDDEN, "Vous n'êtes pas autorisé à exécuter cette action");
        }
        return response()->json([
            'success' => true,
            'message' => 'Acteurs récupérés avec succès',
            'data' => Actor::all()->loadMissing('user'),
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request) : JsonResponse
    {
        if (Auth::user()->actor) {
            abort(Response::HTTP_FORBIDDEN, "Vous avez déjà renseigné vos informations d'acteur");
        }
        $validatedData = $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'npi' => 'required|numeric|digits_between:11,11|unique:actors',
            'n_rib' => 'required|alpha_num|size:32',
            'id_card' => 'required|mimetypes:image/jpeg,image/png,application/pdf|max:2048',
            'rib' => 'required|mimetypes:image/jpeg,image/png,application/pdf|max:2048',
            'birthdate' => 'required|date|before:today',
            'birthplace' => 'required|string',
            'diploma' => 'required|in:BAC,LICENCE,MASTER,DOCTORAT',
            'bank' => 'required|in:NSIA,UBA,ECOBANK,BOA,LA POSTE,CORIS,ORABANK',
            'phone' => 'nullable|unique:actors|numeric|digits_between:10,10',
        ]);
        if (!$request->filled('user_id')) {
            $validatedData['user_id'] = Auth::id();
        }

        if ($request->hasFile('rib')) {
            $validatedData['rib'] = $request->file('rib')->store('ribs', 'public');
        }
        if ($request->hasFile('id_card')) {
            $validatedData['id_card'] = $request->file('id_card')->store('id_cards', 'public');
        }

        $actor = Actor::create($validatedData);
        return response()->json([
            'success' => true,
            'message' => 'Acteur créé avec succès',
            'data' => $actor->loadMissing('user'),
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Actor $actor)
    {
        if (! Gate::allows('manage-actor', $actor)) {
            abort(Response::HTTP_FORBIDDEN, "Vous n'êtes pas autorisé à exécuter cette action");
        }
        return response()->json([
            'success' => true,
            'message' => 'Acteur récupéré avec succès',
            'data' => $actor->loadMissing('user'),
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Actor $actor) : JsonResponse
    {
        if (! Gate::allows('manage-actor', $actor)) {
            abort(Response::HTTP_FORBIDDEN, "Vous n'êtes pas autorisé à exécuter cette action");
        }
        $validatedData = $request->validate([
            'npi' => 'required|numeric|digits_between:11,11|'.Rule::unique('actors','npi')->ignore($actor->id),
            'n_rib' => 'required|alpha_num|size:32',
            'id_card' => 'nullable|mimetypes:image/jpeg,image/png,application/pdf|max:2048',
            'rib' => 'nullable|mimetypes:image/jpeg,image/png,application/pdf|max:2048',
            'birthdate' => 'required|date|before:today',
            'birthplace' => 'required|string',
            'diploma' => 'required|in:BAC,LICENCE,MASTER,DOCTORAT',
            'bank' => 'required|in:NSIA,UBA,ECOBANK,BOA,LA POSTE,CORIS,ORABANK',
            'phone' => 'nullable|numeric|digits_between:10,10|'.Rule::unique('actors','phone')->ignore($actor->id),
        ]);

        if (!$request->filled('phone')) {
            $validatedData['phone'] = null;
        }

        if ($request->hasFile('rib')) {
            Storage::disk('public')->delete($actor->rib);
            $validatedData['rib'] = $request->file('rib')->store('ribs', 'public');
        }
        if ($request->hasFile('id_card')) {
            Storage::disk('public')->delete($actor->id_card);
            $validatedData['id_card'] = $request->file('id_card')->store('id_cards', 'public');
        }

        $actor->update($validatedData);
        return response()->json([
            'success' => true,
            'message' => 'Acteur mis à jour avec succès',
            'data' => $actor->loadMissing('user'),
        ]);
    }
    
    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Actor $actor)
    {
        if (! Gate::allows('manage-actor', $actor)) {
            abort(Response::HTTP_FORBIDDEN, "Vous n'êtes pas autorisé à exécuter cette action");
        }
        $actor->delete();
        return response()->json([
            'success' => true,
            'message' => 'Acteur supprimé avec succès'
        ]);
    }
}
