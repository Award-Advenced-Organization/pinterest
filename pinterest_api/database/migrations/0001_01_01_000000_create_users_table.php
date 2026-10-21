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
        // Identifiants textuels (« usr_jaye_ahf_01 », « creator_3 ») : l'application mobile les attend en chaîne.
        Schema::create('users', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('username')->unique();
            $table->string('name');
            $table->string('avatar_url')->default('');
            $table->text('bio')->default('');
            $table->json('pronouns')->nullable();
            $table->string('website')->default('');
            $table->string('email')->default('');
            $table->string('country_code', 8)->default('+229');
            $table->string('phone', 20)->default('');
            $table->string('appearance', 10)->default('system');
            $table->unsignedInteger('base_follower_count')->default(0);
            $table->unsignedInteger('base_following_count')->default(0);
            $table->timestamps();
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
