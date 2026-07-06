<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERP Logistica de Turnos | Molca V38</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap');
        :root { --sp-blue: #38bdf8; --sp-bg: #0b1120; --sp-panel: rgba(15, 23, 42, 0.92); --sp-border: rgba(56, 189, 248, 0.15); }
        body, input, select, button, table, textarea, .mono { font-family: 'Inter', system-ui, -apple-system, sans-serif; }
        body { background-color: var(--sp-bg); color: #e2e8f0; margin: 0; font-size: 0.9rem; line-height: 1.5; -webkit-font-smoothing: antialiased; }
        .glass { background: var(--sp-panel); border: 1px solid var(--sp-border); backdrop-filter: blur(16px); }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.2s ease-out; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
        .tab-btn { color: #94a3b8; transition: all .2s; font-size: 0.90rem; padding: 12px 16px; cursor: pointer; border-left: 3px solid transparent; font-weight: 500; }
        .tab-btn:hover { background: rgba(30, 41, 59, 0.5); color: #e2e8f0; }
        .tab-btn.active-tab { background: rgba(3, 105, 161, 0.2); color: #fff; border-left: 3px solid #38bdf8; font-weight: 600; }
        #toast { position: fixed; bottom: 1.5rem; right: 1.5rem; padding: .75rem 1.5rem; border-radius: 8px; font-size: .9rem; font-weight: 600; opacity: 0; transition: opacity .3s; z-index: 9999; pointer-events: none; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        #toast.show { opacity: 1; }
        #toast.ok   { background:#064e3b; border:1px solid #10b981; color:#34d399; }
        #toast.err  { background:#7f1d1d; border:1px solid #f87171; color:#f87171; }
        .etl-step { transition: all 0.3s; opacity: 0.5; }
        .etl-step.active { opacity: 1; transform: scale(1.02); border-color: #38bdf8; box-shadow: 0 0 15px rgba(56,189,248,0.2); }
        .etl-step.done { opacity: 1; border-color: #4ade80; }
        .input-error { border-color: #f43f5e !important; box-shadow: 0 0 0 1px #f43f5e; }
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: rgba(15, 23, 42, 0.5); border-radius: 4px; }
        ::-webkit-scrollbar-thumb { background: #334155; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #475569; }
        
        /* Estilos CSV Capacidad */
        .cap-parent-row { background: rgba(2, 8, 23, 0.55); }
        .cap-parent-row:hover { background: rgba(15, 23, 42, 0.90); }
        .cap-child-row { background: rgba(15, 23, 42, 0.35); }
        .cap-child-row.hidden-row { display: none; }
        .expander-btn { width: 18px; height: 18px; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px; border: 1px solid #334155; background: #0f172a; color: #38bdf8; font-weight: 800; line-height: 1; margin-right: 8px; cursor: pointer; transition: transform .25s ease, background .2s ease; }
        .expander-btn:hover { background: #1e293b; }
        .expander-btn.open { transform: rotate(90deg); background:#1e293b; }
        .cap-child-indent { display: inline-block; width: 26px; color: #38bdf8; }
        .mono-num { font-variant-numeric: tabular-nums; }
        .csv-status { border-radius: 12px; padding: 12px 14px; margin-bottom: 14px; border: 1px solid transparent; }
        .csv-status.ok { background: rgba(20, 83, 45, 0.35); border-color: rgba(74, 222, 128, 0.45); color: #bbf7d0; }
        .csv-status.warn { background: rgba(120, 53, 15, 0.30); border-color: rgba(251, 191, 36, 0.45); color: #fde68a; }
        .csv-status.err { background: rgba(127, 29, 29, 0.30); border-color: rgba(248, 113, 113, 0.45); color: #fecaca; }
        .csv-status .csv-title { font-size: 12px; font-weight: 800; text-transform: uppercase; letter-spacing: .04em; }
        .csv-status .csv-detail { font-size: 12px; margin-top: 4px; line-height: 1.45; word-break: break-word; }
        .cap-input, .cap-select { background:#020617; border:1px solid #334155; color:#e2e8f0; border-radius:4px; padding:4px 6px; width:100%; font-size:11px; }
        .cap-input.num { text-align:right; }
        .cap-select { min-width:72px; }
        .cap-col-planta { min-width:160px; }

        /* Estilos Splash Screen */
        #splash-screen { position: fixed; inset: 0; background-color: #020617; z-index: 99999; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: 'JetBrains Mono', monospace; transition: opacity 0.8s ease-out; }
        #splash-screen.hidden-splash { opacity: 0; pointer-events: none; }
        #splash-content { width: 100%; max-width: 600px; padding: 2rem; }
        .term-header { color: #38bdf8; font-weight: 700; margin-bottom: 1rem; border-bottom: 1px dashed #334155; padding-bottom: 0.5rem; }
        #splash-log { color: #4ade80; font-size: 0.85rem; line-height: 1.6; height: 300px; overflow-y: auto; }
        .cursor-blink { display: inline-block; width: 8px; height: 1em; background-color: #4ade80; animation: blink 1s step-end infinite; vertical-align: middle; margin-left: 4px; }
        @keyframes blink { 0%, 100% { opacity: 1; } 50% { opacity: 0; } }
    </style>
</head>
<body class="flex h-screen overflow-hidden text-slate-200 selection:bg-sky-500/30 selection:text-sky-200">

<!-- SPLASH SCREEN -->
<div id="splash-screen">
    <div id="splash-content">
        <div class="term-header">MOLCA.ERP [Version 38.4.1]<br>Sistema de Gestion Logistica</div>
        <div id="splash-log"></div>
        <div><span class="text-emerald-400">>_</span><span class="cursor-blink"></span></div>
    </div>
</div>

<aside class="w-64 glass flex flex-col py-6 border-r border-slate-700/50 h-full z-10 shadow-2xl shrink-0">
    <div class="px-6 mb-6">
        <h1 class="text-2xl font-extrabold text-white mb-1 tracking-tight">MOLCA<span class="text-sky-400">.ERP</span></h1>
        <p class="text-[10px] text-slate-400 uppercase font-semibold tracking-widest mb-4">Logistica de Turnos</p>
        <div class="text-xs inline-flex items-center gap-2 px-2.5 py-1.5 rounded-md bg-slate-900/50 border border-slate-700/50 w-full">
            <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse shadow-[0_0_8px_rgba(52,211,153,0.8)]"></span>
            <span class="font-semibold text-slate-300">API Conectada</span>
        </div>
    </div>

    <nav class="space-y-1 flex-1 overflow-y-auto px-3 custom-scrollbar" id="main-nav">
        <button class="w-full text-left rounded-lg tab-btn active-tab flex items-center gap-3" data-target="s2" id="btn-tab-monitor">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17V7m0 10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2a2 2 0 012 2m0 10a2 2 0 002 2h2a2 2 0 002-2M9 7a2 2 0 012-2h2a2 2 0 012 2m0 10V7m0 10a2 2 0 002 2h2a2 2 0 002-2V7a2 2 0 00-2-2h-2a2 2 0 00-2 2"></path></svg>
            Monitor Diario
        </button>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="s1" id="btn-tab-abm" onclick="abrirAltaTurno()">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
            Gestion de Turno
        </button>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="s10" onclick="initDashboard()">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z"></path></svg>
            Dashboard e indicadores
        </button>

        <div class="pt-5 pb-2 px-3">
            <span class="text-[10px] font-bold uppercase text-slate-500 tracking-wider">Menu de Configuracion</span>
        </div>
        
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="sFlota">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path></svg>
            Flota
        </button>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="s6">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
            Proveedores
        </button>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="s7">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
            Usuarios
        </button>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="sZonas">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16"></path></svg>
            Zonas de Descarga
        </button>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="s8" onclick="renderizarABMHorarios()">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
            Config. Horarios
        </button>
        
        <div class="pt-5 pb-2 px-3">
            <span class="text-[10px] font-bold uppercase text-slate-500 tracking-wider">Sistema</span>
        </div>
        <button class="w-full text-left rounded-lg tab-btn flex items-center gap-3" data-target="s9">
            <svg class="w-4 h-4 opacity-70" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
            Auditoria ETL
        </button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto relative w-full bg-slate-900/40 custom-scrollbar">
    <div id="header-user-box" class="absolute top-8 right-8 glass px-4 py-2 rounded-lg flex items-center gap-3 text-sm border border-slate-700/50 shadow-sm z-20">
        <div class="w-7 h-7 rounded bg-sky-500/20 flex items-center justify-center text-sky-400">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>
        </div>
        <div>
            <span id="app-user-name" class="block text-white font-semibold leading-tight">Iniciando...</span>
            <span class="block text-[10px] text-slate-400">Sesion Activa</span>
        </div>
    </div>

    <!-- SECCION 2: MONITOR DE TURNOS DIARIOS -->
    <section id="s2" class="tab-content active w-full max-w-[1600px] mx-auto">
        <div class="flex justify-start items-center mb-6 gap-4">
            <div>
                <h2 class="text-2xl font-bold text-white tracking-tight">Monitor de Turnos Diarios</h2>
            </div>
            <div class="flex gap-3 ml-4">
                <button onclick="abrirAltaTurno()" class="bg-sky-600 hover:bg-sky-500 text-white px-5 py-2 text-xs font-semibold rounded-lg shadow-sm shadow-sky-900/50 transition flex items-center gap-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
                    Nuevo Turno
                </button>
                <button onclick="enviarResumenDiario()" class="bg-slate-800 hover:bg-slate-700 text-white px-4 py-2 text-xs font-semibold rounded-lg border border-slate-600 transition flex items-center gap-2 shadow-sm">
                    <svg class="w-4 h-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path></svg>
                    Enviar Resumen
                </button>
            </div>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 h-[calc(100vh-140px)]">
            
            <!-- PANEL DISPONIBILIDAD (ZONAS) -->
            <div class="col-span-1 lg:col-span-3 glass p-5 rounded-xl flex flex-col h-full overflow-hidden border border-slate-700/50 shadow-sm order-2 lg:order-1">
                <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-4 shrink-0 flex items-center gap-2">
                    <svg class="w-4 h-4 text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                    Turnos Disponibles
                </h3>
                
                <div class="w-full bg-slate-900 p-3 rounded-lg border border-slate-700/50 mb-5 shadow-inner shrink-0">
                    <div class="flex justify-between items-center mb-3 px-1">
                        <span id="calendar-month-title" class="font-bold text-sky-400 uppercase tracking-wide text-sm">MES</span>
                        <div class="text-[10px] text-slate-400 font-semibold uppercase bg-slate-800 px-2 py-0.5 rounded">Calendario</div>
                    </div>
                    <div class="grid grid-cols-7 text-center font-bold text-slate-500 uppercase tracking-wider mb-2 text-[10px]">
                        <span>Lu</span><span>Ma</span><span>Mi</span><span>Ju</span><span>Vi</span><span>Sa</span><span>Do</span>
                    </div>
                    <div id="calendar-days-grid" class="grid grid-cols-7 gap-1 text-center font-medium text-xs w-full"></div>
                </div>
                
                <div id="panel-resumen-capacidad" class="w-full bg-slate-950/80 p-2 rounded border border-slate-800 mb-2 shadow-inner shrink-0 max-h-40 overflow-y-auto text-[10px]"></div>

                <div class="flex-1 overflow-y-auto pr-1 relative custom-scrollbar">
                    <div id="panel-disponibilidad-dinamico" class="space-y-4"></div>
                </div>
            </div>

            <!-- TABLA PRINCIPAL Y FILTROS -->
            <div class="col-span-1 lg:col-span-9 flex flex-col h-full order-1 lg:order-2">
                <div class="flex gap-3 mb-4 items-end bg-slate-900/50 p-4 rounded-lg border border-slate-700 shrink-0 flex-wrap shadow-sm">
                    <div class="flex-1 min-w-[120px]">
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Patente</label>
                        <input type="text" id="filtro_patente" onkeyup="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-2 text-xs text-white rounded outline-none focus:border-sky-500 w-full transition-colors font-sans" placeholder="Buscar...">
                    </div>
                    <div class="flex-1 min-w-[140px]">
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Proveedor</label>
                        <select id="filtro_proveedor_busq" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-2 text-xs text-white rounded outline-none focus:border-sky-500 w-full transition-colors font-sans">
                            <option value="TODOS">-- Todos --</option>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[140px]">
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Planta Fisica</label>
                        <select id="filtro_planta_descarga" onchange="sincronizarFiltrosYMonitor()" class="bg-slate-950 border border-slate-700 p-2 text-xs text-white rounded outline-none focus:border-sky-500 w-full transition-colors font-sans">
                            <option value="TODAS">-- Todas --</option>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[140px]">
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Zona Descarga</label>
                        <select id="filtro_zona" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-2 text-xs text-white rounded outline-none focus:border-sky-500 w-full transition-colors font-sans">
                            <option value="TODAS">-- Todas --</option>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[140px]">
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Responsable</label>
                        <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-2 text-xs text-white rounded outline-none focus:border-sky-500 w-full transition-colors font-sans">
                            <option value="TODOS">-- Todos --</option>
                        </select>
                    </div>
                    <div class="flex-1 min-w-[140px]">
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Estado</label>
                        <select id="filtro_estado" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-2 text-xs text-white rounded outline-none focus:border-sky-500 w-full transition-colors font-sans">
                            <option value="TODOS">-- Todos --</option>
                            <option value="Pendiente">Pendientes</option>
                            <option value="Aprobado">Aprobados</option>
                            <option value="Reprogramado">Reprogramados</option>
                            <option value="Cancelado">Cancelados/Rechazados</option>
                        </select>
                    </div>
                    <div class="flex items-center gap-2">
                        <button onclick="restablecerFiltros()" class="bg-slate-800 text-slate-300 border border-slate-600 px-3 py-2 text-xs font-semibold rounded hover:bg-slate-700 transition" title="Limpiar Filtros">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4h16v2l-6 5.5v5.5l-4 2v-7.5L4 6V4z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3l18 18"></path></svg>
                        </button>
                        <button onclick="refrescarDBAbsoluto()" class="bg-sky-900/50 border border-sky-700 text-sky-400 px-4 py-2 text-xs font-bold rounded hover:bg-sky-800/50 transition flex items-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
                            Sync DB
                        </button>
                    </div>
                </div>
                
                <div class="glass flex-1 border border-slate-700/50 rounded-lg relative overflow-hidden flex flex-col shadow-sm">
                    <div class="overflow-y-auto overflow-x-auto flex-1 custom-scrollbar">
                        <table class="w-full text-left text-sm text-slate-300 relative font-sans">
                            <thead class="bg-slate-900/90 backdrop-blur text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow z-10">
                                <tr>
                                    <th class="py-3 px-4 tracking-wider">ID</th>
                                    <th class="px-3">Fecha</th>
                                    <th class="px-3">Planta</th>
                                    <th class="px-3">Proveedor</th>
                                    <th class="px-3">Patente</th>
                                    <th class="px-3">Horario</th>
                                    <th class="px-3 text-center">Estado</th>
                                    <th class="px-4 text-center">Accion</th>
                                </tr>
                            </thead>
                            <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                                <tr><td colspan="8" class="p-8 text-center text-slate-500 text-sm">Cargando base de datos...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- SECCION 1: ABM DE TURNOS -->
    <section id="s1" class="tab-content mt-8 w-full max-w-5xl mx-auto">
        <div class="flex items-center gap-4 mb-4">
            <button id="btn-modo-modificar" onclick="modoABM_Modificar()" class="hidden bg-amber-600 hover:bg-amber-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">Modificar</button>
            <h2 class="text-2xl font-bold text-sky-400 tracking-tight">Gestion de Turno</h2>
            <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1.5 bg-emerald-900/50 text-emerald-400 border border-emerald-800 rounded-md font-bold tracking-wide">Alta de Turno</div>
        </div>
        
        <div id="abm-mensaje-estado" class="text-sm font-bold px-4 py-3 rounded-lg mb-5 hidden shadow-sm border font-sans"></div>

        <div class="glass p-8 rounded-xl w-full grid grid-cols-2 gap-x-8 gap-y-6 border border-slate-700/50 shadow-lg relative overflow-hidden">
            <div class="absolute top-0 right-0 w-64 h-64 bg-sky-500/5 rounded-full blur-3xl pointer-events-none"></div>

            <input type="hidden" id="f_item_id">
            
            <div class="col-span-2 grid grid-cols-3 gap-6 border-b border-slate-700/50 pb-6 mb-2 relative z-10">
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Patente Vehiculo *</label>
                    <div class="flex gap-2">
                        <input type="text" id="f_patente" list="dl_flota_patentes" placeholder="Ej: AB123CD" onblur="autocompletarPatenteFlota()" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-amber-300 uppercase outline-none f-control transition-colors focus:border-sky-500 flex-1 rounded text-sm shadow-sm font-sans" maxlength="7">
                        <button type="button" onclick="syncFlotaABM()" class="bg-slate-700 hover:bg-slate-600 text-emerald-300 px-3 py-2 text-xs font-bold rounded border border-slate-600 transition shrink-0" title="Sincronizar flota">Sync</button>
                    </div>
                    <datalist id="dl_flota_patentes"></datalist>
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Hora Ingreso Real</label>
                    <input type="time" id="f_hora_ing" class="bg-slate-900/50 border border-slate-800 p-2.5 w-full text-emerald-400 outline-none transition-colors focus:border-sky-500 cursor-not-allowed opacity-70 rounded text-sm shadow-sm font-sans" readonly>
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Hora Salida Real</label>
                    <input type="time" id="f_hora_sal" class="bg-slate-900/50 border border-slate-800 p-2.5 w-full text-rose-400 outline-none transition-colors focus:border-sky-500 cursor-not-allowed opacity-70 rounded text-sm shadow-sm font-sans" readonly>
                </div>
            </div>

            <div class="relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Num Proveedor / CUIT *</label>
                <input type="text" id="f_cuit" placeholder="Ej: 30712345678" onblur="autocompletarProveedor()" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white font-sans outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm">
            </div>
            <div class="relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Num Orden Compra (OC)</label>
                <input type="text" id="f_oc" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans">
            </div>
            <div class="col-span-2 relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Razon Social Proveedor *</label>
                <input type="text" id="f_proveedor" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans" readonly>
            </div>
            <div class="col-span-2 relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Email de Contacto</label>
                <input type="email" id="f_email" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans">
            </div>

            <div class="relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Planta Fisica (Ubicacion)</label>
                <select id="f_planta_descarga" onchange="onPlantaFisicaChange()" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans"></select>
            </div>
            <div class="relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Zona de Descarga (Area)</label>
                <select id="f_planta" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans"></select>
            </div>

            <div class="relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Fecha Solicitud *</label>
                <input type="date" id="f_fecha" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans">
            </div>
            <div class="relative z-10">
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1.5 tracking-wider">Slot Horario Calculado *</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-2.5 w-full text-white outline-none f-control transition-colors focus:border-sky-500 rounded text-sm shadow-sm font-sans"></select>
            </div>

            <div class="col-span-2 bg-slate-900/50 p-4 rounded-lg text-sm border border-slate-700/50 text-slate-300 flex justify-between items-center mt-2 shadow-inner relative z-10 font-sans">
                <span>Dia Semana: <strong id="f_dia" class="text-white">-</strong></span>
                <label class="inline-flex items-center gap-2 cursor-pointer select-none">
                    <input type="checkbox" id="f_sobreturno" class="w-4 h-4 rounded bg-slate-900 border-slate-600 text-violet-500 focus:ring-violet-500 f-control">
                    <span class="text-violet-300 font-bold uppercase text-xs tracking-wider">Sobreturno / Excepcion</span>
                </label>
            </div>

            <div class="col-span-2 flex gap-4 mt-2 relative z-10" id="panel-botones-abm"></div>

            <div class="col-span-2 mt-4 border-t border-slate-700/50 pt-5 flex items-end justify-between relative z-10" id="panel-tracking">
                <div class="flex gap-8 items-end">
                    <div>
                        <span class="block text-[10px] uppercase text-slate-400 font-bold mb-2 tracking-wider">Registro Operativo (Porteria)</span>
                        <div class="flex gap-3">
                            <button id="btn-track-in" onclick="marcarTrackingForm('IN')" class="bg-slate-800/80 text-emerald-400 border border-emerald-900/50 hover:bg-slate-700 px-5 py-2 rounded-lg text-xs font-bold transition shadow-sm">
                                [ In ] Ingreso
                            </button>
                            <button id="btn-track-out" onclick="marcarTrackingForm('OUT')" class="bg-slate-800/80 text-rose-400 border border-rose-900/50 hover:bg-slate-700 px-5 py-2 rounded-lg text-xs font-bold transition shadow-sm">
                                [ Out ] Salida
                            </button>
                        </div>
                    </div>
                    <div class="pb-1.5">
                        <span class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Responsable Operacion</span>
                        <span id="f_usuario_gestor" class="text-white font-bold text-sm uppercase drop-shadow-sm font-sans">-</span>
                    </div>
                </div>
                <div class="text-right flex flex-col justify-end">
                    <span class="block text-[10px] uppercase text-slate-400 font-bold mb-1 tracking-wider">Estado Transaccion</span>
                    <span id="f_estado_actual" class="text-2xl font-black text-slate-500 uppercase tracking-widest drop-shadow-md font-sans">NUEVO</span>
                </div>
            </div>
        </div>
    </section>

    <!-- PROVEEDORES -->
    <section id="s6" class="tab-content mt-8 w-full max-w-[1400px] mx-auto">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h2 class="text-2xl font-bold text-sky-400 tracking-tight">Proveedores</h2>
                <p class="text-sm text-slate-400 mt-1">Gestion del padron y sincronizacion de datos de terceros.</p>
            </div>
        </div>
        
        <div class="glass p-8 rounded-xl mb-6 border border-slate-700 w-full text-sm shadow-md font-sans">
            <input type="hidden" id="p_index">
            <div class="grid grid-cols-12 gap-5 items-end">
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Usuario Creador</label>
                    <input type="text" id="p_usuario" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-slate-400 rounded outline-none cursor-not-allowed shadow-sm" readonly>
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Responsable Interno</label>
                    <select id="p_resp" onchange="autoCompletarMailResp()" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm"></select>
                </div>
                <div class="col-span-4">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Mail Responsable</label>
                    <input type="email" id="p_mail" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-slate-400 rounded outline-none cursor-not-allowed shadow-sm" readonly>
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Tipo Insumo</label>
                    <select id="p_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                        <option value="">- Tipo -</option>
                        <option value="Insumos">Insumos</option>
                        <option value="Packaging">Packaging</option>
                        <option value="Materia Prima">Materia Prima</option>
                    </select>
                </div>
                
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Num Prov (ID)</label>
                    <input type="text" id="p_num_prov" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500 shadow-sm font-sans">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">CUIT (Fijo)</label>
                    <input type="text" id="p_cuit" placeholder="Ej: 30712345678" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500 shadow-sm font-sans">
                </div>
                <div class="col-span-5">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Razon Social Proveedor</label>
                    <input type="text" id="p_razon" placeholder="Ej: Molinos del Sur SA" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Estado Operativo</label>
                    <select id="p_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">No Habilitado</option>
                    </select>
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_prov" onclick="eliminarProveedor()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioProveedor()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionProveedor()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>

        <div class="glass flex-1 border border-slate-700/50 rounded-lg relative overflow-hidden flex flex-col shadow-sm">
            <div class="overflow-y-auto overflow-x-auto h-[500px] custom-scrollbar">
                <table class="w-full text-left text-sm text-slate-300 relative font-sans">
                    <thead class="bg-slate-900/90 backdrop-blur text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow z-10">
                        <tr>
                            <th class="py-3 px-4">Usuario</th>
                            <th class="px-3">Responsable</th>
                            <th class="px-3 tracking-wider">N Prov</th>
                            <th class="px-3 tracking-wider">CUIT</th>
                            <th class="px-3">Razon Social</th>
                            <th class="px-3">Insumo</th>
                            <th class="px-3">Estado</th>
                            <th class="px-4 text-center">Accion</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-proveedores" class="divide-y divide-slate-700/50">
                        <tr><td colspan="8" class="p-8 text-center text-slate-500 text-sm">Sin padron de proveedores cargado.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- USUARIOS -->
    <section id="s7" class="tab-content mt-8 w-full max-w-[1400px] mx-auto">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h2 class="text-2xl font-bold text-sky-400 tracking-tight">Usuarios</h2>
                <p class="text-sm text-slate-400 mt-1">Configuracion de perfiles y listas de distribucion.</p>
            </div>
        </div>
        
        <div class="glass p-8 rounded-xl mb-6 border border-slate-700 w-full text-sm shadow-md font-sans">
            <input type="hidden" id="u_index">
            <div class="grid grid-cols-1 md:grid-cols-6 gap-5 items-end">
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">ID Usuario</label>
                    <input type="text" id="u_id" placeholder="Ej: Usu11" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500 shadow-sm font-sans">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Nombre y Apellido</label>
                    <input type="text" id="u_nombre" placeholder="Ej: Gomez, Juan" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Email Corporativo</label>
                    <input type="email" id="u_email" placeholder="Ej: gomezj@molca.com" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Planta Asociada</label>
                    <select id="u_planta" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm"></select>
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Recibe Reporte</label>
                    <select id="u_reporte" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                        <option value="SI">SI</option>
                        <option value="NO">NO</option>
                    </select>
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Estado</label>
                    <select id="u_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">No Habilitado</option>
                    </select>
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_usu" onclick="eliminarUsuario()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioUsuario()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionUsuario()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>

        <div class="glass flex-1 border border-slate-700/50 rounded-lg relative overflow-hidden flex flex-col shadow-sm">
            <div class="overflow-y-auto overflow-x-auto h-[500px] custom-scrollbar">
                <table class="w-full text-left text-sm text-slate-300 relative font-sans">
                    <thead class="bg-slate-900/90 backdrop-blur text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow z-10">
                        <tr><th class="py-3 px-4">ID</th><th class="px-3">Nombre y Apellido</th><th class="px-3">Email</th><th class="px-3">Planta</th><th class="px-3">Reporte</th><th class="px-3">Estado</th><th class="px-4 text-center">Accion</th></tr>
                    </thead>
                    <tbody id="tabla-usuarios" class="divide-y divide-slate-700/50">
                        <tr><td colspan="7" class="p-8 text-center text-slate-500 text-sm">Sin datos de usuarios en cache.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- FLOTA -->
    <section id="sFlota" class="tab-content mt-8 w-full max-w-[1400px] mx-auto">
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-sky-400 tracking-tight">Flota</h2>
            <p class="text-xs text-slate-400">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Documentos compartidos/Flota.csv</span></p>
        </div>
        
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm font-sans">
            <input type="hidden" id="fl_item_id">
            <div class="grid grid-cols-12 gap-4 items-end mb-2">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Patente *</label>
                    <input type="text" id="fl_patente" class="w-full bg-slate-900 border border-slate-700 p-2 text-amber-300 font-bold uppercase rounded outline-none focus:border-sky-500" placeholder="Ej: AB123CD">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Descripcion</label>
                    <input type="text" id="fl_descripcion" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500" placeholder="Marca / Modelo">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Vehiculo *</label>
                    <select id="fl_tipo" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Tipo -</option>
                        <option value="CHASIS">CHASIS</option>
                        <option value="BALANCIN">BALANCIN</option>
                        <option value="SEMI">SEMI</option>
                        <option value="UTILITARIO">UTILITARIO</option>
                        <option value="FURGON">FURGON</option>
                    </select>
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Empresa / Proveedor</label>
                    <input type="text" id="fl_empresa" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">CUIT Empresa</label>
                    <input type="text" id="fl_cuit" class="w-full bg-slate-900 border border-slate-700 p-2 text-amber-300 font-bold rounded outline-none focus:border-sky-500">
                </div>
            </div>

            <div class="grid grid-cols-12 gap-4 items-end mb-2">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre Chofer</label>
                    <input type="text" id="fl_nombre" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Apellido Chofer</label>
                    <input type="text" id="fl_apellido" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">DNI</label>
                    <input type="text" id="fl_dni" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Correo</label>
                    <input type="email" id="fl_correo" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Celular</label>
                    <input type="text" id="fl_celular" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
            </div>

            <div class="grid grid-cols-12 gap-4 items-end">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Cap 1 (Pallets)</label>
                    <input type="text" id="fl_cap1" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Cap 2 (KGs)</label>
                    <input type="text" id="fl_cap2" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Cap 3 (Vol)</label>
                    <input type="text" id="fl_cap3" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Disp.</label>
                    <input type="text" id="fl_tipodisp" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Num Disp.</label>
                    <input type="text" id="fl_numdisp" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado *</label>
                    <select id="fl_estado" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">Deshabilitado</option>
                    </select>
                </div>
            </div>

            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_flota" onclick="eliminarFlota()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioFlota()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionFlota()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>

        <div class="glass flex-1 border border-slate-700/50 rounded-lg relative overflow-hidden flex flex-col shadow-sm">
            <div class="overflow-y-auto overflow-x-auto h-[480px] custom-scrollbar">
                <table class="w-full text-left text-sm text-slate-300 whitespace-nowrap">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0">
                        <tr>
                            <th class="py-3 px-4">Patente</th>
                            <th class="px-3">Tipo</th>
                            <th class="px-3">Empresa / Prov.</th>
                            <th class="px-3">Chofer</th>
                            <th class="px-3">Cap (KGs)</th>
                            <th class="px-3">Estado</th>
                            <th class="px-4 text-center">Accion</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-flota" class="divide-y divide-slate-700/50">
                        <tr><td colspan="7" class="p-6 text-center text-slate-500 text-sm">Sin datos de flota cargados.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- ZONAS DE DESCARGA -->
    <section id="sZonas" class="tab-content mt-8 w-full max-w-[1400px] mx-auto">
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-sky-400 tracking-tight">Zonas de Descarga</h2>
            <p class="text-xs text-slate-400">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Documentos compartidos/Zonas.csv</span></p>
        </div>
        
        <div class="glass p-8 rounded-xl mb-6 border border-slate-700 w-full text-sm shadow-md font-sans">
            <input type="hidden" id="z_index">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-5 items-end">
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">ID Zona</label>
                    <input type="text" id="z_id" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500 shadow-sm font-sans" placeholder="Ej: ZON-01">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Planta Asociada</label>
                    <select id="z_planta" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-sky-400 font-bold rounded outline-none transition-colors focus:border-sky-500 shadow-sm"></select>
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Nombre Zona</label>
                    <input type="text" id="z_nombre" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm" placeholder="Packaging Principal">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Estado</label>
                    <select id="z_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                        <option value="">- Estado -</option>
                        <option value="Activo">Activo</option>
                        <option value="Inactivo">Inactivo</option>
                    </select>
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Tipo Insumo</label>
                    <select id="z_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                        <option value="">- Tipo -</option>
                        <option value="Insumos">Insumos</option>
                        <option value="Packaging">Packaging</option>
                        <option value="No Productivo">No Productivo</option>
                        <option value="Materia Prima">Materia Prima</option>
                        <option value="Granel">Granel</option>
                    </select>
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1.5 text-[10px] tracking-wider">Capacidad (turnos/dia)</label>
                    <input type="number" id="z_capacidad" min="1" max="99" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500 shadow-sm">
                </div>
            </div>
            <div class="mt-6 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_zona" onclick="eliminarZona()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioZona()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionZona()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>

        <div class="glass flex-1 border border-slate-700/50 rounded-lg relative overflow-hidden flex flex-col shadow-sm">
            <div class="overflow-y-auto overflow-x-auto h-[480px] custom-scrollbar">
                <table class="w-full text-left text-sm text-slate-300 relative font-sans">
                    <thead class="bg-slate-900/90 backdrop-blur text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow z-10">
                        <tr><th class="py-3 px-4">ID Zona</th><th class="px-3">Planta</th><th class="px-3">Nombre Zona</th><th class="px-3">Tipo Insumo</th><th class="px-3 text-center">Capacidad</th><th class="px-3">Estado</th><th class="px-4 text-center">Accion</th></tr>
                    </thead>
                    <tbody id="tabla-zonas" class="divide-y divide-slate-700/50">
                        <tr><td colspan="7" class="p-8 text-center text-slate-500 text-sm">Sin zonas de descarga cargadas.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- CONFIG HORARIOS -->
    <section id="s8" class="tab-content mt-8 w-full max-w-[1400px] mx-auto">
        <h2 class="text-2xl font-bold mb-2 text-sky-400 tracking-tight">Configuracion de Horarios por Planta</h2>
        <p class="text-sm text-slate-400 mb-6">Ajuste las ventanas operativas y duracion de turnos de manera general.</p>
        <div id="csv-capacidad-status" class="csv-status warn"><div class="csv-title">Validacion CSV</div><div class="csv-detail">Pendiente de lectura del archivo.</div></div>
        <div class="glass p-6 rounded-xl text-base w-full shadow-sm">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300 font-sans">
                    <thead class="bg-slate-800 text-sm uppercase text-slate-400 font-bold border-b border-slate-700">
                        <tr><th class="py-4 px-4 cap-col-planta">Planta</th><th class="px-4">Tipo_Carga</th><th class="px-4 text-center">Habilitado</th><th class="px-4 text-center">Turnos_Cargados</th><th class="px-4 text-center">Turnos_Calc</th><th class="px-4 text-center">Turnos_Sabado</th><th class="px-4 text-center">Min_LV</th><th class="px-4 text-center">Min_SAB</th><th class="px-4 text-center">Minutos_Turno</th><th class="px-4 text-center">TotalDia</th><th class="px-4 text-center">Estatus</th></tr>
                    </thead>
                    <tbody id="tabla-config-horarios" class="divide-y divide-slate-700/50"></tbody>
                </table>
            </div>
            <div class="mt-6 flex justify-between items-center">
                <button onclick="guardarConfiguracionHorarios()" class="bg-emerald-600 hover:bg-emerald-500 px-6 py-3 font-bold rounded-lg shadow-sm transition text-white">Guardar y actualizar CSV</button>
                <button onclick="cargarCapacidadTurnosCSV(); renderizarABMHorarios(); showToast('Pantalla recargada desde CSV', 'ok');" class="bg-sky-700 hover:bg-sky-600 px-6 py-3 font-bold rounded-lg shadow-sm transition text-white">Refrescar desde CSV</button>
            </div>
        </div>
    </section>

    <!-- ETL -->
    <section id="s9" class="tab-content mt-8 w-full max-w-[1200px] mx-auto">
        <h2 class="text-2xl font-bold mb-4 text-sky-400 tracking-tight">Auditoria ETL</h2>

        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 shadow-sm">
            <div class="flex items-center justify-between mb-4 border-b border-slate-700 pb-3">
                <div>
                    <h3 class="text-base font-bold text-sky-300 uppercase tracking-wider">Estado de Sincronizaciones</h3>
                    <p class="text-xs text-slate-400 mt-1">Lectura y escritura contra las listas y documentos de SharePoint.</p>
                </div>
                <button onclick="sincronizarTodo()" class="bg-sky-700 hover:bg-sky-600 text-white px-5 py-2.5 text-sm font-bold rounded-lg shadow-sm transition">
                    Sincronizar Todo
                </button>
            </div>
            <div class="grid grid-cols-2 gap-4">
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Padron de Proveedores</div>
                        <div class="text-xs text-slate-400">Documentos/proveedores.csv</div>
                        <div id="sync-status-prov" class="text-xs mt-1.5 font-semibold text-slate-500">Sin sincronizar en esta sesion</div>
                    </div>
                    <button onclick="sincronizarCSVConFeedback('prov')" class="bg-slate-700 hover:bg-slate-600 text-sky-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">
                        Subir CSV
                    </button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Base de Usuarios</div>
                        <div class="text-xs text-slate-400">Documentos/Usuarios.csv</div>
                        <div id="sync-status-usu" class="text-xs mt-1.5 font-semibold text-slate-500">Sin sincronizar en esta sesion</div>
                    </div>
                    <button onclick="sincronizarCSVConFeedback('usu')" class="bg-slate-700 hover:bg-slate-600 text-sky-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">
                        Subir CSV
                    </button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Flota de Vehiculos</div>
                        <div class="text-xs text-slate-400">Documentos/Flota.csv</div>
                        <div id="sync-status-flota" class="text-xs mt-1.5 font-semibold text-slate-500">Sin leer en esta sesion</div>
                    </div>
                    <button onclick="sincronizarFlotaConFeedback()" class="bg-slate-700 hover:bg-slate-600 text-emerald-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">
                        Leer CSV
                    </button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Zonas de Descarga</div>
                        <div class="text-xs text-slate-400">Documentos/Zonas.csv</div>
                        <div id="sync-status-zonas" class="text-xs mt-1.5 font-semibold text-slate-500">Sin leer en esta sesion</div>
                    </div>
                    <button onclick="sincronizarZonasConFeedback()" class="bg-slate-700 hover:bg-slate-600 text-emerald-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">
                        Leer CSV
                    </button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between col-span-2">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Lista de Turnos Proveedores</div>
                        <div class="text-xs text-slate-400">Lists/Turnos Proveedores</div>
                        <div id="sync-status-turnos" class="text-xs mt-1.5 font-semibold text-slate-500">Sin leer en esta sesion</div>
                    </div>
                    <button onclick="sincronizarTurnosConFeedback()" class="bg-slate-700 hover:bg-slate-600 text-amber-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">
                        Refrescar Turnos
                    </button>
                </div>
            </div>
        </div>

        <div class="w-full grid grid-cols-2 gap-8">
            <div class="glass p-8 rounded-xl shadow-sm">
                <h3 class="text-base font-bold text-slate-300 uppercase mb-6 border-b border-slate-700 pb-3">Flujo de Automatizacion del Core</h3>
                <div class="flex flex-col gap-6 relative">
                    <div class="absolute left-8 top-8 bottom-8 w-0.5 bg-slate-700 z-0"></div>
                    <div id="etl-extract" class="etl-step flex items-center gap-5 z-10 bg-slate-900 p-4 rounded border border-slate-700"><div class="w-10 h-10 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-sm" id="etl-ic1">1</div><div><div class="font-bold text-sky-400 text-base">Extraccion (E)</div><div class="text-sm text-slate-400">Lectura OData API REST y Repositorios.</div></div></div>
                    <div id="etl-transform" class="etl-step flex items-center gap-5 z-10 bg-slate-900 p-4 rounded border border-slate-700"><div class="w-10 h-10 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-sm" id="etl-ic2">2</div><div><div class="font-bold text-amber-400 text-base">Transformacion (T)</div><div class="text-sm text-slate-400">Mapeo OData y validacion defensiva.</div></div></div>
                    <div id="etl-load" class="etl-step flex items-center gap-5 z-10 bg-slate-900 p-4 rounded border border-slate-700"><div class="w-10 h-10 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-sm" id="etl-ic3">3</div><div><div class="font-bold text-emerald-400 text-base">Carga (L)</div><div class="text-sm text-slate-400">POST/MERGE a Base de Datos.</div></div></div>
                </div>
            </div>
            <div class="glass p-8 rounded-xl flex flex-col h-[600px] shadow-sm">
                <h3 class="text-base font-bold text-slate-300 uppercase mb-4 border-b border-slate-700 pb-3">Registro Maestro de Auditoria (Logs)</h3>
                <div class="flex-1 bg-black/80 rounded-lg border border-slate-700 p-5 font-mono text-xs overflow-y-auto custom-scrollbar" id="etl-log-console" style="color:#4ade80"><div>> Inicializando motor ETL Audit v10.0...</div></div>
            </div>
        </div>
    </section>

    <!-- DASHBOARD -->
    <section id="s10" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-4 text-sky-400 tracking-tight">Dashboard e Indicadores</h2>

        <div class="glass p-5 rounded-xl mb-6 border border-slate-700 shadow-sm">
            <div class="flex justify-between items-center mb-3 border-b border-slate-700 pb-2">
                <h3 class="text-sm font-bold text-emerald-400 uppercase tracking-wider">Resumen Operacion Diaria</h3>
                <span id="resumen-fecha-label" class="text-xs text-slate-400">Calculando...</span>
            </div>
            <div id="resumen-contadores-vertical" class="grid grid-cols-5 gap-3 font-sans"></div>
        </div>
        
        <div class="glass p-4 rounded-xl mb-6 flex gap-4 items-end border border-slate-700 text-sm shadow-sm flex-wrap">
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px] tracking-wider">Fecha</label>
                <input type="date" id="dash_fecha" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500 transition-colors font-sans">
            </div>
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px] tracking-wider">Planta</label>
                <select id="dash_planta" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500 transition-colors font-sans">
                    <option value="TODAS">-- Todas --</option>
                </select>
            </div>
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px] tracking-wider">Horario</label>
                <select id="dash_horario" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500 transition-colors font-sans">
                    <option value="TODOS">-- Todos --</option>
                </select>
            </div>
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px] tracking-wider">Responsable</label>
                <select id="dash_resp" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500 transition-colors font-sans">
                    <option value="TODOS">-- Todos --</option>
                </select>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div class="glass p-4 rounded-xl shadow-sm">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Estados Globales</h3>
                <canvas id="chartEstados"></canvas>
            </div>
            <div class="glass p-4 rounded-xl shadow-sm">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Ranking de Proveedores</h3>
                <canvas id="chartProveedores"></canvas>
            </div>
            <div class="glass p-4 rounded-xl shadow-sm">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Turnos por Planta</h3>
                <canvas id="chartPlantas"></canvas>
            </div>
            <div class="glass p-4 rounded-xl shadow-sm">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Curva de Horarios</h3>
                <canvas id="chartHorarios"></canvas>
            </div>
        </div>

        <div class="glass p-5 rounded-xl flex flex-col w-full shadow-lg">
            <div class="flex justify-between items-center mb-3 border-b border-slate-700 pb-2">
                <h3 class="text-sm font-bold text-emerald-400 uppercase tracking-wider">Resumen de Operacion (Totalizado)</h3>
            </div>
            <div class="overflow-x-auto w-full">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-900/50 text-xs uppercase text-slate-400 font-bold">
                        <tr>
                            <th class="py-2 px-3">Planta Fisica</th>
                            <th class="px-3 text-center">T. Asignados</th>
                            <th class="px-3 text-center text-amber-400">Pendientes</th>
                            <th class="px-3 text-center text-emerald-400">Aprobados</th>
                            <th class="px-3 text-center text-sky-400">Reprogramados</th>
                            <th class="px-3 text-center text-rose-400">Cancelados</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-resumen-dashboard" class="divide-y divide-slate-700/50 font-sans">
                    </tbody>
                </table>
            </div>
        </div>
    </section>

</main>
<div id="toast"></div>

<script>
    // =========================================================================
    // ZONA DE CONEXION A SHAREPOINT
    // =========================================================================
    const relativeSiteUrl = "/sites/GestiondeTurnos";
    const CAPACIDAD_CSV_SERVER_RELATIVE_URL = "/sites/GestiondeTurnos/Documentos compartidos/capacidad_turnos_por_planta.csv";
    const NOMBRES_LISTA_POSIBLES = ['Turnos Proveedores', 'Turnos Proveedores_1'];
    let targetListName = NOMBRES_LISTA_POSIBLES[0];

    async function resolverNombreListaTurnos() {
        for (const nombre of NOMBRES_LISTA_POSIBLES) {
            try {
                const url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${nombre}')/items?$top=0`;
                const res = await fetch(url, { headers: { "Accept": "application/json;odata=nometadata" } });
                if (res.ok) { targetListName = nombre; logLog(`[ETL] Lista de Turnos resuelta: "${nombre}"`); return; }
            } catch (e) { }
        }
        logLog(`[WARN] No se pudo confirmar el nombre de la lista al arrancar.`);
    }

    async function fetchSharePoint(query, options = {}) {
        if (!options.headers) options.headers = { "Accept": "application/json;odata=nometadata" };
        let url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/${query}`;
        let res = await fetch(url, options);
        if (res.status === 404) {
            const otroNombre = NOMBRES_LISTA_POSIBLES.find(n => n !== targetListName);
            if (otroNombre) {
                const urlAlt = `${relativeSiteUrl}/_api/web/lists/getbytitle('${otroNombre}')/${query}`;
                res = await fetch(urlAlt, options);
            }
        }
        return res;
    }

    async function getDigest() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/contextinfo`, { method: 'POST', headers: { "Accept": "application/json;odata=verbose" } });
            if (!res.ok) throw new Error();
            const data = await res.json();
            return data.d.GetContextWebInformation.FormDigestValue;
        } catch (e) { return "TOKEN_MOCK"; }
    }

    async function sincronizarListFormSilencioso() {
        try { fetch("https://grupocanuelas.sharepoint.com/:l:/r/sites/GestiondeTurnos/Lists/Turnos%20Proveedores_1?e=z4KwLY", { mode: 'no-cors' }); } catch(e) {}
    }

    function ordenarEstructuralmenteBase(turnos) {
        const prioridadEst = { 'pendiente': 1, 'aprobado': 2, 'reprogramado': 3, 'cancelado': 4, 'rechazado': 4 };
        return turnos.sort((a, b) => {
            let plantaA = (a.PlantaDescarga || '').toLowerCase(); let plantaB = (b.PlantaDescarga || '').toLowerCase();
            if (plantaA < plantaB) return -1; if (plantaA > plantaB) return 1;
            let fechaA = a.field_6 || ''; let fechaB = b.field_6 || '';
            if (fechaA < fechaB) return -1; if (fechaA > fechaB) return 1;
            let estA = String(a.field_7 || 'pendiente').toLowerCase().trim(); let estB = String(b.field_7 || 'pendiente').toLowerCase().trim();
            let pA = prioridadEst[estA] || 99; let pB = prioridadEst[estB] || 99;
            if (pA < pB) return -1; if (pA > pB) return 1;
            return 0;
        });
    }

    async function ejecutarTransaccion(itemId, payload, msg, skipRefresh = false) {
        logETLStep(3, false);
        try {
            const digest = await getDigest();
            const query = itemId ? `items(${itemId})` : `items`;
            const options = { method: 'POST', headers: { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest }, body: JSON.stringify(payload) };
            if(itemId) { options.headers["X-HTTP-Method"] = "MERGE"; options.headers["If-Match"] = "*"; }

            let res = await fetchSharePoint(query, options);
            if (res.status === 400) {
                delete payload.Patente; delete payload.HoraIngresoReal; delete payload.HoraSalidaReal; delete payload.EsSobreturno;
                options.body = JSON.stringify(payload);
                res = await fetchSharePoint(query, options);
            }
            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error("Falla API " + res.status);
            
            logETLStep(3, true); showToast(msg, "ok"); generarLogArchivoSP("Transaccion_Turno", msg); sincronizarListFormSilencioso();
            if(!skipRefresh) await cargarTurnos(); generarResumenDiario(); 
        } catch(e) {
            logLog(`[ERROR ESCRITURA SP]: ${e.message}`); showToast("Simulacion Local", "err");
            if(itemId) { let obj = listaTurnosCache.find(x=>x.Id==itemId); if(obj) Object.assign(obj, payload); }
            else listaTurnosCache.unshift({...payload, Id: Math.floor(Math.random()*1000)});
            ordenarEstructuralmenteBase(listaTurnosCache); aplicarFiltrosMonitor(); calcularDisponibilidadOffline(); generarResumenDiario(); renderizarResumenCapacidad();
        }
    }

    // =========================================================================
    // MODULO ETL Y CSV
    // =========================================================================
    function setETLStatus(id, texto, tipo) {
        const el = document.getElementById(id); if(!el) return; el.textContent = texto;
        el.className = `text-xs mt-1.5 font-semibold ${ tipo === 'ok' ? 'text-emerald-400' : tipo === 'err' ? 'text-rose-400' : tipo === 'busy' ? 'text-sky-400 animate-pulse' : 'text-slate-500' }`;
    }

    async function sincronizarCSVConFeedback(tipo) {
        let statusId, label, cache;
        if (tipo === 'prov') { statusId = 'sync-status-prov'; label = 'Proveedores'; cache = listaProveedoresCache; }
        else if (tipo === 'usu') { statusId = 'sync-status-usu'; label = 'Usuarios'; cache = listaUsuariosCache; }
        
        if (cache.length === 0) { setETLStatus(statusId, 'Sin registros en memoria para sincronizar.', 'err'); showToast(`Base de ${label} vacia.`, 'err'); return; }
        setETLStatus(statusId, `Subiendo ${cache.length} registros...`, 'busy');
        try {
            await actualizarCSVSharePoint(tipo);
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus(statusId, `OK -- ${cache.length} registros sincronizados a las ${ahora}`, 'ok'); logLog(`[ETL CSV] ${label}.csv subido exitosamente.`);
        } catch(e) { setETLStatus(statusId, `Error: ${e.message}`, 'err'); logLog(`[ERROR CSV SP]: ${e.message}`); }
    }

    async function sincronizarFlotaConFeedback() {
        setETLStatus('sync-status-flota', 'Leyendo Flota.csv desde SharePoint...', 'busy');
        try {
            await cargarFlotaSP(); const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-flota', `OK -- ${listaFlotaCache.length} vehiculos desde Flota.csv a las ${ahora}`, 'ok');
        } catch(e) { setETLStatus('sync-status-flota', `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarZonasConFeedback() {
        setETLStatus('sync-status-zonas', 'Leyendo Zonas.csv desde SharePoint...', 'busy');
        try {
            await cargarZonasSP(); const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-zonas', `OK -- ${listaZonasCache.length} zonas desde Zonas.csv a las ${ahora}`, 'ok');
        } catch(e) { setETLStatus('sync-status-zonas', `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarTurnosConFeedback() {
        setETLStatus('sync-status-turnos', 'Consultando SharePoint...', 'busy');
        try {
            await cargarTurnos(); const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-turnos', `OK -- ${listaTurnosCache.length} turnos a las ${ahora}`, 'ok');
        } catch(e) { setETLStatus('sync-status-turnos', `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarTodo() {
        showToast('Iniciando sincronizacion completa...', 'ok');
        await sincronizarCSVConFeedback('prov'); await sincronizarCSVConFeedback('usu'); await sincronizarFlotaConFeedback(); await sincronizarZonasConFeedback(); await sincronizarTurnosConFeedback();
        showToast('Sincronizacion completa finalizada.', 'ok');
    }

    async function actualizarCSVSharePoint(tipo) {
        logETLStep(3, false);
        try {
            const digest = await getDigest();
            let fileName = tipo === 'prov' ? 'proveedores.csv' : (tipo === 'usu' ? 'Usuarios.csv' : (tipo === 'flota' ? 'Flota.csv' : 'Zonas.csv'));
            let folderName = 'Documentos compartidos';

            let csvContent = "\uFEFF"; 
            if (tipo === 'usu') {
                csvContent += "ID;Nombre y apellido;Email;Planta;Estado\n";
                listaUsuariosCache.forEach(u => { csvContent += `${u.id||''};${u.nombre||''};${u.email||''};${u.planta||''};${u.estado||''}\n`; });
            } else if (tipo === 'flota') {
                if (flotaSchemaLine) csvContent += flotaSchemaLine.replace(/^\uFEFF/, '') + "\n";
                const headerCols = flotaHeaderCols.length ? flotaHeaderCols : ['Código del Vehículo','Descripción','Nombre','Apellido','Correo','Celular','Capacidad 1','Capacidad 2','Capacidad 3','Detalle','Tipo Dispositivo','Número Dispositivo','Etiqueta Costos','Flotas','Empleador','Tipo Vehículo','DNI','Última latitud','Última longitud'];
                const escapeCsv = (v) => `"${String(v ?? '').replace(/"/g, '""')}"`;
                csvContent += headerCols.map(escapeCsv).join(',') + "\n";
                listaFlotaCache.forEach(v => {
                    const row = Array.isArray(v.raw) ? [...v.raw] : Array(headerCols.length).fill('');
                    while (row.length < headerCols.length) row.push('');
                    const partes = splitChofer(v.chofer || '');
                    row[0]  = (v.patente || '').trim(); row[2]  = partes.nombre || row[2] || ''; row[3]  = partes.apellido || row[3] || ''; row[14] = v.empresa || row[14] || ''; row[15] = v.tipo || row[15] || '';
                    csvContent += row.map(escapeCsv).join(',') + "\n";
                });
            } else if (tipo === 'zonas') {
                csvContent += "ID Zona;Planta Asociada;Nombre Zona;Tipo Insumo;Capacidad;Estado\n";
                listaZonasCache.forEach(z => { csvContent += `${z.id||''};${z.planta||''};${z.nombre||''};${z.tipo||''};${z.capacidad||''};${z.estado||''}\n`; });
            } else {
                csvContent += "Usuario;Responsable;Mail Responsable;Tipo Insumo;Num_Proveedor;Nombre proveedor;Estado;Cuit\n";
                listaProveedoresCache.forEach(p => { csvContent += `${p.usuario||''};${p.responsable||''};${p.mail||''};${p.tipo||''};${p.id||''};${p.nombre||''};${p.estado||''};${p.cuit || ''}\n`; });
            }

            let url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folderName}')/Files/add(url='${fileName}',overwrite=true)`;
            let res = await fetch(url, { method: 'POST', headers: { "X-RequestDigest": digest }, body: csvContent });
            if (!res.ok) {
                folderName = 'Shared Documents'; url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folderName}')/Files/add(url='${fileName}',overwrite=true)`;
                res = await fetch(url, { method: 'POST', headers: { "X-RequestDigest": digest }, body: csvContent });
            }
            if (!res.ok) throw new Error("Falla sobrescritura " + res.status);
            logETLStep(3, true);
        } catch (err) { logLog(`[ERROR ETL CSV]: ${err.message}`); throw err; }
    }

    // =========================================================================
    // ENRUTADOR
    // =========================================================================
    function setupRuteo() {
        try {
            const btns = document.querySelectorAll('.tab-btn[data-target]');
            const contents = document.querySelectorAll('.tab-content');

            const seccionCallbacks = {
                's6':     () => { limpiarFormularioProveedor(); renderizarBaseProveedores(); },
                's7':     () => { limpiarFormularioUsuario(); renderizarBaseUsuarios(); },
                'sFlota': () => { limpiarFormularioFlota(); renderizarBaseFlota(); },
                'sZonas': () => { limpiarFormularioZona(); renderizarBaseZonas(); },
                's8':     () => renderizarABMHorarios(),
                's10':    () => initDashboard(),
            };

            btns.forEach(btn => {
                btn.addEventListener('click', () => {
                    const target = btn.dataset.target;
                    btns.forEach(b => b.classList.remove('active-tab')); btn.classList.add('active-tab');
                    contents.forEach(c => { c.classList.remove('active'); c.style.display = 'none'; });
                    const targetEl = document.getElementById(target);
                    if(targetEl) { targetEl.classList.add('active'); targetEl.style.display = 'block'; }
                    if(seccionCallbacks[target]) { try { seccionCallbacks[target](); } catch(e) {} }
                });
            });
        } catch(e) {}
    }
    setupRuteo();

    let listaTurnosCache = []; let listaUsuariosCache = []; let listaProveedoresCache = []; let listaFlotaCache = []; let listaFlotaRawRows = []; let flotaSchemaLine = ''; let flotaHeaderCols = [];
    let listaZonasCache = []; let capacidadPorPlantaTipoCache = []; let capacidadPorPlantaIndex = {};
    let fechaSeleccionadaGlobal = ""; let currentLoggedUser = { name: "Local", email: "logistica@grupocanuelas.com" }; let _modalProvAbierto = false; 
    
    const ORDEN_TIPOS = ['INSUMOS', 'PACKAGING', 'NO_PRODUCTIVO']; const TIPOS_ZONA_CALCULO = ['INSUMOS', 'PACKAGING', 'NO_PRODUCTIVO'];

    function terminalLog(msg) {
        const d = document.getElementById('splash-log'); 
        if(d) { d.insertAdjacentHTML('beforeend', `<div><span class="text-slate-500">[${new Date().toLocaleTimeString()}]</span> ${msg}</div>`); d.scrollTop = d.scrollHeight; } 
    }

    // --- ARRANQUE Y AUTO-SINCRONIZACION ---
    async function initApp() {
        try {
            terminalLog("=====================================");
            terminalLog("Inicializando Core ERP Logistico...");
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.getFullYear() + "-" + String(hoy.getMonth() + 1).padStart(2, '0') + "-" + String(hoy.getDate()).padStart(2, '0');
            
            cargarSelectPlantasFisicas(); renderizarABMHorarios(); renderizarGrilaCalendario();
            await cargarCapacidadTurnosCSV();
            
            terminalLog("Obteniendo credenciales de usuario...");
            await testConexion();
            terminalLog(`Usuario conectado: ${currentLoggedUser.name} [OK]`);

            await resolverNombreListaTurnos();
            limpiarFormularioProveedor();
            
            terminalLog("Disparando hilos asincronos de Sincronizacion de Maestros...");
            
            await Promise.all([
                importarCSVSharePoint('prov', true).then(() => terminalLog("Cargando Proveedores.csv [OK]")),
                importarCSVSharePoint('usu', true).then(() => terminalLog("Cargando Usuarios.csv [OK]")),
                importarCSVSharePoint('flota', true).then(() => terminalLog("Cargando Flota.csv [OK]")),
                importarCSVSharePoint('zonas', true).then(() => terminalLog("Cargando Zonas.csv [OK]"))
            ]);

            poblarSelectsABMInicial();
            terminalLog("Maestros sincronizados. Disparando carga de Turnos...");
            await cargarTurnos();
            terminalLog("Inicializacion completada exitosamente.");
            
            setTimeout(() => { document.getElementById('splash-screen').classList.add('hidden-splash'); }, 1500);

        } catch (err) { terminalLog(`<span class="text-rose-400 font-bold">[FALLA CRITICA INIT]: ${err.message}</span>`); }
    }

    function normalizarTipoCarga(valor) {
        const v = String(valor || '').trim().toUpperCase(); if (!v) return '';
        if (v === 'NO PRODUCTIVO' || v === 'NO-PRODUCTIVO') return 'NO_PRODUCTIVO';
        return v.replace(/\s+/g, '_');
    }
    function normalizarTipoZona(valor) { return normalizarTipoCarga(valor); }
    function parseCsvFlexible(text) {
        const limpio = String(text || '').replace(/^\uFEFF/, '').replace(/^﻿/, '');
        const lines = limpio.split(/\r?\n|\r/).filter(l => l.trim() !== ''); if (!lines.length) return [];
        const firstLine = lines[0]; const sep = firstLine.includes(';') ? ';' : ',';
        const normalizeHeader = h => String(h || '').replace(/^\uFEFF/, '').replace(/^﻿/, '').replace(/^"+|"+$/g, '').trim();
        const headers = firstLine.split(sep).map(normalizeHeader);
        return lines.slice(1).map(line => {
            const cols = line.split(sep).map(v => String(v || '').replace(/^"+|"+$/g, '').trim());
            const row = {}; headers.forEach((h, i) => row[h] = cols[i] || ''); return row;
        });
    }
    function normalizeHeaderName(v) { return String(v || '').replace(/^\uFEFF/, '').replace(/^﻿/, '').replace(/^"+|"+$/g, '').trim().toUpperCase(); }
    function toNum(v, dec = 2) { const n = Number(String(v ?? '').replace(',', '.')); if (!Number.isFinite(n)) return 0; return Number(n.toFixed(dec)); }
    function fmtNum(v, dec = 0) { const n = Number(v); if (!Number.isFinite(n)) return '-'; return dec === 0 ? String(Math.floor(n)) : String(Number(n.toFixed(dec))); }

    function actualizarEstadoCSVVisual(tipo, titulo, detalle) {
        const box = document.getElementById('csv-capacidad-status'); if (!box) return; box.className = `csv-status ${tipo}`; box.innerHTML = `<div class="csv-title">${escapeHtml(titulo)}</div><div class="csv-detail">${escapeHtml(detalle)}</div>`;
    }

    function construirIndiceCapacidad() {
        const idx = {};
        capacidadPorPlantaTipoCache.forEach(r => {
            const planta = String(r.Planta || '').trim(); const tipo = normalizarTipoCarga(r.Tipo_Carga);
            if (!planta || !tipo) return;
            if (!idx[planta]) idx[planta] = { tipos: {}, resumen: null, filas: [] };
            idx[planta].tipos[tipo] = r; idx[planta].filas.push(r);
            if (!idx[planta].resumen) idx[planta].resumen = { Planta: planta };
        });
        Object.values(idx).forEach(g => recomputarResumenGrupo(g)); capacidadPorPlantaIndex = idx;
    }

    function recomputarResumenGrupo(g) {
        const filas = (g?.filas || []); if (!filas.length) return; const base = filas[0];
        g.resumen = {
            Planta: base.Planta, Turnos_Calc: filas.length ? Math.max(...filas.map(r => toNum(r.Turnos_Calc, 2))) : 0, Turnos_Sabado: filas.length ? Math.max(...filas.map(r => toNum(r.Turnos_Sabado, 2))) : 0, Min_LV: filas.length ? Math.max(...filas.map(r => toNum(r.Min_LV, 2))) : 0, Min_SAB: filas.length ? Math.max(...filas.map(r => toNum(r.Min_SAB, 2))) : 0, Minutos_Turno: filas.length ? Math.max(...filas.map(r => toNum(r.Minutos_Turno, 2))) : 0, TotalDia: filas.length ? Math.max(...filas.map(r => toNum(r.TotalDia, 2))) : 0, Estatus: base.Estatus || 'OK'
        };
    }

    function refreshCapacidadFromCache(preserveExpanded = true) {
        construirIndiceCapacidad(); convertirConfigDesdeCSV(); cargarSelectPlantasFisicas(); renderizarABMHorarios(preserveExpanded); renderizarResumenCapacidad(); calcularDisponibilidadOffline(); generarResumenDiario();
        if (document.getElementById('s10')?.classList.contains('active')) updateDashboard();
    }

    function convertirConfigDesdeCSV() {
        if (!capacidadPorPlantaTipoCache.length) return;
        const baseMap = new Map((configPlantas || []).map(p => [p.id, { ...p }]));
        Object.values(capacidadPorPlantaIndex).forEach(g => {
            const r = g.resumen || {}; const planta = String(r.Planta || '').trim(); if (!planta) return;
            const base = baseMap.get(planta) || { id: planta, hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false };
            const minS = toNum(r.Min_SAB, 2); const minutosTurno = toNum(r.Minutos_Turno, 2) || base.duracion || 1;
            baseMap.set(planta, { id: planta, hInLV: base.hInLV, hOutLV: base.hOutLV, hInS: base.hInS, hOutS: base.hOutS, duracion: minutosTurno, sabado: minS > 0, totalDiaLV: toNum(r.TotalDia, 2), totalSabado: toNum(r.Turnos_Sabado, 2) });
        });
        configPlantas = Array.from(baseMap.values());
    }

    function collectCapacidadRowsFromDom() {
        const rows = Array.from(document.querySelectorAll('tr.cap-child-row'));
        if (!rows.length) return capacidadPorPlantaTipoCache;
        return rows.map(tr => ({
            Planta: tr.dataset.planta || '', Tipo_Carga: tr.dataset.tipo || '', Habilitado: Number(tr.querySelector('[data-field="Habilitado"]')?.value || 0), Turnos_Cargados: toNum(tr.querySelector('[data-field="Turnos_Cargados"]')?.value, 2), Turnos_Calc: toNum(tr.querySelector('[data-field="Turnos_Calc"]')?.value, 2), Turnos_Sabado: toNum(tr.querySelector('[data-field="Turnos_Sabado"]')?.value, 2), Min_LV: toNum(tr.querySelector('[data-field="Min_LV"]')?.value, 2), Min_SAB: toNum(tr.querySelector('[data-field="Min_SAB"]')?.value, 2), Minutos_Turno: toNum(tr.querySelector('[data-field="Minutos_Turno"]')?.value, 2), TotalDia: toNum(tr.querySelector('[data-field="TotalDia"]')?.value, 2), Estatus: String(tr.querySelector('[data-field="Estatus"]')?.value || 'OK').trim()
        }));
    }

    function serializeCapacidadCsv(rows) {
        const bom = '\uFEFF'; const headers = ['Planta','Tipo_Carga','Habilitado','Turnos_Cargados','Turnos_Calc','Turnos_Sabado','Min_LV','Min_SAB','Minutos_Turno','TotalDia','Estatus'];
        let csv = bom + headers.join(';') + '\n'; rows.forEach(r => { csv += [r.Planta,r.Tipo_Carga,r.Habilitado,r.Turnos_Cargados,r.Turnos_Calc,r.Turnos_Sabado,r.Min_LV,r.Min_SAB,r.Minutos_Turno,r.TotalDia,r.Estatus].join(';') + '\n'; });
        return csv;
    }

    async function guardarCapacidadCSVSharePoint(rows) {
        const digest = await getDigest(); const csvContent = serializeCapacidadCsv(rows);
        let folder = 'Documentos compartidos'; let url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folder}')/Files/add(url='capacidad_turnos_por_planta.csv',overwrite=true)`;
        let res = await fetch(url, { method: 'POST', headers: { 'X-RequestDigest': digest }, body: csvContent });
        if (!res.ok) { folder = 'Shared Documents'; url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folder}')/Files/add(url='capacidad_turnos_por_planta.csv',overwrite=true)`; res = await fetch(url, { method: 'POST', headers: { 'X-RequestDigest': digest }, body: csvContent }); }
        if (!res.ok) throw new Error(`No se pudo escribir capacidad_turnos_por_planta.csv. HTTP ${res.status}`); return true;
    }

    async function cargarCapacidadTurnosCSV() {
        try {
            actualizarEstadoCSVVisual('warn', 'Validación CSV', 'Leyendo capacidad_turnos_por_planta.csv...');
            const urlPrimaria = `${relativeSiteUrl}/_api/web/GetFileByServerRelativeUrl('${CAPACIDAD_CSV_SERVER_RELATIVE_URL}')/$value`;
            let res = await fetch(urlPrimaria, { headers: { 'Accept': 'text/plain' } }); let rutaUsada = CAPACIDAD_CSV_SERVER_RELATIVE_URL;
            if (!res.ok) { const alt = CAPACIDAD_CSV_SERVER_RELATIVE_URL.replace('/Documentos compartidos/', '/Shared Documents/'); const altUrl = `${relativeSiteUrl}/_api/web/GetFileByServerRelativeUrl('${alt}')/$value`; res = await fetch(altUrl, { headers: { 'Accept': 'text/plain' } }); rutaUsada = alt; }
            if (!res.ok) throw new Error(`Archivo no encontrado o no accesible. HTTP ${res.status}`);
            const raw = await res.text(); const trimmed = raw.trim();
            if (trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html')) throw new Error('La URL devolvió HTML en lugar del contenido del CSV');
            const rows = parseCsvFlexible(raw);
            if (!rows.length) { actualizarEstadoCSVVisual('warn', 'CSV vacío', 'El archivo fue leído pero no contiene filas útiles o está vacío.'); capacidadPorPlantaTipoCache = []; capacidadPorPlantaIndex = {}; renderizarABMHorarios(); return []; }
            const headersRaw = Object.keys(rows[0] || {}); const headers = headersRaw.map(normalizeHeaderName);
            const required = ['PLANTA','TIPO_CARGA']; const faltantes = required.filter(c => !headers.includes(c));
            if (faltantes.length) throw new Error(`Faltan columnas obligatorias en CSV: ${faltantes.join(', ')}`);
            const parsed = rows.map(r => {
                const planta = r.Planta ?? r.PLANTA ?? ''; const tipo = r.Tipo_Carga ?? r.TIPO_CARGA ?? '';
                return { Planta: String(planta || '').trim(), Tipo_Carga: normalizarTipoCarga(tipo), Habilitado: toNum(r.Habilitado, 0), Turnos_Cargados: toNum(r.Turnos_Cargados, 2), Turnos_Calc: toNum(r.Turnos_Calc, 2), Turnos_Sabado: toNum(r.Turnos_Sabado, 2), Min_LV: toNum(r.Min_LV, 2), Min_SAB: toNum(r.Min_SAB, 2), Minutos_Turno: toNum(r.Minutos_Turno, 2), TotalDia: toNum(r.TotalDia, 2), Estatus: String(r.Estatus || 'OK').trim() };
            }).filter(r => r.Planta && r.Tipo_Carga);
            capacidadPorPlantaTipoCache = parsed; refreshCapacidadFromCache(false);
            actualizarEstadoCSVVisual('ok', 'CSV válido', `Ruta: ${rutaUsada} | Registros: ${parsed.length} | Columnas: ${headersRaw.join(', ')}`);
            terminalLog(`capacidad_turnos_por_planta.csv: ${parsed.length} registros cargados.`);
            return parsed;
        } catch (e) {
            const detalle = e && e.message ? e.message : 'Error no identificado al leer el CSV.'; terminalLog(`[ERROR CSV CAPACIDAD]: ${detalle}`); actualizarEstadoCSVVisual('err', 'CSV inválido o inaccesible', detalle); capacidadPorPlantaTipoCache = []; capacidadPorPlantaIndex = {}; renderizarABMHorarios(); return [];
        }
    }

    function toggleDetalleCapacidad(plantaKey) {
        const rows = Array.from(document.querySelectorAll('tr[data-parent-planta]')).filter(r => r.getAttribute('data-parent-planta') === plantaKey);
        const icon = Array.from(document.querySelectorAll('[data-expander-planta]')).find(el => el.getAttribute('data-expander-planta') === plantaKey);
        if (!rows.length) return;
        const expanded = rows.every(r => !r.classList.contains('hidden-row'));
        rows.forEach(r => r.classList.toggle('hidden-row', expanded));
        if (icon) { icon.textContent = expanded ? '+' : '−'; if (expanded) icon.classList.remove('open'); else icon.classList.add('open'); }
    }

    function resetSelectConGuion(selectEl, label) { if (!selectEl) return; const guion = label || '-'; selectEl.innerHTML = `<option value="">${guion}</option>`; }
    function asegurarOptionSelect(selectEl, valor, texto) { if (!selectEl || !valor) return; if (!Array.from(selectEl.options).some(o => o.value === valor)) { selectEl.add(new Option(texto || valor, valor)); } selectEl.value = valor; }

    function poblarSelectZonasPorPlanta(plantaFisica, valorSeleccionado) {
        const sel = document.getElementById('f_planta'); if (!sel) return; resetSelectConGuion(sel); if (!plantaFisica) return;
        const zonas = listaZonasCache.filter(z => z.estado !== 'Inactivo' && String(z.planta).toLowerCase() === String(plantaFisica).toLowerCase());
        if (zonas.length === 0) { TIPOS_ZONA_CALCULO.forEach(t => sel.add(new Option(t, t))); } else { zonas.forEach(z => { const label = z.nombre || z.tipo; const val = z.tipo || z.nombre; if (val && !Array.from(sel.options).some(o => o.value === val)) { sel.add(new Option(label, val)); } }); }
        if (valorSeleccionado) asegurarOptionSelect(sel, valorSeleccionado); else sel.selectedIndex = 0;
    }

    function onPlantaFisicaChange() { const pf = document.getElementById('f_planta_descarga')?.value || ''; poblarSelectZonasPorPlanta(pf, ''); handleHorariosChange(); }

    function calcularTurnosTeoricos(plantaConfig, esSabado) {
        if (!plantaConfig || !plantaConfig.duracion) return 0; if (esSabado && !plantaConfig.sabado) return 0;
        const hIn = esSabado ? plantaConfig.hInS : plantaConfig.hInLV; const hOut = esSabado ? plantaConfig.hOutS : plantaConfig.hOutLV;
        if (hOut <= hIn) return 0; return Math.floor(((hOut - hIn) * 60) / plantaConfig.duracion);
    }

    function contarZonasActivasPorTipo(plantaId, tipo) {
        const activas = listaZonasCache.filter(z => z.estado !== 'Inactivo' && String(z.planta).toLowerCase() === String(plantaId).toLowerCase() && String(z.tipo).toLowerCase() === String(tipo).toLowerCase());
        if (activas.length === 0) return 1; return activas.reduce((sum, z) => sum + (parseInt(z.capacidad, 10) > 0 ? parseInt(z.capacidad, 10) : 1), 0);
    }

    function calcularCapacidadPlantaPorTipo(plantaConfig, esSabado) {
        const idx = capacidadPorPlantaIndex[plantaConfig.id] || null; const resumen = idx?.resumen || null;
        const slots = resumen ? (esSabado ? toNum(resumen.Turnos_Sabado, 2) : toNum(resumen.TotalDia || resumen.Turnos_Calc, 2)) : calcularTurnosTeoricos(plantaConfig, esSabado);
        const res = {}; const total = slots;
        TIPOS_ZONA_CALCULO.forEach(tipo => {
            const reg = idx?.tipos?.[tipo]; let cap = 0;
            if (reg && reg.Habilitado === 1) cap = esSabado ? toNum(reg.Turnos_Sabado, 2) : toNum(reg.Turnos_Cargados || reg.TotalDia || reg.Turnos_Calc, 2);
            else if (!reg) cap = slots; res[tipo] = cap;
        });
        return { slots, porTipo: res, total };
    }

    function esSabadoFecha(fechaStr) { if (!fechaStr) return false; const d = new Date(fechaStr.replace(/-/g, '/') + ' 00:00:00'); return d.getDay() === 6; }

    function renderizarResumenCapacidad() {
        const panel = document.getElementById('panel-resumen-capacidad'); if (!panel) return;
        const pfFiltro = document.getElementById('filtro_planta_descarga')?.value || 'TODAS'; const esSab = esSabadoFecha(fechaSeleccionadaGlobal);
        let html = `<div class="text-[9px] uppercase text-slate-500 font-bold mb-1 text-center">Capacidad ${fechaSeleccionadaGlobal}${esSab ? ' (Sab)' : ' (LV)'}</div>`; let hayDatos = false;
        configPlantas.forEach(p => {
            if (pfFiltro !== 'TODAS' && p.id !== pfFiltro) return;
            const cap = calcularCapacidadPlantaPorTipo(p, esSab); if (cap.slots === 0) return; hayDatos = true;
            TIPOS_ZONA_CALCULO.forEach(tipo => {
                const teo = cap.porTipo[tipo] || 0; if (teo === 0) return;
                const ocup = listaTurnosCache.filter(t => t.field_6 && String(t.field_6).startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === p.id && normalizarTipoZona(t.Planta) === normalizarTipoCarga(tipo) && !['cancelado', 'rechazado'].includes(String(t.field_7 || '').toLowerCase())).length;
                const disp = Math.max(0, teo - ocup);
                html += `<div class="flex justify-between gap-1 py-0.5 border-b border-slate-800/50"><span class="text-sky-300 truncate">${escapeHtml(p.id)} / ${escapeHtml(tipo)}</span><span class="text-slate-400 shrink-0">${fmtNum(teo, 0)}|${ocup}|<span class="text-emerald-400 font-bold">${fmtNum(disp, 0)}</span></span></div>`;
            });
        });
        panel.innerHTML = hayDatos ? html : '<div class="text-center text-slate-500 text-[10px] py-2">Sin capacidad configurada.</div>';
    }

    function actualizarDatalistFlota() { const dl = document.getElementById('dl_flota_patentes'); if (!dl) return; dl.innerHTML = listaFlotaCache.filter(v => v.estado === 'Habilitado').map(v => `<option value="${escapeHtml(v.patente)}">`).join(''); }

    async function syncFlotaABM() { await cargarFlotaSP(); actualizarDatalistFlota(); showToast(`Flota sincronizada: ${listaFlotaCache.length} vehiculos.`, 'ok'); }

    function autocompletarPatenteFlota() {
        const pat = document.getElementById('f_patente')?.value.trim().toUpperCase(); if (!pat) return; document.getElementById('f_patente').value = pat;
        const v = listaFlotaCache.find(x => String(x.patente).toUpperCase() === pat);
        if (v && v.empresa && !document.getElementById('f_proveedor').value) { showToast(`Patente ${pat} encontrada en flota (${v.empresa}).`, 'ok'); }
    }

    let configPlantasData = [
        { id: "Parque Canuelas", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false },
        { id: "Predio Canuelas", hInLV: 10, hOutLV: 17, hInS: 7, hOutS: 11, duracion: 40, sabado: true },
        { id: "Spegazzini", hInLV: 8, hOutLV: 16, hInS: 8, hOutS: 12, duracion: 45, sabado: true },
        { id: "Almar", hInLV: 7, hOutLV: 14, hInS: 7, hOutS: 11, duracion: 30, sabado: true },
        { id: "Metro Mataderos", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false }
    ];

    function toggleMenuConfig() { const sub = document.getElementById('submenu-config'); const icon = document.getElementById('icon-menu-config'); const abierto = !sub.classList.contains('hidden'); sub.classList.toggle('hidden', abierto); icon.textContent = abierto ? '\u25B6' : '\u25BC'; icon.className = 'text-red-500 text-sm font-bold'; }
    function agregarNuevaPlanta() { const nombre = prompt('Nombre de la nueva Planta Fisica:'); if(!nombre || !nombre.trim()) return; if(configPlantas.find(p => p.id.toLowerCase() === nombre.trim().toLowerCase())) return showToast('Ya existe una planta con ese nombre.', 'err'); configPlantas.push({ id: nombre.trim(), hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false }); renderizarABMHorarios(); cargarSelectPlantasFisicas(); showToast(`Planta "${nombre.trim()}" agregada. Guarda la configuracion para aplicar.`, 'ok'); }

    function obtenerFechaISO(offsetDias = 0) { const d = new Date(); d.setDate(d.getDate() + offsetDias); return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, '0') + "-" + String(d.getDate()).padStart(2, '0'); }
    function aplicarVentanaFechaAlta() { const fFecha = document.getElementById('f_fecha'); if (!fFecha) return; fFecha.min = obtenerFechaISO(0); fFecha.max = obtenerFechaISO(1); }

    function parseCsvLineSeguro(linea) {
        const out = []; let cur = ''; let inQuotes = false;
        for (let i = 0; i < linea.length; i++) {
            const ch = linea[i];
            if (ch === '"') { if (inQuotes && linea[i + 1] === '"') { cur += '"'; i++; } else inQuotes = !inQuotes; } 
            else if (ch === ',' && !inQuotes) { out.push(cur); cur = ''; } 
            else { cur += ch; }
        }
        out.push(cur); return out.map(v => String(v || '').trim());
    }

    function mapearFilaFlota(cols) {
        const patente = String(cols[0] || '').trim().toUpperCase(); const descripcion = String(cols[1] || '').trim(); const nombre = String(cols[2] || '').trim(); const apellido = String(cols[3] || '').trim(); const correo = String(cols[4] || '').trim(); const celular = String(cols[5] || '').trim(); const capacidad1 = String(cols[6] || '').trim(); const capacidad2 = String(cols[7] || '').trim(); const capacidad3 = String(cols[8] || '').trim(); const detalle = String(cols[9] || '').trim(); const tipoDispositivo = String(cols[10] || '').trim(); const numeroDispositivo = String(cols[11] || '').trim(); const etiquetaCostos = String(cols[12] || '').trim(); const flotas = String(cols[13] || '').trim(); const empresa = String(cols[14] || '').trim(); const tipo = String(cols[15] || '').trim(); const dni = String(cols[16] || '').trim(); const ultimaLatitud = String(cols[17] || '').trim(); const ultimaLongitud = String(cols[18] || '').trim();
        const chofer = [apellido, nombre].filter(Boolean).join(' ').trim();
        return {
            spId: null, patente, tipo, empresa, cuit: '', chofer, estado: patente ? 'Habilitado' : 'Deshabilitado', descripcion, nombre, apellido, correo, celular, capacidad1, capacidad2, capacidad3, detalle, tipoDispositivo, numeroDispositivo, etiquetaCostos, flotas, dni, ultimaLatitud, ultimaLongitud, raw: cols
        };
    }

    function parsearCSVFlota(text) {
        const lines = text.split(/\r?\n|\r/).filter(l => l !== ''); flotaSchemaLine = ''; flotaHeaderCols = []; listaFlotaRawRows = [];
        if (!lines.length) { listaFlotaCache = []; renderizarBaseFlota(); actualizarDatalistFlota(); return; }
        let idxHeader = 0;
        if (String(lines[0] || '').startsWith('ListSchema=')) { flotaSchemaLine = lines[0].replace(/^\uFEFF/, ''); idxHeader = 1; }
        const headerLine = (lines[idxHeader] || '').replace(/^\uFEFF/, ''); flotaHeaderCols = parseCsvLineSeguro(headerLine);
        const rows = [];
        for (let i = idxHeader + 1; i < lines.length; i++) {
            const cols = parseCsvLineSeguro(lines[i]); if (!cols.length) continue;
            const item = mapearFilaFlota(cols); if (!item.patente) continue; rows.push(item);
        }
        listaFlotaCache = rows; listaFlotaRawRows = rows.map(r => r.raw);
        renderizarBaseFlota(); actualizarDatalistFlota(); 
    }

    async function cargarFlotaSP() {
        try { await importarCSVSharePoint('flota', true); } 
        catch(e) { terminalLog(`[WARN] Flota CSV no disponible: ${e.message}. Usando cache local.`); renderizarBaseFlota(); }
    }

    function splitChofer(choferStr) {
        const s = String(choferStr || '').trim(); if (!s) return { apellido: '', nombre: '' };
        const parts = s.split(/\s+/); if (parts.length === 1) return { apellido: parts[0], nombre: '' };
        return { apellido: parts[0], nombre: parts.slice(1).join(' ') };
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos'); if(!tbody) return;
        if(items.length === 0) { tbody.innerHTML = `<tr><td colspan="8" class="p-6 text-center text-slate-500 text-sm">No hay turnos para estos filtros.</td></tr>`; return; }
        let htmlRows = '';
        items.forEach(t => {
            const estado = escapeHtml(String(t.field_7 || 'Pendiente').trim()); const esAprobado = estado.toLowerCase() === 'aprobado';
            const esSobreturno = t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1;
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : ((estado.toLowerCase() === 'cancelado' || estado.toLowerCase() === 'rechazado') ? 'text-rose-400' : (estado.toLowerCase() === 'reprogramado' ? 'text-sky-400 font-bold' : 'text-amber-400'));
            const fechaStr = t.field_6 ? String(t.field_6).split('T')[0] : '-';
            const filaClase = esSobreturno ? 'border-b border-slate-700/50 hover:bg-violet-900/30 bg-violet-950/20 text-sm border-l-2 border-l-violet-500' : 'border-b border-slate-700/50 hover:bg-slate-800/30 text-sm';
            const tagSobreturno = esSobreturno ? `<span class="ml-1.5 text-[9px] uppercase font-bold text-violet-300 bg-violet-900/50 border border-violet-700 px-1.5 py-0.5 rounded">Sobreturno</span>` : '';
            const horaIn  = t.HoraIngresoReal  ? `<span class="text-emerald-400 text-[10px] block mt-0.5">${escapeHtml(t.HoraIngresoReal)}</span>`  : '';
            const horaSal = t.HoraSalidaReal   ? `<span class="text-rose-400 text-[10px] block mt-0.5">${escapeHtml(t.HoraSalidaReal)}</span>` : '';
            const botonesTracking = esAprobado ? `<button onclick="marcarTracking(${t.Id},'IN')" title="Registrar Ingreso" class="bg-slate-800 hover:bg-emerald-900/60 text-emerald-400 border border-emerald-900 px-2 py-1 rounded text-[10px] font-bold transition flex flex-col items-center leading-tight">In${horaIn}</button><button onclick="marcarTracking(${t.Id},'OUT')" title="Registrar Salida" class="bg-slate-800 hover:bg-rose-900/60 text-rose-400 border border-rose-900 px-2 py-1 rounded text-[10px] font-bold transition flex flex-col items-center leading-tight">Out${horaSal}</button>` : '';

            htmlRows += `
            <tr class="${filaClase}">
                <td class="p-3 font-semibold text-sky-400 font-sans">${t.Id}</td>
                <td class="p-3 text-slate-300 font-medium font-sans">${fechaStr}</td>
                <td class="p-3 text-slate-300 font-bold font-sans">${escapeHtml(t.PlantaDescarga || '-')}</td>
                <td class="p-3 text-white font-semibold font-sans">${escapeHtml(t.field_2 || '-')}${tagSobreturno}</td>
                <td class="p-3 font-semibold tracking-widest text-slate-300 font-sans">
                    <span class="bg-black/40 px-2 py-1 rounded">${escapeHtml(t.Patente || '-')}</span>
                </td>
                <td class="p-3 text-amber-300 font-semibold font-sans">${escapeHtml(t.field_5 || '-')}</td>
                <td class="p-3 ${colorEst} text-center font-sans">${estado}<br><span class="text-[10px] text-slate-500 font-normal truncate block max-w-[120px] mx-auto mt-0.5">${escapeHtml(getResponsableName(t))}</span></td>
                <td class="p-3 text-center flex justify-center gap-2">
                    <button onclick="modoABM_Ver(${t.Id})" class="bg-sky-700 hover:bg-sky-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Ver</button>
                    ${!esAprobado && estado.toLowerCase() !== 'cancelado' && estado.toLowerCase() !== 'rechazado' ? `<button onclick="modoABM_Aprobar(${t.Id})" class="bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Aprobar</button>` : ''}
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }
    function getResponsableName(t) { return t.Author ? t.Author.Title : (t.Editor ? t.Editor.Title : (t.Gestor || 'S/D')); }

    function renderizarGrilaCalendario() {
        const gridContainer = document.getElementById('calendar-days-grid'); if (!gridContainer) return;
        const baseDate = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00'); const anio = baseDate.getFullYear(); const mes = baseDate.getMonth(); 
        document.getElementById('calendar-month-title').textContent = `${["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"][mes]} ${anio}`;
        let dayOfWeek = new Date(anio, mes, 1).getDay(); let calHtml = ''; 
        for (let b = 0; b < (dayOfWeek === 0 ? 6 : dayOfWeek - 1); b++) calHtml += `<div class="p-2 text-transparent select-none">-</div>`;
        const totalDiasMes = new Date(anio, mes + 1, 0).getDate();
        for (let dia = 1; dia <= totalDiasMes; dia++) {
            let claseEstilo = (dia === baseDate.getDate()) ? 'bg-sky-500 text-slate-900 font-extrabold rounded shadow' : 'text-slate-300 hover:bg-slate-800 rounded cursor-pointer transition';
            let strDia = `${anio}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
            calHtml += `<button onclick="conmutarFechaDesdeCalendario('${strDia}')" class="p-2 rounded text-sm w-full font-sans ${claseEstilo}">${dia}</button>`;
        }
        gridContainer.innerHTML = calHtml;
    }
    function conmutarFechaDesdeCalendario(nuevaFecha) {
        fechaSeleccionadaGlobal = nuevaFecha; document.getElementById('f_fecha') && (document.getElementById('f_fecha').value = nuevaFecha);
        renderizarGrilaCalendario(); aplicarFiltrosMonitor(); generarResumenDiario(); renderizarResumenCapacidad();
        if(document.getElementById('s10') && document.getElementById('s10').classList.contains('active')) { document.getElementById('dash_fecha').value = nuevaFecha; updateDashboard(); }
    }

    function renderizarABMHorarios(preserveExpanded = true) {
        const tb = document.getElementById('tabla-config-horarios'); if(!tb) return; let h = '';
        const expandedPlants = preserveExpanded ? Array.from(document.querySelectorAll('[data-expander-planta].open')).map(x => x.getAttribute('data-expander-planta')) : [];
        if (capacidadPorPlantaTipoCache && capacidadPorPlantaTipoCache.length) {
            const grupos = Object.values(capacidadPorPlantaIndex).sort((a,b)=> String(a.resumen?.Planta || '').localeCompare(String(b.resumen?.Planta || '')));
            const rows = grupos.map(g => {
                const r = g.resumen || {}; const plantaKey = String(r.Planta || ''); const plantaKeyAttr = escapeHtml(plantaKey); const isOpen = expandedPlants.includes(plantaKey);
                const claseOpen = isOpen ? 'open' : ''; const simbolo = isOpen ? '−' : '+';
                const saturacion = g.filas.length ? Math.max(...g.filas.map(x => { const c = toNum(x.Turnos_Cargados,2); const t = Math.max(1,toNum(x.TotalDia || x.Turnos_Calc,2)); return c/t; })) : 0;
                const colorPlant = saturacion >= 1 ? 'text-rose-400' : (saturacion >= .8 ? 'text-amber-400' : 'text-sky-400');
                const parent = `<tr class="text-sm cap-parent-row border-b border-slate-700/50 hover:bg-slate-800/30"><td class="py-3 px-4 font-bold ${colorPlant} whitespace-nowrap"><button type="button" class="expander-btn ${claseOpen}" data-expander-planta="${plantaKeyAttr}" onclick="toggleDetalleCapacidad('${plantaKey.replace(/'/g, "\\'")}')">${simbolo}</button>${escapeHtml(r.Planta || '-')}</td ><td class="px-4 text-slate-400 font-semibold">-</td><td class="px-4 text-center text-slate-400">-</td><td class="px-4 text-center text-slate-400">-</td><td class="px-4 text-center text-emerald-400 font-bold mono-num">${fmtNum(r.Turnos_Calc || r.TotalDia, 0)}</td><td class="px-4 text-center text-amber-400 font-bold mono-num">${fmtNum(r.Turnos_Sabado, 0)}</td><td class="px-4 text-center text-slate-300 mono-num">${fmtNum(r.Min_LV, 0)}</td><td class="px-4 text-center text-slate-300 mono-num">${fmtNum(r.Min_SAB, 0)}</td><td class="px-4 text-center text-slate-300 mono-num">${fmtNum(r.Minutos_Turno, 0)}</td><td class="px-4 text-center text-sky-300 font-bold mono-num">${fmtNum(r.TotalDia || r.Turnos_Calc, 0)}</td><td class="px-4 text-center font-bold ${String(r.Estatus || 'OK').toUpperCase()==='OK' ? 'text-emerald-400' : 'text-amber-400'}">${escapeHtml(r.Estatus || 'OK')}</td></tr>`;
                const children = (g.filas || []).sort((a,b) => { const ta = String(a.Tipo_Carga || '').toUpperCase(); const tb = String(b.Tipo_Carga || '').toUpperCase(); const ia = ORDEN_TIPOS.includes(ta) ? ORDEN_TIPOS.indexOf(ta) : 999; const ib = ORDEN_TIPOS.includes(tb) ? ORDEN_TIPOS.indexOf(tb) : 999; return ia - ib; }).map(row => {
                    const colorHab = Number(row.Habilitado || 0) === 1 ? 'text-emerald-400' : 'text-rose-400'; const colorEst = String(row.Estatus || 'OK').toUpperCase() === 'OK' ? 'text-emerald-400' : 'text-amber-400'; const hidden = isOpen ? '' : 'hidden-row';
                    return `<tr class="text-sm cap-child-row ${hidden} border-b border-slate-800/60" data-parent-planta="${plantaKeyAttr}" data-planta="${escapeHtml(row.Planta)}" data-tipo="${escapeHtml(row.Tipo_Carga)}"><td class="py-2.5 px-4 text-slate-500"><span class="cap-child-indent">&#9492;</span></td><td class="px-4 text-white font-semibold">${escapeHtml(row.Tipo_Carga || '-')}</td><td class="px-4 text-center font-bold ${colorHab} mono-num"><select class="cap-select" data-field="Habilitado"><option value="1" ${Number(row.Habilitado||0)===1?'selected':''}>1</option><option value="0" ${Number(row.Habilitado||0)===0?'selected':''}>0</option></select></td><td class="px-4 text-center text-slate-200 mono-num"><input class="cap-input num" data-field="Turnos_Cargados" value="${fmtNum(row.Turnos_Cargados,2)}"></td><td class="px-4 text-center text-emerald-400 font-bold mono-num"><input class="cap-input num" data-field="Turnos_Calc" value="${fmtNum(row.Turnos_Calc,2)}"></td><td class="px-4 text-center text-amber-400 font-bold mono-num"><input class="cap-input num" data-field="Turnos_Sabado" value="${fmtNum(row.Turnos_Sabado,2)}"></td><td class="px-4 text-center text-slate-300 mono-num"><input class="cap-input num" data-field="Min_LV" value="${fmtNum(row.Min_LV,0)}"></td><td class="px-4 text-center text-slate-300 mono-num"><input class="cap-input num" data-field="Min_SAB" value="${fmtNum(row.Min_SAB,0)}"></td><td class="px-4 text-center text-slate-300 mono-num"><input class="cap-input num" data-field="Minutos_Turno" value="${fmtNum(row.Minutos_Turno,0)}"></td><td class="px-4 text-center text-sky-300 font-bold mono-num"><input class="cap-input num" data-field="TotalDia" value="${fmtNum(row.TotalDia,2)}"></td><td class="px-4 text-center font-bold ${colorEst}"><select class="cap-select" data-field="Estatus"><option value="OK" ${String(row.Estatus||'OK').toUpperCase()==='OK'?'selected':''}>OK</option><option value="REVISION" ${String(row.Estatus||'').toUpperCase()==='REVISION'?'selected':''}>REVISION</option></select></td></tr>`;
                }).join('');
                return parent + children;
            }).join('');
            tb.innerHTML = rows || '<tr><td colspan="11" class="p-6 text-center text-slate-500 text-sm">Sin datos en capacidad_turnos_por_planta.csv.</td></tr>';
            return;
        }
        tb.innerHTML = '<tr><td colspan="11" class="p-6 text-center text-slate-500 text-sm">Sin datos en capacidad_turnos_por_planta.csv.</td></tr>';
    }

    function previewHorariosConfig() { renderizarABMHorarios(); }
    function toggleSabado(idx) { let isChk = document.getElementById(`cfg_sab_${idx}`).checked; document.getElementById(`cfg_ins_${idx}`).disabled = !isChk; document.getElementById(`cfg_outs_${idx}`).disabled = !isChk; document.getElementById(`cfg_ins_${idx}`).classList.toggle('opacity-30', !isChk); document.getElementById(`cfg_outs_${idx}`).classList.toggle('opacity-30', !isChk); }
    function guardarConfiguracionHorarios() {
        (async () => {
            try {
                const rows = collectCapacidadRowsFromDom();
                if (!rows.length) return showToast('No hay datos de capacidad para guardar.', 'err');
                capacidadPorPlantaTipoCache = rows.map(r => ({ ...r, Tipo_Carga: normalizarTipoCarga(r.Tipo_Carga) }));
                await guardarCapacidadCSVSharePoint(capacidadPorPlantaTipoCache);
                refreshCapacidadFromCache();
                actualizarEstadoCSVVisual('ok', 'CSV actualizado', `Registros guardados: ${capacidadPorPlantaTipoCache.length}. La información ya impacta en Turnos Diarios y paneles relacionados.`);
                showToast('Capacidad guardada y CSV actualizado.', 'ok');
                logLog(`[ETL CSV] capacidad_turnos_por_planta.csv actualizado desde configuración. Registros: ${capacidadPorPlantaTipoCache.length}`);
            } catch (e) {
                actualizarEstadoCSVVisual('err', 'Error al guardar CSV', e.message || 'No se pudo guardar el CSV');
                showToast('No se pudo guardar el CSV de capacidad.', 'err');
                logLog(`[ERROR CSV CAPACIDAD WRITE]: ${e.message}`);
            }
        })();
    }

    function getSlotsCalculados(plantaId, fechaStr) {
        let slots = []; if(!fechaStr || !plantaId) return slots;
        let pConf = configPlantas.find(p => p.id === plantaId); if (!pConf) return slots;
        const d = new Date(fechaStr.replace(/-/g, '/') + ' 00:00:00'); const day = d.getDay();
        if (day === 0 || (day === 6 && !pConf.sabado)) return slots;
        let startMins = (day === 6 ? pConf.hInS : pConf.hInLV) * 60; let endMins = (day === 6 ? pConf.hOutS : pConf.hOutLV) * 60; let duration = pConf.duracion;
        if(duration <= 0 || startMins >= endMins) return slots; 
        let current = startMins;
        while ((current + duration) <= endMins) {
            let h1 = String(Math.floor(current/60)).padStart(2,'0'); let m1 = String(current%60).padStart(2,'0');
            let curEnd = current + duration; let h2 = String(Math.floor(curEnd/60)).padStart(2,'0'); let m2 = String(curEnd%60).padStart(2,'0');
            slots.push(`${h1}:${m1} a ${h2}:${m2} h`); current += duration;
        }
        return slots;
    }
    function normalizarStringHorario(str) { return String(str || "").toLowerCase().replace(/h/g, "").replace(/\s+/g, "").trim(); }

    function autoDia() {
        const fVal = document.getElementById('f_fecha').value; if (!fVal) return;
        document.getElementById('f_dia').textContent = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'][new Date(fVal.replace(/-/g, '/') + ' 00:00:00').getDay()];
    }

    let modoABMActual = null;
    function handleHorariosChange() { const filtrar = (modoABMActual === 'ALTA' || modoABMActual === 'REPROGRAMAR'); regenerarHorariosABM(filtrar); autoDia(); }
    function regenerarHorariosABM(modoFiltro = false) {
        const pf = document.getElementById('f_planta_descarga').value; const zona = document.getElementById('f_planta').value; const f = document.getElementById('f_fecha').value; const sel = document.getElementById('f_horario');
        if(!sel) return; sel.innerHTML = '';
        if(!pf) { sel.innerHTML = '<option value="">-</option>'; return; }
        if(!f) { sel.innerHTML = '<option value="">Seleccione fecha</option>'; return; }
        if(!zona) { sel.innerHTML = '<option value="">Seleccione zona</option>'; return; }
        let allSlots = getSlotsCalculados(pf, f);
        if(allSlots.length === 0) { sel.innerHTML = '<option value="">Sin Operacion</option>'; return; }
        let oc = modoFiltro ? listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(f) && t.PlantaDescarga === pf && t.Planta === zona && String(t.field_7).toLowerCase() !== 'cancelado' && String(t.field_7).toLowerCase() !== 'rechazado').map(t => normalizarStringHorario(t.field_5)) : [];
        let htmlOpts = '';
        allSlots.forEach(s => { if (!(modoFiltro && oc.includes(normalizarStringHorario(s)))) htmlOpts += `<option value="${s}">${s}</option>`; });
        sel.innerHTML = htmlOpts === '' ? '<option value="">Agenda Completa</option>' : htmlOpts;
    }

    function limpiarErroresVisuales() { document.querySelectorAll('.input-error').forEach(el => el.classList.remove('input-error')); }
    function marcarError(id, msg) { const el = document.getElementById(id); if(el) { el.classList.add('input-error'); el.focus(); } showToast(msg, "err"); return false; }
    
    function validarFormularioTurno(modo) {
        limpiarErroresVisuales();
        const fPatente = document.getElementById('f_patente').value.trim(); const fCuit = document.getElementById('f_cuit').value.trim();
        const fProv = document.getElementById('f_proveedor').value.trim(); const fEmail = document.getElementById('f_email').value.trim();
        const fFec = document.getElementById('f_fecha').value; const fHor = document.getElementById('f_horario').value;

        if(!fPatente) return marcarError('f_patente', "Patente obligatoria.");
        let cuitLimpio = fCuit.replace(/[^0-9]/g, '');
        if(!fCuit || cuitLimpio.length < 5) return marcarError('f_cuit', "ID invalido.");
        const provEnBD = listaProveedoresCache.find(p => p.id === cuitLimpio || p.cuit === cuitLimpio);
        if(!provEnBD && listaProveedoresCache.length > 0) return marcarError('f_cuit', "Proveedor no existe.");
        if(provEnBD && provEnBD.estado !== 'Habilitado') return marcarError('f_cuit', "Proveedor inhabilitado.");
        if(!fProv) return marcarError('f_proveedor', "Razon Social vacia.");
        if(fEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fEmail)) return marcarError('f_email', "Email invalido.");
        if(!fFec) return marcarError('f_fecha', "Fecha requerida.");
        const fPlanta = document.getElementById('f_planta_descarga').value; const fZona = document.getElementById('f_planta').value;
        if(!fPlanta) return marcarError('f_planta_descarga', "Seleccione Planta Fisica.");
        if(!fZona) return marcarError('f_planta', "Seleccione Zona de Descarga.");
        if(modo === 'ALTA' || modo === 'REPROGRAMAR') {
            const hoy = new Date(); hoy.setHours(0,0,0,0); const maxHabilitada = new Date(); maxHabilitada.setDate(maxHabilitada.getDate() + 1); maxHabilitada.setHours(0,0,0,0);
            const fechaIngresada = new Date(fFec.replace(/-/g, '/') + ' 00:00:00');
            if(fechaIngresada < hoy) return marcarError('f_fecha', "Fecha pasada.");
            if(fechaIngresada > maxHabilitada) return marcarError('f_fecha', "Solo se permiten Altas/Reprogramaciones para hoy o manana.");
        }
        if(!fHor) return marcarError('f_horario', "Seleccione horario libre.");
        return true;
    }

    async function checkSlotLibreConcurrencia(planta, zona, fecha, slot) {
        try { const res = await fetchSharePoint(`items?$filter=PlantaDescarga eq '${planta}' and Planta eq '${zona}' and startswith(field_6, '${fecha}') and field_5 eq '${slot}' and field_7 ne 'Cancelado' and field_7 ne 'Rechazado'&$select=Id`); if(res.ok) { const data = await res.json(); return data.value.length === 0; } } catch(e) {} 
        return true;
    }

    function mostrarBannerABM(id, modo) {
        const banner = document.getElementById('abm-mensaje-estado'); banner.classList.remove('hidden');
        if(modo === 'VER') { banner.className = "text-sm font-bold px-4 py-3 rounded-lg mb-4 shadow-sm bg-sky-900/50 text-sky-300 border border-sky-700 block font-sans"; banner.innerHTML = `El turno con el ID N&deg; ${id} esta siendo consultado.`; } 
        else if (modo === 'APROBAR') { banner.className = "text-sm font-bold px-4 py-3 rounded-lg mb-4 shadow-sm bg-amber-900/50 text-amber-300 border border-amber-700 block font-sans"; banner.innerHTML = `El turno con el ID N&deg; ${id} esta siendo modificado.`; }
    }

    function abrirAltaTurno() {
        limpiarFormularioABM(); poblarSelectsABMInicial();
        document.getElementById('f_fecha').value = ''; document.getElementById('f_dia').innerHTML = "-"; document.getElementById('f_horario').innerHTML = '<option value="">-</option>';
        aplicarVentanaFechaAlta(); document.getElementById('f_usuario_gestor').textContent = escapeHtml(currentLoggedUser.name || 'S/D');
        actualizarDatalistFlota();
        document.getElementById('btn-modo-modificar').classList.add('hidden');
        document.getElementById('form-mode-indicator').innerHTML = "ALTA DE TURNO"; document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-emerald-900/50 text-emerald-400 border border-emerald-800 rounded-md font-bold tracking-wide";
        habilitarCamposABM(true); renderBotonesABM('ALTA'); document.querySelector('[data-target="s1"]').click();
    }
    
    function modoABM_Ver(id) {
        document.querySelector('[data-target="s1"]').click(); const t = listaTurnosCache.find(x => x.Id == id); const est = String(t.field_7 || 'PENDIENTE').trim().toUpperCase();
        cargarTurnoEnFormulario(id, 'VER'); mostrarBannerABM(id, 'VER'); habilitarCamposABM(false); 
        if (est === 'PENDIENTE') {
            document.getElementById('f_planta_descarga').innerHTML = '<option value="">Seleccione Planta</option>'; document.getElementById('f_planta').innerHTML = '<option value="">Seleccione Zona</option>';
            document.getElementById('btn-modo-modificar').classList.remove('hidden'); document.getElementById('form-mode-indicator').innerHTML = `CONSULTA LECTURA`;
            renderBotonesABM('VER_PENDIENTE', est);
        } else {
            document.getElementById('btn-modo-modificar').classList.add('hidden'); document.getElementById('form-mode-indicator').innerHTML = `CONSULTA LECTURA`;
            renderBotonesABM('VER', est);
        }
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-slate-800 text-slate-300 rounded-md font-bold border border-slate-600 tracking-wide flex items-center";
    }
    
    function modoABM_Modificar() {
        const id = document.getElementById('f_item_id').value; document.getElementById('abm-mensaje-estado').className = "hidden"; cargarTurnoEnFormulario(id, 'MODIFICAR');
        document.getElementById('btn-modo-modificar').classList.add('hidden'); document.getElementById('form-mode-indicator').innerHTML = `MODIFICANDO TURNO N&deg; ${id}`; document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-amber-900/50 text-amber-400 border border-amber-700 rounded-md font-bold tracking-wide flex items-center";
        habilitarCamposABM(true); renderBotonesABM('MODIFICANDO');
    }

    function modoABM_Aprobar(id) {
        cargarTurnoEnFormulario(id, 'APROBAR_PANEL'); document.getElementById('btn-modo-modificar').classList.add('hidden');
        document.getElementById('form-mode-indicator').innerHTML = "MODO APROBACION"; document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-amber-900/50 text-amber-400 border border-amber-700 rounded-md font-bold tracking-wide";
        mostrarBannerABM(id, 'APROBAR'); habilitarCamposABM(false); renderBotonesABM('APROBAR_PANEL'); document.querySelector('[data-target="s1"]').click();
    }
    
    function modoABM_Reprogramar() {
        document.getElementById('form-mode-indicator').innerHTML = "REPROGRAMACION"; document.getElementById('abm-mensaje-estado').className = "hidden"; document.getElementById('btn-modo-modificar').classList.add('hidden');
        habilitarCamposABM(false); document.getElementById('f_fecha').disabled = false; document.getElementById('f_fecha').min = new Date().toISOString().split('T')[0]; document.getElementById('f_horario').disabled = false;
        handleHorariosChange(); renderBotonesABM('REPROGRAMAR');
    }
    
    function volverTurnosDiarios() { modoABMActual = null; cerrarModalNuevoProveedor(); document.getElementById('btn-modo-modificar').classList.add('hidden'); document.querySelector('[data-target="s2"]').click(); }
    
    function habilitarCamposABM(estado) { document.querySelectorAll('.f-control').forEach(el => el.disabled = !estado); }

    function setModoIndicador(texto, claseColor, modo) { modoABMActual = modo || null; const ind = document.getElementById('form-mode-indicator'); if(!ind) return; ind.textContent = texto; ind.className = `text-xs uppercase px-3 py-1.5 rounded-full font-bold border min-w-[120px] text-center ${claseColor}`; }

    function renderBotonesABM(modo, estadoStr = '') {
        const panel = document.getElementById('panel-botones-abm'); if(!panel) return;
        if (modo === 'ALTA') { setModoIndicador('ALTA DE TURNO','bg-emerald-900 text-emerald-300 border-emerald-700', 'ALTA'); panel.innerHTML = `<button onclick="crearTurno()" class="bg-sky-600 hover:bg-sky-500 px-8 py-3 font-bold rounded-lg text-white transition shadow-sm flex items-center justify-center gap-2 flex-1">Registrar Alta</button><button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; } 
        else if (modo === 'VER_PENDIENTE' || modo === 'VER') { setModoIndicador('CONSULTA','bg-sky-900 text-sky-300 border-sky-700', 'VER'); panel.innerHTML = `<button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Cancelar / Volver</button>`; } 
        else if (modo === 'MODIFICANDO') { setModoIndicador('MODIFICANDO','bg-amber-900 text-amber-300 border-amber-700', 'MODIFICAR'); panel.innerHTML = `<button onclick="guardarModificacionTurno()" class="bg-amber-600 hover:bg-amber-500 px-8 py-3 font-bold rounded-lg text-white transition shadow-sm flex-1">Guardar Modificacion</button><button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; } 
        else if (modo === 'APROBAR_PANEL') { setModoIndicador('APROBACION','bg-emerald-900 text-emerald-300 border-emerald-700', 'APROBAR_PANEL'); panel.innerHTML = `<button onclick="ejecutarAccionFlujo('Aprobado')" class="bg-emerald-600 hover:bg-emerald-500 px-4 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Aprobar</button><button onclick="ejecutarAccionFlujo('Cancelado')" class="bg-rose-600 hover:bg-rose-500 px-4 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Cancelar Turno</button><button onclick="modoABM_Reprogramar()" class="bg-amber-600 hover:bg-amber-500 px-4 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Reprogramar</button><button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; } 
        else if (modo === 'REPROGRAMAR') { setModoIndicador('REPROGRAMACION','bg-indigo-900 text-indigo-300 border-indigo-700', 'REPROGRAMAR'); panel.innerHTML = `<button onclick="ejecutarReprogramacion()" class="bg-indigo-600 hover:bg-indigo-500 px-6 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Confirmar Reprogramacion</button><button onclick="modoABM_Ver(document.getElementById('f_item_id').value)" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; }
    }

    function cargarTurnoEnFormulario(id, modo) {
        const t = listaTurnosCache.find(item => item.Id === parseInt(id)); if (!t) return;
        const modoActual = modo || modoABMActual || 'VER'; limpiarErroresVisuales();
        document.getElementById('f_item_id').value = t.Id; document.getElementById('f_patente').value = t.Patente || ''; document.getElementById('f_hora_ing').value = t.HoraIngresoReal || '';
        document.getElementById('f_hora_sal').value = t.HoraSalidaReal || ''; document.getElementById('f_cuit').value = t.field_1 || ''; document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || ''; document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('f_email').value = t.field_3 || ''; if (t.field_6) document.getElementById('f_fecha').value = String(t.field_6).split('T')[0];
        autoDia();

        const selPD = document.getElementById('f_planta_descarga'); resetSelectConGuion(selPD); configPlantas.forEach(p => selPD.add(new Option(p.id, p.id)));
        const mostrarValoresGuardados = (modoActual === 'VER' || modoActual === 'APROBAR_PANEL');
        if (mostrarValoresGuardados) { asegurarOptionSelect(selPD, t.PlantaDescarga); poblarSelectZonasPorPlanta(t.PlantaDescarga, t.Planta); } 
        else if (modoActual === 'MODIFICAR' || modoActual === 'REPROGRAMAR') { if (t.PlantaDescarga) { asegurarOptionSelect(selPD, t.PlantaDescarga); poblarSelectZonasPorPlanta(t.PlantaDescarga, t.Planta); } else { selPD.selectedIndex = 0; poblarSelectZonasPorPlanta('', ''); } } 
        else { selPD.selectedIndex = 0; poblarSelectZonasPorPlanta('', ''); }

        document.getElementById('f_sobreturno').checked = (t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1);
        regenerarHorariosABM(modoActual === 'ALTA' || modoActual === 'REPROGRAMAR');
        let slotSelect = document.getElementById('f_horario'); if(t.field_5 && !Array.from(slotSelect.options).some(opt => opt.value === t.field_5)) slotSelect.add(new Option(t.field_5 + ' (Asignado)', t.field_5));
        slotSelect.value = t.field_5 || '';
        document.getElementById('f_usuario_gestor').innerHTML = escapeHtml(getResponsableName(t));
        const est = String(t.field_7 || 'PENDIENTE').trim().toUpperCase(); document.getElementById('f_estado_actual').innerHTML = est;
        
        const trackEnab = (est === 'APROBADO' || est === 'REPROGRAMADO'); document.getElementById('btn-track-in').disabled = !trackEnab; document.getElementById('btn-track-out').disabled = !trackEnab;
    }

    function limpiarFormularioABM() {
        limpiarErroresVisuales(); document.getElementById('abm-mensaje-estado').className = "hidden"; document.getElementById('f_item_id').value = '';
        ['f_planta_descarga', 'f_planta'].forEach(id => { const sel = document.getElementById(id); if (sel && sel.options.length > 0 && sel.options[0].value === '') sel.remove(0); });
        document.querySelectorAll('.f-control').forEach(i => { if (i.tagName === 'SELECT') { if (i.id === 'f_horario') i.innerHTML = '<option value="">-</option>'; else if (i.selectedIndex >= 0) i.selectedIndex = 0; } else if (i.type === 'checkbox') i.checked = false; else i.value = ''; i.disabled = true; });
        document.getElementById('f_fecha').min = ''; document.getElementById('f_fecha').max = ''; document.getElementById('f_dia').innerHTML = '-'; document.getElementById('f_usuario_gestor').innerHTML = '-'; document.getElementById('f_estado_actual').innerHTML = 'NUEVO'; document.getElementById('panel-botones-abm').innerHTML = ''; document.getElementById('btn-track-in').disabled = true; document.getElementById('btn-track-out').disabled = true;
    }

    async function crearTurno() {
        if(!validarFormularioTurno('ALTA')) return;
        const pf = document.getElementById('f_planta_descarga').value; const zona = document.getElementById('f_planta').value; const fc = document.getElementById('f_fecha').value; const sh = document.getElementById('f_horario').value;
        const libre = await checkSlotLibreConcurrencia(pf, zona, fc, sh);
        if(!libre && !document.getElementById('f_sobreturno').checked) return marcarError('f_horario', "Slot ocupado. Utilice opcion de Sobreturno.");

        const payload = {
            field_1: document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''), field_2: document.getElementById('f_proveedor').value.trim(), field_3: document.getElementById('f_email').value.trim(),
            field_5: sh, field_6: fc + "T00:00:00Z", field_7: "Pendiente", N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, PlantaDescarga: pf, Dia: document.getElementById('f_dia').textContent, Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            EsSobreturno: document.getElementById('f_sobreturno').checked
        };
        await ejecutarTransaccion(null, payload, "Turno Creado"); volverTurnosDiarios();
    }

    async function ejecutarModificacion() {
        if(!validarFormularioTurno('ALTA')) return; 
        const id = document.getElementById('f_item_id').value;
        const payload = {
            field_1: document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''), field_2: document.getElementById('f_proveedor').value.trim(), field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value, field_6: document.getElementById('f_fecha').value + "T00:00:00Z", N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, PlantaDescarga: document.getElementById('f_planta_descarga').value, Dia: document.getElementById('f_dia').textContent, Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            EsSobreturno: document.getElementById('f_sobreturno').checked
        };
        await ejecutarTransaccion(id, payload, "Turno Modificado"); volverTurnosDiarios();
    }

    async function ejecutarAccionFlujo(nuevoEstado) {
        const id = document.getElementById('f_item_id').value; const email = document.getElementById('f_email').value; const t = listaTurnosCache.find(x => x.Id == id);
        if(t && String(t.field_7).toLowerCase() === 'cancelado' && nuevoEstado !== 'Cancelado') return showToast("El turno ya fue cancelado.", "err");
        await ejecutarTransaccion(id, { field_7: nuevoEstado }, `Turno ${nuevoEstado}`);
        
        if (email) {
            const responsable = getResponsableName(t); const userObj = listaUsuariosCache.find(u => u.nombre === responsable); const cc = userObj && userObj.email ? `&cc=${userObj.email}` : '';
            let body = `Su turno logistico ha sido ${nuevoEstado.toUpperCase()}.\nFecha: ${document.getElementById('f_fecha').value}\nHorario: ${document.getElementById('f_horario').value}\n\nEnviado por: ${responsable}`;
            window.location.href = `mailto:${email}?subject=Estado Turno: ${nuevoEstado}${cc}&body=${encodeURIComponent(body)}`;
        }
        volverTurnosDiarios();
    }

    async function ejecutarReprogramacion() {
        if(!validarFormularioTurno('REPROGRAMAR')) return;
        const id = document.getElementById('f_item_id').value; const pf = document.getElementById('f_planta_descarga').value; const zona = document.getElementById('f_planta').value; const fc = document.getElementById('f_fecha').value; const sh = document.getElementById('f_horario').value;
        const libre = await checkSlotLibreConcurrencia(pf, zona, fc, sh);
        if(!libre && !document.getElementById('f_sobreturno').checked) return marcarError('f_horario', "Slot ocupado.");
        await ejecutarTransaccion(id, { field_6: fc + "T00:00:00Z", field_5: sh, field_7: "Reprogramado" }, "Turno Reprogramado");
        volverTurnosDiarios();
    }

    async function marcarTrackingForm(tipo) {
        if(tipo === 'OUT') {
            const hIn = document.getElementById('f_hora_ing').value;
            if(!hIn) return showToast("No puede cargar horario de salida ya que no hay un horario de ingreso informado", "err");
        }
        const id = document.getElementById('f_item_id').value; const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        let payload = {}; if(tipo === 'IN') { payload.HoraIngresoReal = horaStr; document.getElementById('f_hora_ing').value = horaStr; } if(tipo === 'OUT') { payload.HoraSalidaReal = horaStr; document.getElementById('f_hora_sal').value = horaStr; }
        await ejecutarTransaccion(id, payload, `Check-${tipo} Registrado`, true);
    }

    async function marcarTracking(itemId, tipo) {
        if (!itemId) return showToast("Sin ID de turno.", "err");
        if(tipo === 'OUT') {
            const obj = listaTurnosCache.find(x => x.Id === parseInt(itemId));
            if(!obj || !obj.HoraIngresoReal) return showToast("No puede cargar horario de salida ya que no hay un horario de ingreso informado.", "err");
        }
        const horaStr = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
        let payload = {}; if (tipo === 'IN')  payload.HoraIngresoReal = horaStr; if (tipo === 'OUT') payload.HoraSalidaReal  = horaStr;
        const obj = listaTurnosCache.find(x => x.Id === parseInt(itemId)); if (obj) Object.assign(obj, payload); aplicarFiltrosMonitor();
        await ejecutarTransaccion(itemId, payload, `Check-${tipo} OK (${horaStr})`, true);
    }

    function llenarComboResponsablesProv() {
        const select = document.getElementById('p_resp'); if(!select) return; let currentVal = select.value; let html = '<option value="">-- Seleccione --</option>';
        const activos = listaUsuariosCache.filter(u => u.estado !== 'Deshabilitado'); activos.forEach(u => { html += `<option value="${escapeHtml(u.nombre)}">${escapeHtml(u.nombre)}</option>`; });
        select.innerHTML = html; if(currentVal) select.value = currentVal;
    }

    function autoCompletarMailResp() {
        const respNombre = document.getElementById('p_resp').value; const user = listaUsuariosCache.find(u => u.nombre === respNombre); document.getElementById('p_mail').value = user ? user.email : '';
    }

    // --- ABM PROVEEDORES ---
    function parsearCSVProveedores(text) {
        const lines = text.split(/\r?\n|\r/); listaProveedoresCache = [];
        const headerLine = lines[0] ? lines[0].replace(/^\uFEFF/, '').trim() : ''; const headerCols = headerLine.split(/;/).map(h => h.trim().toLowerCase());
        const iUsuario = headerCols.findIndex(h => h.startsWith('usuario')); const iResp = headerCols.findIndex(h => h.startsWith('responsable')); const iMail = headerCols.findIndex(h => h.includes('mail') || h.includes('email')); const iTipo = headerCols.findIndex(h => h.startsWith('tipo'));
        const iNum = headerCols.findIndex(h => h.startsWith('num') || h === 'id'); const iNombre = headerCols.findIndex((h, i) => i !== iNum && (h.includes('nombre') || h.includes('razon'))); const iEstado = headerCols.findIndex(h => h === 'estado'); const iCuit = headerCols.findIndex(h => h === 'cuit');
        const usarHeader = iNum >= 0 && iNombre >= 0;

        for (let i = 1; i < lines.length; i++) {
            const row = lines[i].trim(); if (!row) continue; const cols = row.split(/;/);
            if (usarHeader) {
                listaProveedoresCache.push({ usuario: (cols[iUsuario >= 0 ? iUsuario : 0] || '').trim(), responsable: (cols[iResp >= 0 ? iResp : 1] || '').trim(), mail: (cols[iMail >= 0 ? iMail : 2] || '').trim(), tipo: (cols[iTipo >= 0 ? iTipo : 3] || '').trim(), id: (cols[iNum] || '').replace(/[^0-9]/g, ''), nombre: (cols[iNombre] || '').trim(), estado: (iEstado >= 0 ? (cols[iEstado] || 'Habilitado').trim() : 'Habilitado') || 'Habilitado', cuit: (iCuit >= 0 ? (cols[iCuit] || '').replace(/[^0-9\-]/g, '') : '') });
            } else if (cols.length === 7) {
                listaProveedoresCache.push({ usuario: cols[0].trim(), responsable: cols[1].trim(), mail: cols[2].trim(), tipo: cols[3].trim(), id: cols[4].replace(/[^0-9]/g, ''), cuit: '', nombre: cols[5].trim(), estado: cols[6].trim() || 'Habilitado' });
            } else if (cols.length >= 8) {
                listaProveedoresCache.push({ usuario: cols[0].trim(), responsable: cols[1].trim(), mail: cols[2].trim(), tipo: cols[3].trim(), id: cols[4].replace(/[^0-9]/g, ''), nombre: cols[5].trim(), estado: cols[6].trim() || 'Habilitado', cuit: cols[7].replace(/[^0-9\-]/g, '') });
            }
        }
        renderizarBaseProveedores();
    }

    function renderizarBaseProveedores() {
        const tb = document.getElementById('tabla-proveedores'); if(!tb) return;
        tb.innerHTML = listaProveedoresCache.map((p, idx) => `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarProvForm(${idx})"><td class="p-3 text-slate-300">${escapeHtml(p.usuario)}</td><td class="p-3 text-slate-400">${escapeHtml(p.responsable)}</td><td class="p-3 text-amber-400 font-bold">${escapeHtml(p.id)}</td><td class="p-3 text-amber-400 font-bold">${escapeHtml(p.cuit || '-')}</td><td class="p-3 text-white font-semibold">${escapeHtml(p.nombre)}</td><td class="p-3 text-slate-400">${escapeHtml(p.tipo)}</td><td class="p-3 font-bold ${p.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(p.estado)}</td><td class="p-3 text-sky-400 underline text-center">Editar</td></tr>`).join('');
    }

    function cargarProvForm(idx) {
        const p = listaProveedoresCache[idx]; document.getElementById('p_index').value = idx; document.getElementById('p_usuario').value = p.usuario || currentLoggedUser.name; document.getElementById('p_resp').value = p.responsable; document.getElementById('p_mail').value = p.mail; document.getElementById('p_tipo').value = p.tipo; document.getElementById('p_num_prov').value = p.id; document.getElementById('p_cuit').value = p.cuit || ''; document.getElementById('p_razon').value = p.nombre; document.getElementById('p_estado').value = p.estado || 'Habilitado';
        const btnElim = document.getElementById('btn_elim_prov'); if(btnElim) btnElim.classList.remove('hidden');
    }

    function limpiarFormularioProveedor() {
        document.getElementById('p_index').value = ''; document.getElementById('p_usuario').value = currentLoggedUser.name || ''; document.getElementById('p_resp').selectedIndex = 0; document.getElementById('p_mail').value = ''; document.getElementById('p_cuit').value = ''; document.getElementById('p_num_prov').value = ''; document.getElementById('p_razon').value = ''; document.getElementById('p_tipo').value = ''; document.getElementById('p_estado').value = 'Habilitado';
        const btnElim = document.getElementById('btn_elim_prov'); if(btnElim) btnElim.classList.add('hidden');
    }

    async function guardarEdicionProveedor() {
        const idx = document.getElementById('p_index').value; const pNum = document.getElementById('p_num_prov').value.replace(/[^0-9]/g, ''); const pCuit = document.getElementById('p_cuit').value.replace(/[^0-9\-]/g, '');
        if(!pNum) return showToast("Falta Num Proveedor", "err");
        const obj = { usuario: document.getElementById('p_usuario').value, responsable: document.getElementById('p_resp').value, mail: document.getElementById('p_mail').value, tipo: document.getElementById('p_tipo').value, id: pNum, cuit: pCuit, nombre: document.getElementById('p_razon').value, estado: document.getElementById('p_estado').value };
        if(idx === '') listaProveedoresCache.push(obj); else listaProveedoresCache[idx] = obj;
        renderizarBaseProveedores(); limpiarFormularioProveedor(); showToast("Proveedor Guardado", "ok"); await actualizarCSVSharePoint('prov');
        if (window.returnToTurnoForm) { window.returnToTurnoForm = false; document.querySelector('[data-target="s1"]').click(); autocompletarProveedor(); }
    }

    async function eliminarProveedor() {
        const idx = document.getElementById('p_index').value; if(idx === '') return;
        if(!confirm('¿Esta seguro de eliminar este proveedor?')) return;
        listaProveedoresCache.splice(idx, 1);
        renderizarBaseProveedores(); limpiarFormularioProveedor();
        showToast('Proveedor eliminado.', 'ok'); await actualizarCSVSharePoint('prov');
    }

    function abrirModalNuevoProveedor(cuitPrecargado) {
        if (_modalProvAbierto) return; _modalProvAbierto = true; limpiarErroresVisuales();
        let modal = document.getElementById('modal-nuevo-prov'); if(modal) modal.remove();
        modal = document.createElement('div'); modal.id = 'modal-nuevo-prov'; modal.className = 'fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm';
        modal.innerHTML = `
            <div class="bg-slate-900 border border-slate-600 rounded-2xl p-8 w-full max-w-lg shadow-2xl">
                <h3 class="text-lg font-bold text-sky-400 mb-1">Nuevo Proveedor</h3>
                <p class="text-xs text-slate-400 mb-5">El CUIT ingresado no existe en el padron. Complete los datos para registrarlo y continuar con el Alta del Turno.</p>
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3"><div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Num Prov (ID)</label><input id="mnp_id" type="text" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none focus:border-sky-500" placeholder="Ej: 12345"></div><div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">CUIT</label><input id="mnp_cuit" type="text" value="${escapeHtml(cuitPrecargado)}" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none focus:border-sky-500"></div></div>
                    <div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Razon Social *</label><input id="mnp_nombre" type="text" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500" placeholder="Nombre del proveedor"></div>
                    <div class="grid grid-cols-2 gap-3"><div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Tipo Insumo</label><select id="mnp_tipo" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500"><option value="Insumos">Insumos</option><option value="Packaging">Packaging</option><option value="Materia Prima">Materia Prima</option><option value="Granel">Granel</option></select></div><div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Mail Contacto</label><input id="mnp_mail" type="email" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500"></div></div>
                </div>
                <div class="flex justify-end gap-3 mt-6"><button onclick="cerrarModalNuevoProveedor()" class="bg-slate-700 hover:bg-slate-600 px-5 py-2.5 font-bold rounded text-white transition">Cancelar</button><button onclick="guardarProveedorDesdeModal()" class="bg-sky-600 hover:bg-sky-500 px-6 py-2.5 font-bold rounded text-white transition shadow">Guardar y Continuar Alta</button></div>
            </div>`;
        document.body.appendChild(modal); setTimeout(() => document.getElementById('mnp_nombre')?.focus(), 100);
    }
    function cerrarModalNuevoProveedor() { _modalProvAbierto = false; const m = document.getElementById('modal-nuevo-prov'); if(m) m.remove(); }
    async function guardarProveedorDesdeModal() {
        const nombre = document.getElementById('mnp_nombre')?.value.trim(); const cuit = document.getElementById('mnp_cuit')?.value.replace(/[^0-9\-]/g,''); const id = document.getElementById('mnp_id')?.value.replace(/[^0-9]/g,'') || cuit; const tipo = document.getElementById('mnp_tipo')?.value || 'Insumos'; const mail = document.getElementById('mnp_mail')?.value.trim() || '';
        if(!nombre) return showToast('Razon Social requerida.', 'err');
        const nuevoProveedor = { usuario: currentLoggedUser.name || '', responsable: currentLoggedUser.name || '', mail, tipo, id, cuit, nombre, estado: 'Habilitado' };
        listaProveedoresCache.push(nuevoProveedor); cerrarModalNuevoProveedor();
        document.getElementById('f_proveedor').value = nombre; document.getElementById('f_email').value = mail; showToast(`Proveedor "${nombre}" registrado. Continue con el Alta del Turno.`, 'ok'); await actualizarCSVSharePoint('prov').catch(() => {});
    }

    function autocompletarProveedor() {
        const nProv = document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''); document.getElementById('f_cuit').value = nProv;
        if (!nProv) return;
        if (listaProveedoresCache.length === 0) return showToast('Padron de proveedores no cargado aun. Verifique la conexion.', 'err');
        const provEncontrado = listaProveedoresCache.find(p => p.id === nProv || p.cuit === nProv);
        if (!provEncontrado) { if (_modalProvAbierto) return; showToast('CUIT no encontrado. Complete el alta de proveedor.', 'ok'); abrirModalNuevoProveedor(nProv); return; }
        if (provEncontrado.estado !== 'Habilitado') return marcarError('f_cuit', "PROVEEDOR INHABILITADO -- no se puede asignar turno.");
        document.getElementById('f_proveedor').value = provEncontrado.nombre; if (provEncontrado.mail) document.getElementById('f_email').value = provEncontrado.mail;
        document.getElementById('f_usuario_gestor').textContent = escapeHtml(currentLoggedUser.name || 'S/D'); showToast(`Proveedor OK: ${provEncontrado.nombre}`, "ok");
    }

    // --- ABM USUARIOS ---
    function parsearCSVUsuarios(text) {
        const lines = text.split(/\r?\n|\r/); listaUsuariosCache = [];
        for(let i=1; i<lines.length; i++) { 
            const row = lines[i].trim(); if(!row) continue; const cols = row.split(/;/); 
            if(cols.length >= 5) listaUsuariosCache.push({ id: cols[0].trim(), nombre: cols[1].trim(), email: cols[2].trim(), planta: cols[3].trim(), estado: cols[4] ? cols[4].trim() : 'Habilitado', reporte: cols[5] ? cols[5].trim() : 'SI' });
        }
        renderizarBaseUsuarios();
    }

    function renderizarBaseUsuarios() {
        const tb = document.getElementById('tabla-usuarios'); if(!tb) return;
        tb.innerHTML = listaUsuariosCache.map((u, idx) => `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer font-sans" onclick="cargarUsuForm(${idx})"><td class="p-3 text-amber-400 font-semibold">${escapeHtml(u.id)}</td><td class="p-3 text-white font-semibold">${escapeHtml(u.nombre)}</td><td class="p-3 text-slate-400">${escapeHtml(u.email)}</td><td class="p-3 text-slate-400">${escapeHtml(u.planta)}</td><td class="p-3 font-semibold ${u.reporte === 'SI' ? 'text-sky-400' : 'text-slate-500'}">${escapeHtml(u.reporte)}</td><td class="p-3 font-bold ${u.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(u.estado)}</td><td class="p-3 text-sky-400 underline text-center">Editar</td></tr>`).join('');
        llenarComboResponsablesProv();
    }

    function cargarUsuForm(idx) {
        const u = listaUsuariosCache[idx]; document.getElementById('u_index').value = idx; document.getElementById('u_id').value = u.id; document.getElementById('u_nombre').value = u.nombre;
        document.getElementById('u_email').value = u.email; document.getElementById('u_planta').value = u.planta; document.getElementById('u_reporte').value = u.reporte || 'SI'; document.getElementById('u_estado').value = u.estado || 'Habilitado';
        const btnElim = document.getElementById('btn_elim_usu'); if(btnElim) btnElim.classList.remove('hidden');
    }

    function limpiarFormularioUsuario() {
        document.getElementById('u_index').value = ''; document.getElementById('u_id').value = ''; document.getElementById('u_nombre').value = ''; document.getElementById('u_email').value = ''; 
        if(document.getElementById('u_planta').options.length > 0) document.getElementById('u_planta').selectedIndex = 0;
        document.getElementById('u_reporte').value = 'SI'; document.getElementById('u_estado').value = 'Habilitado';
        const btnElim = document.getElementById('btn_elim_usu'); if(btnElim) btnElim.classList.add('hidden');
    }

    async function guardarEdicionUsuario() {
        const idx = document.getElementById('u_index').value; const uId = document.getElementById('u_id').value.trim(); const uPlanta = document.getElementById('u_planta').value; const uEstado = document.getElementById('u_estado').value;
        if(!uId) return showToast("Falta ID", "err"); if(!uPlanta) return showToast("Seleccione Planta Asociada", "err"); if(!uEstado) return showToast("Seleccione Estado", "err");
        const obj = { id: uId, nombre: document.getElementById('u_nombre').value, email: document.getElementById('u_email').value, planta: document.getElementById('u_planta').value, reporte: document.getElementById('u_reporte').value, estado: document.getElementById('u_estado').value };
        if(idx === '') listaUsuariosCache.push(obj); else listaUsuariosCache[idx] = obj;
        renderizarBaseUsuarios(); sincronizarFiltrosYMonitor(); limpiarFormularioUsuario(); showToast("Usuario Guardado", "ok"); await actualizarCSVSharePoint('usu');
    }

    async function eliminarUsuario() {
        const idx = document.getElementById('u_index').value; if(idx === '') return;
        if(!confirm('¿Esta seguro de eliminar este usuario?')) return;
        listaUsuariosCache.splice(idx, 1);
        renderizarBaseUsuarios(); sincronizarFiltrosYMonitor(); limpiarFormularioUsuario();
        showToast('Usuario eliminado.', 'ok'); await actualizarCSVSharePoint('usu');
    }

    // --- FLOTA ---
    function renderizarBaseFlota() {
        const tb = document.getElementById('tabla-flota'); if(!tb) return;
        tb.innerHTML = listaFlotaCache.map((f, idx) => `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer font-sans" onclick="cargarFlotaForm(${idx})"><td class="p-3 font-semibold text-amber-400 uppercase">${escapeHtml(f.patente)}</td><td class="p-3 text-white font-semibold">${escapeHtml(f.tipo)}</td><td class="p-3 text-slate-400">${escapeHtml(f.capacidad1)}</td><td class="p-3 text-slate-400">${escapeHtml(f.empresa)}</td><td class="p-3 font-bold ${f.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(f.estado)}</td><td class="p-3 text-sky-400 underline text-center">Editar</td></tr>`).join('');
    }
    function limpiarFormularioFlota() {
        document.getElementById('fl_item_id').value = ''; 
        ['fl_patente','fl_descripcion','fl_empresa','fl_cuit','fl_apellido','fl_nombre','fl_cap1','fl_cap2','fl_cap3','fl_tipodisp','fl_numdisp','fl_correo','fl_celular','fl_dni'].forEach(id => { const el = document.getElementById(id); if(el) el.value = ''; });
        document.getElementById('fl_tipo').value = ''; document.getElementById('fl_estado').value = '';
        const btnElim = document.getElementById('btn_elim_flota'); if(btnElim) btnElim.classList.add('hidden');
    }
    function cargarFlotaForm(idx) {
        const f = listaFlotaCache[idx]; limpiarFormularioFlota();
        document.getElementById('fl_item_id').value = idx; document.getElementById('fl_patente').value = f.patente || ''; document.getElementById('fl_tipo').value = f.tipo || ''; document.getElementById('fl_descripcion').value = f.descripcion || ''; document.getElementById('fl_empresa').value = f.empresa || ''; document.getElementById('fl_cuit').value = f.cuit || ''; document.getElementById('fl_apellido').value = f.apellido || ''; document.getElementById('fl_nombre').value = f.nombre || ''; document.getElementById('fl_correo').value = f.correo || ''; document.getElementById('fl_celular').value = f.celular || ''; document.getElementById('fl_cap1').value = f.capacidad1 || ''; document.getElementById('fl_cap2').value = f.capacidad2 || ''; document.getElementById('fl_cap3').value = f.capacidad3 || ''; document.getElementById('fl_tipodisp').value = f.tipoDispositivo || ''; document.getElementById('fl_numdisp').value = f.numeroDispositivo || ''; document.getElementById('fl_dni').value = f.dni || ''; document.getElementById('fl_estado').value = f.estado || '';
        const btnElim = document.getElementById('btn_elim_flota'); if(btnElim) btnElim.classList.remove('hidden');
    }
    async function guardarEdicionFlota() {
        const idx = document.getElementById('fl_item_id').value; const pat = document.getElementById('fl_patente').value.trim().toUpperCase(); const tipo = document.getElementById('fl_tipo').value; const estado = document.getElementById('fl_estado').value;
        if(!pat) return showToast("Falta Patente", "err"); if(!tipo) return showToast("Debe seleccionar un Tipo", "err"); if(!estado) return showToast("Debe seleccionar un Estado", "err");
        
        const existente = idx !== '' && listaFlotaCache[parseInt(idx,10)] ? listaFlotaCache[parseInt(idx,10)] : listaFlotaCache.find(v => v.patente === pat);
        const headerLen = flotaHeaderCols.length || 19;
        const raw = existente && Array.isArray(existente.raw) ? [...existente.raw] : Array(headerLen).fill('');
        while (raw.length < headerLen) raw.push('');
        
        raw[0] = pat;
        raw[1] = document.getElementById('fl_descripcion').value.trim();
        raw[2] = document.getElementById('fl_nombre').value.trim();
        raw[3] = document.getElementById('fl_apellido').value.trim();
        raw[4] = document.getElementById('fl_correo').value.trim();
        raw[5] = document.getElementById('fl_celular').value.trim();
        raw[6] = document.getElementById('fl_cap1').value.trim();
        raw[7] = document.getElementById('fl_cap2').value.trim();
        raw[8] = document.getElementById('fl_cap3').value.trim();
        raw[10] = document.getElementById('fl_tipodisp').value.trim();
        raw[11] = document.getElementById('fl_numdisp').value.trim();
        raw[14] = document.getElementById('fl_empresa').value.trim();
        raw[15] = tipo;
        raw[16] = document.getElementById('fl_dni').value.trim();

        const obj = mapearFilaFlota(raw);
        obj.cuit = document.getElementById('fl_cuit').value.replace(/[^0-9\-]/g,'');
        obj.estado = estado;
        
        if (idx !== '' && listaFlotaCache[parseInt(idx,10)]) listaFlotaCache[parseInt(idx,10)] = obj;
        else if (!existente) listaFlotaCache.push(obj);
        else { const pos = listaFlotaCache.findIndex(v => v.patente === pat); if (pos >= 0) listaFlotaCache[pos] = obj; }
        
        renderizarBaseFlota(); actualizarDatalistFlota(); limpiarFormularioFlota(); showToast("Vehiculo Guardado", "ok"); await actualizarCSVSharePoint('flota');
    }
    async function eliminarFlota() {
        const idx = document.getElementById('fl_item_id').value; if(idx === '') return;
        if(!confirm('¿Esta seguro de eliminar este vehiculo?')) return;
        listaFlotaCache.splice(idx, 1);
        renderizarBaseFlota(); actualizarDatalistFlota(); limpiarFormularioFlota();
        showToast('Vehiculo eliminado.', 'ok'); await actualizarCSVSharePoint('flota');
    }

    // --- ZONAS DE DESCARGA ---
    function parsearCSVZonas(text) {
        const lines = text.split(/\r?\n|\r/).filter(l => l.trim() !== ''); listaZonasCache = [];
        for(let i=1; i<lines.length; i++) {
            const row = lines[i].trim(); if(!row) continue;
            const cols = row.split(';');
            if(cols.length >= 6) {
                listaZonasCache.push({ id: cols[0].trim(), planta: cols[1].trim(), nombre: cols[2].trim(), tipo: cols[3].trim(), capacidad: cols[4].trim(), estado: cols[5].trim() || 'Activo' });
            }
        }
        renderizarBaseZonas();
    }
    function renderizarBaseZonas() {
        const tb = document.getElementById('tabla-zonas'); if(!tb) return;
        tb.innerHTML = listaZonasCache.map((z, idx) => `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer font-sans" onclick="cargarZonaForm(${idx})"><td class="p-3 font-semibold text-amber-400">${escapeHtml(z.id)}</td><td class="p-3 text-white font-semibold">${escapeHtml(z.planta)}</td><td class="p-3 text-slate-400">${escapeHtml(z.nombre)}</td><td class="p-3 text-slate-400">${escapeHtml(z.tipo)}</td><td class="p-3 text-slate-400 text-center">${escapeHtml(z.capacidad)}</td><td class="p-3 font-bold ${z.estado === 'Activo' || z.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(z.estado)}</td><td class="p-3 text-sky-400 underline text-center">Editar</td></tr>`).join('');
    }
    function limpiarFormularioZona() {
        document.getElementById('z_index').value = ''; document.getElementById('z_id').value = ''; document.getElementById('z_nombre').value = ''; document.getElementById('z_capacidad').value = '';
        if(document.getElementById('z_planta').options.length > 0) document.getElementById('z_planta').selectedIndex = 0;
        document.getElementById('z_tipo').value = ''; document.getElementById('z_estado').value = '';
        const btnElim = document.getElementById('btn_elim_zona'); if(btnElim) btnElim.classList.add('hidden');
    }
    function cargarZonaForm(idx) {
        const z = listaZonasCache[idx]; limpiarFormularioZona();
        document.getElementById('z_index').value = idx; document.getElementById('z_id').value = z.id; document.getElementById('z_planta').value = z.planta; document.getElementById('z_nombre').value = z.nombre; document.getElementById('z_tipo').value = z.tipo; document.getElementById('z_capacidad').value = z.capacidad; document.getElementById('z_estado').value = z.estado;
        const btnElim = document.getElementById('btn_elim_zona'); if(btnElim) btnElim.classList.remove('hidden');
    }
    async function guardarEdicionZona() {
        const idx = document.getElementById('z_index').value; const zPlanta = document.getElementById('z_planta').value; const zTipo = document.getElementById('z_tipo').value; const zEstado = document.getElementById('z_estado').value;
        if(!zPlanta) return showToast("Seleccione Planta Asociada", "err"); if(!zTipo) return showToast("Seleccione Tipo de Insumo", "err"); if(!zEstado) return showToast("Seleccione Estado", "err");
        const obj = { id: document.getElementById('z_id').value.trim() || `ZON-${Date.now().toString().slice(-4)}`, planta: zPlanta, nombre: document.getElementById('z_nombre').value.trim(), tipo: zTipo, capacidad: document.getElementById('z_capacidad').value, estado: zEstado };
        if(idx === '') listaZonasCache.push(obj); else listaZonasCache[idx] = obj;
        renderizarBaseZonas(); limpiarFormularioZona(); showToast("Zona Guardada", "ok"); await actualizarCSVSharePoint('zonas'); poblarSelectsABMInicial();
    }
    async function eliminarZona() {
        const idx = document.getElementById('z_index').value; if(idx === '') return;
        if(!confirm('¿Esta seguro de eliminar esta zona de descarga?')) return;
        listaZonasCache.splice(idx, 1);
        renderizarBaseZonas(); limpiarFormularioZona();
        showToast('Zona eliminada.', 'ok'); await actualizarCSVSharePoint('zonas'); poblarSelectsABMInicial();
    }

    // --- MAILING PARA REPORTES ---
    function enviarResumenDiario() {
        const idsPermitidos = ['Usu01', 'Usu02', 'Usu03', 'Usu04', 'Usu05', 'Usu06', 'Usu07', 'Usu08'];
        const para = listaUsuariosCache.filter(u => u.estado !== 'Deshabilitado' && idsPermitidos.includes(String(u.id))).map(u => u.email).filter(Boolean).join(';');
        if(!para) return showToast("No se detectaron los usuarios autorizados en la base", "err");
        const turnosVentana = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fechaSeleccionadaGlobal));
        if(turnosVentana.length === 0) return showToast("No hay turnos para reportar en la fecha", "err");
        const esSobre = t => t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1;
        const aprobados = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('aprobado')); const pendientes = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('pendiente')); const cancelados = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('cancelado') || String(t.field_7).toLowerCase().includes('rechazado')); const reprogramados = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('reprogramado')); const sobreturnos = turnosVentana.filter(esSobre);
        let body = `RESUMEN OPERATIVO MOLCA - ${fechaSeleccionadaGlobal} (generado ${new Date().toLocaleString('es-AR')})\n\nTotales: Aprobados ${aprobados.length} | Pendientes ${pendientes.length} | Cancelados ${cancelados.length} | Reprogramados ${reprogramados.length} | Sobreturnos ${sobreturnos.length}\n\n=== DETALLE POR PLANTA ===\n`;
        configPlantas.forEach(p => { const turnosP = turnosVentana.filter(t => t.PlantaDescarga === p.id); if(turnosP.length > 0) { body += `[ ${p.id.toUpperCase()} ] (${turnosP.length} turnos)\n`; turnosP.forEach(t => body += `  -> ${String(t.field_6).split('T')[0]} ${t.field_5} | Patente: ${t.Patente||'S/D'} | Prov: ${t.field_2} | Estado: ${t.field_7}${esSobre(t) ? ' [SOBRETURNO]' : ''}\n`); body += `\n`; } });
        body += `=== DETALLE POR RESPONSABLE ===\n`;
        const respUnicos = [...new Set(turnosVentana.map(t => getResponsableName(t)))].sort();
        respUnicos.forEach(r => { const turnosR = turnosVentana.filter(t => getResponsableName(t) === r); body += `[ ${r} ] (${turnosR.length} turnos)\n`; turnosR.forEach(t => body += `  -> ${String(t.field_6).split('T')[0]} ${t.field_5} | Planta: ${t.PlantaDescarga} | Estado: ${t.field_7}${esSobre(t) ? ' [SOBRETURNO]' : ''}\n`); body += `\n`; });
        window.location.href = `mailto:${para}?subject=Reporte de Operacion Molca (${fechaSeleccionadaGlobal})&body=${encodeURIComponent(body)}`;
    }

    // --- DASHBOARD DE INDICADORES (KPIs) ---
    let chartEstados, chartProveedores, chartPlantas, chartHorarios;
    function initDashboard() { document.getElementById('dash_fecha').value = fechaSeleccionadaGlobal; cargarSelectoresDashboard(); updateDashboard(); }
    function cargarSelectoresDashboard() {
        let usrHTML = '<option value="TODOS">-- Todos --</option>'; const usr = [...new Set(listaTurnosCache.map(t => getResponsableName(t)).filter(Boolean))].sort(); usr.forEach(u => { usrHTML += `<option value="${escapeHtml(u)}">${escapeHtml(u)}</option>`; }); document.getElementById('dash_resp').innerHTML = usrHTML;
        let horHTML = '<option value="TODOS">-- Todos --</option>'; const hor = [...new Set(listaTurnosCache.map(t => t.field_5).filter(Boolean))].sort(); hor.forEach(h => { horHTML += `<option value="${escapeHtml(h)}">${escapeHtml(h)}</option>`; }); document.getElementById('dash_horario').innerHTML = horHTML;
    }
    function updateDashboard() {
        const d_fec = document.getElementById('dash_fecha').value; const d_pla = document.getElementById('dash_planta').value; const d_hor = document.getElementById('dash_horario').value; const d_res = document.getElementById('dash_resp').value;
        let filtrados = listaTurnosCache;
        if(d_fec) filtrados = filtrados.filter(t => t.field_6 && t.field_6.startsWith(d_fec)); if(d_pla !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === d_pla); if(d_hor !== 'TODOS') filtrados = filtrados.filter(t => t.field_5 === d_hor); if(d_res !== 'TODOS') filtrados = filtrados.filter(t => getResponsableName(t) === d_res);
        let estadosCount = { 'Aprobado':0, 'Pendiente':0, 'Reprogramado':0, 'Cancelado':0, 'Rechazado':0 }; let plantasCount = {}; let horCount = {}; let provCount = {};
        let htmlResumen = ''; let totAsig = 0, totPend = 0, totApro = 0, totRepr = 0, totCanc = 0;
        filtrados.forEach(t => {
            let est = String(t.field_7).trim(); if(estadosCount[est] !== undefined) estadosCount[est]++; else if (est.toLowerCase().includes('rechazado')) estadosCount['Rechazado']++;
            let pl = t.PlantaDescarga || 'S/D'; plantasCount[pl] = (plantasCount[pl] || 0) + 1; let hr = t.field_5 || 'S/D'; horCount[hr] = (horCount[hr] || 0) + 1; let prv = t.field_2 || 'S/D'; provCount[prv] = (provCount[prv] || 0) + 1;
        });
        configPlantas.forEach(p => {
            const trnP = filtrados.filter(t => t.PlantaDescarga === p.id);
            if(trnP.length > 0) {
                let asig = trnP.length; let pend = trnP.filter(t => (t.field_7||'').toLowerCase().includes('pendiente')).length; let apro = trnP.filter(t => (t.field_7||'').toLowerCase().includes('aprobado')).length; let repr = trnP.filter(t => (t.field_7||'').toLowerCase().includes('reprogramado')).length; let canc = trnP.filter(t => (t.field_7||'').toLowerCase().includes('cancelado') || (t.field_7||'').toLowerCase().includes('rechazado')).length;
                totAsig += asig; totPend += pend; totApro += apro; totRepr += repr; totCanc += canc;
                htmlResumen += `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 transition"><td class="py-3 px-3 font-bold text-sky-300 text-sm">${p.id}</td><td class="px-3 text-center font-bold text-white text-base">${asig}</td><td class="px-3 text-center font-bold text-amber-400">${pend}</td><td class="px-3 text-center font-bold text-emerald-400">${apro}</td><td class="px-3 text-center font-bold text-sky-400">${repr}</td><td class="px-3 text-center font-bold text-rose-400">${canc}</td></tr>`;
            }
        });
        if(htmlResumen === '') { htmlResumen = '<tr><td colspan="6" class="p-6 text-center text-slate-500 text-sm">No hay actividad logistica para estos filtros.</td></tr>'; } 
        else { htmlResumen += `<tr class="bg-slate-800/80 font-extrabold text-white uppercase tracking-wider border-t-2 border-slate-500"><td class="py-4 px-3 text-right">TOTALES:</td><td class="px-3 text-center text-lg">${totAsig}</td><td class="px-3 text-center text-amber-400 text-lg">${totPend}</td><td class="px-3 text-center text-emerald-400 text-lg">${totApro}</td><td class="px-3 text-center text-sky-400 text-lg">${totRepr}</td><td class="px-3 text-center text-rose-400 text-lg">${totCanc}</td></tr>`; }
        document.getElementById('tabla-resumen-dashboard').innerHTML = htmlResumen;

        const lblFecha = document.getElementById('dash-resumen-fecha-label'); if(lblFecha) lblFecha.textContent = d_fec;
        const cont = document.getElementById('dash-resumen-contadores');
        if(cont) {
            let htmlVert = '';
            configPlantas.forEach(p => {
                const trnP = filtrados.filter(t => t.PlantaDescarga === p.id);
                if(trnP.length > 0) {
                    let asig = trnP.length; let pend = trnP.filter(t => (t.field_7||'').toLowerCase().includes('pendiente')).length; let apro = trnP.filter(t => (t.field_7||'').toLowerCase().includes('aprobado')).length; let repr = trnP.filter(t => (t.field_7||'').toLowerCase().includes('reprogramado')).length; let canc = trnP.filter(t => (t.field_7||'').toLowerCase().includes('cancelado') || (t.field_7||'').toLowerCase().includes('rechazado')).length; let sobre = trnP.filter(t => t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1).length;
                    htmlVert += `<div class="bg-slate-900/60 border border-slate-700 rounded-lg p-3"><div class="flex items-center justify-between mb-2"><span class="font-bold text-sky-300 text-xs uppercase truncate">${escapeHtml(p.id)}</span><span class="font-extrabold text-white text-sm bg-slate-800 rounded px-2 py-0.5">${asig}</span></div><div class="space-y-1 text-[11px] font-sans"><div class="flex justify-between"><span class="text-amber-400">Pendientes</span><span class="font-bold text-amber-400">${pend}</span></div><div class="flex justify-between"><span class="text-emerald-400">Aprobados</span><span class="font-bold text-emerald-400">${apro}</span></div><div class="flex justify-between"><span class="text-sky-400">Reprogramados</span><span class="font-bold text-sky-400">${repr}</span></div><div class="flex justify-between"><span class="text-rose-400">Cancelados</span><span class="font-bold text-rose-400">${canc}</span></div><div class="flex justify-between"><span class="text-violet-300">Sobreturnos</span><span class="font-bold text-violet-300">${sobre}</span></div></div></div>`;
                }
            });
            if(htmlVert === '') cont.innerHTML = '<div class="text-center text-slate-500 text-xs mt-6 px-2">No hay actividad logistica en esta fecha.</div>'; else cont.innerHTML = htmlVert;
        }

        Chart.defaults.color = '#94a3b8'; Chart.defaults.font.family = 'Inter';
        if(chartEstados) chartEstados.destroy(); chartEstados = new Chart(document.getElementById('chartEstados'), { type: 'bar', data: { labels: ['Aprobados', 'Pendientes', 'Reprogramados', 'Cancelados/Rechazados'], datasets: [{ label: 'Cantidad de Turnos', data: [estadosCount['Aprobado'], estadosCount['Pendiente'], estadosCount['Reprogramado'], estadosCount['Cancelado']+estadosCount['Rechazado']], backgroundColor: ['rgba(52, 211, 153, 0.7)', 'rgba(251, 191, 36, 0.7)', 'rgba(56, 189, 248, 0.7)', 'rgba(244, 63, 94, 0.7)'], borderColor: ['#10b981', '#f59e0b', '#0ea5e9', '#e11d48'], borderWidth: 1 }] }, options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
        const provSorted = Object.entries(provCount).sort((a,b) => b[1]-a[1]).slice(0,10);
        if(chartProveedores) chartProveedores.destroy(); chartProveedores = new Chart(document.getElementById('chartProveedores'), { type: 'bar', data: { labels: provSorted.map(p => p[0].substring(0, 15) + '...'), datasets: [{ label: 'Turnos por Proveedor (Top 10)', data: provSorted.map(p => p[1]), backgroundColor: 'rgba(99, 102, 241, 0.7)', borderColor: '#4f46e5', borderWidth: 1 }] }, options: { indexAxis: 'y', responsive: true, scales: { x: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
        if(chartPlantas) chartPlantas.destroy(); chartPlantas = new Chart(document.getElementById('chartPlantas'), { type: 'bar', data: { labels: Object.keys(plantasCount), datasets: [{ label: 'Volumen Operativo', data: Object.values(plantasCount), backgroundColor: 'rgba(244, 114, 182, 0.7)', borderColor: '#e11d48', borderWidth: 1 }] }, options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
        if(chartHorarios) chartHorarios.destroy(); chartHorarios = new Chart(document.getElementById('chartHorarios'), { type: 'line', data: { labels: Object.keys(horCount).sort(), datasets: [{ label: 'Densidad por Horario', data: Object.keys(horCount).sort().map(k => horCount[k]), backgroundColor: 'rgba(167, 139, 250, 0.2)', borderColor: '#c084fc', borderWidth: 2, fill: true, tension: 0.3 }] }, options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
    }

    initApp();
</script>
</body>
</html>