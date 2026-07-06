<%@ Page Language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consola Maestra | Logistica de Turnos Molca Spegazzini</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Syne:wght@400;600;700;800&display=swap');

        /* ── DESIGN TOKENS ─────────────────────────────────────────────── */
        :root {
            --sp-blue:    #38bdf8;
            --sp-green:   #4ade80;
            --sp-amber:   #fbbf24;
            --sp-red:     #f87171;
            --sp-bg:      #0b1120;
            --sp-panel:   rgba(15, 23, 42, 0.92);
            --sp-border:  rgba(56, 189, 248, 0.15);
        }

        /* ── BASE ───────────────────────────────────────────────────────── */
        * { box-sizing: border-box; }
        body { font-family: 'Syne', sans-serif; background-color: var(--sp-bg); color: #e2e8f0; margin: 0; font-size: 1rem; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .glass { background: var(--sp-panel); border: 1px solid var(--sp-border); backdrop-filter: blur(12px); }

        /* ── TABS ───────────────────────────────────────────────────────── */
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.2s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
        .tab-btn { color: #94a3b8; transition: background .15s, color .15s; font-size: 0.95rem; }
        .tab-btn:hover { background: #1e293b; color: #fff; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; }

        /* ── TOAST ──────────────────────────────────────────────────────── */
        #toast {
            position: fixed; bottom: 1.5rem; right: 1.5rem;
            padding: .6rem 1.2rem; border-radius: 8px;
            font-size: .9rem; font-weight: 600;
            opacity: 0; transition: opacity .3s;
            z-index: 9999; pointer-events: none;
        }
        #toast.show { opacity: 1; }
        #toast.ok  { background: #166534; border: 1px solid #4ade80; color: #4ade80; }
        #toast.err { background: #7f1d1d; border: 1px solid #f87171; color: #f87171; }
        #toast.warn { background: #78350f; border: 1px solid #fbbf24; color: #fbbf24; }

        /* ── ESTADO DE CARGA ─────────────────────────────────────────────── */
        .btn-loading { opacity: 0.5; cursor: not-allowed; pointer-events: none; }
        #overlay-loading {
            display: none; position: fixed; inset: 0;
            background: rgba(11,17,32,.6); z-index: 9000;
            align-items: center; justify-content: center;
        }
        #overlay-loading.active { display: flex; }

        /* ── ACCESIBILIDAD ──────────────────────────────────────────────── */
        :focus-visible { outline: 2px solid var(--sp-blue); outline-offset: 2px; }
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after { animation-duration: .01ms !important; transition-duration: .01ms !important; }
        }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

<!-- ════════════════════════════════════════════════════════════
     SIDEBAR
════════════════════════════════════════════════════════════ -->
<aside class="w-64 glass flex flex-col p-4 border-r h-full z-10" style="border-color: var(--sp-border)">
    <h1 class="text-xl font-bold text-white mb-1">
        Programacion de Turnos <span style="color:var(--sp-blue)">Molca</span>
    </h1>
    <div class="mb-5 text-xs inline-flex items-center gap-2 p-1.5 rounded-full"
         style="background:rgba(0,0,0,.4); border:1px solid #334155;">
        <span id="status-dot" class="w-2 h-2 rounded-full bg-slate-500"></span>
        <span id="status-label" class="font-bold text-slate-400">Conectando...</span>
    </div>

    <nav class="space-y-1 flex-1" role="navigation" aria-label="Secciones">
        <button class="w-full text-left px-4 py-2 rounded tab-btn active-tab" data-target="s2">1. Turnos del Día</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s1">2. Captura y Consulta</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s6">3. Base Proveedores</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s5">4. Log Terminal</button>
    </nav>
</aside>

<!-- ════════════════════════════════════════════════════════════
     MAIN
════════════════════════════════════════════════════════════ -->
<main class="flex-1 p-8 overflow-y-auto relative">

    <!-- Usuario conectado -->
    <div id="header-user-box"
         class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50"
         aria-live="polite">
        <span class="text-slate-400 font-semibold">Usuario:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Verificando...</span>
    </div>

    <!-- ── SECCIÓN 1: Formulario ABM ────────────────────────────────── -->
    <section id="s1" class="tab-content mt-10" aria-label="Gestión de turnos">
        <div class="flex items-center justify-between mb-4 max-w-4xl">
            <h2 class="text-2xl font-bold" style="color:var(--sp-blue)">Gestión de Solicitud de Turnos</h2>
            <div id="form-mode-indicator"
                 class="text-xs uppercase px-3 py-1 rounded-full font-bold bg-emerald-950/60 text-emerald-400 border border-emerald-500/30"
                 role="status" aria-live="polite">
                Modo: Nuevo Registro
            </div>
        </div>

        <!-- Panel de errores de validación (oculto por defecto) -->
        <div id="form-error-panel"
             class="hidden mb-4 max-w-4xl bg-red-950/60 border border-red-500/30 rounded-xl px-5 py-3 text-sm text-red-400"
             role="alert" aria-live="assertive">
        </div>

        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4 text-base">
            <input type="hidden" id="f_item_id">

            <div>
                <label for="f_cuit" class="block text-xs uppercase text-slate-400 mb-1 font-bold">CUIT *</label>
                <input type="text" id="f_cuit" placeholder="XX-XXXXXXXX-X" maxlength="13" autocomplete="off"
                       class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div>
                <label for="f_oc" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Número OC *</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" maxlength="50" autocomplete="off"
                       class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div class="col-span-2">
                <label for="f_proveedor" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Nombre Proveedor *</label>
                <input type="text" id="f_proveedor" placeholder="Razón Social" maxlength="255" autocomplete="off"
                       class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div class="col-span-2">
                <label for="f_email" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" maxlength="255" autocomplete="off"
                       class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div>
                <label for="f_fecha" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Fecha Solicitud *</label>
                <input type="date" id="f_fecha"
                       class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div>
                <label for="f_dia" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Día</label>
                <input type="text" id="f_dia" readonly placeholder="Automático"
                       class="w-full bg-slate-950 border border-slate-800 rounded p-3 text-slate-400 outline-none"
                       aria-readonly="true">
            </div>
            <div>
                <label for="f_planta" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Planta Destino *</label>
                <select id="f_planta" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                </select>
            </div>
            <div>
                <label for="f_horario" class="block text-xs uppercase text-slate-400 mb-1 font-bold">Horario (Módulos 45 min) *</label>
                <select id="f_horario" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500"></select>
            </div>

            <div class="col-span-2 grid grid-cols-3 gap-4 mt-4">
                <button id="btn-alta"
                        class="font-bold py-3.5 rounded transition bg-sky-500 hover:bg-sky-400 text-slate-950 text-base">
                    ➕ Registrar Turno
                </button>
                <button id="btn-modificar" disabled
                        class="font-bold py-3.5 rounded transition bg-amber-500 hover:bg-amber-400 text-slate-950 text-base opacity-40 cursor-not-allowed">
                    💾 Guardar Cambios
                </button>
                <button id="btn-limpiar"
                        class="font-bold py-3.5 rounded transition bg-slate-800 hover:bg-slate-700 text-slate-300 text-base border border-slate-700">
                    🧹 Limpiar Panel
                </button>
            </div>
        </div>
    </section>

    <!-- ── SECCIÓN 2: Monitor de Turnos ─────────────────────────────── -->
    <section id="s2" class="tab-content active mt-10" aria-label="Monitor de turnos">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Monitor de Turnos | SharePoint Online</h2>

        <div class="grid grid-cols-5 gap-6">
            <!-- Tabla principal -->
            <div class="col-span-3 glass p-6 rounded-xl h-[720px] overflow-y-auto">
                <div class="flex justify-between mb-4 items-center">
                    <span class="text-sm text-slate-400">Lista: <strong>Turnos Proveedores</strong></span>
                    <div class="flex gap-2">
                        <button id="btn-filtro-pk"
                                class="bg-sky-900/60 border border-sky-500/30 text-sky-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-sky-900">
                            Planta PK
                        </button>
                        <button id="btn-filtro-in"
                                class="bg-amber-900/60 border border-amber-500/30 text-amber-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-amber-900">
                            Planta IN
                        </button>
                        <button id="btn-filtro-todos"
                                class="bg-slate-800 border border-slate-700 text-slate-300 px-3 py-1.5 rounded text-xs font-bold hover:bg-slate-700">
                            Ver Todos
                        </button>
                        <button id="btn-refrescar"
                                class="bg-slate-700 px-4 py-1.5 rounded text-xs font-bold text-white hover:bg-slate-600">
                            ↻ Refrescar
                        </button>
                    </div>
                </div>

                <div class="overflow-x-auto text-base">
                    <table class="w-full text-left text-sm text-slate-300" role="grid" aria-label="Tabla de turnos">
                        <thead class="bg-slate-800 text-xs uppercase text-slate-400 font-bold border-b border-slate-700">
                            <tr>
                                <th class="py-3.5 px-3" scope="col">ID Único</th>
                                <th class="px-3" scope="col">Proveedor</th>
                                <th class="px-3" scope="col">Planta</th>
                                <th class="px-3" scope="col">Núm. OC</th>
                                <th class="px-3" scope="col">Fecha / Creación</th>
                                <th class="px-3" scope="col">Horario</th>
                                <th class="px-3" scope="col">Estado</th>
                                <th class="px-3 text-center" scope="col">Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                            <tr>
                                <td colspan="8" class="p-6 text-center text-slate-500 text-xs">
                                    Construyendo grilla...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Panel de disponibilidad + calendario -->
            <div class="col-span-2 glass p-4 rounded-xl flex flex-col h-[720px] overflow-hidden">
                <h3 class="text-base font-bold text-sky-400 uppercase tracking-wider text-center mb-1">
                    Disponibilidad por Planta
                </h3>

                <!-- Mini-calendario -->
                <div class="bg-slate-950/80 p-3 rounded-lg border border-slate-800 mb-3 text-xs">
                    <div class="flex justify-between items-center mb-2 px-1">
                        <span id="calendar-month-title" class="font-bold text-white uppercase tracking-wide">—</span>
                        <div class="text-[10px] text-slate-400 font-semibold font-mono">MOLCA SPEGAZZINI</div>
                    </div>
                    <div class="grid grid-cols-7 text-center font-bold text-slate-500 uppercase tracking-wider mb-1 text-[10px]">
                        <span>Lu</span><span>Ma</span><span>Mi</span><span>Ju</span><span>Vi</span><span>Sa</span><span>Do</span>
                    </div>
                    <div id="calendar-days-grid" class="grid grid-cols-7 gap-1 text-center font-mono font-bold"></div>
                </div>

                <!-- Semáforo de slots -->
                <div class="grid grid-cols-2 gap-3 flex-1 overflow-y-auto pr-1">
                    <div>
                        <h4 class="text-xs font-bold text-sky-400 uppercase tracking-wider text-center mb-2 p-1.5 bg-sky-950/40 rounded border border-sky-500/20">
                            Packaging (PK)
                        </h4>
                        <div id="slots-container-packaging" class="space-y-1.5"></div>
                    </div>
                    <div>
                        <h4 class="text-xs font-bold text-amber-400 uppercase tracking-wider text-center mb-2 p-1.5 bg-amber-950/40 rounded border border-amber-500/20">
                            Insumos (IN)
                        </h4>
                        <div id="slots-container-insumos" class="space-y-1.5"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ── SECCIÓN 3: Base Proveedores ──────────────────────────────── -->
    <section id="s6" class="tab-content mt-10" aria-label="Base de proveedores">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Base de Datos Maestro de Proveedores</h2>
        <div class="glass p-6 rounded-xl text-base">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300" role="grid" aria-label="Tabla de proveedores">
                    <thead class="bg-slate-800 text-xs uppercase text-slate-400 font-bold">
                        <tr>
                            <th class="py-3 px-3" scope="col">CUIT</th>
                            <th class="px-3" scope="col">Razón Social / Proveedor</th>
                            <th class="px-3" scope="col">Email de Contacto</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-proveedores" class="divide-y divide-slate-700/50">
                        <tr>
                            <td colspan="3" class="p-6 text-center text-slate-500 text-xs">
                                Procesando datos...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- ── SECCIÓN 4: Log Terminal ───────────────────────────────────── -->
    <section id="s5" class="tab-content mt-10" aria-label="Consola de diagnóstico">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Consola de Diagnóstico</h2>
        <div class="glass p-4 rounded-xl space-y-4 text-xs">
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Debug — Procesos Internos</h3>
                <div id="debug-log" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded border border-slate-700"
                     style="color:#38bdf8" role="log" aria-live="polite" aria-label="Log de debug"></div>
            </div>
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Log de Operaciones</h3>
                <div id="user-logs" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded border border-slate-700"
                     style="color:#fbbf24" role="log" aria-live="polite" aria-label="Log de operaciones"></div>
            </div>
        </div>
    </section>

