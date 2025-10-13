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
        // Agregar campos a tabla de facturas
        Schema::table('invoices', function (Blueprint $table) {
            $table->string('consulta_cpe_estado', 2)->nullable()->after('estado_sunat');
            $table->json('consulta_cpe_respuesta')->nullable()->after('consulta_cpe_estado');
            $table->timestamp('consulta_cpe_fecha')->nullable()->after('consulta_cpe_respuesta');
            
            // Índices para mejorar consultas
            $table->index('consulta_cpe_estado');
            $table->index('consulta_cpe_fecha');
        });

        // Agregar campos a tabla de boletas
        Schema::table('boletas', function (Blueprint $table) {
            $table->string('consulta_cpe_estado', 2)->nullable()->after('estado_sunat');
            $table->json('consulta_cpe_respuesta')->nullable()->after('consulta_cpe_estado');
            $table->timestamp('consulta_cpe_fecha')->nullable()->after('consulta_cpe_respuesta');
            
            $table->index('consulta_cpe_estado');
            $table->index('consulta_cpe_fecha');
        });

        // Agregar campos a tabla de notas de crédito
        Schema::table('credit_notes', function (Blueprint $table) {
            $table->string('consulta_cpe_estado', 2)->nullable()->after('estado_sunat');
            $table->json('consulta_cpe_respuesta')->nullable()->after('consulta_cpe_estado');
            $table->timestamp('consulta_cpe_fecha')->nullable()->after('consulta_cpe_respuesta');
            
            $table->index('consulta_cpe_estado');
            $table->index('consulta_cpe_fecha');
        });

        // Agregar campos a tabla de notas de débito
        Schema::table('debit_notes', function (Blueprint $table) {
            $table->string('consulta_cpe_estado', 2)->nullable()->after('estado_sunat');
            $table->json('consulta_cpe_respuesta')->nullable()->after('consulta_cpe_estado');
            $table->timestamp('consulta_cpe_fecha')->nullable()->after('consulta_cpe_respuesta');
            
            $table->index('consulta_cpe_estado');
            $table->index('consulta_cpe_fecha');
        });

        // Agregar campos API SUNAT a tabla de empresas (si no existen)
        Schema::table('companies', function (Blueprint $table) {
            // Verificar si no existen antes de agregarlos
            if (!Schema::hasColumn('companies', 'api_sunat_client_id')) {
                $table->string('api_sunat_client_id')->nullable()->after('gre_clave_sol');
            }
            if (!Schema::hasColumn('companies', 'api_sunat_client_secret')) {
                $table->string('api_sunat_client_secret')->nullable()->after('api_sunat_client_id');
            }
            if (!Schema::hasColumn('companies', 'api_sunat_endpoint_beta')) {
                $table->string('api_sunat_endpoint_beta')->nullable()->after('api_sunat_client_secret')
                      ->default('https://api-beta.sunat.gob.pe');
            }
            if (!Schema::hasColumn('companies', 'api_sunat_endpoint_produccion')) {
                $table->string('api_sunat_endpoint_produccion')->nullable()->after('api_sunat_endpoint_beta')
                      ->default('https://api.sunat.gob.pe');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            $table->dropIndex(['consulta_cpe_estado']);
            $table->dropIndex(['consulta_cpe_fecha']);
            $table->dropColumn(['consulta_cpe_estado', 'consulta_cpe_respuesta', 'consulta_cpe_fecha']);
        });

        Schema::table('boletas', function (Blueprint $table) {
            $table->dropIndex(['consulta_cpe_estado']);
            $table->dropIndex(['consulta_cpe_fecha']);
            $table->dropColumn(['consulta_cpe_estado', 'consulta_cpe_respuesta', 'consulta_cpe_fecha']);
        });

        Schema::table('credit_notes', function (Blueprint $table) {
            $table->dropIndex(['consulta_cpe_estado']);
            $table->dropIndex(['consulta_cpe_fecha']);
            $table->dropColumn(['consulta_cpe_estado', 'consulta_cpe_respuesta', 'consulta_cpe_fecha']);
        });

        Schema::table('debit_notes', function (Blueprint $table) {
            $table->dropIndex(['consulta_cpe_estado']);
            $table->dropIndex(['consulta_cpe_fecha']);
            $table->dropColumn(['consulta_cpe_estado', 'consulta_cpe_respuesta', 'consulta_cpe_fecha']);
        });

        Schema::table('companies', function (Blueprint $table) {
            if (Schema::hasColumn('companies', 'api_sunat_client_id')) {
                $table->dropColumn(['api_sunat_client_id', 'api_sunat_client_secret', 'api_sunat_endpoint_beta', 'api_sunat_endpoint_produccion']);
            }
        });
    }
};