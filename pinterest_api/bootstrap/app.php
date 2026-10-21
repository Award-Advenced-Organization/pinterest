<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        // Pas de préfixe « /api » : l'application mobile appelle directement /v3/….
        api: __DIR__.'/../routes/api.php',
        apiPrefix: '',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Toutes les erreurs de l'API au format { "error": "…" }, que l'application affiche telles quelles.
        $isApi = fn (Request $request) => $request->is('v3/*', 'pins/*', 'uploads/*', 'health');

        $exceptions->shouldRenderJsonWhen(fn (Request $request) => $isApi($request) || $request->expectsJson());

        $exceptions->render(function (ValidationException $e, Request $request) use ($isApi) {
            if ($isApi($request)) {
                return response()->json(['error' => $e->validator->errors()->first(), 'errors' => $e->errors()], 422);
            }
        });

        $exceptions->render(function (NotFoundHttpException $e, Request $request) use ($isApi) {
            if ($isApi($request)) {
                return response()->json(['error' => 'Ressource introuvable.'], 404);
            }
        });

        $exceptions->render(function (HttpExceptionInterface $e, Request $request) use ($isApi) {
            if ($isApi($request)) {
                return response()->json(['error' => $e->getMessage() ?: 'Requête impossible.'], $e->getStatusCode());
            }
        });
    })->create();
