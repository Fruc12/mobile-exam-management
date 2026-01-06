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
        Schema::create('actors', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');

            $table->string('phone')->unique()->nullable();
            $table->string('npi');
            $table->string('id_card');  // filepath
            $table->timestamp('birthdate');
            $table->string('birthplace');
            $table->enum('diploma', ['BAC', 'LICENCE', 'MASTER', 'DOCTORAT']);
            $table->enum('bank', ['NSIA', 'UBA', 'ECOBANK', 'BOA', 'LA POSTE', 'CORIS', 'ORABANK']);
            $table->string('n_rib');
            $table->string('rib');  // filepath
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('actors');
    }
};
