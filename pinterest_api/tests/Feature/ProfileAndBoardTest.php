<?php

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

it('affiche le profil du compte comme sur la capture', function () {
    $this->getJson('/v3/users/me/')
        ->assertOk()
        ->assertJsonPath('data.username', 'ahiffent')
        ->assertJsonPath('data.full_name', 'Jaye ahf')
        ->assertJsonPath('data.follower_count', 1)
        ->assertJsonPath('data.following_count', 2)
        ->assertJsonPath('data.saved_pins_count', 42)
        ->assertJsonPath('data.boards_count', 0)
        ->assertJsonPath('data.appearance', 'system');
});

it('s’abonne à un créateur et se désabonne', function () {
    $this->getJson('/v3/users/hugo.lfv/')->assertJsonPath('data.is_following', false);

    $this->postJson('/v3/users/hugo.lfv/follow/')->assertJson(['is_following' => true, 'following_count' => 3]);
    $this->getJson('/v3/users/hugo.lfv/')->assertJsonPath('data.is_following', true);
    $this->postJson('/v3/users/hugo.lfv/follow/')->assertJson(['is_following' => false, 'following_count' => 2]);

    $this->postJson('/v3/users/me/follow/')->assertUnprocessable();
    $this->postJson('/v3/users/personne/follow/')->assertNotFound();
});

it('modifie le profil et valide chaque champ', function () {
    $this->patchJson('/v3/users/me/', [
        'full_name' => 'Jephté A.',
        'bio' => 'Designer',
        'pronouns' => ['il'],
        'appearance' => 'dark',
    ])->assertOk()
        ->assertJsonPath('data.full_name', 'Jephté A.')
        ->assertJsonPath('data.pronouns', ['il'])
        ->assertJsonPath('data.appearance', 'dark');

    // Le nouveau nom est utilisé par la recherche.
    $this->postJson('/v3/pins/', ['image_url' => '/pins/10.jpg', 'title' => 'Essai'])->assertCreated();
    expect($this->getJson('/v3/search/?q=jephte')->json('count'))->toBe(1);

    $this->patchJson('/v3/users/me/', ['username' => 'x'])
        ->assertUnprocessable()
        ->assertJsonPath('error', 'Nom d’utilisateur invalide (3 à 30 caractères : lettres, chiffres, point, tiret bas).');
    $this->patchJson('/v3/users/me/', ['username' => 'lea.martin'])
        ->assertJsonPath('error', 'Ce nom d’utilisateur est déjà pris.');
    $this->patchJson('/v3/users/me/', ['full_name' => '  '])
        ->assertJsonPath('error', 'Le nom ne peut pas être vide.');
    $this->patchJson('/v3/users/me/', ['pronouns' => ['il', 'elle', 'iel']])
        ->assertJsonPath('error', 'Choisissez au plus 2 pronoms.');
});

it('change la photo de profil', function () {
    Storage::fake('media');

    // PNG de 1 pixel : pas besoin de l'extension GD pour fabriquer l'image.
    $png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
    $url = $this->post('/v3/users/me/avatar/', ['image' => UploadedFile::fake()->createWithContent('moi.png', $png)], ['Accept' => 'application/json'])
        ->assertOk()
        ->json('data.avatar_url');

    expect($url)->toStartWith('/uploads/up_')->toEndWith('.png');
    Storage::disk('media')->assertExists(ltrim($url, '/'));
});

it('liste les comptes pour un nouveau message', function () {
    $this->getJson('/v3/users/?q=')->assertOk()->assertJsonCount(12, 'data');
    $this->getJson('/v3/users/?q=zor')->assertJsonCount(1, 'data')->assertJsonPath('data.0.username', 'zora');
    $this->getJson('/v3/users/?q=camille')->assertJsonPath('data.0.is_following', true);
});

it('crée, renomme et supprime un tableau', function () {
    $id = $this->postJson('/v3/boards/', ['name' => 'Idées déco', 'secret' => true])
        ->assertCreated()
        ->assertJsonPath('data.secret', true)
        ->json('data.id');

    $this->postJson('/v3/boards/', ['name' => 'idees deco'])
        ->assertStatus(409)
        ->assertJsonPath('error', 'Vous avez déjà un tableau portant ce nom.');
    $this->postJson('/v3/boards/', ['name' => ''])
        ->assertJsonPath('error', 'Le nom du tableau est obligatoire.');

    $this->patchJson("/v3/boards/{$id}/", ['name' => 'Déco salon', 'secret' => false])
        ->assertOk()
        ->assertJsonPath('data.name', 'Déco salon')
        ->assertJsonPath('data.secret', false);
    $this->getJson('/v3/users/me/boards/')->assertJsonCount(1, 'data');

    // Supprimer le tableau retire aussi ses Épingles enregistrées.
    $this->postJson("/v3/boards/{$id}/pins/", ['pin_ids' => ['pin_10', 'pin_11']])->assertJsonPath('data.pin_count', 2);
    $this->deleteJson("/v3/boards/{$id}/")->assertOk();
    $this->getJson('/v3/users/me/')->assertJsonPath('data.saved_pins_count', 40);
    $this->getJson("/v3/boards/{$id}/")->assertNotFound();
});

it('organise des Épingles et les déplace d’un tableau à l’autre', function () {
    $a = $this->postJson('/v3/boards/', ['name' => 'A'])->json('data.id');
    $b = $this->postJson('/v3/boards/', ['name' => 'B'])->json('data.id');

    $this->postJson("/v3/boards/{$a}/pins/", ['pin_ids' => ['pin_10', 'pin_11', 'pin_17']])->assertJsonPath('data.pin_count', 3);
    $this->postJson("/v3/boards/{$b}/pins/", ['pin_ids' => ['pin_10']])->assertJsonPath('data.pin_count', 1);
    $this->getJson("/v3/boards/{$a}/")->assertJsonPath('data.pin_count', 2);

    $unorganized = collect($this->getJson('/v3/users/me/pins/saved/?unorganized=1')->json('data'))->pluck('id');
    expect($unorganized)->toHaveCount(39)->not->toContain('pin_10');

    $this->deleteJson("/v3/boards/{$a}/pins/pin_11/")->assertJsonPath('data.pin_count', 1);
    expect(collect($this->getJson('/v3/users/me/pins/saved/?unorganized=1')->json('data'))->pluck('id'))->toContain('pin_11');

    $this->postJson("/v3/boards/{$a}/pins/", ['pin_ids' => ['inconnue']])
        ->assertJsonPath('error', 'Une des Épingles n’existe plus.');
});

it('transforme un regroupement proposé en tableau', function () {
    $this->getJson('/v3/users/me/clusters/')
        ->assertOk()
        ->assertJsonCount(3, 'data')
        ->assertJsonPath('data.0', [
            'id' => 'cluster_fond_ecran',
            'name' => 'Fond d’écran',
            'pin_count' => 18,
            'cover_images' => ['/pins/10.jpg', '/pins/11.jpg', '/pins/17.jpg'],
        ]);

    $this->postJson('/v3/users/me/clusters/cluster_bord_de_mer/create/')
        ->assertCreated()
        ->assertJsonPath('data.name', 'Bord de mer')
        ->assertJsonPath('data.pin_count', 15);

    $names = collect($this->getJson('/v3/users/me/clusters/')->json('data'))->pluck('name');
    expect($names->all())->toBe(['Fond d’écran', 'Photographie']);
    $this->postJson('/v3/users/me/clusters/cluster_bord_de_mer/create/')->assertNotFound();
});
