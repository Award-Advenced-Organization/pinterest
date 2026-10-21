<?php

namespace App\Http\Controllers;

use App\Http\Requests\SendMessageRequest;
use App\Http\Resources\ActivityResource;
use App\Http\Resources\ConversationResource;
use App\Http\Resources\InboxUpdateResource;
use App\Http\Resources\MessageResource;
use App\Models\Activity;
use App\Models\Conversation;
use App\Models\InboxUpdate;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/** Boîte de réception : activité, mises à jour et messagerie. */
class InboxController extends Controller
{
    public function activity(): JsonResponse
    {
        $items = Activity::query()->where('user_id', $this->me()->id)->with('actor')->orderBy('position')->get();

        return $this->ok(['data' => ActivityResource::collection($items)]);
    }

    public function updates(): JsonResponse
    {
        $items = InboxUpdate::query()
            ->where('user_id', $this->me()->id)
            ->whereNull('dismissed_at')
            ->orderBy('position')
            ->get();

        return $this->ok(['data' => InboxUpdateResource::collection($items)]);
    }

    /** « Masquer cette mise à jour ». */
    public function dismissUpdate(string $id): JsonResponse
    {
        InboxUpdate::query()->where('user_id', $this->me()->id)->findOrFail($id)->update(['dismissed_at' => now()]);

        return $this->ok();
    }

    /** Conversations, la plus récente d'abord. */
    public function conversations(): JsonResponse
    {
        $conversations = $this->me()->conversations()->with(['otherUser', 'messages.pin'])->get();

        return $this->ok(['data' => ConversationResource::collection($conversations)]);
    }

    /** Ouvre la conversation existante avec ce compte, ou en crée une. */
    public function openConversation(Request $request): JsonResponse
    {
        $me = $this->me();
        $data = $request->validate([
            'username' => ['required', 'string', Rule::exists('users', 'username')->whereNot('id', $me->id)],
        ], [
            'username.required' => 'Choisissez un destinataire.',
            'username.exists' => 'User not found',
        ]);
        $other = User::query()->where('username', $data['username'])->firstOrFail();

        $conversation = Conversation::query()->firstOrCreate(
            ['user_id' => $me->id, 'other_user_id' => $other->id],
            ['id' => 'conv_'.preg_replace('/[^a-z0-9]/i', '_', $other->username)],
        );

        return $this->ok(['data' => ConversationResource::make($conversation->load(['otherUser', 'messages.pin']))], 201);
    }

    public function sendMessage(SendMessageRequest $request, string $id): JsonResponse
    {
        $conversation = $this->me()->conversations()->findOrFail($id);

        $message = $conversation->messages()->create([
            'sender_id' => $this->me()->id,
            'text' => (string) $request->validated('text'),
            'pin_id' => $request->validated('pin_id'),
        ]);
        // La conversation remonte en tête de liste.
        $conversation->touch();

        return $this->ok(['data' => MessageResource::make($message->load('pin'))], 201);
    }
}
