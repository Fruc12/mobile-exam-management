<?php

use App\Http\Controllers\ActorController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\CheckUserEmailVerificationMiddleware;
use App\Http\Middleware\GuestMiddleware;
use Illuminate\Support\Facades\Route;

Route::middleware(['guest.api'])->group(function () {
    Route::post('/login', [UserController::class , 'login'])->name('login');
    Route::post('/login/verify-user', [UserController::class , 'verifyOtp'])->name('login-otp');
    Route::post('/register', [UserController::class , 'register'])->name('register');
    Route::post('/email/verification-notification', [UserController::class, 'sendEmailVerificationNotification'])
            ->middleware('throttle:6,1')->name('verification.send');
});

Route::middleware(['auth:sanctum', 'email.verified'])->group(function () {
    Route::post('/logout', [UserController::class , 'logout'])->name('logout');
    Route::get('/user', [UserController::class , 'getAuthenticatedUser'])->name('user');
//    Route::get('/email/verify', [UserController::class , 'noticeEmailVerification'])
//            ->name('verification.notice');

    Route::apiResource('/actors', ActorController::class);
});
