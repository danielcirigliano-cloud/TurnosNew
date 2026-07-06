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
        .mono { font-family: 'JetBrains Mono', monospace; }
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
    <h1 class="text-xl font-bold text-white mb-5 uppercase tracking-wide">MOLCA <span class="text-sky-400">LOGÍSTICA</span></h1>
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
        <span class="text-slate-400 font-semibold">Usuario Conectado:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Iniciando...</span>
    </div>

    <section id="s1" class="tab-content">
        <div class="flex justify-between items-center mb-4 max-w-4xl mt-10">
            <h2 class="text-2xl font-bold text-sky-400">Panel Operativo de Gestión</h2>
            <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold">Alta de Turno</div>
        </div>
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4">
            <input type="hidden" id="f_item_id">
            
            <div class="col-span-2 grid grid-cols-3 gap-4 border-b border-slate-700 pb-4 mb-2">
                <div>
                    <label class="block text-[10px] uppercase text-slate-400 font-bold">Patente Vehículo</label>
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
                <label class="block text-[10px] uppercase text-slate-400 font-bold">CUIT Proveedor (field_1)</label>
                <input type="text" id="f_cuit" placeholder="XX-XXXXXXXX-X" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Número OC (N_x00b0__x0020_de_x0020_OC)</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Razón Social Proveedor (field_2)</label>
                <input type="text" id="f_proveedor" placeholder="Proveedor" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div class="col-span-2">
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Email Referencia (field_3)</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>

            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Fecha Solicitud (field_6)</label>
                <input type="date" id="f_fecha" onchange="regenerarHorarios()" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Tipo de Descarga (Planta)</label>
                <select id="f_planta" class="bg-slate-900 border border-slate-700 p-2 w-full text-white">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                    <option value="Materia Prima">Materia Prima</option>
                </select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Planta de Descarga (PlantaDescarga)</label>
                <select id="f_planta_descarga" onchange="regenerarHorarios()" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-400 font-bold">
                    <option value="Parque Cañuelas">Parque Cañuelas</option>
                    <option value="Predio Cañuelas">Predio Cañuelas</option>
                    <option value="Spegazzini">Spegazzini</option>
                    <option value="Almar">Almar</option>
                </select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold">Slot Horario Calculado (field_5)</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-2 w-full text-sky-300 font-mono font-bold"></select>
            </div>

            <div class="col-span-2 bg-slate-950 p-3 rounded text-xs border border-slate-800 text-slate-400">
                Última Modificación por (Editor): <span id="f_usuario_gestor" class="font-bold text-white">-</span> | Modificado: <span id="f_fecha_mod" class="font-bold text-slate-300">-</span>
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
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Filtrar Planta Descarga</label>
                <select id="filtro_planta_descarga" onchange="aplicarFiltrosMonitor()" class="bg-slate-900 border border-slate-700 p-1.5 text-xs text-white rounded">
                    <option value="TODAS">-- Todas las Plantas --</option>
                    <option value="Parque Cañuelas">Parque Cañuelas</option>
                    <option value="Predio Cañuelas">Predio Cañuelas</option>
                    <option value="Spegazzini">Spegazzini</option>
                    <option value="Almar">Almar</option>
                </select>
            </div>
            <div>
                <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Filtrar por Modificado por (Editor)</label>
                <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-900 border border-slate-700 p-1.5 text-xs text-white rounded">
                    <option value="TODOS">-- Todos los Modificadores --</option>
                </select>
            </div>
            <button onclick="restablecerFiltros()" class="bg-slate-700 px-3 py-1.5 text-xs rounded">Restablecer</button>
            <button onclick="cargarTurnos()" class="ml-auto bg-slate-800 border border-slate-600 px-4 py-1.5 text-xs rounded text-sky-400">↻ Refrescar Red</button>
        </div>

        <div class="glass p-4 rounded-xl overflow-x-auto h-[650px]">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow z-10">
                    <tr>
                        <th class="py-3 px-2">ID</th>
                        <th class="px-2">Planta Descarga</th>
                        <th class="px-2">Tipo Descarga</th>
                        <th class="px-2">Proveedor</th>
                        <th class="px-2">Horario Asignado</th>
                        <th class="px-2">Patente</th>
                        <th class="px-2">Tracking (In/Out)</th>
                        <th class="px-2">Estado</th>
                        <th class="px-2">Modificado Por</th>
                        <th class="px-2 text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                    <tr><td colspan="10" class="p-6 text-center text-slate-500 text-xs">Cargando matriz transaccional...</td></tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="s6" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Base de Datos Maestro de Proveedores</h2>
        <div class="glass p-4 rounded-xl overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold">
                    <tr><th class="py-3 px-3">CUIT (field_1)</th><th class="px-3">Razón Social (field_2)</th><th class="px-3">Email (field_3)</th></tr>
                </thead>
                <tbody id="tabla-proveedores"></tbody>
            </table>
        </div>
    </section>

    <section id="s7" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Gestión de Usuarios</h2>
        <p class="text-xs text-slate-400 mb-6">Importe el archivo delimitado por comas (CSV): <span class="font-mono text-amber-300">Usuario,Nombre_Apellido,Email,Planta</span></p>
        
        <div class="flex gap-4 mb-6 glass p-4 rounded items-center">
            <input type="file" id="file_usuarios" accept=".csv" class="text-sm">
            <button onclick="procesarCSVUsuarios()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 font-bold rounded text-xs">📥 Importar y Sincronizar</button>
        </div>

        <div class="glass p-4 rounded-xl overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold">
                    <tr><th class="py-3 px-3">Usuario</th><th class="px-3">Nombre y Apellido</th><th class="px-3">Correo Electrónico</th><th class="px-3">Planta Base</th></tr>
                </thead>
                <tbody id="tabla-usuarios">
                    <tr><td colspan="4" class="p-4 text-center text-slate-500 text-xs">Sin usuarios cargados en memoria.</td></tr>
                </tbody>
            </table>
        </div>
    </section>

    <section id="s5" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Consola Debug / Terminal</h2>
        <div class="glass p-4 rounded-xl space-y-4 text-xs">
            <div>
                <h3 class="font-bold uppercase text-slate-400 mb-1">Terminal de Procesos Internos</h3>
                <div id="debug-log" class="mono bg-black/80 h-64 overflow-y-auto p-4 rounded border border-slate-700" style="color:#38bdf8"></div>
            </div>
            <div>
                <h3 class="font-bold uppercase text-slate-400 mb-1">Consola de Log Usuario</h3>
                <div id="user-logs" class="mono bg-black/80 h-32 overflow-y-auto p-4 rounded border border-slate-700" style="color:#fbbf24"></div>
            </div>
        </div>
    </section>
