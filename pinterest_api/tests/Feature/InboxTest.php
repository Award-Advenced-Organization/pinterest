<?php

it('liste l’activité avec l’état d’abonnement', function () {
    $this->getJson('/v3/activity/')
        ->assertOk()
        ->assertJsonCount(2, 'data')
        ->assertJsonPath('data.0.type', 'suggestion')
        ->assertJsonPath('data.0.user.username', 'alassanemomo')
        ->assertJsonPath('data.0.user.is_following', false)
        ->assertJsonPath('data.1.time_ago', '03/26');
});

it('liste et masque les mises à jour', function () {
    $this->getJson('/v3/notifications/')->assertJsonCount(4, 'data')->assertJsonPath('data.0.query', 'bord de mer');

    $this->deleteJson('/v3/notifications/notif_01/')->assertOk();
    $this->getJson('/v3/notifications/')->assertJsonCount(3, 'data');
    $this->deleteJson('/v3/notifications/inconnue/')->assertNotFound();
});

it('affiche la conversation de départ', function () {
    $this->getJson('/v3/conversations/')
        ->assertOk()
        ->assertJsonPath('data.0.id', 'conv_camille')
        ->assertJsonPath('data.0.with_user.username', 'camille_design')
        ->assertJsonPath('data.0.last_message', 'Super ton tableau Bord de mer !')
        ->assertJsonPath('data.0.time_ago', '3 j')
        ->assertJsonPath('data.0.messages.1', ['from' => 'me', 'text' => 'Oui, magnifiques ! Je les ai enregistrées.', 'time' => '14:22']);
});

it('ouvre une seule conversation par personne et envoie messages et Épingles', function () {
    $id = $this->postJson('/v3/conversations/', ['username' => 'zora'])
        ->assertCreated()
        ->assertJsonPath('data.messages', [])
        ->json('data.id');
    expect($this->postJson('/v3/conversations/', ['username' => 'zora'])->json('data.id'))->toBe($id);

    $this->postJson("/v3/conversations/{$id}/messages/", ['text' => 'Salut ! 👋'])
        ->assertCreated()
        ->assertJsonPath('data.from', 'me')
        ->assertJsonPath('data.text', 'Salut ! 👋');

    $this->postJson("/v3/conversations/{$id}/messages/", ['text' => '', 'pin_id' => 'pin_60'])
        ->assertCreated()
        ->assertJsonPath('data.pin_id', 'pin_60')
        ->assertJsonPath('data.pin_image', '/pins/60.jpg');

    // La conversation la plus récente passe en tête.
    $this->getJson('/v3/conversations/')
        ->assertJsonPath('data.0.id', $id)
        ->assertJsonPath('data.0.last_message', 'A envoyé une Épingle')
        ->assertJsonPath('data.0.time_ago', 'À l’instant');
});

it('refuse les messages vides et les destinataires inconnus', function () {
    $this->postJson('/v3/conversations/conv_camille/messages/', ['text' => '  '])
        ->assertUnprocessable()
        ->assertJsonPath('error', 'Le message est vide.');
    $this->postJson('/v3/conversations/', ['username' => 'personne'])->assertUnprocessable();
    $this->postJson('/v3/conversations/', ['username' => 'ahiffent'])->assertUnprocessable();
    $this->postJson('/v3/conversations/inconnue/messages/', ['text' => 'Hé'])->assertNotFound();
});
