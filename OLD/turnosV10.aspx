<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consola Maestra | Logistica de Turnos Molca</title>
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
    </style>
</head>
<body class="flex h-screen overflow-hidden text-slate-200">

<aside class="w-64 glass flex flex-col p-4 border-r border-slate-700 h-full z-10">
    <h1 class="text-xl font-bold text-white mb-5 uppercase tracking-wide">MOLCA <span class="text-sky-400">LOGISTICA</span></h1>
    <div class="mb-5 text-xs inline-flex items-center gap-2 p-1.5 rounded-full" style="background:rgba(0,0,0,.4); border:1px solid #334155;">
        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
        <span class="font-bold text-emerald-400">Online API REST</span>
    </div>

    <nav class="space-y-1 flex-1">
        <button class="w-full text-left rounded tab-btn active-tab" data-target="s2">1. Turnos Diarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s1">2. Captura y Consulta</button>
        <button class="w-full text-left rounded tab-btn" data-target="s6">3. Base Proveedores</button>
        <button class="w-full text-left rounded tab-btn" data-target="s7">4. Base Usuarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s5">5. Consola Debug</button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto relative">
    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50 z-20">
        <span class="text-slate-400 font-semibold">Usuario:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Iniciando...</span>
    </div>

    <section id="s1" class="tab-content mt-10">
        <div class="flex items-center justify-between mb-4 max-w-4xl">
            <h2 class="text-2xl font-bold text-sky-400">Panel Operativo de Gestion</h2>
            <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold">Alta de Turno</div>
        </div>
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4">
            <input type="hidden" id="f_item_id">
            
            <div class="col-span-2 grid grid-cols-3 gap-4 border-b border-slate-700 pb-4 mb-2">
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Patente</label>
                    <input type="text" id="f_patente" placeholder="AAA111" class="bg-slate-900 border border-slate-700 p-2 w-full font-mono text-amber-300 uppercase">
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Hora Ingreso</label>
                    <input type="time" id="f_hora_ing" class="bg-slate-900 border border-slate-700 p-2 w-full text-emerald-400">
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Hora Salida</label>
                    <input type="time" id="f_hora_sal" class="bg-slate-900 border border-slate-700 p-2 w-full text-rose-400">
                </div>
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">N Proveedor / CUIT (field_1)</label>
                <input type="text" id="f_cuit" placeholder="Escriba ID y presione Tab" onblur="autocompletarProveedor()" class="bg-slate-900 border border-slate-700 p-2 w-full text-amber-300 font-bold">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Num OC</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Razon Social (field_2)</label>
                <input type="text" id="f_proveedor" placeholder="Proveedor" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Email (field_3)</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Fecha Solicitud (field_6)</label>
                <input type="date" id="f_fecha" onchange="regenerarHorarios(); autoDia();" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Tipo Descarga (Planta)</label>
                <select id="f_planta" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                    <option value="Materia Prima">Materia Prima</option>
                </select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Planta Fisica (PlantaDescarga)</label>
                <select id="f_planta_descarga" onchange="regenerarHorarios()" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-400 font-bold">
                    <option value="Parque Canuelas">Parque Canuelas</option>
                    <option value="Predio Canuelas">Predio Canuelas</option>
                    <option value="Spegazzini">Spegazzini</option>
                    <option value="Almar">Almar</option>
                </select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Slot Horario (field_5)</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-300 font-mono font-bold"></select>
            </div>

            <div class="col-span-2 bg-slate-950 p-3 rounded text-xs border border-slate-800 text-slate-400 flex justify-between">
                <span>Modificado por: <strong id="f_usuario_gestor" class="text-white">-</strong></span>
                <span>Dia: <strong id="f_dia" class="text-white">-</strong></span>
            </div>

            <div class="col-span-2 flex gap-3 mt-4">
                <button id="btn-alta" onclick="crearTurno()" class="bg-sky-600 hover:bg-sky-500 px-6 py-3 font-bold rounded flex-1 transition">Registrar Alta</button>
                <button id="btn-modificar" onclick="guardarCambiosTurno()" disabled class="bg-amber-600 px-6 py-3 font-bold rounded opacity-30 flex-1 transition">Guardar Cambios</button>
                <button onclick="limpiarFormularioABM()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 rounded transition">Limpiar</button>
            </div>
        </div>
    </section>

    <section id="s2" class="tab-content active mt-10">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-sky-400">Monitor de Turnos Diarios</h2>
            <button onclick="enviarResumenDiario()" class="bg-indigo-600 hover:bg-indigo-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">Enviar Resumen Mail</button>
        </div>
        
        <div class="grid grid-cols-5 gap-6">
            <div class="col-span-3 glass p-6 rounded-xl h-[720px] flex flex-col">
                <div class="flex gap-2 mb-4 items-end bg-slate-900/50 p-3 rounded-lg border border-slate-700">
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Planta Descarga</label>
                        <select id="filtro_planta_descarga" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none">
                            <option value="TODAS">-- Todas --</option>
                            <option value="Parque Canuelas">Parque Canuelas</option>
                            <option value="Predio Canuelas">Predio Canuelas</option>
                            <option value="Spegazzini">Spegazzini</option>
                            <option value="Almar">Almar</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Modificador</label>
                        <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none">
                            <option value="TODOS">-- Todos --</option>
                        </select>
                    </div>
                    <button onclick="restablecerFiltros()" class="bg-slate-700 px-3 py-1.5 text-xs rounded hover:bg-slate-600">Quitar Filtro</button>
                    <button onclick="cargarTurnos()" class="ml-auto bg-slate-800 border border-slate-600 px-4 py-1.5 text-xs rounded text-sky-400 hover:bg-slate-700">Refrescar DB</button>
                </div>
                
                <div class="overflow-x-auto text-base flex-1">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0">
                            <tr>
                                <th class="py-3 px-2">ID</th>
                                <th class="px-2">Planta F.</th>
                                <th class="px-2">Proveedor</th>
                                <th class="px-2">Horario</th>
                                <th class="px-2">Patente</th>
                                <th class="px-2 text-center">In / Out</th>
                                <th class="px-2">Estado</th>
                                <th class="px-2 text-center">Accion</th>
                            </tr>
                        </thead>
                        <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                            <tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Cargando datos optimistas...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-span-2 glass p-4 rounded-xl flex flex-col h-[720px] overflow-hidden">
                <h3 class="text-base font-bold text-sky-400 uppercase tracking-wider text-center mb-1">Disponibilidad</h3>
                <div class="bg-slate-950/80 p-3 rounded-lg border border-slate-800 mb-3 text-xs">
                    <div class="flex justify-between items-center mb-2 px-1">
                        <span id="calendar-month-title" class="font-bold text-white uppercase tracking-wide">MES</span>
                        <div class="text-[10px] text-slate-400 font-semibold font-mono">MOLCA LOGISTICA</div>
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
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Base Maestro de Proveedores</h2>
        <p class="text-xs text-slate-400 mb-6">Suba su archivo Excel guardado como CSV. Formato: <span class="font-mono text-amber-300">Tipo Insumo,Nombre proveedor,N prove,Responsable</span></p>
        
        <div class="flex gap-4 mb-6 glass p-4 rounded items-center border border-slate-700">
            <input type="file" id="file_proveedores" accept=".csv" class="text-sm text-slate-300">
            <button onclick="procesarCSVProveedores()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-5 py-2 font-bold rounded text-xs shadow transition">Importar Padron</button>
        </div>

        <div class="glass p-6 rounded-xl text-base">
            <div class="overflow-x-auto h-96">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-xs uppercase text-slate-400 font-bold sticky top-0">
                        <tr><th class="py-3 px-3">N Proveedor</th><th class="px-3">Razon Social</th><th class="px-3">Tipo Insumo</th><th class="px-3">Responsable</th></tr>
                    </thead>
                    <tbody id="tabla-proveedores">
                        <tr><td colspan="4" class="p-6 text-center text-slate-500 text-xs">Sin padron de proveedores cargado.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section id="s7" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Gestion de Usuarios (Mailing)</h2>
        <p class="text-xs text-slate-400 mb-6">Suba el CSV con formato: <span class="font-mono text-amber-300">Usuario,Nombre,Email,Planta</span></p>
        <div class="flex gap-4 mb-6 glass p-4 rounded items-center border border-slate-700">
            <input type="file" id="file_usuarios" accept=".csv" class="text-sm text-slate-300">
            <button onclick="procesarCSVUsuarios()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-5 py-2 font-bold rounded text-xs shadow transition">Importar Correos</button>
        </div>
        <div class="glass p-4 rounded-xl overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold">
                    <tr><th class="py-3 px-3">ID</th><th class="px-3">Nombre</th><th class="px-3">Email</th><th class="px-3">Planta</th></tr>
                </thead>
                <tbody id="tabla-usuarios">
                    <tr><td colspan="4" class="p-4 text-center text-slate-500 text-xs">Sin datos.</td></tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="s5" class="tab-content mt-10">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-sky-400">Terminal de Procesos y Control</h2>
            <button onclick="testConexion()" class="bg-indigo-600 hover:bg-indigo-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">Test API (Vanilla 10)</button>
        </div>
        <div class="glass p-4 rounded-xl space-y-4 text-xs">
            <div id="debug-log" class="mono bg-black/80 h-[500px] overflow-y-auto p-4 rounded border border-slate-700" style="color:#38bdf8"></div>
        </div>
    </section>

