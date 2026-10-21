<?php

namespace App\Http\Controllers;

use App\Http\Resources\PinResource;
use App\Models\Pin;
use App\Models\SearchIdea;
use App\Support\Text;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    /** Recherche par mots-clés : chaque mot doit apparaître dans le titre, les mots-clés, la catégorie ou le créateur. */
    public function index(Request $request): JsonResponse
    {
        $query = $this->visiblePins()->orderBy('feed_rank');

        if ($category = $request->query('category')) {
            $query->where('category', (string) $category);
        }
        foreach (Text::words((string) $request->query('q')) as $word) {
            $query->where('search_text', 'like', '%'.str_replace(['%', '_'], '', $word).'%');
        }
        $pins = $query->get();

        return $this->ok([
            'query' => (string) $request->query('q', ''),
            'count' => $pins->count(),
            'data' => PinResource::collection($pins),
        ]);
    }

    /** Recherche par image : les Épingles dont la couleur dominante est la plus proche. */
    public function visual(Request $request): JsonResponse
    {
        $request->validate(['color' => ['required', 'regex:/^#?[0-9a-fA-F]{6}$/']], [
            'color.required' => 'color=#rrggbb required',
            'color.regex' => 'color=#rrggbb required',
        ]);
        $target = $this->rgb((string) $request->query('color'));

        $pins = $this->visiblePins()->get()
            ->sortBy(fn (Pin $pin) => array_sum(array_map(
                fn (int $a, int $b) => ($a - $b) ** 2,
                $this->rgb($pin->dominant_color),
                $target,
            )))
            ->take(30)
            ->values();

        return $this->ok(['count' => $pins->count(), 'data' => PinResource::collection($pins)]);
    }

    /** Cartes de la page Rechercher. */
    public function ideas(): JsonResponse
    {
        $ideas = SearchIdea::query()->orderBy('position')->get()->groupBy('section');
        $map = fn (string $section) => ($ideas[$section] ?? collect())
            ->map(fn (SearchIdea $i) => ['title' => $i->title, 'query' => $i->query, 'image' => $i->image])
            ->values();

        return $this->ok(['data' => ['ideas' => $map('ideas'), 'popular' => $map('popular')]]);
    }

    /**
     * @return array{int, int, int}
     */
    private function rgb(string $hex): array
    {
        $hex = ltrim($hex, '#');

        return [hexdec(substr($hex, 0, 2)), hexdec(substr($hex, 2, 2)), hexdec(substr($hex, 4, 2))];
    }
}
