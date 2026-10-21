<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/** Message texte, Épingle partagée, ou les deux. */
class SendMessageRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge(['text' => trim((string) $this->input('text'))]);
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'text' => ['required_without:pin_id', 'nullable', 'string', 'max:2000'],
            'pin_id' => ['nullable', 'string', 'exists:pins,id'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'text.required_without' => 'Le message est vide.',
            'text.max' => 'Le message ne doit pas dépasser 2000 caractères.',
            'pin_id.exists' => 'Cette Épingle n’existe plus.',
        ];
    }
}