</main>

<div id="toast"></div>

<script>
    // --- ESTADO GLOBAL ---
    const relativeSiteUrl = "/sites/GestiondeTurnos";
    const targetListName = 'Turnos Proveedores';
    let listaTurnosCache = [];
    let listaUsuariosCache = [];
    let listaProveedoresCache = [];
    const slotsHorarios = [];
    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Local", email: "logistica@grupocanuelas.com" };

    // --- ARRANQUE OPTIMISTA ---
    function initApp() {
        try {
            logDebug("Arranque Seguro UI-First...");
            
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.toISOString().split('T')[0];
            const inputFecha = document.getElementById('f_fecha');
            if(inputFecha) inputFecha.value = fechaSeleccionadaGlobal;
            
            autoDia();
            setupRuteo();
            regenerarHorarios();

            // Mock preventivo
            listaTurnosCache = [
                { Id: 10, field_1: "1864361", field_2: "ABK SRL", field_3: "abk@proveedor.com", field_5: "08:00 a 08:45 h", field_6: fechaSeleccionadaGlobal+"T00:00:00Z", field_7: "Pendiente", Planta: "Packaging", PlantaDescarga: "Spegazzini", Patente: "AF123BC", Gestor: "Admin" }
            ];
            
            renderizarFilas(listaTurnosCache);
            poblarFiltroModificadores();
            renderizarGrilaCalendario();
            calcularDisponibilidadOffline();

            // Llama a la funcion de test de Vanilla 10 para identificar al usuario de forma segura
            setTimeout(() => { testConexion(); }, 50);
            setTimeout(() => { cargarTurnos(); }, 150);
        } catch (err) { logDebug("Init Error: " + err.message); }
    }

    // --- LOGICA DEL ARCHIVO VANILLA 10.HTML ---
    async function testConexion() {
        logDebug("Iniciando test de API (Logica Vanilla 10)...");
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, {
                headers: { "Accept": "application/json;odata=nometadata" }
            });
            if (res.ok) {
                const data = await res.json();
                const userName = data.Title || data.DisplayName || "Usuario OK";
                logDebug("API respondio: " + userName);
                
                currentLoggedUser.name = userName;
                currentLoggedUser.email = data.Email || data.UserPrincipalName || "";
                document.getElementById('app-user-name').textContent = currentLoggedUser.name;
            } else {
                logDebug("API respondio con error: " + res.status);
            }
        } catch (err) {
            logDebug("Error critico de red: " + err.message);
        }
    }

    function setupRuteo() {
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
                btn.classList.add('active-tab');
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                const target = btn.dataset.target;
                const el = document.getElementById(target);
                if(el) el.classList.add('active');
            });
        });
    }

    function autoDia() {
        const fechaVal = document.getElementById('f_fecha').value;
        if (!fechaVal) return;
        const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
        const fecha = new Date(fechaVal.replace(/-/g, '/') + ' 00:00:00');
        const diaControl = document.getElementById('f_dia');
        if(diaControl) diaControl.value = dias[fecha.getDay()];
    }

    // --- REGLAS LOGISTICAS DE HORARIOS ---
    function regenerarHorarios() {
        try {
            const plantaDescarga = document.getElementById('f_planta_descarga').value;
            const fechaStr = document.getElementById('f_fecha').value;
            const select = document.getElementById('f_horario');
            if(!select || !fechaStr) return;

            const d = new Date(fechaStr.replace(/-/g, '/') + ' 00:00:00');
            const day = d.getDay(); 
            slotsHorarios.length = 0; 
            select.innerHTML = '';

            if (day === 0) {
                select.innerHTML = '<option value="">Domingo Cerrado</option>';
                return;
            }

            let startMins, endMins, duration, lastSlotMins;
            let operativo = false;

            if (plantaDescarga === 'Parque Canuelas') {
                if (day >= 1 && day <= 5) { operativo = true; startMins = 7*60; endMins = 15*60; duration = 40; lastSlotMins = 14*60+20; }
            } else if (plantaDescarga === 'Predio Canuelas') {
                if (day >= 1 && day <= 5) { operativo = true; startMins = 10*60; endMins = 17*60; duration = 40; lastSlotMins = 16*60+20; }
                else if (day === 6) { operativo = true; startMins = 7*60; endMins = 11*60; duration = 40; lastSlotMins = 10*60+20; }
            } else if (plantaDescarga === 'Spegazzini') {
                if (day >= 1 && day <= 5) { operativo = true; startMins = 8*60; endMins = 16*60; duration = 45; lastSlotMins = 16*60; }
                else if (day === 6) { operativo = true; startMins = 7*60; endMins = 11*60; duration = 45; lastSlotMins = 10*60+15; }
            } else if (plantaDescarga === 'Almar') {
                if (day >= 1 && day <= 5) { operativo = true; startMins = 7*60; endMins = 14*60; duration = 30; lastSlotMins = 14*60; }
                else if (day === 6) { operativo = true; startMins = 7*60; endMins = 11*60; duration = 30; lastSlotMins = 11*60; }
            }

            if (!operativo) {
                select.innerHTML = '<option value="">Sin Turnos</option>';
                return;
            }

            let htmlOpts = '';
            let current = startMins;
            while (current <= lastSlotMins && (current + duration) <= endMins) {
                let h1 = String(Math.floor(current/60)).padStart(2,'0');
                let m1 = String(current%60).padStart(2,'0');
                let curEnd = current + duration;
                let h2 = String(Math.floor(curEnd/60)).padStart(2,'0');
                let m2 = String(curEnd%60).padStart(2,'0');
                
                let slotStr = `${h1}:${m1} a ${h2}:${m2} h`;
                slotsHorarios.push(slotStr);
                htmlOpts += `<option value="${slotStr}">${slotStr}</option>`;
                current += duration;
            }
            select.innerHTML = htmlOpts;
        } catch(e) { logDebug("Error slots: " + e.message); }
    }

    async function getDigest() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/contextinfo`, { method: 'POST', headers: { "Accept": "application/json;odata=verbose" } });
            const data = await res.json();
            return data.d.GetContextWebInformation.FormDigestValue;
        } catch (e) { return "TOKEN_MOCK"; }
    }

    // Usando Comodin OData para evitar Error 400
    async function cargarTurnos() {
        logDebug("Invocando API SharePoint (Modo Expandido sin $select)...");
        try {
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$expand=Editor&$orderby=Created desc&$top=100`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            
            if (!res.ok) {
                const errData = await res.json();
                throw new Error(errData.error ? errData.error.message.value : "HTTP " + res.status);
            }
            
            const data = await res.json();
            listaTurnosCache = data.value || [];
            
            renderizarFilas(listaTurnosCache);
            poblarFiltroModificadores();
            renderizarGrilaCalendario();
            calcularDisponibilidadOffline();
            logDebug("Datos SharePoint extraidos con exito.");
        } catch (err) {
            logDebug(`ERROR API TURNOS: ${err.message}`);
        }
    }

    // --- RENDERIZADO TABLA ---
    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Sin registros activos</td></tr>`;
            return;
        }

        let htmlRows = '';
        items.forEach(t => {
            const estado = String(t.field_7 || 'Pendiente').trim();
            const esAprobado = estado.toLowerCase() === 'aprobado';
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : 'text-amber-400';
            
            let hIng = t.HoraIngreso || '--:--';
            let hSal = t.HoraSalida || '--:--';
            let pFisica = t.PlantaDescarga || '-';
            let pTipo = t.Planta || '-';
            let pat = t.Patente || 'N/D';
            
            let modPor = t.Editor ? t.Editor.Title : (t.Gestor || '-');

            let inOutStr = `<span class="text-emerald-400 font-bold text-[10px]">${hIng}</span> / <span class="text-rose-400 font-bold text-[10px]">${hSal}</span>`;

            htmlRows += `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                <td class="p-2 font-mono text-sky-400 font-bold">${t.Id}</td>
                <td class="p-2 text-slate-300 font-bold">${pFisica} <span class="text-[9px] font-normal block text-slate-500">${pTipo}</span></td>
                <td class="p-2 text-white">${t.field_2 || '-'}</td>
                <td class="p-2 text-amber-300 font-mono">${t.field_5 || '-'}</td>
                <td class="p-2 font-mono tracking-widest text-slate-300">${pat}</td>
                <td class="p-2 bg-black/20 text-center rounded">${inOutStr}</td>
                <td class="p-2 ${colorEst}">${estado}<br><span class="text-[9px] text-slate-400 font-normal">Por: ${modPor}</span></td>
                <td class="p-2 text-center flex flex-wrap gap-1 justify-center max-w-[140px]">
                    <button onclick="consultarTurnoAlFormulario(${t.Id})" class="bg-sky-900 text-sky-300 px-2 py-1 rounded hover:bg-sky-700 transition">[Ver]</button>
                    ${!esAprobado ? `<button onclick="cambiarEstado(${t.Id}, 'Aprobado')" class="bg-emerald-900 text-emerald-300 px-2 py-1 rounded hover:bg-emerald-700 transition">[Aprobar]</button>` : ''}
                    <button onclick="marcarTracking(${t.Id}, 'IN')" class="bg-slate-800 text-emerald-400 px-2 py-1 rounded hover:bg-slate-700 transition">[In]</button>
                    <button onclick="marcarTracking(${t.Id}, 'OUT')" class="bg-slate-800 text-rose-400 px-2 py-1 rounded hover:bg-slate-700 transition">[Out]</button>
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    // --- CALENDARIO ---
    function renderizarGrilaCalendario() {
        const gridContainer = document.getElementById('calendar-days-grid');
        const titleContainer = document.getElementById('calendar-month-title');
        if (!gridContainer || !titleContainer) return;

        const baseDate = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00');
        const anio = baseDate.getFullYear();
        const mes = baseDate.getMonth(); 

        const mesesNombres = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
        titleContainer.textContent = `${mesesNombres[mes]} ${anio}`;

        const primerDiaMes = new Date(anio, mes, 1);
        let dayOfWeek = primerDiaMes.getDay(); 
        let despilfaroBlanco = dayOfWeek === 0 ? 6 : dayOfWeek - 1; 

        let calHtml = ''; 
        if (despilfaroBlanco > 0 && despilfaroBlanco < 7) {
            for (let b = 0; b < despilfaroBlanco; b++) calHtml += `<div class="p-1">-</div>`;
        }

        const totalDiasMes = new Date(anio, mes + 1, 0).getDate();
        const diaActualSeleccionado = baseDate.getDate();

        for (let dia = 1; dia <= totalDiasMes; dia++) {
            let esSeleccionado = (dia === diaActualSeleccionado);
            let claseEstilo = esSeleccionado ? 'bg-sky-500 text-black font-bold rounded' : 'text-slate-300 hover:bg-slate-800 rounded cursor-pointer transition';
            let stringDiaFormato = `${anio}-${String(mes + 1).padStart(2, '0')}-${String(dia).padStart(2, '0')}`;
            calHtml += `<button onclick="conmutarFechaDesdeCalendario('${stringDiaFormato}')" class="p-1 text-center text-xs ${claseEstilo}">${dia}</button>`;
        }
        gridContainer.innerHTML = calHtml;
    }

    function conmutarFechaDesdeCalendario(nuevaFechaString) {
        fechaSeleccionadaGlobal = nuevaFechaString;
        const inputFecha = document.getElementById('f_fecha');
        if(inputFecha) inputFecha.value = nuevaFechaString;
        autoDia();
        regenerarHorarios();
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    // --- SEMAFOROS ---
    function normalizarStringHorario(str) {
        if (!str) return "";
        return String(str).toLowerCase().replace(/h/g, "").replace(/\\s+/g, "").trim();
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

    function obtenerEntidadTurnoSlot(tipoInsumo, slot, fecha) {
        if(!listaTurnosCache || listaTurnosCache.length === 0) return { estado: 'Libre', visualId: '' };
        const coincidencia = listaTurnosCache.find(t => 
            t.field_6 && String(t.field_6).split('T')[0] === fecha && 
            normalizarStringHorario(t.field_5) === normalizarStringHorario(slot) && 
            (t.Planta ? String(t.Planta).toLowerCase() : 'packaging') === tipoInsumo.toLowerCase()
        );

        if (!coincidencia || !coincidencia.field_7) return { estado: 'Libre', visualId: '' };
        const st = String(coincidencia.field_7).trim().toLowerCase();
        if (st === 'cancelado' || st === 'anulado') return { estado: 'Libre', visualId: '' };
        
        let cPlanta = (String(coincidencia.Planta).toLowerCase() === 'insumos') ? 'IN' : 'PK';
        return { estado: String(coincidencia.field_7).trim(), visualId: `TN${cPlanta}${coincidencia.Id}` }; 
    }

    function generarTarjetaSemaforoHTML(slot, estado, visualId) {
        let bgStyle = "";
        let stLimpio = estado ? String(estado).toLowerCase() : 'libre';

        if (stLimpio === 'aprobado') bgStyle = 'bg-red-600 text-white border-red-500';
        else if (stLimpio === 'pending' || stLimpio === 'pendiente') bgStyle = 'bg-amber-500 text-black border-amber-400';
        else bgStyle = 'bg-emerald-600 text-white border-emerald-500';

        return `<div class="flex justify-between p-2 border rounded text-xs font-mono ${bgStyle} mb-1.5 shadow-sm">
            <span>${String(slot).split(' ')[0]}</span>
            <span class="font-bold bg-black/30 px-1 rounded">${visualId}</span>
        </div>`;
    }

    // --- IMPORTACION PROVEEDORES Y AUTOCOMPLETADO ---
    function procesarCSVProveedores() {
        const f = document.getElementById('file_proveedores').files[0];
        if(!f) return showToast("Falta Archivo CSV", "err");
        const r = new FileReader();
        r.onload = function(e) {
            try {
                const lines = e.target.result.split('\\n');
                listaProveedoresCache = [];
                for(let i=1; i<lines.length; i++) {
                    const row = lines[i].trim();
                    if(!row) continue;
                    const cols = row.split(/,|;/); 
                    if(cols.length >= 4) {
                        listaProveedoresCache.push({ tipo: cols[0].trim(), nombre: cols[1].trim(), id: cols[2].trim(), responsable: cols[3].trim() });
                    }
                }
                const tb = document.getElementById('tabla-proveedores');
                tb.innerHTML = listaProveedoresCache.map(p => `<tr class="border-b border-slate-700 text-xs"><td class="p-3 font-mono text-amber-400 font-bold">${p.id}</td><td class="p-3 text-white">${p.nombre}</td><td class="p-3 text-slate-300 font-bold">${p.tipo}</td><td class="p-3 text-slate-400">${p.responsable}</td></tr>`).join('');
                showToast(`Mapeados: ${listaProveedoresCache.length} regs`, "ok");
                logDebug(`Excel Proveedores importado OK.`);
            } catch(err) { showToast("Error parseando CSV Proveedores", "err"); }
        };
        r.readAsText(f);
    }

    function autocompletarProveedor() {
        const nProv = document.getElementById('f_cuit').value.trim();
        if(!nProv || listaProveedoresCache.length === 0) return;
        const provEncontrado = listaProveedoresCache.find(p => p.id === nProv);
        if(provEncontrado) {
            document.getElementById('f_proveedor').value = provEncontrado.nombre;
            if(provEncontrado.tipo.toLowerCase().includes('insumo')) document.getElementById('f_planta').value = 'Insumos';
            else if(provEncontrado.tipo.toLowerCase().includes('pack')) document.getElementById('f_planta').value = 'Packaging';
            showToast(`Datos auto-cargados`, "ok");
            logDebug(`Autocompletado para Proveedor: ${nProv}`);
        }
    }

    // --- FORMULARIO ABM ---
    function consultarTurnoAlFormulario(itemId) {
        const id = parseInt(itemId, 10);
        const t = listaTurnosCache.find(item => parseInt(item.Id, 10) === id);
        if (!t) return;

        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_patente').value = t.Patente || '';
        document.getElementById('f_hora_ing').value = t.HoraIngreso || '';
        document.getElementById('f_hora_sal').value = t.HoraSalida || '';
        document.getElementById('f_cuit').value = t.field_1 || '';
        document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || '';
        document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('f_email').value = t.field_3 || '';
        if (t.field_6) document.getElementById('f_fecha').value = String(t.field_6).split('T')[0];
        
        autoDia();
        document.getElementById('f_planta').value = t.Planta || 'Packaging';
        document.getElementById('f_planta_descarga').value = t.PlantaDescarga || 'Parque Canuelas';
        
        regenerarHorarios();
        document.getElementById('f_horario').value = t.field_5 || '';
        
        let modPor = t.Editor ? t.Editor.Title : (t.Gestor || '-');
        document.getElementById('f_usuario_gestor').textContent = modPor;

        const est = String(t.field_7 || '').trim().toLowerCase();
        if (est === 'aprobado') {
            document.getElementById('btn-modificar').disabled = true;
            document.getElementById('btn-modificar').classList.add('opacity-40');
        } else {
            document.getElementById('btn-modificar').disabled = false;
            document.getElementById('btn-modificar').classList.remove('opacity-40');
        }
        document.querySelector("[data-target='s1']").click();
    }

    function limpiarFormularioABM() {
        document.getElementById('f_item_id').value = '';
        document.querySelectorAll('#s1 input:not([type="hidden"])').forEach(i => i.value = '');
        document.getElementById('f_usuario_gestor').textContent = '-';
        document.getElementById('btn-modificar').disabled = true;
        document.getElementById('btn-modificar').classList.add('opacity-40');
    }

    async function ejecutarTransaccion(itemId, payload, msg) {
        payload.Gestor = currentLoggedUser.name; 
        try {
            const digest = await getDigest();
            const url = itemId ? `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})` : `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items`;
            const reqHeaders = { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest };
            if(itemId) { reqHeaders["X-HTTP-Method"] = "MERGE"; reqHeaders["If-Match"] = "*"; }

            const res = await fetch(url, { method: 'POST', headers: reqHeaders, body: JSON.stringify(payload) });
            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error("Falla API");
            
            showToast(msg, "ok");
            cargarTurnos(); 
        } catch(e) {
            if(itemId) listaTurnosCache = listaTurnosCache.map(t => t.Id == itemId ? {...t, ...payload, Editor: {Title: currentLoggedUser.name}} : t);
            else listaTurnosCache.unshift({...payload, Id: Math.floor(Math.random()*1000), Editor: {Title: currentLoggedUser.name}});
            showToast(msg + " (Modo Offline)", "ok");
            renderizarFilas(listaTurnosCache);
            renderizarGrilaCalendario();
            calcularDisponibilidadOffline();
        }
    }

    async function crearTurno() {
        const payload = {
            field_1: document.getElementById('f_cuit').value.trim(), field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value, field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            field_7: "Pendiente", N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, PlantaDescarga: document.getElementById('f_planta_descarga').value,
            Patente: document.getElementById('f_patente').value.trim().toUpperCase(), HoraIngreso: document.getElementById('f_hora_ing').value, HoraSalida: document.getElementById('f_hora_sal').value
        };
        await ejecutarTransaccion(null, payload, "Alta OK");
        limpiarFormularioABM();
    }

    async function guardarCambiosTurno() {
        const id = document.getElementById('f_item_id').value;
        if(!id) return;
        const payload = {
            field_1: document.getElementById('f_cuit').value.trim(), field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value, field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(), Planta: document.getElementById('f_planta').value,
            PlantaDescarga: document.getElementById('f_planta_descarga').value, Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            HoraIngreso: document.getElementById('f_hora_ing').value, HoraSalida: document.getElementById('f_hora_sal').value
        };
        await ejecutarTransaccion(id, payload, "Guardado OK");
        limpiarFormularioABM();
    }

    async function cambiarEstado(id, est) {
        if(!confirm(`Confirme operacion: ${est}`)) return;
        await ejecutarTransaccion(id, { field_7: est }, `Estado -> ${est}`);
    }

    async function marcarTracking(id, tipo) {
        const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        let p = {};
        if(tipo === 'IN') p.HoraIngreso = horaStr;
        if(tipo === 'OUT') p.HoraSalida = horaStr;
        await ejecutarTransaccion(id, p, `Tracking OK`);
    }

    // --- FILTROS TABLA ---
    function poblarFiltroModificadores() {
        const select = document.getElementById('filtro_usuario');
        if(!select) return;
        const usr = [...new Set(listaTurnosCache.map(t => t.Editor ? t.Editor.Title : t.Gestor).filter(Boolean))];
        let h = '<option value="TODOS">-- Todos --</option>';
        usr.forEach(u => { h += `<option value="${u}">${u}</option>`; });
        select.innerHTML = h;
    }

    function aplicarFiltrosMonitor() {
        const pd = document.getElementById('filtro_planta_descarga').value;
        const u = document.getElementById('filtro_usuario').value;
        let filtrados = listaTurnosCache;
        if(pd !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === pd);
        if(u !== 'TODOS') filtrados = filtrados.filter(t => (t.Editor ? t.Editor.Title : t.Gestor) === u);
        renderizarFilas(filtrados);
    }

    function restablecerFiltros() {
        document.getElementById('filtro_planta_descarga').value = 'TODAS';
        document.getElementById('filtro_usuario').value = 'TODOS';
        renderizarFilas(listaTurnosCache);
    }

    // --- IMPORTADOR USUARIOS (MAILING) ---
    function procesarCSVUsuarios() {
        const f = document.getElementById('file_usuarios').files[0];
        if(!f) return showToast("Falta CSV", "err");
        const r = new FileReader();
        r.onload = function(e) {
            try {
                const lines = e.target.result.split('\\n');
                listaUsuariosCache = [];
                for(let i=1; i<lines.length; i++) {
                    const row = lines[i].trim();
                    if(!row) continue;
                    const cols = row.split(/,|;/); 
                    if(cols.length >= 4) listaUsuariosCache.push({ usuario: cols[0], nombre: cols[1], email: cols[2], planta: cols[3] });
                }
                document.getElementById('tabla-usuarios').innerHTML = listaUsuariosCache.map(u => `<tr class="border-b border-slate-700 text-xs"><td class="p-2 text-sky-400">${u.usuario}</td><td class="p-2">${u.nombre}</td><td class="p-2">${u.email}</td><td class="p-2">${u.planta}</td></tr>`).join('');
                showToast("Lista Correo OK", "ok");
            } catch(err) { showToast("Error CSV", "err"); }
        };
        r.readAsText(f);
    }

    // --- ENVIAR MAILING DIARIO ---
    function enviarResumenDiario() {
        const fFiltro = document.getElementById('f_fecha').value;
        const turnosHoy = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fFiltro));
        if(turnosHoy.length === 0) return showToast("Sin turnos hoy", "err");

        let body = `RESUMEN DIARIO LOGISTICO - ${fFiltro}\\n\\n`;
        const plantas = [...new Set(turnosHoy.map(t => t.PlantaDescarga).filter(Boolean))];
        plantas.forEach(p => {
            body += `== PLANTA FISICA: ${p.toUpperCase()} ==\\n`;
            turnosHoy.filter(t => t.PlantaDescarga === p).forEach(t => {
                let mPor = t.Editor ? t.Editor.Title : (t.Gestor || '-');
                body += `[${t.field_5}] Patente: ${t.Patente||'S/D'} | Prov: ${t.field_2} | Est: ${t.field_7} | Por: ${mPor}\\n`;
                if(t.HoraIngreso) body += `  -> In=${t.HoraIngreso} / Out=${t.HoraSalida||'En planta'}\\n`;
            });
            body += `\\n`;
        });
        const bcc = listaUsuariosCache.map(u => u.email).filter(Boolean).join(';');
        window.location.href = `mailto:?bcc=${bcc}&subject=Resumen Diaro Molca - ${fFiltro}&body=${encodeURIComponent(body)}`;
    }

    function showToast(msg, type) {
        const t = document.getElementById('toast');
        if(!t) return;
        t.textContent = msg; t.className = `show ${type}`;
        setTimeout(() => t.className = '', 3000);
    }

    function logDebug(msg) {
        const d = document.getElementById('debug-log');
        if(d) { d.insertAdjacentHTML('beforeend', `<div class="mb-1 border-b border-slate-800 pb-1"><span class="text-slate-500">[${new Date().toLocaleTimeString()}]</span> ${msg}</div>`); d.scrollTop = d.scrollHeight; }
        console.log(msg);
    }

    initApp();
</script>
</body>
</html>