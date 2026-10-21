<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

/**
 * Sert les images sous /pins/… et /uploads/… en passant par Laravel, pour qu'elles reçoivent
 * les en-têtes CORS (indispensables à la version web de l'application).
 */
class MediaController extends Controller
{
    public function show(string $folder, string $file): BinaryFileResponse
    {
        $disk = Storage::disk('media');
        $path = "{$folder}/{$file}";
        abort_unless($disk->exists($path), 404);

        return response()->file($disk->path($path), ['Cache-Control' => 'public, max-age=604800']);
    }
}
