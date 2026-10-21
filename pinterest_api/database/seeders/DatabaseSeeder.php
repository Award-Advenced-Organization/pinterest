<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * Les événements des modèles restent actifs : ils calculent le texte de recherche des Épingles.
     */
    public function run(): void
    {
        $this->call(PinterestSeeder::class);
    }
}