</main>

<!-- ════════════════════════════════════════════════════════════
     MODAL: Redacción de correo
════════════════════════════════════════════════════════════ -->
<div id="mailModal"
     class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm hidden items-center justify-center z-50"
     role="dialog" aria-modal="true" aria-labelledby="modal-title">
    <div class="bg-slate-900 border border-slate-700 w-full max-w-2xl rounded-xl p-6 shadow-2xl text-base">
        <div class="flex justify-between items-center border-b border-slate-700 pb-3 mb-4">
            <h3 id="modal-title" class="text-base font-bold text-sky-400 uppercase tracking-wider flex items-center gap-2">
                ✉ Redacción de Correo al Proveedor
            </h3>
            <button id="btn-cerrar-modal"
                    class="text-slate-400 hover:text-white font-bold text-xl leading-none"
                    aria-label="Cerrar modal">
                &times;
            </button>
        </div>
        <div class="space-y-3 text-sm">
            <div class="grid grid-cols-6 items-center">
                <span class="col-span-1 text-slate-400 font-bold uppercase text-xs">DE:</span>
                <input type="text" id="m_de" readonly
                       class="col-span-5 bg-slate-950 border border-slate-800 p-2.5 rounded text-slate-400 outline-none font-mono"
                       aria-label="Remitente">
            </div>
            <div class="grid grid-cols-6 items-center">
                <label for="m_para" class="col-span-1 text-slate-400 font-bold uppercase text-xs">PARA:</label>
                <input type="email" id="m_para"
                       class="col-span-5 bg-slate-950 border border-slate-800 p-2.5 rounded text-white outline-none focus:border-sky-500">
            </div>
            <div class="grid grid-cols-6 items-center">
                <label for="m_asunto" class="col-span-1 text-slate-400 font-bold uppercase text-xs">ASUNTO:</label>
                <input type="text" id="m_asunto" maxlength="200"
                       class="col-span-5 bg-slate-950 border border-slate-800 p-2.5 rounded text-white outline-none focus:border-sky-500">
            </div>
            <div>
                <label for="m_cuerpo" class="block text-slate-400 font-bold uppercase mb-1 text-xs">CUERPO:</label>
                <textarea id="m_cuerpo" rows="8" maxlength="2000"
                          class="w-full bg-slate-950 border border-slate-800 p-3 rounded text-white font-mono outline-none resize-none focus:border-sky-500"></textarea>
            </div>
        </div>
        <div class="flex justify-end gap-3 mt-5 border-t border-slate-700 pt-3">
            <button id="btn-abortar-mail"
                    class="bg-slate-800 hover:bg-slate-700 px-4 py-2 rounded text-xs font-bold text-slate-300">
                Cancelar
            </button>
            <button id="btnEnviarMailFinal"
                    class="bg-sky-600 hover:bg-sky-500 px-5 py-2.5 rounded text-xs font-bold text-slate-950">
                Enviar Correo
            </button>
        </div>
    </div>
</div>

<!-- Overlay de carga global -->
<div id="overlay-loading" role="status" aria-label="Procesando...">
    <div class="flex flex-col items-center gap-3">
        <div class="w-10 h-10 border-4 border-sky-500 border-t-transparent rounded-full animate-spin"></div>
        <span class="text-sky-400 text-sm font-bold font-mono">Procesando...</span>
    </div>
</div>

<div id="toast" role="alert" aria-live="assertive"></div>

<!-- ════════════════════════════════════════════════════════════
     SCRIPT PRINCIPAL — arquitectura en capas
     ─────────────────────────────────────────────────────────
     Orden de capas:
       1. CONFIG          — constantes de configuración
       2. FIELD_MAP       — mapa de nombres de campo SharePoint
       3. AppState        — estado global encapsulado
       4. DigestCache     — caché del Form Digest (TTL 25 min)
       5. Validators      — validación y sanitización
       6. TurnosService   — acceso a datos (REST API)
       7. UI              — render, DOM, eventos
       8. App             — orquestador / punto de entrada
════════════════════════════════════════════════════════════ -->
<script>
"use strict";

