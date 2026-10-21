<?php

namespace App\Http\Resources;

use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Message
 */
class MessageResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'from' => $this->sender_id === app('pinterest.me')->id ? 'me' : 'them',
            'text' => $this->text,
            'time' => $this->created_at?->format('H:i'),
            $this->mergeWhen($this->pin_id !== null, fn () => [
                'pin_id' => $this->pin_id,
                'pin_image' => $this->pin?->image_url,
            ]),
        ];
    }
}
