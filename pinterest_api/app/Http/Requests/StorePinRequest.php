<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/** Création d'une Épingle : image envoyée depuis l'appareil, ou image existante (collage). */
class StorePinRequest extends FormRequest
{
    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'image' => ['required_without:image_url', 'file', 'image', 'max:15360'],
            'image_url' => ['required_without:image', 'nullable', 'string', 'regex:#^/(pins|uploads)/[A-Za-z0-9._-]+$#'],
            'title' => ['nullable', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:800'],
            'link' => ['nullable', 'url:http,https', 'max:500'],
            'board_id' => ['nullable', 'string', Rule::exists('boards', 'id')->where('user_id', config('pinterest.me_id'))],
            'collage_images' => ['nullable', 'json'],
            'width' => ['nullable', 'integer', 'min:1', 'max:20000'],
            'height' => ['nullable', 'integer', 'min:1', 'max:20000'],
            'dominant_color' => ['nullable', 'regex:/^#[0-9a-fA-F]{6}$/'],
        ];
    }

    /**
     * Images d'un collage (2 à 4 chemins d'images existantes), ou null.
     *
     * @return list<string>|null
     */
    public function collageImages(): ?array
    {
        $images = json_decode((string) $this->input('collage_images'), true);
        if (! is_array($images)) {
            return null;
        }
        $images = array_values(array_filter($images, fn ($u) => is_string($u) && preg_match('#^/(pins|uploads)/[A-Za-z0-9._-]+$#', $u)));

        return count($images) > 1 ? array_slice($images, 0, 4) : null;
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'image.required_without' => 'Choisissez une image pour votre Épingle.',
            'image_url.required_without' => 'Choisissez une image pour votre Épingle.',
            'image.image' => 'Le fichier choisi n’est pas une image.',
            'image.max' => 'L’image dépasse 15 Mo.',
            'image_url.regex' => 'Image introuvable.',
            'title.max' => 'Le titre ne doit pas dépasser 100 caractères.',
            'description.max' => 'La description ne doit pas dépasser 800 caractères.',
            'link.url' => 'Ce lien ne semble pas valide.',
            'board_id.exists' => 'Ce tableau n’existe pas.',
        ];
    }
}
