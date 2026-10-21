<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;

/** Ligne de la section « Mises à jour » de la boîte de réception. */
#[Table('inbox_updates', keyType: 'string', incrementing: false)]
#[Fillable(['id', 'user_id', 'text', 'query', 'image_url', 'icon', 'time_label', 'dismissed_at', 'position'])]
class InboxUpdate extends Model
{
    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return ['dismissed_at' => 'datetime'];
    }
}