/* ══════════════════════════════════════════════════════════
   1. CONFIG
══════════════════════════════════════════════════════════ */
const CONFIG = Object.freeze({
    siteUrl:      "/sites/GestiondeTurnos",
    listName:     "Turnos Proveedores",
    maxItemsFetch: 500,             // trae hasta 500 ítems filtrados por fecha
    digestTTL:    25 * 60 * 1000,   // 25 minutos en milisegundos
    toastDuration: 4000,
    horarioInicio: 8 * 60,          // 08:00 en minutos
    horarioFin:   16 * 60 + 15,     // 16:15 en minutos
    moduloMinutos: 45
});

/* ══════════════════════════════════════════════════════════
   2. FIELD_MAP — única fuente de verdad para nombres internos
══════════════════════════════════════════════════════════ */
const F = Object.freeze({
    CUIT:       "field_1",
    PROVEEDOR:  "field_2",
    EMAIL:      "field_3",
    HORARIO:    "field_5",
    FECHA:      "field_6",
    ESTADO:     "field_7",
    NUM_OC:     "N_x00b0__x0020_de_x0020_OC",
    PLANTA:     "Planta"
});

const SELECT_FIELDS = `Id,Title,${F.CUIT},${F.PROVEEDOR},${F.NUM_OC},${F.FECHA},${F.HORARIO},${F.ESTADO},Created,${F.PLANTA},${F.EMAIL}`;

/* ══════════════════════════════════════════════════════════
   3. AppState — estado centralizado con acceso controlado
══════════════════════════════════════════════════════════ */
const AppState = (() => {
    let _turnosCache      = [];
    let _fechaSeleccionada = new Date().toISOString().split("T")[0];
    let _transicionPendiente = null;
    let _usuario          = { name: "", email: "" };  // sin hardcodeo
    let _isLoading        = false;
    const _slotsHorarios  = [];

    return {
        getTurnos()            { return [..._turnosCache]; },
        setTurnos(items)       { _turnosCache = Array.isArray(items) ? items : []; },
        actualizarTurno(id, cambios) {
            _turnosCache = _turnosCache.map(t =>
                parseInt(t.Id, 10) === parseInt(id, 10) ? { ...t, ...cambios } : t
            );
        },
        eliminarTurno(id) {
            _turnosCache = _turnosCache.filter(t => parseInt(t.Id, 10) !== parseInt(id, 10));
        },
        agregarTurno(item) {
            _turnosCache.unshift(item);
        },

        getFecha()             { return _fechaSeleccionada; },
        setFecha(f)            { _fechaSeleccionada = f; },

        getTransicion()        { return _transicionPendiente; },
        setTransicion(ctx)     { _transicionPendiente = ctx; },
        limpiarTransicion()    { _transicionPendiente = null; },

        getUsuario()           { return { ..._usuario }; },
        setUsuario(u)          { _usuario = { name: u.name || "", email: u.email || "" }; },

        isLoading()            { return _isLoading; },
        setLoading(v)          { _isLoading = !!v; },

        getSlots()             { return [..._slotsHorarios]; },
        generarSlots() {
            _slotsHorarios.length = 0;
            let inicio = CONFIG.horarioInicio;
            while (inicio + CONFIG.moduloMinutos <= CONFIG.horarioFin) {
                const pad = (n) => String(Math.floor(n)).padStart(2, "0");
                const hIni = pad(inicio / 60), mIni = pad(inicio % 60);
                inicio += CONFIG.moduloMinutos;
                const hFin = pad(inicio / 60), mFin = pad(inicio % 60);
                _slotsHorarios.push(`${hIni}:${mIni} h a ${hFin}:${mFin} h`);
            }
        }
    };
})();

/* ══════════════════════════════════════════════════════════
   4. DigestCache — Form Digest con TTL para evitar llamadas
      repetidas a /_api/contextinfo en cada escritura
══════════════════════════════════════════════════════════ */
const DigestCache = (() => {
    let _value  = null;
    let _expiry = 0;

    return {
        async get() {
            if (_value && Date.now() < _expiry) {
                return _value;
            }
            try {
                const res  = await fetch(`${CONFIG.siteUrl}/_api/contextinfo`, {
                    method:  "POST",
                    headers: { "Accept": "application/json;odata=verbose" }
                });
                if (!res.ok) throw new Error(`HTTP ${res.status}`);
                const data = await res.json();
                _value  = data.d.GetContextWebInformation.FormDigestValue;
                _expiry = Date.now() + CONFIG.digestTTL;
                return _value;
            } catch (e) {
                _value  = null;
                _expiry = 0;
                // CORRECCIÓN: nunca retornar token dummy; propagar el error
                throw new Error("No se pudo obtener el token de seguridad. Reintente la operación.");
            }
        },
        invalidar() {
            _value  = null;
            _expiry = 0;
        }
    };
})();

