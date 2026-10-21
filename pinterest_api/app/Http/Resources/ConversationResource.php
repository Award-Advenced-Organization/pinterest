<?php

namespace App\Http\Resources;

use App\Models\Conversation;
use App\Support\TimeAgo;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Conversation
 */
class ConversationResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $last = $this->messages->last();

        return [
            'id' => $this->id,
            'with_user' => CreatorResource::make($this->otherUser),
            'last_message' => match (true) {
                $last === null => '',
                $last->text !== '' => $last->text,
                default => 'A envoyé une Épingle',
            },
            'time_ago' => TimeAgo::short($last?->created_at),
            'messages' => MessageResource::collection($this->messages),
        ];
    }
}
