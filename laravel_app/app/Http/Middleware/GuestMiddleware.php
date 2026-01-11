<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class GuestMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()) {
            return response()->json([
                // 'success' => false,
                'message' => 'Vous êtes déjà connecté',
            ], Response::HTTP_UNAUTHORIZED);
        }
        return $next($request);
    }
}
