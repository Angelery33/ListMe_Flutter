# ListMe

> **Gestiona todo lo que quieres ver, leer y jugar** — en un solo lugar, desde cualquier dispositivo.

ListMe es una aplicación multiplataforma (Android, Web, Windows) construida con Flutter que permite organizar colecciones personales de películas, series, libros, manga, anime y videojuegos. Los usuarios pueden crear bibliotecas, añadir ítems de forma manual o importarlos desde APIs externas (TMDb, OMDb, Google Books, MAL/Jikan), y compartir sus listas con otros usuarios mediante invitaciones.

---

## Características principales

- **Bibliotecas personalizadas** — crea y organiza colecciones por categoría (películas, series, libros, manga, anime, videojuegos)
- **Importación desde APIs** — busca y añade contenido directamente desde TMDb, OMDb, Google Books y MyAnimeList (Jikan)
- **Atributos dinámicos** — cada ítem puede tener atributos personalizados (puntuación, estado, fecha, notas…)
- **Galería de imágenes** — sube fotos a cada ítem y elige una imagen favorita como miniatura
- **Listas compartidas** — invita a otros usuarios a colaborar en tus bibliotecas
- **Búsqueda y filtros** — filtra por nombre, categoría, estado y más
- **Soporte multiidioma** — español e inglés incluidos
- **Temas y personalización** — modo claro/oscuro, colores de acento, escala de fuente
- **Claves API configurables** — introduce tus propias claves de TMDb, OMDb y Google Books desde los ajustes

---

## Capturas de pantalla

| Inicio | Detalle | Búsqueda | Ajustes |
|:------:|:-------:|:--------:|:-------:|
| *(próximamente)* | *(próximamente)* | *(próximamente)* | *(próximamente)* |

---

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| Frontend | Flutter 3 · Dart · Provider |
| Autenticación | Firebase Authentication |
| Almacenamiento de imágenes | Firebase Storage |
| Backend | Spring Boot 3 · Java 21 |
| Base de datos | PostgreSQL |
| Cache local | Hive |
| Preferencias | SharedPreferences |
| Redes | Dio · http |
| CI/CD | GitHub Actions |
| Despliegue | Docker Compose en NAS (Cloudflare Tunnel) |

---

## Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.11
- Dart SDK ≥ 3.11
- Un proyecto Firebase con **Authentication** y **Storage** habilitados
- Backend ListMe en ejecución (ver [API_Listme](../API_Listme))

---

## Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/<usuario>/list_me.git
cd list_me
flutter pub get
```

### 2. Configurar Firebase

Descarga el archivo de configuración correspondiente a tu plataforma desde la consola de Firebase y colócalo en su ubicación:

| Plataforma | Archivo | Destino |
|-----------|---------|---------|
| Android | `google-services.json` | `android/app/` |
| iOS | `GoogleService-Info.plist` | `ios/Runner/` |
| Web | `firebase_options.dart` | `lib/` |
| Windows | `google-services.json` | `windows/` |

### 3. Configurar la URL de la API

En [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart) ajusta la URL base del backend:

```dart
static const String baseUrl = 'https://tu-dominio.com/api';
```

### 4. Claves API externas (opcional)

Las claves de TMDb, OMDb y Google Books se pueden introducir desde **Ajustes → Claves API** dentro de la propia app. Si no introduces ninguna, se usa la clave por defecto del proyecto.

---

## Compilar y ejecutar

### Android

```bash
flutter build apk --release
# o instalar directamente en un dispositivo conectado:
flutter run --release
```

### Web

```bash
flutter build web --release
# El output queda en build/web/
```

### Windows

```bash
flutter build windows --release
# El ejecutable queda en build/windows/x64/runner/Release/
```

---

## Estructura del proyecto

```
lib/
├── core/
│   ├── constants/       # URLs, colores, constantes globales
│   ├── models/          # Modelos de datos (Item, List, User…)
│   ├── services/        # Servicios: API cliente, Firebase, APIs externas
│   └── utils/           # Helpers y utilidades
├── data/
│   └── items/           # Repositorios de datos
├── providers/           # Estado global (Provider / ChangeNotifier)
│   ├── auth/
│   ├── items/
│   ├── lists/
│   └── settings/
├── screens/             # Pantallas de la aplicación
│   ├── auth/
│   ├── items/
│   ├── lists/
│   ├── profile/
│   ├── settings/
│   └── social/
├── widgets/             # Widgets reutilizables
│   ├── items/
│   ├── lists/
│   └── shared/
└── main.dart
```

---

## Despliegue web (GitHub Actions)

El repositorio incluye un workflow que, en cada push a `main`, compila la versión web y la despliega en el NAS mediante SCP a través del túnel Cloudflare:

```
.github/workflows/deploy.yml
```

Los secretos necesarios en GitHub (`SSH_HOST`, `SSH_USER`, `SSH_KEY`, etc.) deben configurarse en **Settings → Secrets and variables → Actions**.

---

## Licencia

Este proyecto es de uso académico y personal. Todos los derechos reservados © 2025 Angel Cantero.
