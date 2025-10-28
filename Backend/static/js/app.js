// Configuración global
const API_BASE = "http://localhost:9000";
let busesChart = null;
let lugaresChart = null;
let usuariosChart = null;

// Inicialización de la aplicación
document.addEventListener("DOMContentLoaded", function () {
  console.log("🚀 Inicializando Dashboard Administrativo...");
  cargarEstadisticasGenerales();
  cargarBusesFavoritos();
  cargarLugaresFavoritos();
  cargarUsuariosPorFecha();
});

// Función para mostrar errores de manera elegante
function mostrarError(elemento, mensaje) {
  elemento.innerHTML = `
        <div class="error-message">
            <strong>⚠️ Error:</strong> ${mensaje}
            <br><br>
            <button class="refresh-btn" onclick="location.reload()">
                🔄 Recargar Página
            </button>
        </div>
    `;
}

// ==================== ESTADÍSTICAS GENERALES ====================
async function cargarEstadisticasGenerales() {
  try {
    const response = await fetch(`${API_BASE}/api/admin/estadisticas/general`);
    if (!response.ok) throw new Error("Error en la respuesta del servidor");

    const data = await response.json();
    console.log("📊 Estadísticas generales:", data);

    document.getElementById("total-usuarios").textContent =
      data.total_usuarios?.toLocaleString() || "0";
    document.getElementById("total-buses-favoritos").textContent =
      data.total_buses_favoritos?.toLocaleString() || "0";
    document.getElementById("total-lugares-favoritos").textContent =
      data.total_lugares_favoritos?.toLocaleString() || "0";
  } catch (error) {
    console.error("❌ Error cargando estadísticas generales:", error);
    document.getElementById("total-usuarios").textContent = "❌";
    document.getElementById("total-buses-favoritos").textContent = "❌";
    document.getElementById("total-lugares-favoritos").textContent = "❌";
  }
}

// ==================== BUSES FAVORITOS ====================
async function cargarBusesFavoritos() {
  const container = document.getElementById("buses-list");
  container.innerHTML =
    '<div class="loading">Cargando datos de buses favoritos</div>';

  try {
    const response = await fetch(
      `${API_BASE}/api/admin/estadisticas/buses-favoritos`
    );
    if (!response.ok) throw new Error("Error al cargar buses favoritos");

    const data = await response.json();
    console.log("🚌 Datos de buses favoritos:", data);

    let busesData = [];

    if (data.buses_favoritos && Array.isArray(data.buses_favoritos)) {
      busesData = data.buses_favoritos;
    } else if (Array.isArray(data)) {
      busesData = data;
    }

    if (busesData.length > 0) {
      const busesConDetalles = await Promise.all(
        busesData.map(async (bus) => {
          try {
            const busResponse = await fetch(
              `${API_BASE}/api/admin/buses/${bus.id_bus || bus.IdBus}`
            );
            const busDetalles = await busResponse.json();

            return {
              ...bus,
              numero: busDetalles.numero,
              placa: busDetalles.placa,
              modelo: busDetalles.modelo,
              marca: busDetalles.marca,
            };
          } catch (error) {
            console.warn(
              `⚠️ No se pudieron cargar los detalles del bus ${bus.id_bus}`
            );
            return {
              ...bus,
              numero: "N/A",
              placa: "N/A",
              modelo: "N/A",
              marca: "N/A",
            };
          }
        })
      );

      renderizarTablaBuses(busesConDetalles, container);
      actualizarGraficoBuses(busesConDetalles);
    } else {
      container.innerHTML =
        '<div class="loading">No hay datos de buses favoritos disponibles</div>';
    }
  } catch (error) {
    console.error("❌ Error:", error);
    mostrarError(
      container,
      "No se pudieron cargar los datos de buses favoritos"
    );
  }
}

function renderizarTablaBuses(buses, container) {
  container.innerHTML = `
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Número de Bus</th>
                    <th>Placa</th>
                    <th>Modelo/Marca</th>
                    <th>Total de Favoritos</th>
                </tr>
            </thead>
            <tbody>
                ${buses
                  .map(
                    (bus, index) => `
                    <tr>
                        <td><strong>${index + 1}</strong></td>
                        <td>${bus.numero || "N/A"}</td>
                        <td>${bus.placa || "N/A"}</td>
                        <td>${bus.modelo || "N/A"} ${bus.marca || ""}</td>
                        <td><span class="badge">${(
                          bus.total_favoritos ||
                          bus.total ||
                          0
                        ).toLocaleString()} favoritos</span></td>
                    </tr>
                `
                  )
                  .join("")}
            </tbody>
        </table>
    `;
}

