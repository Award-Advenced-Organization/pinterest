<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

/** Carte de la page Rechercher (« Des idées pour vous », « Populaire sur Pinterest »). */
#[Fillable(['section', 'title', 'query', 'image', 'position'])]
class SearchIdea extends Model {}
