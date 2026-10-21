<?php

namespace App\Http\Controllers;

use App\Http\Resources\BoardResource;
use App\Models\Board;
use App\Models\Cluster;
use App\Models\Pin;
use App\Support\Text;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/** Regroupements proposés sur le profil (« Fond d’écran », « Bord de mer »…). */
class ClusterController extends Controller
{
    /** Regroupements d'au moins 3 Épingles non classées. */
    public function index(): JsonResponse
    {
        $unorganized = $this->unorganizedPins();

        $data = $this->me()->clusters()->whereNull('dismissed_at')->get()
            ->map(fn (Cluster $c) => [$c, $c->matching($unorganized)])
            ->filter(fn (array $pair) => $pair[1]->count() >= 3)
            ->map(fn (array $pair) => [
                'id' => $pair[0]->id,
                'name' => $pair[0]->name,
                'pin_count' => $pair[1]->count(),
                'cover_images' => $pair[1]->take(3)->pluck('image_url')->values(),
            ])
            ->values();

        return $this->ok(['data' => $data]);
    }

    /** « Créer » : fait du regroupement un tableau contenant ses Épingles. */
    public function createBoard(string $id): JsonResponse
    {
        $me = $this->me();
        $cluster = $me->clusters()->whereNull('dismissed_at')->findOrFail($id);
        if ($this->nameTaken($cluster->name)) {
            return $this->fail('Vous avez déjà un tableau portant ce nom.', 409);
        }

        $board = DB::transaction(function () use ($me, $cluster) {
            $board = Board::create([
                'id' => 'board_'.Str::lower((string) Str::ulid()),
                'user_id' => $me->id,
                'name' => $cluster->name,
            ]);
            $board->pins()->attach(
                $cluster->matching($this->unorganizedPins())->mapWithKeys(fn (Pin $p) => [$p->id => ['created_at' => now()]])->all(),
            );
            $cluster->update(['dismissed_at' => now()]);

            return $board;
        });

        return $this->ok(['data' => BoardResource::make($board)], 201);
    }

    /**
     * @return Collection<int, Pin>
     */
    private function unorganizedPins(): Collection
    {
        $me = $this->me();

        return Pin::query()
            ->join('saves', 'saves.pin_id', '=', 'pins.id')
            ->where('saves.user_id', $me->id)
            ->whereDoesntHave('boards', fn (Builder $q) => $q->where('boards.user_id', $me->id))
            ->orderBy('saves.created_at')
            ->select('pins.*')
            ->get();
    }

    private function nameTaken(string $name): bool
    {
        return $this->me()->boards()->get()->contains(fn (Board $b) => Text::searchable($b->name) === Text::searchable($name));
    }
}
