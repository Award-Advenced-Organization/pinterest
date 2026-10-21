<?php

namespace App\Models;

use App\Support\Text;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Scope;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Facades\DB;

#[Table(keyType: 'string', incrementing: false)]
#[Fillable([
    'id', 'user_id', 'title', 'description', 'tags', 'link', 'image_url', 'images', 'collage_images',
    'width', 'height', 'dominant_color', 'category', 'repin_count', 'base_like_count', 'feed_rank', 'created_at',
])]
class Pin extends Model
{
    protected static function booted(): void
    {
        // Texte de recherche tenu à jour à chaque enregistrement.
        static::saving(function (Pin $pin): void {
            $pin->search_text = Text::searchable(implode(' ', [
                $pin->title,
                $pin->category,
                implode(' ', $pin->tags ?? []),
                $pin->creator?->name,
            ]));
        });
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function boards(): BelongsToMany
    {
        return $this->belongsToMany(Board::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class)->oldest();
    }

    public function savers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'saves');
    }

    public function likers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'likes');
    }

    public function hiders(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'hidden_pins');
    }

    /**
     * Ajoute ce que la personne connectée voit sur chaque Épingle :
     * enregistrée, tableau, aimée, nombres de j'aime et de commentaires.
     */
    #[Scope]
    protected function forViewer(Builder $query, User $viewer): void
    {
        $query->select('pins.*')
            ->with('creator')
            ->withCount(['comments', 'likers as likes_count'])
            ->withExists([
                'savers as is_saved' => fn (Builder $q) => $q->whereKey($viewer->id),
                'likers as liked' => fn (Builder $q) => $q->whereKey($viewer->id),
            ])
            ->addSelect(['board_id' => DB::table('board_pin')
                ->join('boards', 'boards.id', '=', 'board_pin.board_id')
                ->where('boards.user_id', $viewer->id)
                ->whereColumn('board_pin.pin_id', 'pins.id')
                ->select('board_pin.board_id')
                ->limit(1),
            ]);
    }

    /** Exclut les Épingles masquées ou signalées par cette personne. */
    #[Scope]
    protected function visibleTo(Builder $query, User $viewer): void
    {
        $query->whereDoesntHave('hiders', fn (Builder $q) => $q->whereKey($viewer->id));
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'tags' => 'array',
            'images' => 'array',
            'collage_images' => 'array',
            'width' => 'integer',
            'height' => 'integer',
            'repin_count' => 'integer',
            'base_like_count' => 'integer',
            'feed_rank' => 'integer',
        ];
    }
}
