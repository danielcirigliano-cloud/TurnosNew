<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERP Logistica de Turnos | Molca</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Syne:wght@400;600;700;800&display=swap');
        :root { --sp-blue: #38bdf8; --sp-bg: #0b1120; --sp-panel: rgba(15, 23, 42, 0.92); --sp-border: rgba(56, 189, 248, 0.15); }
        body { font-family: 'Syne', sans-serif; background-color: var(--sp-bg); color: #e2e8f0; margin: 0; font-size: 1rem; }
        .mono { font-family: 'JetBrains Mono', monospace; }
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
    </style>
</head>
<body class="flex h-screen overflow-hidden text-slate-200">

<aside class="w-64 glass flex flex-col p-4 border-r border-slate-700 h-full z-10">
    <h1 class="text-xl font-bold text-white mb-5 uppercase tracking-wide">MOLCA <span class="text-sky-400">ERP</span></h1>
    <div class="mb-5 text-xs inline-flex items-center gap-2 p-1.5 rounded-full" style="background:rgba(0,0,0,.4); border:1px solid #334155;">
        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
        <span class="font-bold text-emerald-400">REST API</span>
    </div>

    <nav class="space-y-1 flex-1 overflow-y-auto" id="main-nav">
        <button class="w-full text-left rounded tab-btn active-tab" data-target="s2">1. Turnos Diarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s1" id="btn-tab-abm">2. ABM de Turnos</button>
        <button class="w-full text-left rounded tab-btn" data-target="s6" onclick="renderizarBaseProveedores()">3. Base Proveedores</button>
        <button class="w-full text-left rounded tab-btn" data-target="s8" onclick="renderizarABMHorarios()">4. Config. Horarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s9">5. Modulo ETL & Logs</button>
        <button class="w-full text-left rounded tab-btn" data-target="s7">6. Base Usuarios</button>
    </nav>
</aside>

<main class="flex-1 p-6 overflow-y-auto relative">
    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50 z-20">
        <span class="text-slate-400 font-semibold">Usuario:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Iniciando...</span>
    </div>

    <section id="s2" class="tab-content active mt-8">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-sky-400">Monitor de Turnos Diarios</h2>
            <div class="flex gap-2">
                <button onclick="abrirAltaTurno()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">[+] Alta de Turno</button>
                <button onclick="enviarResumenDiario()" class="bg-indigo-600 hover:bg-indigo-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">Enviar Resumen</button>
            </div>
        </div>
        
        <div class="grid grid-cols-7 gap-4">
            <div class="col-span-5 glass p-4 rounded-xl h-[720px] flex flex-col">
                <div class="flex gap-2 mb-4 items-end bg-slate-900/50 p-3 rounded-lg border border-slate-700">
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Filtro Planta Fisica</label>
                        <select id="filtro_planta_descarga" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-36">
                            <option value="TODAS">-- Todas --</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Modificador</label>
                        <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-36">
                            <option value="TODOS">-- Todos --</option>
                        </select>
                    </div>
                    <button onclick="restablecerFiltros()" class="bg-slate-700 px-3 py-1.5 text-xs rounded hover:bg-slate-600 transition">Quitar Filtro</button>
                    <button onclick="refrescarDBAbsoluto()" class="ml-auto bg-slate-800 border border-slate-600 px-4 py-1.5 text-xs rounded text-sky-400 hover:bg-slate-700 transition">Refrescar DB</button>
                </div>
                
                <div class="overflow-x-auto text-base flex-1">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow">
                            <tr>
                                <th class="py-3 px-2">ID</th>
                                <th class="px-2">Planta Fisica</th>
                                <th class="px-2">Tipo Carga</th>
                                <th class="px-2">Proveedor</th>
                                <th class="px-2">Patente</th>
                                <th class="px-2">Horario</th>
                                <th class="px-2 text-center">Estado</th>
                                <th class="px-2 text-center">Accion</th>
                            </tr>
                        </thead>
                        <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                            <tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Cargando base de datos...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-span-2 glass p-4 rounded-xl flex flex-col h-[720px] overflow-hidden">
                <h3 class="text-sm font-bold text-sky-400 uppercase tracking-wider text-center mb-2">Disponibilidad</h3>
                <div class="bg-slate-950/80 p-2 rounded border border-slate-800 mb-2 text-xs">
                    <div class="flex justify-between items-center mb-1 px-1">
                        <span id="calendar-month-title" class="font-bold text-white uppercase tracking-wide">MES</span>
                        <div class="text-[9px] text-slate-400 font-semibold font-mono">SELECCION</div>
                    </div>
                    <div class="grid grid-cols-7 text-center font-bold text-slate-500 uppercase tracking-wider mb-1 text-[9px]">
                        <span>Lu</span><span>Ma</span><span>Mi</span><span>Ju</span><span>Vi</span><span>Sa</span><span>Do</span>
                    </div>
                    <div id="calendar-days-grid" class="grid grid-cols-7 gap-1 text-center font-mono font-bold text-xs"></div>
                </div>
                <div class="flex-1 overflow-y-auto pr-1">
                    <div id="panel-disponibilidad-dinamico" class="space-y-4"></div>
                </div>
            </div>
        </div>
    </section>

    <section id="s1" class="tab-content mt-8">
        <div class="flex items-center justify-between mb-4 max-w-4xl">
            <h2 class="text-2xl font-bold text-sky-400">ABM de Turnos</h2>
            <div class="flex gap-2 items-center">
                <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold">Alta de Turno</div>
                <button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 text-white px-3 py-1 text-xs rounded border border-slate-500 transition">Volver</button>
            </div>
        </div>
        
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4">
            <input type="hidden" id="f_item_id">
            
            <div class="col-span-2 grid grid-cols-3 gap-4 border-b border-slate-700 pb-4 mb-2">
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Patente Vehiculo *</label>
                    <input type="text" id="f_patente" placeholder="AA111AA / AAA111" class="bg-slate-900 border border-slate-700 p-2 w-full font-mono text-amber-300 uppercase outline-none f-control transition-colors" maxlength="7">
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Hora Ingreso Real</label>
                    <input type="time" id="f_hora_ing" class="bg-slate-900 border border-slate-700 p-2 w-full text-emerald-400 outline-none f-control transition-colors">
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Hora Salida Real</label>
                    <input type="time" id="f_hora_sal" class="bg-slate-900 border border-slate-700 p-2 w-full text-rose-400 outline-none f-control transition-colors">
                </div>
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Num Proveedor / CUIT *</label>
                <input type="text" id="f_cuit" placeholder="Solo numeros" onblur="autocompletarProveedor()" class="bg-slate-900 border border-slate-700 p-2 w-full text-amber-300 font-bold outline-none f-control transition-colors">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Num OC</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="bg-slate-900 border border-slate-700 p-2 w-full text-white outline-none f-control transition-colors">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Razon Social Proveedor *</label>
                <input type="text" id="f_proveedor" placeholder="Razon Social" class="bg-slate-900 border border-slate-700 p-2 w-full text-white outline-none f-control transition-colors">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="bg-slate-900 border border-slate-700 p-2 w-full text-white outline-none f-control transition-colors">
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Planta Fisica (Ubicacion)</label>
                <select id="f_planta_descarga" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-400 font-bold outline-none f-control transition-colors"></select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Tipo Carga (Area)</label>
                <select id="f_planta" class="bg-slate-900 border border-slate-700 p-2 w-full text-white outline-none f-control transition-colors">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                    <option value="Materia Prima">Materia Prima</option>
                </select>
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Fecha Solicitud *</label>
                <input type="date" id="f_fecha" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-2 w-full text-white outline-none f-control transition-colors">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Slot Horario Calculado *</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-300 font-mono font-bold outline-none f-control transition-colors"></select>
            </div>

            <div class="col-span-2 bg-slate-950 p-3 rounded text-xs border border-slate-800 text-slate-400 flex justify-between">
                <span>Responsable: <strong id="f_usuario_gestor" class="text-white">-</strong></span>
                <span>Dia Semana: <strong id="f_dia" class="text-white">-</strong></span>
            </div>

            <div class="col-span-2 flex gap-3 mt-2" id="panel-botones-abm"></div>

            <div class="col-span-2 mt-2 border-t border-slate-700 pt-3 flex items-center justify-between" id="panel-tracking">
                <div>
                    <span class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Registro de Porteria (Tracking)</span>
                    <div class="flex gap-2">
                        <button id="btn-track-in" onclick="marcarTrackingForm('IN')" class="bg-slate-800 text-emerald-400 border border-slate-700 hover:bg-slate-700 px-3 py-1.5 rounded text-xs font-bold transition">[ In ] Marcar Ingreso</button>
                        <button id="btn-track-out" onclick="marcarTrackingForm('OUT')" class="bg-slate-800 text-rose-400 border border-slate-700 hover:bg-slate-700 px-3 py-1.5 rounded text-xs font-bold transition">[ Out ] Marcar Salida</button>
                    </div>
                </div>
                <div class="text-right">
                    <span class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Estado Actual</span>
                    <span id="f_estado_actual" class="text-xl font-bold text-slate-500 uppercase tracking-widest">NUEVO</span>
                </div>
            </div>
        </div>
    </section>

    <section id="s8" class="tab-content mt-8">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Configuracion de Horarios por Planta</h2>
        <p class="text-xs text-slate-400 mb-4">Ajuste las ventanas operativas y duracion de turnos. Los sabados poseen reglas integradas.</p>
        <div class="glass p-4 rounded-xl text-base max-w-5xl">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-xs uppercase text-slate-400 font-bold border-b border-slate-700">
                        <tr><th class="py-3 px-3">Planta Fisica</th><th class="px-3">Lunes a Viernes</th><th class="px-3">Sabados</th><th class="px-3">Min. x Turno</th><th class="px-3 text-center">Accion</th></tr>
                    </thead>
                    <tbody id="tabla-config-horarios" class="divide-y divide-slate-700/50"></tbody>
                </table>
            </div>
            <div class="mt-4 flex gap-2">
                <button onclick="guardarConfiguracionHorarios()" class="bg-emerald-600 hover:bg-emerald-500 px-4 py-2 text-xs font-bold rounded shadow transition text-white">Guardar Configuracion</button>
            </div>
        </div>
    </section>

    <section id="s6" class="tab-content mt-8">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Base Maestro de Proveedores</h2>
        <div class="glass p-4 rounded mb-6 border border-slate-700 flex gap-3 items-end max-w-5xl text-xs">
            <input type="hidden" id="p_index">
            <div class="w-1/6">
                <label class="block uppercase text-slate-400 font-bold mb-1">Num Proveedor</label>
                <input type="text" id="p_cuit" class="w-full bg-slate-900 border border-slate-700 p-2 text-amber-300 font-bold rounded outline-none">
            </div>
            <div class="w-2/6">
                <label class="block uppercase text-slate-400 font-bold mb-1">Razon Social</label>
                <input type="text" id="p_razon" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none">
            </div>
            <div class="w-1/6">
                <label class="block uppercase text-slate-400 font-bold mb-1">Tipo Insumo</label>
                <input type="text" id="p_tipo" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none">
            </div>
            <div class="w-1/6">
                <label class="block uppercase text-slate-400 font-bold mb-1">Responsable</label>
                <input type="text" id="p_resp" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none">
            </div>
            <div class="w-1/6">
                <label class="block uppercase text-slate-400 font-bold mb-1">Estado</label>
                <select id="p_estado" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none">
                    <option value="Habilitado">Habilitado</option>
                    <option value="Deshabilitado">No Habilitado</option>
                </select>
            </div>
            <div>
                <button onclick="guardarEdicionProveedor()" class="bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 font-bold rounded transition">Guardar</button>
            </div>
        </div>
        <div class="flex gap-4 mb-4 items-center">
            <input type="file" id="file_proveedores" accept=".csv" class="text-sm text-slate-300">
            <button onclick="procesarCSVProveedores()" class="bg-slate-700 hover:bg-slate-600 text-white px-4 py-1.5 font-bold rounded text-xs transition border border-slate-600">Carga Masiva CSV</button>
        </div>
        <div class="glass p-4 rounded-xl text-base max-w-5xl">
            <div class="overflow-x-auto h-96">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0">
                        <tr><th class="py-3 px-3">Num Proveedor</th><th class="px-3">Razon Social</th><th class="px-3">Tipo Insumo</th><th class="px-3">Responsable</th><th class="px-3">Estado</th><th class="px-3">Accion</th></tr>
                    </thead>
                    <tbody id="tabla-proveedores">
                        <tr><td colspan="6" class="p-6 text-center text-slate-500 text-xs">Sin padron de proveedores cargado.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section id="s9" class="tab-content mt-8">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Modulo ETL Visual</h2>
        <div class="max-w-5xl grid grid-cols-2 gap-6">
            <div class="glass p-6 rounded-xl col-span-2">
                <h3 class="text-sm font-bold text-slate-300 uppercase mb-4 border-b border-slate-700 pb-2">Flujo de Automatizacion</h3>
                <div class="flex flex-col gap-4 relative">
                    <div class="absolute left-6 top-6 bottom-6 w-0.5 bg-slate-700 z-0"></div>
                    <div id="etl-extract" class="etl-step flex items-center gap-4 z-10 bg-slate-900 p-3 rounded border border-slate-700">
                        <div class="w-8 h-8 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-xs" id="etl-ic1">1</div>
                        <div><div class="font-bold text-sky-400 text-sm">Extraccion (E)</div><div class="text-xs text-slate-400">Lectura de buffers y API REST.</div></div>
                    </div>
                    <div id="etl-transform" class="etl-step flex items-center gap-4 z-10 bg-slate-900 p-3 rounded border border-slate-700">
                        <div class="w-8 h-8 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-xs" id="etl-ic2">2</div>
                        <div><div class="font-bold text-amber-400 text-sm">Transformacion (T)</div><div class="text-xs text-slate-400">Mapeo OData y validacion defensiva.</div></div>
                    </div>
                    <div id="etl-load" class="etl-step flex items-center gap-4 z-10 bg-slate-900 p-3 rounded border border-slate-700">
                        <div class="w-8 h-8 rounded-full bg-slate-800 border-2 border-slate-500 flex items-center justify-center font-bold text-xs" id="etl-ic3">3</div>
                        <div><div class="font-bold text-emerald-400 text-sm">Carga (L)</div><div class="text-xs text-slate-400">POST/MERGE a SharePoint.</div></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section id="s7" class="tab-content mt-8">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Gestion de Usuarios (Mailing)</h2>
        <div class="flex gap-4 mb-6 glass p-4 rounded items-center max-w-4xl">
            <input type="file" id="file_usuarios" accept=".csv" class="text-sm text-slate-300">
            <button onclick="procesarCSVUsuarios()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-1.5 font-bold rounded text-xs transition">Importar Correos</button>
        </div>
        <div class="glass p-4 rounded-xl overflow-x-auto max-w-4xl">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold"><tr><th class="py-3 px-3">ID</th><th class="px-3">Nombre</th><th class="px-3">Email</th><th class="px-3">Planta</th></tr></thead>
                <tbody id="tabla-usuarios"><tr><td colspan="4" class="p-4 text-center text-slate-500 text-xs">Sin datos.</td></tr></tbody>
            </table>
        </div>
    </section>

</main>

<div id="toast"></div>

<script>
    // =========================================================================
    // ENRUTADOR SEGURO DE UI: AISLADO PARA EVITAR CONGELAMIENTOS
    // =========================================================================
    function setupRuteo() {
        try {
            const btns = document.querySelectorAll('.tab-btn');
            const contents = document.querySelectorAll('.tab-content');
            btns.forEach(btn => {
                btn.addEventListener('click', () => {
                    btns.forEach(b => b.classList.remove('active-tab', 'bg-[#0369a1]', 'text-white'));
                    btn.classList.add('active-tab', 'bg-[#0369a1]', 'text-white');
                    contents.forEach(c => c.classList.remove('active', 'block'));
                    contents.forEach(c => c.style.display = 'none');
                    const targetEl = document.getElementById(btn.dataset.target);
                    if(targetEl) { targetEl.classList.add('active'); targetEl.style.display = 'block'; }
                });
            });
        } catch(e) { console.error("Error UI Menu", e); }
    }
    setupRuteo();

    // =========================================================================
    // MOTOR DE CONEXION RESILIENTE (AUTO-DISCOVERY)
    // =========================================================================
    const relativeSiteUrl = "/sites/GestiondeTurnos";
    let targetListName = 'Turnos Proveedores'; 

    async function fetchSharePoint(query, options = {}) {
        if (!options.headers) { options.headers = { "Accept": "application/json;odata=nometadata" }; }
        let url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/${query}`;
        let res = await fetch(url, options);
        
        // Auto-Discovery: Si la lista principal devuelve 404, prueba con la variante _1
        if (res.status === 404 && targetListName === 'Turnos Proveedores') {
            targetListName = 'Turnos Proveedores_1';
            url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/${query}`;
            res = await fetch(url, options);
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

    // =========================================================================

    let listaTurnosCache = [];
    let listaUsuariosCache = [];
    let listaProveedoresCache = [];
    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Local", email: "logistica@grupocanuelas.com" };

    let configPlantas = [
        { id: "Parque Canuelas", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false },
        { id: "Predio Canuelas", hInLV: 10, hOutLV: 17, hInS: 7, hOutS: 11, duracion: 40, sabado: true },
        { id: "Spegazzini", hInLV: 8, hOutLV: 16, hInS: 8, hOutS: 12, duracion: 45, sabado: true },
        { id: "Almar", hInLV: 7, hOutLV: 14, hInS: 7, hOutS: 11, duracion: 30, sabado: true }
    ];

    function escapeHtml(unsafe) {
        if(!unsafe) return "";
        return String(unsafe).replace(/[&<"'>]/g, function(match) {
            const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
            return map[match];
        });
    }

    function initApp() {
        try {
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.getFullYear() + "-" + String(hoy.getMonth() + 1).padStart(2, '0') + "-" + String(hoy.getDate()).padStart(2, '0');
            
            cargarSelectPlantasFisicas();
            renderizarABMHorarios();
            renderizarGrilaCalendario();
            
            setTimeout(() => { testConexion(); }, 50);
            setTimeout(() => { refrescarDBAbsoluto(); }, 150); 
        } catch (err) { console.error("Init Error", err); }
    }

    function cargarSelectPlantasFisicas() {
        const selects = [document.getElementById('f_planta_descarga'), document.getElementById('filtro_planta_descarga')];
        selects.forEach(s => {
            if(!s) return;
            let h = s.id.includes('filtro') ? '<option value="TODAS">-- Todas las Plantas --</option>' : '';
            configPlantas.forEach(p => h += `<option value="${p.id}">${p.id}</option>`);
            s.innerHTML = h;
        });
    }

    function renderizarABMHorarios() {
        const tb = document.getElementById('tabla-config-horarios');
        if(!tb) return;
        let h = '';
        configPlantas.forEach((p, idx) => {
            let chkSab = p.sabado ? 'checked' : '';
            h += `
            <tr class="text-xs">
                <td class="p-2 font-bold text-sky-400">${p.id}</td>
                <td class="p-2">
                    <input type="number" id="cfg_inlv_${idx}" value="${p.hInLV}" class="w-12 bg-slate-900 border border-slate-700 text-center rounded text-white"> a 
                    <input type="number" id="cfg_outlv_${idx}" value="${p.hOutLV}" class="w-12 bg-slate-900 border border-slate-700 text-center rounded text-white">
                </td>
                <td class="p-2">
                    <label class="mr-2"><input type="checkbox" id="cfg_sab_${idx}" ${chkSab} onchange="toggleSabado(${idx})"> Hab.</label>
                    <input type="number" id="cfg_ins_${idx}" value="${p.hInS}" class="w-12 bg-slate-900 border border-slate-700 text-center rounded text-white ${!p.sabado ? 'opacity-30' : ''}" ${!p.sabado ? 'disabled' : ''}> a 
                    <input type="number" id="cfg_outs_${idx}" value="${p.hOutS}" class="w-12 bg-slate-900 border border-slate-700 text-center rounded text-white ${!p.sabado ? 'opacity-30' : ''}" ${!p.sabado ? 'disabled' : ''}>
                </td>
                <td class="p-2"><input type="number" id="cfg_dur_${idx}" value="${p.duracion}" class="w-16 bg-slate-900 border border-slate-700 text-center rounded text-white"></td>
                <td class="p-2 text-center text-slate-500 font-mono">OK</td>
            </tr>`;
        });
        tb.innerHTML = h;
    }

    function toggleSabado(idx) {
        let isChk = document.getElementById(`cfg_sab_${idx}`).checked;
        document.getElementById(`cfg_ins_${idx}`).disabled = !isChk;
        document.getElementById(`cfg_outs_${idx}`).disabled = !isChk;
        document.getElementById(`cfg_ins_${idx}`).classList.toggle('opacity-30', !isChk);
        document.getElementById(`cfg_outs_${idx}`).classList.toggle('opacity-30', !isChk);
    }

    function guardarConfiguracionHorarios() {
        configPlantas.forEach((p, idx) => {
            let dur = parseInt(document.getElementById(`cfg_dur_${idx}`).value) || 30;
            p.duracion = dur < 10 ? 10 : dur; 
            p.hInLV = parseInt(document.getElementById(`cfg_inlv_${idx}`).value) || 7;
            p.hOutLV = Math.max(p.hInLV + 1, parseInt(document.getElementById(`cfg_outlv_${idx}`).value) || 15);
            p.sabado = document.getElementById(`cfg_sab_${idx}`).checked;
            p.hInS = parseInt(document.getElementById(`cfg_ins_${idx}`).value) || 0;
            p.hOutS = Math.max(p.hInS, parseInt(document.getElementById(`cfg_outs_${idx}`).value) || 0);
        });
        showToast("Configuracion Guardada", "ok");
        handleHorariosChange();
        calcularDisponibilidadOffline();
    }

    function getSlotsCalculados(plantaId, fechaStr) {
        let slots = [];
        if(!fechaStr) return slots;
        let pConf = configPlantas.find(p => p.id === plantaId) || configPlantas[0];
        const d = new Date(fechaStr.replace(/-/g, '/') + ' 00:00:00');
        const day = d.getDay(); 

        if (day === 0 || (day === 6 && !pConf.sabado)) return slots;

        let startMins = (day === 6 ? pConf.hInS : pConf.hInLV) * 60;
        let endMins = (day === 6 ? pConf.hOutS : pConf.hOutLV) * 60;
        let duration = pConf.duracion;
        
        if(duration <= 0 || startMins >= endMins) return slots; 

        let current = startMins;
        while ((current + duration) <= endMins) {
            let h1 = String(Math.floor(current/60)).padStart(2,'0');
            let m1 = String(current%60).padStart(2,'0');
            let curEnd = current + duration;
            let h2 = String(Math.floor(curEnd/60)).padStart(2,'0');
            let m2 = String(curEnd%60).padStart(2,'0');
            slots.push(`${h1}:${m1} a ${h2}:${m2} h`);
            current += duration;
        }
        return slots;
    }

    function autoDia() {
        const fechaVal = document.getElementById('f_fecha').value;
        if (!fechaVal) return;
        const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
        const fecha = new Date(fechaVal.replace(/-/g, '/') + ' 00:00:00');
        document.getElementById('f_dia').textContent = dias[fecha.getDay()];
    }

    function handleHorariosChange() {
        const ind = document.getElementById('form-mode-indicator').textContent;
        const modoFiltro = ind.includes('ALTA') || ind.includes('REPROGRAMA');
        regenerarHorariosABM(modoFiltro);
        autoDia();
    }

    function regenerarHorariosABM(modoFiltroDisponibles = false) {
        const pFisica = document.getElementById('f_planta_descarga').value;
        const fecha = document.getElementById('f_fecha').value;
        const select = document.getElementById('f_horario');
        if(!select) return;

        let allSlots = getSlotsCalculados(pFisica, fecha);
        select.innerHTML = '';
        if(allSlots.length === 0) { select.innerHTML = '<option value="">Sin Operacion</option>'; return; }

        let slotsOcupados = [];
        if (modoFiltroDisponibles) {
            slotsOcupados = listaTurnosCache
                .filter(t => t.field_6 && t.field_6.startsWith(fecha) && t.PlantaDescarga === pFisica && String(t.field_7).toLowerCase() !== 'cancelado')
                .map(t => normalizarStringHorario(t.field_5));
        }

        let htmlOpts = '';
        allSlots.forEach(s => {
            if (!(modoFiltroDisponibles && slotsOcupados.includes(normalizarStringHorario(s)))) {
                htmlOpts += `<option value="${s}">${s}</option>`;
            }
        });
        if(htmlOpts === '') htmlOpts = '<option value="">Agenda Completa</option>';
        select.innerHTML = htmlOpts;
    }

    // --- CONEXION SP ---
    async function testConexion() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (res.ok) {
                const data = await res.json();
                currentLoggedUser.name = data.Title || data.DisplayName || "Usuario OK";
                document.getElementById('app-user-name').textContent = escapeHtml(currentLoggedUser.name);
            }
        } catch (err) { }
    }

    async function refrescarDBAbsoluto() {
        document.getElementById('filtro_planta_descarga').value = 'TODAS';
        document.getElementById('filtro_usuario').value = 'TODOS';
        await cargarTurnos();
    }

    async function cargarTurnos() {
        logETLStep(1, false);
        try {
            // Intento 1: Completo con Expand
            let res = await fetchSharePoint(`items?$expand=Editor,Author&$select=*,Editor/Title,Author/Title&$orderby=Created desc&$top=1000`);
            
            // Intento 2: Fallback si SP rechaza el Expand
            if (res.status === 400) {
                console.warn("SP Rechazó Expand. Intentando consulta simple...");
                res = await fetchSharePoint(`items?$orderby=Created desc&$top=1000`);
            }
            
            if (!res.ok) throw new Error("HTTP " + res.status);
            
            const data = await res.json();
            listaTurnosCache = data.value || [];
            
            logETLStep(1, true); 
            logETLStep(2, false);
            
            poblarFiltrosEstaticos(); 
            aplicarFiltrosMonitor(); 
            calcularDisponibilidadOffline(); 
            
            logETLStep(2, true); 
            console.log(`BD Sincronizada.`);
        } catch (err) { 
            console.error(`[FALLA LECTURA SP]: ${err.message}`); 
            document.getElementById('tabla-turnos').innerHTML = `<tr><td colspan="8" class="p-6 text-center text-rose-500 font-bold text-xs">Error de conexion a SharePoint. Verifique permisos o URL de la lista.</td></tr>`;
        }
    }

    // --- RENDER TABLAS ---
    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">No hay turnos.</td></tr>`;
            return;
        }

        let htmlRows = '';
        items.forEach(t => {
            const estado = escapeHtml(String(t.field_7 || 'Pendiente').trim());
            const esAprobado = estado.toLowerCase() === 'aprobado';
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : (estado.toLowerCase() === 'cancelado' ? 'text-rose-400' : 'text-amber-400');
            
            let pFisica = escapeHtml(t.PlantaDescarga || '-'); 
            let pTipo = escapeHtml(t.Planta || '-'); 
            let prov = escapeHtml(t.field_2 || '-'); 
            let pat = escapeHtml(t.Patente || '-');
            let modPor = escapeHtml(getResponsableName(t));

            htmlRows += `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                <td class="p-2 font-mono text-sky-400 font-bold">${t.Id}</td>
                <td class="p-2 text-slate-300 font-bold">${pFisica}</td>
                <td class="p-2 text-slate-400">${pTipo}</td>
                <td class="p-2 text-white font-semibold">${prov}</td>
                <td class="p-2 font-mono tracking-widest text-slate-300 bg-black/20 text-center rounded">${pat}</td>
                <td class="p-2 text-amber-300 font-mono">${escapeHtml(t.field_5 || '-')}</td>
                <td class="p-2 ${colorEst} text-center">${estado}<br><span class="text-[9px] text-slate-500 font-normal truncate block max-w-[100px] mx-auto">${modPor}</span></td>
                <td class="p-2 text-center flex justify-center gap-1">
                    <button onclick="modoABM_Ver(${t.Id})" class="bg-sky-700 hover:bg-sky-600 text-white px-2 py-1 rounded transition text-[10px] uppercase font-bold shadow">Ver</button>
                    ${!esAprobado && estado.toLowerCase() !== 'cancelado' ? `<button onclick="modoABM_Aprobar(${t.Id})" class="bg-emerald-700 hover:bg-emerald-600 text-white px-2 py-1 rounded transition text-[10px] uppercase font-bold shadow">Aprobar</button>` : ''}
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    function poblarFiltrosEstaticos() {
        const selectU = document.getElementById('filtro_usuario');
        if (selectU) {
            const usr = [...new Set(listaTurnosCache.map(t => getResponsableName(t)).filter(Boolean))].sort();
            let h = '<option value="TODOS">-- Todos --</option>';
            usr.forEach(u => { h += `<option value="${escapeHtml(u)}">${escapeHtml(u)}</option>`; });
            selectU.innerHTML = h;
        }
    }

    function aplicarFiltrosMonitor() {
        const pd = document.getElementById('filtro_planta_descarga').value;
        const u = document.getElementById('filtro_usuario').value;
        let filtrados = listaTurnosCache.filter(t => t.field_6 && String(t.field_6).split('T')[0] === fechaSeleccionadaGlobal);
        if(pd !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === pd);
        if(u !== 'TODOS') filtrados = filtrados.filter(t => getResponsableName(t) === u);
        renderizarFilas(filtrados);
    }

    function restablecerFiltros() {
        document.getElementById('filtro_planta_descarga').value = 'TODAS';
        document.getElementById('filtro_usuario').value = 'TODOS';
        aplicarFiltrosMonitor();
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
        for (let b = 0; b < (dayOfWeek === 0 ? 6 : dayOfWeek - 1); b++) calHtml += `<div class="p-1">-</div>`;

        const totalDiasMes = new Date(anio, mes + 1, 0).getDate();
        for (let dia = 1; dia <= totalDiasMes; dia++) {
            let claseEstilo = (dia === baseDate.getDate()) ? 'bg-sky-500 text-slate-900 font-bold rounded shadow' : 'text-slate-300 hover:bg-slate-800 rounded cursor-pointer transition';
            let strDia = `${anio}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
            calHtml += `<button onclick="conmutarFechaDesdeCalendario('${strDia}')" class="p-1 rounded ${claseEstilo}">${dia}</button>`;
        }
        gridContainer.innerHTML = calHtml;
    }

    function conmutarFechaDesdeCalendario(nuevaFecha) {
        fechaSeleccionadaGlobal = nuevaFecha;
        renderizarGrilaCalendario(); calcularDisponibilidadOffline(); aplicarFiltrosMonitor(); 
    }

    function normalizarStringHorario(str) { return String(str || "").toLowerCase().replace(/h/g, "").replace(/\s+/g, "").trim(); }

    function calcularDisponibilidadOffline() {
        const panel = document.getElementById('panel-disponibilidad-dinamico');
        if(!panel) return;
        const pfSeleccionada = document.getElementById('filtro_planta_descarga').value;
        let htmlPanel = '';

        configPlantas.forEach(plantaConfig => {
            if (pfSeleccionada !== 'TODAS' && plantaConfig.id !== pfSeleccionada) return;
            let ocupados = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === plantaConfig.id && String(t.field_7).toLowerCase() !== 'cancelado');
            let slotsTotales = getSlotsCalculados(plantaConfig.id, fechaSeleccionadaGlobal);
            
            if (slotsTotales.length > 0) {
                htmlPanel += `<div class="mb-3"><h4 class="text-[10px] font-bold text-sky-300 uppercase tracking-wider text-center mb-1 bg-sky-950/40 py-1 rounded">${plantaConfig.id}</h4><div class="space-y-1">`;
                slotsTotales.forEach(s => {
                    let ocupado = ocupados.find(t => normalizarStringHorario(t.field_5) === normalizarStringHorario(s));
                    if (ocupado) {
                        htmlPanel += `<div class="flex justify-between p-1.5 border border-red-900 bg-red-950/30 rounded text-[9px] font-mono text-rose-300 shadow"><span>${s.split(' ')[0]}</span><span class="font-bold tracking-wider">${escapeHtml(ocupado.Patente || 'N/A')}</span></div>`;
                    } else {
                        htmlPanel += `<div class="flex justify-between p-1.5 border border-emerald-900 bg-emerald-950/30 rounded text-[9px] font-mono text-emerald-400 shadow opacity-70"><span>${s.split(' ')[0]}</span><span class="font-bold tracking-wider opacity-50">LIBRE</span></div>`;
                    }
                });
                htmlPanel += `</div></div>`;
            }
        });
        panel.innerHTML = htmlPanel || '<div class="text-center text-slate-500 text-xs mt-4">Sin turnos.</div>';
    }

    // --- CENTRAL DE VALIDACION ---
    function limpiarErroresVisuales() {
        document.querySelectorAll('.input-error').forEach(el => el.classList.remove('input-error'));
    }
    function marcarError(id, msg) {
        const el = document.getElementById(id);
        if(el) { el.classList.add('input-error'); el.focus(); }
        showToast(msg, "err");
        return false;
    }

    function validarFormularioTurno(modo) {
        limpiarErroresVisuales();
        const fPatente = document.getElementById('f_patente').value.trim();
        const fCuit = document.getElementById('f_cuit').value.trim();
        const fProv = document.getElementById('f_proveedor').value.trim();
        const fEmail = document.getElementById('f_email').value.trim();
        const fFec = document.getElementById('f_fecha').value;
        const fHor = document.getElementById('f_horario').value;

        if(!fPatente) return marcarError('f_patente', "Patente obligatoria.");
        if(!fCuit) return marcarError('f_cuit', "Num Proveedor obligatorio.");
        let cuitLimpio = fCuit.replace(/[^0-9]/g, '');
        
        const provEnBD = listaProveedoresCache.find(p => p.id.replace(/[^0-9]/g, '') === cuitLimpio);
        if(!provEnBD && listaProveedoresCache.length > 0) return marcarError('f_cuit', "Proveedor no existe.");
        if(provEnBD && provEnBD.estado !== 'Habilitado') return marcarError('f_cuit', "Proveedor inhabilitado.");

        if(!fProv) return marcarError('f_proveedor', "Razon Social vacia.");
        if(fEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fEmail)) return marcarError('f_email', "Email invalido.");
        if(!fFec) return marcarError('f_fecha', "Fecha requerida.");
        
        if(modo === 'ALTA' || modo === 'REPROGRAMAR') {
            const hoy = new Date(); hoy.setHours(0,0,0,0);
            const selDate = new Date(fFec.replace(/-/g, '/') + ' 00:00:00');
            if(selDate < hoy) return marcarError('f_fecha', "Fecha pasada.");
        }

        if(!fHor) return marcarError('f_horario', "Seleccione horario libre.");
        return true;
    }

    // --- ESTADOS ABM ---
    function abrirAltaTurno() {
        limpiarFormularioABM();
        const inputFecha = document.getElementById('f_fecha');
        const hoyIso = new Date().toISOString().split('T')[0];
        inputFecha.value = fechaSeleccionadaGlobal >= hoyIso ? fechaSeleccionadaGlobal : hoyIso;
        inputFecha.min = hoyIso; 
        autoDia();
        handleHorariosChange();

        document.getElementById('form-mode-indicator').textContent = "ALTA DE TURNO";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-sky-900 text-sky-300 rounded-full font-bold";
        habilitarCamposABM(true);
        renderBotonesABM('ALTA');
        document.querySelector("[data-target='s1']").click();
    }

    function modoABM_Ver(id) {
        cargarTurnoEnFormulario(id);
        document.getElementById('form-mode-indicator').textContent = "CONSULTA LECTURA";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-slate-800 text-slate-300 rounded-full font-bold";
        habilitarCamposABM(false); 
        renderBotonesABM('VER');
        document.querySelector("[data-target='s1']").click();
    }

    function modoABM_Aprobar(id) {
        cargarTurnoEnFormulario(id);
        document.getElementById('form-mode-indicator').textContent = "MODO APROBACION";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-amber-900 text-amber-300 rounded-full font-bold border border-amber-500";
        habilitarCamposABM(false);
        renderBotonesABM('APROBAR_PANEL');
        document.querySelector("[data-target='s1']").click();
    }

    function modoABM_Reprogramar() {
        document.getElementById('form-mode-indicator').textContent = "REPROGRAMACION";
        habilitarCamposABM(false);
        const fFec = document.getElementById('f_fecha');
        fFec.disabled = false;
        fFec.min = new Date().toISOString().split('T')[0];
        document.getElementById('f_horario').disabled = false;
        handleHorariosChange();
        renderBotonesABM('REPROGRAMAR');
    }

    function volverTurnosDiarios() { document.querySelector("[data-target='s2']").click(); }

    function habilitarCamposABM(estado) { document.querySelectorAll('.f-control').forEach(el => el.disabled = !estado); }

    function renderBotonesABM(modo) {
        const panel = document.getElementById('panel-botones-abm');
        if (modo === 'ALTA') panel.innerHTML = `<button onclick="crearTurno()" class="bg-sky-600 hover:bg-sky-500 px-6 py-3 font-bold rounded text-white flex-1 transition shadow">Registrar Alta</button>`;
        else if (modo === 'VER') panel.innerHTML = `<button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded text-white flex-1 transition shadow">Volver a Monitor</button>`;
        else if (modo === 'APROBAR_PANEL') panel.innerHTML = `<button onclick="ejecutarAccionFlujo('Aprobado')" class="bg-emerald-600 hover:bg-emerald-500 px-4 py-3 font-bold rounded text-white flex-1 transition shadow">Aprobar Turno</button><button onclick="ejecutarAccionFlujo('Cancelado')" class="bg-rose-600 hover:bg-rose-500 px-4 py-3 font-bold rounded text-white flex-1 transition shadow">Cancelar</button><button onclick="modoABM_Reprogramar()" class="bg-amber-600 hover:bg-amber-500 px-4 py-3 font-bold rounded text-white flex-1 transition shadow">Reprogramar</button>`;
        else if (modo === 'REPROGRAMAR') panel.innerHTML = `<button onclick="ejecutarReprogramacion()" class="bg-indigo-600 hover:bg-indigo-500 px-6 py-3 font-bold rounded text-white flex-1 transition shadow">Confirmar Reprogramacion</button><button onclick="modoABM_Ver(document.getElementById('f_item_id').value)" class="bg-slate-700 hover:bg-slate-600 px-4 py-3 font-bold rounded text-white transition shadow">Abortar</button>`;
    }

    function cargarTurnoEnFormulario(id) {
        const t = listaTurnosCache.find(item => item.Id === parseInt(id));
        if (!t) return;
        limpiarErroresVisuales();
        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_patente').value = t.Patente || '';
        document.getElementById('f_hora_ing').value = t.HoraIngresoReal || '';
        document.getElementById('f_hora_sal').value = t.HoraSalidaReal || '';
        document.getElementById('f_cuit').value = t.field_1 || '';
        document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || '';
        document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('f_email').value = t.field_3 || '';
        if (t.field_6) document.getElementById('f_fecha').value = String(t.field_6).split('T')[0];
        
        autoDia();
        document.getElementById('f_planta').value = t.Planta || 'Packaging';
        document.getElementById('f_planta_descarga').value = t.PlantaDescarga || 'Parque Canuelas';
        
        regenerarHorariosABM(false);
        let slotSelect = document.getElementById('f_horario');
        if (!Array.from(slotSelect.options).some(opt => opt.value === t.field_5) && t.field_5) {
            slotSelect.add(new Option(t.field_5 + " (Asignado)", t.field_5));
        }
        slotSelect.value = t.field_5 || '';
        
        document.getElementById('f_usuario_gestor').textContent = escapeHtml(getResponsableName(t));
        const est = String(t.field_7 || 'PENDIENTE').trim().toUpperCase();
        document.getElementById('f_estado_actual').textContent = est;
        const trackEnab = (est === 'APROBADO' || est === 'REPROGRAMADO');
        document.getElementById('btn-track-in').disabled = !trackEnab;
        document.getElementById('btn-track-out').disabled = !trackEnab;
    }

    function limpiarFormularioABM() {
        limpiarErroresVisuales();
        document.getElementById('f_item_id').value = '';
        document.querySelectorAll('.f-control').forEach(i => { i.value = ''; i.disabled = true; });
        document.getElementById('f_fecha').min = '';
        document.getElementById('f_usuario_gestor').textContent = '-';
        document.getElementById('f_estado_actual').textContent = 'NUEVO';
        document.getElementById('panel-botones-abm').innerHTML = '';
        document.getElementById('btn-track-in').disabled = true;
        document.getElementById('btn-track-out').disabled = true;
    }

    async function ejecutarTransaccion(itemId, payload, msg) {
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
            
            // Auto-Healing: Si SP rechaza por campos nuevos que aun no creaste
            if (res.status === 400) {
                console.warn("SP 400: Limpiando campos extra y reintentando...");
                delete payload.Patente; delete payload.HoraIngresoReal; delete payload.HoraSalidaReal;
                options.body = JSON.stringify(payload);
                res = await fetchSharePoint(query, options);
            }

            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error("Falla HTTP " + res.status);
            
            logETLStep(3, true);
            showToast(msg, "ok");
            await cargarTurnos(); 
        } catch(e) {
            console.error(`[ERROR ESCRITURA SP]: ${e.message}`);
            if(itemId) { let obj = listaTurnosCache.find(x=>x.Id==itemId); if(obj) Object.assign(obj, payload); }
            else { listaTurnosCache.unshift({...payload, Id: Math.floor(Math.random()*1000), Editor: {Title: currentLoggedUser.name}}); }
            showToast(msg + " (Simulacion Local)", "ok");
            aplicarFiltrosMonitor(); calcularDisponibilidadOffline();
        }
    }

    async function crearTurno() {
        if(!validarFormularioTurno('ALTA')) return;
        const payload = {
            field_1: document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''), 
            field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value, 
            field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            field_7: "Pendiente", 
            N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, 
            PlantaDescarga: document.getElementById('f_planta_descarga').value,
            Dia: document.getElementById('f_dia').textContent,
            Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            HoraIngresoReal: document.getElementById('f_hora_ing').value,
            HoraSalidaReal: document.getElementById('f_hora_sal').value
        };
        await ejecutarTransaccion(null, payload, "Turno Creado");
        volverTurnosDiarios();
    }

    async function ejecutarAccionFlujo(nuevoEstado) {
        const id = document.getElementById('f_item_id').value;
        const email = document.getElementById('f_email').value;
        
        const t = listaTurnosCache.find(x => x.Id == id);
        if(t && String(t.field_7).toLowerCase() === 'cancelado' && nuevoEstado !== 'Cancelado') {
            return showToast("El turno ya fue cancelado.", "err");
        }

        await ejecutarTransaccion(id, { field_7: nuevoEstado }, `Turno ${nuevoEstado}`);
        if (email) {
            let body = `Su turno logistico ha sido ${nuevoEstado.toUpperCase()}.\nFecha: ${document.getElementById('f_fecha').value}\nHorario: ${document.getElementById('f_horario').value}`;
            window.location.href = `mailto:${email}?subject=Estado Turno: ${nuevoEstado}&body=${encodeURIComponent(body)}`;
        }
        volverTurnosDiarios();
    }

    async function ejecutarReprogramacion() {
        if(!validarFormularioTurno('REPROGRAMAR')) return;
        const id = document.getElementById('f_item_id').value;
        const fc = document.getElementById('f_fecha').value;
        const sh = document.getElementById('f_horario').value;
        await ejecutarTransaccion(id, { field_6: fc + "T00:00:00Z", field_5: sh, field_7: "Reprogramado" }, "Turno Reprogramado");
        volverTurnosDiarios();
    }

    async function marcarTrackingForm(tipo) {
        const id = document.getElementById('f_item_id').value;
        const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        let payload = {};
        if(tipo === 'IN') { payload.HoraIngresoReal = horaStr; document.getElementById('f_hora_ing').value = horaStr; }
        if(tipo === 'OUT') { payload.HoraSalidaReal = horaStr; document.getElementById('f_hora_sal').value = horaStr; }
        await ejecutarTransaccion(id, payload, `Check-${tipo} Registrado`);
    }

    // --- PROVEEDORES ---
    function procesarCSVProveedores() {
        const f = document.getElementById('file_proveedores').files[0];
        if(!f) return showToast("Falta Archivo CSV", "err");
        const r = new FileReader();
        r.onload = function(e) {
            try {
                const lines = e.target.result.split(/\r?\n|\r/);
                listaProveedoresCache = [];
                for(let i=1; i<lines.length; i++) {
                    const row = lines[i].trim();
                    if(!row) continue;
                    const cols = row.split(/,|;/); 
                    if(cols.length >= 4) {
                        listaProveedoresCache.push({ tipo: cols[0].trim(), nombre: cols[1].trim(), id: cols[2].replace(/[^0-9]/g, ''), responsable: cols[3].trim(), estado: 'Habilitado' });
                    }
                }
                renderizarBaseProveedores();
                showToast(`Padron Importado`, "ok");
            } catch(err) { showToast("Error CSV Proveedores", "err"); }
        };
        r.readAsText(f, 'ISO-8859-1');
    }

    function renderizarBaseProveedores() {
        const tb = document.getElementById('tabla-proveedores');
        if(!tb) return;
        tb.innerHTML = listaProveedoresCache.map((p, idx) => `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs cursor-pointer" onclick="cargarProvForm(${idx})">
                <td class="p-2 font-mono text-amber-400 font-bold">${escapeHtml(p.id)}</td>
                <td class="p-2 text-white font-semibold">${escapeHtml(p.nombre)}</td>
                <td class="p-2 text-slate-400">${escapeHtml(p.tipo)}</td>
                <td class="p-2 text-slate-400">${escapeHtml(p.responsable)}</td>
                <td class="p-2 font-bold ${p.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(p.estado)}</td>
                <td class="p-2 text-sky-400 underline">Editar</td>
            </tr>`).join('');
    }

    function cargarProvForm(idx) {
        const p = listaProveedoresCache[idx];
        document.getElementById('p_index').value = idx;
        document.getElementById('p_cuit').value = p.id;
        document.getElementById('p_razon').value = p.nombre;
        document.getElementById('p_tipo').value = p.tipo;
        document.getElementById('p_resp').value = p.responsable;
        document.getElementById('p_estado').value = p.estado || 'Habilitado';
    }

    function guardarEdicionProveedor() {
        const idx = document.getElementById('p_index').value;
        const pId = document.getElementById('p_cuit').value.replace(/[^0-9]/g, '');
        if(!pId) return showToast("Falta CUIT", "err");
        const obj = {
            id: pId, nombre: document.getElementById('p_razon').value,
            tipo: document.getElementById('p_tipo').value, responsable: document.getElementById('p_resp').value,
            estado: document.getElementById('p_estado').value
        };
        if(idx === '') listaProveedoresCache.push(obj);
        else listaProveedoresCache[idx] = obj;
        renderizarBaseProveedores();
        showToast("Proveedor Guardado", "ok");
    }

    function autocompletarProveedor() {
        const nProv = document.getElementById('f_cuit').value.replace(/[^0-9]/g, '');
        document.getElementById('f_cuit').value = nProv; 
        if(!nProv || listaProveedoresCache.length === 0) return;
        const provEncontrado = listaProveedoresCache.find(p => p.id === nProv);
        if(provEncontrado) {
            if(provEncontrado.estado === 'Habilitado') {
                document.getElementById('f_proveedor').value = provEncontrado.nombre;
                if(provEncontrado.tipo.toLowerCase().includes('insumo')) document.getElementById('f_planta').value = 'Insumos';
                else if(provEncontrado.tipo.toLowerCase().includes('pack')) document.getElementById('f_planta').value = 'Packaging';
                showToast(`Auto-Completado OK`, "ok");
            } else { marcarError('f_cuit', "PROVEEDOR INHABILITADO"); }
        }
    }

    // --- ETL & LOGS ---
    function logETLStep(stepNum, isDone=false) {
        const steps = ['etl-extract', 'etl-transform', 'etl-load'];
        const ic = ['etl-ic1', 'etl-ic2', 'etl-ic3'];
        steps.forEach((s, idx) => {
            let el = document.getElementById(s);
            if(!el) return;
            if(idx === stepNum-1) {
                el.classList.add('active');
                if(isDone) { el.classList.add('done'); document.getElementById(ic[idx]).innerHTML = '✔'; }
            } else { el.classList.remove('active'); }
        });
    }

    function showToast(msg, type) {
        const t = document.getElementById('toast');
        if(!t) return; t.textContent = msg; t.className = `show ${type}`;
        setTimeout(() => t.className = '', 3000);
    }

    initApp();
</script>
</body>
</html>