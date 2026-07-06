<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consola Maestra | Logistica de Turnos Molca Spegazzini</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Syne:wght@400;600;700;800&display=swap');
        :root {
            --sp-blue:   #38bdf8;
            --sp-green:  #4ade80;
            --sp-amber:  #fbbf24;
            --sp-red:    #f87171;
            --sp-bg:     #0b1120;
            --sp-panel:  rgba(15, 23, 42, 0.92);
            --sp-border: rgba(56, 189, 248, 0.15);
        }

        * { box-sizing: border-box; }
        body { font-family: 'Syne', sans-serif; background-color: var(--sp-bg); color: #e2e8f0; margin: 0; font-size: 1rem; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .glass { background: var(--sp-panel); border: 1px solid var(--sp-border); backdrop-filter: blur(12px); }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.2s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
        
        .tab-btn { color: #94a3b8; transition: background .15s, color .15s; font-size: 0.95rem; }
        .tab-btn:hover { background: #1e293b; color: #fff; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; }

        #toast { position: fixed; bottom: 1.5rem; right: 1.5rem; padding: .6rem 1.2rem; border-radius: 8px; font-size: .9rem; font-weight: 600; opacity: 0; transition: opacity .3s; z-index: 9999; pointer-events: none; }
        #toast.show { opacity: 1; }
        #toast.ok   { background:#166534; border:1px solid #4ade80; color:#4ade80; }
        #toast.err  { background:#7f1d1d; border:1px solid #f87171; color:#f87171; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

<aside class="w-64 glass flex flex-col p-4 border-r h-full z-10" style="border-color: var(--sp-border)">
    <h1 class="text-xl font-bold text-white mb-1">Programacion de Turnos <span style="color:var(--sp-blue)">Molca</span></h1>
    <div class="mb-5 text-xs inline-flex items-center gap-2 p-1.5 rounded-full" style="background:rgba(0,0,0,.4); border:1px solid #334155;">
        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
        <span class="font-bold text-emerald-400">Online API REST</span>
    </div>

    <nav class="space-y-1 flex-1">
        <button class="w-full text-left px-4 py-2 rounded tab-btn active-tab" data-target="s2">1. Turnos del Dia</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s1">2. Captura y Consulta</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s6">3. Base Proveedores</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s7">4. Importar Excel</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s5">5. Log Terminal</button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto relative">

    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50">
        <span class="text-slate-400 font-semibold">Usuario Conectado:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Verificando API...</span>
    </div>

    <section id="s1" class="tab-content mt-10">
        <div class="flex items-center justify-between mb-4 max-w-4xl">
            <h2 class="text-2xl font-bold" style="color:var(--sp-blue)">Gestion de Solicitud de Turnos</h2>
            <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1 rounded-full font-bold bg-emerald-950/60 text-emerald-400 border border-emerald-500/30">
                Modo: Nuevo Registro (Alta)
            </div>
        </div>
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4 text-base relative">
            <input type="hidden" id="f_item_id" value="">
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">CUIT</label>
                <input type="text" id="f_cuit" placeholder="XX-XXXXXXXX-X" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Numero OC</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Nombre Proveedor</label>
                <input type="text" id="f_proveedor" placeholder="Razon Social" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Fecha Solicitud</label>
                <input type="date" id="f_fecha" onchange="autoDia();" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Dia</label>
                <input type="text" id="f_dia" readonly placeholder="Auto" class="w-full bg-slate-950 border border-slate-800 rounded p-3 text-slate-400 outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Planta Destino</label>
                <select id="f_planta" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                </select>
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Horario (Modulos 45 min)</label>
                <select id="f_horario" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none transition-all focus:border-sky-500"></select>
            </div>
            
            <div class="col-span-2 grid grid-cols-3 gap-4 mt-4">
                <button id="btn-alta" onclick="crearTurno()" class="font-bold py-3.5 rounded transition bg-sky-500 hover:bg-sky-400 text-slate-950 text-base">
                    ➕ Registrar Alta (Inyectar)
                </button>
                <button id="btn-modificar" onclick="guardarCambiosTurno()" disabled class="font-bold py-3.5 rounded transition bg-amber-500 hover:bg-amber-400 text-slate-950 text-base opacity-40 cursor-not-allowed">
                    💾 Guardar Cambios
                </button>
                <button onclick="limpiarFormularioABM()" class="font-bold py-3.5 rounded transition bg-slate-800 hover:bg-slate-700 text-slate-300 text-base border border-slate-700">
                    🧹 Limpiar Panel
                </button>
            </div>
        </div>
    </section>

    <section id="s2" class="tab-content active mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Monitor de Turnos | SharePoint en Linea</h2>
        
        <div class="grid grid-cols-5 gap-6">
            <div class="col-span-3 glass p-6 rounded-xl h-[720px] overflow-y-auto">
                <div class="flex justify-between mb-4 items-center">
                    <span class="text-sm text-slate-400">Lista conectada: <strong>Turnos Proveedores</strong></span>
                    <div class="flex gap-2">
                        <button onclick="filtrarPorPlanta('Packaging')" class="bg-sky-900/60 border border-sky-500/30 text-sky-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-sky-900">Planta PK</button>
                        <button onclick="filtrarPorPlanta('Insumos')" class="bg-amber-900/60 border border-amber-500/30 text-amber-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-amber-900">Planta IN</button>
                        <button onclick="restablecerFiltro()" class="bg-slate-800 border border-slate-700 text-slate-300 px-3 py-1.5 rounded text-xs font-bold hover:bg-slate-700">Ver Todos</button>
                        <button onclick="cargarTurnos()" class="bg-slate-700 px-4 py-1.5 rounded text-xs font-bold text-white hover:bg-slate-600">↻ Refrescar</button>
                    </div>
                </div>
                
                <div class="overflow-x-auto text-base">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="bg-slate-800 text-xs uppercase text-slate-400 font-bold border-b border-slate-700">
                            <tr>
                                <th class="py-3.5 px-3">ID Unico</th>
                                <th class="px-3">Proveedor</th>
                                <th class="px-3">Planta</th>
                                <th class="px-3">Num_OC</th>
                                <th class="px-3">Fecha / Creacion</th>
                                <th class="px-3">Horario</th>
                                <th class="px-3">Estado</th>
                                <th class="px-3 text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                            <tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Construyendo grilla visual...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-span-2 glass p-4 rounded-xl flex flex-col h-[720px] overflow-hidden">
                <h3 class="text-base font-bold text-sky-400 uppercase tracking-wider text-center mb-1">Turnos Disponibles x Planta</h3>
                
                <div class="bg-slate-950/80 p-3 rounded-lg border border-slate-800 mb-3 text-xs">
                    <div class="flex justify-between items-center mb-2 px-1">
                        <span id="calendar-month-title" class="font-bold text-white uppercase tracking-wide">MES AÑO</span>
                        <div class="text-[10px] text-slate-400 font-semibold font-mono">MOLCA SPEGAZZINI</div>
                    </div>
                    <div class="grid grid-cols-7 text-center font-bold text-slate-500 uppercase tracking-wider mb-1 text-[10px]">
                        <span>Lu</span><span>Ma</span><span>Mi</span><span>Ju</span><span>Vi</span><span>Sa</span><span>Do</span>
                    </div>
                    <div id="calendar-days-grid" class="grid grid-cols-7 gap-1 text-center font-mono font-bold"></div>
                </div>
                
                <div class="grid grid-cols-2 gap-3 flex-1 overflow-y-auto pr-1">
                    <div>
                        <h4 class="text-xs font-bold text-sky-400 uppercase tracking-wider text-center mb-2 p-1.5 bg-sky-950/40 rounded border border-sky-500/20">Packaging (PK)</h4>
                        <div id="slots-container-packaging" class="space-y-1.5"></div>
                    </div>
                    <div>
                        <h4 class="text-sm font-bold text-amber-400 uppercase tracking-wider text-center mb-2 p-1.5 bg-amber-950/40 rounded border border-amber-500/20">Insumos (IN)</h4>
                        <div id="slots-container-insumos" class="space-y-1.5"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section id="s6" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Base de Datos Maestro de Proveedores</h2>
        <div class="glass p-6 rounded-xl text-base">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-xs uppercase text-slate-400 font-bold">
                        <tr>
                            <th class="py-3 px-3">CUIT / Num Prov</th>
                            <th class="px-3">Razon Social / Proveedor</th>
                            <th class="px-3">Tipo Insumo</th>
                            <th class="px-3">Responsable Relacionado</th>
                            <th class="px-3">Email de Contacto</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-proveedores" class="divide-y divide-slate-700/50">
                        <tr><td colspan="5" class="p-6 text-center text-slate-500 text-xs">Procesando pool de datos...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section id="s7" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Carga masiva - Base de Datos de Proveedores</h2>
        <div class="glass p-6 rounded-xl max-w-4xl space-y-6">
            <p class="text-sm text-slate-400">
                Selecciona un archivo Excel <code class="text-sky-400 font-mono">.xlsx</code> para importar de manera directa el pool logístico. El sistema mapeará y sanitizará las columnas de forma automática:
            </p>
            <div class="grid grid-cols-4 gap-2 text-center text-xs font-mono font-bold uppercase">
                <div class="p-2.5 bg-slate-900 border border-slate-800 rounded text-slate-300">Tipo Insumo</div>
                <div class="p-2.5 bg-slate-900 border border-slate-800 rounded text-slate-300">Nombre proveedor</div>
                <div class="p-2.5 bg-slate-900 border border-slate-800 rounded text-slate-300">Nº proveedor</div>
                <div class="p-2.5 bg-slate-900 border border-slate-800 rounded text-slate-300">Responsable</div>
            </div>
            <div class="border-2 border-dashed border-slate-700 rounded-xl p-8 flex flex-col items-center justify-center bg-slate-950/30 hover:border-sky-500/50 transition-colors relative">
                <input type="file" id="excel-file-input" accept=".xlsx, .xls, .csv" class="absolute inset-0 opacity-0 cursor-pointer" onchange="procesarArchivoExcel(event)">
                <span class="text-3xl mb-2">📁</span>
                <span id="excel-file-label" class="text-sm font-semibold text-slate-300">Arrastra tu archivo proveedores.xlsx o haz clic para buscar</span>
                <span class="text-xs text-slate-500 mt-1">Soporta formatos XLSX, XLS y CSV</span>
            </div>
            
            <div id="excel-preview-box" class="hidden space-y-3">
                <div class="flex items-center justify-between">
                    <h3 class="text-sm font-bold uppercase tracking-wider text-amber-400">Vista previa de datos detectados</h3>
                    <button onclick="inyectarProveedoresImportados()" class="bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold px-4 py-2 rounded text-xs transition-transform">
                        🚀 Validar e Inyectar en Base Activa
                    </button>
                </div>
                <div class="overflow-y-auto max-h-60 border border-slate-800 rounded-lg text-xs">
                    <table class="w-full text-left text-slate-300">
                        <thead class="bg-slate-900 sticky top-0 text-slate-400 font-bold border-b border-slate-800">
                            <tr>
                                <th class="p-2">Tipo Insumo</th>
                                <th class="p-2">Nombre Proveedor</th>
                                <th class="p-2">Nº Proveedor</th>
                                <th class="p-2">Responsable</th>
                            </tr>
                        </thead>
                        <tbody id="excel-preview-tbody" class="divide-y divide-slate-800/40 bg-slate-950/20"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>

    <section id="s5" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Consola de Diagnostico / Terminal Master</h2>
        <div class="glass p-4 rounded-xl space-y-4 text-xs">
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Modo Debug: Monitoreo de Procesos Internos</h3>
                <div id="debug-log" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded border border-slate-700" style="color:#38bdf8"></div>
            </div>
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Consola de Log Usuario</h3>
                <div id="user-logs" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded border border-slate-700" style="color:#fbbf24"></div>
            </div>
        </div>
    </section>

</main>

<div id="mailModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm hidden items-center justify-center z-50">
    <div class="bg-slate-900 border border-slate-700 w-full max-w-2xl rounded-xl p-6 shadow-2xl text-base">
        <div class="flex justify-between items-center border-b border-slate-700 pb-3 mb-4">
            <h3 class="text-base font-bold text-sky-400 uppercase tracking-wider flex items-center gap-2">
                <span>&#9993;</span> Redaccion de Correo al Proveedor
            </h3>
            <button onclick="cerrarModalMail()" class="text-slate-400 hover:text-white font-bold">&times;</button>
        </div>
        <div class="space-y-3 text-sm">
            <div class="grid grid-cols-6 items-center">
                <span class="col-span-1 text-slate-400 font-bold uppercase">DE:</span>
                <input type="text" id="m_de" class="col-span-5 bg-slate-950 border border-slate-800 p-2.5 rounded text-white outline-none font-mono">
            </div>
            <div class="grid grid-cols-6 items-center">
                <span class="col-span-1 text-slate-400 font-bold uppercase">PARA:</span>
                <input type="text" id="m_para" class="col-span-5 bg-slate-950 border border-slate-800 p-2.5 rounded text-white outline-none">
            </div>
            <div class="grid grid-cols-6 items-center">
                <span class="col-span-1 text-slate-400 font-bold uppercase">ASUNTO:</span>
                <input type="text" id="m_asunto" class="col-span-5 bg-slate-950 border border-slate-800 p-2.5 rounded text-white outline-none">
            </div>
            <div>
                <label class="block text-slate-400 font-bold uppercase mb-1">CUERPO DEL MENSAJE:</label>
                <textarea id="m_cuerpo" rows="8" class="w-full bg-slate-950 border border-slate-800 p-3 rounded text-white font-mono outline-none resize-none"></textarea>
            </div>
        </div>
        <div class="flex justify-end gap-3 mt-5 border-t border-slate-700 pt-3">
            <button onclick="cerrarModalMail()" class="bg-slate-800 hover:bg-slate-700 px-4 py-2 rounded text-xs font-bold text-slate-300">Abortar</button>
            <button id="btnEnviarMailFinal" class="bg-sky-600 hover:bg-sky-500 px-5 py-2.5 rounded text-xs font-bold text-slate-950">Despachar Correo</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script>
    const relativeSiteUrl = "/sites/GestiondeTurnos";
    const targetListName = 'Turnos Proveedores';
    
    let listaTurnosCache = [];
    let proveedoresImportadosExcel = []; // Pool de datos para la carga masiva
    const slotsHorarios = [];
    let transicionPendienteCtx = null;
    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Usuario", email: "logistica@grupocanuelas.com" };

    // ==========================================
    // NUEVA FUNCION: SANITIZACION DE CARACTERES
    // ==========================================
    function limpiarCaracteresRaros(str) {
        if (!str) return "";
        return String(str)
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "") // Remueve acentos y diéresis
            .replace(/[^a-zA-Z0-9\s.\-_():@\/]/g, ""); // Permite solo alfanuméricos y puntuación básica
    }

    function initApp() {
        try {
            logDebug("Iniciando Renderizado Optimista (UI-First)...");
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.toISOString().split('T')[0];
            generarSlots45Min();
            
            const inputFecha = document.getElementById('f_fecha');
            if(inputFecha) inputFecha.value = fechaSeleccionadaGlobal;
            const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
            const fechaObj = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00');
            document.getElementById('f_dia').value = dias[fechaObj.getDay()];

            inicializarRuteoPestañas();

            listaTurnosCache = obtenerDatosMockDeRescate();
            renderizarFilas(listaTurnosCache);
            renderizarBaseProveedores();
            renderizarGrilaCalendario();
            calcularDisponibilidadOffline();
            logDebug("UI interactiva renderizada con exito al milisegundo 0.");
            setTimeout(() => { resolverUsuarioLogueado(); }, 50);
            setTimeout(() => { cargarTurnos(); }, 100);

        } catch (err) {
            logDebug("Critical Error UI-First: " + err.message);
        }
    }

    function obtenerDatosMockDeRescate() {
        return [
            { Id: 17, Title: "TNPK17", field_1: "20-25987412-3", field_2: "Franco SRL", N_x00b0__x0020_de_x0020_OC: "1011", field_6: "2026-06-08", field_5: "08:00 h a 08:45 h", field_7: "Pendiente", Planta: "Packaging", Created: "2026-06-08T04:06:08Z", field_3: "franco@logistica.com" },
            { Id: 16, Title: "TNPK16", field_1: "20-25987412-3", field_2: "Franco SRL", N_x00b0__x0020_de_x0020_OC: "1010", field_6: "2026-06-08", field_5: "08:00 h a 08:45 h", field_7: "Aprobado", Planta: "Packaging", Created: "2026-06-08T03:46:40Z", field_3: "franco@logistica.com" },
            { Id: 15, Title: "TNPK15", field_1: "27-30444555-2", field_2: "PEQL Transporte", N_x00b0__x0020_de_x0020_OC: "1008", field_6: "2026-06-08", field_5: "08:00 h a 08:45 h", field_7: "Aprobado", Planta: "Packaging", Created: "2026-06-08T03:45:10Z", field_3: "peql@transportes.com" }
        ];
    }

    function logDebug(msg) {
        const area = document.getElementById('debug-log');
        if(!area) return;
        const ts = new Date().toLocaleTimeString();
        area.insertAdjacentHTML('beforeend', `<div>[${ts}] ${limpiarCaracteresRaros(msg)}</div>`);
        area.scrollTop = area.scrollHeight;
    }

    function userLog(msg, tipoIngreso = 'MANUAL') {
        const logUserArea = document.getElementById('user-logs');
        if (!logUserArea) return;
        const tsComplete = new Date().toLocaleString();
        logUserArea.insertAdjacentHTML('beforeend', `<div class="mb-1"><span class="text-slate-500">[${tsComplete}]</span> <span class="text-sky-400 font-bold">[${tipoIngreso}]</span> <span class="text-white font-semibold">${currentLoggedUser.name}:</span> ${limpiarCaracteresRaros(msg)}</div>`);
        logUserArea.scrollTop = logUserArea.scrollHeight;
    }

    function inicializarRuteoPestañas() {
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
                btn.classList.add('active-tab');
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
              
                const target = btn.dataset.target;
                const elementTarget = document.getElementById(target);
                if(elementTarget) elementTarget.classList.add('active');
                
                if (target === 's6') renderizarBaseProveedores();
            });
        });
    }

    async function resolverUsuarioLogueado() {
        logDebug("Resolviendo contexto de red...");
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, {
                headers: { "Accept": "application/json;odata=nometadata" }
            });
            if (res.ok) {
                const data = await res.json();
                currentLoggedUser.name = limpiarCaracteresRaros(data.Title || data.DisplayName);
                currentLoggedUser.email = data.Email || data.UserPrincipalName;
                document.getElementById('app-user-name').textContent = currentLoggedUser.name;
                logDebug("Validacion M365 OK.");
            }
        } catch(e) {
            document.getElementById('app-user-name').textContent = currentLoggedUser.name + " (Local)";
            logDebug("API User offline o promesa pendiente.");
        }
    }

    async function cargarTurnos() {
        logDebug("Sincronizando con matriz maestra en SharePoint...");
        try {
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$select=Id,Title,field_1,field_2,N_x00b0__x0020_de_x0020_OC,field_6,field_5,field_7,Created,Planta,field_3&$orderby=Created desc&$top=50`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (!res.ok) throw new Error("Falla de API");
            const data = await res.json();
            listaTurnosCache = data.value || [];
            renderizarFilas(listaTurnosCache);
            renderizarBaseProveedores();
            renderizarGrilaCalendario();
            calcularDisponibilidadOffline();
            logDebug("Datos descargados e inyectados.");
        } catch (err) {
            logDebug("SharePoint bloqueo peticion o la red expiro. Interfaz sobrevive con datos locales.");
        }
    }

    function generarSlots45Min() {
        slotsHorarios.length = 0;
        let inicio = 8 * 60; 
        const fin = 16 * 60 + 15;
        while (inicio + 45 <= fin) {
            let hhInicio = Math.floor(inicio / 60).toString().padStart(2, '0');
            let mmInicio = (inicio % 60).toString().padStart(2, '0');
            inicio += 45;
            let hhFin = Math.floor(inicio / 60).toString().padStart(2, '0');
            let mmFin = (inicio % 60).toString().padStart(2, '0');
            slotsHorarios.push(`${hhInicio}:${mmInicio} a ${hhFin}:${mmFin}`);
        }
        
        const selectHorario = document.getElementById('f_horario');
        if(selectHorario) {
            let optsHtml = '';
            slotsHorarios.forEach(slot => { optsHtml += `<option value="${slot}">${slot}</option>`; });
            selectHorario.innerHTML = optsHtml;
        }
    }

    function renderizarGrilaCalendario() {
        const gridContainer = document.getElementById('calendar-days-grid');
        const titleContainer = document.getElementById('calendar-month-title');
        if (!gridContainer || !titleContainer) return;

        const baseDate = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00');
        const anio = baseDate.getFullYear();
        const mes = baseDate.getMonth(); 

        const mesesNombres = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
        titleContainer.textContent = `${mesesNombres[mes]} ${anio}`;

        const primerDiaMes = new Date(anio, mes, 1);
        let dayOfWeek = primerDiaMes.getDay();
        let despilfaroBlanco = dayOfWeek === 0 ? 6 : dayOfWeek - 1; 

        let calHtml = '';
        if (despilfaroBlanco > 0 && despilfaroBlanco < 7) {
            for (let b = 0; b < despilfaroBlanco; b++) {
                calHtml += `<div class="p-1 text-transparent select-none">-</div>`;
            }
        }

        const totalDiasMes = new Date(anio, mes + 1, 0).getDate();
        const diaActualSeleccionado = baseDate.getDate();

        for (let dia = 1; dia <= totalDiasMes; dia++) {
            let esSeleccionado = (dia === diaActualSeleccionado);
            let claseEstilo = esSeleccionado 
                ? 'bg-sky-500 text-slate-950 font-extrabold rounded shadow font-bold' 
                : 'text-slate-300 hover:bg-slate-800 rounded cursor-pointer transition-colors';
            let stringDiaFormato = `${anio}-${(mes + 1).toString().padStart(2, '0')}-${dia.toString().padStart(2, '0')}`;
            calHtml += `<button onclick="conmutarFechaDesdeCalendario('${stringDiaFormato}')" class="p-1 text-center text-xs transition-all ${claseEstilo}">${dia}</button>`;
        }
        gridContainer.innerHTML = calHtml;
    }

    function conmutarFechaDesdeCalendario(nuevaFechaString) {
        fechaSeleccionadaGlobal = nuevaFechaString;
        const inputFecha = document.getElementById('f_fecha');
        if(inputFecha) inputFecha.value = nuevaFechaString;
        
        const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
        const fecha = new Date(nuevaFechaString.replace(/-/g, '/') + ' 00:00:00');
        document.getElementById('f_dia').value = dias[fecha.getDay()];

        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="8" class="p-4 text-center text-slate-500 text-xs">No se encontraron turnos logísticos.</td></tr>`;
            return;
        }

        let htmlRows = '';
        items.forEach(t => {
            let statusColor = 'text-amber-400';
            let filaGrisadaStyle = ""; 
            let isDisabled = "";
            let btnOpa = "hover:scale-125";

            const estadoLimpio = t.field_7 ? String(t.field_7).trim().toLowerCase() : 'pendiente';

            if (estadoLimpio === 'pendiente') {
                filaGrisadaStyle = "opacity-45 bg-slate-950/20 grayscale-[30%]";
                statusColor = 'text-amber-500 font-medium';
            } else if (estadoLimpio === 'aprobado') {
                statusColor = 'text-emerald-400 font-bold';
                isDisabled = "disabled style='opacity: 0.15; pointer-events: none;'";
                btnOpa = "";
            } else {
                statusColor = 'text-rose-400';
            }

            let plantaDisplay = t.Planta ? String(t.Planta) : 'Packaging'; 
            let codigoPlanta = (plantaDisplay.toLowerCase() === 'insumos') ? 'IN' : 'PK';
            let idInteligente = `TN${codigoPlanta}${t.Id}`;

            let timestampCreacionReal = t.Created ? new Date(t.Created).toLocaleString() : 'No registrado';
            let fechaSolicitada = t.field_6 ? String(t.field_6).split('T')[0] : '-';

            let pEmail = t.field_3 ? String(t.field_3).replace(/'/g, "\\'") : '-';
            // APLICAMOS SANITIZACION AL RENDERIZAR NOMBRES DE PROVEEDORES
            let pProv = t.field_2 ? limpiarCaracteresRaros(String(t.field_2).replace(/'/g, "\\'")) : '-';
            
            htmlRows += `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 transition-all ${filaGrisadaStyle}">
                <td class="py-3 px-3 font-mono font-bold text-sky-400">
                    <div class="flex items-center gap-2">
                        <button onclick="consultarTurnoAlFormulario(${t.Id})" class="text-emerald-400 hover:text-white hover:scale-125 transition-transform text-sm" title="Consultar / Cargar en Panel">&#128065;</button>
                        <button onclick="abrirClienteMailManual('${pEmail}', '${pProv}', '${fechaSolicitada}', '${t.field_7 || 'Pendiente'}')" class="text-sky-400 hover:text-white transition-colors text-xs hover:scale-125" title="Redactar Correo Manual">&#9993;</button>
                        <span>${idInteligente}</span>
                    </div>
                </td>
                <td class="px-3 text-white font-semibold">${pProv}</td>
                <td class="px-3 font-mono text-xs font-bold text-slate-400">${plantaDisplay}</td>
                <td class="px-3 text-slate-400 font-mono">${t.N_x00b0__x0020_de_x0020_OC || '-'}</td>
                <td class="px-3 text-xs text-slate-300">Sol: ${fechaSolicitada}<br/><span class="text-[10px] text-slate-500">Alta: ${timestampCreacionReal}</span></td>
                <td class="px-3 text-sky-400 font-mono">${t.field_5 || '-'}</td>
                <td class="px-3 ${statusColor}">${t.field_7 || 'Pendiente'}</td>
                <td class="px-3 text-center">
                    <div class="flex items-center justify-center gap-3 text-base">
                        <button ${isDisabled} onclick="interceptarCambioEstado(${t.Id}, '${idInteligente}', 'Aprobado', '${pEmail}', '${pProv}', '${fechaSolicitada}')" class="${btnOpa} transition-transform" title="Aprobar">&#9989;</button>
                        <button ${isDisabled} onclick="interceptarCambioEstado(${t.Id}, '${idInteligente}', 'Cancelado', '${pEmail}', '${pProv}', '${fechaSolicitada}')" class="${btnOpa} transition-transform" title="Cancelar">&#10060;</button>
                        <button ${isDisabled} onclick="eliminarTurnoServidor(${t.Id}, '${idInteligente}', '${pProv}')" class="${btnOpa} transition-transform text-rose-500" title="Eliminar y Liberar Turno">&#128465;</button>
                    </div>
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    function normalizarStringHorario(str) {
        if (!str) return "";
        return String(str).toLowerCase().replace(/h/g, "").replace(/\s+/g, "").trim();
    }

    function calcularDisponibilidadOffline() {
        const containerPkg = document.getElementById('slots-container-packaging');
        const containerIns = document.getElementById('slots-container-insumos');
        if(!containerPkg || !containerIns) return;

        const fechaFiltro = fechaSeleccionadaGlobal;
        let htmlPkg = '';
        let htmlIns = '';
        slotsHorarios.forEach(slot => {
            let resPkg = obtenerEntidadTurnoSlot('packaging', slot, fechaFiltro);
            htmlPkg += generarTarjetaSemaforoHTML(slot, resPkg.estado, resPkg.visualId);

            let resIns = obtenerEntidadTurnoSlot('insumos', slot, fechaFiltro);
            htmlIns += generarTarjetaSemaforoHTML(slot, resIns.estado, resIns.visualId);
        });
        containerPkg.innerHTML = htmlPkg;
        containerIns.innerHTML = htmlIns;
    }

    function obtenerEntidadTurnoSlot(planta, slot, fecha) {
        if(!listaTurnosCache || listaTurnosCache.length === 0) return { estado: 'Libre', visualId: '' };
        const coincidencia = listaTurnosCache.find(t => 
            t.field_6 && String(t.field_6).split('T')[0] === fecha && 
            normalizarStringHorario(t.field_5) === normalizarStringHorario(slot) && 
            (t.Planta ? String(t.Planta).toLowerCase() : 'packaging') === planta.toLowerCase()
        );
        if (!coincidencia || !coincidencia.field_7) return { estado: 'Libre', visualId: '' };
        
        const st = String(coincidencia.field_7).trim().toLowerCase();
        if (st === 'cancelado' || st === 'anulado') return { estado: 'Libre', visualId: '' };
        
        let pDisp = coincidencia.Planta ? String(coincidencia.Planta) : 'Packaging';
        let cPlanta = (pDisp.toLowerCase() === 'insumos') ? 'IN' : 'PK';
        let idInteligente = `TN${cPlanta}${coincidencia.Id}`;
        return { estado: String(coincidencia.field_7).trim(), visualId: idInteligente }; 
    }

    function generarTarjetaSemaforoHTML(slot, estado, visualId) {
        let bgStyle = "";
        let labelStatus = "";
        let idSubBlock = "";
        let stLimpio = estado ? String(estado).toLowerCase() : 'libre';
        if (stLimpio === 'aprobado') {
            bgStyle = 'bg-red-600 border-red-500 text-white font-bold tracking-wide';
            labelStatus = 'Ocupado';
            idSubBlock = `<span class="text-[10px] px-1 bg-black/30 rounded text-sky-300 font-bold font-mono">${visualId}</span>`;
        } else if (stLimpio === 'pending' || stLimpio === 'pendiente') {
            bgStyle = 'bg-amber-500 border-amber-400 text-slate-950 font-bold tracking-wide';
            labelStatus = 'En Revision';
            idSubBlock = `<span class="text-[10px] px-1 bg-black/20 rounded text-slate-800 font-bold font-mono">${visualId}</span>`;
        } else {
            bgStyle = 'bg-emerald-600 border-emerald-500 text-white font-bold tracking-wide';
            labelStatus = 'Libre';
            idSubBlock = `<span></span>`;
        }

        return `
            <div class="flex items-center justify-between p-2 border rounded text-sm font-mono ${bgStyle} shadow-md transition-all">
                <span>${String(slot).split(' ')[0]}</span>
                ${idSubBlock}
                <span class="text-[9px] uppercase tracking-wider bg-black/20 px-1.5 py-0.5 rounded font-extrabold">${labelStatus}</span>
            </div>`;
    }

    function consultarTurnoAlFormulario(itemId) {
        const idNumerico = parseInt(itemId, 10);
        const t = listaTurnosCache.find(item => parseInt(item.Id, 10) === idNumerico);
        if (!t) return;

        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_cuit').value = t.field_1 ? String(t.field_1).trim() : '';
        document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC ? String(t.N_x00b0__x0020_de_x0020_OC).trim() : '';
        document.getElementById('f_proveedor').value = limpiarCaracteresRaros(t.field_2 ? String(t.field_2).trim() : '');
        document.getElementById('f_email').value = t.field_3 ? String(t.field_3).trim() : '';
        
        if (t.field_6) {
            document.getElementById('f_fecha').value = String(t.field_6).split('T')[0];
        }
        autoDia();
        
        document.getElementById('f_planta').value = t.Planta ? String(t.Planta) : 'Packaging';
        document.getElementById('f_horario').value = t.field_5 ? String(t.field_5).trim() : '';

        const estadoLimpio = t.field_7 ? String(t.field_7).trim().toLowerCase() : 'pendiente';
        const ind = document.getElementById('form-mode-indicator');
        if (estadoLimpio === 'aprobado') {
            ind.textContent = `Modo: Consulta Exclusiva (Turno APROBADO) 🔒`;
            ind.className = "text-xs uppercase px-3 py-1 rounded-full font-bold bg-red-950/60 text-red-400 border border-red-500/30";
            setFormInputsReadOnly(true);
            document.getElementById('btn-modificar').disabled = true;
            document.getElementById('btn-modificar').classList.add('opacity-40', 'cursor-not-allowed');
        } else {
            ind.textContent = `Modo: Edicion Activa (Turno PENDIENTE) ✏️`;
            ind.className = "text-xs uppercase px-3 py-1 rounded-full font-bold bg-amber-950/60 text-amber-400 border border-amber-500/30";
            setFormInputsReadOnly(false);
            document.getElementById('btn-modificar').disabled = false;
            document.getElementById('btn-modificar').classList.remove('opacity-40', 'cursor-not-allowed');
        }

        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
        document.querySelector("[data-target='s1']").classList.add('active-tab');
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.getElementById('s1').classList.add('active');
        showToast(`Turno TN-${t.Id} cargado en el panel`, "ok");
    }

    function setFormInputsReadOnly(isReadOnly) {
        const inputs = ['f_cuit', 'f_oc', 'f_proveedor', 'f_email', 'f_fecha'];
        inputs.forEach(id => {
            const el = document.getElementById(id);
            if(el) el.readOnly = isReadOnly;
        });
        document.getElementById('f_planta').disabled = isReadOnly;
        document.getElementById('f_horario').disabled = isReadOnly;
    }

    function limpiarFormularioABM() {
        document.getElementById('f_item_id').value = '';
        document.querySelectorAll('#s1 input:not([readonly])').forEach(i => i.value = '');
        setFormInputsReadOnly(false);
        
        const ind = document.getElementById('form-mode-indicator');
        ind.textContent = `Modo: Nuevo Registro (Alta)`;
        ind.className = "text-xs uppercase px-3 py-1 rounded-full font-bold bg-emerald-950/60 text-emerald-400 border border-emerald-500/30";
        
        document.getElementById('btn-modificar').disabled = true;
        document.getElementById('btn-modificar').classList.add('opacity-40', 'cursor-not-allowed');
    }

    async function guardarCambiosTurno() {
        const itemId = document.getElementById('f_item_id').value;
        if (!itemId) return;

        const cuit = document.getElementById('f_cuit').value.trim();
        const oc = document.getElementById('f_oc').value.trim();
        const prov = limpiarCaracteresRaros(document.getElementById('f_proveedor').value.trim());
        const email = document.getElementById('f_email').value.trim();
        const fecha = document.getElementById('f_fecha').value;
        const horario = document.getElementById('f_horario').value;
        const planta = document.getElementById('f_planta').value;

        if (!cuit || !oc || !prov || !fecha) {
            showToast("Complete los campos obligatorios.", "err");
            return;
        }

        const digest = await getDigest();
        const updatePayload = {
            "field_1": cuit, "N_x00b0__x0020_de_x0020_OC": oc, "field_2": prov, "field_3": email,
            "field_6": fecha + "T00:00:00Z", "field_5": horario, "Planta": planta
        };
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})`, {
                method: 'POST',
                headers: {
                    "Accept": "application/json;odata=nometadata", "Content-Type": "application/json",
                    "X-RequestDigest": digest, "X-HTTP-Method": "MERGE", "If-Match": "*"
                },
                body: JSON.stringify(updatePayload)
            });
            if (res.ok || res.status === 204) {
                showToast("Cambios guardados con exito", "ok");
                limpiarFormularioABM();
                cargarTurnos();
            }
        } catch (err) {
            listaTurnosCache = listaTurnosCache.map(item => parseInt(item.Id, 10) === parseInt(itemId, 10) ? { ...item, field_1: cuit, N_x00b0__x0020_de_x0020_OC: oc, field_2: prov, field_3: email, field_6: fecha, field_5: horario, Planta: planta } : item);
            showToast("Cambios aplicados localmente", "ok");
            limpiarFormularioABM();
            renderizarFilas(listaTurnosCache);
            calcularDisponibilidadOffline();
        }
    }

    async function crearTurno() {
        const cuit = document.getElementById('f_cuit').value.trim();
        const oc = document.getElementById('f_oc').value.trim();
        const prov = limpiarCaracteresRaros(document.getElementById('f_proveedor').value.trim());
        const email = document.getElementById('f_email').value.trim();
        const fecha = document.getElementById('f_fecha').value;
        const horario = document.getElementById('f_horario').value;
        const planta = document.getElementById('f_planta').value;

        if (!cuit || !oc || !prov || !fecha) {
            showToast("Complete los campos obligatorios.", "err");
            return;
        }

        const slotOcupado = listaTurnosCache.some(t => 
            t.field_6 && String(t.field_6).split('T')[0] === fecha && 
            normalizarStringHorario(t.field_5) === normalizarStringHorario(horario) && 
            (t.Planta ? String(t.Planta).toLowerCase() : 'packaging') === planta.toLowerCase() &&
            (t.field_7 ? String(t.field_7).trim().toLowerCase() : '') === 'aprobado'
        );
        if (slotOcupado) {
            showToast(`Modulo horario reservado.`, "err");
            return;
        }

        const digest = await getDigest();
        const payload = {
            "Title": "PROV-" + Date.now().toString().slice(-4), "field_1": cuit, "N_x00b0__x0020_de_x0020_OC": oc, "field_2": prov, "field_3": email,                          
            "field_6": fecha + "T00:00:00Z", "field_5": horario, "field_7": "Pendiente", "Planta": planta                     
        };

        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items`, {
                method: 'POST',
                headers: { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest },
                body: JSON.stringify(payload)
            });
            if (res.ok || res.status === 201) {
                showToast("Turno registrado en SharePoint", "ok");
                limpiarFormularioABM();
                cargarTurnos();
            }
        } catch (err) {
            listaTurnosCache.unshift({ Id: Math.floor(Math.random()*100), Title: payload.Title, field_1: cuit, field_2: prov, N_x00b0__x0020_de_x0020_OC: oc, field_6: fecha, field_5: horario, field_7: "Pendiente", Planta: planta, Created: new Date().toISOString(), field_3: email });
            showToast("Alta local procesada", "ok");
            limpiarFormularioABM();
            renderizarFilas(listaTurnosCache);
            calcularDisponibilidadOffline();
        }
    }

    function interceptarCambioEstado(itemId, visualId, nuevoEstado, proveedorEmail, razonSocial, fechaTurno) {
        const idNumerico = parseInt(itemId, 10);
        const turnoEnCache = listaTurnosCache.find(item => parseInt(item.Id, 10) === idNumerico);

        if (turnoEnCache && turnoEnCache.field_7) {
            const estadoRealServidor = String(turnoEnCache.field_7).trim().toLowerCase();
            if (estadoRealServidor === 'aprobado' && nuevoEstado === 'Aprobado') {
                alert(`🚨 CONTROL LOGISTICO EXCEPCIONAL:\nEl turno ${visualId} ya se encuentra aprobado y confirmado.`);
                return; 
            }
        }

        if (!confirm(`¿Desea cambiar el estado del turno ${visualId} a [${nuevoEstado.toUpperCase()}]?`)) return;
        transicionPendienteCtx = { itemId, visualId, nuevoEstado, proveedorEmail, razonSocial };

        if (nuevoEstado === 'Aprobado') {
            if (confirm("¿Desea enviar el mail de confirmacion al proveedor externo?")) {
                abrirModalRedaccionEstructurado(proveedorEmail, razonSocial, fechaTurno, "Aprobado");
            } else {
                procesarTransicionDirecta();
            }
        } else {
            abrirModalRedaccionEstructurado(proveedorEmail, razonSocial, fechaTurno, "Cancelado");
        }
    }

    function abrirModalRedaccionEstructurado(email, razonSocial, fecha, estado) {
        document.getElementById('m_de').value = currentLoggedUser.email;
        document.getElementById('m_para').value = email === '-' ? '' : email;
        document.getElementById('m_asunto').value = `Turno ${estado} - Molca Spegazzini`;
        document.getElementById('m_cuerpo').value = `Sr ${limpiarCaracteresRaros(razonSocial)} su turno para el dia ${fecha} ha sido ${estado} , debera presentarse con la documentacion requerida para su descarga.`;
        document.getElementById('btnEnviarMailFinal').onclick = async function() {
            const remitente = document.getElementById('m_de').value.trim();
            const destino = document.getElementById('m_para').value.trim();
            const asunto = document.getElementById('m_asunto').value.trim();
            const cuerpoTexto = document.getElementById('m_cuerpo').value.trim().replace(/\n/g, '<br/>');
            await procesarTransicionYMail(destino, asunto, cuerpoTexto, remitente);
        };
        const modal = document.getElementById('mailModal');
        modal.classList.remove('hidden');
        modal.classList.add('flex');
    }

    function cerrarModalMail() { 
        const modal = document.getElementById('mailModal');
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        transicionPendienteCtx = null; 
    }

    async function procesarTransicionYMail(para, asunto, cuerpo, remitenteCompleto) {
        if(!transicionPendienteCtx) return;
        const ctx = transicionPendienteCtx;
        const digest = await getDigest();

        const updatePayload = { "field_7": ctx.nuevoEstado };
        listaTurnosCache = listaTurnosCache.map(item => parseInt(item.Id, 10) === parseInt(ctx.itemId, 10) ? { ...item, field_7: ctx.nuevoEstado } : item);
        try {
            await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${ctx.itemId})`, {
                method: 'POST',
                headers: { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest, "X-HTTP-Method": "MERGE", "If-Match": "*" },
                body: JSON.stringify(updatePayload)
            });
        } catch(e) {}

        showToast(`Turno actualizado y notificado`, "ok");
        if (para) abrirClienteMailManual(para, ctx.razonSocial, fechaSeleccionadaGlobal, ctx.nuevoEstado);
        
        cerrarModalMail();
        renderizarFilas(listaTurnosCache);
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    async function procesarTransicionDirecta() {
        if(!transicionPendienteCtx) return;
        const ctx = transicionPendienteCtx;
        const digest = await getDigest();

        const updatePayload = { "field_7": ctx.nuevoEstado };
        listaTurnosCache = listaTurnosCache.map(item => parseInt(item.Id, 10) === parseInt(ctx.itemId, 10) ? { ...item, field_7: ctx.nuevoEstado } : item);
        try {
            await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${ctx.itemId})`, {
                method: 'POST',
                headers: { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest, "X-HTTP-Method": "MERGE", "If-Match": "*" },
                body: JSON.stringify(updatePayload)
            });
        } catch(e) {}

        showToast(`Turno aprobado directo`, "ok");
        renderizarFilas(listaTurnosCache);
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    async function eliminarTurnoServidor(itemId, visualId, razonSocial) {
        if (!confirm(`¿Desea ELIMINAR permanentemente el turno ${visualId}? El slot se liberara.`)) return;
        const digest = await getDigest();
        listaTurnosCache = listaTurnosCache.filter(item => parseInt(item.Id, 10) !== parseInt(itemId, 10));
        try {
            await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})`, {
                method: 'POST',
                headers: { "X-RequestDigest": digest, "X-HTTP-Method": "DELETE", "If-Match": "*" }
            });
        } catch(e) {}

        showToast("Turno eliminado", "ok");
        renderizarFilas(listaTurnosCache);
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    function renderizarBaseProveedores() {
        const tbodyProv = document.getElementById('tabla-proveedores');
        if (!tbodyProv) return;

        // Combinar datos locales mapeados del cache con el pool importado del Excel
        const cuitsMapeados = new Set();
        const poolRenderFinal = [];

        // 1. Mapear desde Excel importado
        proveedoresImportadosExcel.forEach(p => {
            if (p.numProveedor && !cuitsMapeados.has(p.numProveedor)) {
                cuitsMapeados.add(p.numProveedor);
                poolRenderFinal.push({
                    cuit: p.numProveedor,
                    text_social: p.nombreProveedor,
                    tipoInsumo: p.tipoInsumo,
                    responsable: p.responsable,
                    email: '-'
                });
            }
        });

        // 2. Mapear desde cache de turnos actual de SharePoint
        if (listaTurnosCache && listaTurnosCache.length > 0) {
            listaTurnosCache.forEach(t => {
                let cuitLimpio = t.field_1 ? String(t.field_1).trim() : '';
                if (cuitLimpio && !cuitsMapeados.has(cuitLimpio)) {
                    cuitsMapeados.add(cuitLimpio);
                    poolRenderFinal.push({
                        cuit: cuitLimpio,
                        text_social: limpiarCaracteresRaros(t.field_2) || 'Sin razon social',
                        tipoInsumo: t.Planta || 'General',
                        responsable: 'No Especificado',
                        email: t.field_3 || '-'
                    });
                }
            });
        }

        if (poolRenderFinal.length === 0) {
            tbodyProv.innerHTML = `<tr><td colspan="5" class="p-4 text-center text-slate-500 text-xs">No hay proveedores en el pool logistico.</td></tr>`;
            return;
        }

        let htmlProv = '';
        poolRenderFinal.forEach(p => {
            htmlProv += `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                <td class="py-3 px-3 font-mono font-bold text-amber-400">${p.cuit}</td>
                <td class="px-3 text-white font-semibold">${p.text_social}</td>
                <td class="px-3 text-slate-400 font-mono text-[11px]">${p.tipoInsumo}</td>
                <td class="px-3 text-slate-300 font-medium">${p.responsable}</td>
                <td class="px-3 text-slate-500 font-mono">${p.email}</td>
            </tr>`;
        });
        tbodyProv.innerHTML = htmlProv;
    }

    // ==========================================
    // LOGICA DE CARGA MASIVA DE EXCEL (SheetJS)
    // ==========================================
    function procesarArchivoExcel(e) {
        const file = e.target.files[0];
        if (!file) return;

        document.getElementById('excel-file-label').textContent = file.name + " (" + (file.size/1024).toFixed(1) + " KB)";
        logDebug("Procesando archivo masivo de proveedores: " + file.name);

        const reader = new FileReader();
        reader.onload = function(evt) {
            try {
                const data = new Uint8Array(evt.target.result);
                const workbook = XLSX.read(data, { type: 'array' });
                const firstSheetName = workbook.SheetNames[0];
                const worksheet = workbook.Sheets[firstSheetName];
                
                const rows = XLSX.utils.sheet_to_json(worksheet, { header: 1 });
                if (rows.length <= 1) {
                    showToast("El archivo de proveedores esta vacio o no tiene cabeceras", "err");
                    return;
                }

                // Normalizamos cabeceras para ser tolerantes a mayúsculas y acentos
                const headers = rows[0].map(h => limpiarCaracteresRaros(h).toLowerCase().trim());
                
                const idxTipo = headers.findIndex(h => h.includes("tipo") || h.includes("insumo"));
                const idxNombre = headers.findIndex(h => h.includes("nombre") || h.includes("proveedor") || h.includes("razon"));
                const idxNum = headers.findIndex(h => h.includes("n") || h.includes("num") || h.includes("cuit"));
                const idxResp = headers.findIndex(h => h.includes("responsable") || h.includes("user"));

                if (idxNombre === -1 || idxNum === -1) {
                    showToast("Faltan columnas obligatorias (Nombre o Nº proveedor)", "err");
                    return;
                }

                proveedoresImportadosExcel = [];
                let previewHtml = '';

                for(let i = 1; i < rows.length; i++) {
                    const row = rows[i];
                    if (!row || row.length === 0 || !row[idxNombre]) continue;

                    const item = {
                        tipoInsumo: idxTipo !== -1 && row[idxTipo] ? limpiarCaracteresRaros(row[idxTipo]) : "Insumos",
                        nombreProveedor: limpiarCaracteresRaros(row[idxNombre]),
                        numProveedor: idxNum !== -1 && row[idxNum] ? String(row[idxNum]).trim() : "PROV-" + Math.floor(Math.random()*10000),
                        responsable: idxResp !== -1 && row[idxResp] ? limpiarCaracteresRaros(row[idxResp]) : "Sistema Central"
                    };

                    proveedoresImportadosExcel.push(item);

                    if (i <= 10) { 
                        previewHtml += `
                            <tr class="border-b border-slate-800/40 hover:bg-slate-900/50">
                                <td class="p-2 font-mono text-slate-400">${item.tipoInsumo}</td>
                                <td class="p-2 text-white font-semibold">${item.nombreProveedor}</td>
                                <td class="p-2 font-mono text-sky-400">${item.numProveedor}</td>
                                <td class="p-2 text-slate-300">${item.responsable}</td>
                            </tr>`;
                    }
                }

                if (rows.length > 11) {
                    previewHtml += `<tr><td colspan="4" class="p-2 text-center text-slate-500 italic">Y ${(rows.length - 11)} proveedores mas detectados...</td></tr>`;
                }

                document.getElementById('excel-preview-box').classList.remove('hidden');
                document.getElementById('excel-preview-tbody').innerHTML = previewHtml;
                showToast("Matriz cargada. Total: " + proveedoresImportadosExcel.length + " proveedores", "ok");

            } catch (err) {
                logDebug("Error procesando Excel: " + err.message);
                showToast("Falla de codificacion en Excel", "err");
            }
        };
        reader.readAsArrayBuffer(file);
    }

    function inyectarProveedoresImportados() {
        if(proveedoresImportadosExcel.length === 0) return;
        
        logDebug("Inyectando proveedores al pool activo.");
        userLog("Importacion masiva realizada con exito de proveedores.xlsx", "MIGRACION");
        
        renderizarBaseProveedores();
        showToast("Base de proveedores actualizada", "ok");
        
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
        document.querySelector("[data-target='s6']").classList.add('active-tab');
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.getElementById('s6').classList.add('active');
    }

    function filtrarPorPlanta(plantaTarget) { 
        const filtrados = listaTurnosCache.filter(t => t.Planta && String(t.Planta).toLowerCase() === plantaTarget.toLowerCase());
        renderizarFilas(filtrados); 
    }
    
    function restablecerFiltro() { 
        renderizarFilas(listaTurnosCache);
    }
    
    function abrirClienteMailManual(paraEmail, nombreProveedor, fechaTurno, estadoTurno) {
        const asunto = `Estado de Turno - Molca Spegazzini`;
        const cuerpo = `Estimado proveedor ${nombreProveedor},\n\nLe informamos que su solicitud de turno para la fecha ${fechaTurno} se encuentra en estado: ${estadoTurno}.\n\nSaludos cordiales,\nLogistica de Planta.`;
        window.location.href = `mailto:${paraEmail}?subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(cuerpo)}`;
    }
    
    function showToast(msg, type = 'ok') {
        const t = document.getElementById('toast');
        if(!t) return;
        t.textContent = limpiarCaracteresRaros(msg); t.className = `show ${type}`;
        setTimeout(() => t.className = '', 4000);
    }
    
    async function getDigest() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/contextinfo`, {
                method: 'POST',
                headers: { "Accept": "application/json;odata=verbose" }
            });
            const data = await res.json();
            return data.d.GetContextWebInformation.FormDigestValue;
        } catch (e) { return "TOKEN_DUMMY_QA"; }
    }

    initApp();
</script>
</body>
</html>