/* ══════════════════════════════════════════════════════════
   5. Validators — validación de entradas y escape HTML
══════════════════════════════════════════════════════════ */
const Validators = Object.freeze({
    // CORRECCIÓN CRÍTICA XSS: escapar SIEMPRE antes de insertar en innerHTML
    escapeHtml(str) {
        if (str === null || str === undefined) return "";
        return String(str)
            .replace(/&/g,  "&amp;")
            .replace(/</g,  "&lt;")
            .replace(/>/g,  "&gt;")
            .replace(/"/g,  "&quot;")
            .replace(/'/g,  "&#x27;");
    },

    // Escape para atributos data-* (solo comillas dobles son peligrosas en ese contexto)
    escapeAttr(str) {
        if (str === null || str === undefined) return "";
        return String(str).replace(/"/g, "&quot;").replace(/'/g, "&#x27;");
    },

    cuit(v)  {
        // Acepta formatos: XX-XXXXXXXX-X o XX-XXXXXXX-X
        return /^\d{2}-\d{7,8}-\d$/.test(String(v).trim());
    },
    email(v) {
        if (!v || !String(v).trim()) return true; // email es opcional
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v).trim());
    },
    texto(v, max = 255) {
        const s = String(v || "").trim();
        return s.length > 0 && s.length <= max;
    },

    validarFormTurno(data) {
        const errors = [];
        if (!this.texto(data.cuit, 13))       errors.push("CUIT es obligatorio (máx. 13 caracteres).");
        if (!this.cuit(data.cuit))             errors.push("Formato de CUIT inválido. Use XX-XXXXXXXX-X.");
        if (!this.texto(data.oc, 50))          errors.push("Número de OC es obligatorio.");
        if (!this.texto(data.prov, 255))       errors.push("Nombre de proveedor es obligatorio (máx. 255 car.).");
        if (!data.fecha)                       errors.push("Fecha de solicitud es obligatoria.");
        if (!this.email(data.email))           errors.push("El email ingresado no tiene un formato válido.");
        return { valid: errors.length === 0, errors };
    }
});

/* ══════════════════════════════════════════════════════════
   6. TurnosService — toda comunicación con SharePoint REST
══════════════════════════════════════════════════════════ */
const TurnosService = {

    // CORRECCIÓN: filtrar por fecha en el servidor (evita $top=50 global)
    async listarPorFecha(fecha) {
        const fechaISO = `${fecha}T00:00:00Z`;
        // Construir query con filtro de fecha para no traer toda la lista
        const endpoint = `${CONFIG.siteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(CONFIG.listName)}')/items`
            + `?$select=${SELECT_FIELDS}`
            + `&$filter=${encodeURIComponent(`${F.FECHA} eq '${fechaISO}'`)}`
            + `&$orderby=Created desc`
            + `&$top=${CONFIG.maxItemsFetch}`;
        const res = await fetch(endpoint, {
            headers: { "Accept": "application/json;odata=nometadata" }
        });
        if (!res.ok) throw new Error(`Error al listar turnos: HTTP ${res.status}`);
        const data = await res.json();
        return data.value || [];
    },

    // Listar recientes (para la tabla completa sin filtro de fecha)
    async listarRecientes() {
        const endpoint = `${CONFIG.siteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(CONFIG.listName)}')/items`
            + `?$select=${SELECT_FIELDS}`
            + `&$orderby=Created desc`
            + `&$top=${CONFIG.maxItemsFetch}`;
        const res = await fetch(endpoint, {
            headers: { "Accept": "application/json;odata=nometadata" }
        });
        if (!res.ok) throw new Error(`Error al listar turnos: HTTP ${res.status}`);
        const data = await res.json();
        return data.value || [];
    },

    // CORRECCIÓN: verificar disponibilidad en el servidor antes de crear
    // Evita condición de carrera entre dos usuarios concurrentes
    async verificarSlotDisponible(fecha, horario, planta) {
        const fechaISO = `${fecha}T00:00:00Z`;
        const filtro = `${F.FECHA} eq '${fechaISO}' and ${F.HORARIO} eq '${horario}' and ${F.PLANTA} eq '${planta}' and ${F.ESTADO} eq 'Aprobado'`;
        const endpoint = `${CONFIG.siteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(CONFIG.listName)}')/items`
            + `?$select=Id&$filter=${encodeURIComponent(filtro)}&$top=1`;
        const res = await fetch(endpoint, {
            headers: { "Accept": "application/json;odata=nometadata" }
        });
        if (!res.ok) return true; // en caso de error, permitir e ignorar (falla controlada)
        const data = await res.json();
        return (data.value || []).length === 0; // true = disponible
    },

    async crear(payload) {
        const digest = await DigestCache.get();
        const res = await fetch(
            `${CONFIG.siteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(CONFIG.listName)}')/items`,
            {
                method:  "POST",
                headers: {
                    "Accept":         "application/json;odata=nometadata",
                    "Content-Type":   "application/json",
                    "X-RequestDigest": digest
                },
                body: JSON.stringify(payload)
            }
        );
        if (!res.ok && res.status !== 201) throw new Error(`Error al crear turno: HTTP ${res.status}`);
        return res.status === 201 ? await res.json() : null;
    },

    async actualizar(id, payload) {
        const digest = await DigestCache.get();
        const res = await fetch(
            `${CONFIG.siteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(CONFIG.listName)}')/items(${parseInt(id, 10)})`,
            {
                method:  "POST",
                headers: {
                    "Accept":          "application/json;odata=nometadata",
                    "Content-Type":    "application/json",
                    "X-RequestDigest": digest,
                    "X-HTTP-Method":   "MERGE",
                    "If-Match":        "*"
                },
                body: JSON.stringify(payload)
            }
        );
        if (!res.ok && res.status !== 204) throw new Error(`Error al actualizar turno: HTTP ${res.status}`);
    },

    async eliminar(id) {
        const digest = await DigestCache.get();
        const res = await fetch(
            `${CONFIG.siteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(CONFIG.listName)}')/items(${parseInt(id, 10)})`,
            {
                method:  "POST",
                headers: {
                    "X-RequestDigest": digest,
                    "X-HTTP-Method":   "DELETE",
                    "If-Match":        "*"
                }
            }
        );
        if (!res.ok) throw new Error(`Error al eliminar turno: HTTP ${res.status}`);
    },

    async resolverUsuario() {
        const res = await fetch(`${CONFIG.siteUrl}/_api/web/currentUser`, {
            headers: { "Accept": "application/json;odata=nometadata" }
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return await res.json();
    }
};

/* ══════════════════════════════════════════════════════════
   7. UI — renderizado, DOM y eventos
      TODAS las inserciones en innerHTML usan Validators.escapeHtml()
══════════════════════════════════════════════════════════ */
const UI = {

    // ─── Helpers ──────────────────────────────────────────────────────
    showToast(msg, type = "ok") {
        const t = document.getElementById("toast");
        if (!t) return;
        t.textContent = msg;
        t.className = `show ${type}`;
        clearTimeout(t._timer);
        t._timer = setTimeout(() => { t.className = ""; }, CONFIG.toastDuration);
    },

    logDebug(msg) {
        const area = document.getElementById("debug-log");
        if (!area) return;
        const ts = new Date().toLocaleTimeString();
        const div = document.createElement("div");
        div.textContent = `[${ts}] ${msg}`;  // textContent es seguro
        area.appendChild(div);
        area.scrollTop = area.scrollHeight;
    },

    userLog(msg, tipo = "MANUAL") {
        const area = document.getElementById("user-logs");
        if (!area) return;
        const ts  = new Date().toLocaleString();
        const usr = AppState.getUsuario();
        const div = document.createElement("div");
        div.className = "mb-1";
        // Construimos con textContent para nodos seguros, sin innerHTML
        const spanTs   = document.createElement("span"); spanTs.className   = "text-slate-500"; spanTs.textContent   = `[${ts}]`;
        const spanTipo = document.createElement("span"); spanTipo.className = "text-sky-400 font-bold"; spanTipo.textContent = ` [${tipo}] `;
        const spanUser = document.createElement("span"); spanUser.className = "text-white font-semibold"; spanUser.textContent = `${usr.name || "Usuario"}: `;
        const spanMsg  = document.createElement("span"); spanMsg.textContent  = msg;
        div.append(spanTs, spanTipo, spanUser, spanMsg);
        area.appendChild(div);
        area.scrollTop = area.scrollHeight;
    },

    setLoading(active) {
        const overlay = document.getElementById("overlay-loading");
        if (overlay) overlay.classList.toggle("active", active);
        AppState.setLoading(active);
        // Deshabilitar botón refrescar durante carga
        const btnRef = document.getElementById("btn-refrescar");
        if (btnRef) btnRef.classList.toggle("btn-loading", active);
    },

    mostrarErroresFormulario(errors) {
        const panel = document.getElementById("form-error-panel");
        if (!panel) return;
        if (!errors || errors.length === 0) {
            panel.classList.add("hidden");
            panel.innerHTML = "";
            return;
        }
        // Usamos textContent para cada ítem (sin XSS)
        panel.innerHTML = "";
        const ul = document.createElement("ul");
        ul.className = "list-disc list-inside space-y-1";
        errors.forEach(e => {
            const li = document.createElement("li");
            li.textContent = e;
            ul.appendChild(li);
        });
        panel.appendChild(ul);
        panel.classList.remove("hidden");
    },

    actualizarEstadoConexion(online) {
        const dot   = document.getElementById("status-dot");
        const label = document.getElementById("status-label");
        if (!dot || !label) return;
        if (online) {
            dot.className   = "w-2 h-2 rounded-full bg-emerald-400 animate-pulse";
            label.className = "font-bold text-emerald-400";
            label.textContent = "Online API REST";
        } else {
            dot.className   = "w-2 h-2 rounded-full bg-amber-400";
            label.className = "font-bold text-amber-400";
            label.textContent = "Modo Local";
        }
    },

    // ─── Selector de día automático ──────────────────────────────────
    calcularDia(fechaStr) {
        const dias  = ["Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"];
        const fecha = new Date(fechaStr.replace(/-/g, "/") + " 00:00:00");
        return dias[fecha.getDay()];
    },

    actualizarCampoDia(fechaStr) {
        const el = document.getElementById("f_dia");
        if (el) el.value = this.calcularDia(fechaStr);
    },

    // ─── Slots de horario ────────────────────────────────────────────
    poblarSelectHorario() {
        const select = document.getElementById("f_horario");
        if (!select) return;
        const slots = AppState.getSlots();
        const frag  = document.createDocumentFragment();
        slots.forEach(slot => {
            const opt = document.createElement("option");
            opt.value       = slot;
            opt.textContent = slot;
            frag.appendChild(opt);
        });
        select.innerHTML = "";
        select.appendChild(frag);
    },

    // ─── Tabla de turnos ─────────────────────────────────────────────
    // CORRECCIÓN CRÍTICA: todos los datos se escapan con Validators.escapeHtml()
    // Los eventos usan data-attributes + event delegation (sin onclick inline)
    renderizarFilas(items) {
        const tbody = document.getElementById("tabla-turnos");
        if (!tbody) return;

        if (!items || items.length === 0) {
            const tr = tbody.insertRow();
            const td = tr.insertCell();
            td.colSpan   = 8;
            td.className = "p-4 text-center text-slate-500 text-xs";
            td.textContent = "No se encontraron turnos para la fecha seleccionada.";
            tbody.innerHTML = "";
            tbody.appendChild(tr);
            return;
        }

        const frag = document.createDocumentFragment();
        items.forEach(t => {
            const estadoRaw  = t[F.ESTADO] ? String(t[F.ESTADO]).trim() : "Pendiente";
            const estadoLow  = estadoRaw.toLowerCase();

            let filaClass  = "";
            let statusClass = "text-amber-500 font-medium";
            let esAprobado  = false;

            if (estadoLow === "pendiente") {
                filaClass   = "opacity-45 bg-slate-950/20 grayscale-[30%]";
            } else if (estadoLow === "aprobado") {
                statusClass = "text-emerald-400 font-bold";
                esAprobado  = true;
            } else {
                statusClass = "text-rose-400";
            }

            const plantaRaw     = t[F.PLANTA] ? String(t[F.PLANTA]) : "Packaging";
            const codigoPlanta  = plantaRaw.toLowerCase() === "insumos" ? "IN" : "PK";
            const idInteligente = `TN${codigoPlanta}${t.Id}`;
            const fechaSol      = t[F.FECHA] ? String(t[F.FECHA]).split("T")[0] : "-";
            const creado        = t.Created ? new Date(t.Created).toLocaleString() : "-";

            // Datos escapados para HTML
            const eId       = Validators.escapeHtml(t.Id);
            const eProv     = Validators.escapeHtml(t[F.PROVEEDOR] || "-");
            const ePlanta   = Validators.escapeHtml(plantaRaw);
            const eOC       = Validators.escapeHtml(t[F.NUM_OC] || "-");
            const eFechaSol = Validators.escapeHtml(fechaSol);
            const eCreado   = Validators.escapeHtml(creado);
            const eHorario  = Validators.escapeHtml(t[F.HORARIO] || "-");
            const eEstado   = Validators.escapeHtml(estadoRaw);
            const eVisualId = Validators.escapeHtml(idInteligente);

            // Datos escapados para atributos data-* (event delegation)
            const dEmail  = Validators.escapeAttr(t[F.EMAIL]    || "");
            const dProv   = Validators.escapeAttr(t[F.PROVEEDOR]|| "");
            const dFecha  = Validators.escapeAttr(fechaSol);
            const dEstado = Validators.escapeAttr(estadoRaw);
            const dId     = parseInt(t.Id, 10);

            const accionesDis = esAprobado ? "opacity-20 pointer-events-none" : "hover:scale-125";

            const tr = document.createElement("tr");
            tr.className = `border-b border-slate-700/50 hover:bg-slate-800/30 transition-all ${filaClass}`;
            // innerHTML aquí es seguro: TODOS los valores ya fueron escapados arriba
            tr.innerHTML = `
                <td class="py-3 px-3 font-mono font-bold text-sky-400">
                    <div class="flex items-center gap-2">
                        <button
                            class="text-emerald-400 hover:text-white transition-transform text-sm btn-consultar"
                            data-id="${eId}"
                            title="Cargar en formulario"
                            aria-label="Consultar turno ${eVisualId}">&#128065;</button>
                        <button
                            class="text-sky-400 hover:text-white transition-colors text-xs btn-mail"
                            data-email="${dEmail}"
                            data-prov="${dProv}"
                            data-fecha="${dFecha}"
                            data-estado="${dEstado}"
                            title="Redactar correo"
                            aria-label="Enviar correo sobre turno ${eVisualId}">&#9993;</button>
                        <span>${eVisualId}</span>
                    </div>
                </td>
                <td class="px-3 text-white font-semibold">${eProv}</td>
                <td class="px-3 font-mono text-xs font-bold text-slate-400">${ePlanta}</td>
                <td class="px-3 text-slate-400 font-mono">${eOC}</td>
                <td class="px-3 text-xs text-slate-300">
                    Sol: ${eFechaSol}<br>
                    <span class="text-[10px] text-slate-500">Alta: ${eCreado}</span>
                </td>
                <td class="px-3 text-sky-400 font-mono">${eHorario}</td>
                <td class="px-3 ${statusClass}">${eEstado}</td>
                <td class="px-3 text-center">
                    <div class="flex items-center justify-center gap-3 text-base">
                        <button
                            class="${accionesDis} transition-transform btn-aprobar"
                            data-id="${dId}" data-visual="${eVisualId}"
                            data-email="${dEmail}" data-prov="${dProv}" data-fecha="${dFecha}"
                            title="Aprobar" aria-label="Aprobar turno ${eVisualId}">&#9989;</button>
                        <button
                            class="${accionesDis} transition-transform btn-cancelar"
                            data-id="${dId}" data-visual="${eVisualId}"
                            data-email="${dEmail}" data-prov="${dProv}" data-fecha="${dFecha}"
                            title="Cancelar" aria-label="Cancelar turno ${eVisualId}">&#10060;</button>
                        <button
                            class="${accionesDis} transition-transform text-rose-500 btn-eliminar"
                            data-id="${dId}" data-visual="${eVisualId}" data-prov="${dProv}"
                            title="Eliminar turno" aria-label="Eliminar turno ${eVisualId}">&#128465;</button>
                    </div>
                </td>`;
            frag.appendChild(tr);
        });

        tbody.innerHTML = "";
        tbody.appendChild(frag);
    },

    // ─── Tabla de proveedores ─────────────────────────────────────────
    renderizarBaseProveedores() {
        const tbody = document.getElementById("tabla-proveedores");
        if (!tbody) return;

        const turnos = AppState.getTurnos();
        if (turnos.length === 0) return;

        const vistos = new Set();
        const proveedores = [];
        turnos.forEach(t => {
            const cuit = t[F.CUIT] ? String(t[F.CUIT]).trim() : "";
            if (cuit && !vistos.has(cuit)) {
                vistos.add(cuit);
                proveedores.push({
                    cuit,
                    razon: t[F.PROVEEDOR] ? String(t[F.PROVEEDOR]) : "Sin razón social",
                    email: t[F.EMAIL]     ? String(t[F.EMAIL])     : "-"
                });
            }
        });

        const frag = document.createDocumentFragment();
        proveedores.forEach(p => {
            const tr = document.createElement("tr");
            tr.className = "border-b border-slate-700/50 hover:bg-slate-800/30 text-xs";
            tr.innerHTML = `
                <td class="py-3 px-3 font-mono font-bold text-amber-400">${Validators.escapeHtml(p.cuit)}</td>
                <td class="px-3 text-white font-semibold">${Validators.escapeHtml(p.razon)}</td>
                <td class="px-3 text-slate-400">${Validators.escapeHtml(p.email)}</td>`;
            frag.appendChild(tr);
        });
        tbody.innerHTML = "";
        tbody.appendChild(frag);
    },

    // ─── Semáforo de disponibilidad ──────────────────────────────────
    renderizarDisponibilidad() {
        const cPkg = document.getElementById("slots-container-packaging");
        const cIns = document.getElementById("slots-container-insumos");
        if (!cPkg || !cIns) return;

        const fecha   = AppState.getFecha();
        const turnos  = AppState.getTurnos();
        const slots   = AppState.getSlots();

        const normSlot = (s) => String(s || "").toLowerCase().replace(/h/g,"").replace(/\s+/g,"").trim();

        const buscarSlot = (planta, slot) => {
            const match = turnos.find(t =>
                t[F.FECHA] && String(t[F.FECHA]).split("T")[0] === fecha &&
                normSlot(t[F.HORARIO]) === normSlot(slot) &&
                (t[F.PLANTA] ? String(t[F.PLANTA]).toLowerCase() : "packaging") === planta.toLowerCase()
            );
            if (!match || !match[F.ESTADO]) return { estado: "Libre", visualId: "" };
            const st = String(match[F.ESTADO]).trim().toLowerCase();
            if (st === "cancelado" || st === "anulado") return { estado: "Libre", visualId: "" };
            const cod  = (match[F.PLANTA] || "").toLowerCase() === "insumos" ? "IN" : "PK";
            return { estado: String(match[F.ESTADO]).trim(), visualId: `TN${cod}${match.Id}` };
        };

        const tarjeta = (slot, estado, visualId) => {
            const st = estado ? estado.toLowerCase() : "libre";
            let bg, label, badge;
            if (st === "aprobado") {
                bg    = "bg-red-600 border-red-500 text-white font-bold";
                label = "Ocupado";
                badge = `<span class="text-[10px] px-1 bg-black/30 rounded text-sky-300 font-bold font-mono">${Validators.escapeHtml(visualId)}</span>`;
            } else if (st === "pendiente") {
                bg    = "bg-amber-500 border-amber-400 text-slate-950 font-bold";
                label = "En Revisión";
                badge = `<span class="text-[10px] px-1 bg-black/20 rounded text-slate-800 font-bold font-mono">${Validators.escapeHtml(visualId)}</span>`;
            } else {
                bg    = "bg-emerald-600 border-emerald-500 text-white font-bold";
                label = "Libre";
                badge = "<span></span>";
            }
            const slotEsc = Validators.escapeHtml(String(slot).split(" ")[0]);
            return `<div class="flex items-center justify-between p-2 border rounded text-sm font-mono ${bg} shadow-md transition-all">
                <span>${slotEsc}</span>
                ${badge}
                <span class="text-[9px] uppercase tracking-wider bg-black/20 px-1.5 py-0.5 rounded font-extrabold">${label}</span>
            </div>`;
        };

        let htmlPkg = "", htmlIns = "";
        slots.forEach(slot => {
            const rPkg = buscarSlot("packaging", slot);
            const rIns = buscarSlot("insumos",   slot);
            htmlPkg += tarjeta(slot, rPkg.estado, rPkg.visualId);
            htmlIns += tarjeta(slot, rIns.estado, rIns.visualId);
        });
        cPkg.innerHTML = htmlPkg;
        cIns.innerHTML = htmlIns;
    },

    // ─── Calendario ──────────────────────────────────────────────────
    renderizarCalendario() {
        const grid  = document.getElementById("calendar-days-grid");
        const title = document.getElementById("calendar-month-title");
        if (!grid || !title) return;

        const fechaStr  = AppState.getFecha();
        const base      = new Date(fechaStr.replace(/-/g, "/") + " 00:00:00");
        const anio      = base.getFullYear();
        const mes       = base.getMonth();
        const meses     = ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
                           "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];

        title.textContent = `${meses[mes]} ${anio}`;

        const primerDia = new Date(anio, mes, 1);
        let dow = primerDia.getDay();
        let desplazamiento = dow === 0 ? 6 : dow - 1;

        const frag = document.createDocumentFragment();

        for (let b = 0; b < desplazamiento; b++) {
            const d = document.createElement("div");
            d.className = "p-1 text-transparent select-none";
            d.textContent = "-";
            frag.appendChild(d);
        }

        const totalDias = new Date(anio, mes + 1, 0).getDate();
        const diaSeleccionado = base.getDate();

        for (let dia = 1; dia <= totalDias; dia++) {
            const fechaDia = `${anio}-${String(mes + 1).padStart(2,"0")}-${String(dia).padStart(2,"0")}`;
            const btn = document.createElement("button");
            btn.type      = "button";
            btn.textContent = String(dia);
            btn.className = dia === diaSeleccionado
                ? "p-1 text-center text-xs transition-all bg-sky-500 text-slate-950 font-extrabold rounded shadow"
                : "p-1 text-center text-xs transition-all text-slate-300 hover:bg-slate-800 rounded cursor-pointer";
            btn.setAttribute("aria-label", `Seleccionar ${fechaDia}`);
            btn.setAttribute("aria-pressed", dia === diaSeleccionado ? "true" : "false");
            btn.dataset.fecha = fechaDia;
            btn.classList.add("btn-cal-dia");
            frag.appendChild(btn);
        }

        grid.innerHTML = "";
        grid.appendChild(frag);
    },

    // ─── Formulario ABM ──────────────────────────────────────────────
    leerFormulario() {
        return {
            itemId:  document.getElementById("f_item_id").value,
            cuit:    (document.getElementById("f_cuit").value   || "").trim(),
            oc:      (document.getElementById("f_oc").value     || "").trim(),
            prov:    (document.getElementById("f_proveedor").value || "").trim(),
            email:   (document.getElementById("f_email").value  || "").trim(),
            fecha:   document.getElementById("f_fecha").value   || "",
            horario: document.getElementById("f_horario").value || "",
            planta:  document.getElementById("f_planta").value  || "Packaging"
        };
    },

    limpiarFormulario() {
        document.getElementById("f_item_id").value = "";
        ["f_cuit","f_oc","f_proveedor","f_email"].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.value = "";
        });
        this.setFormReadOnly(false);
        this.mostrarErroresFormulario([]);

        const ind = document.getElementById("form-mode-indicator");
        if (ind) {
            ind.textContent = "Modo: Nuevo Registro";
            ind.className   = "text-xs uppercase px-3 py-1 rounded-full font-bold bg-emerald-950/60 text-emerald-400 border border-emerald-500/30";
        }
        const btnMod = document.getElementById("btn-modificar");
        if (btnMod) {
            btnMod.disabled   = true;
            btnMod.classList.add("opacity-40","cursor-not-allowed");
        }
    },

    cargarTurnoEnFormulario(t) {
        document.getElementById("f_item_id").value   = t.Id;
        document.getElementById("f_cuit").value      = String(t[F.CUIT]     || "").trim();
        document.getElementById("f_oc").value        = String(t[F.NUM_OC]   || "").trim();
        document.getElementById("f_proveedor").value = String(t[F.PROVEEDOR]|| "").trim();
        document.getElementById("f_email").value     = String(t[F.EMAIL]    || "").trim();

        const fechaVal = t[F.FECHA] ? String(t[F.FECHA]).split("T")[0] : "";
        document.getElementById("f_fecha").value = fechaVal;
        if (fechaVal) this.actualizarCampoDia(fechaVal);

        document.getElementById("f_planta").value  = t[F.PLANTA]  ? String(t[F.PLANTA])  : "Packaging";
        document.getElementById("f_horario").value = t[F.HORARIO] ? String(t[F.HORARIO]) : "";

        const estadoLow = t[F.ESTADO] ? String(t[F.ESTADO]).trim().toLowerCase() : "pendiente";
        const ind       = document.getElementById("form-mode-indicator");
        const btnMod    = document.getElementById("btn-modificar");

        if (estadoLow === "aprobado") {
            if (ind) {
                ind.textContent = "Modo: Consulta (Turno APROBADO) 🔒";
                ind.className   = "text-xs uppercase px-3 py-1 rounded-full font-bold bg-red-950/60 text-red-400 border border-red-500/30";
            }
            this.setFormReadOnly(true);
            if (btnMod) { btnMod.disabled = true; btnMod.classList.add("opacity-40","cursor-not-allowed"); }
        } else {
            if (ind) {
                ind.textContent = "Modo: Edición Activa (PENDIENTE) ✏️";
                ind.className   = "text-xs uppercase px-3 py-1 rounded-full font-bold bg-amber-950/60 text-amber-400 border border-amber-500/30";
            }
            this.setFormReadOnly(false);
            if (btnMod) { btnMod.disabled = false; btnMod.classList.remove("opacity-40","cursor-not-allowed"); }
        }
    },

    setFormReadOnly(ro) {
        ["f_cuit","f_oc","f_proveedor","f_email","f_fecha"].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.readOnly = ro;
        });
        const selPlanta  = document.getElementById("f_planta");
        const selHorario = document.getElementById("f_horario");
        if (selPlanta)  selPlanta.disabled  = ro;
        if (selHorario) selHorario.disabled = ro;
    },

    navegarASeccion(target) {
        document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active-tab"));
        const btn = document.querySelector(`[data-target="${target}"]`);
        if (btn) btn.classList.add("active-tab");
        document.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));
        const sec = document.getElementById(target);
        if (sec) sec.classList.add("active");
    },

    // ─── Modal de correo ─────────────────────────────────────────────
    abrirModal(email, prov, fecha, estado) {
        const usuario = AppState.getUsuario();
        document.getElementById("m_de").value     = usuario.email || "";
        document.getElementById("m_para").value   = email !== "-" ? email : "";
        document.getElementById("m_asunto").value = `Turno ${Validators.escapeHtml(estado)} - Molca Spegazzini`;
        document.getElementById("m_cuerpo").value =
            `Estimado/a ${prov},\n\nLe informamos que su solicitud de turno para el día ${fecha} ha sido ${estado}.\n\nDeberá presentarse con la documentación requerida para el ingreso a planta.\n\nSaludos cordiales,\nLogística - Molca Spegazzini`;

        const modal = document.getElementById("mailModal");
        modal.classList.remove("hidden");
        modal.classList.add("flex");
        document.getElementById("m_para").focus();
    },

    cerrarModal() {
        const modal = document.getElementById("mailModal");
        modal.classList.add("hidden");
        modal.classList.remove("flex");
        AppState.limpiarTransicion();
    }
};

