\# PROJECT CONTEXT



\## Información General



\*\*Proyecto:\*\* AutoTurnos Logística



\*\*Versión:\*\* 1.0



\*\*Estado:\*\* Desarrollo



\*\*Repositorio GitHub:\*\*

https://github.com/danielcirigliano-cloud/TurnosNew



\---



\# Objetivo



Desarrollar una aplicación web empresarial para administrar la solicitud, aprobación y seguimiento de turnos logísticos.



La aplicación debe reemplazar procesos manuales realizados mediante planillas Excel y correos electrónicos, centralizando toda la información en Microsoft 365.



\---



\# Tecnologías



\## Frontend



\- HTML5

\- CSS3

\- JavaScript Vanilla



\## Backend



Actualmente no posee backend propio.



Las integraciones se realizan mediante:



\- SharePoint Online

\- Power Automate

\- SharePoint REST API

\- Microsoft Graph (cuando sea necesario)



\---



\# Inteligencia Artificial



La aplicación deberá estar preparada para integrar modelos de IA.



La IA podrá utilizarse para:



\- clasificación automática de solicitudes

\- generación de respuestas

\- análisis documental

\- sugerencias al operador

\- automatización de tareas



\---



\# Usuarios



\## Solicitante



Responsable de crear solicitudes de turno.



\## Operador Logístico



Administra las solicitudes.



\## Supervisor



Aprueba solicitudes especiales.



\## Administrador



Configura parámetros generales.



\---



\# Proceso Principal



1\. Crear solicitud.

2\. Validar información.

3\. Registrar en SharePoint.

4\. Ejecutar Power Automate.

5\. Notificar usuarios.

6\. Aprobar o rechazar.

7\. Confirmar turno.

8\. Registrar historial.



\---



\# Integraciones



\## SharePoint



Repositorio principal de datos.



\## Power Automate



Automatización de procesos.



\## Outlook



Envío de notificaciones.



\## Microsoft Teams



Notificaciones futuras.



\---



\# Arquitectura



Frontend



↓



REST API SharePoint



↓



SharePoint Lists



↓



Power Automate



↓



Notificaciones



\---



\# Objetivos Técnicos



\- Código modular.

\- Bajo acoplamiento.

\- Alta mantenibilidad.

\- Alto rendimiento.

\- Escalable.

\- Compatible con SharePoint Online.



\---



\# Convenciones



\- HTML separado de JS.

\- CSS independiente.

\- Async/Await para APIs.

\- Sin jQuery.

\- Sin frameworks.

\- Configuración centralizada.



\---



\# Restricciones



No modificar nombres internos de SharePoint.



No hardcodear URLs.



No almacenar credenciales.



No duplicar lógica.



No utilizar librerías externas salvo autorización.



\---



\# Calidad



Toda funcionalidad deberá incluir:



\- validaciones

\- manejo de errores

\- logging

\- mensajes claros

\- documentación



\---



\# Objetivo Final



Construir una plataforma empresarial reutilizable para gestionar procesos logísticos, solicitudes y aprobaciones utilizando Microsoft 365 e Inteligencia Artificial.

