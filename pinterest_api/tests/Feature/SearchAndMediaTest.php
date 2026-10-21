<?php

it('trouve les Épingles sans tenir compte des accents ni des apostrophes', function () {
    $count = $this->getJson('/v3/search/?q=fond%20d%27ecran')->assertOk()->json('count');
    expect($count)->toBeGreaterThan(5);

    $this->getJson('/v3/search/?q=bord%20de%20mer')
        ->assertOk()
        ->assertJsonPath('query', 'bord de mer')
        ->assertJsonPath('data.0.category', 'mer');

    $this->getJson('/v3/search/?q=Lamborghini')->assertJson(['count' => 0, 'data' => []]);
});

it('cherche aussi par nom de créateur', function () {
    $pins = $this->getJson('/v3/search/?q=lea%20martin')->json('data');
    expect($pins)->not->toBeEmpty();
    expect(collect($pins)->pluck('creator.username')->unique()->all())->toBe(['lea.martin']);
});

it('trie la recherche par image selon la couleur la plus proche', function () {
    $pins = $this->getJson('/v3/search/visual/?color=%23336699')->assertOk()->assertJsonCount(30, 'data')->json('data');
    expect($pins[0]['dominant_color'])->toBe('#2c8aaa');

    $this->getJson('/v3/search/visual/?color=bleu')
        ->assertUnprocessable()
        ->assertJsonPath('error', 'color=#rrggbb required');
});

it('fournit les cartes de la page Rechercher', function () {
    $this->getJson('/v3/search/ideas/')
        ->assertOk()
        ->assertJsonCount(8, 'data.ideas')
        ->assertJsonCount(4, 'data.popular')
        ->assertJsonPath('data.ideas.0', ['title' => 'Fond d’écran nature', 'query' => 'fond d’écran', 'image' => '/pins/83.jpg']);
});

it('sert les images avec les en-têtes CORS', function () {
    $this->get('/pins/10.jpg', ['Origin' => 'http://localhost:8090'])
        ->assertOk()
        ->assertHeader('Content-Type', 'image/jpeg')
        ->assertHeader('Access-Control-Allow-Origin', '*');

    $this->get('/uploads/avatar_jaye.jpg')->assertOk();
    $this->getJson('/pins/absente.jpg')->assertNotFound();
    $this->get('/pins/..%2F..%2F.env')->assertNotFound();
});

it('répond au contrôle de santé', function () {
    $this->getJson('/health')->assertOk()->assertJson([
        'status' => 'ok',
        'total_pins' => 118,
        'active_user' => 'ahiffent',
    ]);
});
