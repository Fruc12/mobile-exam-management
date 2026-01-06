<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class CheckUserEmailVerificationMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param Closure(Request): (Response) $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (Auth::user()->hasVerifiedEmail()) {
            return $next($request);
        }
        abort(Response::HTTP_FORBIDDEN, "Veuillez vérifier votre email au préalable");
    }
}
