const API_URL = "http://localhost:3000/api";

document.addEventListener('DOMContentLoaded', async () => {
  const session = requireAuth();
  if (!session) return;

  const params = new URLSearchParams(window.location.search);
  const tiendaId = params.get('id');

  if (!tiendaId) {
    window.location.href = 'index.html';
    return;
  }

  document.getElementById('btnLogout').addEventListener('click', logout);

  try {
    const response = await fetch(`${API_URL}/stores/${tiendaId}/album`, {
      headers: { 'Authorization': `Bearer ${session.token}` }
    });
    if (!response.ok) throw new Error('No se pudo cargar el álbum');

    const { tienda, empleados, semanas } = await response.json();
    
    renderNavbar(tienda, semanas, empleados);
    renderHero(tienda, semanas, empleados);
    renderSemanas(semanas, empleados);
    renderStatsBar(semanas, empleados);

  } catch (err) {
    console.error(err);
    window.location.href = 'index.html';
  }
});

function renderNavbar(tienda, semanas, empleados) {
  const semActiva = semanas.find(s => s.activa) || { numero: 1 };
  const desbloqueados = empleados.filter(e => e.espacios_album?.some(ea => ea.desbloqueado)).length;
  const pct = empleados.length ? Math.round((desbloqueados / empleados.length) * 100) : 0;

  document.getElementById('navTienda').textContent = tienda.nombre;
  document.getElementById('navRegion').textContent = tienda.region;
  document.getElementById('navSemana').textContent = `Semana ${semActiva.numero} de 6`;
  document.getElementById('navPct').textContent = `${pct}%`;
  document.getElementById('progressFill').style.width = `${pct}%`;
}

function renderHero(tienda, semanas, empleados) {
  const semActiva = semanas.find(s => s.activa) || { numero: 1 };
  const desbloqueados = empleados.filter(e => e.espacios_album?.some(ea => ea.desbloqueado)).length;

  document.getElementById('heroTienda').textContent = tienda.nombre;
  document.getElementById('heroRegion').textContent = tienda.region;
  document.getElementById('heroFechas').textContent = `Mundial 2026`;

  document.getElementById('statTotal').textContent = tienda.total_empleados || empleados.length;
  document.getElementById('statDesbloqueados').textContent = desbloqueados;
  document.getElementById('statSemana').textContent = semActiva.numero;
  document.getElementById('statPorSemana').textContent = Math.ceil((tienda.total_empleados || empleados.length) / 6);
}

function renderSemanas(semanas, empleados) {
  const container = document.getElementById('albumContainer');
  container.innerHTML = '';

  semanas.forEach(semana => {
    const empsDeLaSemana = empleados.filter(e => e.semana_asignada === semana.numero);
    if (empsDeLaSemana.length === 0) return;

    const section = document.createElement('section');
    const estado = semana.activa ? 'actual' : (new Date(semana.fecha_fin) < new Date() ? 'pasada' : 'futura');
    section.className = `semana-section semana-${estado}`;
    section.id = `semana-${semana.numero}`;

    const okCount = empsDeLaSemana.filter(e => e.espacios_album?.some(ea => ea.desbloqueado)).length;
    const badgeTxt = estado === 'actual' ? '▶ En Curso' : (estado === 'pasada' ? '✓ Finalizada' : '🔒 Bloqueada');

    section.innerHTML = `
      <div class="semana-header">
        <div class="semana-info">
          <span class="semana-num">Semana ${semana.numero}</span>
          <span class="semana-nombre">${semana.nombre || ''}</span>
        </div>
        <div class="semana-meta">
          <span class="semana-badge badge-${estado}">${badgeTxt}</span>
          <span class="semana-counter">${okCount}/${empsDeLaSemana.length} desbloqueados</span>
        </div>
      </div>
      <div class="cards-grid">
        ${empsDeLaSemana.map(e => buildCardMarkup(e, estado)).join('')}
      </div>
    `;
    container.appendChild(section);
  });
}

function buildCardMarkup(empleado, estadoSemana) {
  const inicial = empleado.nombre.charAt(0).toUpperCase();
  const haDesbloqueado = empleado.espacios_album?.some(ea => ea.desbloqueado);

  if (estadoSemana === 'futura') {
    return `
      <div class="sticker sticker-futura">
        <div class="sticker-inner"><div class="sticker-silhouette">?</div><div class="sticker-lock-icon">🔒</div></div>
        <div class="sticker-footer"><span class="sticker-status">Por llegar</span></div>
      </div>`;
  }

  if (haDesbloqueado) {
    return `
      <div class="sticker sticker-desbloqueado">
        <div class="sticker-shine"></div>
        <div class="sticker-inner">
          <div class="sticker-foto">
            ${empleado.foto_url ? `<img src="${empleado.foto_url}" />` : `<div class="sticker-inicial">${inicial}</div>`}
          </div>
          <div class="sticker-badge-meta">⭐ 100%</div>
        </div>
        <div class="sticker-footer">
          <span class="sticker-nombre">${empleado.nombre}</span>
          <span class="sticker-cargo">${empleado.cargo || 'Asesor'}</span>
        </div>
      </div>`;
  }

  const label = estadoSemana === 'actual' ? 'En curso' : 'No cumplió';
  const clase = estadoSemana === 'actual' ? 'sticker-en-curso' : 'sticker-bloqueado';

  return `
    <div class="sticker ${clase}">
      <div class="sticker-inner">
        <div class="sticker-silhouette">${inicial}</div>
        ${estadoSemana === 'actual' ? '<div class="pulse-ring"></div>' : ''}
      </div>
      <div class="sticker-footer">
        <span class="sticker-nombre">${empleado.nombre}</span>
        <span class="sticker-status">${label}</span>
      </div>
    </div>`;
}

function renderStatsBar(semanas, empleados) {
  const container = document.getElementById('statsBar');
  if (!container) return;

  container.innerHTML = semanas.map(s => {
    const emps = empleados.filter(e => e.semana_asignada === s.numero);
    const ok = emps.filter(e => e.espacios_album?.some(ea => ea.desbloqueado)).length;
    const pct = emps.length ? Math.round((ok / emps.length) * 100) : 0;
    const estado = s.activa ? 'actual' : (new Date(s.fecha_fin) < new Date() ? 'pasada' : 'futura');

    return `
      <div class="mini-stat mini-${estado}" onclick="document.getElementById('semana-${s.numero}')?.scrollIntoView({behavior:'smooth'})">
        <span class="mini-num">S${s.numero}</span>
        <div class="mini-bar-wrap"><div class="mini-bar-fill" style="width:${pct}%"></div></div>
        <span class="mini-pct">${pct}%</span>
      </div>`;
  }).join('');
}
