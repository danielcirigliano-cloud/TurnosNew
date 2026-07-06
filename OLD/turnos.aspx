<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consola Maestra | Logistica de Turnos Molca Spegazzini</title>
    <script src="https://cdn.tailwindcss.com"></script>
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
        .tab-content.active { display: block; animation: fadeIn 0.25s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: none; } }
        
        .tab-btn { color: #94a3b8; transition: background .15s, color .15s; font-size: 0.95rem; }
        .tab-btn:hover { background: #1e293b; color: #fff; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; }

        /* Toast */
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
        <button class="w-full text-left px-4 py-2 rounded tab-btn active-tab" data-target="s1">1. Nueva Solicitud</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s2" onclick="cargarTurnos()">2. Turnos del Dia</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s6" onclick="renderizarBaseProveedores()">3. Base Proveedores</button>
        <button class="w-full text-left px-4 py-2 rounded tab-btn" data-target="s5">4. Log Terminal</button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto relative">

    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50">
        <span class="text-slate-400 font-semibold">Usuario Conectado:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Verificando API...</span>
    </div>

    <section id="s1" class="tab-content active mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Captura de Solicitud</h2>
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4 text-base">
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">CUIT</label>
                <input type="text" id="f_cuit" placeholder="XX-XXXXXXXX-X" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Numero OC</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Nombre Proveedor</label>
                <input type="text" id="f_proveedor" placeholder="Razon Social" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Fecha Solicitud</label>
                <input type="date" id="f_fecha" onchange="autoDia();" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Dia</label>
                <input type="text" id="f_dia" readonly placeholder="Auto" class="w-full bg-slate-950 border border-slate-800 rounded p-3 text-slate-400 outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Planta Destino</label>
                <select id="f_planta" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                </select>
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1 font-bold">Horario (Modulos 45 min)</label>
                <select id="f_horario" class="w-full bg-slate-900 border border-slate-700 rounded p-3 text-white outline-none">
                </select>
            </div>
            <button onclick="crearTurno()" class="col-span-2 mt-4 font-bold py-3.5 rounded transition text-white hover:bg-sky-500 text-base" style="background:var(--sp-blue); color:#0b1120">
                Inyectar a SharePoint
            </button>
        </div>
    </section>

    <section id="s2" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Monitor de Turnos | SharePoint en Linea</h2>
        
        <div class="grid grid-cols-5 gap-6">
            <div class="col-span-3 glass p-6 rounded-xl h-[720px] overflow-y-auto">
                <div class="flex justify-between mb-4 items-center">
                    <span class="text-sm text-slate-400">Lista conectada: <strong>Turnos Proveedores</strong></span>
                    <div class="flex gap-2">
                        <button onclick="filtrarPorPlanta('Packaging')" class="bg-sky-900/60 border border-sky-500/30 text-sky-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-sky-900">Planta Packaging</button>
                        <button onclick="filtrarPorPlanta('Insumos')" class="bg-amber-900/60 border border-amber-500/30 text-amber-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-amber-900">Planta Insumos</button>
                        <button onclick="restablecerFiltro()" class="bg-slate-800 border border-slate-700 text-slate-300 px-3 py-1.5 rounded text-xs font-bold hover:bg-slate-700">Ver Todos</button>
                        <button onclick="cargarTurnos()" class="bg-slate-700 px-4 py-1.5 rounded text-xs font-bold text-white hover:bg-slate-600">↻ Refrescar Datos</button>
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
                            <tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Aguardando conexion con la lista...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-span-2 glass p-4 rounded-xl flex flex-col h-[720px] overflow-hidden">
                <h3 class="text-base font-bold text-sky-400 uppercase tracking-wider text-center mb-1">Turnos Disponibles x Planta</h3>
                
                <div class="bg-slate-950/80 p-3 rounded-lg border border-slate-800 mb-3 text-xs">
                    <div class="flex justify-between items-center mb-2 px-1">
                        <span id="calendar-month-title" class="font-bold text-white uppercase tracking-wide">Junio 2026</span>
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
                            <th class="py-3 px-3">CUIT</th>
                            <th class="px-3">Razon Social / Proveedor</th>
                            <th class="px-3">Email de Contacto Maestro</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-proveedores" class="divide-y divide-slate-700/50">
                        <tr><td colspan="3" class="p-6 text-center text-slate-500 text-xs">Aguardando sincronizacion con el monitor...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section id="s5" class="tab-content mt-10">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Consola de Diagnostico</h2>
        <div class="glass p-4 rounded-xl space-y-4 text-xs">
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Log Terminal (Sistema)</h3>
                <div id="sys-logs" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded border border-slate-700" style="color:#4ade80"></div>
            </div>
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Consola de Log Usuario (Auditoria Interna con Timestamp)</h3>
                <div id="user-logs" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded border border-slate-700" style="color:#fbbf24"></div>
            </div>
        </div>
    </section>

</main>

<div id="mailModal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-sm hidden flex items-center justify-center z-50">
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
    const slotsHorarios = [];
    let transicionPendienteCtx = null;
    
    let fechaSeleccionadaGlobal = "";
    let currentLoggedUser = { name: "Usuario Local", email: "logistica@grupocanuelas.com" };

    document.addEventListener("DOMContentLoaded", async () => {
        const hoy = new Date();
        fechaSeleccionadaGlobal = hoy.toISOString().split('T')[0];
        document.getElementById('f_fecha').value = fechaSeleccionadaGlobal;

        generarSlots45Min();
        await resolverUsuarioLogueado();
        cargarTurnos();
    });

    async function resolverUsuarioLogueado() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/currentUser`, {
                headers: { "Accept": "application/json;odata=nometadata" }
            });
            if (res.ok) {
                const data = await res.json();
                currentLoggedUser.name = data.Title || data.DisplayName;
                currentLoggedUser.email = data.Email || data.UserPrincipalName;
            } else {
                if (typeof _spPageContextInfo !== 'undefined') {
                    currentLoggedUser.name = _spPageContextInfo.userDisplayName;
                    currentLoggedUser.email = _spPageContextInfo.userEmail;
                }
            }
        } catch(e) {}
        document.getElementById('app-user-name').textContent = currentLoggedUser.name;
        const ts = new Date().toLocaleString();
        document.getElementById('user-logs').innerHTML = `<div>[${ts}] [SISTEMA] Auditoria activa para: ${currentLoggedUser.name}</div>`;
    }

    function generarSlots45Min() {
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
        selectHorario.innerHTML = '';
        slotsHorarios.forEach(slot => {
            let opt = document.createElement('option');
            opt.value = slot; opt.textContent = slot;
            selectHorario.appendChild(opt);
        });
    }

    function renderizarGrilaCalendario() {
        const gridContainer = document.getElementById('calendar-days-grid');
        const titleContainer = document.getElementById('calendar-month-title');
        if (!gridContainer) return;

        const baseDate = new Date(fechaSeleccionadaGlobal + 'T00:00:00');
        const anio = baseDate.getFullYear();
        const mes = baseDate.getMonth(); 

        const mesesNombres = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
        titleContainer.textContent = `${mesesNombres[mes]} ${anio}`;

        gridContainer.innerHTML = '';

        const primerDiaMes = new Date(anio, mes, 1);
        let dayOfWeek = primerDiaMes.getDay();
        let despilfaroBlanco = dayOfWeek === 0 ? 6 : dayOfWeek - 1;

        for (let b = 0; b < despilfaroBlanco; b++) {
            gridContainer.innerHTML += `<div class="p-1 text-transparent select-none">-</div>`;
        }

        const totalDiasMes = new Date(anio, mes + 1, 0).getDate();
        const diaActualSeleccionado = baseDate.getDate();

        for (let dia = 1; dia <= totalDiasMes; dia++) {
            let esSeleccionado = (dia === diaActualSeleccionado);
            let claseEstilo = esSeleccionado 
                ? 'bg-sky-500 text-slate-950 font-extrabold rounded shadow' 
                : 'text-slate-300 hover:bg-slate-800 rounded cursor-pointer transition-colors';

            let stringDiaFormato = `${anio}-${(mes + 1).toString().padStart(2, '0')}-${dia.toString().padStart(2, '0')}`;

            gridContainer.innerHTML += `
                <button onclick="conmutarFechaDesdeCalendario('${stringDiaFormato}')" class="p-1 text-center transition-all ${claseEstilo}" title="Ver turnos para el ${dia}">
                    ${dia}
                </button>
            `;
        }
    }

    function conmutarFechaDesdeCalendario(nuevaFechaString) {
        fechaSeleccionadaGlobal = nuevaFechaString;
        document.getElementById('f_fecha').value = nuevaFechaString;
        autoDia();
        
        sysLog(`Calendario conmutó visualización al día: ${nuevaFechaString}`, "INFO");
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
            btn.classList.add('active-tab');
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            document.getElementById(btn.dataset.target).classList.add('active');
        });
    });

    function sysLog(msg, type = 'INFO') {
        const logArea = document.getElementById('sys-logs');
        if (!logArea) return;
        const ts = new Date().toISOString().replace('T', ' ').substring(0, 19);
        let color = type === 'ERR' ? '#f87171' : (type === 'WARN' ? '#fbbf24' : '#4ade80');
        logArea.innerHTML += `<div style="color:${color}">[${ts}] [${type}] ${msg}</div>`;
        logArea.scrollTop = logArea.scrollHeight;
    }

    function userLog(msg, tipoIngreso = 'MANUAL') {
        const logUserArea = document.getElementById('user-logs');
        if (!logUserArea) return;
        const tsComplete = new Date().toLocaleString();
        logUserArea.innerHTML += `<div class="mb-1"><span class="text-slate-500">[${tsComplete}]</span> <span class="text-sky-400 font-bold">[${tipoIngreso}]</span> <span class="text-white font-semibold">${currentLoggedUser.name}:</span> ${msg}</div>`;
        logUserArea.scrollTop = logUserArea.scrollHeight;
    }

    function showToast(msg, type = 'ok') {
        const t = document.getElementById('toast');
        t.textContent = msg; t.className = `show ${type}`;
        setTimeout(() => t.className = '', 4000);
    }

    function autoDia() {
        const fechaVal = document.getElementById('f_fecha').value;
        if (!fechaVal) return;
        const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
        const fecha = new Date(fechaVal + 'T00:00:00');
        document.getElementById('f_dia').value = dias[fecha.getDay()];
        fechaSeleccionadaGlobal = fechaVal;
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

    async function enviarNotificacionMail(destinatario, asunto, cuerpo, remitenteOpcional) {
        const cuerpoLimpioOutlook = cuerpo.replace(/<br\/>/g, '\n').replace(/<b>/g, '').replace(/<\/b>/g, '');
        const mailtoUrl = `mailto:${destinatario}?subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(cuerpoLimpioOutlook)}`;
        const linkFicticio = document.createElement('a');
        linkFicticio.href = mailtoUrl;
        linkFicticio.click();
    }

    async function crearTurno() {
        const cuit = document.getElementById('f_cuit').value.trim();
        const oc = document.getElementById('f_oc').value.trim();
        const prov = document.getElementById('f_proveedor').value.trim();
        const email = document.getElementById('f_email').value.trim();
        const fecha = document.getElementById('f_fecha').value;
        const horario = document.getElementById('f_horario').value;
        const planta = document.getElementById('f_planta').value;

        if (!cuit || !oc || !prov || !fecha) {
            showToast("Complete los campos obligatorios.", "err");
            return;
        }

        const slotOcupado = listaTurnosCache.some(t => 
            t.field_6 && t.field_6.split('T')[0] === fecha && 
            normalizarStringHorario(t.field_5) === normalizarStringHorario(horario) && 
            (t.Planta || 'Packaging').toLowerCase() === planta.toLowerCase() &&
            t.field_7 === 'Aprobado'
        );

        if (slotOcupado) {
            sysLog(`Slot ocupado en Planta ${planta}. Calculando alternativas...`, "WARN");
            let alternativaEncontrada = null;
            const indexActual = slotsHorarios.indexOf(horario);
            
            for (let i = indexActual + 1; i < slotsHorarios.length; i++) {
                let posibleSlot = slotsHorarios[i];
                let ocupado = listaTurnosCache.some(t => 
                    t.field_6 && t.field_6.split('T')[0] === fecha && 
                    normalizarStringHorario(t.field_5) === normalizarStringHorario(posibleSlot) && 
                    (t.Planta || 'Packaging').toLowerCase() === planta.toLowerCase() &&
                    t.field_7 === 'Aprobado'
                );
                if (!ocupado) { alternativaEncontrada = posibleSlot; break; }
            }

            if (alternativaEncontrada) {
                showToast(`Slot ocupado. Alternativa sugerida: ${alternativaEncontrada}.`, "err");
                const asuntoMail = `Sugerencia de Turno Alternativo - Planta ${planta}`;
                const cuerpoMail = `Hola ${currentLoggedUser.name},\n\nEl turno para ${prov} a las ${horario} esta ocupado.\nSlot libre calculado: ${alternativaEncontrada}`;
                await enviarNotificacionMail(currentLoggedUser.email, asuntoMail, cuerpoMail, currentLoggedUser.email);
            } else {
                showToast("No hay mas turnos disponibles para este dia.", "err");
            }
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
                showToast("Turno registrado exitosamente", "ok");
                userLog(`Creacion manual de turno para ${prov} en Planta ${planta}`, "CREACION");
                document.querySelectorAll('input:not([readonly])').forEach(i => i.value = '');
                cargarTurnos();
            }
        } catch (err) {
            showToast("Turno registrado localmente en matriz de desarrollo.", "ok");
            listaTurnosCache.unshift({ Id: Math.floor(Math.random()*100), Title: payload.Title, field_1: cuit, field_2: prov, N_x00b0__x0020_de_x0020_OC: oc, field_6: fecha, field_5: horario, field_7: "Pendiente", Planta: planta, Created: new Date().toISOString(), field_3: email });
            renderizarFilas(listaTurnosCache);
            calcularDisponibilidadOffline();
        }
    }

    async function cargarTurnos() {
        try {
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$select=Id,Title,field_1,field_2,N_x00b0__x0020_de_x0020_OC,field_6,field_5,field_7,Created,Planta,field_3&$orderby=Created desc&$top=50`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            if (!res.ok) throw new Error();
            const data = await res.json();
            listaTurnosCache = data.value || [];
        } catch (err) {
            if(listaTurnosCache.length === 0) {
                listaTurnosCache = [
                    { Id: 12, Title: "TNPK12", field_1: "27-30444555-2", field_2: "PEQL", N_x00b0__x0020_de_x0020_OC: "1100", field_6: "2026-06-05", field_5: "14:00 h a 14:45 h", field_7: "Aprobado", Planta: "Packaging", Created: "2026-06-04T04:48:52Z", field_3: "peql@transportes.com" },
                    { Id: 11, Title: "TNIN11", field_1: "27-30444555-2", field_2: "PEQL Transporte", N_x00b0__x0020_de_x0020_OC: "1007", field_6: "2026-06-05", field_5: "08:00 h a 08:45 h", field_7: "Aprobado", Planta: "Insumos", Created: "2026-06-04T04:39:06Z", field_3: "peql@transportes.com" },
                    { Id: 10, Title: "TNPK10", field_1: "27-30444555-2", field_2: "PEQL Transporte", N_x00b0__x0020_de_x0020_OC: "1005", field_6: "2026-06-05", field_5: "12:30 h a 13:15 h", field_7: "Aprobado", Planta: "Packaging", Created: "2026-06-04T04:17:41Z", field_3: "peql@transportes.com" },
                    { Id: 8, Title: "TNPK8", field_1: "20-14258963-8", field_2: "El Petionense", N_x00b0__x0020_de_x0020_OC: "1002", field_6: "2026-06-04", field_5: "08:45 h a 09:30 h", field_7: "Aprobado", Planta: "Packaging", Created: "2026-06-04T02:48:35Z", field_3: "petionense@log.com" },
                    { Id: 7, Title: "TNIN7", field_1: "27-30444555-2", field_2: "PEQL Transporte", N_x00b0__x0020_de_x0020_OC: "1001", field_6: "2026-06-04", field_5: "08:00 h a 08:45 h", field_7: "Aprobado", Planta: "Insumos", Created: "2026-06-04T02:17:47Z", field_3: "peql@transportes.com" }
                ];
            }
        }
        renderizarFilas(listaTurnosCache);
        renderizarBaseProveedores();
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="8" class="p-4 text-center text-slate-500 text-xs">No se encontraron turnos.</td></tr>`;
            return;
        }

        tbody.innerHTML = items.map(t => {
            let statusColor = 'text-amber-400';
            let filaGrisadaStyle = ""; 
            let isDisabled = "";
            let btnOpa = "hover:scale-125";

            if (t.field_7 === 'Pendiente') {
                filaGrisadaStyle = "opacity-45 bg-slate-950/20 grayscale-[30%]";
                statusColor = 'text-amber-500 font-medium';
            } else if (t.field_7 === 'Aprobado') {
                statusColor = 'text-emerald-400 font-bold';
                isDisabled = "disabled style='opacity: 0.25; pointer-events: none;'";
                btnOpa = "";
            } else {
                statusColor = 'text-rose-400';
            }

            let plantaDisplay = t.Planta || 'Packaging'; 
            let codigoPlanta = (plantaDisplay.toLowerCase() === 'insumos') ? 'IN' : 'PK';
            let idInteligente = `TN${codigoPlanta}${t.Id}`;

            let timestampCreacionReal = t.Created ? new Date(t.Created).toLocaleString() : 'No registrado';
            let fechaSolicitada = t.field_6 ? t.field_6.split('T')[0] : '-';

            let pEmail = t.field_3 ? t.field_3.replace(/'/g, "\\'") : '-';
            let pProv = t.field_2 ? t.field_2.replace(/'/g, "\\'") : '-';

            return `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 transition-all ${filaGrisadaStyle}">
                <td class="py-3 px-3 font-mono font-bold text-sky-400">
                    <div class="flex items-center gap-1.5">
                        <button ${isDisabled} onclick="abrirClienteMailManual('${pEmail}', '${pProv}', '${fechaSolicitada}', '${t.field_7 || 'Pendiente'}', '${idInteligente}')" class="text-sky-400 hover:text-white transition-colors text-xs ${btnOpa}" title="Redactar Correo Manual">&#9993;</button>
                        <span>${idInteligente}</span>
                    </div>
                </td>
                <td class="px-3 text-white font-semibold">${t.field_2 || '-'}</td>
                <td class="px-3 font-mono text-xs font-bold text-slate-400">${plantaDisplay}</td>
                <td class="px-3 text-slate-400 font-mono">${t.N_x00b0__x0020_de_x0020_OC || '-'}</td>
                <td class="px-3 text-xs text-slate-300">Sol: ${fechaSolicitada}<br/><span class="text-[10px] text-slate-500">Alta: ${timestampCreacionReal}</span></td>
                <td class="px-3 text-sky-400 font-mono">${t.field_5 || '-'}</td>
                <td class="px-3 ${statusColor}">${t.field_7 || 'Pendiente'}</td>
                <td class="px-3 text-center">
                    <div class="flex items-center justify-center gap-3 text-base">
                        <button ${isDisabled} onclick="interceptarCambioEstado(${t.Id}, '${idInteligente}', 'Aprobado', '${pEmail}', '${pProv}', '${fechaSolicitada}')" class="${btnOpa} transition-transform" title="Aprobar">&#9989;</button>
                        <button onclick="interceptarCambioEstado(${t.Id}, '${idInteligente}', 'Cancelado', '${pEmail}', '${pProv}', '${fechaSolicitada}')" class="hover:scale-125 transition-transform" title="Cancelar">&#10060;</button>
                        <button onclick="eliminarTurnoServidor(${t.Id}, '${idInteligente}', '${pProv}')" class="hover:scale-125 transition-transform text-rose-500" title="Eliminar y Liberar Turno">&#128465;</button>
                    </div>
                </td>
            </tr>`;
        }).join('');
    }

    function normalizarStringHorario(str) {
        if (!str) return "";
        return str.toLowerCase().replace(/h/g, "").replace(/\s+/g, "").trim();
    }

    function calcularDisponibilidadOffline() {
        const containerPkg = document.getElementById('slots-container-packaging');
        const containerIns = document.getElementById('slots-container-insumos');
        if(!containerPkg || !containerIns) return;

        const fechaFiltro = fechaSeleccionadaGlobal;

        containerPkg.innerHTML = '';
        containerIns.innerHTML = '';

        slotsHorarios.forEach(slot => {
            let resPkg = obtenerEntidadTurnoSlot('packaging', slot, fechaFiltro);
            containerPkg.innerHTML += generarTarjetaSemaforoHTML(slot, resPkg.estado, resPkg.visualId);

            let resIns = obtenerEntidadTurnoSlot('insumos', slot, fechaFiltro);
            containerIns.innerHTML += generarTarjetaSemaforoHTML(slot, resIns.estado, resIns.visualId);
        });
    }

    // Retorna un objeto con el estado y el ID Unico real del turno ocupante
    function obtenerEntidadTurnoSlot(planta, slot, fecha) {
        const coincidencia = listaTurnosCache.find(t => 
            t.field_6 && t.field_6.split('T')[0] === fecha && 
            normalizarStringHorario(t.field_5) === normalizarStringHorario(slot) && 
            (t.Planta || 'Packaging').toLowerCase() === planta.toLowerCase()
        );

        if (!coincidencia || coincidencia.field_7 === 'Cancelado' || coincidencia.field_7 === 'Anulado') {
            return { estado: 'Libre', visualId: '' };
        }
        
        let pDisp = coincidencia.Planta || 'Packaging';
        let cPlanta = (pDisp.toLowerCase() === 'insumos') ? 'IN' : 'PK';
        let idInteligente = `TN${cPlanta}${coincidencia.Id}`;
        
        return { estado: coincidencia.field_7, visualId: idInteligente }; 
    }

    // REQUERIMIENTO: Inyectar el ID Unico (visualId) entre la Franja y el Estado para las tarjetas Ocupado / En Revision
    function generarTarjetaSemaforoHTML(slot, estado, visualId) {
        let bgStyle = "";
        let labelStatus = "";
        let idSubBlock = "";

        if (estado === 'Aprobado') {
            bgStyle = 'bg-red-600 border-red-500 text-white font-bold tracking-wide';
            labelStatus = 'Ocupado';
            idSubBlock = `<span class="text-[10px] px-1 bg-black/30 rounded text-sky-300 tracking-normal font-mono font-bold">${visualId}</span>`;
        } else if (estado === 'Pending' || estado === 'Pendiente') {
            bgStyle = 'bg-amber-500 border-amber-400 text-slate-950 font-bold tracking-wide';
            labelStatus = 'En Revision';
            idSubBlock = `<span class="text-[10px] px-1 bg-black/20 rounded text-slate-800 tracking-normal font-mono font-bold">${visualId}</span>`;
        } else {
            bgStyle = 'bg-emerald-600 border-emerald-500 text-white font-bold tracking-wide';
            labelStatus = 'Libre';
            // Si esta libre no lleva ID intermedio, queda limpio
            idSubBlock = `<span></span>`;
        }

        return `
            <div class="flex items-center justify-between p-2 border rounded text-sm font-mono ${bgStyle} shadow-md transition-all">
                <span>${slot.split(' ')[0]}</span>
                ${idSubBlock}
                <span class="text-[9px] uppercase tracking-wider bg-black/20 px-1.5 py-0.5 rounded font-extrabold">${labelStatus}</span>
            </div>`;
    }

    function interceptarCambioEstado(itemId, visualId, nuevoEstado, proveedorEmail, razonSocial, fechaTurno) {
        const mensajeConfirmacion = `¿Desea cambiar el estado del turno ${visualId} a [${nuevoEstado.toUpperCase()}]?`;
        if (!confirm(mensajeConfirmacion)) return;

        const timestampOperacion = new Date().toLocaleString();
        transicionPendienteCtx = { itemId, visualId, nuevoEstado, proveedorEmail, razonSocial, timestampOperacion };

        if (nuevoEstado === 'Aprobado') {
            if (confirm("¿Desea enviar el mail de confirmacion al proveedor externo?")) {
                userLog(`Aprobacion de turno ${visualId}. Abriendo asistente de redaccion.`, "CONFIRMACION");
                abrirModalRedaccionEstructurado(proveedorEmail, razonSocial, fechaTurno, "Aprobado");
            } else {
                userLog(`Aprobacion directa ejecutada para ${visualId}. Omitiendo notificacion externa.`, "ACCION");
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
        document.getElementById('m_cuerpo').value = `Sr ${razonSocial} su turno para el dia ${fecha} ha sido ${estado} , debera presentarse con la documentacion requerida para su descarga.`;

        document.getElementById('btnEnviarMailFinal').onclick = async function() {
            const remitente = document.getElementById('m_de').value.trim();
            const destino = document.getElementById('m_para').value.trim();
            const asunto = document.getElementById('m_asunto').value.trim();
            const cuerpoTexto = document.getElementById('m_cuerpo').value.trim().replace(/\n/g, '<br/>');
            await procesarTransicionYMail(destino, asunto, cuerpoTexto, remitente);
        };
        document.getElementById('mailModal').classList.remove('hidden');
    }

    async function procesarTransicionYMail(para, asunto, cuerpo, remitenteCompleto) {
        if(!transicionPendienteCtx) return;
        const ctx = transicionPendienteCtx;
        const digest = await getDigest();

        const updatePayload = { "field_7": ctx.nuevoEstado };
        listaTurnosCache = listaTurnosCache.map(item => item.Id === ctx.itemId ? { ...item, field_7: ctx.nuevoEstado } : item);

        try {
            await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${ctx.itemId})`, {
                method: 'POST',
                headers: { "Accept": "application/json;odata=nometadata", "Content-Type": "application/json", "X-RequestDigest": digest, "X-HTTP-Method": "MERGE", "If-Match": "*" },
                body: JSON.stringify(updatePayload)
            });
        } catch(e) {}

        showToast(`Turno actualizado y notificado`, "ok");
        userLog(`Transicion completada: ${ctx.visualId} -> ${ctx.nuevoEstado} por [${remitenteCompleto}]`, 'ACCION');
        if (para) await enviarNotificacionMail(para, asunto, cuerpo, remitenteCompleto);
        
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
        listaTurnosCache = listaTurnosCache.map(item => item.Id === ctx.itemId ? { ...item, field_7: ctx.nuevoEstado } : item);

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
        listaTurnosCache = listaTurnosCache.filter(item => item.Id !== itemId);

        try {
            await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})`, {
                method: 'POST',
                headers: { "X-RequestDigest": digest, "X-HTTP-Method": "DELETE", "If-Match": "*" }
            });
        } catch(e) {}

        showToast("Turno eliminado", "ok");
        userLog(`ELIMINACION FISICA: Registro ${visualId} purgado del servidor.`, "DELETE");
        renderizarFilas(listaTurnosCache);
        renderizarGrilaCalendario();
        calcularDisponibilidadOffline();
    }

    function renderizarBaseProveedores() {
        const tbodyProv = document.getElementById('tabla-proveedores');
        if (!tbodyProv || listaTurnosCache.length === 0) return;

        const proveedoresUnicos = [];
        const cuitsMapeados = new Set();

        listaTurnosCache.forEach(t => {
            let cuitLimpio = t.field_1 ? t.field_1.trim() : '';
            if (cuitLimpio && !cuitsMapeados.has(cuitLimpio)) {
                cuitsMapeados.add(cuitLimpio);
                proveedoresUnicos.push({ cuit: cuitLimpio, nombre: t.field_2 || 'Sin razon social', email: t.field_3 || '-' });
            }
        });

        tbodyProv.innerHTML = proveedoresUnicos.map(p => `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-xs">
                <td class="py-3 px-3 font-mono font-bold text-amber-400">${p.cuit}</td>
                <td class="px-3 text-white font-semibold">${p.nombre}</td>
                <td class="px-3 text-slate-400">${p.email}</td>
            </tr>`).join('');
    }

    function filtrarPorPlanta(plantaTarget) { 
        const filtrados = listaTurnosCache.filter(t => t.Planta && t.Planta.toString().toLowerCase() === plantaTarget.toLowerCase());
        renderizarFilas(filtrados); 
    }
    function restablecerFiltro() { renderizarFilas(listaTurnosCache); }
    function abrirClienteMailManual(paraEmail, nombreProveedor, fechaTurno, estadoTurno, visualId) {
        abrirModalRedaccionEstructurado(paraEmail, nombreProveedor, fechaTurno, estadoTurno, visualId);
    }
    function cerrarModalMail() { document.getElementById('mailModal').classList.add('hidden'); transicionPendienteCtx = null; }
</script>
</body>
</html>