# Escanear-Hardware-placa
Herramienta en Windows de un solo clic para extraer la tabla de hardware

Una herramienta ultraligera en Windows de un solo clic que extrae la tabla completa de componentes (GPU, Wi-Fi, BIOS, Audio, RAM) con sus identificadores de hardware (`PCI IDs`).

Ideal para consultar compatibilidad con Linux 
## 🚀 Cómo usarlo (En 1 Clic)

1. **Descarga** el archivo `Escanear-Hardware.bat` de este repositorio.
2. Dale **doble clic** para ejecutarlo en Windows.
3. Se abrirá una ventana con la tabla estructurada de tus componentes.
4. Selecciona la tabla, cópiala y pégala en tu IA favorita para consultar compatibilidad y soluciones a fallos de Kernel/BIOS.
# CMD
```bash
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm 'https://raw.githubusercontent.com/eyi3iyj3-svg/Escanear-Hardware-placa/main/Escanear-Hardware.bat')"
