<?php

use App\Models\Pin;
use Illuminate\Support\Facades\Storage;

it('pagine le fil d’accueil au format attendu par l’application', function () {
    $first = $this->getJson('/v3/feeds/home/?page=1&page_size=20')
        ->assertOk()
        ->assertJsonPath('status', 'success')
        ->assertJsonPath('total', 118)
        ->assertJsonPath('bookmark', '2')
        ->assertJsonCount(20, 'data')
        ->assertJsonStructure(['data' => [[
            'id', 'title', 'image_url', 'width', 'height', 'aspect_ratio', 'dominant_color',
            'creator' => ['id', 'name', 'username', 'avatar_url'],
            'is_saved', 'board_id', 'liked', 'like_count', 'comment_count', 'is_carousel',
        ]]]);

    expect($first->json('data.0.id'))->toBeString();

    $this->getJson('/v3/feeds/home?page=6&page_size=20')
        ->assertOk()
        ->assertJsonPath('bookmark', null)
        ->assertJsonCount(18, 'data');
});

it('affiche le détail d’une Épingle avec commentaires et Épingles similaires', function () {
    $this->getJson('/v3/pins/pin_12/')
        ->assertOk()
        ->assertJsonPath('data.id', 'pin_12')
        ->assertJsonPath('data.is_mine', false)
        ->assertJsonPath('data.is_saved', true)
        ->assertJsonCount(2, 'data.comments')
        ->assertJsonCount(20, 'data.related_pins')
        ->assertJsonPath('data.related_pins.0.category', 'mer');
});

it('renvoie une erreur lisible pour une Épingle inconnue', function () {
    $this->getJson('/v3/pins/inconnue/')
        ->assertNotFound()
        ->assertExactJson(['error' => 'Ressource introuvable.']);
});

it('enregistre, range dans un tableau puis retire une Épingle', function () {
    $board = $this->postJson('/v3/boards/', ['name' => 'Voyage'])->assertCreated()->json('data.id');

    $this->postJson('/v3/pins/pin_49/save/', ['board_id' => $board])
        ->assertOk()
        ->assertJson(['is_saved' => true, 'board_id' => $board, 'board_name' => 'Voyage']);
    $this->getJson('/v3/pins/pin_49/')->assertJsonPath('data.board_id', $board);

    // Sans tableau : l'Épingle revient dans « Idées non organisées ».
    $this->postJson('/v3/pins/pin_49/save/', ['board_id' => null])->assertJsonPath('board_id', null);
    $this->getJson("/v3/boards/{$board}/pins/")->assertJsonCount(0, 'data');

    $this->deleteJson('/v3/pins/pin_49/save/')->assertJson(['is_saved' => false]);
    $this->getJson('/v3/pins/pin_49/')->assertJsonPath('data.is_saved', false);
});

it('refuse d’enregistrer dans un tableau qui n’existe pas', function () {
    $this->postJson('/v3/pins/pin_49/save/', ['board_id' => 'board_inconnu'])
        ->assertUnprocessable()
        ->assertJsonPath('error', 'Ce tableau n’existe pas.');
});

it('bascule le j’aime et met à jour le compteur', function () {
    $base = Pin::find('pin_49')->base_like_count;

    $this->postJson('/v3/pins/pin_49/like/')->assertJson(['liked' => true, 'like_count' => $base + 1]);
    $this->postJson('/v3/pins/pin_49/like/')->assertJson(['liked' => false, 'like_count' => $base]);
});

it('masque une Épingle du fil et peut l’y remettre', function () {
    $this->postJson('/v3/pins/pin_45/hide/')->assertJson(['hidden' => true]);
    $ids = collect([1, 2])->flatMap(fn (int $page) => $this->getJson("/v3/feeds/home?page={$page}&page_size=100")
        ->assertJsonPath('total', 117)
        ->json('data'))->pluck('id');
    expect($ids)->not->toContain('pin_45')->toHaveCount(117);

    $this->deleteJson('/v3/pins/pin_45/hide/')->assertJson(['hidden' => false]);
    $this->getJson('/v3/feeds/home')->assertJsonPath('total', 118);
});

it('ajoute un commentaire et refuse un commentaire vide', function () {
    $this->postJson('/v3/pins/pin_49/comments/', ['text' => '  Superbe !  '])
        ->assertCreated()
        ->assertJsonPath('data.text', 'Superbe !')
        ->assertJsonPath('data.author', 'Jaye ahf')
        ->assertJsonPath('data.mine', true)
        ->assertJsonPath('data.time_ago', 'À l’instant')
        ->assertJsonPath('comment_count', 1);

    $this->postJson('/v3/pins/pin_49/comments/', ['text' => '   '])
        ->assertUnprocessable()
        ->assertJsonPath('error', 'Le commentaire est vide.');
});

it('publie une Épingle avec une image de l’appareil', function () {
    Storage::fake('media');

    $response = $this->post('/v3/pins/', [
        'image' => jpegUpload(),
        'title' => 'Mon essai',
        'link' => 'https://example.com',
        'width' => 600,
        'height' => 800,
        'dominant_color' => '#336699',
    ], ['Accept' => 'application/json'])->assertCreated();

    $pin = $response->json('data');
    expect($pin['id'])->toStartWith('pin_user_')
        ->and($pin['image_url'])->toStartWith('/uploads/up_')
        ->and($pin['creator']['username'])->toBe('ahiffent')
        ->and($pin['is_saved'])->toBeTrue();
    Storage::disk('media')->assertExists(ltrim($pin['image_url'], '/'));

    // En tête du fil, dans « Créées » et dans les Épingles enregistrées.
    $this->getJson('/v3/feeds/home')->assertJsonPath('data.0.id', $pin['id']);
    $this->getJson('/v3/users/me/pins/created/')->assertJsonPath('data.0.id', $pin['id']);
    $this->getJson('/v3/users/me/pins/saved/')->assertJsonPath('data.0.id', $pin['id']);

    // Seul son auteur peut la supprimer, et l'image disparaît avec elle.
    $this->deleteJson("/v3/pins/{$pin['id']}/")->assertOk();
    Storage::disk('media')->assertMissing(ltrim($pin['image_url'], '/'));
    $this->deleteJson('/v3/pins/pin_49/')->assertForbidden()
        ->assertJsonPath('error', 'Vous ne pouvez supprimer que vos propres Épingles.');
});

it('publie un collage à partir d’images existantes', function () {
    $this->postJson('/v3/pins/', [
        'title' => 'Collage',
        'image_url' => '/pins/10.jpg',
        'collage_images' => json_encode(['/pins/10.jpg', '/pins/11.jpg', '/pins/12.jpg']),
    ])->assertCreated()->assertJsonPath('data.collage_images', ['/pins/10.jpg', '/pins/11.jpg', '/pins/12.jpg']);
});

it('refuse une Épingle sans image ou avec un lien invalide', function () {
    $this->postJson('/v3/pins/', ['title' => 'Sans image'])
        ->assertUnprocessable()
        ->assertJsonPath('error', 'Choisissez une image pour votre Épingle.');

    $this->postJson('/v3/pins/', ['image_url' => '/pins/10.jpg', 'link' => 'pas un lien'])
        ->assertUnprocessable()
        ->assertJsonPath('error', 'Ce lien ne semble pas valide.');
});
