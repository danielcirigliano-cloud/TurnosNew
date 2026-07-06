<!DOCTYPE html>
<html lang='es'>
<head>
<meta charset='UTF-8'>
<title>Capacidad BI FINAL</title>
<style>
body{background:#0b1220;color:#e2e8f0;font-family:sans-serif}
.expander-btn{cursor:pointer;transition:.3s}
.expander-btn.open{transform:rotate(90deg)}
.hidden{display:none}
table{width:100%;border-collapse:collapse}
td,th{padding:6px;border-bottom:1px solid #1e293b}
</style>
</head>
<body>
<h2>Capacidad por Planta y Tipo de Carga</h2>
<table>
<thead>
<tr>
<th>Planta</th><th>Tipo_Carga</th><th>Turnos</th>
</tr>
</thead>
<tbody id="tabla"></tbody>
</table>
<script>
const ORDEN_TIPOS=['INSUMOS','PACKAGING','NO_PRODUCTIVO'];

function toggle(p){
 document.querySelectorAll(`[data-p='${p}']`).forEach(r=>r.classList.toggle('hidden'));
 const b=document.querySelector(`[data-b='${p}']`);
 b.classList.toggle('open');
}

function render(data){
 let g={};
 data.forEach(d=>{
  if(!g[d.Planta]) g[d.Planta]=[];
  g[d.Planta].push(d);
 });
 let h='';
 Object.keys(g).forEach(p=>{
  h+=`<tr><td><button class='expander-btn' data-b='${p}' onclick="toggle('${p}')">+</button>${p}</td><td></td><td></td></tr>`;
  g[p].sort((a,b)=>ORDEN_TIPOS.indexOf(a.Tipo_Carga)-ORDEN_TIPOS.indexOf(b.Tipo_Carga));
  g[p].forEach(r=>{
   h+=`<tr class='hidden' data-p='${p}'><td></td><td>&#9492; ${r.Tipo_Carga}</td><td>${r.Turnos}</td></tr>`;
  });
 });
 document.getElementById('tabla').innerHTML=h;
}

render([
{Planta:'Almar',Tipo_Carga:'INSUMOS',Turnos:14},
{Planta:'Almar',Tipo_Carga:'PACKAGING',Turnos:14},
{Planta:'Almar',Tipo_Carga:'NO_PRODUCTIVO',Turnos:14}
]);
</script>
</body>
</html>