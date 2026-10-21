<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/** Création (nom obligatoire) et modification (champs facultatifs) d'un tableau. */
class BoardRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        if ($this->has('name')) {
            $this->merge(['name' => trim((string) $this->input('name'))]);
        }
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        $creating = $this->isMethod('post');

        return [
            'name' => [$creating ? 'required' : 'sometimes', 'required', 'string', 'max:50'],
            'secret' => ['sometimes', 'boolean'],
            'description' => ['sometimes', 'nullable', 'string', 'max:500'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'name.required' => 'Le nom du tableau est obligatoire.',
            'name.max' => 'Le nom du tableau ne doit pas dépasser 50 caractères.',
            'description.max' => 'La description ne doit pas dépasser 500 caractères.',
        ];
    }
}
