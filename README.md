# Just WPOS - Sistema de Punto de Venta Multiplataforma - Flutter App 🚀

**Just WPOS** es una aplicación simple pero efectiva de **Punto de Venta (POS)** diseñada para ser utilizada por pequeños y medianos negocios. Con una interfaz intuitiva y funcionalidades clave, la aplicación permite a los dueños de tiendas gestionar inventarios, ventas, cajeros y más desde una sola plataforma.

![Vista principal](https://raw.githubusercontent.com/rinkyn05/jwp-pos-offline/refs/heads/main/assets/app_screenshot/basic%20pos%20home.png)

---

## 🌟 Características

- **Gestión de Cajeros**: Los dueños pueden agregar cajeros y limitar sus permisos exclusivamente a realizar ventas.
- **Control de Inventarios**: Lleva un registro detallado de los productos disponibles.
- **Procesamiento de Ventas**: Realiza ventas de manera rápida y eficiente.
- **Interfaz Intuitiva**: Simple, limpia y fácil de usar para cualquier usuario.
- **Soporte Multiplataforma**: Disponible en **Android**, **iOS**, **Windows**, **macOS**, **Linux** y **Web**.
- **Desempeño Optimizado**: Diseñado para ofrecer un rendimiento fluido incluso en dispositivos con recursos limitados.
- **Sincronización Opcional**: Aunque está diseñado para trabajar offline, la integración con Firebase permite sincronización en la nube cuando sea necesario.

---

## 🛠️ Tecnologías Clave

- **Flutter y Dart**: Para desarrollo multiplataforma.
- **Firebase**: Para autenticación y almacenamiento opcional en la nube.
- **Shared Preferences**: Para soporte offline.
- **Tecnologías adicionales**:
  - **C++ (10.0%)**: Para la integración con servicios nativos.
  - **CMake (7.8%)**: Gestión de dependencias y construcción del proyecto.
  - **Inno Setup (1.8%)**: Creación de instaladores para Windows.
  - **Swift (0.9%)**: Soporte nativo para iOS.
  - **C (0.6%)**: Para integraciones específicas.
  - **Otros (0.5%)**: Complementos adicionales.

---

## 🚀 Cómo Usar

### Clonar el Repositorio
Clona el proyecto a tu máquina local utilizando el siguiente comando:

```bash
git clone https://github.com/rinkyn05/just_wpos
```

### Ejecutar la Aplicación

1. Asegúrate de tener Flutter configurado en tu sistema.
2. Ejecuta el siguiente comando desde la raíz del proyecto:

```bash
flutter run
```

3. Selecciona el dispositivo o emulador en el que deseas probar la aplicación.

### Personalización

- **Modificar Pantallas**: Edita los archivos en la carpeta `lib/screens/`.
- **Agregar Funcionalidades**: Incluye nuevos servicios en la carpeta `lib/services/`.

### Crear un Instalador para Escritorio

Para generar instaladores para Windows, macOS o Linux, sigue las instrucciones en la documentación oficial de Flutter.

---

## 🖼️ Vista Previa

### 📌 Demo en Vivo
La aplicación se encuentra en fase de desarrollo, pero puedes obtener más información en el siguiente enlace:  
[Just WPOS - Información](https://rinkyn05.github.io/jwp-pos-offline/)

### 📄 Splash
![Splash](https://raw.githubusercontent.com/rinkyn05/jwp-pos-offline/refs/heads/main/assets/app_screenshot/basic%20pos%20splash.png)

### 📄 Registro o Login
![Registro_Logion](https://raw.githubusercontent.com/rinkyn05/jwp-pos-offline/refs/heads/main/assets/app_screenshot/basic%20pos%20login%20or%20register.png)

### 📄 Registro
![Registro](https://raw.githubusercontent.com/rinkyn05/jwp-pos-offline/refs/heads/main/assets/app_screenshot/basic%20pos%20register.png)

### 📄 Productos
![Productos](https://raw.githubusercontent.com/rinkyn05/jwp-pos-offline/refs/heads/main/assets/app_screenshot/basic%20pos%20products.png)

---

## 💾 Estructura del Proyecto

El proyecto está diseñado de manera modular para facilitar la comprensión, el mantenimiento y la colaboración:

```plaintext
just_wpos/
├── lib/                      # Código principal de Flutter
│   ├── models/               # Modelos de datos
│   ├── screens/              # Pantallas principales de la app
│   ├── widgets/              # Widgets reutilizables
│   ├── services/             # Servicios y lógica de negocios
│   ├── config/               # Configuración global (temas, traducciones, etc.)
│   └── main.dart             # Punto de entrada de la aplicación
├── android/                  # Archivos específicos de Android
├── ios/                      # Archivos específicos de iOS
├── web/                      # Archivos específicos para la versión web
├── windows/                  # Archivos específicos para Windows
├── macos/                    # Archivos específicos para macOS
├── linux/                    # Archivos específicos para Linux
├── assets/                   # Imágenes, fuentes y recursos estáticos
├── pubspec.yaml              # Configuración de dependencias y recursos
└── README.md                 # Documentación del proyecto
```

---

## 📝 Licencia

Este proyecto está bajo la licencia **MIT**. Puedes usarlo, modificarlo y distribuirlo libremente. 🎉

---

## ❤️ Contribuciones

¡Las contribuciones son bienvenidas! Si deseas agregar más funcionalidades o mejorar el diseño, no dudes en hacer un pull request.

---

## 📖 Recursos Adicionales

Para más información, consulta los siguientes enlaces:

- [Página de Inicio e Información](https://rinkyn05.github.io/app/)
- [Estructura del Proyecto](#-estructura-del-proyecto)
