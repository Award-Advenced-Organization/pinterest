<?php

namespace App\Support;

use Illuminate\Support\Str;

class Text
{
    /**
     * Minuscules, sans accents ni apostrophes : « Fond d’écran » devient « fond d ecran ».
     * SQLite ne sait pas ignorer les accents, la recherche compare donc ces formes.
     */
    public static function searchable(?string $value): string
    {
        $value = str_replace(['’', "'"], ' ', (string) $value);

        return trim(preg_replace('/\s+/', ' ', Str::lower(Str::ascii($value))));
    }

    /**
     * Mots d'au moins deux lettres d'une recherche, normalisés.
     *
     * @return list<string>
     */
    public static function words(?string $query): array
    {
        return array_values(array_filter(
            explode(' ', self::searchable($query)),
            fn (string $w) => mb_strlen($w) > 1,
        ));
    }
}
