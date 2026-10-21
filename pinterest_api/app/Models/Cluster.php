<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Collection;

/** Regroupement d'Épingles non classées proposé sur le profil. */
#[Table(keyType: 'string', incrementing: false)]
#[Fillable(['id', 'user_id', 'name', 'tag', 'category', 'dismissed_at', 'position'])]
class Cluster extends Model
{
    /**
     * Épingles non classées de l'utilisateur qui correspondent au regroupement.
     *
     * @param  Collection<int, Pin>  $unorganized
     * @return Collection<int, Pin>
     */
    public function matching(Collection $unorganized): Collection
    {
        return $unorganized->filter(fn (Pin $pin) => $this->category
            ? $pin->category === $this->category
            : in_array($this->tag, $pin->tags ?? [], true))->values();
    }

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
