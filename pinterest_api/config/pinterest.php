<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Compte utilisé par l'application
    |--------------------------------------------------------------------------
    |
    | L'application mobile n'a pas d'écran de connexion : toutes les actions sont
    | faites au nom de ce compte (créé par le seeder).
    |
    */

    'me_id' => env('PINTEREST_ME_ID', 'usr_jaye_ahf_01'),

    /*
    | Dossier des images servies sous /pins/… et /uploads/… (avec en-têtes CORS).
    */

    'media_path' => storage_path('app/media'),

];
