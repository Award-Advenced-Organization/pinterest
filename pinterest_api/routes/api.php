<?php

use App\Http\Controllers\BoardController;
use App\Http\Controllers\ClusterController;
use App\Http\Controllers\FeedController;
use App\Http\Controllers\InboxController;
use App\Http\Controllers\MediaController;
use App\Http\Controllers\PinActionController;
use App\Http\Controllers\PinController;
use App\Http\Controllers\SearchController;
use App\Http\Controllers\UserController;
use App\Models\Pin;
use Illuminate\Support\Facades\Route;

/*
| API de l'application mobile, compatible avec l'ancien backend Node (mêmes adresses /v3/…).
| Laravel ignore la barre oblique finale : « /v3/feeds/home/ » et « /v3/feeds/home » sont équivalents.
*/

Route::prefix('v3')->group(function () {
    Route::get('feeds/home', [FeedController::class, 'home']);

    Route::controller(PinController::class)->group(function () {
        Route::post('pins', 'store');
        Route::get('pins/{id}', 'show');
        Route::delete('pins/{id}', 'destroy');
    });

    Route::controller(PinActionController::class)->prefix('pins/{id}')->group(function () {
        Route::post('save', 'save');
        Route::delete('save', 'unsave');
        Route::post('like', 'like');
        Route::post('hide', 'hide');
        Route::delete('hide', 'unhide');
        Route::post('comments', 'comment');
    });

    Route::controller(SearchController::class)->prefix('search')->group(function () {
        Route::get('/', 'index');
        Route::get('visual', 'visual');
        Route::get('ideas', 'ideas');
    });

    Route::controller(UserController::class)->prefix('users')->group(function () {
        Route::get('/', 'index');
        Route::patch('me', 'update');
        Route::post('me/avatar', 'avatar');
        Route::get('me/pins/saved', 'savedPins');
        Route::get('{username}', 'show');
        Route::post('{username}/follow', 'follow');
        Route::get('{username}/pins/created', 'createdPins');
        Route::get('{username}/boards', 'boards');
    });

    Route::controller(ClusterController::class)->prefix('users/me/clusters')->group(function () {
        Route::get('/', 'index');
        Route::post('{id}/create', 'createBoard');
    });

    Route::controller(BoardController::class)->prefix('boards')->group(function () {
        Route::post('/', 'store');
        Route::get('{id}', 'show');
        Route::patch('{id}', 'update');
        Route::delete('{id}', 'destroy');
        Route::get('{id}/pins', 'pins');
        Route::post('{id}/pins', 'addPins');
        Route::delete('{id}/pins/{pinId}', 'removePin');
    });

    Route::controller(InboxController::class)->group(function () {
        Route::get('activity', 'activity');
        Route::get('notifications', 'updates');
        Route::delete('notifications/{id}', 'dismissUpdate');
        Route::get('conversations', 'conversations');
        Route::post('conversations', 'openConversation');
        Route::post('conversations/{id}/messages', 'sendMessage');
    });
});

// Images du fil et envois depuis l'application.
Route::get('{folder}/{file}', [MediaController::class, 'show'])
    ->whereIn('folder', ['pins', 'uploads'])
    ->where('file', '[A-Za-z0-9._-]+');

Route::get('health', fn () => response()->json([
    'status' => 'ok',
    'service' => 'pinterest-api-backend',
    'version' => '3.0.0',
    'framework' => 'Laravel '.app()->version(),
    'total_pins' => Pin::query()->count(),
    'active_user' => app('pinterest.me')->username,
]));
