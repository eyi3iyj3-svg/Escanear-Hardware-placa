# ====================================================================
# Escaner de Hardware - Windows (version PowerShell pura)
# ====================================================================
$ErrorActionPreference = 'SilentlyContinue'
$c = @()

$sys   = Get-CimInstance Win32_ComputerSystem
$board = Get-CimInstance Win32_BaseBoard
$bios  = Get-CimInstance Win32_BIOS
$cpu   = Get-CimInstance Win32_Processor

if ($sys) {
    $c += [PSCustomObject]@{ Componente="Equipo"; Nombre=("$($sys.Manufacturer) $($sys.Model)").Trim(); Descripcion="Modelo de Computadora / Laptop"; ID_O_Fecha="-" }
}
if ($board) {
    $c += [PSCustomObject]@{ Componente="Placa Madre"; Nombre=("$($board.Manufacturer) $($board.Product)").Trim(); Descripcion="Tarjeta Madre (Chipset)"; ID_O_Fecha="-" }
}
if ($bios) {
    $d = if ($bios.ReleaseDate) { $bios.ReleaseDate.ToString("yyyy-MM-dd") } else { "N/A" }
    $c += [PSCustomObject]@{ Componente="BIOS / UEFI"; Nombre=$bios.SMBIOSBIOSVersion; Descripcion="Firmware principal"; ID_O_Fecha=$d }
}
if ($cpu) {
    $c += [PSCustomObject]@{ Componente="Procesador"; Nombre=("$($cpu.Name)").Trim(); Descripcion="$($cpu.NumberOfCores) Nucleos / $($cpu.NumberOfLogicalProcessors) Hilos"; ID_O_Fecha="-" }
}
if ($sys) {
    $ram = [math]::Round($sys.TotalPhysicalMemory / 1GB, 2)
    $c += [PSCustomObject]@{ Componente="Memoria RAM"; Nombre="$ram GB Total"; Descripcion="Memoria de Trabajo"; ID_O_Fecha="-" }
}

Get-CimInstance Win32_DiskDrive | ForEach-Object {
    $sizeGB = if ($_.Size) { [math]::Round($_.Size / 1GB, 2) } else { "N/A" }
    $iface  = if ($_.InterfaceType) { $_.InterfaceType } else { "Desconocida" }
    $c += [PSCustomObject]@{ Componente="Disco Duro/SSD"; Nombre=("$($_.Model)").Trim(); Descripcion="$sizeGB GB ($iface)"; ID_O_Fecha=$_.PNPDeviceID }
}
Get-CimInstance Win32_VideoController | ForEach-Object {
    $c += [PSCustomObject]@{ Componente="Grafica (GPU)"; Nombre=("$($_.Name)").Trim(); Descripcion="Controlador de Video"; ID_O_Fecha=$_.PNPDeviceID }
}
Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PNPDeviceID -and $_.PhysicalAdapter } | ForEach-Object {
    $c += [PSCustomObject]@{ Componente="Red / Wi-Fi"; Nombre=("$($_.Name)").Trim(); Descripcion="Tarjeta de Red"; ID_O_Fecha=$_.PNPDeviceID }
}
Get-CimInstance Win32_SoundDevice | ForEach-Object {
    $c += [PSCustomObject]@{ Componente="Audio"; Nombre=("$($_.Name)").Trim(); Descripcion="Dispositivo de Sonido"; ID_O_Fecha=$_.PNPDeviceID }
}
Get-CimInstance Win32_USBController | ForEach-Object {
    $c += [PSCustomObject]@{ Componente="Puerto USB"; Nombre=("$($_.Name)").Trim(); Descripcion="Controlador de Puertos USB"; ID_O_Fecha=$_.PNPDeviceID }
}
$bat = Get-CimInstance Win32_Battery
if ($bat) {
    $c += [PSCustomObject]@{ Componente="Bateria"; Nombre="Bateria Integrada"; Descripcion="Carga actual: $($bat.EstimatedChargeRemaining)%"; ID_O_Fecha=$bat.Status }
}

$c | Format-Table -AutoSize -Wrap
