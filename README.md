# TerraGuard Arequipa — Frontend Flutter

Cliente móvil/desktop para **TerraGuard Arequipa**, conectado al backend Python del hackatón mediante un adaptador REST mínimo (`HackatonFlit/api_server.py`).

## Descripción

Aplicación Flutter con **Material Design 3** que expone todas las funcionalidades del MVP:

| Pantalla | Función |
|---|---|
| **Inicio** | Explicación del proyecto y flujo de trabajo |
| **Analizar** | Subir/tomar foto, zona, pH y ubicación GPS |
| **Procesando** | Indicador de carga durante visión + predicción |
| **Resultados** | Riesgo, confianza, probabilidades, clorosis, necrosis, distancia, pH |
| **Reporte IA** | Markdown generado por Gemini (o fallback local) |
| **Mapa** | Focos mineros y muestras del dataset sobre OpenStreetMap |
| **Info** | Stack, métricas del Random Forest y disclaimer |

Navegación principal con **Bottom Navigation Bar** (Inicio · Analizar · Mapa · Info).

---

## Tecnologías

- **Flutter** 3.x / **Dart** 3.8+
- **Material Design 3**
- **provider** — estado de la aplicación
- **http** — cliente REST
- **image_picker** — cámara y galería
- **geolocator** — ubicación GPS
- **flutter_map** + **latlong2** — mapa interactivo
- **flutter_markdown** — renderizado del reporte

---

## Arquitectura

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp + Bottom Nav shell
├── config/
│   ├── api_config.dart       # URL base del backend
│   └── theme.dart            # Tema M3 y colores de riesgo
├── models/
│   └── terraguard_models.dart
├── services/
│   └── api_service.dart      # Cliente HTTP (adaptador backend)
├── providers/
│   └── analysis_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── analyze_screen.dart
│   ├── processing_screen.dart
│   ├── results_screen.dart
│   ├── report_screen.dart
│   ├── map_screen.dart
│   └── about_screen.dart
└── widgets/
    └── common_widgets.dart   # Componentes reutilizables
```

**Patrón:** capa de servicios (API) → provider (estado) → pantallas/widgets.

---

## Integración con el backend

El backend original es **Streamlit** (`app.py`) sin API HTTP. Se añadió **`api_server.py`** como adaptador mínimo que reutiliza los módulos existentes **sin modificar su lógica**:

| Endpoint | Módulo reutilizado |
|---|---|
| `POST /api/analyze-image` | `vision.analizar_hoja()` |
| `POST /api/predict` | `model.predecir_riesgo()` + `data_generator.dist_a_mina_mas_cercana()` |
| `POST /api/report` | `reporte.generar_reporte()` |
| `GET /api/zones` | `data_generator.ZONAS_RIESGO` |
| `GET /api/metrics` | `model.entrenar()` → métricas |
| `GET /api/map-samples` | `data_generator.generar_dataset()` |

### Funcionalidades incompletas detectadas en el backend

1. **`app.py` importa desde `src/`** pero los módulos están en la raíz del repo (sin carpeta `src/`). Streamlit puede fallar hasta corregir imports o crear `src/`.
2. **No existía API REST** antes de `api_server.py` — el frontend depende de levantar ese servidor.
3. **Gemini** requiere API key opcional; sin ella el fallback local funciona igual.

---

## Cómo ejecutar

### 1. Backend (adaptador REST)

```bash
cd HackatonFlit
pip install -r requirements.txt
uvicorn api_server:app --reload --host 0.0.0.0 --port 8000
```

Verifica: [http://localhost:8000/health](http://localhost:8000/health)

Opcional — reporte con Gemini:

```bash
set GEMINI_API_KEY=tu_clave   # Windows
export GEMINI_API_KEY=tu_clave # Linux/macOS
```

### 2. Frontend Flutter

```bash
cd frontend_flit2026
flutter pub get
flutter run
```

### URL del backend por plataforma

Configurada en `lib/config/api_config.dart`:

| Plataforma | URL por defecto |
|---|---|
| Android emulador | `http://10.0.2.2:8000` |
| iOS simulador / Web / Desktop | `http://localhost:8000` |
| Dispositivo físico | IP de tu PC en la red local |

---

## Permisos

- **Android:** Internet, cámara, ubicación (`AndroidManifest.xml`)
- **iOS:** NSCameraUsageDescription, NSPhotoLibraryUsageDescription, NSLocationWhenInUseUsageDescription (`Info.plist`)

---

## Flujo de análisis

1. Usuario elige zona, pH y opcionalmente GPS.
2. Sube foto o activa sliders manuales de síntomas.
3. Frontend llama `POST /api/analyze-image` (si hay foto).
4. Frontend llama `POST /api/predict` con clorosis, necrosis, pH y ubicación.
5. Pantalla de resultados muestra riesgo y métricas visuales.
6. Desde resultados → `POST /api/report` para el reporte Markdown.

---

## Licencia / disclaimer

Tamizaje preliminar de apoyo a la decisión. **No reemplaza** análisis de laboratorio certificado (EPA 6020 / ICP-MS).
