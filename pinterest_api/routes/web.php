<?php

use Illuminate\Support\Facades\Route;

// API seule : la racine renvoie vers le contrôle de santé.
Route::get('/', fn () => response()->json([
    'service' => 'pinterest-api-backend',
    'health' => url('/health'),
]));
