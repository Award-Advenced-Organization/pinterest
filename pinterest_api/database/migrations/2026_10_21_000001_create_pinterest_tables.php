<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pins', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->string('title')->default('');
            $table->text('description')->default('');
            $table->json('tags')->nullable();
            $table->string('link')->nullable();
            $table->string('image_url');
            $table->json('images')->nullable(); // carrousel
            $table->json('collage_images')->nullable();
            $table->unsignedInteger('width');
            $table->unsignedInteger('height');
            $table->string('dominant_color', 7)->default('#d9d9d4');
            $table->string('category', 40)->default('');
            $table->unsignedInteger('repin_count')->default(0);
            $table->unsignedInteger('base_like_count')->default(0);
            // Ordre du fil d'accueil (les Épingles créées passent devant, valeurs négatives).
            $table->bigInteger('feed_rank')->default(0)->index();
            // Titre, mots-clés, catégorie et créateur en minuscules sans accents, pour la recherche.
            $table->text('search_text')->default('');
            $table->timestamps();
        });

        Schema::create('boards', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->string('name');
            $table->boolean('secret')->default(false);
            $table->text('description')->default('');
            $table->timestamps();
        });

        Schema::create('board_pin', function (Blueprint $table) {
            $table->string('board_id');
            $table->string('pin_id');
            $table->foreign('board_id')->references('id')->on('boards')->cascadeOnDelete();
            $table->foreign('pin_id')->references('id')->on('pins')->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();
            $table->primary(['board_id', 'pin_id']);
        });

        // Liens simples entre un utilisateur et une Épingle : enregistrée, aimée, masquée.
        foreach (['saves', 'likes', 'hidden_pins'] as $name) {
            Schema::create($name, function (Blueprint $table) {
                $table->string('user_id');
                $table->string('pin_id');
                $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
                $table->foreign('pin_id')->references('id')->on('pins')->cascadeOnDelete();
                $table->timestamp('created_at')->useCurrent();
                $table->primary(['user_id', 'pin_id']);
            });
        }

        Schema::create('comments', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('pin_id');
            $table->string('user_id');
            $table->foreign('pin_id')->references('id')->on('pins')->cascadeOnDelete();
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->text('text');
            $table->timestamps();
        });

        Schema::create('follows', function (Blueprint $table) {
            $table->string('follower_id');
            $table->string('followed_id');
            $table->foreign('follower_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('followed_id')->references('id')->on('users')->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();
            $table->primary(['follower_id', 'followed_id']);
        });

        Schema::create('conversations', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->string('other_user_id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('other_user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->unique(['user_id', 'other_user_id']);
            $table->timestamps();
        });

        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->string('conversation_id');
            $table->string('sender_id');
            $table->foreign('conversation_id')->references('id')->on('conversations')->cascadeOnDelete();
            $table->foreign('sender_id')->references('id')->on('users')->cascadeOnDelete();
            $table->text('text')->default('');
            $table->string('pin_id')->nullable();
            $table->foreign('pin_id')->references('id')->on('pins')->nullOnDelete();
            $table->timestamps();
        });

        // « Mises à jour » de la boîte de réception (nom distinct des notifications Laravel).
        Schema::create('inbox_updates', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->text('text');
            $table->string('query')->default('');
            $table->string('image_url')->nullable();
            $table->string('icon', 20)->nullable();
            $table->string('time_label', 20)->default('');
            $table->timestamp('dismissed_at')->nullable();
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();
        });

        Schema::create('activities', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->string('actor_id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->foreign('actor_id')->references('id')->on('users')->cascadeOnDelete();
            $table->string('type', 20); // suggestion | follow
            $table->string('text');
            $table->string('time_label', 20)->default('');
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();
        });

        // Regroupements proposés sur le profil (« Créer » en fait un tableau).
        Schema::create('clusters', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id');
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            $table->string('name');
            $table->string('tag')->nullable();
            $table->string('category')->nullable();
            $table->timestamp('dismissed_at')->nullable();
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();
        });

        Schema::create('search_ideas', function (Blueprint $table) {
            $table->id();
            $table->string('section', 10); // ideas | popular
            $table->string('title');
            $table->string('query');
            $table->string('image');
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        foreach (['search_ideas', 'clusters', 'activities', 'inbox_updates', 'messages', 'conversations', 'follows',
            'comments', 'hidden_pins', 'likes', 'saves', 'board_pin', 'boards', 'pins'] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
