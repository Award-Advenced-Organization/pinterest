<?php

namespace App\Http\Controllers;

use App\Models\Pin;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;

abstract class Controller
{
    /** Compte de l'application. */
    protected function me(): User
    {
        return app('pinterest.me');
    }

    /** Épingles avec l'état vu par le compte (enregistrée, aimée, tableau…), sans les masquées. */
    protected function visiblePins(): Builder
    {
        return Pin::query()->forViewer($this->me())->visibleTo($this->me());
    }

    /**
     * Réponse au format de l'API : { "status": "success", … }.
     *
     * @param  array<string, mixed>  $payload
     */
    protected function ok(array $payload = [], int $status = 200): JsonResponse
    {
        return response()->json(['status' => 'success', ...$payload], $status);
    }

    /** Réponse d'erreur : { "error": "…" }, lue telle quelle par l'application mobile. */
    protected function fail(string $message, int $status): JsonResponse
    {
        return response()->json(['error' => $message], $status);
    }
}
