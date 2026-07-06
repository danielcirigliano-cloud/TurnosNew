<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Test Molca Spegazzini</title>
</head>
<body style="background-color: #0b1120; color: white; padding: 50px;">
    <h1>Modo Debug: Si ves esto, el archivo carga.</h1>
    <div id="debug-log" style="font-family: monospace; border: 1px solid white; padding: 20px;"></div>

    <script>
        const debugLog = document.getElementById('debug-log');
        
        function log(msg) {
            const entry = document.createElement('div');
            entry.textContent = `[${new Date().toLocaleTimeString()}] ${msg}`;
            debugLog.appendChild(entry);
            console.log(msg);
        }

        log("Script inicializado correctamente.");

        // Intentar obtener usuario sin depender de nada externo
        async function testConexion() {
            log("Iniciando test de API...");
            try {
                const res = await fetch("/sites/GestiondeTurnos/_api/web/currentUser", {
                    headers: { "Accept": "application/json;odata=nometadata" }
                });
                if (res.ok) {
                    const data = await res.json();
                    log("API respondio: " + data.Title);
                } else {
                    log("API respondio con error: " + res.status);
                }
            } catch (err) {
                log("Error critico de red: " + err.message);
            }
        }

        testConexion();
    </script>
</body>
</html>