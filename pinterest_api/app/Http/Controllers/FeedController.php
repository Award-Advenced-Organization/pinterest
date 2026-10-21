<?php

namespace App\Http\Controllers;

use App\Http\Resources\PinResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FeedController extends Controller
{
    /** Fil d'accueil paginé ; « bookmark » indique la page suivante (null à la fin). */
    public function home(Request $request): JsonResponse
    {
        $page = max(1, (int) $request->query('page', 1));
        $size = min(100, max(1, (int) $request->query('page_size', 20)));

        $query = $this->visiblePins()->orderBy('feed_rank')->orderByDesc('created_at');
        $total = (clone $query)->count();
        $pins = $query->forPage($page, $size)->get();

        return $this->ok([
            'bookmark' => $page * $size < $total ? (string) ($page + 1) : null,
            'data' => PinResource::collection($pins),
            'total' => $total,
        ]);
    }
}
