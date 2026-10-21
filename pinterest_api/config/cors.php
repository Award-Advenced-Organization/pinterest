<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    |
    | La version web de l'application (Flutter) appelle l'API et charge les images
    | depuis une autre origine : toutes les routes de l'API sont ouvertes.
    |
    */

    'paths' => ['v3/*', 'pins/*', 'uploads/*', 'health'],

    'allowed_methods' => ['*'],

    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,

];