function actualizarGraficoBuses(buses) {
  const ctx = document.getElementById("busesChart").getContext("2d");

  if (busesChart) busesChart.destroy();

  busesChart = new Chart(ctx, {
    type: "doughnut",
    data: {
      labels: buses.map((bus) => `Bus ${bus.numero || bus.id_bus || "N/A"}`),
      datasets: [
        {
          label: "Número de Favoritos",
          data: buses.map((bus) => bus.total_favoritos || bus.total || 0),
          backgroundColor: [
            "#FF6B6B",
            "#4ECDC4",
            "#45B7D1",
            "#96CEB4",
            "#FFEAA7",
            "#DDA0DD",
            "#98D8C8",
            "#F7DC6F",
            "#BB8FCE",
            "#85C1E9",
          ],
          borderColor: "#ffffff",
          borderWidth: 3,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: "right",
          labels: {
            padding: 20,
            usePointStyle: true,
            font: { size: 12 },
          },
        },
        tooltip: {
          callbacks: {
            label: (context) => `${context.label}: ${context.raw} favoritos`,
          },
        },
      },
      cutout: "60%",
      animation: {
        animateScale: true,
        animateRotate: true,
      },
    },
  });
}

// ==================== LUGARES FAVORITOS ====================
async function cargarLugaresFavoritos() {
  const container = document.getElementById("lugares-list");
  container.innerHTML =
    '<div class="loading">Cargando datos de lugares favoritos</div>';

  try {
    const response = await fetch(
      `${API_BASE}/api/admin/estadisticas/lugares-favoritos`
    );
    if (!response.ok) throw new Error("Error al cargar lugares favoritos");

    const data = await response.json();
    console.log("📍 Datos de lugares favoritos:", data);

    let lugaresData = [];
    let totalLugares = 0;

    if (data.lugares_populares && Array.isArray(data.lugares_populares)) {
      lugaresData = data.lugares_populares;
      totalLugares = data.total_lugares || 0;
    } else if (Array.isArray(data)) {
      lugaresData = data;
    }

    if (lugaresData.length > 0) {
      renderizarTablaLugares(lugaresData, totalLugares, container);
      actualizarGraficoLugares(lugaresData);
    } else {
      container.innerHTML = `
                <div class="debug-info">
                    Total de lugares en sistema: ${totalLugares}
                </div>
                <div class="loading">No hay datos de lugares favoritos disponibles</div>
            `;
    }
  } catch (error) {
    console.error("❌ Error:", error);
    mostrarError(
      container,
      "No se pudieron cargar los datos de lugares favoritos"
    );
  }
}

function renderizarTablaLugares(lugares, totalLugares, container) {
  container.innerHTML = `
        <div class="debug-info">
            📍 Total de lugares en sistema: <strong>${totalLugares}</strong>
        </div>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Nombre del Lugar</th>
                    <th>Total de Registros</th>
                </tr>
            </thead>
            <tbody>
                ${lugares
                  .map(
                    (lugar, index) => `
                    <tr>
                        <td><strong>${index + 1}</strong></td>
                        <td>${lugar.nombre || lugar.Nombre}</td>
                        <td><span class="badge">${(
                          lugar.total || 1
                        ).toLocaleString()} registros</span></td>
                    </tr>
                `
                  )
                  .join("")}
            </tbody>
        </table>
    `;
}

function actualizarGraficoLugares(lugares) {
  const ctx = document.getElementById("lugaresChart").getContext("2d");

  if (lugaresChart) lugaresChart.destroy();

  lugaresChart = new Chart(ctx, {
    type: "doughnut",
    data: {
      labels: lugares.map((lugar) => lugar.nombre || lugar.Nombre),
      datasets: [
        {
          label: "Registros",
          data: lugares.map((lugar) => lugar.total || 1),
          backgroundColor: [
            "#FF6384",
            "#36A2EB",
            "#FFCE56",
            "#4BC0C0",
            "#9966FF",
            "#FF9F40",
            "#85C1E9",
            "#F7DC6F",
          ],
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: "right",
        },
      },
    },
  });
}

