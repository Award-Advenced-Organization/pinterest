<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

#[Table(keyType: 'string', incrementing: false)]
#[Fillable(['id', 'user_id', 'other_user_id', 'created_at', 'updated_at'])]
class Conversation extends Model
{
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /** L'interlocuteur. */
    public function otherUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'other_user_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class)->oldest()->orderBy('id');
    }

    public function lastMessage(): HasOne
    {
        return $this->hasOne(Message::class)->latestOfMany();
    }
}
