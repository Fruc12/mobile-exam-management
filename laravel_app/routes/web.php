<?php

use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('email/verify/{id}/{hash}', [UserController::class, 'verifyUserEmail'])
    ->middleware('signed')->name('verification.verify');
