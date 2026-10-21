<?php

namespace App\Http\Controllers;

use App\Http\Requests\StorePinRequest;
use App\Http\Resources\CommentResource;
use App\Http\Resources\PinResource;
use App\Models\Pin;
use App\Support\Media;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PinController extends Controller
{
    /** Détail d'une Épingle : commentaires, abonnement au créateur et Épingles similaires. */
    public function show(string $id): JsonResponse
    {
        $me = $this->me();
        $pin = Pin::query()->forViewer($me)->findOrFail($id);

        $tags = $pin->tags ?? [];
        $related = $this->visiblePins()
            ->whereKeyNot($pin->id)
            ->orderBy('feed_rank')
            ->get()
            ->sortByDesc(fn (Pin $p) => ($p->category === $pin->category ? 2 : 0)
                + count(array_intersect($p->tags ?? [], $tags)))
            ->take(20)
            ->values();

        return $this->ok(['data' => [
            ...PinResource::make($pin)->resolve(),
            'is_mine' => $pin->user_id === $me->id,
            'is_following' => $pin->creator->isFollowedBy($me),
            'comments' => CommentResource::collection($pin->comments()->with('author')->get()),
            'related_pins' => PinResource::collection($related),
        ]]);
    }

    /** Publication d'une Épingle (image de l'appareil, ou images existantes pour un collage). */
    public function store(StorePinRequest $request): JsonResponse
    {
        $me = $this->me();
        $imageUrl = $request->hasFile('image')
            ? Media::storeUpload($request->file('image'))
            : $request->string('image_url')->toString();

        $pin = DB::transaction(function () use ($request, $me, $imageUrl) {
            $pin = Pin::create([
                'id' => 'pin_user_'.Str::lower((string) Str::ulid()),
                'user_id' => $me->id,
                'title' => trim((string) $request->input('title')),
                'description' => trim((string) $request->input('description')),
                'tags' => [],
                'link' => $request->input('link') ?: null,
                'image_url' => $imageUrl,
                'collage_images' => $request->collageImages(),
                'width' => (int) $request->input('width', 736),
                'height' => (int) $request->input('height', 980),
                'dominant_color' => $request->input('dominant_color') ?: '#d9d9d4',
                'category' => 'perso',
                // Les Épingles créées passent en tête du fil, la plus récente d'abord.
                'feed_rank' => -now()->getTimestampMs(),
            ]);

            $me->savedPins()->attach($pin->id, ['created_at' => now()]);
            if ($boardId = $request->input('board_id')) {
                $pin->boards()->attach($boardId, ['created_at' => now()]);
            }

            return $pin;
        });

        return $this->ok(['data' => PinResource::make(Pin::query()->forViewer($me)->find($pin->id))], 201);
    }

    /** Suppression d'une de ses propres Épingles. */
    public function destroy(string $id): JsonResponse
    {
        $pin = Pin::query()->findOrFail($id);
        if ($pin->user_id !== $this->me()->id) {
            return $this->fail('Vous ne pouvez supprimer que vos propres Épingles.', 403);
        }

        $image = $pin->image_url;
        $pin->delete();
        Media::deleteUploadIfUnused($image);

        return $this->ok();
    }
}
