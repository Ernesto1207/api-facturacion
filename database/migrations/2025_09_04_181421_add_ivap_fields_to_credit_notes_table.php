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
        Schema::table('credit_notes', function (Blueprint $table) {
            // Agregar campos IVAP después de mto_igv
            $table->decimal('mto_base_ivap', 12, 2)->default(0)->after('mto_igv')->comment('Base imponible IVAP');
            $table->decimal('mto_ivap', 12, 2)->default(0)->after('mto_base_ivap')->comment('Monto IVAP');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('credit_notes', function (Blueprint $table) {
            $table->dropColumn(['mto_base_ivap', 'mto_ivap']);
        });
    }
};