// ==================== ESTADÍSTICAS DE USUARIOS ====================
async function cargarUsuariosPorFecha() {
  const container = document.getElementById("usuarios-list");
  const selectRango = document.getElementById("rango-fechas");
  const dias = selectRango ? parseInt(selectRango.value) : 0;

  container.innerHTML =
    '<div class="loading">Cargando datos de usuarios...</div>';

  try {
    console.log(`📅 Solicitando datos para los últimos ${dias} días`);

    let data;

    // Primero intentar con el endpoint normal
    try {
      const response = await fetch(
        `${API_BASE}/api/admin/estadisticas/usuarios-por-fecha?dias=${dias}`
      );
      if (!response.ok) throw new Error(`Error HTTP: ${response.status}`);
      data = await response.json();
    } catch (error) {
      console.warn("❌ Endpoint principal falló, usando fallback:", error);
      // Usar endpoint de fallback
      const fallbackResponse = await fetch(
        `${API_BASE}/api/admin/estadisticas/usuarios-fallback`
      );
      data = await fallbackResponse.json();
      data.fallback_used = true;
    }

    console.log("👥 Datos recibidos:", data);

    // Actualizar estadísticas generales
    if (data.estadisticas_generales) {
      document.getElementById("total-usuarios-general").textContent =
        data.estadisticas_generales.total_usuarios?.toLocaleString() || "0";
      document.getElementById("usuarios-activos").textContent =
        data.estadisticas_generales.usuarios_activos?.toLocaleString() || "0";
      document.getElementById("usuarios-inactivos").textContent =
        data.estadisticas_generales.usuarios_inactivos?.toLocaleString() || "0";
    }

    // Verificar si hay datos
    if (data.usuarios_por_fecha && data.usuarios_por_fecha.length > 0) {
      renderizarTablaUsuarios(data, container, dias);
      actualizarGraficoUsuarios(data.usuarios_por_fecha);

      if (data.fallback_used) {
        container.innerHTML += `
                    <div class="debug-info" style="margin-top: 15px;">
                        ⚠️ Usando modo de respaldo - Los filtros por fecha no están disponibles
                    </div>
                `;
      }
    } else {
      container.innerHTML = `
                <div class="debug-info">
                    Período: ${
                      dias === 0 ? "Todo el historial" : `Últimos ${dias} días`
                    } | 
                    Total de usuarios en sistema: <strong>${
                      data.estadisticas_generales?.total_usuarios || 0
                    }</strong>
                    ${data.fallback_used ? "<br>⚠️ Modo respaldo activado" : ""}
                </div>
                <div class="loading">
                    📊 No hay registros de usuarios para el período seleccionado.
                </div>
            `;

      if (usuariosChart) {
        usuariosChart.destroy();
        usuariosChart = null;
      }
    }
  } catch (error) {
    console.error("❌ Error crítico:", error);
    container.innerHTML = `
            <div class="error-message">
                <strong>❌ Error crítico:</strong> ${error.message}
                <br><br>
                <button class="refresh-btn" onclick="probarDiagnosticoCompleto()">
                    🔧 Ejecutar Diagnóstico Completo
                </button>
            </div>
        `;
  }
}

// Función de diagnóstico completo
async function probarDiagnosticoCompleto() {
  const endpoints = [
    "/api/admin/debug/usuarios-fechas",
    "/api/admin/debug/database-structure",
    "/api/admin/estadisticas/usuarios-fallback",
    "/api/admin/estadisticas/general",
  ];

  for (const endpoint of endpoints) {
    try {
      const response = await fetch(`${API_BASE}${endpoint}`);
      const data = await response.json();
      console.log(`🔍 ${endpoint}:`, data);
    } catch (err) {
      console.log(`❌ ${endpoint}:`, err.message);
    }
  }
  alert("Diagnóstico completado. Revisa la consola (F12)");
}

// Función de diagnóstico desde el frontend
async function probarEndpoints() {
  try {
    console.log("🔍 Ejecutando diagnóstico...");

    const endpoints = [
      "/api/admin/estadisticas/usuarios-por-fecha?dias=7",
      "/api/admin/debug/usuarios-fechas",
      "/api/admin/debug/database-structure",
    ];

    for (const endpoint of endpoints) {
      try {
        const response = await fetch(`${API_BASE}${endpoint}`);
        const data = await response.json();
        console.log(`✅ ${endpoint}:`, data);
      } catch (err) {
        console.log(`❌ ${endpoint}:`, err.message);
      }
    }

    alert("Diagnóstico completado. Revisa la consola (F12)");
  } catch (error) {
    console.error("Error en diagnóstico:", error);
  }
}

// ==================== UTILIDADES ====================
// Actualización automática cada 30 segundos
setInterval(() => {
  cargarEstadisticasGenerales();
}, 30000);

// Función para debug (activar desde consola)
window.debugEndpoints = async function () {
  try {
    const endpoints = [
      "/api/admin/estadisticas/general",
      "/api/admin/estadisticas/buses-favoritos",
      "/api/admin/estadisticas/lugares-favoritos",
      "/api/admin/estadisticas/usuarios-por-fecha?dias=30",
    ];

    for (const endpoint of endpoints) {
      const response = await fetch(`${API_BASE}${endpoint}`);
      const data = await response.json();
      console.log(`🔍 ${endpoint}:`, data);
    }
  } catch (error) {
    console.error("❌ Error en debug:", error);
  }
};

console.log(
  "🎯 Dashboard cargado. Usa debugEndpoints() en la consola para diagnóstico."
);
