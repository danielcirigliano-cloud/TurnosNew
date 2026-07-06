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

        <div class="mt-2">
            <button onclick="toggleMenuConfig()" class="w-full text-left rounded tab-btn flex justify-between items-center" id="btn-menu-config">
                <span>3. Configuracion</span>
                <span id="icon-menu-config" class="text-red-500 text-sm font-bold">&#9654;</span>
            </button>
            <div id="submenu-config" class="hidden pl-3 border-l border-slate-700 ml-3 mt-1 space-y-1">
                <button class="w-full text-left rounded tab-btn text-sm" data-target="sFlota" onclick="renderizarBaseFlota()">Flota</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="s6" onclick="renderizarBaseProveedores()">Proveedores</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="s7" onclick="renderizarBaseUsuarios()">Usuarios</button>
                <button class="w-full text-left rounded tab-btn text-sm" data-target="sZonas" onclick="renderizarBaseZonas()">Zonas de Descarga</button>
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
                        <input type="text" id="filtro_patente" list="dl_patentes" oninput="aplicarFiltrosMonitor()" placeholder="Buscar patente..."
                            class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-28 uppercase">
                        <datalist id="dl_patentes"></datalist>
                    </div>
                    <div>
                        <label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Proveedor</label>
                        <input type="text" id="filtro_proveedor" list="dl_proveedores" oninput="aplicarFiltrosMonitor()" placeholder="Buscar proveedor..."
                            class="bg-slate-950 border border-slate-700 p-1.5 text-xs text-white rounded outline-none w-40">
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

    <!-- SECCION 6: BASE PROVEEDORES -->
    <section id="s6" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Proveedores</h2>
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
                <div class="col-span-1">
				<label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Insumo</label>
				<select id="p_tipo" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none transition-colors focus:border-sky-500">
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

    <!-- SECCION 7: USUARIOS -->
    <section id="s7" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Usuarios</h2>
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
                        <option value="">-</option>
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
                        <tr><th class="py-4 px-4">Planta Fisica</th><th class="px-4">Lunes a Viernes</th><th class="px-4">Sabados</th><th class="px-4">Minutos x Turno</th><th class="px-4 text-center">Turnos LV</th><th class="px-4 text-center">Turnos Sab</th><th class="px-4 text-center">Ins/Pack/NoProd</th><th class="px-4 text-center">Total/dia</th><th class="px-4 text-center">Estatus</th></tr>
                    </thead>
                    <tbody id="tabla-config-horarios" class="divide-y divide-slate-700/50"></tbody>
                </table>
            </div>
            <div class="mt-6 flex gap-2">
                <button onclick="guardarConfiguracionHorarios()" class="bg-emerald-600 hover:bg-emerald-500 px-6 py-3 font-bold rounded shadow transition text-white">Guardar Configuracion</button>
                <button onclick="agregarNuevaPlanta()" class="bg-sky-700 hover:bg-sky-600 px-6 py-3 font-bold rounded shadow transition text-white">[+] Agregar Planta</button>
            </div>
        </div>
    </section>

    <!-- SECCION 11: FLOTA COMPLETA CON TODOS LOS CAMPOS -->
    <section id="sFlota" class="tab-content mt-8 w-full max-w-[1400px] mx-auto">
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-sky-400 tracking-tight">Flota</h2>
            <p class="text-xs text-slate-400">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Lists/Vehiculos</span></p>
        </div>
        
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="fl_item_id">
            <div class="grid grid-cols-12 gap-4 items-end mb-2">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Patente *</label>
                    <input type="text" id="fl_patente" class="w-full bg-slate-900 border border-slate-700 p-2 text-amber-300 font-bold uppercase rounded outline-none focus:border-sky-500" placeholder="Ej: AB123CD">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Descripcion</label>
                    <input type="text" id="fl_descripcion" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500" placeholder="Marca / Modelo">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Vehiculo *</label>
                    <select id="fl_tipo" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Tipo -</option>
                        <option value="CHASIS">CHASIS</option>
                        <option value="BALANCIN">BALANCIN</option>
                        <option value="SEMI">SEMI</option>
                        <option value="UTILITARIO">UTILITARIO</option>
                        <option value="FURGON">FURGON</option>
                    </select>
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Empresa / Proveedor</label>
                    <input type="text" id="fl_empresa" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">CUIT Empresa</label>
                    <input type="text" id="fl_cuit" class="w-full bg-slate-900 border border-slate-700 p-2 text-amber-300 font-bold rounded outline-none focus:border-sky-500">
                </div>
            </div>

            <div class="grid grid-cols-12 gap-4 items-end mb-2">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Nombre Chofer</label>
                    <input type="text" id="fl_nombre" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Apellido Chofer</label>
                    <input type="text" id="fl_apellido" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">DNI</label>
                    <input type="text" id="fl_dni" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Correo</label>
                    <input type="email" id="fl_correo" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-3">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Celular</label>
                    <input type="text" id="fl_celular" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
            </div>

            <div class="grid grid-cols-12 gap-4 items-end">
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Cap 1 (Pallets)</label>
                    <input type="text" id="fl_cap1" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Cap 2 (KGs)</label>
                    <input type="text" id="fl_cap2" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Cap 3 (Vol)</label>
                    <input type="text" id="fl_cap3" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Tipo Disp.</label>
                    <input type="text" id="fl_tipodisp" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Num Disp.</label>
                    <input type="text" id="fl_numdisp" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                </div>
                <div class="col-span-2">
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado *</label>
                    <select id="fl_estado" class="w-full bg-slate-900 border border-slate-700 p-2 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Habilitado">Habilitado</option>
                        <option value="Deshabilitado">Deshabilitado</option>
                    </select>
                </div>
            </div>

            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button onclick="limpiarFormularioFlota()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Limpiar / Nuevo</button>
                <button onclick="guardarEdicionFlota()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Vehiculo</button>
            </div>
        </div>

        <div class="glass p-6 rounded-xl w-full">
            <div class="overflow-x-auto h-[480px]">
                <table class="w-full text-left text-sm text-slate-300 whitespace-nowrap">
                    <thead class="bg-slate-800 text-[10px] uppercase text-slate-400 font-bold sticky top-0">
                        <tr>
                            <th class="py-3 px-3">Patente</th>
                            <th class="px-3">Tipo</th>
                            <th class="px-3">Empresa / Prov.</th>
                            <th class="px-3">Chofer</th>
                            <th class="px-3">Cap (KGs)</th>
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

    <!-- ZONAS DE DESCARGA -->
    <section id="sZonas" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-2 text-sky-400">Zonas de Descarga</h2>
        <p class="text-xs text-slate-400 mb-4">Conectado a: <span class="text-sky-400">/sites/GestiondeTurnos/Lists/Zonas descarga</span></p>
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700 w-full text-sm">
            <input type="hidden" id="z_item_id">
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
                        <option value="">-</option>
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
                    <label class="block uppercase text-slate-400 font-bold mb-1 text-[10px]">Estado *</label>
                    <select id="z_estado" class="w-full bg-slate-900 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500">
                        <option value="">- Estado -</option>
                        <option value="Activo">Activo</option>
                        <option value="Inactivo">Inactivo</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 flex justify-end gap-3 pt-5 border-t border-slate-700/50">
                <button onclick="limpiarFormularioZona()" class="bg-slate-700 hover:bg-slate-600 text-white px-6 py-2.5 font-bold rounded transition shadow">Limpiar / Nuevo</button>
                <button onclick="guardarEdicionZona()" class="bg-sky-600 hover:bg-sky-500 text-white px-8 py-2.5 font-bold rounded transition shadow">Guardar Zona</button>
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

    <section id="s9" class="tab-content mt-8 w-full">
        <h2 class="text-2xl font-bold mb-4 text-sky-400">Modulo ETL y Auditoria</h2>
        <div class="glass p-6 rounded-xl mb-6 border border-slate-700">
            <div class="flex items-center justify-between mb-4 border-b border-slate-700 pb-3">
                <div>
                    <h3 class="text-base font-bold text-sky-300 uppercase tracking-wider">Estado de Sincronizaciones</h3>
                    <p class="text-xs text-slate-400 mt-1">Lectura y escritura contra las listas y documentos de SharePoint.</p>
                </div>
                <button onclick="sincronizarTodo()" class="bg-sky-700 hover:bg-sky-600 text-white px-5 py-2.5 text-sm font-bold rounded shadow transition">Sincronizar Todo</button>
            </div>
            <div class="grid grid-cols-2 gap-4">
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Padron de Proveedores</div>
                        <div class="text-xs text-slate-400">Documentos/proveedores.csv</div>
                        <div id="sync-status-prov" class="text-xs mt-1.5 font-semibold text-slate-500">Sin sincronizar en esta sesion</div>
                    </div>
                    <button onclick="sincronizarCSVConFeedback('prov')" class="bg-slate-700 hover:bg-slate-600 text-sky-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">Subir CSV</button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Base de Usuarios</div>
                        <div class="text-xs text-slate-400">Documentos/Usuarios.csv</div>
                        <div id="sync-status-usu" class="text-xs mt-1.5 font-semibold text-slate-500">Sin sincronizar en esta sesion</div>
                    </div>
                    <button onclick="sincronizarCSVConFeedback('usu')" class="bg-slate-700 hover:bg-slate-600 text-sky-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">Subir CSV</button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Flota de Vehiculos</div>
                        <div class="text-xs text-slate-400">Lists/Vehiculos</div>
                        <div id="sync-status-flota" class="text-xs mt-1.5 font-semibold text-slate-500">Sin leer en esta sesion</div>
                    </div>
                    <button onclick="sincronizarFlotaConFeedback()" class="bg-slate-700 hover:bg-slate-600 text-emerald-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">Leer SP</button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Zonas de Descarga</div>
                        <div class="text-xs text-slate-400">Lists/Zonas descarga</div>
                        <div id="sync-status-zonas" class="text-xs mt-1.5 font-semibold text-slate-500">Sin leer en esta sesion</div>
                    </div>
                    <button onclick="sincronizarZonasConFeedback()" class="bg-slate-700 hover:bg-slate-600 text-emerald-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">Leer SP</button>
                </div>
                <div class="bg-slate-900 border border-slate-700 rounded-lg p-4 flex items-center justify-between col-span-2">
                    <div>
                        <div class="font-bold text-white text-sm mb-0.5">Lista de Turnos Proveedores</div>
                        <div class="text-xs text-slate-400">Lists/Turnos Proveedores</div>
                        <div id="sync-status-turnos" class="text-xs mt-1.5 font-semibold text-slate-500">Sin leer en esta sesion</div>
                    </div>
                    <button onclick="sincronizarTurnosConFeedback()" class="bg-slate-700 hover:bg-slate-600 text-amber-300 px-4 py-2 text-xs font-bold rounded border border-slate-600 transition">Refrescar Turnos</button>
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
                <div class="flex-1 bg-black/80 rounded border border-slate-700 p-4 text-xs overflow-y-auto" id="etl-log-console" style="color:#4ade80"><div>> Inicializando motor ETL Audit v9.0...</div></div>
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
    const NOMBRES_LISTA_POSIBLES = ['Turnos Proveedores', 'Turnos Proveedores_1'];
    let targetListName = NOMBRES_LISTA_POSIBLES[0];

    // ---- ABM FLOTA -- Lista SharePoint: Vehículos ----
    let LISTA_FLOTA = 'Vehículos'; // El nombre exacto devuelto por Auto-Discovery o fallback
    let LISTA_ZONAS = 'Zonas descarga';

    async function resolverNombreListaTurnos() {
        for (const nombre of NOMBRES_LISTA_POSIBLES) {
            try {
                const url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${nombre}')/items?$top=0`;
                const res = await fetch(url, { headers: { "Accept": "application/json;odata=nometadata" } });
                if (res.ok) { targetListName = nombre; logLog(`[ETL] Lista de Turnos resuelta: "${nombre}"`); return; }
            } catch (e) {}
        }
        logLog(`[WARN] No se pudo confirmar el nombre de la lista al arrancar. Se usara fallback por-llamada.`);
    }

    async function resolverNombresListasExternas() {
        // En base a la URL https://grupocanuelas.sharepoint.com/sites/GestiondeTurnos/Lists/Vehculos/
        // SharePoint frecuentemente elimina las tildes en la URL pero mantiene la tilde en el Title.
        // El array intenta primero con el nombre que dio 404, luego con tilde, etc.
        const candidatosFlota = ['Vehículos', 'Vehculos', 'Vehiculos', 'Vehiculos_1', 'Flota'];
        const candidatosZonas = ['Zonas descarga', 'Zonas de descarga', 'ZonasDescarga', 'Zonas_x0020_descarga'];

        for (let cand of candidatosFlota) {
            try {
                let res = await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${cand}')?$select=Title`, { headers: { "Accept": "application/json;odata=nometadata" }});
                if (res.ok) { LISTA_FLOTA = cand; break; }
            } catch(e) {}
        }
        for (let cand of candidatosZonas) {
            try {
                let res = await fetch(`${relativeSiteUrl}/_api/web/lists/getbytitle('${cand}')?$select=Title`, { headers: { "Accept": "application/json;odata=nometadata" }});
                if (res.ok) { LISTA_ZONAS = cand; break; }
            } catch(e) {}
        }
        logLog(`[API] Listas SP Resueltas: Flota='${LISTA_FLOTA}', Zonas='${LISTA_ZONAS}'`);
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

    async function fetchSPLista(lista, query, options = {}) {
        if (!options.headers) options.headers = { "Accept": "application/json;odata=nometadata" };
        const url = `${relativeSiteUrl}/_api/web/lists/getbytitle('${encodeURIComponent(lista)}')/${query}`;
        return fetch(url, options);
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
            let plantaA = (a.PlantaDescarga || '').toLowerCase(); let plantaB = (b.PlantaDescarga || '').toLowerCase();
            if (plantaA < plantaB) return -1; if (plantaA > plantaB) return 1;
            let fechaA = a.field_6 || ''; let fechaB = b.field_6 || '';
            if (fechaA < fechaB) return -1; if (fechaA > fechaB) return 1;
            let estA = String(a.field_7 || 'pendiente').toLowerCase().trim(); let estB = String(b.field_7 || 'pendiente').toLowerCase().trim();
            let pA = prioridadEst[estA] || 99; let pB = prioridadEst[estB] || 99;
            if (pA < pB) return -1; if (pA > pB) return 1;
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
            if(!skipRefresh) await cargarTurnos(); 
        } catch(e) {
            logLog(`[ERROR ESCRITURA SP]: ${e.message}`);
            showToast("Simulacion Local", "err");
            if(itemId) { let obj = listaTurnosCache.find(x=>x.Id==itemId); if(obj) Object.assign(obj, payload); }
            else listaTurnosCache.unshift({...payload, Id: Math.floor(Math.random()*1000)});
            
            ordenarEstructuralmenteBase(listaTurnosCache); 
            aplicarFiltrosMonitor(); calcularDisponibilidadOffline(); generarResumenDiario(); renderizarResumenCapacidad();
        }
    }

    function setETLStatus(id, texto, tipo) {
        const el = document.getElementById(id);
        if(!el) return;
        el.textContent = texto;
        el.className = `text-xs mt-1.5 font-semibold ${ tipo === 'ok' ? 'text-emerald-400' : tipo === 'err' ? 'text-rose-400' : tipo === 'busy' ? 'text-sky-400 animate-pulse' : 'text-slate-500' }`;
    }

    async function sincronizarCSVConFeedback(tipo) {
        const statusId = tipo === 'prov' ? 'sync-status-prov' : 'sync-status-usu';
        const label    = tipo === 'prov' ? 'Proveedores' : 'Usuarios';
        const cache    = tipo === 'prov' ? listaProveedoresCache : listaUsuariosCache;

        if (cache.length === 0) {
            setETLStatus(statusId, 'Sin registros en memoria para sincronizar.', 'err');
            showToast(`Base de ${label} vacia, no hay nada que subir.`, 'err'); return;
        }
        setETLStatus(statusId, `Subiendo ${cache.length} registros...`, 'busy');
        try {
            await actualizarCSVSharePoint(tipo);
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus(statusId, `OK -- ${cache.length} registros sincronizados a las ${ahora}`, 'ok');
            logLog(`[ETL CSV] ${label}: ${cache.length} registros subidos.`);
        } catch(e) { setETLStatus(statusId, `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarFlotaConFeedback() {
        setETLStatus('sync-status-flota', 'Leyendo desde SharePoint...', 'busy');
        try {
            await cargarFlotaSP();
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-flota', `OK -- ${listaFlotaCache.length} vehiculos a las ${ahora}`, 'ok');
        } catch(e) { setETLStatus('sync-status-flota', `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarZonasConFeedback() {
        setETLStatus('sync-status-zonas', 'Leyendo desde SharePoint...', 'busy');
        try {
            await cargarZonasSP();
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-zonas', `OK -- ${listaZonasCache.length} zonas a las ${ahora}`, 'ok');
        } catch(e) { setETLStatus('sync-status-zonas', `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarTurnosConFeedback() {
        setETLStatus('sync-status-turnos', 'Consultando SharePoint...', 'busy');
        try {
            await cargarTurnos();
            const ahora = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
            setETLStatus('sync-status-turnos', `OK -- ${listaTurnosCache.length} turnos a las ${ahora}`, 'ok');
        } catch(e) { setETLStatus('sync-status-turnos', `Error: ${e.message}`, 'err'); }
    }

    async function sincronizarTodo() {
        showToast('Iniciando sincronizacion completa...', 'ok');
        await sincronizarCSVConFeedback('prov');
        await sincronizarCSVConFeedback('usu');
        await sincronizarFlotaConFeedback();
        await sincronizarZonasConFeedback();
        await sincronizarTurnosConFeedback();
        showToast('Sincronizacion completa finalizada.', 'ok');
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
                csvContent += "Usuario;Responsable;Mail Responsable;Tipo Insumo;Num_Proveedor;Nombre proveedor;Estado;Cuit\n";
                listaProveedoresCache.forEach(p => { csvContent += `${p.usuario};${p.responsable};${p.mail};${p.tipo};${p.id};${p.nombre};${p.estado};${p.cuit || ''}\n`; });
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
            const btns = document.querySelectorAll('.tab-btn[data-target]');
            const contents = document.querySelectorAll('.tab-content');
            const seccionCallbacks = {
                's6':     () => { limpiarFormularioProveedor(); renderizarBaseProveedores(); },
                's7':     () => { limpiarFormularioUsuario();   renderizarBaseUsuarios(); },
                'sFlota': () => { limpiarFormularioFlota();     renderizarBaseFlota(); },
                'sZonas': () => { limpiarFormularioZona();      renderizarBaseZonas(); },
                's8':     () => renderizarABMHorarios(),
                's10':    () => initDashboard(),
            };
            btns.forEach(btn => {
                btn.addEventListener('click', () => {
                    const target = btn.dataset.target;
                    btns.forEach(b => b.classList.remove('active-tab'));
                    btn.classList.add('active-tab');
                    contents.forEach(c => { c.classList.remove('active'); c.style.display = 'none'; });
                    const targetEl = document.getElementById(target);
                    if(targetEl) { targetEl.classList.add('active'); targetEl.style.display = 'block'; }
                    if(seccionCallbacks[target]) { try { seccionCallbacks[target](); } catch(e) {} }
                });
            });
        } catch(e) {}
    }
    setupRuteo();

    let listaTurnosCache = []; let listaUsuariosCache = []; let listaProveedoresCache = []; let listaFlotaCache = []; let listaZonasCache = [];
    let fechaSeleccionadaGlobal = ""; let currentLoggedUser = { name: "Local", email: "logistica@grupocanuelas.com" };
    let _modalProvAbierto = false; const TIPOS_ZONA_CALCULO = ['Insumos', 'Packaging', 'No Productivo'];

    function resetSelectConGuion(selectEl, label) { if (!selectEl) return; selectEl.innerHTML = `<option value="">${label || '-'}</option>`; }
    function asegurarOptionSelect(selectEl, valor, texto) { if (!selectEl || !valor) return; if (!Array.from(selectEl.options).some(o => o.value === valor)) { selectEl.add(new Option(texto || valor, valor)); } selectEl.value = valor; }

    function poblarSelectZonasPorPlanta(plantaFisica, valorSeleccionado) {
        const sel = document.getElementById('f_planta');
        if (!sel) return;
        resetSelectConGuion(sel);
        if (!plantaFisica) return;
        const zonas = listaZonasCache.filter(z => z.estado !== 'Inactivo' && String(z.planta).toLowerCase() === String(plantaFisica).toLowerCase());
        if (zonas.length === 0) { TIPOS_ZONA_CALCULO.forEach(t => sel.add(new Option(t, t))); } 
        else { zonas.forEach(z => { const val = z.tipo || z.nombre; if (val && !Array.from(sel.options).some(o => o.value === val)) { sel.add(new Option(z.nombre || z.tipo, val)); } }); }
        if (valorSeleccionado) asegurarOptionSelect(sel, valorSeleccionado); else sel.selectedIndex = 0;
    }

    function onPlantaFisicaChange() { const pf = document.getElementById('f_planta_descarga')?.value || ''; poblarSelectZonasPorPlanta(pf, ''); handleHorariosChange(); }

    function calcularTurnosTeoricos(plantaConfig, esSabado) {
        if (!plantaConfig || !plantaConfig.duracion) return 0;
        if (esSabado && !plantaConfig.sabado) return 0;
        const hIn = esSabado ? plantaConfig.hInS : plantaConfig.hInLV; const hOut = esSabado ? plantaConfig.hOutS : plantaConfig.hOutLV;
        if (hOut <= hIn) return 0; return Math.floor(((hOut - hIn) * 60) / plantaConfig.duracion);
    }

    function contarZonasActivasPorTipo(plantaId, tipo) {
        const activas = listaZonasCache.filter(z => z.estado !== 'Inactivo' && String(z.planta).toLowerCase() === String(plantaId).toLowerCase() && String(z.tipo).toLowerCase() === String(tipo).toLowerCase());
        if (activas.length === 0) return 1;
        return activas.reduce((sum, z) => sum + (parseInt(z.capacidad, 10) > 0 ? parseInt(z.capacidad, 10) : 1), 0);
    }

    function calcularCapacidadPlantaPorTipo(plantaConfig, esSabado) {
        const slots = calcularTurnosTeoricos(plantaConfig, esSabado); const res = {}; let total = 0;
        TIPOS_ZONA_CALCULO.forEach(tipo => { const mult = contarZonasActivasPorTipo(plantaConfig.id, tipo); const cap = slots * mult; res[tipo] = cap; total += cap; });
        return { slots, porTipo: res, total };
    }

    function esSabadoFecha(fechaStr) { if (!fechaStr) return false; const d = new Date(fechaStr.replace(/-/g, '/') + ' 00:00:00'); return d.getDay() === 6; }

    function renderizarResumenCapacidad() {
        const panel = document.getElementById('panel-resumen-capacidad'); if (!panel) return;
        const pfFiltro = document.getElementById('filtro_planta_descarga')?.value || 'TODAS'; const esSab = esSabadoFecha(fechaSeleccionadaGlobal);
        let html = `<div class="text-[9px] uppercase text-slate-500 font-bold mb-1 text-center">Capacidad ${fechaSeleccionadaGlobal}${esSab ? ' (Sab)' : ' (LV)'}</div>`; let hayDatos = false;
        configPlantas.forEach(p => {
            if (pfFiltro !== 'TODAS' && p.id !== pfFiltro) return;
            const cap = calcularCapacidadPlantaPorTipo(p, esSab); if (cap.slots === 0) return; hayDatos = true;
            TIPOS_ZONA_CALCULO.forEach(tipo => {
                const teo = cap.porTipo[tipo] || 0;
                const ocup = listaTurnosCache.filter(t => t.field_6 && String(t.field_6).startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === p.id && String(t.Planta || '').toLowerCase() === tipo.toLowerCase() && !['cancelado', 'rechazado'].includes(String(t.field_7 || '').toLowerCase())).length;
                const disp = Math.max(0, teo - ocup);
                html += `<div class="flex justify-between gap-1 py-0.5 border-b border-slate-800/50"><span class="text-sky-300 truncate">${escapeHtml(p.id)} / ${tipo}</span><span class="text-slate-400 shrink-0">${teo}|${ocup}|<span class="text-emerald-400 font-bold">${disp}</span></span></div>`;
            });
        });
        panel.innerHTML = hayDatos ? html : '<div class="text-center text-slate-500 text-[10px] py-2">Sin capacidad configurada.</div>';
    }

    function actualizarDatalistFlota() { const dl = document.getElementById('dl_flota_patentes'); if (!dl) return; dl.innerHTML = listaFlotaCache.filter(v => v.estado === 'Habilitado').map(v => `<option value="${escapeHtml(v.patente)}">`).join(''); }

    async function syncFlotaABM() { await cargarFlotaSP(); actualizarDatalistFlota(); showToast(`Flota sincronizada: ${listaFlotaCache.length} vehiculos.`, 'ok'); }

    function autocompletarPatenteFlota() {
        const pat = document.getElementById('f_patente')?.value.trim().toUpperCase(); if (!pat) return; document.getElementById('f_patente').value = pat;
        const v = listaFlotaCache.find(x => String(x.patente).toUpperCase() === pat);
        if (v && v.empresa && !document.getElementById('f_proveedor').value) { showToast(`Patente ${pat} encontrada en flota (${v.empresa}).`, 'ok'); }
    }

    let configPlantas = [
        { id: "Parque Canuelas", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false },
        { id: "Predio Canuelas", hInLV: 10, hOutLV: 17, hInS: 7, hOutS: 11, duracion: 40, sabado: true },
        { id: "Spegazzini", hInLV: 8, hOutLV: 16, hInS: 8, hOutS: 12, duracion: 45, sabado: true },
        { id: "Almar", hInLV: 7, hOutLV: 14, hInS: 7, hOutS: 11, duracion: 30, sabado: true },
        { id: "Metro Mataderos", hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false }
    ];

    function toggleMenuConfig() { const sub = document.getElementById('submenu-config'); const icon = document.getElementById('icon-menu-config'); const abierto = !sub.classList.contains('hidden'); sub.classList.toggle('hidden', abierto); icon.textContent = abierto ? '\u25B6' : '\u25BC'; icon.className = 'text-red-500 text-sm font-bold'; }
    function agregarNuevaPlanta() { const nombre = prompt('Nombre de la nueva Planta Fisica:'); if(!nombre || !nombre.trim()) return; if(configPlantas.find(p => p.id.toLowerCase() === nombre.trim().toLowerCase())) return showToast('Ya existe una planta con ese nombre.', 'err'); configPlantas.push({ id: nombre.trim(), hInLV: 7, hOutLV: 15, hInS: 0, hOutS: 0, duracion: 40, sabado: false }); renderizarABMHorarios(); cargarSelectPlantasFisicas(); showToast(`Planta "${nombre.trim()}" agregada.`, 'ok'); }

    // --- ARRANQUE Y AUTO-SINCRONIZACION ---
    async function initApp() {
        try {
            logLog("====================================="); logLog("Inicializando Core ERP Logistico...");
            const hoy = new Date(); fechaSeleccionadaGlobal = hoy.getFullYear() + "-" + String(hoy.getMonth() + 1).padStart(2, '0') + "-" + String(hoy.getDate()).padStart(2, '0');
            cargarSelectPlantasFisicas(); renderizarABMHorarios(); renderizarGrilaCalendario();
            await testConexion(); await resolverNombresListasExternas(); await resolverNombreListaTurnos();
            limpiarFormularioProveedor(); 
            logLog("[ETL] Disparando hilos asincronos de Sincronizacion de Maestros...");
            Promise.all([
                importarCSVSharePoint('prov', true), importarCSVSharePoint('usu', true), cargarFlotaSP(), cargarZonasSP()
            ]).then(() => {
                poblarSelectsABMInicial(); logLog("[ETL] Disparando carga de Turnos..."); refrescarDBAbsoluto(); 
            });
        } catch (err) { logLog(`[FALLA CRITICA INIT]: ${err.message}`); }
    }

    function obtenerFechaISO(offsetDias = 0) { const d = new Date(); d.setDate(d.getDate() + offsetDias); return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, '0') + "-" + String(d.getDate()).padStart(2, '0'); }
    function aplicarVentanaFechaAlta() { const fFecha = document.getElementById('f_fecha'); if (!fFecha) return; fFecha.min = obtenerFechaISO(0); fFecha.max = obtenerFechaISO(1); }

    function poblarSelectsABMInicial() {
        const selPD = document.getElementById('f_planta_descarga');
        if (selPD) { resetSelectConGuion(selPD); configPlantas.forEach(p => selPD.add(new Option(p.id, p.id))); }
        poblarSelectZonasPorPlanta('', '');
    }

    function cargarSelectPlantasFisicas() {
        const selects = [document.getElementById('f_planta_descarga'), document.getElementById('filtro_planta_descarga'), document.getElementById('u_planta'), document.getElementById('dash_planta'), document.getElementById('z_planta')];
        selects.forEach(s => {
            if(!s) return; let h = '';
            if (s.id.includes('filtro') || s.id.includes('dash')) h = '<option value="TODAS">-- Todas las Plantas --</option>';
            else if (s.id === 'u_planta' || s.id === 'f_planta_descarga' || s.id === 'z_planta') h = '<option value="">-</option>';
            configPlantas.forEach(p => h += `<option value="${p.id}">${p.id}</option>`); s.innerHTML = h;
        });
        poblarSelectZonasPorPlanta(document.getElementById('f_planta_descarga')?.value || '', document.getElementById('f_planta')?.value || '');
    }

    function sincronizarFiltrosYMonitor() {
        const pObj = document.getElementById('filtro_planta_descarga');
        const plantaSelect = pObj ? pObj.value : 'TODAS';
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
        const pd  = document.getElementById('filtro_planta_descarga')?.value || 'TODAS';
        const u   = document.getElementById('filtro_usuario')?.value || 'TODOS';
        const est = document.getElementById('filtro_estado')?.value || 'TODOS';
        const tt  = document.getElementById('filtro_tipo_turno')?.value || 'TODOS';
        const pat = (document.getElementById('filtro_patente')?.value || '').trim().toUpperCase();
        const prov= (document.getElementById('filtro_proveedor')?.value || '').trim().toLowerCase();
        
        let filtrados = listaTurnosCache;
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
        
        renderizarFilas(filtrados); calcularDisponibilidadOffline(); 
    }

    function restablecerFiltros() {
        ['filtro_planta_descarga','filtro_usuario','filtro_estado','filtro_tipo_turno','filtro_patente','filtro_proveedor'].forEach(id => {
            const el = document.getElementById(id); if(!el) return;
            if(el.tagName === 'SELECT') el.selectedIndex = 0; else el.value = '';
        });
        sincronizarFiltrosYMonitor(); 
    }

    async function refrescarDBAbsoluto() { restablecerFiltros(); await cargarTurnos(); }
    async function cargarTurnos() {
        try {
            let res = await fetchSharePoint(`items?$expand=Editor,Author&$select=*,Editor/Title,Author/Title&$orderby=Created desc&$top=1000`);
            if (res.status === 400) { res = await fetchSharePoint(`items?$orderby=Created desc&$top=1000`); }
            if (!res.ok) throw new Error("HTTP " + res.status);
            const data = await res.json();
            listaTurnosCache = data.value || [];
            ordenarEstructuralmenteBase(listaTurnosCache);
            llenarFiltroProveedoresMonitor();
            sincronizarFiltrosYMonitor(); 
            if(document.getElementById('etl-log-console')) logLog(`[ETL] BD Turnos Sincronizada. Registros: ${listaTurnosCache.length}`);
            if(document.getElementById('s10') && document.getElementById('s10').classList.contains('active')) updateDashboard(); 
        } catch (err) { const tb = document.getElementById('tabla-turnos'); if(tb) tb.innerHTML = `<tr><td colspan="8" class="p-6 text-center text-rose-500 font-bold text-sm">Error de conexion.</td></tr>`; }
    }

    function llenarFiltroProveedoresMonitor() {
        const sel = document.getElementById('filtro_proveedor_busq'); if(!sel) return;
        const provs = [...new Set(listaTurnosCache.map(t => t.field_2).filter(Boolean))].sort();
        let h = '<option value="TODOS">-- Todos --</option>'; provs.forEach(p => h += `<option value="${escapeHtml(p)}">${escapeHtml(p)}</option>`); sel.innerHTML = h;
    }

    function calcularDisponibilidadOffline() {
        const panel = document.getElementById('panel-disponibilidad-dinamico'); if(!panel) return;
        const pfSeleccionada = document.getElementById('filtro_planta_descarga')?.value || 'TODAS';
        const estSeleccionado = document.getElementById('filtro_estado') ? document.getElementById('filtro_estado').value : 'TODOS';
        let htmlPanel = '';

        configPlantas.forEach(plantaConfig => {
            if (pfSeleccionada !== 'TODAS' && plantaConfig.id !== pfSeleccionada) return;
            let ocupados = listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(fechaSeleccionadaGlobal) && t.PlantaDescarga === plantaConfig.id && String(t.field_7).toLowerCase() !== 'cancelado' && String(t.field_7).toLowerCase() !== 'rechazado');
            if (estSeleccionado !== 'TODOS') {
                if (estSeleccionado === 'Cancelado') ocupados = []; else ocupados = ocupados.filter(t => String(t.field_7).toLowerCase().includes(estSeleccionado.toLowerCase()));
            }
            let zonasDePlanta = listaZonasCache.filter(z => z.estado !== 'Inactivo' && String(z.planta).toLowerCase() === String(plantaConfig.id).toLowerCase());
            if(zonasDePlanta.length === 0) zonasDePlanta = [{nombre: 'Insumos'}, {nombre: 'Packaging'}, {nombre: 'Materia Prima'}];
            
            let slotsTotales = getSlotsCalculados(plantaConfig.id, fechaSeleccionadaGlobal);
            if (slotsTotales.length > 0) {
                htmlPanel += `<div class="mb-5"><h4 class="text-sm font-bold text-sky-300 uppercase tracking-wider text-center mb-3 bg-sky-950/40 py-2 rounded border border-sky-900/30">${plantaConfig.id}</h4>`;
                zonasDePlanta.forEach(zona => {
                    let turnosZona = ocupados.filter(t => t.Planta === zona.nombre);
                    htmlPanel += `<div class="mb-4 ml-2 border-l-2 border-slate-700 pl-3"><h5 class="text-xs font-bold text-slate-300 uppercase tracking-widest mb-2">${zona.nombre}</h5><div class="space-y-2">`;
                    slotsTotales.forEach(s => {
                        let ocupado = turnosZona.find(t => normalizarStringHorario(t.field_5) === normalizarStringHorario(s));
                        if (ocupado) {
                            let estado = String(ocupado.field_7||'').toLowerCase();
                            const esSobreturno = ocupado.EsSobreturno === true || ocupado.EsSobreturno === 'true' || ocupado.EsSobreturno === 1;
                            let claseBg = 'bg-red-950/30 border-red-900 text-rose-300';
                            if (estado.includes('pendiente')) claseBg = 'bg-amber-900/30 border-amber-600 text-amber-300';
                            if (esSobreturno) claseBg = 'bg-violet-950/40 border-violet-600 text-violet-300';
                            const pat = escapeHtml(ocupado.Patente || 'S/D'); const raz = escapeHtml(ocupado.field_2 || 'S/D'); const rsp = escapeHtml(getResponsableName(ocupado));
                            const tagSobre = esSobreturno ? `<span class="ml-1 text-[9px] uppercase font-bold text-violet-300 bg-violet-900/50 border border-violet-700 px-1 rounded">Sobret.</span>` : '';
                            htmlPanel += `<div class="flex flex-col p-2.5 border ${claseBg} rounded-md text-xs shadow-sm"><div class="flex justify-between mb-1"><span class="font-bold">${s.split(' ')[0]}</span><span class="font-bold tracking-widest bg-black/40 px-2 rounded">${pat}</span></div><div class="flex flex-col text-slate-300 mt-1 gap-1"><span class="truncate font-semibold text-[11px] leading-tight">${raz}${tagSobre}</span><span class="text-sky-400 text-[10px] whitespace-nowrap bg-sky-900/30 px-1.5 py-0.5 rounded w-fit">Resp: ${rsp}</span></div></div>`;
                        } else {
                            htmlPanel += `<div class="flex justify-between items-center p-2.5 border border-emerald-900/80 bg-emerald-950/20 rounded-md text-xs text-emerald-400 shadow-sm opacity-70"><span class="font-bold">${s.split(' ')[0]}</span><span class="font-bold tracking-widest opacity-60">LIBRE</span></div>`;
                        }
                    });
                    htmlPanel += `</div></div>`;
                });
                htmlPanel += `</div>`;
            }
        });
        panel.innerHTML = htmlPanel || '<div class="text-center text-slate-500 text-sm mt-8">Sin agenda para esta configuracion.</div>';
    }

    function renderizarFilas(items) {
        const tbody = document.getElementById('tabla-turnos'); if(!tbody) return;
        if(items.length === 0) { tbody.innerHTML = `<tr><td colspan="8" class="p-6 text-center text-slate-500 text-sm">No hay turnos para estos filtros.</td></tr>`; return; }
        let htmlRows = '';
        items.forEach(t => {
            const estado = escapeHtml(String(t.field_7 || 'Pendiente').trim()); const esAprobado = estado.toLowerCase() === 'aprobado';
            const esSobreturno = t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1;
            let colorEst = esAprobado ? 'text-emerald-400 font-bold' : ((estado.toLowerCase() === 'cancelado' || estado.toLowerCase() === 'rechazado') ? 'text-rose-400' : (estado.toLowerCase() === 'reprogramado' ? 'text-sky-400 font-bold' : 'text-amber-400'));
            const fechaStr = t.field_6 ? String(t.field_6).split('T')[0] : '-';
            const filaClase = esSobreturno ? 'border-b border-slate-700/50 hover:bg-violet-900/30 bg-violet-950/20 text-sm border-l-2 border-l-violet-500' : 'border-b border-slate-700/50 hover:bg-slate-800/30 text-sm';
            const tagSobreturno = esSobreturno ? `<span class="ml-1.5 text-[9px] uppercase font-bold text-violet-300 bg-violet-900/50 border border-violet-700 px-1.5 py-0.5 rounded">Sobreturno</span>` : '';
            const horaIn  = t.HoraIngresoReal  ? `<span class="text-emerald-400 text-[10px] block mt-0.5">${escapeHtml(t.HoraIngresoReal)}</span>`  : '';
            const horaSal = t.HoraSalidaReal   ? `<span class="text-rose-400 text-[10px] block mt-0.5">${escapeHtml(t.HoraSalidaReal)}</span>` : '';
            const botonesTracking = esAprobado ? `<button onclick="marcarTracking(${t.Id},'IN')" title="Registrar Ingreso" class="bg-slate-800 hover:bg-emerald-900/60 text-emerald-400 border border-emerald-900 px-2 py-1 rounded text-[10px] font-bold transition flex flex-col items-center leading-tight">In${horaIn}</button><button onclick="marcarTracking(${t.Id},'OUT')" title="Registrar Salida" class="bg-slate-800 hover:bg-rose-900/60 text-rose-400 border border-rose-900 px-2 py-1 rounded text-[10px] font-bold transition flex flex-col items-center leading-tight">Out${horaSal}</button>` : '';

            htmlRows += `
            <tr class="${filaClase}">
                <td class="p-3 text-sky-400 font-bold">${t.Id}</td>
                <td class="p-3 text-slate-300">${fechaStr}</td>
                <td class="p-3 text-slate-300 font-bold">${escapeHtml(t.PlantaDescarga || '-')}</td>
                <td class="p-3 text-white font-semibold">${escapeHtml(t.field_2 || '-')}${tagSobreturno}</td>
                <td class="p-3 tracking-widest text-slate-300"><span class="bg-black/40 px-2 py-1 rounded">${escapeHtml(t.Patente || '-')}</span></td>
                <td class="p-3 text-amber-300 font-bold">${escapeHtml(t.field_5 || '-')}</td>
                <td class="p-3 ${colorEst} text-center">${estado}<br><span class="text-[10px] text-slate-500 font-normal truncate block max-w-[120px] mx-auto mt-0.5">${escapeHtml(getResponsableName(t))}</span></td>
                <td class="p-3 text-center"><div class="flex justify-center items-center gap-1.5 flex-wrap"><button onclick="modoABM_Ver(${t.Id})" class="bg-sky-700 hover:bg-sky-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Ver</button>${!esAprobado && estado.toLowerCase() !== 'cancelado' && estado.toLowerCase() !== 'rechazado' ? `<button onclick="modoABM_Aprobar(${t.Id})" class="bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded transition text-[10px] uppercase font-bold shadow">Aprobar</button>` : ''}${botonesTracking}</div></td>
            </tr>`;
        });
        tbody.innerHTML = htmlRows;
    }
    function getResponsableName(t) { return t.Author ? t.Author.Title : (t.Editor ? t.Editor.Title : (t.Gestor || 'S/D')); }

    function renderizarGrilaCalendario() {
        const gridContainer = document.getElementById('calendar-days-grid'); if (!gridContainer) return;
        const baseDate = new Date(fechaSeleccionadaGlobal.replace(/-/g, '/') + ' 00:00:00'); const anio = baseDate.getFullYear(); const mes = baseDate.getMonth(); 
        document.getElementById('calendar-month-title').textContent = `${["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"][mes]} ${anio}`;
        let dayOfWeek = new Date(anio, mes, 1).getDay(); let calHtml = ''; 
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
        fechaSeleccionadaGlobal = nuevaFecha; document.getElementById('f_fecha') && (document.getElementById('f_fecha').value = nuevaFecha);
        renderizarGrilaCalendario(); aplicarFiltrosMonitor(); generarResumenDiario(); renderizarResumenCapacidad();
        if(document.getElementById('s10') && document.getElementById('s10').classList.contains('active')) { document.getElementById('dash_fecha').value = nuevaFecha; updateDashboard(); }
    }

    function renderizarABMHorarios() {
        const tb = document.getElementById('tabla-config-horarios'); if(!tb) return; let h = '';
        configPlantas.forEach((p, idx) => {
            let chkSab = p.sabado ? 'checked' : ''; const capLV = calcularCapacidadPlantaPorTipo(p, false); const capSab = calcularCapacidadPlantaPorTipo(p, true);
            const desglose = `${capLV.porTipo['Insumos']||0}/${capLV.porTipo['Packaging']||0}/${capLV.porTipo['No Productivo']||0}`;
            h += `<tr class="text-sm border-b border-slate-700/50">
                <td class="py-3 px-4 font-bold text-sky-400"><input type="text" id="cfg_id_${idx}" value="${p.id}" class="bg-slate-900 border border-slate-700 text-white rounded p-1 w-full outline-none focus:border-sky-500"></td>
                <td class="px-4"><input type="number" id="cfg_inlv_${idx}" value="${p.hInLV}" oninput="previewHorariosConfig()" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white"> a <input type="number" id="cfg_outlv_${idx}" value="${p.hOutLV}" oninput="previewHorariosConfig()" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white"></td>
                <td class="px-4"><label class="mr-3"><input type="checkbox" id="cfg_sab_${idx}" ${chkSab} onchange="toggleSabado(${idx}); previewHorariosConfig();"> Hab.</label><input type="number" id="cfg_ins_${idx}" value="${p.hInS}" oninput="previewHorariosConfig()" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white ${!p.sabado ? 'opacity-30' : ''}" ${!p.sabado ? 'disabled' : ''}> a <input type="number" id="cfg_outs_${idx}" value="${p.hOutS}" oninput="previewHorariosConfig()" class="w-14 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white ${!p.sabado ? 'opacity-30' : ''}" ${!p.sabado ? 'disabled' : ''}></td>
                <td class="px-4"><input type="number" id="cfg_dur_${idx}" value="${p.duracion}" oninput="previewHorariosConfig()" class="w-16 bg-slate-900 border border-slate-700 text-center rounded p-1 text-white"></td>
                <td class="px-4 text-center text-emerald-400 font-bold" id="cfg_prev_lv_${idx}">${capLV.slots}</td><td class="px-4 text-center text-amber-400 font-bold" id="cfg_prev_sab_${idx}">${capSab.slots}</td><td class="px-4 text-center text-slate-300 text-xs" id="cfg_prev_tip_${idx}">${desglose}</td><td class="px-4 text-center text-sky-300 font-bold" id="cfg_prev_tot_${idx}">${capLV.total}</td><td class="px-4 text-center text-slate-500">OK</td></tr>`;
        });
        tb.innerHTML = h;
    }

    function previewHorariosConfig() {
        configPlantas.forEach((p, idx) => {
            const dur = parseInt(document.getElementById(`cfg_dur_${idx}`)?.value, 10) || p.duracion;
            const tmp = {
                id: p.id, hInLV: parseInt(document.getElementById(`cfg_inlv_${idx}`)?.value, 10) || p.hInLV, hOutLV: parseInt(document.getElementById(`cfg_outlv_${idx}`)?.value, 10) || p.hOutLV, hInS: parseInt(document.getElementById(`cfg_ins_${idx}`)?.value, 10) || p.hInS, hOutS: parseInt(document.getElementById(`cfg_outs_${idx}`)?.value, 10) || p.hOutS, duracion: dur < 10 ? 10 : dur, sabado: document.getElementById(`cfg_sab_${idx}`)?.checked || false
            };
            const capLV = calcularCapacidadPlantaPorTipo(tmp, false); const capSab = calcularCapacidadPlantaPorTipo(tmp, true);
            const elLv = document.getElementById(`cfg_prev_lv_${idx}`); const elSab = document.getElementById(`cfg_prev_sab_${idx}`); const elTip = document.getElementById(`cfg_prev_tip_${idx}`); const elTot = document.getElementById(`cfg_prev_tot_${idx}`);
            if (elLv) elLv.textContent = capLV.slots; if (elSab) elSab.textContent = capSab.slots;
            if (elTip) elTip.textContent = `${capLV.porTipo['Insumos']||0}/${capLV.porTipo['Packaging']||0}/${capLV.porTipo['No Productivo']||0}`; if (elTot) elTot.textContent = capLV.total;
        });
    }

    function toggleSabado(idx) {
        let isChk = document.getElementById(`cfg_sab_${idx}`).checked;
        document.getElementById(`cfg_ins_${idx}`).disabled = !isChk; document.getElementById(`cfg_outs_${idx}`).disabled = !isChk;
        document.getElementById(`cfg_ins_${idx}`).classList.toggle('opacity-30', !isChk); document.getElementById(`cfg_outs_${idx}`).classList.toggle('opacity-30', !isChk);
    }
    function guardarConfiguracionHorarios() {
        configPlantas.forEach((p, idx) => {
            let dur = parseInt(document.getElementById(`cfg_dur_${idx}`).value) || 30; p.duracion = dur < 10 ? 10 : dur; 
            p.hInLV = parseInt(document.getElementById(`cfg_inlv_${idx}`).value) || 7; p.hOutLV = Math.max(p.hInLV + 1, parseInt(document.getElementById(`cfg_outlv_${idx}`).value) || 15);
            p.sabado = document.getElementById(`cfg_sab_${idx}`).checked;
            p.hInS = parseInt(document.getElementById(`cfg_ins_${idx}`).value) || 0; p.hOutS = Math.max(p.hInS, parseInt(document.getElementById(`cfg_outs_${idx}`).value) || 0);
        });
        showToast("Configuracion Guardada", "ok"); handleHorariosChange(); calcularDisponibilidadOffline(); renderizarResumenCapacidad(); renderizarABMHorarios();
    }

    function getSlotsCalculados(plantaId, fechaStr) {
        let slots = []; if(!fechaStr || !plantaId) return slots;
        let pConf = configPlantas.find(p => p.id === plantaId); if (!pConf) return slots;
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
        const fVal = document.getElementById('f_fecha').value; if (!fVal) return;
        document.getElementById('f_dia').textContent = ['Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado'][new Date(fVal.replace(/-/g, '/') + ' 00:00:00').getDay()];
    }

    let modoABMActual = null;
    function handleHorariosChange() { const filtrar = (modoABMActual === 'ALTA' || modoABMActual === 'REPROGRAMAR'); regenerarHorariosABM(filtrar); autoDia(); }
    function regenerarHorariosABM(modoFiltro = false) {
        const pf = document.getElementById('f_planta_descarga').value; const zona = document.getElementById('f_planta').value; const f = document.getElementById('f_fecha').value; const sel = document.getElementById('f_horario');
        if(!sel) return; sel.innerHTML = '';
        if(!pf) { sel.innerHTML = '<option value="">-</option>'; return; }
        if(!f) { sel.innerHTML = '<option value="">Seleccione fecha</option>'; return; }
        if(!zona) { sel.innerHTML = '<option value="">Seleccione zona</option>'; return; }
        let allSlots = getSlotsCalculados(pf, f);
        if(allSlots.length === 0) { sel.innerHTML = '<option value="">Sin Operacion</option>'; return; }
        let oc = modoFiltro ? listaTurnosCache.filter(t => t.field_6 && t.field_6.startsWith(f) && t.PlantaDescarga === pf && t.Planta === zona && String(t.field_7).toLowerCase() !== 'cancelado' && String(t.field_7).toLowerCase() !== 'rechazado').map(t => normalizarStringHorario(t.field_5)) : [];
        let htmlOpts = '';
        allSlots.forEach(s => { if (!(modoFiltro && oc.includes(normalizarStringHorario(s)))) htmlOpts += `<option value="${s}">${s}</option>`; });
        sel.innerHTML = htmlOpts === '' ? '<option value="">Agenda Completa</option>' : htmlOpts;
    }

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
        const provEnBD = listaProveedoresCache.find(p => p.id === cuitLimpio || p.cuit === cuitLimpio);
        if(!provEnBD && listaProveedoresCache.length > 0) return marcarError('f_cuit', "Proveedor no existe.");
        if(provEnBD && provEnBD.estado !== 'Habilitado') return marcarError('f_cuit', "Proveedor inhabilitado.");
        if(!fProv) return marcarError('f_proveedor', "Razon Social vacia.");
        if(fEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fEmail)) return marcarError('f_email', "Email invalido.");
        if(!fFec) return marcarError('f_fecha', "Fecha requerida.");
        const fPlanta = document.getElementById('f_planta_descarga').value; const fZona = document.getElementById('f_planta').value;
        if(!fPlanta) return marcarError('f_planta_descarga', "Seleccione Planta Fisica.");
        if(!fZona) return marcarError('f_planta', "Seleccione Zona de Descarga.");
        if(modo === 'ALTA' || modo === 'REPROGRAMAR') {
            const hoy = new Date(); hoy.setHours(0,0,0,0); const maxHabilitada = new Date(); maxHabilitada.setDate(maxHabilitada.getDate() + 1); maxHabilitada.setHours(0,0,0,0);
            const fechaIngresada = new Date(fFec.replace(/-/g, '/') + ' 00:00:00');
            if(fechaIngresada < hoy) return marcarError('f_fecha', "Fecha pasada.");
            if(fechaIngresada > maxHabilitada) return marcarError('f_fecha', "Solo se permiten Altas/Reprogramaciones para hoy o manana.");
        }
        if(!fHor) return marcarError('f_horario', "Seleccione horario libre.");
        return true;
    }

    async function checkSlotLibreConcurrencia(planta, zona, fecha, slot) {
        try { const res = await fetchSharePoint(`items?$filter=PlantaDescarga eq '${planta}' and Planta eq '${zona}' and startswith(field_6, '${fecha}') and field_5 eq '${slot}' and field_7 ne 'Cancelado' and field_7 ne 'Rechazado'&$select=Id`); if(res.ok) { const data = await res.json(); return data.value.length === 0; } } catch(e) {} 
        return true;
    }

    function mostrarBannerABM(id, modo) {
        const banner = document.getElementById('abm-mensaje-estado'); banner.classList.remove('hidden');
        if(modo === 'VER') { banner.className = "text-sm font-bold px-4 py-3 rounded-lg mb-4 shadow-sm bg-sky-900/50 text-sky-300 border border-sky-700 block"; banner.textContent = `Turno ID ${id} en modo consulta. Use los botones para Modificar o Eliminar.`; } 
        else if (modo === 'APROBAR') { banner.className = "text-sm font-bold px-4 py-3 rounded-lg mb-4 shadow-sm bg-amber-900/50 text-amber-300 border border-amber-700 block"; banner.textContent = `Turno ID ${id} listo para aprobacion o reprogramacion.`; }
    }

    function abrirAltaTurno() {
        limpiarFormularioABM(); poblarSelectsABMInicial();
        document.getElementById('f_fecha').value = ''; document.getElementById('f_dia').textContent = '-'; document.getElementById('f_horario').innerHTML = '<option value="">-</option>';
        aplicarVentanaFechaAlta(); document.getElementById('f_usuario_gestor').textContent = escapeHtml(currentLoggedUser.name || 'S/D');
        cargarFlotaSP().then(() => actualizarDatalistFlota()).catch(() => {});
        document.getElementById('btn-modo-modificar').classList.add('hidden');
        document.getElementById('form-mode-indicator').textContent = "ALTA DE TURNO"; document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-emerald-900/50 text-emerald-400 border border-emerald-800 rounded-md font-bold tracking-wide";
        habilitarCamposABM(true); renderBotonesABM('ALTA'); document.getElementById('btn-tab-abm').click();
    }
    
    function modoABM_Ver(id) {
        document.getElementById('btn-tab-abm').click(); const t = listaTurnosCache.find(x => x.Id == id); const est = String(t.field_7 || 'PENDIENTE').trim().toUpperCase();
        cargarTurnoEnFormulario(id, 'VER'); mostrarBannerABM(id, 'VER'); habilitarCamposABM(false); 
        if (est === 'PENDIENTE') {
            document.getElementById('f_planta_descarga').innerHTML = '<option value="">Seleccione Planta</option>'; document.getElementById('f_planta').innerHTML = '<option value="">Seleccione Zona</option>';
            document.getElementById('btn-modo-modificar').classList.remove('hidden'); document.getElementById('form-mode-indicator').textContent = `CONSULTA LECTURA`;
            renderBotonesABM('VER_PENDIENTE', est);
        } else {
            document.getElementById('btn-modo-modificar').classList.add('hidden'); document.getElementById('form-mode-indicator').textContent = `CONSULTA LECTURA`;
            renderBotonesABM('VER', est);
        }
        document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-slate-800 text-slate-300 rounded-md font-bold border border-slate-600 tracking-wide flex items-center";
    }
    
    function modoABM_Modificar() {
        const id = document.getElementById('f_item_id').value; document.getElementById('abm-mensaje-estado').className = "hidden"; cargarTurnoEnFormulario(id, 'MODIFICAR');
        document.getElementById('btn-modo-modificar').classList.add('hidden'); document.getElementById('form-mode-indicator').innerHTML = `MODIFICANDO TURNO N&deg; ${id}`; document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-amber-900/50 text-amber-400 border border-amber-700 rounded-md font-bold tracking-wide flex items-center";
        habilitarCamposABM(true); renderBotonesABM('MODIFICANDO');
    }

    function modoABM_Aprobar(id) {
        cargarTurnoEnFormulario(id, 'APROBAR_PANEL'); document.getElementById('btn-modo-modificar').classList.add('hidden');
        document.getElementById('form-mode-indicator').textContent = "MODO APROBACION"; document.getElementById('form-mode-indicator').className = "text-xs uppercase px-3 py-1.5 bg-amber-900/50 text-amber-400 border border-amber-700 rounded-md font-bold tracking-wide";
        mostrarBannerABM(id, 'APROBAR'); habilitarCamposABM(false); renderBotonesABM('APROBAR_PANEL'); document.getElementById('btn-tab-abm').click();
    }
    
    function modoABM_Reprogramar() {
        document.getElementById('form-mode-indicator').textContent = "REPROGRAMACION"; document.getElementById('abm-mensaje-estado').className = "hidden"; document.getElementById('btn-modo-modificar').classList.add('hidden');
        habilitarCamposABM(false); document.getElementById('f_fecha').disabled = false; aplicarVentanaFechaAlta(); document.getElementById('f_horario').disabled = false;
        handleHorariosChange(); renderBotonesABM('REPROGRAMAR');
    }
    
    function volverTurnosDiarios() { modoABMActual = null; cerrarModalNuevoProveedor(); document.getElementById('btn-modo-modificar').classList.add('hidden'); document.getElementById('btn-tab-monitor').click(); }
    
    function habilitarCamposABM(estado) { document.querySelectorAll('.f-control').forEach(el => el.disabled = !estado); }

    function setModoIndicador(texto, claseColor, modo) { modoABMActual = modo || null; const ind = document.getElementById('form-mode-indicator'); if(!ind) return; ind.textContent = texto; ind.className = `text-xs uppercase px-3 py-1.5 rounded-full font-bold border min-w-[120px] text-center ${claseColor}`; }

    function renderBotonesABM(modo, estadoStr = '') {
        const panel = document.getElementById('panel-botones-abm'); if(!panel) return;
        if (modo === 'ALTA') { setModoIndicador('ALTA DE TURNO','bg-emerald-900 text-emerald-300 border-emerald-700', 'ALTA'); panel.innerHTML = `<button onclick="crearTurno()" class="bg-sky-600 hover:bg-sky-500 px-8 py-3 font-bold rounded-lg text-white transition shadow-sm flex items-center justify-center gap-2 flex-1">Registrar Alta</button><button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; } 
        else if (modo === 'VER_PENDIENTE' || modo === 'VER') { setModoIndicador('CONSULTA','bg-sky-900 text-sky-300 border-sky-700', 'VER'); panel.innerHTML = `<button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Cancelar / Volver</button>`; } 
        else if (modo === 'MODIFICANDO') { setModoIndicador('MODIFICANDO','bg-amber-900 text-amber-300 border-amber-700', 'MODIFICAR'); panel.innerHTML = `<button onclick="guardarModificacionTurno()" class="bg-amber-600 hover:bg-amber-500 px-8 py-3 font-bold rounded-lg text-white transition shadow-sm flex-1">Guardar Modificacion</button><button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-6 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; } 
        else if (modo === 'APROBAR_PANEL') { setModoIndicador('APROBACION','bg-emerald-900 text-emerald-300 border-emerald-700', 'APROBAR_PANEL'); panel.innerHTML = `<button onclick="ejecutarAccionFlujo('Aprobado')" class="bg-emerald-600 hover:bg-emerald-500 px-4 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Aprobar</button><button onclick="ejecutarAccionFlujo('Cancelado')" class="bg-rose-600 hover:bg-rose-500 px-4 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Cancelar Turno</button><button onclick="modoABM_Reprogramar()" class="bg-amber-600 hover:bg-amber-500 px-4 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Reprogramar</button><button onclick="volverTurnosDiarios()" class="bg-slate-700 hover:bg-slate-600 px-4 py-3 font-bold rounded-lg text-white transition shadow-sm">Volver al Monitor</button>`; } 
        else if (modo === 'REPROGRAMAR') { setModoIndicador('REPROGRAMACION','bg-indigo-900 text-indigo-300 border-indigo-700', 'REPROGRAMAR'); panel.innerHTML = `<button onclick="ejecutarReprogramacion()" class="bg-indigo-600 hover:bg-indigo-500 px-6 py-3 font-bold rounded-lg text-white flex-1 transition shadow-sm">Confirmar</button><button onclick="modoABM_Ver(document.getElementById('f_item_id').value)" class="bg-slate-700 hover:bg-slate-600 px-4 py-3 font-bold rounded-lg text-white transition shadow-sm">Cancelar</button>`; }
    }

    function cargarTurnoEnFormulario(id, modo) {
        const t = listaTurnosCache.find(item => item.Id === parseInt(id)); if (!t) return;
        const modoActual = modo || modoABMActual || 'VER'; limpiarErroresVisuales();
        document.getElementById('f_item_id').value = t.Id; document.getElementById('f_patente').value = t.Patente || ''; document.getElementById('f_hora_ing').value = t.HoraIngresoReal || '';
        document.getElementById('f_hora_sal').value = t.HoraSalidaReal || ''; document.getElementById('f_cuit').value = t.field_1 || ''; document.getElementById('f_oc').value = t.N_x00b0__x0020_de_x0020_OC || ''; document.getElementById('f_proveedor').value = t.field_2 || '';
        document.getElementById('f_email').value = t.field_3 || ''; if (t.field_6) document.getElementById('f_fecha').value = String(t.field_6).split('T')[0];
        autoDia();

        const selPD = document.getElementById('f_planta_descarga'); resetSelectConGuion(selPD); configPlantas.forEach(p => selPD.add(new Option(p.id, p.id)));
        const mostrarValoresGuardados = (modoActual === 'VER' || modoActual === 'APROBAR_PANEL');
        if (mostrarValoresGuardados) { asegurarOptionSelect(selPD, t.PlantaDescarga); poblarSelectZonasPorPlanta(t.PlantaDescarga, t.Planta); } 
        else if (modoActual === 'MODIFICAR' || modoActual === 'REPROGRAMAR') { if (t.PlantaDescarga) { asegurarOptionSelect(selPD, t.PlantaDescarga); poblarSelectZonasPorPlanta(t.PlantaDescarga, t.Planta); } else { selPD.selectedIndex = 0; poblarSelectZonasPorPlanta('', ''); } } 
        else { selPD.selectedIndex = 0; poblarSelectZonasPorPlanta('', ''); }

        document.getElementById('f_sobreturno').checked = (t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1);
        regenerarHorariosABM(modoActual === 'ALTA' || modoActual === 'REPROGRAMAR');
        let slotSelect = document.getElementById('f_horario'); if(t.field_5 && !Array.from(slotSelect.options).some(opt => opt.value === t.field_5)) slotSelect.add(new Option(t.field_5 + ' (Asignado)', t.field_5));
        slotSelect.value = t.field_5 || '';
        document.getElementById('f_usuario_gestor').textContent = escapeHtml(getResponsableName(t));
        const est = String(t.field_7 || 'PENDIENTE').trim().toUpperCase(); document.getElementById('f_estado_actual').textContent = est;
        
        const trackEnab = (est === 'APROBADO' || est === 'REPROGRAMADO'); document.getElementById('btn-track-in').disabled = !trackEnab; document.getElementById('btn-track-out').disabled = !trackEnab;
    }

    function limpiarFormularioABM() {
        limpiarErroresVisuales(); document.getElementById('abm-mensaje-estado').className = "hidden"; document.getElementById('f_item_id').value = '';
        ['f_planta_descarga', 'f_planta'].forEach(id => { const sel = document.getElementById(id); if (sel && sel.options.length > 0 && sel.options[0].value === '') sel.remove(0); });
        document.querySelectorAll('.f-control').forEach(i => { if (i.tagName === 'SELECT') { if (i.id === 'f_horario') i.innerHTML = '<option value="">-</option>'; else if (i.selectedIndex >= 0) i.selectedIndex = 0; } else if (i.type === 'checkbox') i.checked = false; else i.value = ''; i.disabled = true; });
        document.getElementById('f_fecha').min = ''; document.getElementById('f_fecha').max = ''; document.getElementById('f_dia').textContent = '-'; document.getElementById('f_usuario_gestor').textContent = '-'; document.getElementById('f_estado_actual').textContent = 'NUEVO'; document.getElementById('panel-botones-abm').innerHTML = '';
    }

    async function crearTurno() {
        if(!validarFormularioTurno('ALTA')) return;
        const pf = document.getElementById('f_planta_descarga').value; const zona = document.getElementById('f_planta').value; const fc = document.getElementById('f_fecha').value; const sh = document.getElementById('f_horario').value;
        const libre = await checkSlotLibreConcurrencia(pf, zona, fc, sh);
        if(!libre && !document.getElementById('f_sobreturno').checked) return marcarError('f_horario', "Slot ocupado. Utilice opcion de Sobreturno.");

        const payload = {
            field_1: document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''), field_2: document.getElementById('f_proveedor').value.trim(), field_3: document.getElementById('f_email').value.trim(),
            field_5: sh, field_6: fc + "T00:00:00Z", field_7: "Pendiente", N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, PlantaDescarga: pf, Dia: document.getElementById('f_dia').textContent, Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            EsSobreturno: document.getElementById('f_sobreturno').checked
        };
        await ejecutarTransaccion(null, payload, "Turno Creado"); volverTurnosDiarios();
    }

    async function ejecutarModificacion() {
        if(!validarFormularioTurno('REPROGRAMAR')) return; 
        const id = document.getElementById('f_item_id').value;
        const payload = {
            field_1: document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''), field_2: document.getElementById('f_proveedor').value.trim(), field_3: document.getElementById('f_email').value.trim(),
            field_5: document.getElementById('f_horario').value, field_6: document.getElementById('f_fecha').value + "T00:00:00Z", N_x00b0__x0020_de_x0020_OC: document.getElementById('f_oc').value.trim(),
            Planta: document.getElementById('f_planta').value, PlantaDescarga: document.getElementById('f_planta_descarga').value, Dia: document.getElementById('f_dia').textContent, Patente: document.getElementById('f_patente').value.trim().toUpperCase(),
            EsSobreturno: document.getElementById('f_sobreturno').checked
        };
        await ejecutarTransaccion(id, payload, "Turno Modificado"); volverTurnosDiarios();
    }

    async function ejecutarAccionFlujo(nuevoEstado) {
        const id = document.getElementById('f_item_id').value; const email = document.getElementById('f_email').value; const t = listaTurnosCache.find(x => x.Id == id);
        if(t && String(t.field_7).toLowerCase() === 'cancelado' && nuevoEstado !== 'Cancelado') return showToast("El turno ya fue cancelado.", "err");
        await ejecutarTransaccion(id, { field_7: nuevoEstado }, `Turno ${nuevoEstado}`);
        
        if (email) {
            const responsable = getResponsableName(t); const userObj = listaUsuariosCache.find(u => u.nombre === responsable); const cc = userObj && userObj.email ? `&cc=${userObj.email}` : '';
            let body = `Su turno logistico ha sido ${nuevoEstado.toUpperCase()}.\nFecha: ${document.getElementById('f_fecha').value}\nHorario: ${document.getElementById('f_horario').value}\n\nEnviado por: ${responsable}`;
            window.location.href = `mailto:${email}?subject=Estado Turno: ${nuevoEstado}${cc}&body=${encodeURIComponent(body)}`;
        }
        volverTurnosDiarios();
    }

    async function ejecutarReprogramacion() {
        if(!validarFormularioTurno('REPROGRAMAR')) return;
        const id = document.getElementById('f_item_id').value; const pf = document.getElementById('f_planta_descarga').value; const zona = document.getElementById('f_planta').value; const fc = document.getElementById('f_fecha').value; const sh = document.getElementById('f_horario').value;
        const libre = await checkSlotLibreConcurrencia(pf, zona, fc, sh);
        if(!libre && !document.getElementById('f_sobreturno').checked) return marcarError('f_horario', "Slot ocupado.");
        await ejecutarTransaccion(id, { field_6: fc + "T00:00:00Z", field_5: sh, field_7: "Reprogramado" }, "Turno Reprogramado");
        volverTurnosDiarios();
    }

    async function marcarTrackingForm(tipo) {
        if(tipo === 'OUT') {
            const hIn = document.getElementById('f_hora_ing').value;
            if(!hIn) return showToast("No puede cargar horario de salida ya que no hay un horario de ingreso informado", "err");
        }
        const id = document.getElementById('f_item_id').value; const horaStr = new Date().toLocaleTimeString('es-AR', {hour: '2-digit', minute:'2-digit'});
        let payload = {}; if(tipo === 'IN') { payload.HoraIngresoReal = horaStr; document.getElementById('f_hora_ing').value = horaStr; } if(tipo === 'OUT') { payload.HoraSalidaReal = horaStr; document.getElementById('f_hora_sal').value = horaStr; }
        await ejecutarTransaccion(id, payload, `Check-${tipo} Registrado`, true);
    }

    async function marcarTracking(itemId, tipo) {
        if (!itemId) return showToast("Sin ID de turno.", "err");
        if(tipo === 'OUT') {
            const obj = listaTurnosCache.find(x => x.Id === parseInt(itemId));
            if(!obj || !obj.HoraIngresoReal) return showToast("No puede cargar horario de salida ya que no hay un horario de ingreso informado.", "err");
        }
        const horaStr = new Date().toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' });
        let payload = {}; if (tipo === 'IN') payload.HoraIngresoReal = horaStr; if (tipo === 'OUT') payload.HoraSalidaReal = horaStr;
        const obj = listaTurnosCache.find(x => x.Id === parseInt(itemId)); if (obj) Object.assign(obj, payload); aplicarFiltrosMonitor();
        await ejecutarTransaccion(itemId, payload, `Check-${tipo} OK (${horaStr})`, true);
    }

    function llenarComboResponsablesProv() {
        const select = document.getElementById('p_resp'); if(!select) return; let currentVal = select.value; let html = '<option value="">-- Seleccione --</option>';
        const activos = listaUsuariosCache.filter(u => u.estado !== 'Deshabilitado'); activos.forEach(u => { html += `<option value="${escapeHtml(u.nombre)}">${escapeHtml(u.nombre)}</option>`; });
        select.innerHTML = html; if(currentVal) select.value = currentVal;
    }

    function autoCompletarMailResp() {
        const respNombre = document.getElementById('p_resp').value; const user = listaUsuariosCache.find(u => u.nombre === respNombre); document.getElementById('p_mail').value = user ? user.email : '';
    }

    // --- ABM PROVEEDORES ---
    function parsearCSVProveedores(text) {
        const lines = text.split(/\r?\n|\r/); listaProveedoresCache = [];
        const headerLine = lines[0] ? lines[0].replace(/^\uFEFF/, '').trim() : ''; const headerCols = headerLine.split(/;/).map(h => h.trim().toLowerCase());
        const iUsuario = headerCols.findIndex(h => h.startsWith('usuario')); const iResp = headerCols.findIndex(h => h.startsWith('responsable')); const iMail = headerCols.findIndex(h => h.includes('mail') || h.includes('email')); const iTipo = headerCols.findIndex(h => h.startsWith('tipo'));
        const iNum = headerCols.findIndex(h => h.startsWith('num') || h === 'id'); const iNombre = headerCols.findIndex((h, i) => i !== iNum && (h.includes('nombre') || h.includes('razon'))); const iEstado = headerCols.findIndex(h => h === 'estado'); const iCuit = headerCols.findIndex(h => h === 'cuit');
        const usarHeader = iNum >= 0 && iNombre >= 0;

        for (let i = 1; i < lines.length; i++) {
            const row = lines[i].trim(); if (!row) continue; const cols = row.split(/;/);
            if (usarHeader) {
                listaProveedoresCache.push({ usuario: (cols[iUsuario >= 0 ? iUsuario : 0] || '').trim(), responsable: (cols[iResp >= 0 ? iResp : 1] || '').trim(), mail: (cols[iMail >= 0 ? iMail : 2] || '').trim(), tipo: (cols[iTipo >= 0 ? iTipo : 3] || '').trim(), id: (cols[iNum] || '').replace(/[^0-9]/g, ''), nombre: (cols[iNombre] || '').trim(), estado: (iEstado >= 0 ? (cols[iEstado] || 'Habilitado').trim() : 'Habilitado') || 'Habilitado', cuit: (iCuit >= 0 ? (cols[iCuit] || '').replace(/[^0-9\-]/g, '') : '') });
            } else if (cols.length === 7) {
                listaProveedoresCache.push({ usuario: cols[0].trim(), responsable: cols[1].trim(), mail: cols[2].trim(), tipo: cols[3].trim(), id: cols[4].replace(/[^0-9]/g, ''), cuit: '', nombre: cols[5].trim(), estado: cols[6].trim() || 'Habilitado' });
            } else if (cols.length >= 8) {
                listaProveedoresCache.push({ usuario: cols[0].trim(), responsable: cols[1].trim(), mail: cols[2].trim(), tipo: cols[3].trim(), id: cols[4].replace(/[^0-9]/g, ''), nombre: cols[5].trim(), estado: cols[6].trim() || 'Habilitado', cuit: cols[7].replace(/[^0-9\-]/g, '') });
            }
        }
        renderizarBaseProveedores();
    }

    function renderizarBaseProveedores() {
        const tb = document.getElementById('tabla-proveedores'); if(!tb) return;
        tb.innerHTML = listaProveedoresCache.map((p, idx) => `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarProvForm(${idx})"><td class="p-3 text-slate-300">${escapeHtml(p.usuario)}</td><td class="p-3 text-slate-400">${escapeHtml(p.responsable)}</td><td class="p-3 text-amber-400 font-bold">${escapeHtml(p.id)}</td><td class="p-3 text-amber-400 font-bold">${escapeHtml(p.cuit || '-')}</td><td class="p-3 text-white font-semibold">${escapeHtml(p.nombre)}</td><td class="p-3 text-slate-400">${escapeHtml(p.tipo)}</td><td class="p-3 font-bold ${p.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(p.estado)}</td><td class="p-3 text-sky-400 underline text-center">Editar</td></tr>`).join('');
    }

    function cargarProvForm(idx) {
        const p = listaProveedoresCache[idx]; document.getElementById('p_index').value = idx; document.getElementById('p_usuario').value = p.usuario || currentLoggedUser.name; document.getElementById('p_resp').value = p.responsable; document.getElementById('p_mail').value = p.mail; document.getElementById('p_tipo').value = p.tipo; document.getElementById('p_num_prov').value = p.id; document.getElementById('p_cuit').value = p.cuit || ''; document.getElementById('p_razon').value = p.nombre; document.getElementById('p_estado').value = p.estado || 'Habilitado';
    }

    function limpiarFormularioProveedor() {
        document.getElementById('p_index').value = ''; document.getElementById('p_usuario').value = currentLoggedUser.name || ''; document.getElementById('p_resp').selectedIndex = 0; document.getElementById('p_mail').value = ''; document.getElementById('p_cuit').value = ''; document.getElementById('p_num_prov').value = ''; document.getElementById('p_razon').value = ''; document.getElementById('p_tipo').value = ''; document.getElementById('p_estado').value = 'Habilitado';
    }

    async function guardarEdicionProveedor() {
        const idx = document.getElementById('p_index').value; const pNum = document.getElementById('p_num_prov').value.replace(/[^0-9]/g, ''); const pCuit = document.getElementById('p_cuit').value.replace(/[^0-9\-]/g, '');
        if(!pNum) return showToast("Falta Num Proveedor", "err");
        const obj = { usuario: document.getElementById('p_usuario').value, responsable: document.getElementById('p_resp').value, mail: document.getElementById('p_mail').value, tipo: document.getElementById('p_tipo').value, id: pNum, cuit: pCuit, nombre: document.getElementById('p_razon').value, estado: document.getElementById('p_estado').value };
        if(idx === '') listaProveedoresCache.push(obj); else listaProveedoresCache[idx] = obj;
        renderizarBaseProveedores(); limpiarFormularioProveedor(); showToast("Proveedor Guardado", "ok"); await actualizarCSVSharePoint('prov');
        if (window.returnToTurnoForm) { window.returnToTurnoForm = false; document.querySelector('[data-target="s1"]').click(); autocompletarProveedor(); }
    }

    function abrirModalNuevoProveedor(cuitPrecargado) {
        if (_modalProvAbierto) return; _modalProvAbierto = true; limpiarErroresVisuales();
        let modal = document.getElementById('modal-nuevo-prov'); if(modal) modal.remove();
        modal = document.createElement('div'); modal.id = 'modal-nuevo-prov'; modal.className = 'fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm';
        modal.innerHTML = `
            <div class="bg-slate-900 border border-slate-600 rounded-2xl p-8 w-full max-w-lg shadow-2xl">
                <h3 class="text-lg font-bold text-sky-400 mb-1">Nuevo Proveedor</h3>
                <p class="text-xs text-slate-400 mb-5">El CUIT ingresado no existe en el padron. Complete los datos para registrarlo y continuar con el Alta del Turno.</p>
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Num Prov (ID)</label><input id="mnp_id" type="text" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none focus:border-sky-500" placeholder="Ej: 12345"></div>
                        <div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">CUIT</label><input id="mnp_cuit" type="text" value="${escapeHtml(cuitPrecargado)}" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-amber-300 font-bold rounded outline-none focus:border-sky-500"></div>
                    </div>
                    <div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Razon Social *</label><input id="mnp_nombre" type="text" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500" placeholder="Nombre del proveedor"></div>
                    <div class="grid grid-cols-2 gap-3">
                        <div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Tipo Insumo</label><select id="mnp_tipo" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500"><option value="Insumos">Insumos</option><option value="Packaging">Packaging</option><option value="Materia Prima">Materia Prima</option><option value="Granel">Granel</option></select></div>
                        <div><label class="block text-[10px] uppercase text-slate-400 font-bold mb-1">Mail Contacto</label><input id="mnp_mail" type="email" class="w-full bg-slate-800 border border-slate-700 p-2.5 text-white rounded outline-none focus:border-sky-500"></div>
                    </div>
                </div>
                <div class="flex justify-end gap-3 mt-6">
                    <button onclick="cerrarModalNuevoProveedor()" class="bg-slate-700 hover:bg-slate-600 px-5 py-2.5 font-bold rounded text-white transition">Cancelar</button>
                    <button onclick="guardarProveedorDesdeModal()" class="bg-sky-600 hover:bg-sky-500 px-6 py-2.5 font-bold rounded text-white transition shadow">Guardar y Continuar Alta</button>
                </div>
            </div>`;
        document.body.appendChild(modal); setTimeout(() => document.getElementById('mnp_nombre')?.focus(), 100);
    }
    function cerrarModalNuevoProveedor() { _modalProvAbierto = false; const m = document.getElementById('modal-nuevo-prov'); if(m) m.remove(); }
    async function guardarProveedorDesdeModal() {
        const nombre = document.getElementById('mnp_nombre')?.value.trim(); const cuit = document.getElementById('mnp_cuit')?.value.replace(/[^0-9\-]/g,''); const id = document.getElementById('mnp_id')?.value.replace(/[^0-9]/g,'') || cuit; const tipo = document.getElementById('mnp_tipo')?.value || 'Insumos'; const mail = document.getElementById('mnp_mail')?.value.trim() || '';
        if(!nombre) return showToast('Razon Social requerida.', 'err');
        const nuevoProveedor = { usuario: currentLoggedUser.name || '', responsable: currentLoggedUser.name || '', mail, tipo, id, cuit, nombre, estado: 'Habilitado' };
        listaProveedoresCache.push(nuevoProveedor); cerrarModalNuevoProveedor();
        document.getElementById('f_proveedor').value = nombre; document.getElementById('f_email').value = mail;
        showToast(`Proveedor "${nombre}" registrado. Continue con el Alta del Turno.`, 'ok');
        await actualizarCSVSharePoint('prov').catch(() => {});
    }

    function autocompletarProveedor() {
        const nProv = document.getElementById('f_cuit').value.replace(/[^0-9]/g, ''); document.getElementById('f_cuit').value = nProv;
        if (!nProv) return;
        if (listaProveedoresCache.length === 0) return showToast('Padron de proveedores no cargado aun. Verifique la conexion.', 'err');
        const provEncontrado = listaProveedoresCache.find(p => p.id === nProv || p.cuit === nProv);
        if (!provEncontrado) { if (_modalProvAbierto) return; showToast('CUIT no encontrado. Complete el alta de proveedor.', 'ok'); abrirModalNuevoProveedor(nProv); return; }
        if (provEncontrado.estado !== 'Habilitado') return marcarError('f_cuit', "PROVEEDOR INHABILITADO -- no se puede asignar turno.");
        document.getElementById('f_proveedor').value = provEncontrado.nombre; if (provEncontrado.mail) document.getElementById('f_email').value = provEncontrado.mail;
        document.getElementById('f_usuario_gestor').textContent = escapeHtml(currentLoggedUser.name || 'S/D'); showToast(`Proveedor OK: ${provEncontrado.nombre}`, "ok");
    }

    // --- ABM USUARIOS ---
    function parsearCSVUsuarios(text) {
        const lines = text.split(/\r?\n|\r/); listaUsuariosCache = [];
        for(let i=1; i<lines.length; i++) { 
            const row = lines[i].trim(); if(!row) continue; const cols = row.split(/;/); 
            if(cols.length >= 5) listaUsuariosCache.push({ id: cols[0].trim(), nombre: cols[1].trim(), email: cols[2].trim(), planta: cols[3].trim(), estado: cols[4] ? cols[4].trim() : 'Habilitado', reporte: cols[5] ? cols[5].trim() : 'SI' });
        }
        renderizarBaseUsuarios();
    }

    function renderizarBaseUsuarios() {
        const tb = document.getElementById('tabla-usuarios'); if(!tb) return;
        tb.innerHTML = listaUsuariosCache.map((u, idx) => `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 text-sm cursor-pointer" onclick="cargarUsuForm(${idx})"><td class="p-3 text-amber-400 font-semibold">${escapeHtml(u.id)}</td><td class="p-3 text-white font-semibold">${escapeHtml(u.nombre)}</td><td class="p-3 text-slate-400">${escapeHtml(u.email)}</td><td class="p-3 text-slate-400">${escapeHtml(u.planta)}</td><td class="p-3 font-semibold ${u.reporte === 'SI' ? 'text-sky-400' : 'text-slate-500'}">${escapeHtml(u.reporte)}</td><td class="p-3 font-bold ${u.estado === 'Habilitado' ? 'text-emerald-400' : 'text-rose-400'}">${escapeHtml(u.estado)}</td><td class="p-3 text-sky-400 underline text-center">Editar</td></tr>`).join('');
        llenarComboResponsablesProv();
    }

    function cargarUsuForm(idx) {
        const u = listaUsuariosCache[idx]; document.getElementById('u_index').value = idx; document.getElementById('u_id').value = u.id; document.getElementById('u_nombre').value = u.nombre;
        document.getElementById('u_email').value = u.email; document.getElementById('u_planta').value = u.planta; document.getElementById('u_reporte').value = u.reporte || 'SI'; document.getElementById('u_estado').value = u.estado || 'Habilitado';
    }

    function limpiarFormularioUsuario() {
        document.getElementById('u_index').value = ''; document.getElementById('u_id').value = ''; document.getElementById('u_nombre').value = ''; document.getElementById('u_email').value = ''; 
        if(document.getElementById('u_planta')) document.getElementById('u_planta').selectedIndex = 0;
        document.getElementById('u_reporte').value = 'SI'; document.getElementById('u_estado').value = 'Habilitado';
    }

    async function guardarEdicionUsuario() {
        const idx = document.getElementById('u_index').value; const uId = document.getElementById('u_id').value.trim(); const uPlanta = document.getElementById('u_planta').value; const uEstado = document.getElementById('u_estado').value;
        if(!uId) return showToast("Falta ID", "err"); if(!uPlanta) return showToast("Seleccione Planta Asociada", "err"); if(!uEstado) return showToast("Seleccione Estado", "err");
        const obj = { id: uId, nombre: document.getElementById('u_nombre').value, email: document.getElementById('u_email').value, planta: document.getElementById('u_planta').value, reporte: document.getElementById('u_reporte').value, estado: document.getElementById('u_estado').value };
        if(idx === '') listaUsuariosCache.push(obj); else listaUsuariosCache[idx] = obj;
        renderizarBaseUsuarios(); sincronizarFiltrosYMonitor(); limpiarFormularioUsuario(); showToast("Usuario Guardado", "ok"); await actualizarCSVSharePoint('usu');
    }

    // --- MAILING PARA REPORTES ---
    function obtenerTurnosVentanaReporte() {
        const ahora = new Date(); const limite = new Date(ahora.getTime() + 24 * 60 * 60 * 1000);
        return listaTurnosCache.filter(t => { if (!t.field_6) return false; const fechaTurno = new Date(String(t.field_6).split('T')[0].replace(/-/g, '/') + ' 00:00:00'); return fechaTurno >= new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate()) && fechaTurno <= limite; });
    }

    function enviarResumenDiario() {
        const idsPermitidos = ['Usu01', 'Usu02', 'Usu03', 'Usu04', 'Usu05', 'Usu06', 'Usu07', 'Usu08'];
        const para = listaUsuariosCache.filter(u => u.estado !== 'Deshabilitado' && idsPermitidos.includes(String(u.id))).map(u => u.email).filter(Boolean).join(';');
        if(!para) return showToast("No se detectaron los usuarios autorizados en la base", "err");
        const turnosVentana = obtenerTurnosVentanaReporte(); if(turnosVentana.length === 0) return showToast("No hay turnos para reportar en la ventana hoy + 24hs", "err");
        const esSobre = t => t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1;
        const aprobados = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('aprobado')); const pendientes = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('pendiente')); const cancelados = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('cancelado') || String(t.field_7).toLowerCase().includes('rechazado')); const reprogramados = turnosVentana.filter(t => String(t.field_7).toLowerCase().includes('reprogramado')); const sobreturnos = turnosVentana.filter(esSobre);
        let body = `RESUMEN OPERATIVO MOLCA - Ventana: hoy + 24hs (generado ${new Date().toLocaleString('es-AR')})\n\n`;
        body += `Totales: Aprobados ${aprobados.length} | Pendientes ${pendientes.length} | Cancelados ${cancelados.length} | Reprogramados ${reprogramados.length} | Sobreturnos ${sobreturnos.length}\n\n`;
        body += `=== DETALLE POR PLANTA ===\n`;
        configPlantas.forEach(p => { const turnosP = turnosVentana.filter(t => t.PlantaDescarga === p.id); if(turnosP.length > 0) { body += `[ ${p.id.toUpperCase()} ] (${turnosP.length} turnos)\n`; turnosP.forEach(t => body += `  -> ${String(t.field_6).split('T')[0]} ${t.field_5} | Patente: ${t.Patente||'S/D'} | Prov: ${t.field_2} | Estado: ${t.field_7}${esSobre(t) ? ' [SOBRETURNO]' : ''}\n`); body += `\n`; } });
        body += `=== DETALLE POR RESPONSABLE ===\n`;
        const respUnicos = [...new Set(turnosVentana.map(t => getResponsableName(t)))].sort();
        respUnicos.forEach(r => { const turnosR = turnosVentana.filter(t => getResponsableName(t) === r); body += `[ ${r} ] (${turnosR.length} turnos)\n`; turnosR.forEach(t => body += `  -> ${String(t.field_6).split('T')[0]} ${t.field_5} | Planta: ${t.PlantaDescarga} | Estado: ${t.field_7}${esSobre(t) ? ' [SOBRETURNO]' : ''}\n`); body += `\n`; });
        window.location.href = `mailto:${para}?subject=Reporte de Operacion Molca (Hoy + 24hs)&body=${encodeURIComponent(body)}`;
    }

    let resumen18hsYaEnviadoHoy = null;
    function checkDisparoAutomatico18hs() { const ahora = new Date(); const hoyStr = obtenerFechaISO(0); if (ahora.getHours() === 18 && ahora.getMinutes() === 0 && resumen18hsYaEnviadoHoy !== hoyStr) { resumen18hsYaEnviadoHoy = hoyStr; logLog("[Automatico] Disparando Resumen Operativo 18:00hs..."); enviarResumenDiario(); } }
    setInterval(checkDisparoAutomatico18hs, 30000);

    // --- DASHBOARD DE INDICADORES (KPIs) ---
    let chartEstados, chartProveedores, chartPlantas, chartHorarios;
    function initDashboard() { document.getElementById('dash_fecha').value = fechaSeleccionadaGlobal; cargarSelectoresDashboard(); updateDashboard(); }
    function cargarSelectoresDashboard() {
        let usrHTML = '<option value="TODOS">-- Todos --</option>'; const usr = [...new Set(listaTurnosCache.map(t => getResponsableName(t)).filter(Boolean))].sort(); usr.forEach(u => { usrHTML += `<option value="${escapeHtml(u)}">${escapeHtml(u)}</option>`; }); document.getElementById('dash_resp').innerHTML = usrHTML;
        let horHTML = '<option value="TODOS">-- Todos --</option>'; const hor = [...new Set(listaTurnosCache.map(t => t.field_5).filter(Boolean))].sort(); hor.forEach(h => { horHTML += `<option value="${escapeHtml(h)}">${escapeHtml(h)}</option>`; }); document.getElementById('dash_horario').innerHTML = horHTML;
    }

    function updateDashboard() {
        const d_fec = document.getElementById('dash_fecha').value; const d_pla = document.getElementById('dash_planta').value; const d_hor = document.getElementById('dash_horario').value; const d_res = document.getElementById('dash_resp').value;
        let filtrados = listaTurnosCache;
        if(d_fec) filtrados = filtrados.filter(t => t.field_6 && t.field_6.startsWith(d_fec)); if(d_pla !== 'TODAS') filtrados = filtrados.filter(t => t.PlantaDescarga === d_pla); if(d_hor !== 'TODOS') filtrados = filtrados.filter(t => t.field_5 === d_hor); if(d_res !== 'TODOS') filtrados = filtrados.filter(t => getResponsableName(t) === d_res);
        let estadosCount = { 'Aprobado':0, 'Pendiente':0, 'Reprogramado':0, 'Cancelado':0, 'Rechazado':0 }; let plantasCount = {}; let horCount = {}; let provCount = {};
        let htmlResumen = ''; let totAsig = 0, totPend = 0, totApro = 0, totRepr = 0, totCanc = 0;
        filtrados.forEach(t => {
            let est = String(t.field_7).trim(); if(estadosCount[est] !== undefined) estadosCount[est]++; else if (est.toLowerCase().includes('rechazado')) estadosCount['Rechazado']++;
            let pl = t.PlantaDescarga || 'S/D'; plantasCount[pl] = (plantasCount[pl] || 0) + 1; let hr = t.field_5 || 'S/D'; horCount[hr] = (horCount[hr] || 0) + 1; let prv = t.field_2 || 'S/D'; provCount[prv] = (provCount[prv] || 0) + 1;
        });
        configPlantas.forEach(p => {
            const trnP = filtrados.filter(t => t.PlantaDescarga === p.id);
            if(trnP.length > 0) {
                let asig = trnP.length; let pend = trnP.filter(t => (t.field_7||'').toLowerCase().includes('pendiente')).length; let apro = trnP.filter(t => (t.field_7||'').toLowerCase().includes('aprobado')).length; let repr = trnP.filter(t => (t.field_7||'').toLowerCase().includes('reprogramado')).length; let canc = trnP.filter(t => (t.field_7||'').toLowerCase().includes('cancelado') || (t.field_7||'').toLowerCase().includes('rechazado')).length;
                totAsig += asig; totPend += pend; totApro += apro; totRepr += repr; totCanc += canc;
                htmlResumen += `<tr class="border-b border-slate-700/50 hover:bg-slate-800/30 transition"><td class="py-3 px-3 font-bold text-sky-300 text-sm">${p.id}</td><td class="px-3 text-center font-bold text-white text-base">${asig}</td><td class="px-3 text-center font-bold text-amber-400">${pend}</td><td class="px-3 text-center font-bold text-emerald-400">${apro}</td><td class="px-3 text-center font-bold text-sky-400">${repr}</td><td class="px-3 text-center font-bold text-rose-400">${canc}</td></tr>`;
            }
        });
        if(htmlResumen === '') { htmlResumen = '<tr><td colspan="6" class="p-6 text-center text-slate-500 text-sm">No hay actividad logistica para estos filtros.</td></tr>'; } 
        else { htmlResumen += `<tr class="bg-slate-800/80 font-extrabold text-white uppercase tracking-wider border-t-2 border-slate-500"><td class="py-4 px-3 text-right">TOTALES:</td><td class="px-3 text-center text-lg">${totAsig}</td><td class="px-3 text-center text-amber-400 text-lg">${totPend}</td><td class="px-3 text-center text-emerald-400 text-lg">${totApro}</td><td class="px-3 text-center text-sky-400 text-lg">${totRepr}</td><td class="px-3 text-center text-rose-400 text-lg">${totCanc}</td></tr>`; }
        document.getElementById('tabla-resumen-dashboard').innerHTML = htmlResumen;

        const lblFecha = document.getElementById('dash-resumen-fecha-label'); if(lblFecha) lblFecha.textContent = d_fec;
        const cont = document.getElementById('dash-resumen-contadores');
        if(cont) {
            let htmlVert = '';
            configPlantas.forEach(p => {
                const trnP = filtrados.filter(t => t.PlantaDescarga === p.id);
                if(trnP.length > 0) {
                    let asig = trnP.length; let pend = trnP.filter(t => (t.field_7||'').toLowerCase().includes('pendiente')).length; let apro = trnP.filter(t => (t.field_7||'').toLowerCase().includes('aprobado')).length; let repr = trnP.filter(t => (t.field_7||'').toLowerCase().includes('reprogramado')).length; let canc = trnP.filter(t => (t.field_7||'').toLowerCase().includes('cancelado') || (t.field_7||'').toLowerCase().includes('rechazado')).length; let sobre = trnP.filter(t => t.EsSobreturno === true || t.EsSobreturno === 'true' || t.EsSobreturno === 1).length;
                    htmlVert += `<div class="bg-slate-900/60 border border-slate-700 rounded-lg p-3"><div class="flex items-center justify-between mb-2"><span class="font-bold text-sky-300 text-xs uppercase truncate">${escapeHtml(p.id)}</span><span class="font-extrabold text-white text-sm bg-slate-800 rounded px-2 py-0.5">${asig}</span></div><div class="space-y-1 text-[11px]"><div class="flex justify-between"><span class="text-amber-400">Pendientes</span><span class="font-bold text-amber-400">${pend}</span></div><div class="flex justify-between"><span class="text-emerald-400">Aprobados</span><span class="font-bold text-emerald-400">${apro}</span></div><div class="flex justify-between"><span class="text-sky-400">Reprogramados</span><span class="font-bold text-sky-400">${repr}</span></div><div class="flex justify-between"><span class="text-rose-400">Cancelados</span><span class="font-bold text-rose-400">${canc}</span></div><div class="flex justify-between"><span class="text-violet-300">Sobreturnos</span><span class="font-bold text-violet-300">${sobre}</span></div></div></div>`;
                }
            });
            if(htmlVert === '') cont.innerHTML = '<div class="text-center text-slate-500 text-xs mt-6 px-2">No hay actividad logistica en esta fecha.</div>'; else cont.innerHTML = htmlVert;
        }

        Chart.defaults.color = '#94a3b8'; Chart.defaults.font.family = 'Inter';
        if(chartEstados) chartEstados.destroy(); chartEstados = new Chart(document.getElementById('chartEstados'), { type: 'bar', data: { labels: ['Aprobados', 'Pendientes', 'Reprogramados', 'Cancelados/Rechazados'], datasets: [{ label: 'Cantidad de Turnos', data: [estadosCount['Aprobado'], estadosCount['Pendiente'], estadosCount['Reprogramado'], estadosCount['Cancelado']+estadosCount['Rechazado']], backgroundColor: ['rgba(52, 211, 153, 0.7)', 'rgba(251, 191, 36, 0.7)', 'rgba(56, 189, 248, 0.7)', 'rgba(244, 63, 94, 0.7)'], borderColor: ['#10b981', '#f59e0b', '#0ea5e9', '#e11d48'], borderWidth: 1 }] }, options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
        const provSorted = Object.entries(provCount).sort((a,b) => b[1]-a[1]).slice(0,10);
        if(chartProveedores) chartProveedores.destroy(); chartProveedores = new Chart(document.getElementById('chartProveedores'), { type: 'bar', data: { labels: provSorted.map(p => p[0].substring(0, 15) + '...'), datasets: [{ label: 'Turnos por Proveedor (Top 10)', data: provSorted.map(p => p[1]), backgroundColor: 'rgba(99, 102, 241, 0.7)', borderColor: '#4f46e5', borderWidth: 1 }] }, options: { indexAxis: 'y', responsive: true, scales: { x: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
        if(chartPlantas) chartPlantas.destroy(); chartPlantas = new Chart(document.getElementById('chartPlantas'), { type: 'bar', data: { labels: Object.keys(plantasCount), datasets: [{ label: 'Volumen Operativo', data: Object.values(plantasCount), backgroundColor: 'rgba(244, 114, 182, 0.7)', borderColor: '#e11d48', borderWidth: 1 }] }, options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
        if(chartHorarios) chartHorarios.destroy(); chartHorarios = new Chart(document.getElementById('chartHorarios'), { type: 'line', data: { labels: Object.keys(horCount).sort(), datasets: [{ label: 'Densidad por Horario', data: Object.keys(horCount).sort().map(k => horCount[k]), backgroundColor: 'rgba(167, 139, 250, 0.2)', borderColor: '#c084fc', borderWidth: 2, fill: true, tension: 0.3 }] }, options: { responsive: true, scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } } } });
    }

    // --- ETL LOGS ---
    function logETLStep(stepNum, isDone=false) {
        const steps = ['etl-extract', 'etl-transform', 'etl-load']; const ic = ['etl-ic1', 'etl-ic2', 'etl-ic3'];
        steps.forEach((s, idx) => { let el = document.getElementById(s); if(!el) return; if(idx === stepNum-1) { el.classList.add('active'); if(isDone) { el.classList.add('done'); document.getElementById(ic[idx]).innerHTML = 'OK'; } } else { el.classList.remove('active'); } });
    }
    function logLog(msg) { const d = document.getElementById('etl-log-console'); if(d) { d.insertAdjacentHTML('beforeend', `<div><span class="text-slate-500">[${new Date().toLocaleTimeString()}]</span> ${msg}</div>`); d.scrollTop = d.scrollHeight; } }
    async function generarLogArchivoSP(modulo, detalle) { if(currentLoggedUser && currentLoggedUser.name) { logLog(`[Audit Log] -> Modulo: ${modulo} | Accion: ${detalle} | User: ${currentLoggedUser.name}`); } }

    function showToast(msg, type) { const t = document.getElementById('toast'); if(!t) return; t.innerHTML = msg; t.className = `show ${type}`; setTimeout(() => t.className = '', 3000); }

    initApp();
</script>
</body>
</html>