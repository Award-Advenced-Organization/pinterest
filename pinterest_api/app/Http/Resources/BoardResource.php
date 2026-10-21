<?php

namespace App\Http\Resources;

use App\Models\Board;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Board
 */
class BoardResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'secret' => $this->secret,
            'description' => $this->description,
            'pin_count' => $this->pins()->count(),
            'cover_images' => $this->pins()->limit(3)->pluck('image_url'),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
