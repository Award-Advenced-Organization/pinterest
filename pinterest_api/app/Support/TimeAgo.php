<?php

namespace App\Support;

use Carbon\CarbonInterface;

class TimeAgo
{
    /**
     * Durée courte à la manière de Pinterest : « À l’instant », « 5 min », « 3 h », « 2 j », « 1 sem. », puis « 03/26 ».
     */
    public static function short(?CarbonInterface $date): string
    {
        if ($date === null) {
            return '';
        }

        $minutes = (int) $date->diffInMinutes(now(), true);

        return match (true) {
            $minutes < 1 => 'À l’instant',
            $minutes < 60 => $minutes.' min',
            $minutes < 60 * 24 => intdiv($minutes, 60).' h',
            $minutes < 60 * 24 * 7 => intdiv($minutes, 60 * 24).' j',
            $minutes < 60 * 24 * 35 => intdiv($minutes, 60 * 24 * 7).' sem.',
            default => $date->format('m/y'),
        };
    }
}
