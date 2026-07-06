<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consola Maestra | Logistica de Turnos Molca Spegazzini</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Syne:wght@400;600;700;800&display=swap');
        :root { --sp-blue: #38bdf8; --sp-bg: #0b1120; --sp-panel: rgba(15, 23, 42, 0.92); --sp-border: rgba(56, 189, 248, 0.15); }
        body { font-family: 'Syne', sans-serif; background-color: var(--sp-bg); color: #e2e8f0; margin: 0; font-size: 1rem; }
        .glass { background: var(--sp-panel); border: 1px solid var(--sp-border); backdrop-filter: blur(12px); }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.2s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(4px); } to { opacity: 1; transform: none; } }
        .tab-btn { color: #94a3b8; padding: 10px; cursor: pointer; transition: 0.2s; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; border-left: 3px solid #38bdf8; }
        #toast { position: fixed; bottom: 1.5rem; right: 1.5rem; padding: .6rem 1.2rem; border-radius: 8px; font-size: .9rem; font-weight: 600; opacity: 0; transition: opacity .3s; z-index: 9999; pointer-events: none; }
        #toast.show { opacity: 1; }
        #toast.ok   { background:#166534; border:1px solid #4ade80; color:#4ade80; }
        #toast.err  { background:#7f1d1d; border:1px solid #f87171; color:#f87171; }
    </style>
</head>
<body class="flex h-screen overflow-hidden text-slate-200">

<aside class="w-64 glass flex flex-col p-4 border-r border-slate-700">
    <h1 class="text-xl font-bold text-white mb-5 uppercase tracking-wide">MOLCA <span class="text-sky-400">SPEGAZZINI</span></h1>
    <nav class="space-y-2 flex-1">
        <button class="w-full text-left rounded tab-btn active-tab" data-target="s2">1. Turnos Diarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s1">2. Captura y Consulta</button>
        <button class="w-full text-left rounded tab-btn" data-target="s6" onclick="renderizarBaseProveedores()">3. Base Proveedores</button>
        <button class="w-full text-left rounded tab-btn" data-target="s7">4. Base Usuarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s5">5. Consola Debug</button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto relative">
    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50">
        <span class="text-slate-400 font-semibold">Usuario Activo:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Iniciando...</span>
    </div>

    <section id="s1" class="tab-content">
        <div class="flex justify-between items-center mb-4 max-w-4xl mt-10">
            <h2 class="text-2xl font-bold text-sky-400">Gestión de Solicitud de Turnos</h2>
            <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold">Alta de Turno</div>
        </div>
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4">
            <input type="hidden" id="f_item_id">
            
            <div class="col-span-2 grid grid-cols-3 gap-4 border-b border-slate-700 pb-4 mb-2">
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Patente (Tractor/Acoplado)</label>
                    <input type="text" id="f_patente" placeholder="AAA111 / AF123BC" class="bg-slate-900 border border-slate-700 p-2 w-full font-mono text-amber-300 uppercase">
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Hora Ingreso Real</label>
                    <input type="time" id="f_hora_ing" class="bg-slate-900 border border-slate-700 p-2 w-full text-emerald-400">
                </div>
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Hora Salida Real</label>
                    <input type="time" id="f_hora_sal" class="bg-slate-900 border border-slate-700 p-2 w-full text-rose-400">
                </div>
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">CUIT Proveedor</label>
                <input type="text" id="f_cuit" placeholder="XX-XXXXXXXX-X" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Número OC</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Razón Social</label>
                <input type="text" id="f_proveedor" placeholder="Proveedor" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Fecha Solicitud</label>
                <input type="date" id="f_fecha" onchange="regenerarHorarios()" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Planta Logística</label>
                <select id="f_planta" onchange="regenerarHorarios()" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
                    <option value="Parque Cañuelas">Parque Cañuelas</option>
                    <option value="Predio Cañuelas">Predio Cañuelas</option>
                    <option value="Spegazzini">Spegazzini</option>
                    <option value="Almar">Almar</option>
                </select>
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Slot Horario Asignado</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-300 font-mono font-bold"></select>
            </div>

            <div class="col-span-2 bg-slate-950 p-3 rounded text-xs border border-slate-800 text-slate-400">
                Gestor Última Modificación: <span id="f_usuario_gestor" class="font-bold text-white">-</span>
            </div>

            <div class="col-span-2 flex gap-3 mt-2">
                <button id="btn-alta" onclick="crearTurno()" class="bg-sky-600 hover:bg-sky-500 px-6 py-3 font-bold rounded flex-1">➕ Registrar Alta</button>
                <button id="btn-modificar" onclick="guardarCambiosTurno()" disabled class="bg-amber-600 px-6 py-3 font-bold rounded opacity-30 flex-1">💾 Guardar Cambios</button>
                <button onclick="limpiarFormularioABM()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 rounded">🧹 Limpiar</button>
            </div>
        </div>
    </section>

    <section id="s2" class="tab-content active mt-10">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-sky-400">Monitor de Turnos Diarios</h2>
            <button onclick="enviarResumenDiario()" class="bg-indigo-600 hover:bg-indigo-500 text-white px-4 py-2 text-xs font-bold rounded shadow">📧 Enviar Resumen del Día</button>
        </div>
        
        <div class="flex gap-3 mb-4 items-end glass p-3 rounded-lg">
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Filtrar por Planta</label>
                <select id="filtro_planta" onchange="aplicarFiltrosMonitor()" class="bg-slate-900 border border-slate-700 p-1.5 text-xs text-white rounded">
                    <option value="TODAS">-- Todas las Plantas --</option>
                    <option value="Parque Cañuelas">Parque Cañuelas</option>
                    <option value="Predio Cañuelas">Predio Cañuelas</option>
                    <option value="Spegazzini">Spegazzini</option>
                    <option value="Almar">Almar</option>
                </select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Filtrar por Usuario Gestor</label>
                <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-900 border border-slate-700 p-1.5 text-xs text-white rounded">
                    <option value="TODOS">-- Todos los Usuarios --</option>
                </select>
            </div>
            <button onclick="restablecerFiltros()" class="bg-slate-700 px-3 py-1.5 text-xs rounded">Restablecer</button>
            <button onclick="cargarTurnos()" class="ml-auto bg-slate-800 border border-slate-600 px-4 py-1.5 text-xs rounded text-sky-400">↻ Refrescar Red</button>
        </div>

        <div class="glass p-4 rounded-xl overflow-x-auto h-[650px]">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow">
                    <tr>
                        <th class="py-3 px-2">ID</th>
                        <th class="px-2">Planta</th>
                        <th class="px-2">Proveedor</th>
                        <th class="px-2">Horario Asignado</th>
                        <th class="px-2">Patente</th>
                        <th class="px-2">Tracking (In/Out)</th>
                        <th class="px-2">Estado</th>
                        <th class="px-2">Gestor</th>
                        <th class="px-2 text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                    <tr><td colspan="9" class="p-6 text-center text-slate-500 text-xs">Inicializando vista optimista...</td></tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="s6" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Base de Datos Maestro de Proveedores</h2>
        <div class="glass p-4 rounded-xl overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold">
                    <tr><th class="py-3 px-3">CUIT</th><th class="px-3">Razón Social</th><th class="px-3">Email Referencia</th></tr>
                </thead>
                <tbody id="tabla-proveedores"></tbody>
            </table>
        </div>
    </section>

    <section id="s7" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Gestión de Usuarios (SharePoint Group Sync)</h2>
        <p class="text-xs text-slate-400 mb-6">Para actualizar el padrón masivo, guarde su Excel corporativo como <strong>CSV (Delimitado por comas)</strong> y cárguelo aquí. Formato requerido: <span class="font-mono text-amber-300">Usuario,Nombre_Apellido,Email,Planta</span></p>
        
        <div class="flex gap-4 mb-6 glass p-4 rounded items-center">
            <input type="file" id="file_usuarios" accept=".csv" class="text-sm">
            <button onclick="procesarCSVUsuarios()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 font-bold rounded text-xs">📥 Importar y Sincronizar</button>
        </div>

        <div class="glass p-4 rounded-xl overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold">
                    <tr><th class="py-3 px-3">Usuario (ID)</th><th class="px-3">Nombre y Apellido</th><th class="px-3">Correo Electrónico</th><th class="px-3">Planta Base</th></tr>
                </thead>
                <tbody id="tabla-usuarios">
                    <tr><td colspan="4" class="p-4 text-center text-slate-500 text-xs">Sin usuarios cargados en memoria temporal.</td></tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="s5" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Consola Debug / Terminal</h2>
        <div class="glass p-4 rounded-xl space-y-4 text-xs">
            <div>
                <h3 class="font-bold uppercase text-slate-400 mb-1">Terminal de Procesos</h3>
                <div id="debug-log" class="mono bg-black/80 h-64 overflow-y-auto p-4 rounded border border-slate-700" style="color:#38bdf8"></div>
            </div>
        </div>
    </section>

</main>

<div id="toast"></div>

<script>
    // === ESTADO GLOBAL ===
    const relativeSiteUrl = "/sites/GestiondeTurnos";
    const targetListName = 'Turnos Proveedores';
    
    let listaTurnosCache = [];
    let listaUsuariosCache = []; // { user, nombre, email, planta }
    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Usuario Local", email: "logistica@grupocanuelas.com" };

    // === INICIALIZADOR DESACOPLADO (UI-FIRST) ===
    function initApp() {
        try {
            logDebug("Sistema de Inicialización UI-First Invokado.");
            
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.toISOString().split('T')[0];
            const inputFecha = document.getElementById('f_fecha');
            if(inputFecha) inputFecha.value = fechaSeleccionadaGlobal;

            // Inicializar Navegación
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
                    btn.classList.add('active-tab');
                    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                    const target = btn.dataset.target;
                    const el = document.getElementById(target);
                    if(el) el.classList.add('active');
                    if(target === 's6') renderizarBaseProveedores();
                });
            });

            regenerarHorarios(); // Genera slots basados en la planta/fecha default

            // Mock Data Inmediato para no trabar pantalla
            listaTurnosCache = obtenerMockRescate();
            renderizarFilas(listaTurnosCache);
            poblarFiltroUsuarios();

            // Llamadas a red asincrónicas no bloqueantes
            setTimeout(() => { resolverUsuarioLogueado(); }, 50);
            setTimeout(() => { cargarTurnos(); }, 100);

        } catch(e) { logDebug("Init Error: " + e.message); }
    }

    // === REGLAS LOGISTICAS (Calculadora de Slots) ===
    function regenerarHorarios() {
        try {
            const planta = document.getElementById('f_planta').value;
            const fechaStr = document.getElementById('f_fecha').value;
            const select = document.getElementById('f_horario');
            if(!select || !fechaStr) return;

            const d = new Date(fechaStr + 'T00:00:00');
            const day = d.getDay(); // 0 Dom, 1 Lun, ... 6 Sab
            select.innerHTML = '';

            if (day === 0) {
                select.innerHTML = '<option value="">Domingo: Planta Cerrada</option>';
                return;
            }

            let startMins, endMins, duration, lastSlotMins;
            let operativo = false;

            if (planta === 'Parque Cañuelas') {
                if (day >= 1 && day <= 5) { operativo=true; startMins=7*60; endMins=15*60; duration=40; lastSlotMins=14*60+20; }
            } else if (planta === 'Predio Cañuelas') {
                if (day >= 1 && day <= 5) { operativo=true; startMins=10*60; endMins=17*60; duration=40; lastSlotMins=16*60+20; }
                else if (day === 6) { operativo=true; startMins=7*60; endMins=11*60; duration=40; lastSlotMins=10*60+20; }
            } else if (planta === 'Spegazzini') {
                if (day >= 1 && day <= 5) { operativo=true; startMins=8*60; endMins=16*60; duration=45; lastSlotMins=16*60; }
                else if (day === 6) { operativo=true; startMins=7*60; endMins=11*60; duration=45; lastSlotMins=10*60+15; }
            } else if (planta === 'Almar') {
                if (day >= 1 && day <= 5) { operativo=true; startMins=7*60; endMins=14*60; duration=30; lastSlotMins=14*60; }
                else if (day === 6) { operativo=true; startMins=7*60; endMins=11*60; duration=30; lastSlotMins=11*60; }
            }

            if (!operativo) {
                select.innerHTML = '<option value="">Fuera de Rango Operativo</option>';
                return;
            }

            let html = '';
            let current = startMins;
            while (current <= lastSlotMins && (current + duration) <= endMins) {
                let h1 = String(Math.floor(current/60)).padStart(2,'0');
                let m1 = String(current%60).padStart(2,'0');
                let curEnd = current + duration;
                let h2 = String(Math.floor(curEnd/60)).padStart(2,'0');
                let m2 = String(curEnd%60).padStart(2,'0');
                
                let slotStr = `${h1}:${m1} a ${h2}:${m2}`;
                html += `<option value="${slotStr}">${slotStr}</option>`;
                current += duration;
            }
            select.innerHTML = html;
            logDebug(`Slots recalculados: ${planta} (Día ${day}). Ventana: ${duration}min.`);
        } catch(e) { logDebug("Error generando slots: " + e.message); }
    }

    // === CONEXIONES API ===
    async function resolverUsuarioLogueado() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (res.ok) {
                const data = await res.json();
                currentLoggedUser.name = data.Title || data.DisplayName;
                currentLoggedUser.email = data.Email || data.UserPrincipalName;
                document.getElementById('app-user-name').textContent = currentLoggedUser.name;
                logDebug("Autenticación SharePoint exitosa: " + currentLoggedUser.name);
            }
        } catch(e) { logDebug("API Auth Falló. Trabajando localmente."); }
    }

    async function getDigest() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/contextinfo`, { method: 'POST', headers: { "Accept": "application/json;odata=verbose" } });
            const data = await res.json();
            return data.d.GetContextWebInformation.FormDigestValue;
        } catch (e) { return "TOKEN_MOCK"; }
    }

    async function cargarTurnos() {
        logDebug("Sincronizando DB Turnos...");
        try {
            // Mapeo extendido para nuevos campos de SharePoint (Patente, HoraIngreso, HoraSalida, UsuarioGestor)
            // Asumiendo que en SharePoint los llamaste Patente, HoraIngreso, HoraSalida, Gestor
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$select=Id,Title,field_1,field_2,N_x00b0__x0020_de_x0020_OC,field_6,field_5,field_7,Created,Planta,field_3,Patente,HoraIngreso,HoraSalida,Gestor&$orderby=Created desc&$top=100`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (!res.ok) throw new Error("Status " + res.status);
            const data = await res.json();
            listaTurnosCache = data.value || [];
            renderizarFilas(listaTurnosCache);
            poblarFiltroUsuarios();
            logDebug("Sincronización OK.");
        } catch (err) {
            logDebug("Error/Offline API Turnos. Reteniendo datos locales.");
            renderizarFilas(listaTurnosCache); // Dibuja lo que tenga el mock
        }
    }

    function obtenerMockRescate() {
        return [
            { Id: 101, field_1: "20-123456-1", field_2: "Logística Sur", N_x00b0__x0020_de_x0020_OC: "OC-991", field_6: fechaSeleccionadaGlobal+"T00:00", field_5: "07:00 a 07:40", Planta: "Parque Cañuelas", field_7: "Pendiente", Patente: "AF555XX", HoraIngreso: "", HoraSalida: "", Gestor: "Admin" },
            { Id: 102, field_1: "30-987654-2", field_2: "Transporte Norte", N_x00b0__x0020_de_x0020_OC: "OC-992", field_6: fechaSeleccionadaGlobal+"T00:00", field_5: "10:00 a 10:40", Planta: "Predio Cañuelas", field_7: "Aprobado", Patente: "AA123BB", HoraIngreso: "10:05", HoraSalida: "", Gestor: "Daniel C." }
        ];
    }

    // === RENDERIZADO TABLA PRINCIPAL ===
    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="9" class="p-4 text-center text-slate-500 text-xs">Sin registros.</td></tr>`;
            return;
        }

        let htmlRows = '';
        items.forEach(t => {
            const estado = String(t.field_7 || 'Pendiente').trim();
            const esAprobado = estado.toLowerCase() === 'aprobado';
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : (estado.toLowerCase() === 'cancelado' ? 'text-rose-400' : 'text-amber-400');
            
            let pEmail = t.field_3 ? String(t.field_3).replace(/'/g, "\\'") : '';
            let pProv = t.field_2 ? String(t.field_2).replace(/'/g, "\\'") : '';
            let fSol = t.field_6 ? String(t.field_6).split('T')[0] : '';
            
            // Tracking Visual
            let inOutStr = `<span class="text-emerald-400 text-[10px]">${t.HoraIngreso || '--:--'}</span> / <span class="text-rose-400 text-[10px]">${t.HoraSalida || '--:--'}</span>`;

            htmlRows += `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30">
                <td class="p-2 font-mono text-sky-400 text-xs font-bold">${t.Id}</td>
                <td class="p-2 text-xs text-slate-300 font-bold">${t.Planta || '-'}</td>
                <td class="p-2 text-xs text-white">${t.field_2 || '-'}</td>
                <td class="p-2 text-xs text-amber-300 font-mono">${t.field_5 || '-'}</td>
                <td class="p-2 text-xs font-mono tracking-widest text-slate-300">${t.Patente || 'N/D'}</td>
                <td class="p-2 font-mono bg-black/20 text-center rounded">${inOutStr}</td>
                <td class="p-2 text-xs ${colorEst}">${estado}</td>
                <td class="p-2 text-[10px] text-slate-400">${t.Gestor || '-'}</td>
                <td class="p-2 text-center text-lg flex justify-center gap-2">
                    <button onclick="consultarTurnoAlFormulario(${t.Id})" class="hover:scale-125" title="Ver / Editar">👁️</button>
                    ${!esAprobado ? `<button onclick="cambiarEstado(${t.Id}, 'Aprobado')" class="hover:scale-125" title="Aprobar">✅</button>` : ''}
                    <button onclick="marcarTracking(${t.Id}, 'IN')" class="text-emerald-400 hover:scale-125" title="Check-In">🚛</button>
                    <button onclick="marcarTracking(${t.Id}, 'OUT')" class="text-rose-400 hover:scale-125" title="Check-Out">🏁</button>
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    // === LOGICA ABM ===
    function consultarTurnoAlFormulario(id) {
        const t = listaTurnosCache.find(x => x.Id == id);
        if(!t) return;

        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_patente').value = t.Patente || '';
        document.getElementById('f_hora_ing').value = t.HoraIngreso || '';
        document.getElementById('f_hora_sal').value = t.HoraSalida || '';
        document.getElementById('f_cuit').value = t.field_1 || '';
        document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || '';
        document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('f_email').value = t.field_3 || '';
        document.getElementById('f_fecha').value = t.field_6 ? t.field_6.split('T')[0] : '';
        document.getElementById('f_planta').value = t.Planta || 'Parque Cañuelas';
        
        regenerarHorarios();
        document.getElementById('f_horario').value = t.field_5 || '';
        document.getElementById('f_usuario_gestor').textContent = t.Gestor || '-';

        const esAprobado = String(t.field_7 || '').trim().toLowerCase() === 'aprobado';
        const ind = document.getElementById('form-mode-indicator');
        
        if(esAprobado) {
            ind.textContent = "Consulta (Aprobado)";
            ind.className = "text-xs uppercase px-3 py-1 bg-red-900 text-red-300 rounded-full font-bold";
            document.getElementById('btn-modificar').disabled = true;
            document.getElementById('btn-modificar').classList.add('opacity-30');
            document.querySelectorAll('#s1 input:not([type="hidden"]), #s1 select').forEach(el => el.disabled = true);
        } else {
            ind.textContent = "Edición (Pendiente)";
            ind.className = "text-xs uppercase px-3 py-1 bg-amber-900 text-amber-300 rounded-full font-bold";
            document.getElementById('btn-modificar').disabled = false;
            document.getElementById('btn-modificar').classList.remove('opacity-30');
            document.querySelectorAll('#s1 input, #s1 select').forEach(el => el.disabled = false);
        }
        
        document.querySelector('[data-target="s1"]').click();
    }

    function limpiarFormularioABM() {
        document.getElementById('f_item_id').value = '';
        document.querySelectorAll('#s1 input:not([type="hidden"])').forEach(i => i.value = '');
        document.getElementById('f_usuario_gestor').textContent = '-';
        document.getElementById('btn-modificar').disabled = true;
        document.getElementById('btn-modificar').classList.add('opacity-30');
        document.querySelectorAll('#s1 input, #s1 select').forEach(el => el.disabled = false);
        document.getElementById('form-mode-indicator').textContent = "Alta de Turno";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold";
    }

    // Acciones Transaccionales Híbridas (Soportan API o Mock Local)
    async function ejecutarTransaccion(itemId, payload, successMsg) {
        payload.Gestor = currentLoggedUser.name; // Siempre audita el usuario
        try {
            const digest = await getDigest();
            const method = itemId ? 'MERGE' : 'POST';
            const url = itemId ? `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})` 
                               : `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items`;
            
            const reqHeaders = { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest };
            if(itemId) { reqHeaders["X-HTTP-Method"] = "MERGE"; reqHeaders["If-Match"] = "*"; }

            const res = await fetch(url, { method: 'POST', headers: reqHeaders, body: JSON.stringify(payload) });
            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error("Falló SP");
            
            showToast(successMsg, "ok");
            cargarTurnos();
        } catch(e) {
            // Mock Fallback
            if(itemId) {
                listaTurnosCache = listaTurnosCache.map(t => t.Id == itemId ? {...t, ...payload} : t);
            } else {
                payload.Id = Math.floor(Math.random()*1000);
                payload.Created = new Date().toISOString();
                listaTurnosCache.unshift(payload);
            }
            showToast(successMsg + " (Cache Local)", "ok");
            renderizarFilas(listaTurnosCache);
            poblarFiltroUsuarios();
        }
    }

    async function crearTurno() {
        const payload = {
            Title: "PROV-" + Date.now().toString().slice(-4),
            field_1: document.getElementById('f_cuit').value.trim(),
            N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            Planta: document.getElementById('f_planta').value,
            field_5: document.getElementById('f_horario').value,
            field_7: "Pendiente",
            Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            HoraIngreso: document.getElementById('f_hora_ing').value,
            HoraSalida: document.getElementById('f_hora_sal').value
        };
        if(!payload.field_1 || !payload.field_6 || !payload.field_5) return showToast("Complete campos clave", "err");
        await ejecutarTransaccion(null, payload, "Turno Registrado");
        limpiarFormularioABM();
    }

    async function guardarCambiosTurno() {
        const id = document.getElementById('f_item_id').value;
        if(!id) return;
        const payload = {
            field_1: document.getElementById('f_cuit').value.trim(),
            N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            Planta: document.getElementById('f_planta').value,
            field_5: document.getElementById('f_horario').value,
            Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            HoraIngreso: document.getElementById('f_hora_ing').value,
            HoraSalida: document.getElementById('f_hora_sal').value
        };
        await ejecutarTransaccion(id, payload, "Cambios Guardados");
        limpiarFormularioABM();
    }

    async function cambiarEstado(id, estado) {
        if(!confirm(`¿Marcar turno como ${estado}?`)) return;
        await ejecutarTransaccion(id, { field_7: estado }, `Turno ${estado}`);
    }

    async function marcarTracking(id, tipo) {
        const t = listaTurnosCache.find(x => x.Id == id);
        if(!t) return;
        const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        
        let payload = {};
        if (tipo === 'IN') payload.HoraIngreso = horaStr;
        if (tipo === 'OUT') payload.HoraSalida = horaStr;
        
        await ejecutarTransaccion(id, payload, `Tracking ${tipo} registrado: ${horaStr}`);
    }

    // === FILTROS EN MONITOR ===
    function poblarFiltroUsuarios() {
        const select = document.getElementById('filtro_usuario');
        if(!select) return;
        const gestores = [...new Set(listaTurnosCache.map(t => t.Gestor).filter(Boolean))];
        let html = '<option value="TODOS">-- Todos los Usuarios --</option>';
        gestores.forEach(g => html += `<option value="${g}">${g}</option>`);
        select.innerHTML = html;
    }

    function aplicarFiltrosMonitor() {
        const p = document.getElementById('filtro_planta').value;
        const u = document.getElementById('filtro_usuario').value;
        let filtrados = listaTurnosCache;
        
        if(p !== 'TODAS') filtrados = filtrados.filter(t => t.Planta === p);
        if(u !== 'TODOS') filtrados = filtrados.filter(t => t.Gestor === u);
        
        renderizarFilas(filtrados);
    }
    
    function restablecerFiltros() {
        document.getElementById('filtro_planta').value = 'TODAS';
        document.getElementById('filtro_usuario').value = 'TODOS';
        renderizarFilas(listaTurnosCache);
    }

    // === BASE PROVEEDORES ===
    function renderizarBaseProveedores() {
        const tbodyProv = document.getElementById('tabla-proveedores');
        if(!tbodyProv) return;
        const cuitsMapeados = new Set();
        let htmlProv = '';

        listaTurnosCache.forEach(t => {
            let c = t.field_1 ? String(t.field_1).trim() : '';
            if (c && !cuitsMapeados.has(c)) {
                cuitsMapeados.add(c);
                htmlProv += `
                <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                    <td class="py-3 px-3 font-mono font-bold text-amber-400">${c}</td>
                    <td class="px-3 text-white">${t.field_2 || 'S/D'}</td>
                    <td class="px-3 text-slate-400">${t.field_3 || '-'}</td>
                </tr>`;
            }
        });
        tbodyProv.innerHTML = htmlProv || `<tr><td colspan="3" class="p-4 text-center">Sin proveedores</td></tr>`;
    }

    // === BASE USUARIOS (IMPORTAR CSV NATIVO) ===
    function procesarCSVUsuarios() {
        const fileInput = document.getElementById('file_usuarios');
        const file = fileInput.files[0];
        if (!file) return showToast("Seleccione un archivo CSV primero", "err");

        const reader = new FileReader();
        reader.onload = function(e) {
            try {
                const text = e.target.result;
                const lines = text.split('\n');
                listaUsuariosCache = [];
                
                // Asume cabecera en línea 0. Parsea desde línea 1. Delimitador coma o punto y coma
                for(let i=1; i<lines.length; i++) {
                    const row = lines[i].trim();
                    if(!row) continue;
                    const cols = row.split(/,|;/); // Soporta , o ;
                    if(cols.length >= 4) {
                        listaUsuariosCache.push({
                            usuario: cols[0].trim(),
                            nombre: cols[1].trim(),
                            email: cols[2].trim(),
                            planta: cols[3].trim()
                        });
                    }
                }
                
                // Renderizar
                const tbody = document.getElementById('tabla-usuarios');
                tbody.innerHTML = listaUsuariosCache.map(u => `
                    <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                        <td class="p-3 font-mono text-sky-400">${u.usuario}</td>
                        <td class="p-3 text-white">${u.nombre}</td>
                        <td class="p-3 text-slate-400">${u.email}</td>
                        <td class="p-3 font-bold">${u.planta}</td>
                    </tr>
                `).join('');
                
                showToast(`Padrón Sincronizado: ${listaUsuariosCache.length} usuarios`, "ok");
                logDebug(`Importación CSV completada. ${listaUsuariosCache.length} usuarios cargados en memoria.`);
            } catch(err) {
                showToast("Error parseando el archivo", "err");
                logDebug("CSV Parse Error: " + err.message);
            }
        };
        reader.readAsText(file);
    }

    // === RESUMEN DIARIO POR CORREO ===
    function enviarResumenDiario() {
        if(listaUsuariosCache.length === 0) {
            showToast("Advertencia: No hay usuarios en Base para enviar mail.", "err");
            // Continuamos de todos modos pero sin CCO masivo
        }

        const fFiltro = document.getElementById('f_fecha').value || fechaSeleccionadaGlobal;
        const turnosHoy = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fFiltro));
        
        if(turnosHoy.length === 0) return showToast("No hay turnos hoy para resumir", "err");

        // Agrupación y formateo de texto puro (Mailto no soporta HTML complejo)
        let bodyTexto = `RESUMEN DIARIO LOGÍSTICO - ${fFiltro}\n`;
        bodyTexto += `Generado por: ${currentLoggedUser.name}\n\n`;

        const plantas = [...new Set(turnosHoy.map(t => t.Planta).filter(Boolean))];
        
        plantas.forEach(p => {
            bodyTexto += `--- PLANTA: ${p.toUpperCase()} ---\n`;
            const turnosPlanta = turnosHoy.filter(t => t.Planta === p);
            turnosPlanta.forEach(t => {
                const est = t.field_7 || 'Pendiente';
                bodyTexto += `* Slot: ${t.field_5} | Patente: ${t.Patente||'S/D'} | Prov: ${t.field_2} | Estado: ${est} | Gestor: ${t.Gestor||'-'}\n`;
                if(t.HoraIngreso) bodyTexto += `  (In: ${t.HoraIngreso} - Out: ${t.HoraSalida||'Pendiente'})\n`;
            });
            bodyTexto += `\n`;
        });

        const emailsMailingList = listaUsuariosCache.map(u => u.email).filter(Boolean).join(';');
        const asunto = `Resumen Operativo Turnos Molca Spegazzini - ${fFiltro}`;
        
        const mailUrl = `mailto:?bcc=${emailsMailingList}&subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(bodyTexto)}`;
        window.location.href = mailUrl;
        logDebug("Lanzando cliente de correo nativo para Resumen Diario.");
    }

    // Arranque Forzado
    logDebug("Cargando Scripts Base...");
    initApp();
</script>
</body>
</html>