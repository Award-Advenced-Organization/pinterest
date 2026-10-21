<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/** « Modifier le profil » et choix de l'apparence. */
class UpdateProfileRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('username')) {
            $this->merge(['username' => mb_strtolower(trim((string) $this->input('username')))]);
        }
        if ($this->has('full_name')) {
            $this->merge(['full_name' => trim((string) $this->input('full_name'))]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'full_name' => ['sometimes', 'required', 'string', 'max:60'],
            'username' => [
                'sometimes', 'required', 'regex:/^[a-z0-9._]{3,30}$/',
                Rule::unique('users', 'username')->ignore(config('pinterest.me_id')),
            ],
            'email' => ['sometimes', 'nullable', 'email', 'max:120'],
            'website' => ['sometimes', 'nullable', 'string', 'max:200'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:500'],
            'pronouns' => ['sometimes', 'array', 'max:2'],
            'pronouns.*' => ['string', Rule::in(['elle', 'il', 'iel', 'elles', 'ils'])],
            'phone' => ['sometimes', 'nullable', 'regex:/^[0-9 +().-]{0,15}$/'],
            'country_code' => ['sometimes', 'regex:/^\+[0-9]{1,4}$/'],
            'appearance' => ['sometimes', Rule::in(['system', 'light', 'dark'])],
        ];
    }

    /**
     * Champs validés sous les noms des colonnes (« full_name » devient « name »).
     *
     * @return array<string, mixed>
     */
    public function attributesToSave(): array
    {
        $data = $this->validated();
        if (array_key_exists('full_name', $data)) {
            $data['name'] = $data['full_name'];
            unset($data['full_name']);
        }

        // Les colonnes texte ne sont jamais nulles : un champ vidé devient une chaîne vide.
        return array_map(fn ($v) => $v ?? '', $data);
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'full_name.required' => 'Le nom ne peut pas être vide.',
            'full_name.max' => 'Le nom ne doit pas dépasser 60 caractères.',
            'username.required' => 'Le nom d’utilisateur ne peut pas être vide.',
            'username.regex' => 'Nom d’utilisateur invalide (3 à 30 caractères : lettres, chiffres, point, tiret bas).',
            'username.unique' => 'Ce nom d’utilisateur est déjà pris.',
            'email.email' => 'Adresse e-mail invalide.',
            'bio.max' => 'La présentation ne doit pas dépasser 500 caractères.',
            'pronouns.max' => 'Choisissez au plus 2 pronoms.',
            'pronouns.*.in' => 'Pronom non reconnu.',
            'phone.regex' => 'Numéro de téléphone invalide.',
            'country_code.regex' => 'Code pays invalide.',
            'appearance.in' => 'Apparence inconnue.',
        ];
    }
}
