<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Table;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Table(keyType: 'string', incrementing: false)]
#[Fillable([
    'id', 'username', 'name', 'avatar_url', 'bio', 'pronouns', 'website', 'email',
    'country_code', 'phone', 'appearance', 'base_follower_count', 'base_following_count',
])]
class User extends Model
{
    /** @use HasFactory<UserFactory> */
    use HasFactory;

    /**
     * La personne qui utilise l'application (pas de connexion : un seul compte).
     */
    public static function me(): self
    {
        return static::query()->findOrFail(config('pinterest.me_id'));
    }

    public function isMe(): bool
    {
        return $this->id === config('pinterest.me_id');
    }

    /** Épingles publiées par l'utilisateur. */
    public function pins(): HasMany
    {
        return $this->hasMany(Pin::class);
    }

    public function boards(): HasMany
    {
        return $this->hasMany(Board::class)->orderBy('created_at');
    }

    public function savedPins(): BelongsToMany
    {
        return $this->belongsToMany(Pin::class, 'saves')->withPivot('created_at');
    }

    public function likedPins(): BelongsToMany
    {
        return $this->belongsToMany(Pin::class, 'likes');
    }

    public function hiddenPins(): BelongsToMany
    {
        return $this->belongsToMany(Pin::class, 'hidden_pins');
    }

    /** Comptes auxquels l'utilisateur est abonné. */
    public function following(): BelongsToMany
    {
        return $this->belongsToMany(self::class, 'follows', 'follower_id', 'followed_id');
    }

    public function followers(): BelongsToMany
    {
        return $this->belongsToMany(self::class, 'follows', 'followed_id', 'follower_id');
    }

    public function conversations(): HasMany
    {
        return $this->hasMany(Conversation::class)->latest('updated_at');
    }

    public function clusters(): HasMany
    {
        return $this->hasMany(Cluster::class)->orderBy('position');
    }

    public function isFollowedBy(self $user): bool
    {
        return $this->followers()->whereKey($user->id)->exists();
    }

    public function followerCount(): int
    {
        return $this->base_follower_count + $this->followers()->count();
    }

    public function followingCount(): int
    {
        return $this->base_following_count + $this->following()->count();
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'pronouns' => 'array',
            'base_follower_count' => 'integer',
            'base_following_count' => 'integer',
        ];
    }
}
