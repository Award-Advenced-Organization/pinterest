<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Table(keyType: 'string', incrementing: false)]
#[Fillable(['id', 'pin_id', 'user_id', 'text', 'created_at'])]
class Comment extends Model
{
    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function pin(): BelongsTo
    {
        return $this->belongsTo(Pin::class);
    }
}
