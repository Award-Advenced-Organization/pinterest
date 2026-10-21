<?php

namespace App\Support;

use App\Models\Pin;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * Images de l'application : celles du fil (/pins/…) et celles envoyées depuis l'appareil (/uploads/…).
 * Elles sont rangées sur le disque « media » et servies par MediaController, avec les en-têtes CORS.
 */
class Media
{
    /** Enregistre une image envoyée et renvoie son chemin public, par exemple « /uploads/up_01k….jpg ». */
    public static function storeUpload(UploadedFile $file): string
    {
        $extension = strtolower($file->guessExtension() ?: $file->getClientOriginalExtension() ?: 'jpg');
        $name = 'up_'.Str::lower((string) Str::ulid()).'.'.$extension;
        $file->storeAs('uploads', $name, 'media');

        return '/uploads/'.$name;
    }

    /** Supprime une image envoyée si plus aucune Épingle ni aucun profil ne l'utilise. */
    public static function deleteUploadIfUnused(?string $url): void
    {
        if ($url === null || ! str_starts_with($url, '/uploads/') || $url === '/uploads/avatar_jaye.jpg') {
            return;
        }

        $used = Pin::query()->where('image_url', $url)->exists()
            || Pin::query()->whereJsonContains('collage_images', $url)->exists()
            || User::query()->where('avatar_url', $url)->exists();

        if (! $used) {
            Storage::disk('media')->delete(ltrim($url, '/'));
        }
    }
}
