<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $username = Str::lower(Str::ascii(fake()->unique()->userName()));

        return [
            'id' => 'usr_'.Str::lower((string) Str::ulid()),
            'username' => preg_replace('/[^a-z0-9._]/', '', $username),
            'name' => fake()->name(),
            'avatar_url' => '',
            'pronouns' => [],
        ];
    }
}
