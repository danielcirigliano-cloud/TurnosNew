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
        .glass { background: var(--sp-panel); border: 1px solid var(--sp-border); backdrop-filter: blur(12px); }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.2s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
        .tab-btn { color: #94a3b8; transition: background .15s, color .15s; font-size: 0.95rem; padding: 10px; cursor: pointer; border-left: 3px solid transparent; }
        .tab-btn:hover { background: #1e293b; color: #fff; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; border-left: 3px solid #38bdf8; }
        #toast { position: fixed; bottom: 1.5rem; right: 1.5rem; padding: .6rem 1.2rem; border-radius: 8px; font-size: .9rem; font-weight: 600; opacity: 0; transition: opacity .3s; z-index: 9999; pointer-events: none; }
        #toast.show { opacity: 1; }
        #toast.ok   { background:#166534; border:1px solid #4ade80; color:#4ade80; }
        #toast.err  { background:#7f1d1d; border:1px solid #f87171; color:#f87171; }
        .etl-step { transition: all 0.3s; opacity: 0.5; }
        .etl-step.active { opacity: 1; transform: scale(1.02); border-color: #38bdf8; box-shadow: 0 0 15px rgba(56,189,248,0.2); }
        .etl-step.done { opacity: 1; border-color: #4ade80; }
        .input-error { border-color: #f43f5e !important; box-shadow: 0 0 0 1px #f43f5e; }
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
<body class="flex h-screen overflow-hidden text-slate-200">

<!-- SPLASH SCREEN -->
<div id="splash-screen">
    <div id="splash-content">
        <div class="term-header">MOLCA.ERP [Version 38.4.1]<br>Sistema de Gestion Logistica</div>
        <div id="splash-log"></div>
        <div><span class="text-emerald-400">>_</span><span class="cursor-blink"></span></div>
    </div>
</div>

<aside class="w-64 glass flex flex-col p-4 border-r border-slate-700 h-full z-10">
    <h1 class="text-xl font-bold text-white mb-5 uppercase tracking-wide">MOLCA <span class="text-sky-400">ERP</span></h1>
    <div class="mb-5 text-xs inline-flex items-center gap-2 p-1.5 rounded-full" style="background:rgba(0,0,0,.4); border:1px solid #334155;">
        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
        <span class="font-bold text-emerald-400">REST API</span>
    </div>

    <nav class="space-y-1 flex-1 overflow-y-auto" id="main-nav">
        <button class="w-full text-left rounded tab-btn active-tab" data-target="s2" id="btn-tab-monitor">1. Turnos Diarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s1" id="btn-tab-abm">2. ABM de Turnos</button>

        <div class="mt-2">
            <button onclick="toggleMenuConfig()" class="w-full text-left rounded tab-btn flex justify-between items-center" id="btn-menu-config">
                <span>3. Configuracion</span>
                <span id="icon-menu-config" class="text-red-500 text-sm font-bold">&#9654;</span>
            </button>
            <div id="submenu-config" class="hidden pl-3 border-l border-slate-700 ml-3 mt-1 space-y-1">
                <button class="w-full text-left rounded tab-btn text-sm" data-target="sFlota" onclick="limpiarFormularioFlota(); renderizarBaseFlota();">Flota</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="s6" onclick="limpiarFormularioProveedor(); renderizarBaseProveedores();">Proveedores</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="s7" onclick="limpiarFormularioUsuario(); renderizarBaseUsuarios();">Usuarios</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="sZonas" onclick="limpiarFormularioZona(); renderizarBaseZonas();">Zonas de Descarga</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="s8" onclick="renderizarABMHorarios()">Config. Horarios</button>
            </div>
        </div>

        <button class="w-full text-left rounded tab-btn" data-target="s9">4. Modulo ETL & Logs</button>
        <button class="w-full text-left rounded tab-btn" data-target="s10" onclick="initDashboard()">5. Dashboard e Indicadores</button>
    </nav>
</aside>

<main class="flex-1 p-6 overflow-y-auto relative w-full">
    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50 z-20">
        <span class="text-slate-400 font-semibold">Usuario:</span>
        <span id="app-user-name" class="text-sky-400 font-bold">Iniciando...</span>
    </div>

    <section id="s2" class="tab-content active mt-8 w-full">
        <div class="flex items-center gap-4 mb-4 flex-wrap">
            <h2 class="text-2xl font-bold text-sky-400">Monitor de Turnos Diarios</h2>
            <button onclick="abrirAltaTurno()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">[+] Alta de Turno</button>
            <button onclick="enviarResumenDiario()" class="bg-indigo-600 hover:bg-indigo-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">[Mail] Enviar Resumen</button>
        </div>
        
        <div class="grid grid-cols-12 gap-4 h-[calc(100vh-130px)]">
            <div class="col-span-9 glass p-4 rounded-xl flex flex-col h-full">
                <div class="flex gap-2 mb-3 items-end bg-slate-900/50 p-3 rounded-lg border border-slate-700 shrink-0 flex-wrap">
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Planta Fisica</label>
                        <select id="filtro_planta_descarga" onchange="sincronizarFiltrosYMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-34">
                            <option value="TODAS">-- Todas --</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Responsable</label>
                        <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-36">
                            <option value="TODOS">-- Todos --</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Estado</label>
                        <select id="filtro_estado" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-32">
                            <option value="TODOS">-- Todos --</option>
                            <option value="Pendiente">Pendientes</option>
                            <option value="Aprobado">Aprobados</option>
                            <option value="Reprogramado">Reprogramados</option>
                            <option value="Cancelado">Cancelados</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Tipo Turno</label>
                        <select id="filtro_tipo_turno" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-28">
                            <option value="TODOS">-- Todos --</option>
                            <option value="Normal">Normal</option>
                            <option value="Sobreturno">Sobreturno</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Patente</label>
                        <input type="text" id="filtro_patente" list="dl_patentes" oninput="aplicarFiltrosMonitor()" placeholder="Buscar patente..." class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-28 uppercase">
                        <datalist id="dl_patentes"></datalist>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Proveedor</label>
                        <input type="text" id="filtro_proveedor" list="dl_proveedores" oninput="aplicarFiltrosMonitor()" placeholder="Buscar proveedor..." class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-40">
                        <datalist id="dl_proveedores"></datalist>
                    </div>
                    <button onclick="restablecerFiltros()" class="bg-slate-700 px-3 py-1.5 text-xs rounded hover:bg-slate-600 transition self-end">Quitar Filtros</button>
                    <button onclick="refrescarDBAbsoluto()" class="ml-auto bg-slate-800 border border-slate-600 px-4 py-1.5 text-xs rounded text-sky-400 hover:bg-slate-700 transition self-end">Refrescar DB</button>
                </div>
                
                <div class="overflow-y-auto overflow-x-auto flex-1 border border-slate-700/50 rounded-lg">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow z-10">
                            <tr>
                                <th class="py-3 px-2">ID</th>
                                <th class="px-2">Fecha</th>
                                <th class="px-2">Planta</th>
                                <th class="px-2">Proveedor</th>
                                <th class="px-2">Patente</th>
                                <th class="px-2">Horario</th>
                                <th class="px-2 text-center">Estado</th>
                                <th class="px-2 text-center">Accion</th>
                            </tr>
                        </thead>
                        <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                            <tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Cargando...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-span-3 glass p-3 rounded-xl flex flex-col h-full overflow-hidden">
                <h3 class="text-xs font-bold text-sky-400 uppercase tracking-wider text-center mb-2 shrink-0">Turnos Disponibles</h3>
                <div id="panel-resumen-capacidad" class="w-full bg-slate-950/80 p-2 rounded border border-slate-800 mb-2 shadow-inner shrink-0 max-h-40 overflow-y-auto text-[10px]"></div>
                <div class="w-full bg-slate-950/80 p-2 rounded border border-slate-800 mb-3 shadow-inner shrink-0">
                    <div class="flex justify-between items-center mb-1 px-1">
                        <span id="calendar-month-title" class="font-bold text-white text-[11px] uppercase tracking-wide">MES</span>
                        <span class="text-[10px] text-slate-400">FECHA</span>
                    </div>
                    <div class="grid grid-cols-7 text-center font-bold text-slate-500 uppercase mb-1 text-[10px]">
                        <span>L</span><span>M</span><span>X</span><span>J</span><span>V</span><span>S</span><span>D</span>
                    </div>
                    <div id="calendar-days-grid" class="grid grid-cols-7 gap-1 text-center font-bold text-[11px] w-full"></div>
                </div>
                <div class="flex-1 overflow-y-auto pr-1">
                    <div id="panel-disponibilidad-dinamico" class="space-y-2"></div>
                </div>
            </div>
        </div>
    </section>

    <section id="s1" class="tab-content mt-8 w-full">
        <div class="flex items-center gap-4 mb-4">
            <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1.5 bg-emerald-900 text-emerald-300 rounded-full font-bold border border-emerald-700 min-w-[120px] text-center">Alta de Turno</div>
            <h2 class="text-2xl font-bold text-sky-400">ABM de Turnos</h2>
        </div>
        
        <div id="abm-mensaje-estado" class="text-sm font-bold px-4 py-3 rounded mb-4 hidden shadow-md"></div>

        <div class="glass p-8 rounded-xl w-full grid grid-cols-2 gap-6">
            <input type="hidden" id="f_item_id">
            <div class="col-span-2 grid grid-cols-3 gap-6 border-b border-slate-700 pb-6 mb-2">
                <div>
                    <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Patente Vehiculo *</label>
                    <div class="flex gap-2">
                        <input type="text" id="f_patente" list="dl_flota_patentes" placeholder="" onblur="autocompletarPatenteFlota()" class="bg-slate-900 border border-slate-700 p-3 w-full text-amber-300 uppercase outline-none f-control transition-colors focus:border-sky-500 flex-1" maxlength="7">
                        <button type="button" onclick="syncFlotaABM()" class="bg-slate-700 hover:bg-slate-600 text-emerald-300 px-3 py-2 text-xs font-bold rounded border border-slate-600 transition shrink-0" title="Sincronizar flota">Sync</button>
                    </div>
                    <datalist id="dl_flota_patentes"></datalist>
                </div>
                <div>
                    <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Hora Ingreso Real</label>
                    <input type="time" id="f_hora_ing" class="bg-slate-900 border border-slate-700 p-3 w-full text-emerald-400 outline-none transition-colors focus:border-sky-500 cursor-not-allowed opacity-80" readonly>
                </div>
                <div>
                    <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Hora Salida Real</label>
                    <input type="time" id="f_hora_sal" class="bg-slate-900 border border-slate-700 p-3 w-full text-rose-400 outline-none transition-colors focus:border-sky-500 cursor-not-allowed opacity-80" readonly>
                </div>
            </div>

            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Num Proveedor / CUIT *</label>
                <input type="text" id="f_cuit" placeholder="" onblur="autocompletarProveedor()" class="bg-slate-900 border border-slate-700 p-3 w-full text-amber-300 font-bold outline-none f-control transition-colors focus:border-sky-500">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Num OC</label>
                <input type="text" id="f_oc" placeholder="" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Razon Social Proveedor *</label>
                <input type="text" id="f_proveedor" placeholder="" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
            </div>

            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Planta Fisica (Ubicacion)</label>
                <select id="f_planta_descarga" onchange="onPlantaFisicaChange()" class="bg-slate-900 border border-slate-700 p-3 w-full text-sky-400 font-bold outline-none f-control transition-colors focus:border-sky-500"></select>
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Zona de Descarga (Area)</label>
                <select id="f_planta" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
                    <option value="">-</option>
                </select>
            </div>

            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Fecha Solicitud *</label>
                <input type="date" id="f_fecha" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Slot Horario Calculado *</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-3 w-full text-sky-300 font-semibold outline-none f-control transition-colors focus:border-sky-500"></select>
            </div>

            <div class="col-span-2 bg-slate-950 px-4 py-3 rounded text-sm border border-slate-800 text-slate-400 flex justify-between items-center mt-4">
                <span>Dia Semana: <strong id="f_dia" class="text-white">-</strong></span>
                <label class="inline-flex items-center gap-2 cursor-pointer select-none">
                    <input type="checkbox" id="f_sobreturno" class="w-4 h-4 rounded bg-slate-900 border-slate-600 text-violet-500 focus:ring-violet-500 f-control">
                    <span class="text-violet-300 font-bold uppercase text-xs">Sobreturno / Excepcion</span>
                </label>
            </div>

            <div class="col-span-2 flex gap-4 mt-2" id="panel-botones-abm"></div>

            <div class="col-span-2 mt-4 border-t border-slate-700 pt-4 flex justify-between items-center" id="panel-tracking">
                <div class="text-left">
                    <span class="block text-xs uppercase text-slate-400 font-bold mb-1">Responsable de Turno</span>
                    <span id="f_usuario_gestor" class="text-base font-bold text-white">-</span>
                </div>
                <div class="text-right">
                    <span class="block text-xs uppercase text-slate-400 font-bold mb-1">Estado de Transaccion</span>
                    <span id="f_estado_actual" class="text-2xl font-bold text-slate-500 uppercase tracking-widest">NUEVO</span>
                </div>
            </div>
        </div>
    </section>

    <!-- PROVEEDORES -->
    <section id="s6" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Proveedores</h2>
        <p class="text-xs text-slate-400 mb-4">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Documentos compartidos/proveedores.csv</span></p>
        
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="p_index">
            <div class="grid grid-cols-12 gap-4 items-end">
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Usuario Creador</label>
                    <input type="text" id="p_usuario" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-slate-400 rounded outline-none cursor-not-allowed" readonly>
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Responsable</label>
                    <select id="p_resp" onchange="autoCompletarMailResp()" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500"></select>
                </div>
                <div class="col-span-4">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Mail Responsable</label>
                    <input type="email" id="p_mail" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-slate-400 rounded outline-none cursor-not-allowed" readonly>
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Insumo</label>
                    <select id="p_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                        <option value="">- Tipo -</option>
                        <option value="Insumos">Insumos</option>
                        <option value="Packaging">Packaging</option>
                        <option value="Materia Prima">Materia Prima</option>
                    </select>
                </div>
                
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Num Prov (ID)</label>
                    <input type="text" id="p_num_prov" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">CUIT</label>
                    <input type="text" id="p_cuit" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-5">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre Proveedor</label>
                    <input type="text" id="p_razon" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado</label>
                    <select id="p_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">No Habilitado</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_prov" onclick="eliminarProveedor()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioProveedor()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionProveedor()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>

        <div class="glass p-6 rounded-xl text-base w-full mt-4">
            <div class="overflow-x-auto h-[500px]">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow">
                        <tr>
                            <th class="py-3 px-3">Usuario</th>
                            <th class="px-3">Responsable</th>
                            <th class="px-3">Num Prov.</th>
                            <th class="px-3">CUIT</th>
                            <th class="px-3">Razon Social</th>
                            <th class="px-3">Tipo Insumo</th>
                            <th class="px-3">Estado</th>
                            <th class="px-3 text-center">Accion</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-proveedores" class="divide-y divide-slate-700/50">
                        <tr><td colspan="8" class="p-6 text-center text-slate-500 text-sm">Sin padron de proveedores cargado.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- USUARIOS -->
    <section id="s7" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Usuarios</h2>
        <p class="text-xs text-slate-400 mb-4">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Documentos compartidos/Usuarios.csv</span></p>
        
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="u_index">
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 items-end">
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">ID Usuario</label>
                    <input type="text" id="u_id" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500" placeholder="">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre y Apellido</label>
                    <input type="text" id="u_nombre" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500" placeholder="">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Email Corporativo</label>
                    <input type="email" id="u_email" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500" placeholder="">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Planta Asociada</label>
                    <select id="u_planta" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500"></select>
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado</label>
                    <select id="u_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">No Habilitado</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_usu" onclick="eliminarUsuario()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioUsuario()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionUsuario()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>

        <div class="glass p-6 rounded-xl w-full">
            <div class="overflow-x-auto h-[500px]">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow">
                        <tr><th class="py-3 px-3">ID</th><th class="px-3">Nombre y Apellido</th><th class="px-3">Email</th><th class="px-3">Planta</th><th class="px-3">Estado</th><th class="px-3 text-center">Accion</th></tr>
                    </thead>
                    <tbody id="tabla-usuarios" class="divide-y divide-slate-700/50">
                        <tr><td colspan="6" class="p-6 text-center text-slate-500 text-sm">Sin datos.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- CONFIG HORARIOS -->
    <section id="s8" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Capacidad por Planta y Tipo de Carga</h2>
        <p class="text-sm text-slate-400 mb-4">Vista productiva alineada a <span class="text-sky-400">capacidad_turnos_por_planta.csv</span>.</p>
        <div id="csv-capacidad-status" class="csv-status warn"><div class="csv-title">Validacion CSV</div><div class="csv-detail">Pendiente de lectura del archivo.</div></div>
        <div class="glass p-6 rounded-xl text-base w-full">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-sm uppercase text-slate-400 font-bold border-b border-slate-700">
                        <tr><th class="py-4 px-4 cap-col-planta">Planta</th><th class="px-4">Tipo_Carga</th><th class="px-4 text-center">Habilitado</th><th class="px-4 text-center">Turnos_Cargados</th><th class="px-4 text-center">Turnos_Calc</th><th class="px-4 text-center">Turnos_Sabado</th><th class="px-4 text-center">Min_LV</th><th class="px-4 text-center">Min_SAB</th><th class="px-4 text-center">Minutos_Turno</th><th class="px-4 text-center">TotalDia</th><th class="px-4 text-center">Estatus</th></tr>
                    </thead>
                    <tbody id="tabla-config-horarios" class="divide-y divide-slate-700/50"></tbody>
                </table>
            </div>
            <div class="mt-6 flex gap-2 pt-5 border-t border-slate-700/50">
                <button onclick="guardarConfiguracionHorarios()" class="bg-emerald-600 hover:bg-emerald-500 px-6 py-3 font-bold rounded shadow transition text-white">Guardar y actualizar CSV</button>
                <button onclick="cargarCapacidadTurnosCSV(); renderizarABMHorarios(); showToast('Pantalla recargada desde CSV', 'ok');" class="bg-sky-700 hover:bg-sky-600 px-6 py-3 font-bold rounded shadow transition text-white">Refrescar desde CSV</button>
            </div>
        </div>
    </section>

    <!-- FLOTA -->
    <section id="sFlota" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Flota</h2>
        <p class="text-xs text-slate-400 mb-4">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Documentos compartidos/Flota.csv</span></p>
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="fl_item_id">
            <div class="grid grid-cols-12 gap-4 items-end">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Patente</label>
                    <input type="text" id="fl_patente" maxlength="7" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold uppercase rounded outline-none focus:border-sky-500" placeholder="AAA000">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Vehiculo</label>
                    <select id="fl_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Tipo -</option>
                        <option value="Camion">Camion</option>
                        <option value="Semi">Semi</option>
                        <option value="Furgon">Furgon</option>
                        <option value="Utilitario">Utilitario</option>
                        <option value="Otro">Otro</option>
                    </select>
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Empresa / Proveedor</label>
                    <input type="text" id="fl_empresa" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">CUIT Empresa</label>
                    <input type="text" id="fl_cuit" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Apellido Chofer</label>
                    <input type="text" id="fl_apellido" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre Chofer</label>
                    <input type="text" id="fl_nombre" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado</label>
                    <select id="fl_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">Deshabilitado</option>
                        <option value="Vencido">Vencido</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_flota" onclick="eliminarFlota()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioFlota()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionFlota()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>
        <div class="glass p-6 rounded-xl w-full">
            <div class="overflow-x-auto h-[480px]">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0">
                        <tr>
                            <th class="py-3 px-3">Patente</th>
                            <th class="px-3">Tipo</th>
                            <th class="px-3">Empresa / Proveedor</th>
                            <th class="px-3">CUIT</th>
                            <th class="px-3">Chofer</th>
                            <th class="px-3">Estado</th>
                            <th class="px-3 text-center">Accion</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-flota" class="divide-y divide-slate-700/50">
                        <tr><td colspan="7" class="p-6 text-center text-slate-500 text-sm">Sin datos de flota cargados.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- ZONAS DE DESCARGA (AHORA COMO CSV) -->
    <section id="sZonas" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Zonas de Descarga</h2>
        <p class="text-xs text-slate-400 mb-4">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Documentos compartidos/Zonas.csv</span></p>
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="z_index">
            <div class="grid grid-cols-12 gap-4 items-end">
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre Zona</label>
                    <input type="text" id="z_nombre" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white font-bold rounded outline-none focus:border-sky-500" placeholder="Ej: ZON-01">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Planta Fisica</label>
                    <select id="z_planta" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-sky-400 font-bold rounded outline-none focus:border-sky-500"></select>
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Insumo</label>
                    <select id="z_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Tipo -</option>
                        <option value="Insumos">Insumos</option>
                        <option value="Packaging">Packaging</option>
                        <option value="No Productivo">No Productivo</option>
                        <option value="Materia Prima">Materia Prima</option>
                        <option value="Granel">Granel</option>
                    </select>
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Capacidad (turnos/dia)</label>
                    <input type="number" id="z_capacidad" min="1" max="99" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado</label>
                    <select id="z_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Activo">Activo</option>
                        <option value="Inactivo">Inactivo</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button id="btn_elim_zona" onclick="eliminarZona()" class="hidden bg-rose-700 hover:bg-rose-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Eliminar</button>
                <button onclick="limpiarFormularioZona()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo / Limpiar</button>
                <button onclick="guardarEdicionZona()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Registro</button>
            </div>
        </div>
        <div class="glass p-6 rounded-xl w-full">
            <div class="overflow-x-auto h-[480px]">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0">
                        <tr>
                            <th class="py-3 px-3">Nombre Zona</th>
                            <th class="px-3">Planta</th>
                            <th class="px-3">Tipo Insumo</th>
                            <th class="px-3">Capacidad</th>
                            <th class="px-3">Estado</th>
                            <th class="px-3 text-center">Accion</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-zonas" class="divide-y divide-slate-700/50">
                        <tr><td colspan="6" class="p-6 text-center text-slate-500 text-sm">Sin zonas de descarga cargadas.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <!-- ETL -->
    <section id="s9" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Modulo ETL y Auditoria</h2>

        <div class="glass p-6 rounded-xl mb-6 border border-slate-700">
            <div class="flex items-center justify-between mb-4 border-b border-slate-700 pb-3">
                <div>
                    <h3 class="text-base font-bold text-sky-300 uppercase tracking-wider">Estado de Sincronizaciones</h3>
                    <p class="text-xs text-slate-400 mt-1">Lectura y escritura contra las listas y documentos de SharePoint.</p>
                </div>
                <button onclick="sincronizarTodo()" class="bg-sky-700 hover:bg-sky-600 text-white px-5 py-2.5 text-sm font-bold rounded shadow transition">
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
            <div class="glass p-8 rounded-xl">
                <h3 class="text-base font-bold text-slate-300 uppercase mb-6 border-b border-slate-700 pb-3">Flujo de Automatizacion del Core</h3>
                <div class="flex flex-col gap-6 relative">
                    <div class="absolute left-8 top-8 bottom-8 w-0.5 bg-slate-700 z-0"></div>
                    <div id="etl-extract" class="etl-step flex items-center gap-5 z-10 bg-slate-900 p-4 rounded border border-slate-700"><div class="w-10 h-10 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-sm" id="etl-ic1">1</div><div><div class="font-bold text-sky-400 text-base">Extraccion (E)</div><div class="text-sm text-slate-400">Lectura OData API REST y Repositorios.</div></div></div>
                    <div id="etl-transform" class="etl-step flex items-center gap-5 z-10 bg-slate-900 p-4 rounded border border-slate-700"><div class="w-10 h-10 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-sm" id="etl-ic2">2</div><div><div class="font-bold text-amber-400 text-base">Transformacion (T)</div><div class="text-sm text-slate-400">Mapeo OData y validacion defensiva.</div></div></div>
                    <div id="etl-load" class="etl-step flex items-center gap-5 z-10 bg-slate-900 p-4 rounded border border-slate-700"><div class="w-10 h-10 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-sm" id="etl-ic3">3</div><div><div class="font-bold text-emerald-400 text-base">Carga (L)</div><div class="text-sm text-slate-400">POST/MERGE a Base de Datos.</div></div></div>
                </div>
            </div>
            <div class="glass p-8 rounded-xl flex flex-col h-[600px]">
                <h3 class="text-base font-bold text-slate-300 uppercase mb-4 border-b border-slate-700 pb-3">Registro Maestro de Auditoria (Logs)</h3>
                <div class="flex-1 bg-black/80 rounded border border-slate-700 p-4 text-xs overflow-y-auto" id="etl-log-console" style="color:#4ade80"><div>> Inicializando motor ETL Audit...</div></div>
            </div>
        </div>
    </section>

    <section id="s10" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Dashboard e Indicadores</h2>

        <div class="glass p-5 rounded-xl mb-6 border border-slate-700">
            <div class="flex justify-between items-center mb-3 border-b border-slate-700 pb-2">
                <h3 class="text-sm font-bold text-emerald-400 uppercase tracking-wider">Resumen Operacion Diaria</h3>
                <span id="resumen-fecha-label" class="text-xs text-slate-400">Calculando...</span>
            </div>
            <div id="resumen-contadores-vertical" class="grid grid-cols-5 gap-3"></div>
        </div>
        
        <div class="glass p-4 rounded-xl mb-6 flex gap-4 items-end border border-slate-700 text-sm">
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Fecha</label>
                <input type="date" id="dash_fecha" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
            </div>
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Planta</label>
                <select id="dash_planta" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                    <option value="TODAS">-- Todas --</option>
                </select>
            </div>
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Horario</label>
                <select id="dash_horario" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                    <option value="TODOS">-- Todos --</option>
                </select>
            </div>
            <div>
                <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Responsable</label>
                <select id="dash_resp" onchange="updateDashboard()" class="bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                    <option value="TODOS">-- Todos --</option>
                </select>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div class="glass p-4 rounded-xl">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Estados Globales</h3>
                <canvas id="chartEstados"></canvas>
            </div>
            <div class="glass p-4 rounded-xl">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Ranking de Proveedores</h3>
                <canvas id="chartProveedores"></canvas>
            </div>
            <div class="glass p-4 rounded-xl">
                <h3 class="text-sm font-bold text-slate-300 mb-2">Turnos por Planta</h3>
                <canvas id="chartPlantas"></canvas>
            </div>
            <div class="glass p-4 rounded-xl">
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
                    <tbody id="tabla-resumen-dashboard" class="divide-y divide-slate-700/50">
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
                if (res.ok) { targetListName = nombre; return; }
            } catch (e) { }
        }
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
            let plantaA = (a.PlantaDescarga || '').toLowerCase();
            let plantaB = (b.PlantaDescarga || '').toLowerCase();
            if (plantaA < plantaB) return -1;
            if (plantaA > plantaB) return 1;

            let fechaA = a.field_6 || '';
            let fechaB = b.field_6 || '';
            if (fechaA < fechaB) return -1;
            if (fechaA > fechaB) return 1;

            let estA = String(a.field_7 || 'pendiente').toLowerCase().trim();
            let estB = String(b.field_7 || 'pendiente').toLowerCase().trim();
            let pA = prioridadEst[estA] || 99;
            let pB = prioridadEst[estB] || 99;
            if (pA < pB) return -1;
            if (pA > pB) return 1;

            return 0;
        });
    }

    async function ejecutarTransaccion(itemId, payload, msg, skipRefresh = false) {
        logETLStep(3, false);
        try {
            const digest = await getDigest();
            const query = itemId ? `items(${itemId})` : `items`;
            const options = {
                method: 'POST',
                headers: { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest },
                body: JSON.stringify(payload)
            };
            if(itemId) { options.headers["X-HTTP-Method"] = "MERGE"; options.headers["If-Match"] = "*"; }

            let res = await fetchSharePoint(query, options);
            if (res.status === 400) {
                delete payload.Patente; delete payload.HoraIngresoReal; delete payload.HoraSalidaReal; delete payload.EsSobreturno;
                options.body = JSON.stringify(payload);
                res = await fetchSharePoint(query, options);
            }
            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error("Falla API " + res.status);
            
            logETLStep(3, true); showToast(msg, "ok");
            generarLogArchivoSP("Transaccion_Turno", msg); 
            sincronizarListFormSilencioso();
            if(!skipRefresh) await cargarTurnos(); generarResumenDiario(); 
        } catch(e) {
            logLog(`[ERROR ESCRITURA SP]: ${e.message}`);
            showToast("Simulacion Local", "err");
            if(itemId) { let obj = listaTurnosCache.find(x=>x.Id==itemId); if(obj) Object.assign(obj, payload); }
            else listaTurnosCache.unshift({...payload, Id: Math.floor(Math.random()*1000)});
            
            ordenarEstructuralmenteBase(listaTurnosCache); 
            aplicarFiltrosMonitor(); calcularDisponibilidadOffline(); generarResumenDiario(); renderizarResumenCapacidad();
        }
    }

    // Sincroniza un CSV a SharePoint y actualiza el estado visual del panel ETL.
    async function sincronizarCSVConFeedback(tipo) {
        let statusId, label, cache;
        if (tipo === 'prov') { statusId = 'sync-status-prov'; label = 'Proveedores'; cache = listaProveedoresCache; }
        else if (tipo === 'usu') { statusId = 'sync-status-usu'; label = 'Usuarios'; cache = listaUsuariosCache; }
        else if (tipo === 'zonas') { statusId = 'sync-status-zonas'; label = 'Zonas'; cache = listaZonasCache; }

        if (cache.length === 0) {
            setETLStatus(statusId, 'Sin registros en memoria para sincronizar.', 'err');
            return;
        }
        setETLStatus(statusId, `Subiendo ${cache.length} registros...`, 'busy');
        try {
            await actualizarCSVSharePoint(tipo);
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus(statusId, `OK -- ${cache.length} registros sincronizados a las ${ahora}`, 'ok');
            logLog(`[ETL CSV] ${label}.csv subido exitosamente.`);
        } catch(e) {
            setETLStatus(statusId, `Error: ${e.message}`, 'err');
            logLog(`[ERROR CSV SP]: ${e.message}`);
        }
    }

    // Helper de estado visual para cualquier tarjeta ETL
    function setETLStatus(id, texto, tipo) {
        const el = document.getElementById(id);
        if(!el) return;
        el.textContent = texto;
        el.className = `text-xs mt-1.5 font-semibold ${
            tipo === 'ok'   ? 'text-emerald-400' :
            tipo === 'err'  ? 'text-rose-400'    :
            tipo === 'busy' ? 'text-sky-400 animate-pulse' : 'text-slate-500'
        }`;
    }

    async function sincronizarFlotaConFeedback() {
        setETLStatus('sync-status-flota', 'Leyendo Flota.csv desde SharePoint...', 'busy');
        try {
            await cargarFlotaSP();
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-flota', `OK -- ${listaFlotaCache.length} vehiculos desde Flota.csv a las ${ahora}`, 'ok');
        } catch(e) {
            setETLStatus('sync-status-flota', `Error: ${e.message}`, 'err');
        }
    }

    async function sincronizarZonasConFeedback() {
        setETLStatus('sync-status-zonas', 'Leyendo Zonas.csv desde SharePoint...', 'busy');
        try {
            await cargarZonasSP();
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-zonas', `OK -- ${listaZonasCache.length} zonas desde Zonas.csv a las ${ahora}`, 'ok');
        } catch(e) {
            setETLStatus('sync-status-zonas', `Error: ${e.message}`, 'err');
        }
    }

    async function sincronizarTurnosConFeedback() {
        setETLStatus('sync-status-turnos', 'Consultando SharePoint...', 'busy');
        try {
            await cargarTurnos();
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-turnos', `OK -- ${listaTurnosCache.length} turnos a las ${ahora}`, 'ok');
        } catch(e) {
            setETLStatus('sync-status-turnos', `Error: ${e.message}`, 'err');
        }
    }

    // Sincroniza todo en secuencia con feedback por entidad
    async function sincronizarTodo() {
        await sincronizarCSVConFeedback('prov');
        await sincronizarCSVConFeedback('usu');
        await sincronizarFlotaConFeedback();
        await sincronizarZonasConFeedback();
        await sincronizarTurnosConFeedback();
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
                const headerCols = flotaHeaderCols.length ? flotaHeaderCols : [
                    'Código del Vehículo','Descripción','Nombre','Apellido','Correo','Celular','Capacidad 1','Capacidad 2','Capacidad 3','Detalle','Tipo Dispositivo','Número Dispositivo','Etiqueta Costos','Flotas','Empleador','Tipo Vehículo','DNI','Última latitud','Última longitud'
                ];
                const escapeCsv = (v) => `"${String(v ?? '').replace(/"/g, '""')}"`;
                csvContent += headerCols.map(escapeCsv).join(',') + "\n";
                listaFlotaCache.forEach(v => {
                    const row = Array.isArray(v.raw) ? [...v.raw] : Array(headerCols.length).fill('');
                    while (row.length < headerCols.length) row.push('');
                    const partes = splitChofer(v.chofer || '');
                    row[0]  = (v.patente || '').trim();
                    row[2]  = partes.nombre || row[2] || '';
                    row[3]  = partes.apellido || row[3] || '';
                    row[14] = v.empresa || row[14] || '';
                    row[15] = v.tipo || row[15] || '';
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
                folderName = 'Shared Documents';
                url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folderName}')/Files/add(url='${fileName}',overwrite=true)`;
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

            // Mapa de secciones a funciones de limpieza/init
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

                    // Resaltar el boton activo (incluyendo sub-items)
                    btns.forEach(b => b.classList.remove('active-tab'));
                    btn.classList.add('active-tab');

                    // Mostrar la seccion destino
                    contents.forEach(c => { c.classList.remove('active'); c.style.display = 'none'; });
                    const targetEl = document.getElementById(target);
                    if(targetEl) { targetEl.classList.add('active'); targetEl.style.display = 'block'; }

                    // Ejecutar callback de limpieza/init de la seccion
                    if(seccionCallbacks[target]) {
                        try { seccionCallbacks[target](); } catch(e) {}
                    }
                });
            });
        } catch(e) {}
    }
    setupRuteo();

    let listaTurnosCache = [];
    let listaUsuariosCache = [];
    let listaProveedoresCache = [];
    let listaFlotaCache = [];
    let listaFlotaRawRows = [];
    let flotaSchemaLine = '';
    let flotaHeaderCols = [];

    let listaZonasCache = [];
    let capacidadPorPlantaTipoCache = [];
    let capacidadPorPlantaIndex = {};

    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Local", email: "logistica@grupocanuelas.com" };
    let _modalProvAbierto = false; 
    
    const ORDEN_TIPOS = ['INSUMOS', 'PACKAGING', 'NO_PRODUCTIVO'];
    const TIPOS_ZONA_CALCULO = ['INSUMOS', 'PACKAGING', 'NO_PRODUCTIVO'];

    // Funciones Helper Console
    function terminalLog(msg) {
        const d = document.getElementById('splash-log'); 
        if(d) { 
            d.insertAdjacentHTML('beforeend', `<div><span class="text-slate-500">[${new Date().toLocaleTimeString()}]</span> ${msg}</div>`);
            d.scrollTop = d.scrollHeight; 
        } 
    }

    // --- ARRANQUE Y AUTO-SINCRONIZACION ---
    async function initApp() {
        try {
            terminalLog("=====================================");
            terminalLog("Inicializando Core ERP Logistico...");
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.getFullYear() + "-" + String(hoy.getMonth() + 1).padStart(2, '0') + "-" + String(hoy.getDate()).padStart(2, '0');
            
            cargarSelectPlantasFisicas();
            renderizarABMHorarios();
            renderizarGrilaCalendario();
            await cargarCapacidadTurnosCSV();
            
            terminalLog("Obteniendo credenciales de usuario...");
            await testConexion();
            terminalLog(`Usuario conectado: ${currentLoggedUser.name} [OK]`);

            await resolverNombreListaTurnos();
            limpiarFormularioProveedor(); // Autocompleta el User Logueado
            
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
            
            setTimeout(() => {
                document.getElementById('splash-screen').classList.add('hidden-splash');
            }, 1500);

        } catch (err) { 
            terminalLog(`<span class="text-rose-400 font-bold">[FALLA CRITICA INIT]: ${err.message}</span>`); 
        }
    }

    function normalizarTipoCarga(valor) {
        const v = String(valor || '').trim().toUpperCase();
        if (!v) return '';
        if (v === 'NO PRODUCTIVO' || v === 'NO-PRODUCTIVO') return 'NO_PRODUCTIVO';
        return v.replace(/\s+/g, '_');
    }

    function normalizarTipoZona(valor) {
        return normalizarTipoCarga(valor);
    }

    function parseCsvFlexible(text) {
        const limpio = String(text || '').replace(/^\uFEFF/, '').replace(/^﻿/, '');
        const lines = limpio.split(/\r?\n|\r/).filter(l => l.trim() !== '');
        if (!lines.length) return [];
        const firstLine = lines[0];
        const sep = firstLine.includes(';') ? ';' : ',';
        const normalizeHeader = h => String(h || '').replace(/^\uFEFF/, '').replace(/^﻿/, '').replace(/^"+|"+$/g, '').trim();
        const headers = firstLine.split(sep).map(normalizeHeader);
        return lines.slice(1).map(line => {
            const cols = line.split(sep).map(v => String(v || '').replace(/^"+|"+$/g, '').trim());
            const row = {};
            headers.forEach((h, i) => row[h] = cols[i] || '');
            return row;
        });
    }

    function normalizeHeaderName(v) {
        return String(v || '').replace(/^\uFEFF/, '').replace(/^﻿/, '').replace(/^"+|"+$/g, '').trim().toUpperCase();
    }

    function toNum(v, dec = 2) {
        const n = Number(String(v ?? '').replace(',', '.'));
        if (!Number.isFinite(n)) return 0;
        return Number(n.toFixed(dec));
    }

    function fmtNum(v, dec = 0) {
        const n = Number(v);
        if (!Number.isFinite(n)) return '-';
        return dec === 0 ? String(Math.floor(n)) : String(Number(n.toFixed(dec)));
    }

    function actualizarEstadoCSVVisual(tipo, titulo, detalle) {
        const box = document.getElementById('csv-capacidad-status');
        if (!box) return;
        box.className = `csv-status ${tipo}`;
        box.innerHTML = `<div class="csv-title">${escapeHtml(titulo)}</div><div class="csv-detail">${escapeHtml(detalle)}</div>`;
    }

    function construirIndiceCapacidad() {
        const idx = {};
        capacidadPorPlantaTipoCache.forEach(r => {
            const planta = String(r.Planta || '').trim();
            const tipo = normalizarTipoCarga(r.Tipo_Carga);
            if (!planta || !tipo) return;
            if (!idx[planta]) idx[planta] = { tipos: {}, resumen: null, filas: [] };
            idx[planta].tipos[tipo] = r;
            idx[planta].filas.push(r);
            if (!idx[planta].resumen) idx[planta].resumen = { Planta: planta };
        });
        Object.values(idx).forEach(g => recomputarResumenGrupo(g));
        capacidadPorPlantaIndex = idx;
    }

    function recomputarResumenGrupo(g) {
        const filas = (g?.filas || []);
        if (!filas.length) return;
        const base = filas[0];
        g.resumen = {
            Planta: base.Planta,
            Turnos_Calc: filas.length ? Math.max(...filas.map(r => toNum(r.Turnos_Calc, 2))) : 0,
            Turnos_Sabado: filas.length ? Math.max(...filas.map(r => toNum(r.Turnos_Sabado, 2))) : 0,
            Min_LV: filas.length ? Math.max(...filas.map(r => toNum(r.Min_LV, 2))) : 0,
            Min_SAB: filas.length ? Math.max(...filas.map(r => toNum(r.Min_SAB, 2))) : 0,
            Minutos_Turno: filas.length ? Math.max(...filas.map(r => toNum(r.Minutos_Turno, 2))) : 0,
            TotalDia: filas.length ? Math.max(...filas.map(r => toNum(r.TotalDia, 2))) : 0,
            Estatus: base.Estatus || 'OK'
        };
    }

    function refreshCapacidadFromCache(preserveExpanded = true) {
        construirIndiceCapacidad();
        convertirConfigDesdeCSV();
        cargarSelectPlantasFisicas();
        renderizarABMHorarios(preserveExpanded);
        renderizarResumenCapacidad();
        calcularDisponibilidadOffline();
        generarResumenDiario();
        if (document.getElementById('s10')?.classList.contains('active')) updateDashboard();
    }

    function convertirConfigDesdeCSV() {
        if (!capacidadPorPlantaTipoCache.length) return;
        const baseMap = new Map((configPlantas || []).map(p => [p.id, { ...p }]));
        Object.values(capacidadPorPlantaIndex).forEach(g => {
            const r = g.resumen || {};
            const planta = String(r.Planta || '').trim();
            if (!planta) return;
            const base = baseMap.get(planta) || { id: planta, hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false };
            const minS = toNum(r.Min_SAB, 2);
            const minutosTurno = toNum(r.Minutos_Turno, 2) || base.duracion || 1;
            baseMap.set(planta, {
                id: planta,
                hInLV: base.hInLV,
                hOutLV: base.hOutLV,
                hInS: base.hInS,
                hOutS: base.hOutS,
                duracion: minutosTurno,
                sabado: minS > 0,
                totalDiaLV: toNum(r.TotalDia, 2),
                totalSabado: toNum(r.Turnos_Sabado, 2)
            });
        });
        configPlantas = Array.from(baseMap.values());
    }

    function collectCapacidadRowsFromDom() {
        const rows = Array.from(document.querySelectorAll('tr.cap-child-row'));
        if (!rows.length) return capacidadPorPlantaTipoCache;
        return rows.map(tr => ({
            Planta: tr.dataset.planta || '',
            Tipo_Carga: tr.dataset.tipo || '',
            Habilitado: Number(tr.querySelector('[data-field="Habilitado"]')?.value || 0),
            Turnos_Cargados: toNum(tr.querySelector('[data-field="Turnos_Cargados"]')?.value, 2),
            Turnos_Calc: toNum(tr.querySelector('[data-field="Turnos_Calc"]')?.value, 2),
            Turnos_Sabado: toNum(tr.querySelector('[data-field="Turnos_Sabado"]')?.value, 2),
            Min_LV: toNum(tr.querySelector('[data-field="Min_LV"]')?.value, 2),
            Min_SAB: toNum(tr.querySelector('[data-field="Min_SAB"]')?.value, 2),
            Minutos_Turno: toNum(tr.querySelector('[data-field="Minutos_Turno"]')?.value, 2),
            TotalDia: toNum(tr.querySelector('[data-field="TotalDia"]')?.value, 2),
            Estatus: String(tr.querySelector('[data-field="Estatus"]')?.value || 'OK').trim()
        }));
    }

    function serializeCapacidadCsv(rows) {
        const bom = '\uFEFF';
        const headers = ['Planta','Tipo_Carga','Habilitado','Turnos_Cargados','Turnos_Calc','Turnos_Sabado','Min_LV','Min_SAB','Minutos_Turno','TotalDia','Estatus'];
        let csv = bom + headers.join(';') + '\n';
        rows.forEach(r => {
            csv += [r.Planta,r.Tipo_Carga,r.Habilitado,r.Turnos_Cargados,r.Turnos_Calc,r.Turnos_Sabado,r.Min_LV,r.Min_SAB,r.Minutos_Turno,r.TotalDia,r.Estatus].join(';') + '\n';
        });
        return csv;
    }

    async function guardarCapacidadCSVSharePoint(rows) {
        const digest = await getDigest();
        const csvContent = serializeCapacidadCsv(rows);
        let folder = 'Documentos compartidos';
        let url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folder}')/Files/add(url='capacidad_turnos_por_planta.csv',overwrite=true)`;
        let res = await fetch(url, { method: 'POST', headers: { 'X-RequestDigest': digest }, body: csvContent });
        if (!res.ok) {
            folder = 'Shared Documents';
            url = `${relativeSiteUrl}/_api/web/GetFolderByServerRelativeUrl('${relativeSiteUrl}/${folder}')/Files/add(url='capacidad_turnos_por_planta.csv',overwrite=true)`;
            res = await fetch(url, { method: 'POST', headers: { 'X-RequestDigest': digest }, body: csvContent });
        }
        if (!res.ok) throw new Error(`No se pudo escribir capacidad_turnos_por_planta.csv. HTTP ${res.status}`);
        return true;
    }

    async function cargarCapacidadTurnosCSV() {
        try {
            actualizarEstadoCSVVisual('warn', 'Validación CSV', 'Leyendo capacidad_turnos_por_planta.csv...');
            const urlPrimaria = `${relativeSiteUrl}/_api/web/GetFileByServerRelativeUrl('${CAPACIDAD_CSV_SERVER_RELATIVE_URL}')/$value`;
            let res = await fetch(urlPrimaria, { headers: { 'Accept': 'text/plain' } });
            let rutaUsada = CAPACIDAD_CSV_SERVER_RELATIVE_URL;
            if (!res.ok) {
                const alt = CAPACIDAD_CSV_SERVER_RELATIVE_URL.replace('/Documentos compartidos/', '/Shared Documents/');
                const altUrl = `${relativeSiteUrl}/_api/web/GetFileByServerRelativeUrl('${alt}')/$value`;
                res = await fetch(altUrl, { headers: { 'Accept': 'text/plain' } });
                rutaUsada = alt;
            }
            if (!res.ok) throw new Error(`Archivo no encontrado o no accesible. HTTP ${res.status}`);
            const raw = await res.text();
            const trimmed = raw.trim();
            if (trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html')) throw new Error('La URL devolvió HTML en lugar del contenido del CSV');
            const rows = parseCsvFlexible(raw);
            if (!rows.length) {
                actualizarEstadoCSVVisual('warn', 'CSV vacío', 'El archivo fue leído pero no contiene filas útiles o está vacío.');
                capacidadPorPlantaTipoCache = [];
                capacidadPorPlantaIndex = {};
                renderizarABMHorarios();
                return [];
            }
            const headersRaw = Object.keys(rows[0] || {});
            const headers = headersRaw.map(normalizeHeaderName);
            const required = ['PLANTA','TIPO_CARGA'];
            const faltantes = required.filter(c => !headers.includes(c));
            if (faltantes.length) throw new Error(`Faltan columnas obligatorias en CSV: ${faltantes.join(', ')}`);
            const parsed = rows.map(r => {
                const planta = r.Planta ?? r.PLANTA ?? '';
                const tipo = r.Tipo_Carga ?? r.TIPO_CARGA ?? '';
                return {
                    Planta: String(planta || '').trim(),
                    Tipo_Carga: normalizarTipoCarga(tipo),
                    Habilitado: toNum(r.Habilitado, 0),
                    Turnos_Cargados: toNum(r.Turnos_Cargados, 2),
                    Turnos_Calc: toNum(r.Turnos_Calc, 2),
                    Turnos_Sabado: toNum(r.Turnos_Sabado, 2),
                    Min_LV: toNum(r.Min_LV, 2),
                    Min_SAB: toNum(r.Min_SAB, 2),
                    Minutos_Turno: toNum(r.Minutos_Turno, 2),
                    TotalDia: toNum(r.TotalDia, 2),
                    Estatus: String(r.Estatus || 'OK').trim()
                };
            }).filter(r => r.Planta && r.Tipo_Carga);
            capacidadPorPlantaTipoCache = parsed;
            refreshCapacidadFromCache(false)
            actualizarEstadoCSVVisual('ok', 'CSV válido', `Ruta: ${rutaUsada} | Registros: ${parsed.length} | Columnas: ${headersRaw.join(', ')}`);
            return parsed;
        } catch (e) {
            const detalle = e && e.message ? e.message : 'Error no identificado al leer el CSV.';
            actualizarEstadoCSVVisual('err', 'CSV inválido o inaccesible', detalle);
            capacidadPorPlantaTipoCache = [];
            capacidadPorPlantaIndex = {};
            renderizarABMHorarios();
            return [];
        }
    }

    function toggleDetalleCapacidad(plantaKey) {
        const rows = Array.from(document.querySelectorAll('tr[data-parent-planta]')).filter(r => r.getAttribute('data-parent-planta') === plantaKey);
        const icon = Array.from(document.querySelectorAll('[data-expander-planta]')).find(el => el.getAttribute('data-expander-planta') === plantaKey);
        if (!rows.length) return;
        const expanded = rows.every(r => !r.classList.contains('hidden-row'));
        rows.forEach(r => r.classList.toggle('hidden-row', expanded));
        if (icon) {
            icon.textContent = expanded ? '+' : '−';
            if (expanded) icon.classList.remove('open'); else icon.classList.add('open');
        }
    }

    function resetSelectConGuion(selectEl, label) {
        if (!selectEl) return;
        const guion = label || '-';
        selectEl.innerHTML = `<option value="">${guion}</option>`;
    }

    function asegurarOptionSelect(selectEl, valor, texto) {
        if (!selectEl || !valor) return;
        if (!Array.from(selectEl.options).some(o => o.value === valor)) {
            selectEl.add(new Option(texto || valor, valor));
        }
        selectEl.value = valor;
    }

    function poblarSelectZonasPorPlanta(plantaFisica, valorSeleccionado) {
        const sel = document.getElementById('f_planta');
        if (!sel) return;
        resetSelectConGuion(sel);
        if (!plantaFisica) return;
        const zonas = listaZonasCache.filter(z =>
            z.estado !== 'Inactivo' &&
            String(z.planta).toLowerCase() === String(plantaFisica).toLowerCase()
        );
        if (zonas.length === 0) {
            TIPOS_ZONA_CALCULO.forEach(t => sel.add(new Option(t, t)));
        } else {
            zonas.forEach(z => {
                const label = z.nombre || z.tipo;
                const val = z.tipo || z.nombre;
                if (val && !Array.from(sel.options).some(o => o.value === val)) {
                    sel.add(new Option(label, val));
                }
            });
        }
        if (valorSeleccionado) asegurarOptionSelect(sel, valorSeleccionado);
        else sel.selectedIndex = 0;
    }

    function onPlantaFisicaChange() {
        const pf = document.getElementById('f_planta_descarga')?.value || '';
        poblarSelectZonasPorPlanta(pf, '');
        handleHorariosChange();
    }

    function calcularTurnosTeoricos(plantaConfig, esSabado) {
        if (!plantaConfig || !plantaConfig.duracion) return 0;
        if (esSabado && !plantaConfig.sabado) return 0;
        const hIn = esSabado ? plantaConfig.hInS : plantaConfig.hInLV;
        const hOut = esSabado ? plantaConfig.hOutS : plantaConfig.hOutLV;
        if (hOut <= hIn) return 0;
        return Math.floor(((hOut - hIn) * 60) / plantaConfig.duracion);
    }

    function contarZonasActivasPorTipo(plantaId, tipo) {
        const activas = listaZonasCache.filter(z =>
            z.estado !== 'Inactivo' &&
            String(z.planta).toLowerCase() === String(plantaId).toLowerCase() &&
            String(z.tipo).toLowerCase() === String(tipo).toLowerCase()
        );
        if (activas.length === 0) return 1;
        return activas.reduce((sum, z) => sum + (parseInt(z.capacidad, 10) > 0 ? parseInt(z.capacidad, 10) : 1), 0);
    }

    function calcularCapacidadPlantaPorTipo(plantaConfig, esSabado) {
        const idx = capacidadPorPlantaIndex[plantaConfig.id] || null;
        const resumen = idx?.resumen || null;
        const slots = resumen ? (esSabado ? toNum(resumen.Turnos_Sabado, 2) : toNum(resumen.TotalDia || resumen.Turnos_Calc, 2)) : calcularTurnosTeoricos(plantaConfig, esSabado);
        const res = {};
        const total = slots;
        TIPOS_ZONA_CALCULO.forEach(tipo => {
            const reg = idx?.tipos?.[tipo];
            let cap = 0;
            if (reg && reg.Habilitado === 1) cap = esSabado ? toNum(reg.Turnos_Sabado, 2) : toNum(reg.Turnos_Cargados || reg.TotalDia || reg.Turnos_Calc, 2);
            else if (!reg) cap = slots;
            res[tipo] = cap;
        });
        return { slots, porTipo: res, total };
    }

    function esSabadoFecha(fechaStr) {
        if (!fechaStr) return false;
        const d = new Date(fechaStr.replace(/-/g, '/') + ' 00:00:00');
        return d.getDay() === 6;
    }

    function renderizarResumenCapacidad() {
        const panel = document.getElementById('panel-resumen-capacidad');
        if (!panel) return;
        const pfFiltro = document.getElementById('filtro_planta_descarga')?.value || 'TODAS';
        const esSab = esSabadoFecha(fechaSeleccionadaGlobal);
        let html = `<div class="text-[9px] uppercase text-slate-500 font-bold mb-1 text-center">Capacidad ${fechaSeleccionadaGlobal}${esSab ? ' (Sab)' : ' (LV)'}</div>`;
        let hayDatos = false;
        configPlantas.forEach(p => {
            if (pfFiltro !== 'TODAS' && p.id !== pfFiltro) return;
            const cap = calcularCapacidadPlantaPorTipo(p, esSab);
            if (cap.slots === 0) return;
            hayDatos = true;
            TIPOS_ZONA_CALCULO.forEach(tipo => {
                const teo = cap.porTipo[tipo] || 0;
                if (teo === 0) return;
                const ocup = listaTurnosCache.filter(t => t.field_6 && String(t.field_6).startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === p.id && normalizarTipoZona(t.Planta) === normalizarTipoCarga(tipo) && !['cancelado', 'rechazado'].includes(String(t.field_7 || '').toLowerCase())).length;
                const disp = Math.max(0, teo - ocup);
                html += `<div class="flex justify-between gap-1 py-0.5 border-b border-slate-800/50"><span class="text-sky-300 truncate">${escapeHtml(p.id)} / ${escapeHtml(tipo)}</span><span class="text-slate-400 shrink-0">${fmtNum(teo, 0)}|${ocup}|<span class="text-emerald-400 font-bold">${fmtNum(disp, 0)}</span></span></div>`;
            });
        });
        panel.innerHTML = hayDatos ? html : '<div class="text-center text-slate-500 text-[10px] py-2">Sin capacidad configurada.</div>';
    }

    function actualizarDatalistFlota() {
        const dl = document.getElementById('dl_flota_patentes');
        if (!dl) return;
        dl.innerHTML = listaFlotaCache
            .filter(v => v.estado === 'Habilitado')
            .map(v => `<option value="${escapeHtml(v.patente)}">`)
            .join('');
    }

    async function syncFlotaABM() {
        await cargarFlotaSP();
        actualizarDatalistFlota();
        showToast(`Flota sincronizada: ${listaFlotaCache.length} vehiculos.`, 'ok');
    }

    function autocompletarPatenteFlota() {
        const pat = document.getElementById('f_patente')?.value.trim().toUpperCase();
        if (!pat) return;
        document.getElementById('f_patente').value = pat;
        const v = listaFlotaCache.find(x => String(x.patente).toUpperCase() === pat);
        if (v && v.empresa && !document.getElementById('f_proveedor').value) {
            showToast(`Patente ${pat} encontrada en flota (${v.empresa}).`, 'ok');
        }
    }

    let configPlantas = [
        { id: "Parque Canuelas", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false },
        { id: "Predio Canuelas", hInLV: 10, hOutLV: 17, hInS: 7, hOutS: 11, duracion: 40, sabado: true },
        { id: "Spegazzini", hInLV: 8, hOutLV: 16, hInS: 8, hOutS: 12, duracion: 45, sabado: true },
        { id: "Almar", hInLV: 7, hOutLV: 14, hInS: 7, hOutS: 11, duracion: 30, sabado: true },
        { id: "Metro Mataderos", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false }
    ];

    function escapeHtml(unsafe) {
        if(!unsafe) return "";
        return String(unsafe).replace(/[&<"'>]/g, function(match) {
            const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
            return map[match];
        });
    }

    function toggleMenuConfig() {
        const sub = document.getElementById('submenu-config');
        const icon = document.getElementById('icon-menu-config');
        const abierto = !sub.classList.contains('hidden');
        sub.classList.toggle('hidden', abierto);
        icon.textContent = abierto ? '\u25B6' : '\u25BC';
        icon.className = 'text-red-500 text-sm font-bold';
    }

    function agregarNuevaPlanta() {
        const nombre = prompt('Nombre de la nueva Planta Fisica:');
        if(!nombre || !nombre.trim()) return;
        if(configPlantas.find(p => p.id.toLowerCase() === nombre.trim().toLowerCase())) {
            return showToast('Ya existe una planta con ese nombre.', 'err');
        }
        configPlantas.push({ id: nombre.trim(), hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false });
        renderizarABMHorarios();
        cargarSelectPlantasFisicas();
        showToast(`Planta "${nombre.trim()}" agregada. Guarda la configuracion para aplicar.`, 'ok');
    }

    function parseCsvLineSeguro(linea) {
        const out = [];
        let cur = '';
        let inQuotes = false;
        for (let i = 0; i < linea.length; i++) {
            const ch = linea[i];
            if (ch === '"') {
                if (inQuotes && linea[i + 1] === '"') { cur += '"'; i++; }
                else inQuotes = !inQuotes;
            } else if (ch === ',' && !inQuotes) {
                out.push(cur);
                cur = '';
            } else {
                cur += ch;
            }
        }
        out.push(cur);
        return out.map(v => String(v || '').trim());
    }

    function mapearFilaFlota(cols) {
        const patente = String(cols[0] || '').trim().toUpperCase();
        const descripcion = String(cols[1] || '').trim();
        const nombre = String(cols[2] || '').trim();
        const apellido = String(cols[3] || '').trim();
        const correo = String(cols[4] || '').trim();
        const celular = String(cols[5] || '').trim();
        const capacidad1 = String(cols[6] || '').trim();
        const capacidad2 = String(cols[7] || '').trim();
        const capacidad3 = String(cols[8] || '').trim();
        const detalle = String(cols[9] || '').trim();
        const tipoDispositivo = String(cols[10] || '').trim();
        const numeroDispositivo = String(cols[11] || '').trim();
        const etiquetaCostos = String(cols[12] || '').trim();
        const flotas = String(cols[13] || '').trim();
        const empresa = String(cols[14] || '').trim();
        const tipo = String(cols[15] || '').trim();
        const dni = String(cols[16] || '').trim();
        const ultimaLatitud = String(cols[17] || '').trim();
        const ultimaLongitud = String(cols[18] || '').trim();
        const chofer = [apellido, nombre].filter(Boolean).join(' ').trim();
        return {
            spId: null,
            patente,
            tipo,
            empresa,
            cuit: '',
            chofer,
            estado: patente ? 'Habilitado' : 'Deshabilitado',
            descripcion,
            nombre,
            apellido,
            correo,
            celular,
            capacidad1,
            capacidad2,
            capacidad3,
            detalle,
            tipoDispositivo,
            numeroDispositivo,
            etiquetaCostos,
            flotas,
            dni,
            ultimaLatitud,
            ultimaLongitud,
            raw: cols
        };
    }

    function parsearCSVFlota(text) {
        const lines = text.split(/\r?\n|\r/).filter(l => l !== '');
        flotaSchemaLine = '';
        flotaHeaderCols = [];
        listaFlotaRawRows = [];
        if (!lines.length) {
            listaFlotaCache = [];
            renderizarBaseFlota();
            actualizarDatalistFlota();
            return;
        }
        let idxHeader = 0;
        if (String(lines[0] || '').startsWith('ListSchema=')) {
            flotaSchemaLine = lines[0].replace(/^\uFEFF/, '');
            idxHeader = 1;
        }
        const headerLine = (lines[idxHeader] || '').replace(/^\uFEFF/, '');
        flotaHeaderCols = parseCsvLineSeguro(headerLine);
        const rows = [];
        for (let i = idxHeader + 1; i < lines.length; i++) {
            const cols = parseCsvLineSeguro(lines[i]);
            if (!cols.length) continue;
            const item = mapearFilaFlota(cols);
            if (!item.patente) continue;
            rows.push(item);
        }
        listaFlotaCache = rows;
        listaFlotaRawRows = rows.map(r => r.raw);
        renderizarBaseFlota();
        actualizarDatalistFlota();
    }

    async function cargarFlotaSP() {
        try {
            await importarCSVSharePoint('flota', true);
        } catch(e) {
            renderizarBaseFlota();
        }
    }

    function renderizarBaseFlota() {
        const tbody = document.getElementById('tabla-flota');
        if(!tbody) return;
        if(listaFlotaCache.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="p-6 text-center text-slate-500 text-sm">Sin vehiculos cargados desde Flota.csv.</td></tr>';
            return;
        }
        tbody.innerHTML = listaFlotaCache.map((v, i) => `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarFlotaForm(${i})">
                <td class="py-3 px-3 font-bold text-amber-300">${escapeHtml(v.patente)}</td>
                <td class="px-3 text-slate-300">${escapeHtml(v.tipo || v.descripcion || '-')}</td>
                <td class="px-3 text-white font-semibold">${escapeHtml(v.empresa || v.flotas || '-')}</td>
                <td class="px-3 text-slate-400 text-xs">${escapeHtml(v.cuit || '-')}</td>
                <td class="px-3 text-slate-300 text-xs">${escapeHtml(v.chofer || '-')}</td>
                <td class="px-3 font-bold ${v.estado==='Habilitado'?'text-emerald-400':v.estado==='Vencido'?'text-amber-400':'text-rose-400'}">${escapeHtml(v.estado)}</td>
                <td class="px-3 text-center"><button class="text-sky-400 text-xs hover:underline font-bold">Editar</button></td>
            </tr>`).join('');
    }

    function splitChofer(choferStr) {
        const s = String(choferStr || '').trim();
        if (!s) return { apellido: '', nombre: '' };
        const parts = s.split(/\s+/);
        if (parts.length === 1) return { apellido: parts[0], nombre: '' };
        return { apellido: parts[0], nombre: parts.slice(1).join(' ') };
    }

    function cargarFlotaForm(idx) {
        const v = listaFlotaCache[idx];
        const ch = splitChofer(v.chofer);
        document.getElementById('fl_item_id').value = idx;
        document.getElementById('fl_patente').value = v.patente || '';
        document.getElementById('fl_tipo').value    = v.tipo || '';
        document.getElementById('fl_empresa').value = v.empresa || '';
        document.getElementById('fl_cuit').value    = v.cuit || '';
        document.getElementById('fl_apellido').value = ch.apellido;
        document.getElementById('fl_nombre').value   = ch.nombre;
        document.getElementById('fl_estado').value  = v.estado || '';
        
        const btnElim = document.getElementById('btn_elim_flota');
        if(btnElim) btnElim.classList.remove('hidden');
    }

    function limpiarFormularioFlota() {
        document.getElementById('fl_item_id').value = '';
        ['fl_patente','fl_empresa','fl_cuit','fl_apellido','fl_nombre'].forEach(id => document.getElementById(id).value = '');
        document.getElementById('fl_tipo').value   = '';
        document.getElementById('fl_estado').value = '';
        
        const btnElim = document.getElementById('btn_elim_flota');
        if(btnElim) btnElim.classList.add('hidden');
    }

    async function guardarEdicionFlota() {
        const pat = document.getElementById('fl_patente').value.trim().toUpperCase();
        if(!pat) return showToast('Patente requerida.', 'err');
        const tipo = document.getElementById('fl_tipo').value;
        const estado = document.getElementById('fl_estado').value;
        if(!tipo) return showToast("Debe seleccionar un Tipo", "err");
        if(!estado) return showToast("Debe seleccionar un Estado", "err");

        const idx = document.getElementById('fl_item_id').value;
        const apellido = document.getElementById('fl_apellido').value.trim();
        const nombre   = document.getElementById('fl_nombre').value.trim();
        const chofer   = [apellido, nombre].filter(Boolean).join(' ');
        
        const existente = idx !== '' && listaFlotaCache[parseInt(idx,10)] ? listaFlotaCache[parseInt(idx,10)] : listaFlotaCache.find(v => v.patente === pat);
        const headerLen = flotaHeaderCols.length || 19;
        const raw = existente && Array.isArray(existente.raw) ? [...existente.raw] : Array(headerLen).fill('');
        while (raw.length < headerLen) raw.push('');
        raw[0] = pat;
        raw[2] = nombre;
        raw[3] = apellido;
        raw[14] = document.getElementById('fl_empresa').value.trim();
        raw[15] = tipo;
        
        const obj = mapearFilaFlota(raw);
        obj.cuit = document.getElementById('fl_cuit').value.replace(/[^0-9\-]/g,'');
        obj.estado = estado;
        obj.chofer = chofer;
        
        if (idx !== '' && listaFlotaCache[parseInt(idx,10)]) listaFlotaCache[parseInt(idx,10)] = obj;
        else if (!existente) listaFlotaCache.push(obj);
        else {
            const pos = listaFlotaCache.findIndex(v => v.patente === pat);
            if (pos >= 0) listaFlotaCache[pos] = obj;
        }
        
        renderizarBaseFlota();
        actualizarDatalistFlota();
        limpiarFormularioFlota();
        showToast('Vehiculo guardado en memoria. Sincronizando Flota.csv...', 'ok');
        await actualizarCSVSharePoint('flota');
    }

    async function eliminarFlota() {
        const idx = document.getElementById('fl_item_id').value;
        if(idx === '') return;
        if(!confirm('¿Esta seguro de eliminar este vehiculo?')) return;
        listaFlotaCache.splice(idx, 1);
        renderizarBaseFlota();
        actualizarDatalistFlota();
        limpiarFormularioFlota();
        showToast('Vehiculo eliminado. Sincronizando Flota.csv...', 'ok');
        await actualizarCSVSharePoint('flota');
    }

    // --- ZONAS DE DESCARGA (AHORA COMO CSV) ---
    function parsearCSVZonas(text) {
        const lines = text.split(/\r?\n|\r/).filter(l => l.trim() !== '');
        listaZonasCache = [];
        for(let i=1; i<lines.length; i++) {
            const row = lines[i].trim();
            if(!row) continue;
            const cols = row.split(';');
            if(cols.length >= 6) {
                listaZonasCache.push({
                    id: cols[0].trim(),
                    planta: cols[1].trim(),
                    nombre: cols[2].trim(),
                    tipo: cols[3].trim(),
                    capacidad: cols[4].trim(),
                    estado: cols[5].trim() || 'Activo'
                });
            }
        }
        renderizarBaseZonas();
    }

    async function cargarZonasSP() {
        try {
            await importarCSVSharePoint('zonas', true);
            poblarSelectsABMInicial();
        } catch(e) {
            renderizarBaseZonas();
        }
    }

    function renderizarBaseZonas() {
        const tb = document.getElementById('tabla-zonas');
        if(!tb) return;
        if(listaZonasCache.length === 0) {
            tb.innerHTML = '<tr><td colspan="6" class="p-6 text-center text-slate-500 text-sm">Sin zonas de descarga cargadas.</td></tr>';
            return;
        }
        tb.innerHTML = listaZonasCache.map((z, idx) => `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarZonaForm(${idx})">
                <td class="p-3 font-semibold text-amber-400">${escapeHtml(z.id)}</td>
                <td class="p-3 text-white font-semibold">${escapeHtml(z.planta)}</td>
                <td class="p-3 text-slate-400">${escapeHtml(z.nombre)}</td>
                <td class="p-3 text-slate-400">${escapeHtml(z.tipo)}</td>
                <td class="p-3 text-slate-400 text-center">${escapeHtml(z.capacidad)}</td>
                <td class="p-3 font-bold ${z.estado === 'Activo' || z.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(z.estado)}</td>
                <td class="p-3 text-sky-400 underline text-center">Editar</td>
            </tr>`).join('');
    }

    function cargarZonaForm(idx) {
        const z = listaZonasCache[idx];
        document.getElementById('z_index').value = idx;
        document.getElementById('z_id').value = z.id || '';
        document.getElementById('z_planta').value = z.planta || '';
        document.getElementById('z_nombre').value = z.nombre || '';
        document.getElementById('z_tipo').value = z.tipo || '';
        document.getElementById('z_capacidad').value = z.capacidad || '';
        document.getElementById('z_estado').value = z.estado || '';
        
        const btnElim = document.getElementById('btn_elim_zona');
        if(btnElim) btnElim.classList.remove('hidden');
    }

    function limpiarFormularioZona() {
        document.getElementById('z_index').value = '';
        document.getElementById('z_id').value = '';
        document.getElementById('z_nombre').value = '';
        document.getElementById('z_capacidad').value = '';
        if(document.getElementById('z_planta').options.length > 0) document.getElementById('z_planta').selectedIndex = 0;
        document.getElementById('z_tipo').value = '';
        document.getElementById('z_estado').value = '';
        
        const btnElim = document.getElementById('btn_elim_zona');
        if(btnElim) btnElim.classList.add('hidden');
    }

    async function guardarEdicionZona() {
        const idx = document.getElementById('z_index').value;
        const zId = document.getElementById('z_id').value.trim();
        const zPlanta = document.getElementById('z_planta').value;
        const zTipo = document.getElementById('z_tipo').value;
        const zEstado = document.getElementById('z_estado').value;
        const nombre = document.getElementById('z_nombre').value.trim();

        if(!zId && idx === '') return showToast("Falta ID Zona", "err");
        if(!nombre) return showToast("Falta Nombre de Zona", "err");
        if(!zPlanta) return showToast("Seleccione Planta Asociada", "err");
        if(!zTipo) return showToast("Seleccione Tipo de Insumo", "err");
        if(!zEstado) return showToast("Seleccione Estado", "err");

        const idFinal = zId || `Z-${Date.now()}`;
        const obj = { 
            id: idFinal, 
            planta: zPlanta, 
            nombre: nombre, 
            tipo: zTipo, 
            capacidad: document.getElementById('z_capacidad').value, 
            estado: zEstado 
        };

        if(idx === '') listaZonasCache.push(obj); 
        else listaZonasCache[idx] = obj;

        renderizarBaseZonas();
        limpiarFormularioZona();
        showToast("Zona guardada en memoria. Sincronizando Zonas.csv...", "ok");
        await actualizarCSVSharePoint('zonas');
        poblarSelectsABMInicial();
    }

    async function eliminarZona() {
        const idx = document.getElementById('z_index').value;
        if(idx === '') return;
        if(!confirm('¿Esta seguro de eliminar esta zona de descarga?')) return;
        listaZonasCache.splice(idx, 1);
        renderizarBaseZonas();
        limpiarFormularioZona();
        showToast('Zona eliminada. Sincronizando Zonas.csv...', 'ok');
        await actualizarCSVSharePoint('zonas');
        poblarSelectsABMInicial();
    }

    function obtenerFechaISO(offsetDias = 0) {
        const d = new Date();
        d.setDate(d.getDate() + offsetDias);
        return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, '0') + "-" + String(d.getDate()).padStart(2, '0');
    }

    function aplicarVentanaFechaAlta() {
        const fFecha = document.getElementById('f_fecha');
        if (!fFecha) return;
        fFecha.min = obtenerFechaISO(0);
        fFecha.max = obtenerFechaISO(1);
    }

    function poblarSelectsABMInicial() {
        const selPD = document.getElementById('f_planta_descarga');
        if (selPD) {
            resetSelectConGuion(selPD);
            configPlantas.forEach(p => selPD.add(new Option(p.id, p.id)));
        }
        poblarSelectZonasPorPlanta('', '');
    }

    function cargarSelectPlantasFisicas() {
        const selects = [document.getElementById('f_planta_descarga'), document.getElementById('filtro_planta_descarga'), document.getElementById('u_planta'), document.getElementById('dash_planta'), document.getElementById('z_planta')];
        selects.forEach(s => {
            if(!s) return;
            let h = '';
            if (s.id.includes('filtro') || s.id.includes('dash')) {
                h = '<option value="TODAS">-- Todas las Plantas --</option>';
            } else if (s.id === 'u_planta' || s.id === 'z_planta') {
                h = '<option value="">-</option>';
            } else if (s.id === 'f_planta_descarga') {
                h = '<option value="">-</option>';
            }
            configPlantas.forEach(p => h += `<option value="${p.id}">${p.id}</option>`);
            s.innerHTML = h;
        });
        poblarSelectZonasPorPlanta(document.getElementById('f_planta_descarga')?.value || '', document.getElementById('f_planta')?.value || '');
    }

    function sincronizarFiltrosYMonitor() {
        const plantaSelect = document.getElementById('filtro_planta_descarga').value;
        const selectU = document.getElementById('filtro_usuario');
        
        let usuariosValidos = listaUsuariosCache.filter(u => u.estado !== 'Deshabilitado');
        if (plantaSelect !== 'TODAS') {
            let usuariosPlanta = usuariosValidos.filter(u => String(u.planta).toLowerCase() === plantaSelect.toLowerCase() || String(u.planta).toLowerCase().includes(plantaSelect.toLowerCase()));
            if(usuariosPlanta.length > 0) usuariosValidos = usuariosPlanta;
        }

        if (selectU) {
            const usr = [...new Set(usuariosValidos.map(u => u.nombre).filter(Boolean))].sort();
            let h = '<option value="TODOS">-- Todos --</option>';
            usr.forEach(u => { h += `<option value="${escapeHtml(u)}">${escapeHtml(u)}</option>`; });
            selectU.innerHTML = h;
        }
        aplicarFiltrosMonitor(); calcularDisponibilidadOffline(); generarResumenDiario(); renderizarResumenCapacidad();
    }

    function actualizarDatalistsFiltros() {
        const dlPat = document.getElementById('dl_patentes');
        const dlProv = document.getElementById('dl_proveedores');
        if(dlPat) {
            const pats = [...new Set(listaTurnosCache.map(t => t.Patente).filter(Boolean))].sort();
            dlPat.innerHTML = pats.map(p => `<option value="${escapeHtml(p)}">`).join('');
        }
        if(dlProv) {
            const provs = [...new Set(listaTurnosCache.map(t => t.field_2).filter(Boolean))].sort();
            dlProv.innerHTML = provs.map(p => `<option value="${escapeHtml(p)}">`).join('');
        }
    }

    function aplicarFiltrosMonitor() {
        const pd  = document.getElementById('filtro_planta_descarga').value;
        const u   = document.getElementById('filtro_usuario').value;
        const est = document.getElementById('filtro_estado').value;
        const tt  = document.getElementById('filtro_tipo_turno').value;
        const pat = (document.getElementById('filtro_patente')?.value || '').trim().toUpperCase();
        const prov= (document.getElementById('filtro_proveedor')?.value || '').trim().toLowerCase();

        let filtrados = listaTurnosCache.filter(t => t.field_6 && String(t.field_6).startsWith(fechaSeleccionadaGlobal));
        if(pd  !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === pd);
        if(u   !== 'TODOS') filtrados = filtrados.filter(t => getResponsableName(t) === u);
        if(est !== 'TODOS') {
            if(est === 'Cancelado') filtrados = filtrados.filter(t => String(t.field_7).toLowerCase().includes('cancelado') || String(t.field_7).toLowerCase().includes('rechazado'));
            else filtrados = filtrados.filter(t => String(t.field_7).toLowerCase().includes(est.toLowerCase()));
        }
        if(tt !== 'TODOS') {
            if(tt === 'Sobreturno') filtrados = filtrados.filter(t => t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1);
            else filtrados = filtrados.filter(t => !(t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1));
        }
        if(pat)  filtrados = filtrados.filter(t => String(t.Patente || '').toUpperCase().includes(pat));
        if(prov) filtrados = filtrados.filter(t => String(t.field_2 || '').toLowerCase().includes(prov));

        renderizarFilas(filtrados);
        calcularDisponibilidadOffline();
        generarResumenDiario();
        renderizarResumenCapacidad();
    }

    function restablecerFiltros() {
        document.getElementById('filtro_planta_descarga').value = 'TODAS';
        document.getElementById('filtro_estado').value = 'TODOS';
        document.getElementById('filtro_tipo_turno').value = 'TODOS';
        const fp = document.getElementById('filtro_patente'); if(fp) fp.value = '';
        const fpr = document.getElementById('filtro_proveedor'); if(fpr) fpr.value = '';
        sincronizarFiltrosYMonitor();
    }

    // --- RESUMEN DIARIO (VERTICAL, COLUMNA IZQUIERDA) ---
    function generarResumenDiario() {
        const cont = document.getElementById('resumen-contadores-vertical');
        const lblFecha = document.getElementById('resumen-fecha-label');
        if(!cont) return;
        lblFecha.textContent = fechaSeleccionadaGlobal;

        const turnosHoy = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fechaSeleccionadaGlobal));
        let htmlResumen = '';
        let totAsig = 0, totPend = 0, totApro = 0, totRepr = 0, totCanc = 0, totSobre = 0;

        configPlantas.forEach(p => {
            const trnP = turnosHoy.filter(t => t.PlantaDescarga === p.id);
            if(trnP.length > 0) {
                let asig = trnP.length;
                let pend = trnP.filter(t => (t.field_7||'').toLowerCase().includes('pendiente')).length;
                let apro = trnP.filter(t => (t.field_7||'').toLowerCase().includes('aprobado')).length;
                let repr = trnP.filter(t => (t.field_7||'').toLowerCase().includes('reprogramado')).length;
                let canc = trnP.filter(t => (t.field_7||'').toLowerCase().includes('cancelado') || (t.field_7||'').toLowerCase().includes('rechazado')).length;
                let sobre = trnP.filter(t => t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1).length;

                totAsig += asig; totPend += pend; totApro += apro; totRepr += repr; totCanc += canc; totSobre += sobre;

                htmlResumen += `
                <div class="bg-slate-900/60 border border-slate-700 rounded-lg p-3">
                    <div class="flex items-center justify-between mb-2">
                        <span class="font-bold text-sky-300 text-xs uppercase truncate">${escapeHtml(p.id)}</span>
                        <span class="font-extrabold text-white text-sm bg-slate-800 rounded px-2 py-0.5">${asig}</span>
                    </div>
                    <div class="space-y-1 text-[11px]">
                        <div class="flex justify-between"><span class="text-amber-400">Pendientes</span><span class="font-bold text-amber-400">${pend}</span></div>
                        <div class="flex justify-between"><span class="text-emerald-400">Aprobados</span><span class="font-bold text-emerald-400">${apro}</span></div>
                        <div class="flex justify-between"><span class="text-sky-400">Reprogramados</span><span class="font-bold text-sky-400">${repr}</span></div>
                        <div class="flex justify-between"><span class="text-rose-400">Cancelados</span><span class="font-bold text-rose-400">${canc}</span></div>
                        <div class="flex justify-between"><span class="text-violet-300">Sobreturnos</span><span class="font-bold text-violet-300">${sobre}</span></div>
                    </div>
                </div>`;
            }
        });

        if(htmlResumen === '') {
            cont.innerHTML = '<div class="text-center text-slate-500 text-xs mt-6 px-2">No hay actividad logistica en esta fecha.</div>';
            return;
        }

        htmlResumen += `
        <div class="bg-slate-800/90 border-2 border-slate-500 rounded-lg p-3 mt-1">
            <div class="flex items-center justify-between mb-2">
                <span class="font-extrabold text-white text-xs uppercase">Totales</span>
                <span class="font-extrabold text-white text-base bg-slate-700 rounded px-2 py-0.5">${totAsig}</span>
            </div>
            <div class="space-y-1 text-[11px] font-bold">
                <div class="flex justify-between"><span class="text-amber-400">Pendientes</span><span class="text-amber-400">${totPend}</span></div>
                <div class="flex justify-between"><span class="text-emerald-400">Aprobados</span><span class="text-emerald-400">${totApro}</span></div>
                <div class="flex justify-between"><span class="text-sky-400">Reprogramados</span><span class="text-sky-400">${totRepr}</span></div>
                <div class="flex justify-between"><span class="text-rose-400">Cancelados</span><span class="text-rose-400">${totCanc}</span></div>
                <div class="flex justify-between"><span class="text-violet-300">Sobreturnos</span><span class="text-violet-300">${totSobre}</span></div>
            </div>
        </div>`;
        cont.innerHTML = htmlResumen;
    }

    // --- CONEXION SP ---
    async function testConexion() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (res.ok) {
                const data = await res.json();
                currentLoggedUser.name = data.Title || data.DisplayName || "Usuario OK";
                currentLoggedUser.email = data.Email || "";
                document.getElementById('app-user-name').textContent = escapeHtml(currentLoggedUser.name);
            }
        } catch (err) {}
    }

    async function refrescarDBAbsoluto() {
        document.getElementById('filtro_planta_descarga').value = 'TODAS';
        document.getElementById('filtro_estado').value = 'TODOS';
        await cargarTurnos(); generarResumenDiario();
    }

    async function cargarTurnos() {
        logETLStep(1, false);
        try {
            let res = await fetchSharePoint(`items?$expand=Editor,Author&$select=*,Editor/Title,Author/Title&$orderby=Created desc&$top=1000`);
            if (res.status === 400) {
                res = await fetchSharePoint(`items?$orderby=Created desc&$top=1000`);
            }
            if (!res.ok) throw new Error("HTTP " + res.status);
            
            const data = await res.json();
            listaTurnosCache = data.value || [];
            
            ordenarEstructuralmenteBase(listaTurnosCache);

            logETLStep(1, true); logETLStep(2, false);
            
            sincronizarFiltrosYMonitor();
            actualizarDatalistsFiltros();
            logETLStep(2, true);
            logLog(`[ETL] BD Turnos Sincronizada. Registros: ${listaTurnosCache.length}`);
            
            if(document.getElementById('s10').classList.contains('active')) updateDashboard(); 
        } catch (err) { 
            document.getElementById('tabla-turnos').innerHTML = `<tr><td colspan="8" class="p-6 text-center text-rose-500 font-bold text-sm">Error de conexion.</td></tr>`;
        }
    }

    // --- DISPONIBILIDAD MEJORADA ---
    function calcularDisponibilidadOffline() {
        const panel = document.getElementById('panel-disponibilidad-dinamico');
        if(!panel) return;
        const pfSeleccionada = document.getElementById('filtro_planta_descarga').value;
        const estSeleccionado = document.getElementById('filtro_estado') ? document.getElementById('filtro_estado').value : 'TODOS';
        let htmlPanel = '';

        configPlantas.forEach(plantaConfig => {
            if (pfSeleccionada !== 'TODAS' && plantaConfig.id !== pfSeleccionada) return;
            let ocupados = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === plantaConfig.id && String(t.field_7).toLowerCase() !== 'cancelado' && String(t.field_7).toLowerCase() !== 'rechazado');
            if (estSeleccionado !== 'TODOS') {
                if (estSeleccionado === 'Cancelado') {
                    ocupados = [];
                } else {
                    ocupados = ocupados.filter(t => String(t.field_7).toLowerCase().includes(estSeleccionado.toLowerCase()));
                }
            }
            let slotsTotales = getSlotsCalculados(plantaConfig.id, fechaSeleccionadaGlobal);
            
            if (slotsTotales.length > 0) {
                htmlPanel += `<div class="mb-5"><h4 class="text-sm font-bold text-sky-300 uppercase tracking-wider text-center mb-2 bg-sky-950/40 py-2 rounded border border-sky-900/30">${plantaConfig.id}</h4><div class="space-y-3">`;
                slotsTotales.forEach(s => {
                    let ocupado = ocupados.find(t => normalizarStringHorario(t.field_5) === normalizarStringHorario(s));
                    if (ocupado) {
                        let estado = String(ocupado.field_7||'').toLowerCase();
                        const esSobreturno = ocupado.EsSobreturno === true || ocupado.EsSobreturno === 'true' || ocupado.EsSobreturno === 1;
                        let claseBg = 'bg-red-950/30 border-red-900 text-rose-300';
                        if (estado.includes('pendiente')) claseBg = 'bg-amber-900/30 border-amber-600 text-amber-300';
                        if (esSobreturno) claseBg = 'bg-violet-950/40 border-violet-600 text-violet-300';

                        const pat = escapeHtml(ocupado.Patente || 'S/D');
                        const raz = escapeHtml(ocupado.field_2 || 'S/D');
                        const rsp = escapeHtml(getResponsableName(ocupado));
                        const tagSobre = esSobreturno ? `<span class="ml-1 text-[9px] uppercase font-bold text-violet-300 bg-violet-900/50 border border-violet-700 px-1 rounded">Sobret.</span>` : '';

                        htmlPanel += `<div class="flex flex-col p-3 border ${claseBg} rounded text-sm shadow-md">
                            <div class="flex justify-between mb-1">
                                <span class="font-bold text-base">${s.split(' ')[0]}</span><span class="font-bold tracking-widest bg-black/40 px-2 rounded">${pat}</span>
                            </div>
                            <div class="flex flex-col text-slate-300 mt-1 gap-1">
                                <span class="truncate font-sans font-semibold">${raz}${tagSobre}</span>
                                <span class="text-sky-400 text-xs whitespace-nowrap bg-sky-900/30 px-2 py-0.5 rounded inline-block w-fit">Resp: ${rsp}</span>
                            </div>
                        </div>`;
                    } else {
                        htmlPanel += `<div class="flex justify-between items-center p-3 border border-emerald-900 bg-emerald-950/30 rounded text-sm text-emerald-400 shadow-md opacity-70">
                            <span class="font-bold text-base">${s.split(' ')[0]}</span><span class="font-bold tracking-widest opacity-60">LIBRE</span>
                        </div>`;
                    }
                });
                htmlPanel += `</div></div>`;
            }
        });
        panel.innerHTML = htmlPanel || '<div class="text-center text-slate-500 text-sm mt-8">Sin agenda para esta configuracion.</div>';
        renderizarResumenCapacidad();
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        if(items.length === 0) { tbody.innerHTML = `<tr><td colspan="8" class="p-6 text-center text-slate-500 text-sm">No hay turnos para estos filtros.</td></tr>`; return; }

        let htmlRows = '';
        items.forEach(t => {
            const estado = escapeHtml(String(t.field_7 || 'Pendiente').trim());
            const esAprobado = estado.toLowerCase() === 'aprobado';
            const esSobreturno = t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1;
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : ((estado.toLowerCase() === 'cancelado' || estado.toLowerCase() === 'rechazado') ? 'text-rose-400' : (estado.toLowerCase() === 'reprogramado' ? 'text-sky-400 font-bold' : 'text-amber-400'));
            
            const fechaStr = t.field_6 ? String(t.field_6).split('T')[0] : '-';

            const filaClase = esSobreturno ? 'border-b border-slate-700/50 hover:bg-violet-900/30 bg-violet-950/20 text-xs border-l-2 border-l-violet-500' : 'border-b border-slate-700/50 hover:bg-slate-800/30 text-xs';
            const tagSobreturno = esSobreturno ? `<span class="ml-1.5 text-[9px] uppercase font-bold text-violet-300 bg-violet-900/50 border border-violet-700 px-1.5 py-0.5 rounded">Sobreturno</span>` : '';

            const horaIn  = t.HoraIngresoReal  ? `<span class="text-emerald-400 text-[10px] block mt-0.5">${escapeHtml(t.HoraIngresoReal)}</span>`  : '';
            const horaSal = t.HoraSalidaReal   ? `<span class="text-rose-400 text-[10px] block mt-0.5">${escapeHtml(t.HoraSalidaReal)}</span>` : '';
            const botonesTracking = esAprobado ? `
                <button onclick="marcarTracking(${t.Id},'IN')" title="Registrar Ingreso" class="bg-slate-800 hover:bg-emerald-900/60 text-emerald-400 border border-emerald-900 px-2 py-1 rounded text-[10px] font-bold transition flex flex-col items-center leading-tight">
                    In${horaIn}
                </button>
                <button onclick="marcarTracking(${t.Id},'OUT')" title="Registrar Salida" class="bg-slate-800 hover:bg-rose-900/60 text-rose-400 border border-rose-900 px-2 py-1 rounded text-[10px] font-bold transition flex flex-col items-center leading-tight">
                    Out${horaSal}
                </button>` : '';

            htmlRows += `
            <tr class="${filaClase}">
                <td class="p-3 text-sky-400 font-bold">${t.Id}</td>
                <td class="p-3 text-slate-300">${fechaStr}</td>
                <td class="p-3 text-slate-300 font-bold">${escapeHtml(t.PlantaDescarga || '-')}</td>
                <td class="p-3 text-white font-semibold">${escapeHtml(t.field_2 || '-')}${tagSobreturno}</td>
                <td class="p-3 tracking-widest text-slate-300">
                    <span class="bg-black/40 px-2 py-1 rounded">${escapeHtml(t.Patente || '-')}</span>
                </td>
                <td class="p-3 text-amber-300 font-bold">${escapeHtml(t.field_5 || '-')}</td>
                <td class="p-3 ${colorEst} text-center">${estado}<br><span class="text-[10px] text-slate-500 font-normal truncate block max-w-[120px] mx-auto mt-0.5">${escapeHtml(getResponsableName(t))}</span></td>
                <td class="p-3 text-center">
                    <div class="flex justify-center items-center gap-1.5 flex-wrap">
                        <button onclick="modoABM_Ver(${t.Id})" class="bg-sky-700 hover:bg-sky-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Ver</button>
                    </div>
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    function getResponsableName(t) { return t.Author ? t.Author.Title : (t.Editor ? t.Editor.Title : (t.Gestor || 'S/D')); }

    function renderizarGrilaCalendario() {
        const gridContainer = document.getElementById('calendar-days-grid');
        if (!gridContainer) return;
        const baseDate = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00');
        const anio = baseDate.getFullYear();
        const mes = baseDate.getMonth(); 
        document.getElementById('calendar-month-title').textContent = `${["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"][mes]} ${anio}`;

        let dayOfWeek = new Date(anio, mes, 1).getDay(); 
        let calHtml = ''; 
        for (let b = 0; b < (dayOfWeek === 0 ? 6 : dayOfWeek - 1); b++) calHtml += `<div class="p-2 text-transparent select-none">-</div>`;

        const totalDiasMes = new Date(anio, mes + 1, 0).getDate();
        for (let dia = 1; dia <= totalDiasMes; dia++) {
            let claseEstilo = (dia === baseDate.getDate()) ? 'bg-sky-500 text-slate-900 font-extrabold rounded shadow' : 'text-slate-300 hover:bg-slate-800 rounded cursor-pointer transition';
            let strDia = `${anio}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
            calHtml += `<button onclick="conmutarFechaDesdeCalendario('${strDia}')" class="p-2 rounded text-sm w-full ${claseEstilo}">${dia}</button>`;
        }
        gridContainer.innerHTML = calHtml;
    }

    function conmutarFechaDesdeCalendario(nuevaFecha) {
        fechaSeleccionadaGlobal = nuevaFecha;
        document.getElementById('f_fecha') && (document.getElementById('f_fecha').value = nuevaFecha);
        renderizarGrilaCalendario(); 
        aplicarFiltrosMonitor(); calcularDisponibilidadOffline(); generarResumenDiario(); renderizarResumenCapacidad();
        if(document.getElementById('s10').classList.contains('active')) {
            document.getElementById('dash_fecha').value = nuevaFecha;
            updateDashboard();
        }
    }

    function logETLStep(stepNum, isDone=false) {
        const steps = ['etl-extract', 'etl-transform', 'etl-load'];
        const ic = ['etl-ic1', 'etl-ic2', 'etl-ic3'];
        steps.forEach((s, idx) => {
            let el = document.getElementById(s); if(!el) return;
            if(idx === stepNum-1) { el.classList.add('active'); if(isDone) { el.classList.add('done'); document.getElementById(ic[idx]).innerHTML = 'OK'; } } 
            else { el.classList.remove('active'); }
        });
    }

    initApp();
</script>

</body>
</html>