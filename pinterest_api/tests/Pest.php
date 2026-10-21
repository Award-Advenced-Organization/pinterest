<?php

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Tests\TestCase;

pest()->extend(TestCase::class)
    ->use(RefreshDatabase::class)
    ->in('Feature');

/** Vraie photo JPEG du fil, envoyée comme depuis l'appareil (sans dépendre de l'extension GD). */
function jpegUpload(string $name = 'photo.jpg'): UploadedFile
{
    return UploadedFile::fake()->createWithContent($name, file_get_contents(storage_path('app/media/pins/10.jpg')));
}
