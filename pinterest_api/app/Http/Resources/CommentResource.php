<?php

namespace App\Http\Resources;

use App\Models\Comment;
use App\Support\TimeAgo;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Comment
 */
class CommentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'author' => $this->author->name,
            'username' => $this->author->username,
            'avatar_url' => $this->author->avatar_url,
            'text' => $this->text,
            'time_ago' => TimeAgo::short($this->created_at),
            'mine' => $this->user_id === app('pinterest.me')->id,
        ];
    }
}
