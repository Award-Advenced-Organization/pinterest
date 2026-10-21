<?php

namespace Database\Seeders;

use App\Models\Activity;
use App\Models\Cluster;
use App\Models\Comment;
use App\Models\Conversation;
use App\Models\InboxUpdate;
use App\Models\Message;
use App\Models\Pin;
use App\Models\SearchIdea;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Données de départ, identiques à l'ancien backend Node (exportées dans data/pinterest.json) :
 * le compte, les créateurs, les 118 Épingles, les Épingles enregistrées, la boîte de réception…
 */
class PinterestSeeder extends Seeder
{
    public function run(): void
    {
        $data = json_decode(file_get_contents(__DIR__.'/data/pinterest.json'), true, flags: JSON_THROW_ON_ERROR);

        DB::transaction(function () use ($data): void {
            $me = $this->seedUsers($data);
            $this->seedPins($data['pins']);
            $this->seedSaves($me, $data['saved']);
            $this->seedComments($data['comments']);
            $this->seedInbox($me, $data);
            $this->seedDiscovery($me, $data);
        });
    }

    private function seedUsers(array $data): User
    {
        $m = $data['me'];
        $me = User::create([
            'id' => $m['id'],
            'username' => $m['username'],
            'name' => $m['full_name'],
            'avatar_url' => '/uploads/avatar_jaye.jpg',
            'website' => $m['website'],
            'country_code' => $m['country_code'],
            'appearance' => $m['appearance'],
            'pronouns' => [],
            'base_follower_count' => $m['follower_count'],
        ]);

        foreach ([...$data['creators'], ...$data['others']] as $u) {
            $seed = strlen($u['username']) * 37;
            User::create([
                'id' => $u['id'],
                'username' => $u['username'],
                'name' => $u['name'],
                'avatar_url' => $u['avatar_url'] ?? '',
                'base_follower_count' => 120 + $seed % 900,
                'base_following_count' => 20 + $seed % 80,
            ]);
        }

        // Abonnements de départ du compte (« 2 abonné(e)s » sur le profil).
        $me->following()->attach(User::whereIn('username', ['camille_design', 'lea.martin'])->pluck('id'));

        return $me;
    }

    private function seedPins(array $pins): void
    {
        foreach ($pins as $p) {
            Pin::create([
                ...collect($p)->except('days_ago')->all(),
                'created_at' => now()->subDays($p['days_ago']),
            ]);
        }
    }

    private function seedSaves(User $me, array $saved): void
    {
        // Dernière de la liste = enregistrée le plus récemment.
        $count = count($saved);
        foreach ($saved as $i => $pinId) {
            $me->savedPins()->attach($pinId, ['created_at' => now()->subMinutes($count - $i)]);
        }
    }

    private function seedComments(array $comments): void
    {
        $delays = [now()->subDays(2), now()->subHours(5)];
        $pins = Pin::query()->pluck('id')->filter(fn (string $id) => ((int) preg_replace('/\D/', '', $id)) % 3 === 0);

        foreach ($pins as $pinId) {
            foreach ($comments as $i => $c) {
                Comment::create([
                    'id' => "{$c['id']}_{$pinId}",
                    'pin_id' => $pinId,
                    'user_id' => User::where('username', $c['username'])->value('id'),
                    'text' => $c['text'],
                    'created_at' => $delays[$i] ?? now(),
                ]);
            }
        }
    }

    private function seedInbox(User $me, array $data): void
    {
        foreach ($data['activity'] as $i => $a) {
            Activity::create([
                'id' => $a['id'],
                'user_id' => $me->id,
                'actor_id' => User::where('username', $a['user'])->value('id'),
                'type' => $a['type'],
                'text' => $a['text'],
                'time_label' => $a['time_ago'],
                'position' => $i,
            ]);
        }

        foreach ($data['notifications'] as $i => $n) {
            InboxUpdate::create([
                'id' => $n['id'],
                'user_id' => $me->id,
                'text' => $n['text'],
                'query' => $n['query'],
                'image_url' => $n['image_url'] ?? null,
                'icon' => $n['icon'] ?? null,
                'time_label' => $n['time_ago'],
                'position' => $i,
            ]);
        }

        foreach ($data['conversations'] as $c) {
            $other = User::where('username', $c['with_user']['username'])->firstOrFail();
            // Il y a 3 jours, aux heures des messages ; la veille si ces heures ne sont pas encore passées.
            $lastTime = explode(':', end($c['messages'])['time']);
            $day = now()->subDays(3)->startOfDay();
            if ($day->copy()->setTime((int) $lastTime[0], (int) $lastTime[1])->gt(now()->subDays(3))) {
                $day->subDay();
            }
            $conversation = Conversation::create([
                'id' => $c['id'],
                'user_id' => $me->id,
                'other_user_id' => $other->id,
                'created_at' => $day,
                'updated_at' => $day,
            ]);
            foreach ($c['messages'] as $m) {
                [$h, $min] = explode(':', $m['time']);
                $at = $day->copy()->setTime((int) $h, (int) $min);
                Message::create([
                    'conversation_id' => $conversation->id,
                    'sender_id' => $m['from'] === 'me' ? $me->id : $other->id,
                    'text' => $m['text'],
                    'created_at' => $at,
                    'updated_at' => $at,
                ]);
                $conversation->forceFill(['updated_at' => $at])->saveQuietly();
            }
        }
    }

    private function seedDiscovery(User $me, array $data): void
    {
        foreach ($data['clusters'] as $i => $c) {
            Cluster::create([
                'id' => $c['id'],
                'user_id' => $me->id,
                'name' => $c['name'],
                'tag' => $c['tag'] ?? null,
                'category' => $c['category'] ?? null,
                'position' => $i,
            ]);
        }

        foreach (['ideas', 'popular'] as $section) {
            foreach ($data['ideas'][$section] as $i => $idea) {
                SearchIdea::create([...$idea, 'section' => $section, 'position' => $i]);
            }
        }
    }
}
