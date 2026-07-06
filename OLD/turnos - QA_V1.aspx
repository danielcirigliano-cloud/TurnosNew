<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consola Maestra | Logistics AutoTurnos M365</title>
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
        body { font-family: 'Syne', sans-serif; background-color: var(--sp-bg); color: #e2e8f0; margin: 0; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .glass { background: var(--sp-panel); border: 1px solid var(--sp-border); backdrop-filter: blur(12px); }
        .tab-content { display: none; }
        .tab-content.active { display: block; animation: fadeIn 0.25s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: none; } }
        
        .tab-btn { color: #94a3b8; transition: background .15s, color .15s; }
        .tab-btn:hover { background: #1e293b; color: #fff; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; }

        /* Toast */
        #toast { position: fixed; bottom: 1.5rem; right: 1.5rem; padding: .6rem 1.2rem; border-radius: 8px; font-size: .8rem; font-weight: 600; opacity: 0; transition: opacity .3s; z-index: 9999; pointer-events: none; }
        #toast.show { opacity: 1; }
        #toast.ok   { background:#166534; border:1px solid #4ade80; color:#4ade80; }
        #toast.err  { background:#7f1d1d; border:1px solid #f87171; color:#f87171; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

<aside class="w-64 glass flex flex-col p-4 border-r h-full z-10" style="border-color: var(--sp-border)">
    <h1 class="text-xl font-bold text-white mb-1">Auto<span style="color:var(--sp-blue)">Turnos</span> Molca</h1>
    <div class="mb-5 text-xs inline-flex items-center gap-2 p-1.5 rounded-full" style="background:rgba(0,0,0,.4); border:1px solid #334155;">
        <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
        <span class="font-bold text-emerald-400">Online API REST</span>
    </div>

    <nav class="space-y-1 flex-1">
        <button class="w-full text-left px-4 py-2 rounded text-sm tab-btn active-tab" data-target="s1">1. Nueva Solicitud</button>
        <button class="w-full text-left px-4 py-2 rounded text-sm tab-btn" data-target="s2" onclick="cargarTurnos()">2. Turnos del Dia</button>
        <button class="w-full text-left px-4 py-2 rounded text-sm tab-btn" data-target="s5">3. Log Terminal</button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto">

    <section id="s1" class="tab-content active">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Ingreso de Solicitud Turno (Manual)</h2>
        <div class="glass p-6 rounded-xl max-w-4xl grid grid-cols-2 gap-4">
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1">CUIT</label>
                <input type="text" id="f_cuit" placeholder="XX-XXXXXXXX-X" class="w-full bg-slate-900 border border-slate-700 rounded p-2.5 text-sm text-white outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1">Numero OC</label>
                <input type="text" id="f_oc" placeholder="Ej: 698765" class="w-full bg-slate-900 border border-slate-700 rounded p-2.5 text-sm text-white outline-none">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1">Nombre Proveedor</label>
                <input type="text" id="f_proveedor" placeholder="Razon Social" class="w-full bg-slate-900 border border-slate-700 rounded p-2.5 text-sm text-white outline-none">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1">Email de Contacto</label>
                <input type="email" id="f_email" placeholder="correo@proveedor.com" class="w-full bg-slate-900 border border-slate-700 rounded p-2.5 text-sm text-white outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1">Fecha Solicitud</label>
                <input type="date" id="f_fecha" onchange="autoDia()" class="w-full bg-slate-900 border border-slate-700 rounded p-2.5 text-sm text-white outline-none">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 mb-1">Dia</label>
                <input type="text" id="f_dia" readonly placeholder="Auto" class="w-full bg-slate-950 border border-slate-800 rounded p-2.5 text-sm text-slate-400 outline-none">
            </div>
            <div class="col-span-2">
                <label class="block text-xs uppercase text-slate-400 mb-1">Horario</label>
                <select id="f_horario" class="w-full bg-slate-900 border border-slate-700 rounded p-2.5 text-sm text-white outline-none">
                    <option>08:00 a 09:00</option>
                    <option>09:00 a 10:00</option>
                    <option>10:00 a 11:00</option>
                    <option>11:00 a 12:00</option>
                    <option>13:00 a 14:00</option>
                    <option>14:00 a 15:00</option>
					<option>15:00 a 16:00</option>
                </select>
            </div>
            <button onclick="crearTurno()" class="col-span-2 mt-4 font-bold py-3 rounded transition text-white hover:bg-sky-500" style="background:var(--sp-blue); color:#0b1120">
                Inyectar a SharePoint | Gestion de turnos
            </button>
        </div>
    </section>

    <section id="s2" class="tab-content">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Monitor de Turnos | SharePoint en Linea</h2>
        <div class="glass p-6 rounded-xl">
            <div class="flex justify-between mb-4 items-center">
                <span class="text-xs text-slate-400">Lista conectada: <strong>Turnos Proveedores</strong></span>
                <div class="flex gap-2">
                    <button onclick="filtrarPorPlanta('Pack')" class="bg-sky-900/60 border border-sky-500/30 text-sky-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-sky-900">Planta Pack</button>
                    <button onclick="filtrarPorPlanta('Insumos')" class="bg-amber-900/60 border border-amber-500/30 text-amber-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-amber-900">Planta Insumos</button>
                    <button onclick="restablecerFiltro()" class="bg-slate-800 border border-slate-700 text-slate-300 px-3 py-1.5 rounded text-xs font-bold hover:bg-slate-700">Ver Todos</button>
                    <button onclick="cargarTurnos()" class="bg-slate-700 px-4 py-1.5 rounded text-xs font-bold text-white hover:bg-slate-600">↻ Refrescar Datos</button>
                </div>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-xs uppercase text-slate-400">
                        <tr>
                            <th class="py-3 px-3">ID Unico</th>
                            <th class="px-3">Proveedor</th>
                            <th class="px-3">Num_OC</th>
                            <th class="px-3">Fecha</th>
                            <th class="px-3">Horario</th>
                            <th class="px-3">Estado</th>
                            <th class="px-3 text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody id="tabla-turnos" class="divide-y divide-slate-700/50">
                        <tr><td colspan="7" class="p-6 text-center text-slate-500 text-xs">Aguardando conexion con la lista...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section id="s5" class="tab-content">
        <h2 class="text-2xl font-bold mb-4" style="color:var(--sp-blue)">Consola de Diagnostico</h2>
        <div class="glass p-4 rounded-xl space-y-4">
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Log Terminal (Sistema)</h3>
                <div id="sys-logs" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded text-xs border border-slate-700" style="color:#4ade80"></div>
            </div>
            <div>
                <h3 class="text-xs font-bold uppercase text-slate-400 mb-1">Consola de Log Usuario (Auditoria Interna)</h3>
                <div id="user-logs" class="mono bg-black/80 h-48 overflow-y-auto p-4 rounded text-xs border border-slate-700" style="color:#fbbf24"></div>
            </div>
        </div>
    </section>

</main>

<div id="toast"></div>

<script>
    // AUTO-DETECCION DE SITIO
    const urlParts = window.location.href.split('/SitePages');
    const relativeSiteUrl = urlParts.length > 1 ? urlParts[0] : '/sites/GestiondeTurnos';
    const targetListName = 'Turnos Proveedores';
    
    // Almacenamiento local de datos para filtrado offline
    let listaTurnosCache = [];

    // Manejo de Pestanas
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
            btn.classList.add('active-tab');
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            document.getElementById(btn.dataset.target).classList.add('active');
        });
    });

    // Loggers
    function sysLog(msg, type = 'INFO') {
        const ts = new Date().toISOString().replace('T', ' ').substring(0, 19);
        const logArea = document.getElementById('sys-logs');
        let color = type === 'ERR' ? '#f87171' : (type === 'WARN' ? '#fbbf24' : '#4ade80');
        logArea.innerHTML += `<div style="color:${color}">[${ts}] [${type}] ${msg}</div>`;
        logArea.scrollTop = logArea.scrollHeight;
    }

    function userLog(msg, tipoIngreso = 'MANUAL') {
        const ts = new Date().toISOString().replace('T', ' ').substring(0, 19);
        const logUserArea = document.getElementById('user-logs');
        const usuarioActual = typeof _spPageContextInfo !== 'undefined' ? _spPageContextInfo.userDisplayName : 'Usuario Local Interno';
        logUserArea.innerHTML += `<div class="mb-1"><span class="text-slate-500">[${ts}]</span> <span class="text-sky-400 font-bold">[${tipoIngreso}]</span> <span class="text-white font-semibold">${usuarioActual}:</span> ${msg}</div>`;
        logUserArea.scrollTop = logUserArea.scrollHeight;
    }

    function showToast(msg, type = 'ok') {
        const t = document.getElementById('toast');
        t.textContent = msg; t.className = `show ${type}`;
        setTimeout(() => t.className = '', 3000);
    }

    // Calcula el Dia Automaticamente
    function autoDia() {
        const fechaVal = document.getElementById('f_fecha').value;
        if (!fechaVal) return;
        const dias = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'];
        const fecha = new Date(fechaVal + 'T00:00:00');
        document.getElementById('f_dia').value = dias[fecha.getDay()];
    }

    // ADQUISICION DE TOKEN M365 (REQUEST DIGEST)
    async function getDigest() {
        try {
            const res = await fetch(`${relativeSiteUrl}/_api/contextinfo`, {
                method: 'POST',
                headers: { "Accept": "application/json;odata=verbose" }
            });
            const data = await res.json();
            return data.d.GetContextWebInformation.FormDigestValue;
        } catch (e) {
            sysLog("Error obteniendo token de seguridad.", "ERR");
            return null;
        }
    }

    // OPERACION POST (CREAR TURNO)
    async function crearTurno() {
        const cuit = document.getElementById('f_cuit').value.trim();
        const oc = document.getElementById('f_oc').value.trim();
        const prov = document.getElementById('f_proveedor').value.trim();
        const email = document.getElementById('f_email').value.trim();
        const fecha = document.getElementById('f_fecha').value;
        const dia = document.getElementById('f_dia').value;
        const horario = document.getElementById('f_horario').value;

        if (!cuit || !oc || !prov || !fecha) {
            showToast("Complete los campos obligatorios.", "err");
            return;
        }

        const digest = await getDigest();
        if (!digest) return;

        const payload = {
            "Title": "TN-" + Date.now().toString().slice(-6),
            "field_1": cuit,                           
            "N_x00b0__x0020_de_x0020_OC": oc,          
            "field_2": prov,                           
            "field_3": email,                          
            "field_6": fecha + "T00:00:00Z",       
            "field_5": horario,                        
            "field_7": "Pendiente"                     
        };

        sysLog(`Intentando inyectar turno para ${prov}...`, "INFO");

        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items`, {
                method: 'POST',
                headers: {
                    "Accept": "application/json;odata=nometadata",
                    "Content-Type": "application/json",
                    "X-RequestDigest": digest
                },
                body: JSON.stringify(payload)
            });

            if (res.ok) {
                showToast("Turno registrado exitosamente", "ok");
                sysLog(`Turno guardado correctamente en SharePoint.`, "INFO");
                
                // Registro específico en la consola de Log Usuario por ingreso por excepción manual
                userLog(`Ingreso manual por excepcion de turno para el proveedor ${prov} (OC: ${oc})`);
                
                // Limpiar form
                document.querySelectorAll('input:not([readonly])').forEach(i => i.value = '');
                cargarTurnos();
            } else {
                const errorData = await res.text();
                throw new Error(errorData);
            }
        } catch (err) {
            showToast("Falla de escritura en servidor.", "err");
            console.error("Detalle del error:", err.message);
            sysLog(`RECHAZO DEL SERVIDOR: ${err.message}`, "ERR");
        }
    }

    // OPERACION GET (LEER TURNOS)
    async function cargarTurnos() {
        sysLog(`Descargando registros desde la lista: ${targetListName}...`, "INFO");
        const tbody = document.getElementById('tabla-turnos');
        tbody.innerHTML = `<tr><td colspan="7" class="p-4 text-center text-xs">Cargando datos desde M365... <div class="spin ml-2"></div></td></tr>`;
        
        try {
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$select=Id,Title,field_1,field_2,N_x00b0__x0020_de_x0020_OC,field_6,field_5,field_7,Planta&$orderby=Created desc&$top=50`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            
            const data = await res.json();
            listaTurnosCache = data.value || [];
            
            renderizarFilas(listaTurnosCache);
            sysLog(`Sincronizacion exitosa. ${listaTurnosCache.length} filas renderizadas.`, "INFO");
        } catch (err) {
            tbody.innerHTML = `<tr><td colspan="7" class="p-4 text-center text-red-400 text-xs font-bold">Error conectando con la API de SharePoint. Ver Log.</td></tr>`;
            sysLog(`Error de lectura GET: ${err.message}`, "ERR");
        }
    }

    // RENDERIZAR DATOS EN LA TABLA CON ICONOS DE ACCIONES
    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(items.length === 0) {
            tbody.innerHTML = `<tr><td colspan="7" class="p-4 text-center text-slate-500 text-xs">No se encontraron turnos con los filtros aplicados.</td></tr>`;
            return;
        }

        tbody.innerHTML = items.map(t => {
            let statusColor = 'text-amber-400';
            if (t.field_7 === 'Aprobado') statusColor = 'text-emerald-400';
            if (t.field_7 === 'Cancelado' || t.field_7 === 'Anulado') statusColor = 'text-rose-400';

            return `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30">
                <td class="py-3 px-3 font-bold text-slate-400">${t.Title || '-'}</td>
                <td class="px-3 text-white">${t.field_2 || '-'} <span class="text-[10px] text-slate-500 font-mono">(${t.Planta || 'No asignada'})</span></td>
                <td class="px-3 text-slate-400">${t.N_x00b0__x0020_de_x0020_OC || '-'}</td>
                <td class="px-3">${t.field_6 ? t.field_6.split('T')[0] : '-'}</td>
                <td class="px-3 text-sky-400">${t.field_5 || '-'}</td>
                <td class="px-3 font-bold ${statusColor}">${t.field_7 || 'Pendiente'}</td>
                <td class="px-3 text-center">
                    <div class="flex items-center justify-center gap-3">
                        <button onclick="cambiarEstadoTurno(${t.Id}, '${t.Title}', 'Aprobado')" class="hover:scale-125 transition-transform" title="Aprobar Turno">✅</button>
                        <button onclick="cambiarEstadoTurno(${t.Id}, '${t.Title}', 'Cancelado')" class="hover:scale-125 transition-transform" title="Cancelar Turno">❌</button>
                        <button onclick="cambiarEstadoTurno(${t.Id}, '${t.Title}', 'Anulado')" class="hover:scale-125 transition-transform" title="Anular Turno">🚫</button>
                    </div>
                </td>
            </tr>`;
        }).join('');
    }

    // FILTRADO LOGICO POR PLANTA (PACK / INSUMOS)
    function filtrarPorPlanta(plantaTarget) {
        sysLog(`Filtrando vista para Planta: ${plantaTarget}`, "INFO");
        const filtrados = listaTurnosCache.filter(t => t.Planta && t.Planta.toString().toLowerCase() === plantaTarget.toLowerCase());
        renderizarFilas(filtrados);
    }

    function restablecerFiltro() {
        sysLog("Restableciendo filtros de vista de planta.", "INFO");
        renderizarFilas(listaTurnosCache);
    }

    // OPERACION PATCH/MERGE (CAMBIAR ESTADO DESDE ICONOS)
    async function cambiarEstadoTurno(itemId, itemTitle, nuevoEstado) {
        const digest = await getDigest();
        if (!digest) return;

        sysLog(`Solicitando cambio de estado para ID ${itemId} a [${nuevoEstado}]...`, "INFO");
        
        const updatePayload = {
            "field_7": nuevoEstado
        };

        try {
            const res = await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items(${itemId})`, {
                method: 'POST',
                headers: {
                    "Accept": "application/json;odata=nometadata",
                    "Content-Type": "application/json",
                    "X-RequestDigest": digest,
                    "X-HTTP-Method": "MERGE",
                    "If-Match": "*"
                },
                body: JSON.stringify(updatePayload)
            });

            if (res.ok) {
                showToast(`Turno ${nuevoEstado.toLowerCase()} correctamente`, "ok");
                sysLog(`Cambio de estado exitoso en M365 para el elemento ${itemId}.`, "INFO");
                
                // Registro de auditoria obligatorio en la Consola Log de Usuario
                userLog(`Transicion de estado en fila [${itemTitle}] -> Cambio a [${nuevoEstado}] realizado con exito`, 'ACCION');
                
                cargarTurnos();
            } else {
                throw new Error(`Error del servidor al actualizar estado: ${res.status}`);
            }
        } catch (err) {
            showToast("No se pudo actualizar el estado.", "err");
            sysLog(`Error al cambiar estado: ${err.message}`, "ERR");
        }
    }
</script>
</body>
</html>