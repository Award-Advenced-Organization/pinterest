<?php

namespace App\Http\Controllers;

use App\Http\Resources\CommentResource;
use App\Models\Board;
use App\Models\Comment;
use App\Models\Pin;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

/** Actions sur une Épingle : enregistrer, j'aime, masquer, commenter. */
class PinActionController extends Controller
{
    /**
     * Enregistre l'Épingle dans un tableau, ou dans « Idées non organisées » sans board_id.
     * Une Épingle n'est rangée que dans un seul tableau à la fois.
     */
    public function save(Request $request, string $id): JsonResponse
    {
        $me = $this->me();
        $pin = Pin::query()->findOrFail($id);
        $data = $request->validate([
            'board_id' => ['nullable', 'string', Rule::exists('boards', 'id')->where('user_id', $me->id)],
        ], ['board_id.exists' => 'Ce tableau n’existe pas.']);
        $board = isset($data['board_id']) ? Board::query()->find($data['board_id']) : null;

        DB::transaction(function () use ($me, $pin, $board): void {
            $me->savedPins()->syncWithoutDetaching([$pin->id => ['created_at' => now()]]);
            $this->detachFromMyBoards($pin);
            $board?->pins()->attach($pin->id, ['created_at' => now()]);
        });

        return $this->ok(['is_saved' => true, 'board_id' => $board?->id, 'board_name' => $board?->name]);
    }

    public function unsave(string $id): JsonResponse
    {
        $pin = Pin::query()->findOrFail($id);

        DB::transaction(function () use ($pin): void {
            $this->me()->savedPins()->detach($pin->id);
            $this->detachFromMyBoards($pin);
        });

        return $this->ok(['is_saved' => false]);
    }

    public function like(string $id): JsonResponse
    {
        $me = $this->me();
        $pin = Pin::query()->findOrFail($id);
        $me->likedPins()->toggle($pin->id);

        $liked = $me->likedPins()->whereKey($pin->id)->exists();

        return $this->ok(['liked' => $liked, 'like_count' => $pin->base_like_count + $pin->likers()->count()]);
    }

    public function hide(string $id): JsonResponse
    {
        $this->me()->hiddenPins()->syncWithoutDetaching([Pin::query()->findOrFail($id)->id]);

        return $this->ok(['hidden' => true]);
    }

    public function unhide(string $id): JsonResponse
    {
        $this->me()->hiddenPins()->detach(Pin::query()->findOrFail($id)->id);

        return $this->ok(['hidden' => false]);
    }

    public function comment(Request $request, string $id): JsonResponse
    {
        $pin = Pin::query()->findOrFail($id);
        $request->merge(['text' => trim((string) $request->input('text'))]);
        $data = $request->validate(['text' => ['required', 'string', 'max:500']], [
            'text.required' => 'Le commentaire est vide.',
            'text.max' => 'Le commentaire ne doit pas dépasser 500 caractères.',
        ]);

        $comment = Comment::create([
            'id' => 'c_'.Str::lower((string) Str::ulid()),
            'pin_id' => $pin->id,
            'user_id' => $this->me()->id,
            'text' => $data['text'],
        ]);

        return $this->ok([
            'data' => CommentResource::make($comment->load('author')),
            'comment_count' => $pin->comments()->count(),
        ], 201);
    }

    private function detachFromMyBoards(Pin $pin): void
    {
        DB::table('board_pin')
            ->where('pin_id', $pin->id)
            ->whereIn('board_id', $this->me()->boards()->select('id'))
            ->delete();
    }
}
