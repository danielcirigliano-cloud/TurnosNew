<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Consola Maestra | Logistica de Turnos Molca Spegazzini</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .tab-btn { color: #94a3b8; padding: 10px; cursor: pointer; }
        .tab-btn.active-tab { background: #0369a1; color: #fff; }
        .glass { background: rgba(15, 23, 42, 0.92); border: 1px solid rgba(56, 189, 248, 0.15); }
    </style>
</head>
<body class="flex h-screen overflow-hidden bg-[#0b1120] text-slate-200">

<aside class="w-64 glass flex flex-col p-4 border-r border-slate-700">
    <h1 class="text-white font-bold mb-5">Molca Spegazzini</h1>
    <nav class="space-y-2">
        <button class="w-full text-left rounded tab-btn active-tab" data-target="s2">1. Turnos del Dia</button>
        <button class="w-full text-left rounded tab-btn" data-target="s1">2. Captura y Consulta</button>
        <button class="w-full text-left rounded tab-btn" data-target="s6">3. Proveedores</button>
    </nav>
</aside>

<main class="flex-1 p-8 overflow-y-auto">
    <section id="s1" class="tab-content">
        <h2 class="text-xl font-bold mb-4 text-sky-400">Captura de Solicitud</h2>
        <div class="glass p-6 rounded-xl grid grid-cols-2 gap-4">
            <input type="hidden" id="f_item_id">
            <input type="text" id="f_cuit" placeholder="CUIT" class="bg-slate-900 border p-2 w-full text-white">
            <input type="text" id="f_oc" placeholder="OC" class="bg-slate-900 border p-2 w-full text-white">
            <input type="text" id="f_proveedor" placeholder="Proveedor" class="col-span-2 bg-slate-900 border p-2 w-full text-white">
            <input type="email" id="f_email" placeholder="Email" class="col-span-2 bg-slate-900 border p-2 w-full text-white">
            <input type="date" id="f_fecha" class="bg-slate-900 border p-2 w-full text-white">
            <select id="f_planta" class="bg-slate-900 border p-2 w-full text-white"><option value="Packaging">Packaging</option><option value="Insumos">Insumos</option></select>
            <select id="f_horario" class="col-span-2 bg-slate-900 border p-2 w-full text-white"></select>
            <div class="col-span-2 flex gap-2">
                <button id="btn-alta" onclick="crearTurno()" class="bg-sky-600 p-3 text-white font-bold">Registrar Alta</button>
                <button id="btn-modificar" onclick="guardarCambiosTurno()" disabled class="bg-amber-600 p-3 text-white font-bold opacity-50">Guardar Cambios</button>
                <button onclick="limpiarFormularioABM()" class="bg-slate-700 p-3 text-white">Limpiar</button>
            </div>
        </div>
    </section>

    <section id="s2" class="tab-content active">
        <h2 class="text-xl font-bold mb-4 text-sky-400">Monitor de Turnos</h2>
        <div class="glass p-4 rounded-xl overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead><tr class="text-slate-400"><th>ID</th><th>Proveedor</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody id="tabla-turnos"></tbody>
            </table>
        </div>
    </section>
</main>

<script>
    // Variables globales
    const relativeSiteUrl = "/sites/GestiondeTurnos";
    const targetListName = 'Turnos Proveedores';
    let listaTurnosCache = [];

    // --- LÓGICA DE INICIALIZACIÓN ---
    // NO usamos DOMContentLoaded para evitar bloqueos de SharePoint.
    // Ejecutamos directamente al cargar el script.
    
    function inicializarApp() {
        console.log("Iniciando aplicación...");
        generarHorarios();
        inicializarNavegacion();
        cargarTurnos();
    }

    function inicializarNavegacion() {
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
                btn.classList.add('active-tab');
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                document.getElementById(btn.dataset.target).classList.add('active');
            });
        });
    }

    function generarHorarios() {
        const select = document.getElementById('f_horario');
        if(!select) return;
        for(let i=8; i<16; i++) {
            let opt = document.createElement('option');
            opt.value = `${i}:00`; opt.textContent = `${i}:00`;
            select.appendChild(opt);
        }
    }

    async function cargarTurnos() {
        try {
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$top=20`;
            const res = await fetch(endpoint, { headers: { "Accept": "application/json;odata=nometadata" } });
            const data = await res.json();
            listaTurnosCache = data.value || [];
            renderizarFilas(listaTurnosCache);
        } catch (e) {
            console.error("Error cargando turnos", e);
        }
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos');
        if(!tbody) return;
        tbody.innerHTML = items.map(t => `
            <tr class="border-b border-slate-700">
                <td class="p-2">${t.Id}</td>
                <td class="p-2">${t.field_2 || '-'}</td>
                <td class="p-2">${t.field_7 || 'Pendiente'}</td>
                <td class="p-2">
                    <button onclick="consultarTurnoAlFormulario(${t.Id})" class="text-sky-400">👁️</button>
                </td>
            </tr>
        `).join('');
    }

    function consultarTurnoAlFormulario(id) {
        const t = listaTurnosCache.find(x => x.Id == id);
        if(!t) return;
        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('btn-modificar').disabled = false;
        document.getElementById('btn-modificar').classList.remove('opacity-50');
        
        // Cambiar pestaña
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active-tab'));
        document.querySelector('[data-target="s1"]').classList.add('active-tab');
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.getElementById('s1').classList.add('active');
    }

    function limpiarFormularioABM() {
        document.getElementById('f_item_id').value = '';
        document.getElementById('f_proveedor').value = '';
        document.getElementById('btn-modificar').disabled = true;
    }

    // Arranque manual directo
    arrancarConsolaMaestra();

    function arrancarConsolaMaestra() {
        inicializarApp();
    }
</script>
</body>
</html>