<?php

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Profil complet. Pour le compte de l'application, ajoute les réglages et les compteurs personnels ;
 * pour un autre compte, indique si on y est abonné.
 *
 * @mixin User
 */
class ProfileResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $me = app('pinterest.me');
        $mine = $this->id === $me->id;

        return [
            'id' => $this->id,
            'username' => $this->username,
            'full_name' => $this->name,
            'avatar_url' => $this->avatar_url,
            'bio' => $this->bio,
            'website' => $this->website,
            'follower_count' => $this->followerCount(),
            'following_count' => $this->followingCount(),
            'created_pins_count' => $this->pins()->count(),
            $this->mergeWhen($mine, fn () => [
                'pronouns' => $this->pronouns ?? [],
                'email' => $this->email,
                'country_code' => $this->country_code,
                'phone' => $this->phone,
                'appearance' => $this->appearance,
                'saved_pins_count' => $this->savedPins()->count(),
                'boards_count' => $this->boards()->count(),
            ]),
            $this->mergeWhen(! $mine, fn () => [
                'is_following' => $this->isFollowedBy($me),
            ]),
        ];
    }
}
