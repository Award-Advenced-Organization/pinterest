<?php

namespace App\Http\Resources;

use App\Models\InboxUpdate;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin InboxUpdate
 */
class InboxUpdateResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'text' => $this->text,
            'query' => $this->query,
            'time_ago' => $this->time_label,
            'image_url' => $this->image_url,
            'icon' => $this->icon,
        ];
    }
}
