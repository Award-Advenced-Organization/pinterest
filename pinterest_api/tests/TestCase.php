<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /** Chaque test part des données de départ (PinterestSeeder). */
    protected bool $seed = true;
}
