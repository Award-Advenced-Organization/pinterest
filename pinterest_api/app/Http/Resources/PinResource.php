<?php

namespace App\Http\Resources;

use App\Models\Pin;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Épingle au format de l'application mobile. Les champs « is_saved », « board_id »,
 * « liked » et les compteurs viennent du scope Pin::forViewer().
 *
 * @mixin Pin
 */
class PinResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'tags' => $this->tags ?? [],
            'link' => $this->link,
            'image_url' => $this->image_url,
            'images' => $this->images,
            'is_carousel' => count($this->images ?? []) > 1,
            'collage_images' => $this->collage_images,
            'width' => $this->width,
            'height' => $this->height,
            'aspect_ratio' => $this->height > 0 ? $this->width / $this->height : 0.75,
            'dominant_color' => $this->dominant_color,
            'category' => $this->category,
            'creator' => CreatorResource::make($this->creator),
            'repin_count' => $this->repin_count,
            'like_count' => $this->base_like_count + (int) ($this->likes_count ?? 0),
            'comment_count' => (int) ($this->comments_count ?? 0),
            'is_saved' => (bool) ($this->is_saved ?? false),
            'board_id' => $this->board_id,
            'liked' => (bool) ($this->liked ?? false),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
