<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateProfileRequest;
use App\Http\Resources\BoardResource;
use App\Http\Resources\CreatorResource;
use App\Http\Resources\PinResource;
use App\Http\Resources\ProfileResource;
use App\Models\Pin;
use App\Models\User;
use App\Support\Media;
use App\Support\Text;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /** Annuaire pour « Nouveau message » et « Partager » : tous les comptes sauf le sien. */
    public function index(Request $request): JsonResponse
    {
        $me = $this->me();
        $q = Text::searchable((string) $request->query('q'));
        $followed = $me->following()->pluck('users.id')->all();

        $users = User::query()->whereKeyNot($me->id)->orderBy('name')->get()
            ->filter(fn (User $u) => $q === ''
                || str_contains(Text::searchable($u->name), $q)
                || str_contains(Text::searchable($u->username), $q))
            ->values()
            ->map(fn (User $u) => [
                ...CreatorResource::make($u)->resolve($request),
                'is_following' => in_array($u->id, $followed, true),
            ]);

        return $this->ok(['data' => $users]);
    }

    public function show(string $username): JsonResponse
    {
        return $this->ok(['data' => ProfileResource::make($this->findUser($username))]);
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $me = $this->me();
        $me->update($request->attributesToSave());
        // Le nom du créateur fait partie du texte de recherche de ses Épingles.
        if ($me->wasChanged('name')) {
            $me->pins()->with('creator')->get()->each->save();
        }

        return $this->ok(['data' => ProfileResource::make($me->refresh())]);
    }

    public function avatar(Request $request): JsonResponse
    {
        $request->validate(['image' => ['required', 'file', 'image', 'max:15360']], [
            'image.required' => 'Choisissez une photo.',
            'image.image' => 'Le fichier choisi n’est pas une image.',
            'image.max' => 'L’image dépasse 15 Mo.',
        ]);

        $me = $this->me();
        $previous = $me->avatar_url;
        $me->update(['avatar_url' => Media::storeUpload($request->file('image'))]);
        Media::deleteUploadIfUnused($previous);

        return $this->ok(['data' => ProfileResource::make($me->refresh())]);
    }

    /** S'abonner ou se désabonner (bascule). */
    public function follow(string $username): JsonResponse
    {
        $me = $this->me();
        $user = $this->findUser($username);
        if ($user->id === $me->id) {
            return $this->fail('Vous ne pouvez pas vous abonner à vous-même.', 422);
        }

        $me->following()->toggle($user->id);

        return $this->ok([
            'is_following' => $user->isFollowedBy($me),
            'following_count' => $me->followingCount(),
        ]);
    }

    public function createdPins(string $username): JsonResponse
    {
        $user = $this->findUser($username);
        $pins = Pin::query()->forViewer($this->me())
            ->where('pins.user_id', $user->id)
            ->orderBy('feed_rank')
            ->orderByDesc('created_at')
            ->get();

        return $this->ok(['data' => PinResource::collection($pins)]);
    }

    /** Épingles enregistrées, la plus récente d'abord ; « unorganized=1 » ne garde que celles hors tableau. */
    public function savedPins(Request $request): JsonResponse
    {
        $me = $this->me();
        $query = Pin::query()->forViewer($me)
            ->join('saves', 'saves.pin_id', '=', 'pins.id')
            ->where('saves.user_id', $me->id)
            ->orderByDesc('saves.created_at');

        if ($request->query('unorganized') === '1') {
            $query->whereDoesntHave('boards', fn (Builder $q) => $q->where('boards.user_id', $me->id));
        }

        return $this->ok(['data' => PinResource::collection($query->get())]);
    }

    public function boards(): JsonResponse
    {
        return $this->ok(['data' => BoardResource::collection($this->me()->boards()->get())]);
    }

    /** « me » ou le nom d'utilisateur du compte désignent le compte de l'application. */
    private function findUser(string $username): User
    {
        $me = $this->me();
        if ($username === 'me' || $username === $me->username) {
            return $me;
        }

        return User::query()->where('username', $username)->firstOrFail();
    }
}
