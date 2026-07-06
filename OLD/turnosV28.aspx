<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERP Logistica de Turnos | Molca</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        <button class="w-full text-left rounded tab-btn active-tab" data-target="s2" id="btn-tab-monitor">1. Turnos Diarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s1" id="btn-tab-abm">2. ABM de Turnos</button>
        <button class="w-full text-left rounded tab-btn" data-target="s6" onclick="renderizarBaseProveedores()">3. Base Proveedores</button>
        <button class="w-full text-left rounded tab-btn" data-target="s7" onclick="renderizarBaseUsuarios()">4. Base Usuarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s8" onclick="renderizarABMHorarios()">5. Config. Horarios</button>
        <button class="w-full text-left rounded tab-btn" data-target="s9">6. Modulo ETL & Logs</button>
        <button class="w-full text-left rounded tab-btn" data-target="s10" onclick="initDashboard()">7. Dashboard Indicadores</button>
    </nav>
</aside>

<main class="flex-1 p-6 overflow-y-auto relative w-full">
    <div id="header-user-box" class="absolute top-6 right-8 glass px-5 py-2.5 rounded-full flex items-center gap-2 text-sm border border-slate-700 bg-slate-900/50 z-20">
        <span class="text-slate-400 font-semibold">Usuario:</span>
        <span id="app-user-name" class="text-sky-400 font-bold font-mono">Iniciando...</span>
    </div>

    <section id="s2" class="tab-content active mt-8 w-full">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-2xl font-bold text-sky-400">Monitor de Turnos Diarios</h2>
            <div class="flex gap-2">
                <button onclick="abrirAltaTurno()" class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">[+] Alta de Turno</button>
                <button onclick="enviarResumenDiario()" class="bg-indigo-600 hover:bg-indigo-500 text-white px-4 py-2 text-xs font-bold rounded shadow transition">[Mail] Enviar Resumen</button>
            </div>
        </div>
        
        <div class="grid grid-cols-12 gap-4 h-[calc(100vh-130px)]">

            <!-- COLUMNA IZQUIERDA: Resumen de Operacion Diaria (vertical) -->
            <!-- Separada del menu de navegacion por un borde propio, independiente del <aside> -->
            <div class="col-span-2 glass p-4 rounded-xl flex flex-col h-full overflow-hidden border-l-2 border-l-slate-600">
                <div class="flex flex-col items-center mb-3 border-b border-slate-700 pb-2 shrink-0">
                    <h3 class="text-xs font-bold text-emerald-400 uppercase tracking-wider text-center">Resumen Operacion Diaria</h3>
                    <span id="resumen-fecha-label" class="text-[11px] font-mono text-slate-400 mt-1">Calculando...</span>
                </div>
                <div id="resumen-contadores-vertical" class="flex-1 overflow-y-auto space-y-3 pr-1"></div>
            </div>

            <div class="col-span-7 glass p-4 rounded-xl flex flex-col h-full">
                <div class="flex gap-2 mb-4 items-end bg-slate-900/50 p-3 rounded-lg border border-slate-700 shrink-0 flex-wrap">
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Filtro Planta Fisica</label>
                        <select id="filtro_planta_descarga" onchange="sincronizarFiltrosYMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-36">
                            <option value="TODAS">-- Todas --</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Responsable</label>
                        <select id="filtro_usuario" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-40">
                            <option value="TODOS">-- Todos --</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Estado</label>
                        <select id="filtro_estado" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-36">
                            <option value="TODOS">-- Todos --</option>
                            <option value="Pendiente">Pendientes</option>
                            <option value="Aprobado">Aprobados</option>
                            <option value="Reprogramado">Reprogramados</option>
                            <option value="Cancelado">Cancelados/Rechazados</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Tipo de Turno</label>
                        <select id="filtro_tipo_turno" onchange="aplicarFiltrosMonitor()" class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-32">
                            <option value="TODOS">-- Todos --</option>
                            <option value="Normal">Normal</option>
                            <option value="Sobreturno">Sobreturno</option>
                        </select>
                    </div>
                    <button onclick="restablecerFiltros()" class="bg-slate-700 px-3 py-1.5 text-xs rounded hover:bg-slate-600 transition">Quitar Filtros</button>
                    <button onclick="refrescarDBAbsoluto()" class="ml-auto bg-slate-800 border border-slate-600 px-4 py-1.5 text-xs rounded text-sky-400 hover:bg-slate-700 transition">Refrescar DB</button>
                </div>
                
                <div class="overflow-y-auto overflow-x-auto text-base flex-1 border border-slate-700/50 rounded-lg relative">
                    <table class="w-full text-left text-sm text-slate-300 relative">
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
                            <tr><td colspan="8" class="p-6 text-center text-slate-500 text-xs">Cargando base de datos...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="col-span-3 glass p-4 rounded-xl flex flex-col h-full overflow-hidden">
                <h3 class="text-base font-bold text-sky-400 uppercase tracking-wider text-center mb-3 shrink-0">Disponibilidad Logistica</h3>
                
                <div class="w-full bg-slate-950/80 p-3 rounded border border-slate-800 mb-4 text-sm shadow-inner shrink-0">
                    <div class="flex justify-between items-center mb-2 px-1">
                        <span id="calendar-month-title" class="font-bold text-white uppercase tracking-wide">MES</span>
                        <div class="text-xs text-slate-400 font-semibold font-mono">SELECCION FECHA</div>
                    </div>
                    <div class="grid grid-cols-7 text-center font-bold text-slate-500 uppercase tracking-wider mb-2 text-xs">
                        <span>Lu</span><span>Ma</span><span>Mi</span><span>Ju</span><span>Vi</span><span>Sa</span><span>Do</span>
                    </div>
                    <div id="calendar-days-grid" class="grid grid-cols-7 gap-2 text-center font-mono font-bold text-sm w-full"></div>
                </div>
                
                <div class="flex-1 overflow-y-auto pr-2 relative">
                    <div id="panel-disponibilidad-dinamico" class="space-y-4"></div>
                </div>
            </div>
        </div>
    </section>

    <section id="s1" class="tab-content mt-8 w-full">
        <div class="flex items-center justify-between mb-4">
            <h2 class="text-2xl font-bold text-sky-400">ABM de Turnos</h2>
            <div class="flex gap-2 items-center">
                <div id="form-mode-indicator" class="text-xs uppercase px-3 py-1 bg-emerald-900 text-emerald-300 rounded-full font-bold">Alta de Turno</div>
                <button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 text-white px-4 py-2 text-xs font-bold rounded border border-slate-500 transition">Volver al Monitor</button>
            </div>
        </div>
        
        <div id="abm-mensaje-estado" class="text-sm font-bold px-4 py-3 rounded mb-4 hidden shadow-md"></div>

        <div class="glass p-8 rounded-xl w-full grid grid-cols-2 gap-6">
            <input type="hidden" id="f_item_id">
            <div class="col-span-2 grid grid-cols-3 gap-6 border-b border-slate-700 pb-6 mb-2">
                <div>
                    <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Patente Vehiculo *</label>
                    <input type="text" id="f_patente" placeholder="" class="bg-slate-900 border border-slate-700 p-3 w-full font-mono text-amber-300 uppercase outline-none f-control transition-colors focus:border-sky-500" maxlength="7">
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
                <select id="f_planta_descarga" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-3 w-full text-sky-400 font-bold outline-none f-control transition-colors focus:border-sky-500"></select>
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Zona de Descarga (Area)</label>
                <select id="f_planta" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
                    <option value="Packaging">Packaging</option>
                    <option value="Insumos">Insumos</option>
                    <option value="Materia Prima">Materia Prima</option>
                </select>
            </div>

            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Fecha Solicitud *</label>
                <input type="date" id="f_fecha" onchange="handleHorariosChange()" class="bg-slate-900 border border-slate-700 p-3 w-full text-white outline-none f-control transition-colors focus:border-sky-500">
            </div>
            <div>
                <label class="block text-xs uppercase text-slate-400 font-bold mb-1">Slot Horario Calculado *</label>
                <select id="f_horario" class="bg-slate-900 border border-slate-700 p-3 w-full text-sky-300 font-mono font-bold outline-none f-control transition-colors focus:border-sky-500"></select>
            </div>

            <div class="col-span-2 bg-slate-950 p-4 rounded text-sm border border-slate-800 text-slate-400 flex justify-between items-center mt-4">
                <span>Responsable de Turno: <strong id="f_usuario_gestor" class="text-white">-</strong></span>
                <span>Dia Semana: <strong id="f_dia" class="text-white">-</strong></span>
                <label class="inline-flex items-center gap-2 cursor-pointer select-none">
                    <input type="checkbox" id="f_sobreturno" class="w-4 h-4 rounded bg-slate-900 border-slate-600 text-violet-500 focus:ring-violet-500 f-control">
                    <span class="text-violet-300 font-bold uppercase text-xs">Sobreturno / Excepcion</span>
                </label>
            </div>

            <div class="col-span-2 flex gap-4 mt-2" id="panel-botones-abm"></div>

            <div class="col-span-2 mt-4 border-t border-slate-700 pt-5 flex items-center justify-between" id="panel-tracking">
                <div>
                    <span class="block text-xs uppercase text-slate-400 font-bold mb-2">Registro de Porteria Operativa (Tracking)</span>
                    <div class="flex gap-3">
                        <button id="btn-track-in" onclick="marcarTrackingForm('IN')" class="bg-slate-800 text-emerald-400 border border-slate-700 hover:bg-slate-700 px-5 py-2.5 rounded text-sm font-bold transition">[ In ] Marcar Ingreso</button>
                        <button id="btn-track-out" onclick="marcarTrackingForm('OUT')" class="bg-slate-800 text-rose-400 border border-slate-700 hover:bg-slate-700 px-5 py-2.5 rounded text-sm font-bold transition">[ Out ] Marcar Salida</button>
                    </div>
                </div>
                <div class="text-right">
                    <span class="block text-xs uppercase text-slate-400 font-bold mb-1">Estado de Transaccion</span>
                    <span id="f_estado_actual" class="text-2xl font-bold text-slate-500 uppercase tracking-widest">NUEVO</span>
                </div>
            </div>
        </div>
    </section>

    <section id="s6" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Base Maestro de Proveedores</h2>
        
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="p_index">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Usuario Creador</label>
                    <input type="text" id="p_usuario" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Responsable</label>
                    <input type="text" id="p_resp" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Mail Responsable</label>
                    <input type="text" id="p_mail" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                </div>
                
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Insumo</label>
                    <input type="text" id="p_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Num Proveedor (ID)</label>
                    <input type="text" id="p_cuit" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre Proveedor</label>
                    <input type="text" id="p_razon" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                </div>
                <div class="col-span-1">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado</label>
                    <select id="p_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">No Habilitado</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3">
                <button onclick="limpiarFormularioProveedor()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo Proveedor</button>
                <button onclick="guardarEdicionProveedor()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar y Sincronizar Proveedor</button>
            </div>
        </div>

        <div class="glass p-6 rounded-xl text-base w-full mt-4">
            <div class="overflow-x-auto h-[500px]">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0 shadow">
                        <tr><th class="py-3 px-3">Usuario</th><th class="px-3">Responsable</th><th class="px-3">Num Prov.</th><th class="px-3">Razon Social</th><th class="px-3">Tipo Insumo</th><th class="px-3">Estado</th><th class="px-3 text-center">Accion</th></tr>
                    </thead>
                    <tbody id="tabla-proveedores" class="divide-y divide-slate-700/50">
                        <tr><td colspan="7" class="p-6 text-center text-slate-500 text-sm">Sin padron de proveedores cargado.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </section>

    <section id="s7" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Gestion de Usuarios (Mailing y Responsables)</h2>
        
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
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">No Habilitado</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3">
                <button onclick="limpiarFormularioUsuario()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">[+] Nuevo Usuario</button>
                <button onclick="guardarEdicionUsuario()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar y Sincronizar Usuario</button>
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

    <section id="s8" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Configuracion de Horarios por Planta</h2>
        <p class="text-sm text-slate-400 mb-6">Ajuste las ventanas operativas y duracion de turnos de manera general.</p>
        <div class="glass p-6 rounded-xl text-base w-full">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="bg-slate-800 text-sm uppercase text-slate-400 font-bold border-b border-slate-700">
                        <tr><th class="py-4 px-4">Planta Fisica</th><th class="px-4">Lunes a Viernes</th><th class="px-4">Sabados</th><th class="px-4">Minutos x Turno</th><th class="px-4 text-center">Estatus</th></tr>
                    </thead>
                    <tbody id="tabla-config-horarios" class="divide-y divide-slate-700/50"></tbody>
                </table>
            </div>
            <div class="mt-6 flex gap-2">
                <button onclick="guardarConfiguracionHorarios()" class="bg-emerald-600 hover:bg-emerald-500 px-6 py-3 font-bold rounded shadow transition text-white">Guardar Configuracion Central</button>
            </div>
        </div>
    </section>

    <section id="s9" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Modulo ETL y Auditoria</h2>
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
                <div class="flex-1 bg-black/80 rounded border border-slate-700 p-4 font-mono text-xs overflow-y-auto" id="etl-log-console" style="color:#4ade80"><div>> Inicializando motor ETL Audit v6.2...</div></div>
            </div>
        </div>
    </section>

    <section id="s10" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Dashboard de Indicadores</h2>
        
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
    let targetListName = 'Turnos Proveedores'; 
    
    async function fetchSharePoint(query, options = {}) {
        if (!options.headers) options.headers = { "Accept": "application/json;odata=nometadata" };
        let url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/${query}`;
        
        let res = await fetch(url, options);
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

    async function sincronizarListFormSilencioso() {
        try {
            fetch("https://grupocanuelas.sharepoint.com/:l:/r/sites/GestiondeTurnos/Lists/Turnos%20Proveedores_1?e=z4KwLY", { mode: 'no-cors' });
        } catch(e) {}
    }

    function ordenarEstructuralmenteBase(turnos) {
        // Orden de Prioridad Operativa
        const prioridadEst = { 'pendiente': 1, 'aprobado': 2, 'reprogramado': 3, 'cancelado': 4, 'rechazado': 4 };
        
        return turnos.sort((a, b) => {
            // 1. Por Planta Fisica (Agrupacion logica)
            let plantaA = (a.PlantaDescarga || '').toLowerCase();
            let plantaB = (b.PlantaDescarga || '').toLowerCase();
            if (plantaA < plantaB) return -1;
            if (plantaA > plantaB) return 1;

            // 2. Por Fecha de Solicitud
            let fechaA = a.field_6 || '';
            let fechaB = b.field_6 || '';
            if (fechaA < fechaB) return -1;
            if (fechaA > fechaB) return 1;

            // 3. Por Estado (Prioridad de Accion)
            let estA = String(a.field_7 || 'pendiente').toLowerCase().trim();
            let estB = String(b.field_7 || 'pendiente').toLowerCase().trim();
            let pA = prioridadEst[estA] || 99;
            let pB = prioridadEst[estB] || 99;
            if (pA < pB) return -1;
            if (pA > pB) return 1;

            return 0; // Iguales
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
                delete payload.Patente; delete payload.HoraIngresoReal; delete payload.HoraSalidaReal;
                options.body = JSON.stringify(payload);
                res = await fetchSharePoint(query, options);
            }
            if (!res.ok && res.status !== 204 && res.status !== 201) throw new Error("Falla API " + res.status);
            
            logETLStep(3, true); showToast(msg, "ok");
            generarLogArchivoSP("Transaccion_Turno", msg); 
            sincronizarListFormSilencioso();
            if(!skipRefresh) await cargarTurnos(); 
        } catch(e) {
            logLog(`[ERROR ESCRITURA SP]: ${e.message}`);
            showToast("Simulacion Local", "err");
            if(itemId) { let obj = listaTurnosCache.find(x=>x.Id==itemId); if(obj) Object.assign(obj, payload); }
            else listaTurnosCache.unshift({...payload, Id: Math.floor(Math.random()*1000)});
            
            ordenarEstructuralmenteBase(listaTurnosCache); 
            aplicarFiltrosMonitor(); calcularDisponibilidadOffline(); generarResumenDiario();
        }
    }

    async function actualizarCSVSharePoint(tipo) {
        logETLStep(3, false);
        try {
            const digest = await getDigest();
            let fileName = tipo === 'prov' ? 'proveedores.csv' : 'Usuarios.csv';
            let folderName = 'Documentos compartidos';
            
            let csvContent = "\uFEFF"; 
            if (tipo === 'usu') {
                csvContent += "ID;Nombre y apellido;Email;Planta;Estado\n";
                listaUsuariosCache.forEach(u => { csvContent += `${u.id};${u.nombre};${u.email};${u.planta};${u.estado}\n`; });
            } else {
                csvContent += "Usuario;Responsable;Mail Responsable;Tipo Insumo;Num_Proveedor;Nombre proveedor;Estado\n";
                listaProveedoresCache.forEach(p => { csvContent += `${p.usuario};${p.responsable};${p.mail};${p.tipo};${p.id};${p.nombre};${p.estado}\n`; });
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
        } catch (err) { logLog(`[ERROR ETL CSV]: ${err.message}`); }
    }

    // =========================================================================
    // ENRUTADOR
    // =========================================================================
    function setupRuteo() {
        try {
            const btns = document.querySelectorAll('.tab-btn');
            const contents = document.querySelectorAll('.tab-content');
            btns.forEach(btn => {
                btn.addEventListener('click', () => {
                    btns.forEach(b => b.classList.remove('active-tab', 'bg-[#0369a1]', 'text-white'));
                    btn.classList.add('active-tab', 'bg-[#0369a1]', 'text-white');
                    contents.forEach(c => { c.classList.remove('active', 'block'); c.style.display = 'none'; });
                    const targetEl = document.getElementById(btn.dataset.target);
                    if(targetEl) { targetEl.classList.add('active'); targetEl.style.display = 'block'; }
                });
            });
        } catch(e) {}
    }
    setupRuteo();

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

    // --- ARRANQUE Y AUTO-SINCRONIZACION ---
    async function initApp() {
        try {
            logLog("=====================================");
            logLog("Inicializando Core ERP Logistico...");
            const hoy = new Date();
            fechaSeleccionadaGlobal = hoy.getFullYear() + "-" + String(hoy.getMonth() + 1).padStart(2, '0') + "-" + String(hoy.getDate()).padStart(2, '0');
            
            cargarSelectPlantasFisicas();
            renderizarABMHorarios();
            renderizarGrilaCalendario();
            
            await testConexion();
            
            logLog("[ETL] Disparando hilos asincronos de Sincronizacion de Maestros...");
            Promise.all([
                importarCSVSharePoint('prov', true),
                importarCSVSharePoint('usu', true)
            ]).then(() => {
                logLog("[ETL] Maestros sincronizados. Disparando carga de Turnos...");
                refrescarDBAbsoluto(); 
            });

        } catch (err) { logLog(`[FALLA CRITICA INIT]: ${err.message}`); }
    }

    // --- IMPORTACION DIRECTA DE SHAREPOINT ---
    async function importarCSVSharePoint(tipo, isSilent = false) {
        let fileName = tipo === 'prov' ? 'proveedores.csv' : 'Usuarios.csv';
        let urlDescarga = `${relativeSiteUrl}/Documentos compartidos/${fileName}`;
        
        try {
            let res = await fetch(urlDescarga);
            if (!res.ok) {
                urlDescarga = `${relativeSiteUrl}/Shared Documents/${fileName}`;
                res = await fetch(urlDescarga);
            }
            if (!res.ok) throw new Error(`Archivo no encontrado: ${fileName}`);
            
            const text = await res.text();
            if(tipo === 'prov') parsearCSVProveedores(text);
            else parsearCSVUsuarios(text);
            
        } catch (err) {
            logLog(`[ERROR CSV SP]: ${err.message}`);
        }
    }

    // --- REGLAS HORARIAS Y SELECTORES ---
    function cargarSelectPlantasFisicas() {
        const selects = [document.getElementById('f_planta_descarga'), document.getElementById('filtro_planta_descarga'), document.getElementById('u_planta'), document.getElementById('dash_planta')];
        selects.forEach(s => {
            if(!s) return;
            let h = s.id.includes('filtro') || s.id.includes('dash') ? '<option value="TODAS">-- Todas las Plantas --</option>' : '';
            configPlantas.forEach(p => h += `<option value="${p.id}">${p.id}</option>`);
            s.innerHTML = h;
        });
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
        aplicarFiltrosMonitor();
    }

    function aplicarFiltrosMonitor() {
        const pd = document.getElementById('filtro_planta_descarga').value;
        const u = document.getElementById('filtro_usuario').value;
        const est = document.getElementById('filtro_estado').value;
        
        let filtrados = listaTurnosCache;
        
        if(pd !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === pd);
        if(u !== 'TODOS') filtrados = filtrados.filter(t => getResponsableName(t) === u);
        if(est !== 'TODOS') {
            if(est === 'Cancelado') {
                filtrados = filtrados.filter(t => String(t.field_7).toLowerCase().includes('cancelado') || String(t.field_7).toLowerCase().includes('rechazado'));
            } else {
                filtrados = filtrados.filter(t => String(t.field_7).toLowerCase().includes(est.toLowerCase()));
            }
        }
        
        renderizarFilas(filtrados);
        calcularDisponibilidadOffline(); 
        generarResumenDiario();
    }

    function restablecerFiltros() {
        document.getElementById('filtro_planta_descarga').value = 'TODAS';
        document.getElementById('filtro_estado').value = 'TODOS';
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
        await cargarTurnos();
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
            logETLStep(2, true); logLog(`[ETL] BD Turnos Sincronizada. Registros: ${listaTurnosCache.length}`);
            
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
        let htmlPanel = '';

        configPlantas.forEach(plantaConfig => {
            if (pfSeleccionada !== 'TODAS' && plantaConfig.id !== pfSeleccionada) return;
            let ocupados = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === plantaConfig.id && String(t.field_7).toLowerCase() !== 'cancelado' && String(t.field_7).toLowerCase() !== 'rechazado');
            let slotsTotales = getSlotsCalculados(plantaConfig.id, fechaSeleccionadaGlobal);
            
            if (slotsTotales.length > 0) {
                htmlPanel += `<div class="mb-5"><h4 class="text-sm font-bold text-sky-300 uppercase tracking-wider text-center mb-2 bg-sky-950/40 py-2 rounded border border-sky-900/30">${plantaConfig.id}</h4><div class="space-y-3">`;
                slotsTotales.forEach(s => {
                    let ocupado = ocupados.find(t => normalizarStringHorario(t.field_5) === normalizarStringHorario(s));
                    if (ocupado) {
                        let pat = escapeHtml(ocupado.Patente || 'S/D');
                        let raz = escapeHtml(ocupado.field_2 || 'S/D');
                        let rsp = escapeHtml(getResponsableName(ocupado));
                        htmlPanel += `
                        <div class="flex flex-col p-3 border border-red-900 bg-red-950/30 rounded text-sm font-mono shadow-md">
                            <div class="flex justify-between text-rose-300 mb-1">
                                <span class="font-bold text-base">${s.split(' ')[0]}</span><span class="font-bold tracking-widest bg-black/40 px-2 rounded">${pat}</span>
                            </div>
                            <div class="flex flex-col text-slate-300 mt-1 gap-1">
                                <span class="truncate font-sans font-semibold">${raz}</span>
                                <span class="text-sky-400 text-xs whitespace-nowrap bg-sky-900/30 px-2 py-0.5 rounded inline-block w-fit">Resp: ${rsp}</span>
                            </div>
                        </div>`;
                    } else {
                        htmlPanel += `<div class="flex justify-between items-center p-3 border border-emerald-900 bg-emerald-950/30 rounded text-sm font-mono text-emerald-400 shadow-md opacity-70">
                            <span class="font-bold text-base">${s.split(' ')[0]}</span><span class="font-bold tracking-widest opacity-60">LIBRE</span>
                        </div>`;
                    }
                });
                htmlPanel += `</div></div>`;
            }
        });
        panel.innerHTML = htmlPanel || '<div class="text-center text-slate-500 text-sm mt-8">Sin agenda para esta configuracion.</div>';
    }

    // --- TABLA MONITOR ---
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

            // Sobreturno: resaltado suave en violeta, en contraste con los
            // colores de estado (verde/ambar/celeste/rojo) ya usados.
            const filaClase = esSobreturno
                ? 'border-b border-slate-700/50 hover:bg-violet-900/30 bg-violet-950/20 text-sm border-l-2 border-l-violet-500'
                : 'border-b border-slate-700/50 hover:bg-slate-800/30 text-sm';
            const tagSobreturno = esSobreturno ? `<span class="ml-1.5 text-[9px] uppercase font-bold text-violet-300 bg-violet-900/50 border border-violet-700 px-1.5 py-0.5 rounded">Sobreturno</span>` : '';

            htmlRows += `
            <tr class="${filaClase}">
                <td class="p-3 font-mono text-sky-400 font-bold">${t.Id}</td>
                <td class="p-3 font-mono text-slate-300">${fechaStr}</td>
                <td class="p-3 text-slate-300 font-bold">${escapeHtml(t.PlantaDescarga || '-')}</td>
                <td class="p-3 text-white font-semibold">${escapeHtml(t.field_2 || '-')}${tagSobreturno}</td>
                <td class="p-3 font-mono tracking-widest text-slate-300">
                    <span class="bg-black/40 px-2 py-1 rounded">${escapeHtml(t.Patente || '-')}</span>
                </td>
                <td class="p-3 text-amber-300 font-mono font-bold">${escapeHtml(t.field_5 || '-')}</td>
                <td class="p-3 ${colorEst} text-center">${estado}<br><span class="text-[10px] text-slate-500 font-normal truncate block max-w-[120px] mx-auto mt-0.5">${escapeHtml(getResponsableName(t))}</span></td>
                <td class="p-3 text-center flex justify-center gap-2">
                    <button onclick="modoABM_Ver(${t.Id})" class="bg-sky-700 hover:bg-sky-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Ver</button>
                    ${!esAprobado && estado.toLowerCase() !== 'cancelado' && estado.toLowerCase() !== 'rechazado' ? `<button onclick="modoABM_Aprobar(${t.Id})" class="bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Aprobar</button>` : ''}
                </td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }

    function getResponsableName(t) { return t.Author ? t.Author.Title : (t.Editor ? t.Editor.Title : (t.Gestor || 'S/D')); }

    // --- CALENDARIO FULL WIDTH ---
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
        renderizarGrilaCalendario(); 
        aplicarFiltrosMonitor(); 
        if(document.getElementById('s10').classList.contains('active')) {
            document.getElementById('dash_fecha').value = nuevaFecha;
            updateDashboard();
        }
    }

    // --- LOGICA HORARIOS ABM ---
    function renderizarABMHorarios() {
        const tb = document.getElementById('tabla-config-horarios');
        if(!tb) return;
        let h = '';
        configPlantas.forEach((p, idx) => {
            let chkSab = p.sabado ? 'checked' : '';
            h += `<tr class="text-sm"><td class="py-3 px-4 font-bold text-sky-400">${p.id}</td><td class="px-4"><input type="number" id="cfg_inlv_${idx}" value="${p.hInLV}" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white"> a <input type="number" id="cfg_outlv_${idx}" value="${p.hOutLV}" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white"></td><td class="px-4"><label class="mr-3"><input type="checkbox" id="cfg_sab_${idx}" ${chkSab} onchange="toggleSabado(${idx})"> Hab.</label><input type="number" id="cfg_ins_${idx}" value="${p.hInS}" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white ${!p.sabado ? 'opacity-30' : ''}" ${!p.sabado ? 'disabled' : ''}> a <input type="number" id="cfg_outs_${idx}" value="${p.hOutS}" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white ${!p.sabado ? 'opacity-30' : ''}" ${!p.sabado ? 'disabled' : ''}></td><td class="px-4"><input type="number" id="cfg_dur_${idx}" value="${p.duracion}" class="w-16 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white"></td><td class="px-4 text-center text-slate-500 font-mono">OK</td></tr>`;
        });
        tb.innerHTML = h;
    }
    function toggleSabado(idx) {
        let isChk = document.getElementById(`cfg_sab_${idx}`).checked;
        document.getElementById(`cfg_ins_${idx}`).disabled = !isChk; document.getElementById(`cfg_outs_${idx}`).disabled = !isChk;
        document.getElementById(`cfg_ins_${idx}`).classList.toggle('opacity-30', !isChk); document.getElementById(`cfg_outs_${idx}`).classList.toggle('opacity-30', !isChk);
    }
    function guardarConfiguracionHorarios() {
        configPlantas.forEach((p, idx) => {
            let dur = parseInt(document.getElementById(`cfg_dur_${idx}`).value) || 30;
            p.duracion = dur < 10 ? 10 : dur; 
            p.hInLV = parseInt(document.getElementById(`cfg_inlv_${idx}`).value) || 7; p.hOutLV = Math.max(p.hInLV + 1, parseInt(document.getElementById(`cfg_outlv_${idx}`).value) || 15);
            p.sabado = document.getElementById(`cfg_sab_${idx}`).checked;
            p.hInS = parseInt(document.getElementById(`cfg_ins_${idx}`).value) || 0; p.hOutS = Math.max(p.hInS, parseInt(document.getElementById(`cfg_outs_${idx}`).value) || 0);
        });
        showToast("Configuracion Guardada", "ok"); handleHorariosChange(); calcularDisponibilidadOffline();
    }

    function getSlotsCalculados(plantaId, fechaStr) {
        let slots = [];
        if(!fechaStr) return slots;
        let pConf = configPlantas.find(p => p.id === plantaId) || configPlantas[0];
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
        const fVal = document.getElementById('f_fecha').value;
        if (!fVal) return;
        document.getElementById('f_dia').textContent = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'][new Date(fVal.replace(/-/g, '/') + ' 00:00:00').getDay()];
    }
    function handleHorariosChange() {
        const ind = document.getElementById('form-mode-indicator').textContent;
        regenerarHorariosABM(ind.includes('ALTA') || ind.includes('REPROGRAMA')); autoDia();
    }
    function regenerarHorariosABM(modoFiltro = false) {
        const pf = document.getElementById('f_planta_descarga').value; const f = document.getElementById('f_fecha').value; const sel = document.getElementById('f_horario');
        if(!sel) return;
        let allSlots = getSlotsCalculados(pf, f); sel.innerHTML = '';
        if(allSlots.length === 0) { sel.innerHTML = '<option value="">Sin Operacion</option>'; return; }
        let oc = modoFiltro ? listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(f) && t.PlantaDescarga === pf && String(t.field_7).toLowerCase() !== 'cancelado' && String(t.field_7).toLowerCase() !== 'rechazado').map(t => normalizarStringHorario(t.field_5)) : [];
        let htmlOpts = '';
        allSlots.forEach(s => { if (!(modoFiltro && oc.includes(normalizarStringHorario(s)))) htmlOpts += `<option value="${s}">${s}</option>`; });
        sel.innerHTML = htmlOpts === '' ? '<option value="">Agenda Completa</option>' : htmlOpts;
    }

    // --- CENTRAL DE VALIDACION ---
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
        
        const provEnBD = listaProveedoresCache.find(p => p.id.replace(/[^0-9]/g, '') === cuitLimpio);
        if(!provEnBD && listaProveedoresCache.length > 0) return marcarError('f_cuit', "Proveedor no existe.");
        if(provEnBD && provEnBD.estado !== 'Habilitado') return marcarError('f_cuit', "Proveedor inhabilitado.");

        if(!fProv) return marcarError('f_proveedor', "Razon Social vacia.");
        if(fEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fEmail)) return marcarError('f_email', "Email invalido.");
        if(!fFec) return marcarError('f_fecha', "Fecha requerida.");
        
        if(modo === 'ALTA' || modo === 'REPROGRAMAR') {
            const hoy = new Date(); hoy.setHours(0,0,0,0);
            if(new Date(fFec.replace(/-/g, '/') + ' 00:00:00') < hoy) return marcarError('f_fecha', "Fecha pasada.");
        }
        if(!fHor) return marcarError('f_horario', "Seleccione horario libre.");
        return true;
    }

    async function checkSlotLibreConcurrencia(planta, fecha, slot) {
        logETLStep(2, false);
        try {
            const res = await fetchSharePoint(`items?$filter=PlantaDescarga eq '${planta}' and startswith(field_6, '${fecha}') and field_5 eq '${slot}' and field_7 ne 'Cancelado' and field_7 ne 'Rechazado'&$select=Id`);
            if(res.ok) { const data = await res.json(); return data.value.length === 0; }
        } catch(e) {} 
        return true; 
    }

    function mostrarBannerABM(id, modo) {
        const banner = document.getElementById('abm-mensaje-estado');
        banner.classList.remove('hidden');
        if(modo === 'VER') {
            banner.className = "text-sm font-bold px-4 py-3 rounded mb-4 shadow-md bg-sky-900/50 text-sky-300 border border-sky-700 block";
            banner.textContent = `El turno con el ID N° ${id} esta siendo consultado.`;
        } else if (modo === 'APROBAR') {
            banner.className = "text-sm font-bold px-4 py-3 rounded mb-4 shadow-md bg-amber-900/50 text-amber-300 border border-amber-700 block";
            banner.textContent = `El turno con el ID N° ${id} esta siendo modificado.`;
        }
    }

    // --- ESTADOS ABM ---
    function abrirAltaTurno() {
        limpiarFormularioABM();
        const hoyIso = new Date().toISOString().split('T')[0];
        document.getElementById('f_fecha').value = ""; 
        document.getElementById('f_fecha').min = hoyIso; 
        document.getElementById('f_dia').textContent = "-"; 
        regenerarHorariosABM(true); 
        document.getElementById('form-mode-indicator').textContent = "ALTA DE TURNO";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-sky-900 text-sky-300 rounded-full font-bold";
        habilitarCamposABM(true); renderBotonesABM('ALTA'); document.getElementById('btn-tab-abm').click();
    }
    function modoABM_Ver(id) {
        cargarTurnoEnFormulario(id);
        document.getElementById('form-mode-indicator').textContent = "CONSULTA LECTURA";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-slate-800 text-slate-300 rounded-full font-bold";
        mostrarBannerABM(id, 'VER');
        habilitarCamposABM(false); renderBotonesABM('VER'); document.getElementById('btn-tab-abm').click();
    }
    function modoABM_Aprobar(id) {
        cargarTurnoEnFormulario(id);
        document.getElementById('form-mode-indicator').textContent = "MODO APROBACION";
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1 bg-amber-900 text-amber-300 rounded-full font-bold border border-amber-500";
        mostrarBannerABM(id, 'APROBAR');
        habilitarCamposABM(false); renderBotonesABM('APROBAR_PANEL'); document.getElementById('btn-tab-abm').click();
    }
    function modoABM_Reprogramar() {
        document.getElementById('form-mode-indicator').textContent = "REPROGRAMACION";
        document.getElementById('abm-mensaje-estado').className = "hidden"; 
        habilitarCamposABM(false);
        document.getElementById('f_fecha').disabled = false; document.getElementById('f_fecha').min = new Date().toISOString().split('T')[0];
        document.getElementById('f_horario').disabled = false;
        handleHorariosChange(); renderBotonesABM('REPROGRAMAR');
    }
    function volverTurnosDiarios() { document.getElementById('btn-tab-monitor').click(); }
    
    function habilitarCamposABM(estado) { 
        document.querySelectorAll('.f-control').forEach(el => el.disabled = !estado); 
    }

    function renderBotonesABM(modo) {
        const panel = document.getElementById('panel-botones-abm');

        if (modo === 'ALTA') panel.innerHTML = `<button onclick="crearTurno()" class="bg-sky-600 hover:bg-sky-500 px-6 py-3 font-bold rounded text-white flex-1 transition shadow">Registrar Alta</button>`;
        else if (modo === 'VER') panel.innerHTML = `<button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded text-white flex-1 transition shadow">Volver al Monitor</button>`;
        else if (modo === 'APROBAR_PANEL') panel.innerHTML = `<button onclick="ejecutarAccionFlujo('Aprobado')" class="bg-emerald-600 hover:bg-emerald-500 px-4 py-3 font-bold rounded text-white flex-1 transition shadow">Aprobar</button><button onclick="ejecutarAccionFlujo('Cancelado')" class="bg-rose-600 hover:bg-rose-500 px-4 py-3 font-bold rounded text-white flex-1 transition shadow">Cancelar</button><button onclick="modoABM_Reprogramar()" class="bg-amber-600 hover:bg-amber-500 px-4 py-3 font-bold rounded text-white flex-1 transition shadow">Reprogramar</button>`;
        else if (modo === 'REPROGRAMAR') panel.innerHTML = `<button onclick="ejecutarReprogramacion()" class="bg-indigo-600 hover:bg-indigo-500 px-6 py-3 font-bold rounded text-white flex-1 transition shadow">Confirmar Reprogramacion</button><button onclick="modoABM_Ver(document.getElementById('f_item_id').value)" class="bg-slate-700 hover:bg-slate-600 px-4 py-3 font-bold rounded text-white transition shadow">Abortar</button>`;
    }

    function cargarTurnoEnFormulario(id) {
        const t = listaTurnosCache.find(item => item.Id === parseInt(id));
        if (!t) return;
        limpiarErroresVisuales();
        document.getElementById('f_item_id').value = t.Id;
        document.getElementById('f_patente').value = t.Patente || ''; document.getElementById('f_hora_ing').value = t.HoraIngresoReal || ''; document.getElementById('f_hora_sal').value = t.HoraSalidaReal || '';
        document.getElementById('f_cuit').value = t.field_1 || ''; document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || ''; document.getElementById('f_proveedor').value = t.field_2 || ''; document.getElementById('f_email').value = t.field_3 || '';
        if (t.field_6) document.getElementById('f_fecha').value = String(t.field_6).split('T')[0];
        
        autoDia(); document.getElementById('f_planta').value = t.Planta || 'Packaging'; document.getElementById('f_planta_descarga').value = t.PlantaDescarga || 'Parque Canuelas';
        
        regenerarHorariosABM(false);
        let slotSelect = document.getElementById('f_horario');
        if (!Array.from(slotSelect.options).some(opt => opt.value === t.field_5) && t.field_5) slotSelect.add(new Option(t.field_5 + " (Asignado)", t.field_5));
        slotSelect.value = t.field_5 || '';
        
        document.getElementById('f_usuario_gestor').textContent = escapeHtml(getResponsableName(t));
        const est = String(t.field_7 || 'PENDIENTE').trim().toUpperCase();
        document.getElementById('f_estado_actual').textContent = est;
        
        // Habilita IN/OUT unicamente si el turno esta Aprobado o Reprogramado
        const trackEnab = (est === 'APROBADO' || est === 'REPROGRAMADO');
        document.getElementById('btn-track-in').disabled = !trackEnab; document.getElementById('btn-track-out').disabled = !trackEnab;
    }

    function limpiarFormularioABM() {
        limpiarErroresVisuales();
        document.getElementById('abm-mensaje-estado').className = "hidden";
        document.getElementById('f_item_id').value = ''; 
        document.querySelectorAll('.f-control').forEach(i => { 
            // Anti-rotura: no borra los selects para que no se trabe el horario de plantas
            if (i.tagName === 'SELECT' && i.options.length > 0) i.selectedIndex = 0;
            else i.value = ''; 
            i.disabled = true; 
        });
        document.getElementById('f_fecha').min = ''; document.getElementById('f_usuario_gestor').textContent = '-'; document.getElementById('f_estado_actual').textContent = 'NUEVO';
        document.getElementById('panel-botones-abm').innerHTML = ''; document.getElementById('btn-track-in').disabled = true; document.getElementById('btn-track-out').disabled = true;
    }

    async function crearTurno() {
        if(!validarFormularioTurno('ALTA')) return;
        const pf = document.getElementById('f_planta_descarga').value; const fc = document.getElementById('f_fecha').value; const sh = document.getElementById('f_horario').value;
        const libre = await checkSlotLibreConcurrencia(pf, fc, sh);
        if(!libre) return marcarError('f_horario', "Slot ocupado por otro usuario.");

        const payload = {
            field_1: document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''), field_2: document.getElementById('f_proveedor').value.trim(), field_3: document.getElementById('f_email').value.trim(),
            field_5: sh, field_6: fc + "T00:00:00Z", field_7: "Pendiente", N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, PlantaDescarga: pf, Dia: document.getElementById('f_dia').textContent, Patente: document.getElementById('f_patente').value.trim().toUpperCase()
        };
        await ejecutarTransaccion(null, payload, "Turno Creado"); volverTurnosDiarios();
    }

    async function ejecutarAccionFlujo(nuevoEstado) {
        const id = document.getElementById('f_item_id').value; const email = document.getElementById('f_email').value;
        const t = listaTurnosCache.find(x => x.Id == id);
        if(t && String(t.field_7).toLowerCase() === 'cancelado' && nuevoEstado !== 'Cancelado') return showToast("El turno ya fue cancelado.", "err");

        await ejecutarTransaccion(id, { field_7: nuevoEstado }, `Turno ${nuevoEstado}`);
        logLog(`[ETL] Accion (${nuevoEstado}) registrada a las ` + new Date().toLocaleTimeString());
        
        if (email) {
            const responsable = getResponsableName(t);
            const userObj = listaUsuariosCache.find(u => u.nombre === responsable);
            const cc = userObj && userObj.email ? `&cc=${userObj.email}` : '';
            let body = `Su turno logistico ha sido ${nuevoEstado.toUpperCase()}.\nFecha: ${document.getElementById('f_fecha').value}\nHorario: ${document.getElementById('f_horario').value}\n\nEnviado por: ${responsable}`;
            window.location.href = `mailto:${email}?subject=Estado Turno: ${nuevoEstado}${cc}&body=${encodeURIComponent(body)}`;
        }
        volverTurnosDiarios();
    }

    async function ejecutarReprogramacion() {
        if(!validarFormularioTurno('REPROGRAMAR')) return;
        const id = document.getElementById('f_item_id').value; const pf = document.getElementById('f_planta_descarga').value; const fc = document.getElementById('f_fecha').value; const sh = document.getElementById('f_horario').value;
        const libre = await checkSlotLibreConcurrencia(pf, fc, sh);
        if(!libre) return marcarError('f_horario', "Slot ocupado.");
        await ejecutarTransaccion(id, { field_6: fc + "T00:00:00Z", field_5: sh, field_7: "Reprogramado" }, "Turno Reprogramado");
        logLog(`[ETL] Accion (Reprogramado) registrada a las ` + new Date().toLocaleTimeString());
        volverTurnosDiarios();
    }

    async function marcarTrackingForm(tipo) {
        const id = document.getElementById('f_item_id').value; const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        let payload = {};
        if(tipo === 'IN') { payload.HoraIngresoReal = horaStr; document.getElementById('f_hora_ing').value = horaStr; }
        if(tipo === 'OUT') { payload.HoraSalidaReal = horaStr; document.getElementById('f_hora_sal').value = horaStr; }
        await ejecutarTransaccion(id, payload, `Check-${tipo} Registrado`, true);
    }

    // --- ABM PROVEEDORES ---
    function parsearCSVProveedores(text) {
        const lines = text.split(/\r?\n|\r/);
        listaProveedoresCache = [];
        for(let i=1; i<lines.length; i++) {
            const row = lines[i].trim();
            if(!row) continue;
            const cols = row.split(/;/); 
            if(cols.length >= 7) {
                listaProveedoresCache.push({ 
                    usuario: cols[0].trim(),
                    responsable: cols[1].trim(),
                    mail: cols[2].trim(),
                    tipo: cols[3].trim(),
                    id: cols[4].replace(/[^0-9]/g, ''), 
                    nombre: cols[5].trim(), 
                    estado: cols[6].trim() || 'Habilitado' 
                });
            }
        }
        renderizarBaseProveedores();
    }

    function renderizarBaseProveedores() {
        const tb = document.getElementById('tabla-proveedores');
        if(!tb) return;
        tb.innerHTML = listaProveedoresCache.map((p, idx) => `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarProvForm(${idx})">
                <td class="p-3 font-mono text-slate-300">${escapeHtml(p.usuario)}</td>
                <td class="p-3 text-slate-400">${escapeHtml(p.responsable)}</td>
                <td class="p-3 font-mono text-amber-400 font-bold">${escapeHtml(p.id)}</td>
                <td class="p-3 text-white font-semibold">${escapeHtml(p.nombre)}</td>
                <td class="p-3 text-slate-400">${escapeHtml(p.tipo)}</td>
                <td class="p-3 font-bold ${p.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(p.estado)}</td>
                <td class="p-3 text-sky-400 underline text-center">Editar</td>
            </tr>`).join('');
    }

    function cargarProvForm(idx) {
        const p = listaProveedoresCache[idx];
        document.getElementById('p_index').value = idx; 
        document.getElementById('p_usuario').value = p.usuario;
        document.getElementById('p_resp').value = p.responsable;
        document.getElementById('p_mail').value = p.mail;
        document.getElementById('p_tipo').value = p.tipo; 
        document.getElementById('p_cuit').value = p.id; 
        document.getElementById('p_razon').value = p.nombre;
        document.getElementById('p_estado').value = p.estado || 'Habilitado';
    }

    // Punto 2: misma logica que limpiarFormularioUsuario, para dar de alta
    // un proveedor nuevo desde un boton explicito en vez de depender de
    // recargar la pagina o dejar el form en estado intermedio.
    function limpiarFormularioProveedor() {
        document.getElementById('p_index').value = '';
        document.getElementById('p_usuario').value = '';
        document.getElementById('p_resp').value = '';
        document.getElementById('p_mail').value = '';
        document.getElementById('p_cuit').value = '';
        document.getElementById('p_razon').value = '';
        document.getElementById('p_tipo').value = '';
        document.getElementById('p_estado').value = 'Habilitado';
        showToast("Formulario listo para nuevo proveedor", "ok");
    }

    async function guardarEdicionProveedor() {
        const idx = document.getElementById('p_index').value; 
        const pId = document.getElementById('p_cuit').value.replace(/[^0-9]/g, '');
        if(!pId) return showToast("Falta CUIT", "err");
        
        const obj = { 
            usuario: document.getElementById('p_usuario').value,
            responsable: document.getElementById('p_resp').value,
            mail: document.getElementById('p_mail').value,
            tipo: document.getElementById('p_tipo').value,
            id: pId, 
            nombre: document.getElementById('p_razon').value, 
            estado: document.getElementById('p_estado').value 
        };
        if(idx === '') listaProveedoresCache.push(obj); 
        else listaProveedoresCache[idx] = obj;
        
        renderizarBaseProveedores(); 
        limpiarFormularioProveedor();

        showToast("Proveedor Guardado", "ok");
        await actualizarCSVSharePoint('prov');
    }

    function autocompletarProveedor() {
        const nProv = document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''); document.getElementById('f_cuit').value = nProv; 
        if(!nProv || listaProveedoresCache.length === 0) return;
        const provEncontrado = listaProveedoresCache.find(p => p.id === nProv);
        if(provEncontrado) {
            if(provEncontrado.estado === 'Habilitado') {
                document.getElementById('f_proveedor').value = provEncontrado.nombre;
                if(provEncontrado.tipo.toLowerCase().includes('insumo')) document.getElementById('f_planta').value = 'Insumos';
                else if(provEncontrado.tipo.toLowerCase().includes('pack')) document.getElementById('f_planta').value = 'Packaging';
                showToast(`Completado OK`, "ok");
            } else { marcarError('f_cuit', "PROVEEDOR INHABILITADO"); }
        }
    }

    // --- ABM USUARIOS ---
    function parsearCSVUsuarios(text) {
        const lines = text.split(/\r?\n|\r/);
        listaUsuariosCache = [];
        for(let i=1; i<lines.length; i++) { 
            const row = lines[i].trim();
            if(!row) continue;
            const cols = row.split(/;/); 
            if(cols.length >= 5) {
                listaUsuariosCache.push({ 
                    id: cols[0].trim(), 
                    nombre: cols[1].trim(), 
                    email: cols[2].trim(), 
                    planta: cols[3].trim(),
                    estado: cols[4] ? cols[4].trim() : 'Habilitado' 
                });
            }
        }
        renderizarBaseUsuarios();
    }

    function renderizarBaseUsuarios() {
        const tb = document.getElementById('tabla-usuarios');
        if(!tb) return;
        tb.innerHTML = listaUsuariosCache.map((u, idx) => `
            <tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarUsuForm(${idx})">
                <td class="p-3 font-mono text-amber-400">${escapeHtml(u.id)}</td>
                <td class="p-3 text-white font-semibold">${escapeHtml(u.nombre)}</td>
                <td class="p-3 text-slate-400">${escapeHtml(u.email)}</td>
                <td class="p-3 text-slate-400">${escapeHtml(u.planta)}</td>
                <td class="p-3 font-bold ${u.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(u.estado)}</td>
                <td class="p-3 text-sky-400 underline text-center">Editar</td>
            </tr>`).join('');
    }

    function cargarUsuForm(idx) {
        const u = listaUsuariosCache[idx];
        document.getElementById('u_index').value = idx; 
        document.getElementById('u_id').value = u.id; 
        document.getElementById('u_nombre').value = u.nombre;
        document.getElementById('u_email').value = u.email; 
        document.getElementById('u_planta').value = u.planta; 
        document.getElementById('u_estado').value = u.estado || 'Habilitado';
    }

    function limpiarFormularioUsuario() {
        document.getElementById('u_index').value = ''; 
        document.getElementById('u_id').value = ''; 
        document.getElementById('u_nombre').value = '';
        document.getElementById('u_email').value = ''; 
        if(document.getElementById('u_planta').options.length > 0) document.getElementById('u_planta').selectedIndex = 0;
        document.getElementById('u_estado').value = 'Habilitado';
        showToast("Formulario listo para nuevo usuario", "ok");
    }

    async function guardarEdicionUsuario() {
        const idx = document.getElementById('u_index').value; 
        const uId = document.getElementById('u_id').value.trim();
        if(!uId) return showToast("Falta ID", "err");
        
        const obj = { 
            id: uId, 
            nombre: document.getElementById('u_nombre').value, 
            email: document.getElementById('u_email').value, 
            planta: document.getElementById('u_planta').value, 
            estado: document.getElementById('u_estado').value 
        };

        if(idx === '') listaUsuariosCache.push(obj); 
        else listaUsuariosCache[idx] = obj;
        
        renderizarBaseUsuarios(); 
        sincronizarFiltrosYMonitor(); 

        document.getElementById('u_index').value = ''; 
        document.getElementById('u_id').value = ''; 
        document.getElementById('u_nombre').value = '';
        document.getElementById('u_email').value = ''; 
        if(document.getElementById('u_planta').options.length > 0) document.getElementById('u_planta').selectedIndex = 0;
        document.getElementById('u_estado').value = 'Habilitado';

        showToast("Usuario Guardado", "ok");
        await actualizarCSVSharePoint('usu');
    }

    // --- MAILING PARA REPORTES ---
    function enviarResumenDiario() {
        const idsPermitidos = ['Usu01', 'Usu02', 'Usu03', 'Usu04', 'Usu05', 'Usu06', 'Usu07', 'Usu08'];
        
        const para = listaUsuariosCache
            .filter(u => u.estado !== 'Deshabilitado' && idsPermitidos.includes(String(u.id)))
            .map(u => u.email)
            .filter(Boolean)
            .join(';');
            
        if(!para) return showToast("No se detectaron los usuarios autorizados en la base", "err");
        
        const fFiltro = fechaSeleccionadaGlobal; 
        const turnosHoy = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fFiltro));
        
        if(turnosHoy.length === 0) return showToast("No hay turnos para reportar en esta fecha", "err");
        
        let body = `RESUMEN DIARIO LOGISTICO - ${fFiltro}\n\n`;
        configPlantas.forEach(p => {
            const turnosP = turnosHoy.filter(t => t.PlantaDescarga === p.id);
            if(turnosP.length > 0) {
                body += `[ === PLANTA: ${p.id.toUpperCase()} === ]\n`;
                turnosP.forEach(t => body += `-> Slot: ${t.field_5} | Patente: ${t.Patente||'S/D'} | Prov: ${t.field_2} | Estado: ${t.field_7}\n`);
                body += `\n`;
            }
        });
        
        window.location.href = `mailto:${para}?subject=Reporte de Operacion Molca - ${fFiltro}&body=${encodeURIComponent(body)}`;
    }

    // --- DASHBOARD DE INDICADORES (KPIs) ---
    let chartEstados, chartProveedores, chartPlantas, chartHorarios;

    function initDashboard() {
        document.getElementById('dash_fecha').value = fechaSeleccionadaGlobal;
        cargarSelectoresDashboard();
        updateDashboard();
    }

    function cargarSelectoresDashboard() {
        let usrHTML = '<option value="TODOS">-- Todos --</option>';
        const usr = [...new Set(listaTurnosCache.map(t => getResponsableName(t)).filter(Boolean))].sort();
        usr.forEach(u => { usrHTML += `<option value="${escapeHtml(u)}">${escapeHtml(u)}</option>`; });
        document.getElementById('dash_resp').innerHTML = usrHTML;

        let horHTML = '<option value="TODOS">-- Todos --</option>';
        const hor = [...new Set(listaTurnosCache.map(t => t.field_5).filter(Boolean))].sort();
        hor.forEach(h => { horHTML += `<option value="${escapeHtml(h)}">${escapeHtml(h)}</option>`; });
        document.getElementById('dash_horario').innerHTML = horHTML;
    }

    function updateDashboard() {
        const d_fec = document.getElementById('dash_fecha').value;
        const d_pla = document.getElementById('dash_planta').value;
        const d_hor = document.getElementById('dash_horario').value;
        const d_res = document.getElementById('dash_resp').value;

        let filtrados = listaTurnosCache;
        if(d_fec) filtrados = filtrados.filter(t => t.field_6 && t.field_6.startsWith(d_fec));
        if(d_pla !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === d_pla);
        if(d_hor !== 'TODOS') filtrados = filtrados.filter(t => t.field_5 === d_hor);
        if(d_res !== 'TODOS') filtrados = filtrados.filter(t => getResponsableName(t) === d_res);

        let estadosCount = { 'Aprobado':0, 'Pendiente':0, 'Reprogramado':0, 'Cancelado':0, 'Rechazado':0 };
        let plantasCount = {};
        let horCount = {};
        let provCount = {};

        let htmlResumen = '';
        let totAsig = 0, totPend = 0, totApro = 0, totRepr = 0, totCanc = 0;

        filtrados.forEach(t => {
            let est = String(t.field_7).trim();
            if(estadosCount[est] !== undefined) estadosCount[est]++;
            else if (est.toLowerCase().includes('rechazado')) estadosCount['Rechazado']++;

            let pl = t.PlantaDescarga || 'S/D';
            plantasCount[pl] = (plantasCount[pl] || 0) + 1;

            let hr = t.field_5 || 'S/D';
            horCount[hr] = (horCount[hr] || 0) + 1;

            let prv = t.field_2 || 'S/D';
            provCount[prv] = (provCount[prv] || 0) + 1;
        });

        configPlantas.forEach(p => {
            const trnP = filtrados.filter(t => t.PlantaDescarga === p.id);
            if(trnP.length > 0) {
                let asig = trnP.length;
                let pend = trnP.filter(t => (t.field_7||'').toLowerCase().includes('pendiente')).length;
                let apro = trnP.filter(t => (t.field_7||'').toLowerCase().includes('aprobado')).length;
                let repr = trnP.filter(t => (t.field_7||'').toLowerCase().includes('reprogramado')).length;
                let canc = trnP.filter(t => (t.field_7||'').toLowerCase().includes('cancelado') || (t.field_7||'').toLowerCase().includes('rechazado')).length;
                
                totAsig += asig; totPend += pend; totApro += apro; totRepr += repr; totCanc += canc;

                htmlResumen += `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 transition">
                    <td class="py-3 px-3 font-bold text-sky-300 text-sm">${p.id}</td>
                    <td class="px-3 text-center font-bold text-white text-base">${asig}</td>
                    <td class="px-3 text-center font-bold text-amber-400">${pend}</td>
                    <td class="px-3 text-center font-bold text-emerald-400">${apro}</td>
                    <td class="px-3 text-center font-bold text-sky-400">${repr}</td>
                    <td class="px-3 text-center font-bold text-rose-400">${canc}</td>
                </tr>`;
            }
        });

        if(htmlResumen === '') {
            htmlResumen = '<tr><td colspan="6" class="p-6 text-center text-slate-500 text-sm">No hay actividad logistica para estos filtros.</td></tr>';
        } else {
            htmlResumen += `<tr class="bg-slate-800/80 font-extrabold text-white uppercase tracking-wider border-t-2 border-slate-500">
                <td class="py-4 px-3 text-right">TOTALES:</td>
                <td class="px-3 text-center text-lg">${totAsig}</td>
                <td class="px-3 text-center text-amber-400 text-lg">${totPend}</td>
                <td class="px-3 text-center text-emerald-400 text-lg">${totApro}</td>
                <td class="px-3 text-center text-sky-400 text-lg">${totRepr}</td>
                <td class="px-3 text-center text-rose-400 text-lg">${totCanc}</td>
            </tr>`;
        }
        document.getElementById('tabla-resumen-dashboard').innerHTML = htmlResumen;

        Chart.defaults.color = '#94a3b8';
        Chart.defaults.font.family = 'Syne';

        if(chartEstados) chartEstados.destroy();
        chartEstados = new Chart(document.getElementById('chartEstados'), {
            type: 'bar',
            data: {
                labels: ['Aprobados', 'Pendientes', 'Reprogramados', 'Cancelados/Rechazados'],
                datasets: [{
                    label: 'Cantidad de Turnos',
                    data: [estadosCount['Aprobado'], estadosCount['Pendiente'], estadosCount['Reprogramado'], estadosCount['Cancelado']+estadosCount['Rechazado']],
                    backgroundColor: ['rgba(52, 211, 153, 0.7)', 'rgba(251, 191, 36, 0.7)', 'rgba(56, 189, 248, 0.7)', 'rgba(244, 63, 94, 0.7)'],
                    borderColor: ['#10b981', '#f59e0b', '#0ea5e9', '#e11d48'],
                    borderWidth: 1
                }]
            },
            options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });

        const provSorted = Object.entries(provCount).sort((a,b) => b[1]-a[1]).slice(0,10);
        if(chartProveedores) chartProveedores.destroy();
        chartProveedores = new Chart(document.getElementById('chartProveedores'), {
            type: 'bar',
            data: {
                labels: provSorted.map(p => p[0].substring(0, 15) + '...'),
                datasets: [{
                    label: 'Turnos por Proveedor (Top 10)',
                    data: provSorted.map(p => p[1]),
                    backgroundColor: 'rgba(99, 102, 241, 0.7)',
                    borderColor: '#4f46e5',
                    borderWidth: 1
                }]
            },
            options: { indexAxis: 'y', responsive: true, scales: { x: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });

        if(chartPlantas) chartPlantas.destroy();
        chartPlantas = new Chart(document.getElementById('chartPlantas'), {
            type: 'bar',
            data: {
                labels: Object.keys(plantasCount),
                datasets: [{
                    label: 'Volumen Operativo',
                    data: Object.values(plantasCount),
                    backgroundColor: 'rgba(244, 114, 182, 0.7)',
                    borderColor: '#e11d48',
                    borderWidth: 1
                }]
            },
            options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });

        if(chartHorarios) chartHorarios.destroy();
        chartHorarios = new Chart(document.getElementById('chartHorarios'), {
            type: 'line',
            data: {
                labels: Object.keys(horCount).sort(),
                datasets: [{
                    label: 'Densidad por Horario',
                    data: Object.keys(horCount).sort().map(k => horCount[k]),
                    backgroundColor: 'rgba(167, 139, 250, 0.2)',
                    borderColor: '#c084fc',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.3
                }]
            },
            options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } }
        });
    }

    // --- ETL LOGS ---
    function logETLStep(stepNum, isDone=false) {
        const steps = ['etl-extract', 'etl-transform', 'etl-load']; const ic = ['etl-ic1', 'etl-ic2', 'etl-ic3'];
        steps.forEach((s, idx) => {
            let el = document.getElementById(s); if(!el) return;
            if(idx === stepNum-1) { el.classList.add('active'); if(isDone) { el.classList.add('done'); document.getElementById(ic[idx]).innerHTML = 'OK'; } } 
            else { el.classList.remove('active'); }
        });
    }
    
    function logLog(msg) { 
        const d = document.getElementById('etl-log-console'); 
        if(d) { 
            d.insertAdjacentHTML('beforeend', `<div><span class="text-slate-500">[${new Date().toLocaleTimeString()}]</span> ${msg}</div>`); 
            d.scrollTop = d.scrollHeight; 
        } 
    }
    
    async function generarLogArchivoSP(modulo, detalle) { logLog(`[Audit Log] -> Modulo: ${modulo} | Accion: ${detalle} | User: ${currentLoggedUser.name}`); }

    function showToast(msg, type) { 
        const t = document.getElementById('toast'); 
        if(!t) return; 
        t.textContent = msg; 
        t.className = `show ${type}`; 
        setTimeout(() => t.className = '', 3000); 
    }

    initApp();
</script>
</body>
</html>