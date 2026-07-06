async function cargarTurnos() {
        logDebug("Invocando API SharePoint (Pidiendo datos de la lista)...");
        try {
            // Consulta OData blindada: Pide todo (*) y explícitamente el nombre del modificador
            const endpoint = `${relativeSiteUrl}/_api/web/lists/getbytitle('${targetListName}')/items?$select=*,Editor/Title&$expand=Editor&$orderby=Created desc&$top=100`;
            
            const res = await fetch(endpoint, { 
                headers: { "Accept": "application/json;odata=nometadata" } 
            });
            
            if (!res.ok) {
                // Forzamos a SharePoint a que nos diga el motivo exacto del rechazo
                const errData = await res.json();
                const msjError = errData.error ? errData.error.message.value : "Error HTTP " + res.status;
                throw new Error(msjError);
            }
            
            const data = await res.json();
            listaTurnosCache = data.value || [];
            
            renderizarFilas(listaTurnosCache);
            poblarFiltroModificadores();
            renderizarGrilaCalendario();
            calcularDisponibilidadOffline();
            logDebug("Exito: Datos descargados. Total turnos: " + listaTurnosCache.length);

        } catch (err) {
            // Imprime el error real en tu pantalla negra de Debug
            logDebug(`[FALLA CRITICA EN LECTURA]: ${err.message}`);
        }
    }