</main>

<div id="toast"></div>

<script>
    let listaTurnosCache = [];
    let listaUsuariosCache = [];
    let transicionPendienteCtx = null;
    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Usuario", email: "logistica@grupocanuelas.com" };

    // --- RENDERIZADO OPTIMISTA (UI-FIRST) ---
    function initApp() {
        try {
            logDebug("Inicializando arquitectura de impacto único en DOM...");
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.toISOString().split('T')[0];
            
            const inputFecha = document.getElementById('f_fecha');
            if(inputFecha) inputFecha.value = fechaSeleccionadaGlobal;
            
            const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
            const fechaObj = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00');
            document.getElementById('f_dia').value = dias[fechaObj.getDay()];

            setupRuteoPestañas();
            regenerarHorarios();

            // Carga de contingencia local
            listaTurnosCache = obtenerSeedMockLogistico();
            renderizarFilas(listaTurnosCache);
            poblarFiltroModificadores();

            // Desacople de peticiones REST de fondo
            setTimeout(() => { resolverUsuarioLogueado(); }, 40);
            setTimeout(() => { cargarTurnos(); }, 80);
        } catch(e) { logDebug("Init Error: " + e.message); }
    }

    function setupRuteoPestañas() {
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
    }

    // --- CALCULADORA MATEMÁTICA DE HORARIOS SEGÚN PLANTA Y DÍA ---
    function regenerarHorarios() {
        try {
            const plantaDescarga = document.getElementById('f_planta_descarga').value;
            const fechaStr = document.getElementById('f_fecha').value;
            const select = document.getElementById('f_horario');
            if(!select || !fechaStr) return;

            const d = new Date(fechaStr + 'T00:00:00');
            const day = d.getDay();
            select.innerHTML = '';

            if (day === 0) {
                select.innerHTML = '<option value="">Domingo: Planta Cerrada</option>';
                return;
            }

            let startMins, endMins, duration, lastSlotMins;
            let operativo = false;

            if (plantaDescarga === 'Parque Cañuelas') {
                if (day >= 1 && day <= 5) { operativo = true; startMins = 7*60; endMins = 15*60; duration = 40; lastSlotMins = 14*60+20; }
            } else if (plantaDescarga === 'Predio Cañuelas') {
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
                select.innerHTML = '<option value="">Sin Turnos Programados</option>';
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
                htmlOpts += `<option value="${slotStr}">${slotStr}</option>`;
                current += duration;
            }
            select.innerHTML = htmlOpts;
        } catch(e) { logDebug("Error slots: " + e.message); }
    }

    // --- INTEGRACIÓN REST SHAREPOINT (Mapeo de Campos Reales) ---
    async function resolverUsuarioLogueado() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (res.ok) {
                const data = await res.json();
                currentLoggedUser.name = data.Title || data.DisplayName;
                currentLoggedUser.email = data.Email || data.UserPrincipalName;
                document.getElementById('app-user-name').textContent = currentLoggedUser.name;
            }
        } catch(e) {}
    }

    async function cargarTurnos() {
        try {
            // Requerimiento: Mapeo exacto de los campos físicos provistos
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$select=Id,Title,field_1,field_2,field_3,field_5,field_6,field_7,N_x00b0__x0020_de_x0020_OC,Planta,PlantaDescarga,Patente,HoraIngreso,HoraSalida,Modified,Editor/Title&$expand=Editor&$orderby=Created desc&$top=60`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (!res.ok) throw new Error();
            const data = await res.json();
            listaTurnosCache = data.value || [];
            
            renderizarFilas(listaTurnosCache);
            poblarFiltroModificadores();
            logDebug("Sincronizado con SharePoint.");
        } catch (err) {
            logDebug("Modo desconectado. Operando con matriz de contingencia.");
        }
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="10" class="p-4 text-center text-slate-500 text-xs">Sin solicitudes logísticas hoy.</td></tr>`;
            return;
        }

        let htmlRows = '';
        items.forEach(t => {
            const estado = String(t.field_7 || 'Pendiente').trim();
            const esAprobado = estado.toLowerCase() === 'aprobado';
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : (estado.toLowerCase() === 'cancelado' ? 'text-rose-400' : 'text-amber-400');
            
            // Extracción segura del modificador por OData expand
            let modificador = '-';
            if (t.Editor && t.Editor.Title) modificador = t.Editor.Title;
            else if (t.Gestor) modificador = t.Gestor;

            let inOutStr = `<span class="text-emerald-400 text-[11px] font-bold">${t.HoraIngreso || '--:--'}</span> / <span class="text-rose-400 text-[11px] font-bold">${t.HoraSalida || '--:--'}</span>`;

            htmlRows += `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                <td class="p-2.5 font-mono text-sky-400 font-bold">${t.Id}</td>
                <td class="p-2.5 text-slate-300 font-bold">${t.PlantaDescarga || '-'}</td>
                <td class="p-2.5 font-mono text-slate-400">${t.Planta || '-'}</td>
                <td class="p-2.5 text-white font-semibold">${t.field_2 || '-'}</td>
                <td class="p-2.5 text-amber-300 font-mono font-bold">${t.field_5 || '-'}</td>
                <td class="p-2.5 font-mono tracking-wider text-slate-200">${t.Patente || 'N/D'}</td>
                <td class="p-2.5 text-center bg-black/10 rounded">${inOutStr}</td>
                <td class="p-2.5 ${colorEst}">${estado}</td>
                <td class="p-2.5 text-slate-400">${modificador}</td>
                <td class="p-2.5 text-center text-sm flex justify-center gap-2">
                    <button onclick="consultarTurnoAlFormulario(${t.Id})" class="hover:scale-125" title="Consultar / ABM">👁️</button>
                    ${!esAprobado ? `<button onclick="cambiarEstado(${t.Id}, 'Aprobado')" class="hover:scale-125" title="Aprobar">✅</button>` : ''}
                    <button onclick="marcarTracking(${t.Id}, 'IN')" class="text-emerald-400 hover:scale-125" title="Check-In">🚛</button>
                    <button onclick="marcarTracking(${t.Id}, 'OUT')" class="text-rose-400 hover:scale-125" title="Check-Out">🏁</button>
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    // --- CLIENTE INTEGRADO ABM (MODIFICACIÓN Y CONSULTA) ---
    function consultarTurnoAlFormulario(itemId) {
        const idNumerico = parseInt(itemId, 10);
        const t = listaTurnosCache.find(item => parseInt(item.Id, 10) === idNumerico);
        if (!t) return;

        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_patente').value = t.Patente || '';
        document.getElementById('f_hora_ing').value = t.HoraIngreso || '';
        document.getElementById('f_hora_sal').value = t.HoraSalida || '';
        document.getElementById('f_cuit').value = t.field_1 || '';
        document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || '';
        document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('f_email').value = t.field_3 || '';
        document.getElementById('f_fecha').value = t.field_6 ? t.field_6.split('T')[0] : '';
        document.getElementById('f_planta').value = t.Planta || 'Packaging';
        document.getElementById('f_planta_descarga').value = t.PlantaDescarga || 'Parque Cañuelas';
        
        regenerarHorarios();
        document.getElementById('f_horario').value = t.field_5 || '';
        
        let modPor = t.Editor ? t.Editor.Title : (t.Gestor || '-');
        document.getElementById('f_usuario_gestor').textContent = modPor;
        document.getElementById('f_fecha_mod').textContent = t.Modified ? new Date(t.Modified).toLocaleString() : '-';

        const estadoLimpio = String(t.field_7 || 'Pendiente').trim().toLowerCase();
        const ind = document.getElementById('form-mode-indicator');
        
        if(estadoLimpio === 'aprobado') {
            ind.textContent = "Consulta Exclusiva (Turno APROBADO) 🔒";
            ind.className = "text-xs uppercase px-3 py-1 bg-red-900 text-red-300 rounded-full font-bold";
            document.getElementById('btn-modificar').disabled = true;
            document.getElementById('btn-modificar').classList.add('opacity-40', 'cursor-not-allowed');
            document.querySelectorAll('#s1 input, #s1 select').forEach(el => el.disabled = true);
        } else {
            ind.textContent = "Edición Activa (Turno PENDIENTE) ✏️";
            ind.className = "text-xs uppercase px-3 py-1 bg-amber-900 text-amber-300 rounded-full font-bold";
            document.getElementById('btn-modificar').disabled = false;
            document.getElementById('btn-modificar').classList.remove('opacity-40', 'cursor-not-allowed');
            document.querySelectorAll('#s1 input, #s1 select').forEach(el => el.disabled = false);
        }
        
        document.querySelector('[data-target="s1"]').click();
    }

    function limpiarFormularioABM() {
        document.getElementById('f_item_id').value = '';
        document.querySelectorAll('#s1 input').forEach(i => i.value = '');
        document.getElementById('f_usuario_gestor').textContent = '-';
        document.getElementById('f_fecha_mod').textContent = '-';
        document.getElementById('btn-modificar').disabled = true;
        document.getElementById('btn-modificar').classList.add('opacity-40', 'cursor-not-allowed');
        document.querySelectorAll('#s1 input, #s1 select').forEach(el => el.disabled = false);
        document.getElementById('form-mode-indicator').textContent = "Alta de Turno";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold";
    }

    async function ejecutarTransaccion(itemId, payload, successMsg) {
        payload.Gestor = currentLoggedUser.name; 
        try {
            const digest = await getDigest();
            const url = itemId ? `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})` 
                               : `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items`;
            
            const reqHeaders = { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest };
            if(itemId) { reqHeaders["X-HTTP-Method"] = "MERGE"; reqHeaders["If-Match"] = "*"; }

            const res = await fetch(url, { method: 'POST', headers: reqHeaders, body: JSON.stringify(payload) });
            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error();
            
            showToast(successMsg, "ok");
            cargarTurnos();
        } catch(e) {
            // Transacción en caché local para QA
            if(itemId) {
                listaTurnosCache = listaTurnosCache.map(t => t.Id == itemId ? {...t, ...payload, Modified: new Date().toISOString(), Editor: {Title: currentLoggedUser.name}} : t);
            } else {
                payload.Id = Math.floor(Math.random()*1000);
                payload.Modified = new Date().toISOString();
                payload.Editor = {Title: currentLoggedUser.name};
                listaTurnosCache.unshift(payload);
            }
            showToast(successMsg + " (Entorno Local)", "ok");
            renderizarFilas(listaTurnosCache);
            poblarFiltroModificadores();
        }
    }

    async function crearTurno() {
        const payload = {
            field_1: document.getElementById('f_cuit').value.trim(),
            field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value,
            field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            field_7: "Pendiente",
            N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value,
            PlantaDescarga: document.getElementById('f_planta_descarga').value,
            Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            HoraIngreso: document.getElementById('f_hora_ing').value,
            HoraSalida: document.getElementById('f_hora_sal').value
        };
        if(!payload.field_1 || !payload.field_6) return showToast("Faltan datos obligatorios.", "err");
        await ejecutarTransaccion(null, payload, "Turno Creado");
        limpiarFormularioABM();
    }

    async function guardarCambiosTurno() {
        const id = document.getElementById('f_item_id').value;
        if(!id) return;
        const payload = {
            field_1: document.getElementById('f_cuit').value.trim(),
            field_2: document.getElementById('f_proveedor').value.trim(),
            field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value,
            field_6: document.getElementById('f_fecha').value + "T00:00:00Z",
            N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value,
            PlantaDescarga: document.getElementById('f_planta_descarga').value,
            Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            HoraIngreso: document.getElementById('f_hora_ing').value,
            HoraSalida: document.getElementById('f_hora_sal').value
        };
        await ejecutarTransaccion(id, payload, "Modificación Completada");
        limpiarFormularioABM();
    }

    async function cambiarEstado(id, nuevoEst) {
        await ejecutarTransaccion(id, { field_7: nuevoEst }, `Turno ${nuevoEst}`);
    }

    async function marcarTracking(id, tipo) {
        const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        let payload = {};
        if(tipo === 'IN') payload.HoraIngreso = horaStr;
        if(tipo === 'OUT') payload.HoraSalida = horaStr;
        await ejecutarTransaccion(id, payload, `Marca de tiempo registrada: ${horaStr}`);
    }

    // --- FILTRADOS OPERATIVOS ---
    function poblarFiltroModificadores() {
        const select = document.getElementById('filtro_usuario');
        if(!select) return;
        const usuarios = [...new Set(listaTurnosCache.map(t => t.Editor ? t.Editor.Title : t.Gestor).filter(Boolean))];
        let htmlOpts = '<option value="TODOS">-- Todos los Modificadores --</option>';
        usuarios.forEach(u => { htmlOpts += `<option value="${u}">${u}</option>`; });
        select.innerHTML = htmlOpts;
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

    // --- BASE PROVEEDORES ---
    function renderizarBaseProveedores() {
        const tbody = document.getElementById('tabla-proveedores');
        if(!tbody) return;
        const cuits = new Set();
        let htmlRows = '';
        listaTurnosCache.forEach(t => {
            let c = t.field_1 ? String(t.field_1).trim() : '';
            if(c && !cuits.has(c)) {
                cuits.add(c);
                htmlRows += `<tr class="border-b border-slate-700/50 text-xs"><td class="p-3 font-mono font-bold text-amber-400">${c}</td><td class="p-3 text-white">${t.field_2 || '-'}</td><td class="p-3 text-slate-400">${t.field_3 || '-'}</td></tr>`;
            }
        });
        tbody.innerHTML = htmlRows;
    }

    // --- IMPORTADOR CSV NATIVO ---
    function procesarCSVUsuarios() {
        const file = document.getElementById('file_usuarios').files[0];
        if(!file) return showToast("Suba un archivo CSV.", "err");
        const r = new FileReader();
        r.onload = function(e) {
            try {
                const lines = e.target.result.split('\n');
                listaUsuariosCache = [];
                for(let i = 1; i < lines.length; i++) {
                    const row = lines[i].trim();
                    if(!row) continue;
                    const cols = row.split(/,|;/);
                    if(cols.length >= 4) {
                        listaUsuariosCache.push({ usuario: cols[0], nombre: cols[1], email: cols[2], planta: cols[3] });
                    }
                }
                document.getElementById('tabla-usuarios').innerHTML = listaUsuariosCache.map(u => `
                    <tr class="border-b border-slate-700/50 text-xs"><td class="p-2.5 font-mono text-sky-400">${u.usuario}</td><td class="p-2.5 text-white">${u.nombre}</td><td class="p-2.5 text-slate-400">${u.email}</td><td class="p-2.5 font-bold">${u.planta}</td></tr>
                `).join('');
                showToast(`Sincronizados ${listaUsuariosCache.length} usuarios`, "ok");
            } catch(err) { showToast("CSV inválido", "err"); }
        };
        r.readAsText(file);
    }

    // --- ENVIAR RESUMEN OPERATIVO ---
    function enviarResumenDiario() {
        const fFiltro = document.getElementById('f_fecha').value || fechaSeleccionadaGlobal;
        const turnosHoy = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fFiltro));
        if(turnosHoy.length === 0) return showToast("Sin turnos registrados hoy.", "err");

        let textoMail = `RESUMEN DIARIO LOGÍSTICO - EMISIÓN: ${fFiltro}\n\n`;
        const plantas = [...new Set(turnosHoy.map(t => t.PlantaDescarga).filter(Boolean))];
        
        plantas.forEach(p => {
            textoMail += `================ PLANTA: ${p.toUpperCase()} ================\n`;
            turnosHoy.filter(t => t.PlantaDescarga === p).forEach(t => {
                let mPor = t.Editor ? t.Editor.Title : (t.Gestor || '-');
                textoMail += `* Slot: ${t.field_5} | Patente: ${t.Patente || 'N/D'} | OC: ${t.N_x00b0__x0020_de_x0020_OC || '-'} | Prov: ${t.field_2} | Estado: ${t.field_7} | Modificado Por: ${mPor}\n`;
                if(t.HoraIngreso) textoMail += `  [Tracking Real] Ingreso: ${t.HoraIngreso} h | Salida: ${t.HoraSalida || 'En descarga'}\n`;
            });
            textoMail += `\n`;
        });

        const bccList = listaUsuariosCache.map(u => u.email).filter(Boolean).join(';');
        const subject = `Resumen General de Turnos Logísticos - ${fFiltro}`;
        window.location.href = `mailto:?bcc=${bccList}&subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(textoMail)}`;
    }

    function logDebug(msg) {
        const area = document.getElementById('debug-log');
        if(!area) return;
        area.insertAdjacentHTML('beforeend', `<div>[${new Date().toLocaleTimeString()}] ${msg}</div>`);
        area.scrollTop = area.scrollHeight;
    }

    function obtenerSeedMockLogistico() {
        return [
            { Id: 18, Title: "PROV-8821", field_1: "30-58965412-7", field_2: "SAF ARGENTINA", field_3: "saf@saf.com.ar", field_5: "08:00 a 08:45 h", field_6: "2026-06-11T00:00:00Z", field_7: "Pendiente", N_x00b0__x0020_de_x0020_OC: "723139", Planta: "Insumos", PlantaDescarga: "Spegazzini", Patente: "AF123BC", HoraIngreso: "", HoraSalida: "", Gestor: "Daniel Cirigliano" }
        ];
    }

    initApp();
</script>
</body>
</html>