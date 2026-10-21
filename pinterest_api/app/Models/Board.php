<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Table(keyType: 'string', incrementing: false)]
#[Fillable(['id', 'user_id', 'name', 'secret', 'description'])]
class Board extends Model
{
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /** Épingles du tableau, la plus récemment ajoutée en premier. */
    public function pins(): BelongsToMany
    {
        return $this->belongsToMany(Pin::class)->withPivot('created_at')->orderByPivot('created_at', 'desc');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return ['secret' => 'boolean'];
    }
}
