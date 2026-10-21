<?php

namespace App\Http\Resources;

use App\Models\Activity;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Activity
 */
class ActivityResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'text' => $this->text,
            'time_ago' => $this->time_label,
            'user' => [
                ...CreatorResource::make($this->actor)->resolve($request),
                'is_following' => $this->actor->isFollowedBy(app('pinterest.me')),
            ],
        ];
    }
}
