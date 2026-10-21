<?php

namespace App\Http\Controllers;

use App\Http\Requests\BoardRequest;
use App\Http\Resources\BoardResource;
use App\Http\Resources\PinResource;
use App\Models\Board;
use App\Models\Pin;
use App\Support\Text;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/** Tableaux du compte de l'application. */
class BoardController extends Controller
{
    public function store(BoardRequest $request): JsonResponse
    {
        $data = $request->validated();
        if ($this->nameTaken($data['name'])) {
            return $this->fail('Vous avez déjà un tableau portant ce nom.', 409);
        }

        $board = Board::create([
            'id' => 'board_'.Str::lower((string) Str::ulid()),
            'user_id' => $this->me()->id,
            'name' => $data['name'],
            'secret' => (bool) ($data['secret'] ?? false),
            'description' => $data['description'] ?? '',
        ]);

        return $this->ok(['data' => BoardResource::make($board)], 201);
    }

    public function show(string $id): JsonResponse
    {
        return $this->ok(['data' => BoardResource::make($this->board($id))]);
    }

    public function update(BoardRequest $request, string $id): JsonResponse
    {
        $board = $this->board($id);
        $data = $request->validated();
        if (isset($data['name']) && $this->nameTaken($data['name'], except: $board)) {
            return $this->fail('Vous avez déjà un tableau portant ce nom.', 409);
        }
        if (array_key_exists('description', $data)) {
            $data['description'] ??= '';
        }
        $board->update($data);

        return $this->ok(['data' => BoardResource::make($board)]);
    }

    /** Comme sur Pinterest : supprimer un tableau retire aussi ses Épingles enregistrées. */
    public function destroy(string $id): JsonResponse
    {
        $board = $this->board($id);

        DB::transaction(function () use ($board): void {
            $this->me()->savedPins()->detach($board->pins()->pluck('pins.id'));
            $board->delete();
        });

        return $this->ok();
    }

    public function pins(string $id): JsonResponse
    {
        $board = $this->board($id);
        $pins = Pin::query()->forViewer($this->me())
            ->join('board_pin', 'board_pin.pin_id', '=', 'pins.id')
            ->where('board_pin.board_id', $board->id)
            ->orderByDesc('board_pin.created_at')
            ->get();

        return $this->ok(['data' => PinResource::collection($pins)]);
    }

    /** « Organiser » : range des Épingles dans ce tableau (en les retirant des autres). */
    public function addPins(Request $request, string $id): JsonResponse
    {
        $board = $this->board($id);
        $data = $request->validate([
            'pin_ids' => ['required', 'array', 'min:1', 'max:200'],
            'pin_ids.*' => ['string', 'distinct', 'exists:pins,id'],
        ], [
            'pin_ids.required' => 'Sélectionnez au moins une Épingle.',
            'pin_ids.*.exists' => 'Une des Épingles n’existe plus.',
        ]);
        $ids = $data['pin_ids'];

        DB::transaction(function () use ($board, $ids): void {
            DB::table('board_pin')
                ->whereIn('pin_id', $ids)
                ->whereIn('board_id', $this->me()->boards()->select('id'))
                ->delete();
            $now = now();
            $board->pins()->attach(collect($ids)->mapWithKeys(fn (string $id) => [$id => ['created_at' => $now]])->all());
            $this->me()->savedPins()->syncWithoutDetaching(collect($ids)->mapWithKeys(fn (string $id) => [$id => ['created_at' => $now]])->all());
        });

        return $this->ok(['data' => BoardResource::make($board)]);
    }

    /** Retire une Épingle du tableau ; elle reste enregistrée dans « Idées non organisées ». */
    public function removePin(string $id, string $pinId): JsonResponse
    {
        $board = $this->board($id);
        $board->pins()->detach($pinId);

        return $this->ok(['data' => BoardResource::make($board)]);
    }

    private function board(string $id): Board
    {
        return $this->me()->boards()->findOrFail($id);
    }

    private function nameTaken(string $name, ?Board $except = null): bool
    {
        return $this->me()->boards()->get()->contains(fn (Board $b) => $b->id !== $except?->id
            && Text::searchable($b->name) === Text::searchable($name));
    }
}
