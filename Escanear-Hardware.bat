<# :
@echo off
chcp 65001 >nul
title Escaner de Hardware - Windows
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $Host.UI.RawUI.BufferSize = [System.Management.Automation.Host.Size]::new(220, 1000) } catch {}; Invoke-Expression (Get-Content '%~f0' -Raw)"
echo.
echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
exit /b
#>

# ====================================================================
# CODIGO DE POWERSHELL
# ====================================================================

$components = @()

# 1. Equipo
$sys = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
if ($sys) {
    $components += [PSCustomObject]@{
        Componente  = "Equipo"
        Nombre      = ("$($sys.Manufacturer) $($sys.Model)").Trim()
        Descripcion = "Modelo de Computadora / Laptop"
        ID_O_Fecha  = "-"
    }
}

# 2. Placa Madre
$board = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
if ($board) {
    $components += [PSCustomObject]@{
        Componente  = "Placa Madre"
        Nombre      = ("$($board.Manufacturer) $($board.Product)").Trim()
        Descripcion = "Tarjeta Madre (Chipset)"
        ID_O_Fecha  = "-"
    }
}

# 3. BIOS / UEFI
$bios = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue
if ($bios) {
    $biosDate = if ($bios.ReleaseDate) { $bios.ReleaseDate.ToString("yyyy-MM-dd") } else { "N/A" }
    $components += [PSCustomObject]@{
        Componente  = "BIOS / UEFI"
        Nombre      = "$($bios.SMBIOSBIOSVersion)"
        Descripcion = "Firmware principal del sistema"
        ID_O_Fecha  = $biosDate
    }
}

# 4. Procesador (CPU)
$cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue
if ($cpu) {
    $components += [PSCustomObject]@{
        Componente  = "Procesador"
        Nombre      = ("$($cpu.Name)").Trim()
        Descripcion = "$($cpu.NumberOfCores) Nucleos / $($cpu.NumberOfLogicalProcessors) Hilos"
        ID_O_Fecha  = "-"
    }
}

# 5. Memoria RAM
if ($sys) {
    $ramGB = [math]::Round($sys.TotalPhysicalMemory / 1GB, 2)
    $components += [PSCustomObject]@{
        Componente  = "Memoria RAM"
        Nombre      = "$ramGB GB Total"
        Descripcion = "Memoria de Trabajo del Sistema"
        ID_O_Fecha  = "-"
    }
}

# 6. Almacenamiento (Discos)
Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue | ForEach-Object {
    $sizeGB = if ($_.Size) { [math]::Round($_.Size / 1GB, 2) } else { "N/A" }
    $iface  = if ($_.InterfaceType) { $_.InterfaceType } else { "Desconocida" }
    $components += [PSCustomObject]@{
        Componente  = "Disco Duro/SSD"
        Nombre      = ("$($_.Model)").Trim()
        Descripcion = "$sizeGB GB ($iface)"
        ID_O_Fecha  = "$($_.PNPDeviceID)"
    }
}

# 7. Tarjetas Graficas (GPU)
Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object {
    $components += [PSCustomObject]@{
        Componente  = "Grafica (GPU)"
        Nombre      = ("$($_.Name)").Trim()
        Descripcion = "Controlador de Video"
        ID_O_Fecha  = "$($_.PNPDeviceID)"
    }
}

# 8. Red (Wi-Fi / Ethernet)
Get-CimInstance Win32_NetworkAdapter -ErrorAction SilentlyContinue |
    Where-Object { $_.PNPDeviceID -and $_.PhysicalAdapter } | ForEach-Object {
    $components += [PSCustomObject]@{
        Componente  = "Red / Wi-Fi"
        Nombre      = ("$($_.Name)").Trim()
        Descripcion = "Tarjeta de Red"
        ID_O_Fecha  = "$($_.PNPDeviceID)"
    }
}

# 9. Chip de Audio
Get-CimInstance Win32_SoundDevice -ErrorAction SilentlyContinue | ForEach-Object {
    $components += [PSCustomObject]@{
        Componente  = "Audio"
        Nombre      = ("$($_.Name)").Trim()
        Descripcion = "Dispositivo de Sonido"
        ID_O_Fecha  = "$($_.PNPDeviceID)"
    }
}

# 10. Controladores USB
Get-CimInstance Win32_USBController -ErrorAction SilentlyContinue | ForEach-Object {
    $components += [PSCustomObject]@{
        Componente  = "Puerto USB"
        Nombre      = ("$($_.Name)").Trim()
        Descripcion = "Controlador de Puertos USB"
        ID_O_Fecha  = "$($_.PNPDeviceID)"
    }
}

# 11. Bateria (si aplica)
$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
if ($battery) {
    $components += [PSCustomObject]@{
        Componente  = "Bateria"
        Nombre      = "Bateria Integrada"
        Descripcion = "Carga actual: $($battery.EstimatedChargeRemaining)%"
        ID_O_Fecha  = "$($battery.Status)"
    }
}

# Imprimir tabla visual
$components | Format-Table -AutoSize -Wrap
