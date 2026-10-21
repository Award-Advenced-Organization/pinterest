<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/** Ligne de la section « Activité » : suggestion d'abonnement ou nouvel abonné. */
#[Table(keyType: 'string', incrementing: false)]
#[Fillable(['id', 'user_id', 'actor_id', 'type', 'text', 'time_label', 'position'])]
class Activity extends Model
{
    public function actor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'actor_id');
    }
}