/* ══════════════════════════════════════════════════════════
   8. App — orquestador, lógica de negocio, event listeners
══════════════════════════════════════════════════════════ */
const App = {

    // ─── Inicialización ───────────────────────────────────────────────
    async init() {
        UI.logDebug("Inicializando app (UI-First)...");

        AppState.generarSlots();
        UI.poblarSelectHorario();

        // Fecha inicial = hoy
        const hoy = new Date().toISOString().split("T")[0];
        AppState.setFecha(hoy);
        document.getElementById("f_fecha").value = hoy;
        UI.actualizarCampoDia(hoy);

        // Render inmediato con datos mock (UI interactiva al instante)
        AppState.setTurnos(this.datosMock());
        UI.renderizarFilas(AppState.getTurnos());
        UI.renderizarCalendario();
        UI.renderizarDisponibilidad();
        UI.renderizarBaseProveedores();

        this.registrarEventos();

        UI.logDebug("UI lista. Resolviendo contexto M365...");

        // Llamadas async en paralelo — sin setTimeout frágiles
        const [resUsuario, resTurnos] = await Promise.allSettled([
            this.cargarUsuario(),
            this.cargarTurnos()
        ]);

        if (resUsuario.status === "rejected") {
            UI.logDebug("Usuario offline: " + resUsuario.reason?.message);
        }
        if (resTurnos.status === "rejected") {
            UI.logDebug("Turnos offline. Interfaz con datos locales.");
            UI.actualizarEstadoConexion(false);
        }
    },

    datosMock() {
        return [
            { Id: 17, Title: "TNPK17", [F.CUIT]: "20-25987412-3", [F.PROVEEDOR]: "Franco SRL",    [F.NUM_OC]: "1011", [F.FECHA]: "2026-06-08", [F.HORARIO]: "08:00 h a 08:45 h", [F.ESTADO]: "Pendiente", [F.PLANTA]: "Packaging", Created: "2026-06-08T04:06:08Z", [F.EMAIL]: "franco@logistica.com" },
            { Id: 16, Title: "TNPK16", [F.CUIT]: "20-25987412-3", [F.PROVEEDOR]: "Franco SRL",    [F.NUM_OC]: "1010", [F.FECHA]: "2026-06-08", [F.HORARIO]: "08:00 h a 08:45 h", [F.ESTADO]: "Aprobado",  [F.PLANTA]: "Packaging", Created: "2026-06-08T03:46:40Z", [F.EMAIL]: "franco@logistica.com" },
            { Id: 15, Title: "TNPK15", [F.CUIT]: "27-30444555-2", [F.PROVEEDOR]: "PEQL Transporte",[F.NUM_OC]: "1008", [F.FECHA]: "2026-06-08", [F.HORARIO]: "08:00 h a 08:45 h", [F.ESTADO]: "Aprobado",  [F.PLANTA]: "Packaging", Created: "2026-06-08T03:45:10Z", [F.EMAIL]: "peql@transportes.com" }
        ];
    },

    // ─── Carga de datos ───────────────────────────────────────────────
    async cargarUsuario() {
        const data = await TurnosService.resolverUsuario();
        AppState.setUsuario({
            name:  data.Title || data.DisplayName || "Usuario",
            email: data.Email || data.UserPrincipalName || ""
        });
        const el = document.getElementById("app-user-name");
        if (el) el.textContent = AppState.getUsuario().name;
        UI.logDebug("Usuario resuelto: " + AppState.getUsuario().name);
        UI.actualizarEstadoConexion(true);
    },

    async cargarTurnos() {
        if (AppState.isLoading()) return;
        UI.setLoading(true);
        UI.logDebug("Sincronizando con SharePoint...");
        try {
            const items = await TurnosService.listarRecientes();
            AppState.setTurnos(items);
            UI.renderizarFilas(items);
            UI.renderizarBaseProveedores();
            UI.renderizarCalendario();
            UI.renderizarDisponibilidad();
            UI.actualizarEstadoConexion(true);
            UI.logDebug(`${items.length} turnos cargados desde SharePoint.`);
        } catch (err) {
            UI.logDebug("Error al cargar: " + err.message);
            UI.actualizarEstadoConexion(false);
            throw err; // re-lanzar para Promise.allSettled
        } finally {
            UI.setLoading(false);
        }
    },

    // ─── Registrar todos los eventos (sin onclick inline) ─────────────
    registrarEventos() {

        // Tabs
        document.querySelectorAll(".tab-btn").forEach(btn => {
            btn.addEventListener("click", () => {
                document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active-tab"));
                btn.classList.add("active-tab");
                document.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));
                const sec = document.getElementById(btn.dataset.target);
                if (sec) sec.classList.add("active");
                if (btn.dataset.target === "s6") UI.renderizarBaseProveedores();
            });
        });

        // Fecha → actualizar día
        document.getElementById("f_fecha")?.addEventListener("change", (e) => {
            if (e.target.value) {
                AppState.setFecha(e.target.value);
                UI.actualizarCampoDia(e.target.value);
                UI.renderizarCalendario();
                UI.renderizarDisponibilidad();
            }
        });

        // Botones del formulario
        document.getElementById("btn-alta")?.addEventListener("click",     () => this.crearTurno());
        document.getElementById("btn-modificar")?.addEventListener("click", () => this.guardarCambios());
        document.getElementById("btn-limpiar")?.addEventListener("click",   () => UI.limpiarFormulario());
        document.getElementById("btn-refrescar")?.addEventListener("click", () => this.cargarTurnos());

        // Filtros de planta
        document.getElementById("btn-filtro-pk")?.addEventListener("click",    () => UI.renderizarFilas(AppState.getTurnos().filter(t => (t[F.PLANTA]||"").toLowerCase() === "packaging")));
        document.getElementById("btn-filtro-in")?.addEventListener("click",    () => UI.renderizarFilas(AppState.getTurnos().filter(t => (t[F.PLANTA]||"").toLowerCase() === "insumos")));
        document.getElementById("btn-filtro-todos")?.addEventListener("click", () => UI.renderizarFilas(AppState.getTurnos()));

        // Event delegation para tabla de turnos (botones consultar, mail, aprobar, cancelar, eliminar)
        document.getElementById("tabla-turnos")?.addEventListener("click", (e) => {
            const btn = e.target.closest("button");
            if (!btn) return;

            if (btn.classList.contains("btn-consultar")) {
                const id = parseInt(btn.dataset.id, 10);
                const t  = AppState.getTurnos().find(item => parseInt(item.Id, 10) === id);
                if (t) {
                    UI.cargarTurnoEnFormulario(t);
                    UI.navegarASeccion("s1");
                    UI.showToast(`Turno TN-${id} cargado en el panel`, "ok");
                    UI.logDebug(`Turno ${id} cargado en formulario.`);
                }
                return;
            }

            if (btn.classList.contains("btn-mail")) {
                this.abrirMailManual(btn.dataset.email, btn.dataset.prov, btn.dataset.fecha, btn.dataset.estado);
                return;
            }

            if (btn.classList.contains("btn-aprobar")) {
                this.interceptarCambioEstado(
                    parseInt(btn.dataset.id, 10), btn.dataset.visual,
                    "Aprobado", btn.dataset.email, btn.dataset.prov, btn.dataset.fecha
                );
                return;
            }

            if (btn.classList.contains("btn-cancelar")) {
                this.interceptarCambioEstado(
                    parseInt(btn.dataset.id, 10), btn.dataset.visual,
                    "Cancelado", btn.dataset.email, btn.dataset.prov, btn.dataset.fecha
                );
                return;
            }

            if (btn.classList.contains("btn-eliminar")) {
                this.eliminarTurno(parseInt(btn.dataset.id, 10), btn.dataset.visual, btn.dataset.prov);
                return;
            }
        });

        // Event delegation para calendario
        document.getElementById("calendar-days-grid")?.addEventListener("click", (e) => {
            const btn = e.target.closest(".btn-cal-dia");
            if (!btn || !btn.dataset.fecha) return;
            AppState.setFecha(btn.dataset.fecha);
            const inputFecha = document.getElementById("f_fecha");
            if (inputFecha) inputFecha.value = btn.dataset.fecha;
            UI.actualizarCampoDia(btn.dataset.fecha);
            UI.renderizarCalendario();
            UI.renderizarDisponibilidad();
        });

        // Modal de correo
        document.getElementById("btn-cerrar-modal")?.addEventListener("click",  () => UI.cerrarModal());
        document.getElementById("btn-abortar-mail")?.addEventListener("click",  () => UI.cerrarModal());
        document.getElementById("mailModal")?.addEventListener("click", (e) => {
            if (e.target === document.getElementById("mailModal")) UI.cerrarModal();
        });
        document.getElementById("btnEnviarMailFinal")?.addEventListener("click", () => this.procesarTransicionYMail());

        // Cerrar modal con Escape
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape") UI.cerrarModal();
        });
    },

    // ─── Crear turno ─────────────────────────────────────────────────
    async crearTurno() {
        const form = UI.leerFormulario();
        const { valid, errors } = Validators.validarFormTurno(form);
        if (!valid) {
            UI.mostrarErroresFormulario(errors);
            return;
        }
        UI.mostrarErroresFormulario([]);

        // Verificación optimista local
        const turnos = AppState.getTurnos();
        const ocupadoLocal = turnos.some(t =>
            t[F.FECHA] && String(t[F.FECHA]).split("T")[0] === form.fecha &&
            String(t[F.HORARIO]||"").trim() === form.horario &&
            (t[F.PLANTA]||"packaging").toLowerCase() === form.planta.toLowerCase() &&
            (t[F.ESTADO]||"").trim().toLowerCase() === "aprobado"
        );
        if (ocupadoLocal) {
            UI.showToast("Ese horario ya está reservado.", "err");
            return;
        }

        UI.setLoading(true);
        UI.logDebug(`Creando turno: ${form.prov} — ${form.fecha} — ${form.horario}`);

        try {
            // CORRECCIÓN: verificar disponibilidad en el servidor (evita race condition)
            const disponible = await TurnosService.verificarSlotDisponible(form.fecha, form.horario, form.planta);
            if (!disponible) {
                UI.showToast("Ese horario fue reservado por otro usuario. Elija otro.", "err");
                UI.setLoading(false);
                return;
            }

            const payload = {
                "Title":     "PROV-" + Date.now().toString().slice(-6),
                [F.CUIT]:    form.cuit,
                [F.NUM_OC]:  form.oc,
                [F.PROVEEDOR]: form.prov,
                [F.EMAIL]:   form.email,
                [F.FECHA]:   form.fecha + "T00:00:00Z",
                [F.HORARIO]: form.horario,
                [F.ESTADO]:  "Pendiente",
                [F.PLANTA]:  form.planta
            };

            const nuevo = await TurnosService.crear(payload);
            UI.showToast("Turno registrado en SharePoint.", "ok");
            UI.userLog(`Alta de turno — ${form.prov} — ${form.fecha}`);
            UI.limpiarFormulario();
            await this.cargarTurnos();

        } catch (err) {
            UI.logDebug("Creación offline: " + err.message);
            // Fallback local con id temporal negativo para distinguirlo de IDs reales
            const tempId = -(Date.now());
            AppState.agregarTurno({
                Id: tempId, Title: "PROV-LOCAL",
                [F.CUIT]: form.cuit, [F.PROVEEDOR]: form.prov,
                [F.NUM_OC]: form.oc, [F.EMAIL]: form.email,
                [F.FECHA]: form.fecha, [F.HORARIO]: form.horario,
                [F.ESTADO]: "Pendiente", [F.PLANTA]: form.planta,
                Created: new Date().toISOString()
            });
            UI.showToast("Alta registrada localmente (sin conexión).", "warn");
            UI.limpiarFormulario();
            UI.renderizarFilas(AppState.getTurnos());
            UI.renderizarDisponibilidad();
        } finally {
            UI.setLoading(false);
        }
    },

    // ─── Guardar cambios ─────────────────────────────────────────────
    async guardarCambios() {
        const form = UI.leerFormulario();
        if (!form.itemId) return;

        const { valid, errors } = Validators.validarFormTurno(form);
        if (!valid) {
            UI.mostrarErroresFormulario(errors);
            return;
        }
        UI.mostrarErroresFormulario([]);
        UI.setLoading(true);

        const payload = {
            [F.CUIT]:      form.cuit,
            [F.NUM_OC]:    form.oc,
            [F.PROVEEDOR]: form.prov,
            [F.EMAIL]:     form.email,
            [F.FECHA]:     form.fecha + "T00:00:00Z",
            [F.HORARIO]:   form.horario,
            [F.PLANTA]:    form.planta
        };

        try {
            await TurnosService.actualizar(form.itemId, payload);
            AppState.actualizarTurno(form.itemId, {
                [F.CUIT]: form.cuit, [F.NUM_OC]: form.oc, [F.PROVEEDOR]: form.prov,
                [F.EMAIL]: form.email, [F.FECHA]: form.fecha, [F.HORARIO]: form.horario,
                [F.PLANTA]: form.planta
            });
            UI.showToast("Cambios guardados.", "ok");
            UI.userLog(`Modificación turno ID ${form.itemId} — ${form.prov}`);
            UI.limpiarFormulario();
            UI.renderizarFilas(AppState.getTurnos());
            UI.renderizarDisponibilidad();
        } catch (err) {
            UI.logDebug("Error al guardar: " + err.message);
            UI.showToast("Error al guardar. Verifique la conexión.", "err");
        } finally {
            UI.setLoading(false);
        }
    },

    // ─── Cambio de estado ─────────────────────────────────────────────
    interceptarCambioEstado(itemId, visualId, nuevoEstado, email, prov, fecha) {
        const turno = AppState.getTurnos().find(t => parseInt(t.Id, 10) === parseInt(itemId, 10));
        if (turno) {
            const estadoActual = String(turno[F.ESTADO] || "").trim().toLowerCase();
            if (estadoActual === "aprobado" && nuevoEstado === "Aprobado") {
                alert(`El turno ${visualId} ya está aprobado y no puede modificarse.`);
                return;
            }
        }

        if (!confirm(`¿Confirma cambiar el estado del turno ${visualId} a [${nuevoEstado.toUpperCase()}]?`)) return;

        AppState.setTransicion({ itemId, visualId, nuevoEstado, email, prov });

        if (nuevoEstado === "Aprobado") {
            if (confirm("¿Desea notificar al proveedor por correo?")) {
                UI.abrirModal(email, prov, fecha, "Aprobado");
            } else {
                this.procesarTransicionDirecta();
            }
        } else {
            UI.abrirModal(email, prov, fecha, "Cancelado");
        }
    },

    async procesarTransicionDirecta() {
        const ctx = AppState.getTransicion();
        if (!ctx) return;
        UI.setLoading(true);

        try {
            await TurnosService.actualizar(ctx.itemId, { [F.ESTADO]: ctx.nuevoEstado });
        } catch (err) {
            UI.logDebug("Transición offline: " + err.message);
        }

        AppState.actualizarTurno(ctx.itemId, { [F.ESTADO]: ctx.nuevoEstado });
        UI.showToast(`Turno ${ctx.visualId} → ${ctx.nuevoEstado}`, "ok");
        UI.userLog(`Cambio de estado: ${ctx.visualId} → ${ctx.nuevoEstado}`);
        AppState.limpiarTransicion();
        UI.renderizarFilas(AppState.getTurnos());
        UI.renderizarCalendario();
        UI.renderizarDisponibilidad();
        UI.setLoading(false);
    },

    async procesarTransicionYMail() {
        const ctx = AppState.getTransicion();
        if (!ctx) return;
        UI.setLoading(true);

        try {
            await TurnosService.actualizar(ctx.itemId, { [F.ESTADO]: ctx.nuevoEstado });
        } catch (err) {
            UI.logDebug("Transición offline: " + err.message);
        }

        AppState.actualizarTurno(ctx.itemId, { [F.ESTADO]: ctx.nuevoEstado });

        const para   = (document.getElementById("m_para").value   || "").trim();
        const asunto = (document.getElementById("m_asunto").value  || "").trim();
        const cuerpo = (document.getElementById("m_cuerpo").value  || "").trim();

        UI.showToast(`Turno ${ctx.visualId} actualizado.`, "ok");
        UI.userLog(`Transición + correo: ${ctx.visualId} → ${ctx.nuevoEstado}`);
        UI.cerrarModal();

        if (para) this.abrirMailManual(para, ctx.prov, AppState.getFecha(), ctx.nuevoEstado);

        UI.renderizarFilas(AppState.getTurnos());
        UI.renderizarCalendario();
        UI.renderizarDisponibilidad();
        UI.setLoading(false);
    },

    // ─── Eliminar turno ───────────────────────────────────────────────
    async eliminarTurno(itemId, visualId, prov) {
        if (!confirm(`¿Eliminar permanentemente el turno ${visualId} (${prov})? El slot quedará libre.`)) return;
        UI.setLoading(true);

        try {
            await TurnosService.eliminar(itemId);
        } catch (err) {
            UI.logDebug("Eliminación offline: " + err.message);
        }

        AppState.eliminarTurno(itemId);
        UI.showToast(`Turno ${visualId} eliminado.`, "ok");
        UI.userLog(`Eliminación: ${visualId} — ${prov}`);
        UI.renderizarFilas(AppState.getTurnos());
        UI.renderizarCalendario();
        UI.renderizarDisponibilidad();
        UI.setLoading(false);
    },

    // ─── Correo ───────────────────────────────────────────────────────
    abrirMailManual(email, prov, fecha, estado) {
        const asunto = `Estado de Turno - Molca Spegazzini`;
        const cuerpo = `Estimado/a ${prov},\n\nSu solicitud de turno para el día ${fecha} se encuentra en estado: ${estado}.\n\nSaludos,\nLogística - Molca Spegazzini`;
        window.location.href = `mailto:${encodeURIComponent(email)}?subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(cuerpo)}`;
    }
};

/* ══════════════════════════════════════════════════════════
   PUNTO DE ENTRADA
══════════════════════════════════════════════════════════ */
App.init();
</script>
</body>
</html>
