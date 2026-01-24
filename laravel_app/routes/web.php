<?php

use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::middleware('guest')->group( function () {
    Route::get('/email/verify/{id}/{hash}', [UserController::class, 'verifyUserEmail'])
        ->middleware('signed')->name('verification.verify');
    Route::get('/email-verified-successfully', function () {
        return view('auth.email-verification-success');
    })->name('email.success');
    Route::get('/reset-password', function () {
        return view('auth.reset-password');
    })->name('password.reset');
});
