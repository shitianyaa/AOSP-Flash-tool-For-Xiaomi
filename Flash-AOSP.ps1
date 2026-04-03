# AOSP Flash Tool v1.0

param([string]$RomFile = "", [string]$Language = "", [switch]$Help)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$ErrorActionPreference = "Continue"

function Get-ScriptDir {
    if ($MyInvocation.MyCommand.Path) {
        return Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    if ($PSScriptRoot) {
        return $PSScriptRoot
    }
    $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    return Split-Path -Parent $exePath
}

$Script:Config = @{
    Version = "1.0.3"
    ScriptDir = Get-ScriptDir
    Language = ""
    ToolsDir = ""
    OutputDir = ""
    PayloadDumperUrl = "https://github.com/ssut/payload-dumper-go/releases/download/1.3.0/payload-dumper-go_1.3.0_windows_amd64.tar.gz"
    PayloadDumperExe = "payload-dumper-go.exe"
    FlashOrder = @("boot", "init_boot", "vendor_boot", "dtbo", "recovery")
    Partitions = @("boot", "init_boot", "vendor_boot", "dtbo", "recovery")
}

$Script:Labels_zh = @{
    Header = "AOSP 刷机工具 v{0}"
    Step = "[步骤] {0}"
    Warn = "[警告] {0}"
    Err = "[错误] {0}"
    OK = "[完成] {0}"
    MainMenu = "主菜单"
    DeviceOps = "设备操作"
    ToolsMgmt = "工具管理"
    DeviceConnected = "设备: 已连接 (ADB)"
    DeviceFastboot = "设备: Fastboot 模式"
    DeviceSideload = "设备: sideload 模式"
    DeviceOffline = "设备: 未连接"
    NoDeviceConnected = "未检测到设备，请连接设备后重试。"
    RefreshDevice = "刷新设备状态"
    FullFlash = "完整刷机流程 (推荐)"
    ExtractOnly = "仅提取 payload.bin"
    FlashImages = "刷入自定义镜像"
    SideloadOnly = "仅 ADB Sideload"
    StartSideload = "正在启动 Sideload..."
    DeviceMenu = "设备操作"
    ToolsMenu = "工具完整性验证"
    ToolsVerifyTitle = "工具完整性验证"
    ToolsVerifyDesc = "请按以下步骤验证工具是否正常工作："
    ToolsVerifyStep1 = "1. 连接手机并开启 USB 调试"
    ToolsVerifyStep2 = "2. 在手机上点击'允许此计算机调试'"
    ToolsVerifyConnected = "是否已连接手机并开启 USB 调试？"
    ToolsVerifyNoDevice = "请连接手机后重新运行验证"
    ToolsVerifyAdbNotInstalled = "ADB/Fastboot 未安装"
    ToolsVerifyDownload = "是否下载安装？"
    ToolsVerifyStep = "Step 1: 检测 ADB 设备..."
    ToolsVerifyAdbOk = "ADB 正常！设备已连接"
    ToolsVerifyReboot = "是否重启到 Fastboot 模式？"
    ToolsVerifyRebooting = "正在重启到 Fastboot..."
    ToolsVerifyWaiting = "等待设备进入 Fastboot..."
    ToolsVerifyFbOk = "Fastboot 模式正常！验证完成"
    ToolsVerifyDeviceInfo = "设备详情:"
    ToolsVerifyFbFailed = "设备未能进入 Fastboot 模式"
    ToolsVerifyCheck = "请检查："
    ToolsVerifyCheckUsb = "- 手机是否开启 USB 调试"
    ToolsVerifyCheckAllow = "- 是否点击了'允许此计算机调试'"
    ToolsVerifyCheckDriver = "- 驱动是否正确安装"
    DriverInstallHint = "首次刷机请先安装安卓驱动: https://lsdy.top/azqddownload"
    DriverInstallTitle = "首次刷机请先安装安卓驱动"
    DriverInstallIgnore = "如已安装驱动，请忽略此提示"
    DriverInstallLink = "驱动下载: https://lsdy.top/azqddownload"
    DriverInstallCheck = "是否已安装驱动？"
    DriverInstallContinue = "继续刷机..."
    DriverInstallDownload = "是否前往下载驱动页面？"
    DriverInstallDone = "请安装驱动后重新运行脚本"
    Exit = "退出"
    Back = "返回"
    Reboot = "重启设备"
    RebootFastboot = "重启到 Bootloader"
    RebootRecovery = "重启到 Recovery"
    DeviceInfo = "设备信息"
    InstallAdb = "安装 ADB/Fastboot"
    InstallPayload = "安装 Payload Dumper"
    AdbFastboot = "ADB/Fastboot: "
    Installed = "已安装 ({0})"
    NotInstalled = "未安装"
    PayloadDumper = "Payload Dumper: "
    SelectRom = "选择 ROM 文件:"
    EnterPath = "手动输入路径"
    ImagesDir = "选择已解压镜像文件夹"
    EnterImagesDir = "输入文件夹路径"
    NoRomFound = "未找到 ROM 文件"
    FileNotFound = "文件不存在"
    DirNotFound = "目录不存在"
    InvalidChoice = "无效选择"
    Cancelled = "已取消"
    StartFlashing = "开始刷机？"
    StartFlash = "开始刷机"
    DeviceNotConnected = "设备未连接"
    NeedFastboot = "设备必须在 Fastboot 模式"
    Step1RebootFastboot = "步骤 1/6: 重启到 Fastboot"
    WaitingFastboot = "等待 Fastboot..."
    EnterFastbootFailed = "设备进入 Fastboot 失败"
    ManualRebootFastboot = "请手动重启到 Fastboot"
    DeviceInFastboot = "设备已进入 Fastboot 模式"
    FlashPartitions = "步骤 2/6: 刷入分区 (boot/init_boot/dtbo/vendor_boot)"
    FlashRecovery = "步骤 3/6: 刷入 Recovery"
    Flashing = "正在刷入: {0}"
    Flashed = "{0} 已刷入"
    FlashFailed = "{0} 失败"
    FlashSuccess = "{0} 成功"
    SkipNotFound = "跳过 {0} (未找到)"
    FlashedCount = "已刷入 {0} 个分区"
    Step4RebootRecovery = "步骤 4/6: 重启到 Recovery"
    DeviceWillReboot = "设备将重启到 Recovery"
    ReadyContinue = "是否继续？"
    WaitRecovery = "等待 Recovery..."
    Step5FactoryReset = "步骤 5/6: 双清 (Factory Reset)"
    OnDeviceFactoryReset = "在设备上: 选择 'Factory Reset' -> 'Format data / factory reset'"
    FactoryResetDone = "双清完成？"
    Step6Sideload = "步骤 6/6: ADB Sideload 刷入 ROM"
    OnDeviceApply = "在设备上: Apply update -> Apply from ADB"
    WaitSideloadMode = "等待 sideload 模式..."
    NotInSideload = "设备不在 Sideload 模式"
    DeviceInSideload = "设备已进入 Sideload 模式"
    Sideload = "ADB Sideload"
    NoRomZip = "未找到 ROM ZIP，跳过 sideload"
    PartitionComplete = "分区刷入完成！"
    FlashingZip = "正在刷入: {0}"
    MayTakeTime = "此过程可能需要 5-15 分钟..."
    FlashComplete = "刷机完成！"
    SelectReboot = "请在设备上选择 'Reboot system now'"
    InstallGapps = "安装 GApps？"
    GappsNote = "注意: 如果需要 GApps，请不要先重启到系统！"
    GappsInstruction = "如需安装 GApps，在 recovery 中选择 'Apply update' -> 'Apply from ADB'"
    WantGapps = "是否需要安装 Google 应用 (GApps)？"
    AfterRomGapps = "请选择 GApps ZIP 文件进行 sideload"
    AfterRomSideload = "刷入 ROM 后，可根据需要安装 GApps"
    ReadyToReboot = "准备重启到系统？"
    Model = "型号: {0}"
    Android = "安卓版本: {0}"
    UnlockingWarn = "解锁将清除所有数据！"
    ConfirmUnlock = "确认？"
    DownloadingTools = "正在下载 Platform Tools..."
    Extract = "正在解压..."
    PlatformToolsOk = "Platform Tools 已安装"
    DownloadFailed = "下载失败: {0}"
    DownloadingPayload = "正在下载 payload-dumper-go..."
    PayloadOk = "payload-dumper-go 已安装"
    AltFailed = "备用方案也失败: {0}"
    AdbNotFound = "未找到 ADB"
    FastbootNotFound = "未找到 Fastboot"
    CannotFind = "无法找到: {0}"
    ExtractingPayload = "正在提取 payload.bin"
    ExtractionComplete = "提取完成"
    ExtractionFailed = "提取失败"
    Error = "错误: {0}"
    Found = "已找到: {0}"
    GoodBye = "再见！"
    PressEnter = "按回车继续"
    EnterConfirmCancel = "输入 1 确认，0 取消"
    Usage = "用法: .\Flash-AOSP.ps1 [-RomFile 路径] [-Language 语言] [-Help]"
    ToolNotFound = "未找到工具"
    AdbCmd = "adb {0}"
    FastbootCmd = "fastboot {0}"
    State = "状态: {0}"
    Sent = "已发送"
    UnsupportedFormat = "不支持的格式"
    NoPayloadInZip = "ZIP 中没有 payload.bin"
    WaitRecoveryMode = "等待 Recovery 模式..."
    SelectLanguage = "选择语言 / Select Language"
    LanguageChinese = "中文"
    LanguageEnglish = "English"
    SaveLanguage = "保存语言偏好？"
    LanguageSaved = "语言已保存"
    SwitchLanguage = "切换语言"
    CurrentLanguage = "当前语言: {0}"
    LanguageSwitched = "语言已切换"
    AdbModeHint = "提示: 可选择 [5] 设备操作 重启到其他模式"
}

$Script:Labels_en = @{
    Header = "AOSP Flash Tool v{0}"
    Step = "[STEP] {0}"
    Warn = "[WARN] {0}"
    Err = "[ERROR] {0}"
    OK = "[OK] {0}"
    MainMenu = "Main Menu"
    DeviceOps = "Device Operations"
    ToolsMgmt = "Tools Management"
    DeviceConnected = "Device: Connected (ADB)"
    DeviceFastboot = "Device: Fastboot mode"
    DeviceSideload = "Device: Sideload mode"
    DeviceOffline = "Device: Not connected"
    NoDeviceConnected = "No device connected. Please connect your device and retry."
    RefreshDevice = "Refresh device status"
    FullFlash = "Full flash process (recommended)"
    ExtractOnly = "Extract payload.bin only"
    FlashImages = "Flash custom image"
    SideloadOnly = "ADB Sideload only"
    StartSideload = "Starting Sideload..."
    DeviceMenu = "Device operations"
    ToolsMenu = "Tools Verify"
    ToolsVerifyTitle = "Tools Verify"
    ToolsVerifyDesc = "Follow these steps to verify tools:"
    ToolsVerifyStep1 = "1. Connect phone and enable USB debugging"
    ToolsVerifyStep2 = "2. Tap 'Allow' on your phone"
    ToolsVerifyConnected = "Have you connected phone with USB debugging enabled?"
    ToolsVerifyNoDevice = "Please connect phone and try again"
    ToolsVerifyAdbNotInstalled = "ADB/Fastboot not installed"
    ToolsVerifyDownload = "Download and install?"
    ToolsVerifyStep = "Step 1: Checking ADB device..."
    ToolsVerifyAdbOk = "ADB OK! Device connected"
    ToolsVerifyReboot = "Reboot to Fastboot mode?"
    ToolsVerifyRebooting = "Rebooting to Fastboot..."
    ToolsVerifyWaiting = "Waiting for Fastboot..."
    ToolsVerifyFbOk = "Fastboot mode OK! Verify complete"
    ToolsVerifyDeviceInfo = "Device Info:"
    ToolsVerifyFbFailed = "Failed to enter Fastboot mode"
    ToolsVerifyCheck = "Please check:"
    ToolsVerifyCheckUsb = "- Is USB debugging enabled"
    ToolsVerifyCheckAllow = "- Did you tap 'Allow' on phone"
    ToolsVerifyCheckDriver = "- Is driver installed correctly"
    DriverInstallHint = "Please install Android driver first: https://lsdy.top/azqddownload"
    DriverInstallTitle = "Please install Android driver first"
    DriverInstallIgnore = "If already installed, ignore this"
    DriverInstallLink = "Driver download: https://lsdy.top/azqddownload"
    DriverInstallCheck = "Have you installed the driver?"
    DriverInstallContinue = "Continuing flash..."
    DriverInstallDownload = "Go to download page?"
    DriverInstallDone = "Please install driver and run script again"
    Exit = "Exit"
    Back = "Back"
    Reboot = "Reboot device"
    RebootFastboot = "Reboot to Bootloader"
    RebootRecovery = "Reboot to Recovery"
    DeviceInfo = "Device info"
    InstallAdb = "Install ADB/Fastboot"
    InstallPayload = "Install Payload Dumper"
    AdbFastboot = "ADB/Fastboot: "
    Installed = "Installed ({0})"
    NotInstalled = "Not installed"
    PayloadDumper = "Payload Dumper: "
    SelectRom = "Select ROM file:"
    EnterPath = "Enter full path manually"
    ImagesDir = "Select folder with extracted images"
    EnterImagesDir = "Enter folder path"
    NoRomFound = "No ROM file found"
    FileNotFound = "File not found"
    DirNotFound = "Directory not found"
    InvalidChoice = "Invalid choice"
    Cancelled = "Cancelled"
    StartFlashing = "Start flashing?"
    StartFlash = "Start Flashing"
    DeviceNotConnected = "Device not connected"
    NeedFastboot = "Device must be in Fastboot mode"
    Step1RebootFastboot = "Step 1/6: Reboot to Fastboot"
    WaitingFastboot = "Waiting for Fastboot..."
    EnterFastbootFailed = "Device failed to enter Fastboot"
    ManualRebootFastboot = "Please manually reboot to Fastboot"
    DeviceInFastboot = "Device in Fastboot mode"
    FlashPartitions = "Step 2/6: Flash partitions (boot/init_boot/dtbo/vendor_boot)"
    FlashRecovery = "Step 3/6: Flash Recovery"
    Flashing = "Flashing: {0}"
    Flashed = "{0} flashed"
    FlashFailed = "{0} failed"
    FlashSuccess = "{0} success"
    SkipNotFound = "Skip {0} (not found)"
    FlashedCount = "Flashed {0} partitions"
    Step4RebootRecovery = "Step 4/6: Reboot to Recovery"
    DeviceWillReboot = "Device will reboot to Recovery"
    ReadyContinue = "Ready to continue?"
    WaitRecovery = "Waiting for Recovery..."
    Step5FactoryReset = "Step 5/6: Factory Reset"
    OnDeviceFactoryReset = "On device: Select 'Factory Reset' -> 'Format data / factory reset'"
    FactoryResetDone = "Factory reset complete?"
    Step6Sideload = "Step 6/6: ADB Sideload ROM"
    OnDeviceApply = "On device: Apply update -> Apply from ADB"
    WaitSideloadMode = "Waiting for sideload mode"
    NotInSideload = "Device not in Sideload mode"
    DeviceInSideload = "Device in Sideload mode"
    Sideload = "ADB Sideload"
    NoRomZip = "No ROM ZIP found, skip sideload"
    PartitionComplete = "Partition flashing complete!"
    FlashingZip = "Flashing: {0}"
    MayTakeTime = "This may take 5-15 minutes..."
    FlashComplete = "Flash Complete!"
    SelectReboot = "Select 'Reboot system now' on device"
    InstallGapps = "Install GApps?"
    GappsNote = "Note: If you need GApps, do NOT reboot to system yet!"
    GappsInstruction = "If you want GApps, select 'Apply update' -> 'Apply from ADB' in recovery"
    WantGapps = "Do you need to install Google Apps (GApps)?"
    AfterRomGapps = "Now select GApps ZIP file for sideload"
    AfterRomSideload = "After flashing ROM, you can install GApps if needed"
    ReadyToReboot = "Ready to reboot to system?"
    Model = "Model: {0}"
    Android = "Android: {0}"
    UnlockingWarn = "Unlocking will erase all data!"
    ConfirmUnlock = "Confirm?"
    DownloadingTools = "Downloading Platform Tools..."
    Extract = "Extracting..."
    PlatformToolsOk = "Platform Tools installed"
    DownloadFailed = "Download failed: {0}"
    DownloadingPayload = "Downloading payload-dumper-go..."
    PayloadOk = "payload-dumper-go installed"
    AltFailed = "Alternative also failed: {0}"
    AdbNotFound = "ADB not found"
    FastbootNotFound = "Fastboot not found"
    CannotFind = "Cannot find: {0}"
    ExtractingPayload = "Extracting payload.bin"
    ExtractionComplete = "Extraction complete"
    ExtractionFailed = "Extraction failed"
    Error = "Error: {0}"
    Found = "Found: {0}"
    GoodBye = "Goodbye!"
    PressEnter = "Press Enter to continue"
    EnterConfirmCancel = "Enter 1 to confirm, 0 to cancel"
    Usage = "Usage: .\Flash-AOSP.ps1 [-RomFile path] [-Language lang] [-Help]"
    ToolNotFound = "Tool not found"
    AdbCmd = "adb {0}"
    FastbootCmd = "fastboot {0}"
    State = "State: {0}"
    Sent = "Sent"
    UnsupportedFormat = "Unsupported format"
    NoPayloadInZip = "No payload.bin in ZIP"
    WaitRecoveryMode = "Waiting for Recovery mode..."
    SelectLanguage = "Select Language / 选择语言"
    LanguageChinese = "中文"
    LanguageEnglish = "English"
    SaveLanguage = "Save language preference?"
    LanguageSaved = "Language saved"
    SwitchLanguage = "Switch Language"
    CurrentLanguage = "Current language: {0}"
    LanguageSwitched = "Language switched"
    AdbModeHint = "Tip: Select [5] Device Operations to reboot to other modes"
}

function T {
    param([string]$Key, [string]$P1 = "", [string]$P2 = "")
    $labels = if ($Script:Config.Language -eq "en") { $Script:Labels_en } else { $Script:Labels_zh }
    $text = $labels[$Key]
    if ($P1) { $text = $text -f $P1 }
    if ($P2) { $text = $text -f $P2 }
    return $text
}

function Render-MainMenu {
    param([string]$state)
    Write-Header
    Write-Host (T "DriverInstallHint") -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Device: " -NoNewline
    switch ($state) {
        "device"   { Write-Host (T "DeviceConnected") -ForegroundColor Green }
        "fastboot" { Write-Host (T "DeviceFastboot") -ForegroundColor Yellow }
        "sideload" { Write-Host (T "DeviceSideload") -ForegroundColor Magenta }
        default    { Write-Host (T "DeviceOffline") -ForegroundColor Red }
    }
    if ($state -eq "device") {
        Write-Host (T "AdbModeHint") -ForegroundColor Cyan
    }
    Write-Host ""
    $curLang = if ($Script:Config.Language -eq "en") { "English" } else { "中文" }
    Write-Host "  Language: $curLang" -ForegroundColor Cyan
    Write-Host (T "MainMenu") -ForegroundColor Yellow
    Write-Host "-----------"
    Write-Host "  [R] Refresh device status"
    Write-Host "  [1] $(T 'FullFlash')"
    Write-Host "  [2] $(T 'ExtractOnly')"
    Write-Host "  [3] $(T 'FlashImages')"
    Write-Host "  [4] $(T 'SideloadOnly')"
    Write-Host "  [5] $(T 'DeviceMenu')"
    Write-Host "  [6] $(T 'ToolsMenu')"
    Write-Host "  [L] $(T 'SwitchLanguage')"
    Write-Host "  [0] $(T 'Exit')"
    Write-Host ""
}

# Returns current device state: device / fastboot / sideload / offline
function Get-DeviceState {
    $r = (Invoke-ADB "devices").Output
    if ($r -match "\tdevice") { return "device" }
    if ($r -match "sideload") { return "sideload" }
    $fb = (Invoke-Fastboot "devices").Output
    if ($fb -match "fastboot") { return "fastboot" }
    return "offline"
}
function Initialize-Paths {
    $Script:Config.ToolsDir = Join-Path $Script:Config.ScriptDir "tools"
    $Script:Config.OutputDir = Join-Path $Script:Config.ScriptDir "output"
    if (-not (Test-Path $Script:Config.ToolsDir)) { New-Item -ItemType Directory -Path $Script:Config.ToolsDir -Force | Out-Null }
    if (-not (Test-Path $Script:Config.OutputDir)) { New-Item -ItemType Directory -Path $Script:Config.OutputDir -Force | Out-Null }
}

function Write-Header { Write-Host ""; Write-Host "============================================" -ForegroundColor Cyan; Write-Host "    $(T 'Header' $Script:Config.Version)" -ForegroundColor Cyan; Write-Host "============================================" -ForegroundColor Cyan; Write-Host "" }
function Write-Step { param([string]$M) Write-Host (T 'Step' $M) -ForegroundColor Green }
function Write-Warn { param([string]$M) Write-Host (T 'Warn' $M) -ForegroundColor Yellow }
function Write-Err { param([string]$M) Write-Host (T 'Err' $M) -ForegroundColor Red }
function Write-OK { param([string]$M) Write-Host (T 'OK' $M) -ForegroundColor Green }

function Get-Input { param([string]$P) Write-Host -NoNewline "$P "; return (Read-Host).Trim() }
function Get-YesNo { param([string]$P) Write-Host -NoNewline "$P (y/n): "; $r = (Read-Host).Trim(); return ($r -eq 'y' -or $r -eq 'Y') }

function Find-PlatformTools {
    $paths = @(
        $Script:Config.ToolsDir,
        (Join-Path $Script:Config.ScriptDir "platform-tools"),
        "D:\platform-tools-latest-windows\platform-tools",
        "C:\platform-tools",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools"
    )
    foreach ($p in $paths) {
        $a = Join-Path $p "adb.exe"
        $f = Join-Path $p "fastboot.exe"
        if ((Test-Path $a) -and (Test-Path $f)) {
            try {
                $test = & $a version 2>&1
                if ($LASTEXITCODE -eq 0 -or $test -match "Android Debug Bridge") {
                    return @{ADB=$a; Fastboot=$f; Dir=$p}
                }
            } catch {}
        }
    }
    return $null
}

function Install-PlatformTools {
    Write-Step (T "DownloadingTools")
    $url = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    $zipPath = Join-Path $Script:Config.ToolsDir "platform-tools.zip"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient; $wc.DownloadFile($url, $zipPath)
        Expand-Archive -Path $zipPath -DestinationPath $Script:Config.ScriptDir -Force
        Remove-Item $zipPath -Force
        Write-OK (T "PlatformToolsOk"); return $true
    } catch { Write-Err (T "DownloadFailed" $_); return $false }
}

function Install-PayloadDumper {
    $dp = Join-Path $Script:Config.ToolsDir $Script:Config.PayloadDumperExe
    if (Test-Path $dp) { return $true }
    Write-Step (T "DownloadingPayload")
    $tarPath = Join-Path $Script:Config.ToolsDir "payload-dumper.tar.gz"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient; $wc.DownloadFile($Script:Config.PayloadDumperUrl, $tarPath)
        Write-Host "  $(T 'Extract')"
        tar -xzf $tarPath -C $Script:Config.ToolsDir
        Remove-Item $tarPath -Force
        Write-OK (T "PayloadOk"); return $true
    } catch { 
        Write-Err (T "DownloadFailed" $_)
        Write-Host "Trying alternative method..."
        try {
            $zipPath = Join-Path $Script:Config.ToolsDir "payload-dumper.zip"
            $wc.DownloadFile("https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_windows_amd64.zip", $zipPath)
            Expand-Archive -Path $zipPath -DestinationPath $Script:Config.ToolsDir -Force
            Remove-Item $zipPath -Force
            Write-OK (T "PayloadOk"); return $true
        } catch { Write-Err (T "AltFailed" $_); return $false }
    }
}

function Verify-Tools {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  验证工具是否正常工作" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "请按以下步骤操作：" -ForegroundColor Yellow
    Write-Host "1. 连接手机并开启 USB 调试"
    Write-Host "2. 在手机上点击'允许此计算机调试'"
    Write-Host ""
    if (Get-YesNo "是否已连接手机并开启 USB 调试？") {
        $t = Find-PlatformTools
        if (-not $t) {
            Write-Err "ADB/Fastboot 未安装"
            Get-Input "按回车返回"
            return
        }
        Write-Host ""
        Write-Host "检测设备..." -ForegroundColor Cyan
        $devices = & $t.ADB devices 2>&1
        if ($devices -match "\tdevice") {
            Write-Host ""
            Write-OK "ADB 正常工作！设备已连接"
            Write-Host ""
            Write-Host "设备详情:" -ForegroundColor Cyan
            $model = & $t.ADB shell getprop ro.product.model 2>$null
            $brand = & $t.ADB shell getprop ro.product.brand 2>$null
            $android = & $t.ADB shell getprop ro.build.version.release 2>$null
            Write-Host "  品牌: $brand" -ForegroundColor Green
            Write-Host "  型号: $model" -ForegroundColor Green
            Write-Host "  Android: $android" -ForegroundColor Green
        } else {
            Write-Err "未检测到设备"
            Write-Host ""
            Write-Host "请检查：" -ForegroundColor Yellow
            Write-Host "  - 手机是否开启 USB 调试"
            Write-Host "  - 是否点击了'允许此计算机调试'"
            Write-Host "  - 驱动是否正确安装"
        }
        Get-Input "按回车返回"
    }
}

function Invoke-ADB {
    param([string]$Arguments, [int]$TimeoutSeconds = 10)
    $t = Find-PlatformTools
    if (-not $t) { Write-Err (T "AdbNotFound"); return $null }
    Write-Host "  > $(T 'AdbCmd' $Arguments)" -ForegroundColor DarkGray
    $outFile = "$env:TEMP\adb_out_$PID.txt"
    $errFile = "$env:TEMP\adb_err_$PID.txt"
    $p = Start-Process -FilePath $t.ADB -ArgumentList ($Arguments -split ' ') -NoNewWindow -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    $completed = $p.WaitForExit($TimeoutSeconds * 1000)
    if (-not $completed) {
        Stop-Process $p.Id -Force -ErrorAction SilentlyContinue
        Remove-Item $outFile,$errFile -ErrorAction SilentlyContinue
        return @{Success=$false; Output=""; ExitCode=-1}
    }
    Start-Sleep -Milliseconds 500
    $exitCode = $p.ExitCode
    $output = Get-Content $outFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    $erroutput = Get-Content $errFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    Remove-Item $outFile,$errFile -ErrorAction SilentlyContinue
    $combined = ""
    if ($output) { $combined += $output }
    if ($erroutput) { $combined += $erroutput }
    if ($combined) { Write-Host $combined }
    $hasSuccess = $combined -match "OKAY|Total xfer|success"
    $isReboot = $Arguments -match "^reboot"
    return @{Success = ($exitCode -eq 0 -or $hasSuccess -or $isReboot); Output = $combined; ExitCode = $exitCode}
}

function Invoke-Fastboot {
    param([string]$Arguments, [int]$TimeoutSeconds = 5)
    $t = Find-PlatformTools
    if (-not $t) { Write-Err (T "FastbootNotFound"); return $null }
    Write-Host "  > $(T 'FastbootCmd' $Arguments)" -ForegroundColor DarkGray
    $outFile = "$env:TEMP\fb_out_$PID.txt"
    $errFile = "$env:TEMP\fb_err_$PID.txt"
    $p = Start-Process -FilePath $t.Fastboot -ArgumentList ($Arguments -split ' ') -NoNewWindow -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    $completed = $p.WaitForExit($TimeoutSeconds * 1000)
    if (-not $completed) {
        Stop-Process $p.Id -Force -ErrorAction SilentlyContinue
        Remove-Item $outFile,$errFile -ErrorAction SilentlyContinue
        return @{Success=$false; Output=""; ExitCode=-1}
    }
    Start-Sleep -Milliseconds 500
    $exitCode = $p.ExitCode
    $output = Get-Content $outFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    $erroutput = Get-Content $errFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    Remove-Item $outFile,$errFile -ErrorAction SilentlyContinue
    $combined = ""
    if ($output) { $combined += $output }
    if ($erroutput) { $combined += $erroutput }
    if ($combined) { Write-Host $combined }
    $hasOkay = $combined -match "OKAY"
    $isReboot = $Arguments -match "^reboot"
    return @{Success = ($exitCode -eq 0 -or $hasOkay -or $isReboot); Output = $combined; ExitCode = $exitCode}
}



function Extract-PayloadBin {
    param([string]$PayloadPath, [string]$OutputDir, [string[]]$Partitions = @())
    if (-not (Test-Path $PayloadPath)) { Write-Err (T "CannotFind" $PayloadPath); return $false }
    if (-not (Install-PayloadDumper)) { return $false }
    $dp = Join-Path $Script:Config.ToolsDir $Script:Config.PayloadDumperExe
    Write-Step (T "ExtractingPayload")
    try {
        Remove-Item -Path "$OutputDir\*" -Recurse -Force -ErrorAction SilentlyContinue
        $args = @("-o", $OutputDir)
        if ($Partitions.Count -gt 0) {
            $args += "-p"
            $args += ($Partitions -join ",")
        }
        $args += $PayloadPath
        $outFile = [System.IO.Path]::GetTempFileName()
        $errFile = [System.IO.Path]::GetTempFileName()
        $p = Start-Process -FilePath $dp -ArgumentList $args -NoNewWindow -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
        $p.WaitForExit()
        Start-Sleep -Milliseconds 500
        if (-not $p.HasExited) { $p.Kill() }
        $exitCode = 0
        try { $exitCode = $p.ExitCode } catch {}
        $output = [System.IO.File]::ReadAllText($outFile)
        $erroutput = [System.IO.File]::ReadAllText($errFile)
        Remove-Item $outFile, $errFile -ErrorAction SilentlyContinue
        $combined = ""
        if ($output) { $combined += $output }
        if ($erroutput) { $combined += $erroutput }
        if ($combined) {
            $cleanOutput = $combined -replace '\x1b\[[0-9;]*[A-Za-z]', ''
            $cleanOutput = $cleanOutput -replace '[.\s]+$', ''
            $cleanOutput = $cleanOutput -replace '^\s+', ''
            $cleanOutput = $cleanOutput.Trim()
        }
        $foundCount = 0
        foreach ($pname in $Partitions) {
            if (Test-Path (Join-Path $OutputDir "$pname.img")) { $foundCount++ }
        }
        if ($foundCount -eq $Partitions.Count -and $Partitions.Count -gt 0) { Write-OK (T "ExtractionComplete"); return $true }
        if ($Partitions.Count -eq 0) { Write-OK (T "ExtractionComplete"); return $true }
        Write-Err "Extraction failed"
        return $false
    } catch { Write-Err (T "Error" $_); return $false }
}

function Find-RomFile {
    $dir = $Script:Config.ScriptDir
    $zips = Get-ChildItem -Path $dir -Filter "*.zip" -File
    if ($zips.Count -gt 0) { return $zips[0].FullName }
    $pf = Join-Path $dir "payload.bin"
    if (Test-Path $pf) { return $pf }
    return $null
}

function Select-RomFile {
    Write-Host ""; Write-Host (T "SelectRom") -ForegroundColor Yellow
    Write-Host "  [1] Use output folder (extracted images)"
    Write-Host "  [2] Enter full path manually"
    Write-Host "  [3] Select other folder with extracted images"
    Write-Host "  [0] Exit"
    $c = Get-Input "Select [0-3]"
    switch ($c) {
        "0" { return $null }
        "1" { 
            $outDir = $Script:Config.OutputDir
            if (Test-Path $outDir) { 
                $imgFiles = Get-ChildItem -Path $outDir -Filter "*.img" -File
                if ($imgFiles.Count -gt 0) { return "DIR:$outDir" }
                Write-Err "No .img files found in output folder"
                return $null
            }
            Write-Err "Output folder not found"
            return $null
        }
        "2" { $p = Get-Input (T "EnterPath"); if (Test-Path $p) { return $p } Write-Err (T "FileNotFound"); return $null }
        "3" { $p = Get-Input (T "EnterImagesDir"); if (Test-Path $p) { return "DIR:$p" } Write-Err (T "DirNotFound"); return $null }
        default { Write-Err (T "InvalidChoice"); return $null }
    }
}

function Start-FlashProcess {
    param([string]$ImageDir, [string]$RomZip, [string]$GappsZip)
    Write-Host ""; Write-Host "========================================" -ForegroundColor Cyan; Write-Host "    $(T 'StartFlash')" -ForegroundColor Cyan; Write-Host "========================================" -ForegroundColor Cyan; Write-Host ""
    $s = Get-DeviceState
    if ($s -eq "offline") { Write-Err (T "DeviceNotConnected"); return $false }
    if (-not (Get-YesNo (T "StartFlashing"))) { Write-Host (T "Cancelled"); return $false }
    
    Write-Step (T "Step1RebootFastboot")
    if ($s -eq "device") {
        Invoke-ADB "reboot bootloader"
        Write-Host (T "WaitingFastboot")
        Start-Sleep -Seconds 5
        $to = 60; $el = 0
        while ($el -lt $to) { $s = Get-DeviceState; if ($s -eq "fastboot") { break }; Start-Sleep -Seconds 2; $el += 2; Write-Host "." -NoNewline }
        Write-Host ""
        if ($s -ne "fastboot") { Write-Err (T "EnterFastbootFailed"); return $false }
    } elseif ($s -ne "fastboot") { Write-Err (T "ManualRebootFastboot"); return $false }
    Write-OK (T "DeviceInFastboot")
    
    Write-Step (T "FlashPartitions")
    $fc = 0
    $partitionImages = @("boot", "init_boot", "dtbo", "vendor_boot")
    foreach ($p in $partitionImages) {
        $img = Join-Path $ImageDir "$p.img"
        if (Test-Path $img) {
            Write-Host ""; Write-Host "  $(T 'Flashing' $p)" -ForegroundColor Cyan
            $res = Invoke-Fastboot "flash $p $img"
            if ($res.Success) { Write-OK (T "Flashed" $p); $fc++ } else { Write-Err (T "FlashFailed" $p) }
        } else { Write-Warn (T "SkipNotFound" $p) }
    }
    Write-Host ""; Write-OK (T "FlashedCount" $fc)
    
    Write-Step (T "FlashRecovery")
    $recoveryImg = Join-Path $ImageDir "recovery.img"
    if (Test-Path $recoveryImg) {
        Write-Host "  $(T 'Flashing' 'recovery')" -ForegroundColor Cyan
        $res = Invoke-Fastboot "flash recovery $recoveryImg"
        if ($res.Success) { Write-OK (T "Flashed" "recovery") } else { Write-Err (T "FlashFailed" "recovery") }
    } else { Write-Warn (T "SkipNotFound" "recovery") }
    
    Write-Step (T "Step4RebootRecovery")
    Write-Host ""; Write-Host "  $(T 'DeviceWillReboot')" -ForegroundColor Yellow
    Invoke-Fastboot "reboot recovery"
    Write-Host (T "WaitRecoveryMode")
    Start-Sleep -Seconds 15
    
    Write-Step (T "Step5FactoryReset")
    Write-Host ""; Write-Host "  $(T 'OnDeviceFactoryReset')" -ForegroundColor Yellow; Write-Host ""
    Write-Host "  1. Select 'Factory Reset' on device" -ForegroundColor Cyan
    Write-Host "  2. Then select 'Format data / factory reset'" -ForegroundColor Cyan
    Write-Host "  3. Wait for formatting to complete" -ForegroundColor Cyan
    Write-Host ""
    if (-not (Get-YesNo (T "FactoryResetDone"))) { Write-Host (T "Cancelled"); return $false }
    
    Write-Step (T "Step6Sideload")
    Write-Host ""; Write-Host "  $(T 'OnDeviceApply')" -ForegroundColor Green
    Write-Host ""
    if (-not $RomZip) {
        $RomZip = Select-RomFile
    }
    if (-not $RomZip) { Write-Warn (T "NoRomZip"); Write-OK (T "PartitionComplete"); return $true }
    if ($RomZip -notmatch "\.zip`$") { Write-Warn (T "NoRomZip"); Write-OK (T "PartitionComplete"); return $true }
    
    Write-Host ""; Write-Host "  $(T 'WaitSideloadMode')" -NoNewline
    $to = 180; $el = 0; $ready = $false
    while ($el -lt $to) { $s = Get-DeviceState; if ($s -eq "sideload") { $ready = $true; break }; Start-Sleep -Seconds 3; $el += 3; Write-Host "." -NoNewline }
    Write-Host ""
    if (-not $ready) { Write-Err (T "NotInSideload"); return $false }
    Write-OK (T "DeviceInSideload")
    
    Write-Host ""; Write-Host "  $(T 'FlashingZip' (Split-Path $RomZip -Leaf))" -ForegroundColor Cyan; Write-Host "  $(T 'MayTakeTime')"; Write-Host ""
    Invoke-ADB -Arguments "sideload `"$RomZip`"" -TimeoutSeconds 900
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan; Write-Host "    $(T 'FlashComplete')" -ForegroundColor Green; Write-Host "========================================" -ForegroundColor Cyan; Write-Host ""
    
    if ($GappsZip -and (Test-Path $GappsZip)) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "  IMPORTANT: Now flashing GApps!" -ForegroundColor Yellow
        Write-Host "  GApps must be flashed BEFORE reboot!" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  $(T 'WaitSideloadMode')" -NoNewline
        $to = 180; $el = 0; $ready = $false
        while ($el -lt $to) { $s = Get-DeviceState; if ($s -eq "sideload") { $ready = $true; break }; Start-Sleep -Seconds 3; $el += 3; Write-Host "." -NoNewline }
        Write-Host ""
        if ($ready) {
            Write-Host "  Flashing GApps: $(Split-Path $GappsZip -Leaf)" -ForegroundColor Cyan
            Invoke-ADB -Arguments "sideload `"$GappsZip`"" -TimeoutSeconds 600
            Write-Host ""
            Write-Host "  GApps flashed! Signature verification may fail - click 'Yes' to continue." -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Process complete!" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan; Write-Host ""
    Write-Host "  $(T 'SelectReboot')" -ForegroundColor Green
    Write-Host ""
    return $true
}

function Show-DeviceMenu {
    $exit = $false
    while (-not $exit) {
        Write-Header
        $s = Get-DeviceState
        Write-Host (T "DeviceOps") -ForegroundColor Yellow; Write-Host "-----------------"; Write-Host "  [1] $(T 'Reboot')"; Write-Host "  [2] $(T 'RebootFastboot')"; Write-Host "  [3] $(T 'RebootRecovery')"; Write-Host "  [4] $(T 'DeviceInfo')"; Write-Host "  [0] $(T 'Back')"; Write-Host ""
        $c = Get-Input "Select [0-4]"
        switch ($c) {
            "1" { 
                if ($s -eq "device") { 
                    $out = Invoke-ADB "reboot"
                    if ($out.Success) { Write-OK (T "Sent") } else { Write-Err "Reboot failed" }
                } elseif ($s -eq "fastboot") { 
                    $out = Invoke-Fastboot "reboot"
                    if ($out.Success) { Write-OK (T "Sent") } else { Write-Err "Reboot failed" }
                } else { Write-Err (T "DeviceNotConnected") }
            }
            "2" { 
                if ($s -eq "device") { 
                    $out = Invoke-ADB "reboot bootloader"
                    if ($out.Success) { Write-OK (T "Sent") } else { Write-Err "Reboot failed" }
                } elseif ($s -eq "fastboot") { Write-Warn "Already in Fastboot mode" }
                else { Write-Err (T "DeviceNotConnected") }
            }
            "3" { 
                if ($s -eq "device") { 
                    $out = Invoke-ADB "reboot recovery"
                    if ($out.Success) { Write-OK (T "Sent") } else { Write-Err "Reboot failed" }
                } elseif ($s -eq "fastboot") { 
                    $out = Invoke-Fastboot "reboot recovery"
                    if ($out.Success) { Write-OK (T "Sent") } else { Write-Err "Reboot failed" }
                } else { Write-Err (T "DeviceNotConnected") }
            }
            "4" { 
                Write-Host ""; $s = Get-DeviceState
                Write-Host (T "State" $s)
                if ($s -eq "device") {
                    Write-Host (T "Model" (Invoke-ADB 'shell getprop ro.product.model'))
                    Write-Host (T "Android" (Invoke-ADB 'shell getprop ro.build.version.release'))
                } elseif ($s -eq "fastboot") {
                    $model = Invoke-Fastboot "getvar product" | Select-Object -First 1
                    $model = $model -replace "^product: ", ""
                    Write-Host "Model: $model"
                }
                Get-Input (T "PressEnter")
            }
            "0" { $exit = $true }
        }
    }
}

function Show-ToolsVerify {
    Write-Header
    Write-Host (T "ToolsVerifyTitle") -ForegroundColor Yellow
    Write-Host "==================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] $(T 'ToolsVerifyTitle')"
    Write-Host "  [0] $(T 'Back')"
    Write-Host ""
    $c = Get-Input "Select [0-1]"
    
    switch ($c) {
        "1" { Show-ToolsVerifyProcess }
        "0" { return }
    }
}

function Show-ToolsVerifyProcess {
    Write-Header
    Write-Host (T "ToolsVerifyTitle") -ForegroundColor Yellow
    Write-Host "==================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host (T "ToolsVerifyDesc") -ForegroundColor Cyan
    Write-Host (T "ToolsVerifyStep1") -ForegroundColor Yellow
    Write-Host (T "ToolsVerifyStep2") -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Get-YesNo (T "ToolsVerifyConnected"))) {
        Write-Host (T "ToolsVerifyNoDevice") -ForegroundColor Yellow
        return
    }
    
    $t = Find-PlatformTools
    if (-not $t) {
        Write-Err (T "ToolsVerifyAdbNotInstalled")
        if (Get-YesNo (T "ToolsVerifyDownload")) {
            Install-PlatformTools
            $t = Find-PlatformTools
        } else {
            return
        }
    }
    
    Write-Host ""
    Write-Host (T "ToolsVerifyStep") -ForegroundColor Cyan
    $adbDevices = & $t.ADB devices 2>&1
    
    if ($adbDevices -match "\tdevice") {
        Write-OK (T "ToolsVerifyAdbOk")
        
        Write-Host ""
        if (Get-YesNo (T "ToolsVerifyReboot")) {
            Write-Host ""
            Write-Host (T "ToolsVerifyRebooting") -ForegroundColor Cyan
            & $t.ADB reboot bootloader
            Start-Sleep -Seconds 5
            
            Write-Host (T "ToolsVerifyWaiting") -ForegroundColor Cyan
            $to = 60; $el = 0
            $inFastboot = $false
            while ($el -lt $to) {
                $fbDevices = & $t.Fastboot devices 2>&1
                if ($fbDevices -match "fastboot") {
                    $inFastboot = $true
                    break
                }
                Start-Sleep -Seconds 2
                $el += 2
                Write-Host "." -NoNewline
            }
            Write-Host ""
            
            if ($inFastboot) {
                Write-OK (T "ToolsVerifyFbOk")
                Write-Host ""
                Write-Host (T "ToolsVerifyDeviceInfo") -ForegroundColor Cyan
                $model = & $t.Fastboot getvar product 2>&1 | Select-Object -First 1
                $model = $model -replace "product: ", ""
                Write-Host "  Device: $model" -ForegroundColor Green
            } else {
                Write-Err (T "ToolsVerifyFbFailed")
            }
        }
    } else {
        Write-Err (T "NoDeviceConnected")
        Write-Host ""
        Write-Host (T "ToolsVerifyCheck") -ForegroundColor Yellow
        Write-Host (T "ToolsVerifyCheckUsb") -ForegroundColor Yellow
        Write-Host (T "ToolsVerifyCheckAllow") -ForegroundColor Yellow
        Write-Host (T "ToolsVerifyCheckDriver") -ForegroundColor Yellow
    }
    
    Write-Host ""
    Get-Input "Press Enter to return"
}

function Start-CompleteFlash {
    Write-Header; Write-Host (T "FullFlash") -ForegroundColor Yellow; Write-Host "====================="; Write-Host ""
    $imgDir = ""
    $zipFile = ""
    $gappsFile = ""
    
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  $(T 'DriverInstallTitle')" -ForegroundColor Yellow
    Write-Host "  $(T 'DriverInstallIgnore')" -ForegroundColor Cyan
    Write-Host "  $(T 'DriverInstallLink')" -ForegroundColor DarkGray
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    if (Get-YesNo (T "DriverInstallCheck")) {
        Write-Host (T "DriverInstallContinue") -ForegroundColor Green
    } else {
        if (Get-YesNo (T "DriverInstallDownload")) {
            Start-Process "https://lsdy.top/azqddownload"
            Write-Host (T "DriverInstallDone") -ForegroundColor Yellow
            return
        }
    }
    
    Write-Host ""
    Write-Host "Step 1: 检查设备模式" -ForegroundColor Cyan
    $s = Get-DeviceState
    if ($s -eq "device") {
        Write-Host "设备处于 ADB 模式，将重启到 Fastboot..." -ForegroundColor Yellow
        if (Get-YesNo "是否重启到 Fastboot 模式？") {
            Invoke-ADB "reboot bootloader"
            Write-Host "等待设备进入 Fastboot..." -ForegroundColor Cyan
            Start-Sleep -Seconds 5
            $to = 60; $el = 0
            while ($el -lt $to) { 
                $s = Get-DeviceState 
                if ($s -eq "fastboot") { break } 
                Start-Sleep -Seconds 2; $el += 2; Write-Host "." -NoNewline 
            }
            Write-Host ""
            if ($s -ne "fastboot") { 
                Write-Err "设备未能进入 Fastboot 模式"
                Write-Host "请手动重启到 Fastboot 后重试" -ForegroundColor Yellow
                return 
            }
        } else {
            return
        }
    } elseif ($s -ne "fastboot") {
        Write-Err "设备未连接，请连接设备后重试"
        return
    }
    Write-OK "设备已处于 Fastboot 模式"
    
    Write-Host ""
    Write-Host "Step 2: Select partition images folder" -ForegroundColor Cyan
    $rf = Select-RomFile
    if (-not $rf) { return }
    
    if ($rf.StartsWith("DIR:")) { 
        $imgDir = $rf.Substring(4) 
    } elseif ($rf -match "\.zip`$") {
        Write-Step (T "Extract")
        $td = Join-Path $Script:Config.OutputDir "temp_extract"
        if (Test-Path $td) { Remove-Item $td -Recurse -Force }
        Expand-Archive -Path $rf -DestinationPath $td -Force
        $pp = Join-Path $td "payload.bin"
        if (Test-Path $pp) { $imgDir = $Script:Config.OutputDir; if (-not (Extract-PayloadBin $pp $imgDir $Script:Config.FlashOrder)) { return } }
        else { Write-Warn "No payload.bin, using extracted files"; $imgDir = $td }
    } elseif ($rf -match "payload\.bin`$") { $imgDir = $Script:Config.OutputDir; if (-not (Extract-PayloadBin $rf $imgDir $Script:Config.FlashOrder)) { return } }
    else { Write-Err (T "UnsupportedFormat"); return }
    
    Write-Host ""; Write-Host "Available images:" -ForegroundColor Cyan
    Get-ChildItem -Path $imgDir -Filter "*.img" -File | ForEach-Object { Write-Host "  - $($_.Name)" }
    Write-Host ""
    
    Write-Host "Step 3: Select full ROM ZIP for sideload" -ForegroundColor Cyan
    Write-Host "  [1] Enter full path manually"
    Write-Host "  [2] Select other folder with extracted images"
    Write-Host "  [0] Skip sideload"
    $c = Get-Input "Select [0-2]"
    if ($c -eq "1") {
        $zf = Get-Input "Enter ZIP file path"
        if ($zf -match "\.zip`$" -and (Test-Path $zf)) { $zipFile = $zf }
    } elseif ($c -eq "2") {
        $zf = Get-Input (T "EnterImagesDir")
        $zips = Get-ChildItem -Path $zf -Filter "*.zip" -File
        if ($zips.Count -gt 0) {
            Write-Host "Available ZIP files:" -ForegroundColor Cyan
            for ($i = 0; $i -lt $zips.Count; $i++) { Write-Host "  [$($i+1)] $($zips[$i].Name)" }
            Write-Host "  [0] Exit"
            $sel = Get-Input "Select ZIP number [0-$($zips.Count)]"
            if ($sel -eq "0") { return }
            $idx = [int]$sel - 1
            if ($idx -ge 0 -and $idx -lt $zips.Count) { $zipFile = $zips[$idx].FullName } else { return }
        } else { return }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  IMPORTANT: GApps must be flashed" -ForegroundColor Yellow
    Write-Host "  BEFORE rebooting to system!" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    $needGapps = Get-YesNo (T "WantGapps")
    if ($needGapps) {
        Write-Host "Step 4: Select GApps ZIP file" -ForegroundColor Cyan
        Write-Host "  [1] Enter full path manually"
        Write-Host "  [2] Select other folder"
        Write-Host "  [0] Skip GApps"
        $c = Get-Input "Select [0-2]"
        if ($c -eq "1") {
            $gf = Get-Input "Enter GApps ZIP file path"
            if ($gf -match "\.zip`$" -and (Test-Path $gf)) { $gappsFile = $gf }
        } elseif ($c -eq "2") {
            $gf = Get-Input (T "EnterImagesDir")
            $gapps = Get-ChildItem -Path $gf -Filter "*.zip" -File
            if ($gapps.Count -gt 0) {
                Write-Host "Available ZIP files:" -ForegroundColor Cyan
                for ($i = 0; $i -lt $gapps.Count; $i++) { Write-Host "  [$($i+1)] $($gapps[$i].Name)" }
                Write-Host "  [0] Exit"
                $sel = Get-Input "Select ZIP number [0-$($gapps.Count)]"
                if ($sel -eq "0") { $gappsFile = "" }
                else { $idx = [int]$sel - 1; if ($idx -ge 0 -and $idx -lt $gapps.Count) { $gappsFile = $gapps[$idx].FullName } }
            }
        }
    }
    
    Write-Host ""
    if ($zipFile) { Write-Host "ROM ZIP: $zipFile" -ForegroundColor Green } else { Write-Host "No sideload (skip)" -ForegroundColor Yellow }
    if ($gappsFile) { Write-Host "GApps ZIP: $gappsFile" -ForegroundColor Green } else { Write-Host "No GApps (skip)" -ForegroundColor Yellow }
    Write-Host "Images: $imgDir" -ForegroundColor Cyan
    Write-Host ""
    Start-FlashProcess $imgDir $zipFile $gappsFile
}

function Start-ExtractOnly {
    Write-Header; Write-Host (T "ExtractOnly") -ForegroundColor Yellow; Write-Host "==================="; Write-Host ""
    $rf = Select-RomFile
    if (-not $rf) { return }
    if ($rf -match "payload\.bin`$") { Extract-PayloadBin $rf $Script:Config.OutputDir }
    elseif ($rf -match "\.zip`$") {
        Write-Step (T "Extract")
        $td = Join-Path $Script:Config.OutputDir "temp_extract"
        Expand-Archive -Path $rf -DestinationPath $td -Force
        $pp = Join-Path $td "payload.bin"
        if (Test-Path $pp) { Extract-PayloadBin $pp $Script:Config.OutputDir } else { Write-Err (T "NoPayloadInZip") }
    }
    Get-Input (T "PressEnter")
}

function Start-FlashImagesOnly {
    Write-Header; Write-Host (T "FlashImages") -ForegroundColor Yellow; Write-Host "================="; Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  $(T 'DriverInstallTitle')" -ForegroundColor Yellow
    Write-Host "  $(T 'DriverInstallIgnore')" -ForegroundColor Cyan
    Write-Host "  $(T 'DriverInstallLink')" -ForegroundColor DarkGray
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    if (Get-YesNo (T "DriverInstallCheck")) {
        Write-Host (T "DriverInstallContinue") -ForegroundColor Green
    } else {
        if (Get-YesNo (T "DriverInstallDownload")) {
            Start-Process "https://lsdy.top/azqddownload"
            Write-Host (T "DriverInstallDone") -ForegroundColor Yellow
            return
        }
    }
    
    $s = Get-DeviceState
    if ($s -eq "offline") { 
        Write-Err (T "DeviceNotConnected")
        return 
    }
    if ($s -eq "device") { 
        Write-Host "Device in ADB mode, need to reboot to Fastboot..." -ForegroundColor Yellow
        if (Get-YesNo "Reboot to Fastboot now?") {
            Invoke-ADB "reboot bootloader"
            Write-Host (T "WaitingFastboot")
            Start-Sleep -Seconds 5
            $to = 60; $el = 0
            while ($el -lt $to) { $s = Get-DeviceState; if ($s -eq "fastboot") { break }; Start-Sleep -Seconds 2; $el += 2; Write-Host "." -NoNewline }
            Write-Host ""
            if ($s -ne "fastboot") { Write-Err (T "EnterFastbootFailed"); return }
        } else {
            return
        }
    }
    if ($s -ne "fastboot") { 
        Write-Err (T "NeedFastboot")
        return 
    }
    
    Write-Host "Available partitions:" -ForegroundColor Cyan
    Write-Host "  [1] boot"
    Write-Host "  [2] init_boot"
    Write-Host "  [3] vendor_boot"
    Write-Host "  [4] dtbo"
    Write-Host "  [5] recovery"
    Write-Host "  [0] Exit"
    Write-Host ""
    
    $c = Get-Input "Select partition [0-5]"
    if ($c -eq "0") { return }
    $partition = switch ($c) {
        "1" { "boot" }
        "2" { "init_boot" }
        "3" { "vendor_boot" }
        "4" { "dtbo" }
        "5" { "recovery" }
        default { Write-Err (T "InvalidChoice"); return }
    }
    
    Write-Host ""
    Write-Host "Command preview:" -ForegroundColor Cyan
    Write-Host "  fastboot flash $partition <image_path>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Select image source:" -ForegroundColor Yellow
    Write-Host "  [1] Select from output folder"
    Write-Host "  [2] Enter path manually"
    Write-Host "  [0] Exit"
    $source = Get-Input "Select [0-2]"
    if ($source -eq "0") { return }
    
    if ($source -eq "1") {
        $outputImages = Get-ChildItem -Path $Script:Config.OutputDir -Filter "*.img" -File
        if ($outputImages.Count -eq 0) {
            Write-Err "No images found in output folder"
            return
        }
        Write-Host ""
        Write-Host "Available images in output folder:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $outputImages.Count; $i++) {
            Write-Host "  [$($i+1)] $($outputImages[$i].Name)"
        }
        Write-Host "  [0] Exit"
        $sel = Get-Input "Select image number"
        if ($sel -eq "0") { return }
        $idx = [int]$sel - 1
        if ($idx -ge 0 -and $idx -lt $outputImages.Count) {
            $imgPath = $outputImages[$idx].FullName
        } else {
            Write-Err (T "InvalidChoice")
            return
        }
    } elseif ($source -eq "2") {
        Write-Host "Enter image file path:" -ForegroundColor Cyan
        $imgPath = Get-Input "Path"
    } else {
        Write-Err (T "InvalidChoice")
        return
    }
    
    if (-not (Test-Path $imgPath)) { 
        Write-Err (T "FileNotFound")
        return 
    }
    
    Write-Host ""
    Write-Host "Ready to flash:" -ForegroundColor Green
    Write-Host "  Partition: $partition" 
    Write-Host "  Image: $imgPath"
    Write-Host ""
    Write-Host (T "EnterConfirmCancel") -ForegroundColor Yellow
    $valid = $false
    while (-not $valid) {
        $c = Get-Input "Enter 1 to confirm, 0 to cancel"
        if ($c -eq "1") { $valid = $true }
        elseif ($c -eq "0") { Write-Host (T "Cancelled"); return }
        else { Write-Warn (T "InvalidChoice") }
    }
    
$res = Invoke-Fastboot "flash $partition $imgPath"
if ($res.Success) {
    Write-OK "Flash success"
} else {
    Write-Err (T "FlashFailed" $partition)
}
}

function Start-SideloadOnly {
    Write-Header; Write-Host (T "SideloadOnly") -ForegroundColor Yellow; Write-Host "============"; Write-Host ""
    $rf = Find-RomFile
    if (-not $rf) { 
        Write-Host "  [0] Exit" -ForegroundColor Yellow
        $rf = Get-Input "Enter ROM ZIP path (or 0 to exit)"
        if ($rf -eq "0") { return }
    }
    if (-not (Test-Path $rf)) { Write-Err (T "FileNotFound"); return }
    Write-Host ""; Write-Host "Make sure device is in ADB Sideload mode" -ForegroundColor Yellow; Write-Host ""
    if (-not (Get-YesNo "Device ready?")) { return }
    Write-Step (T 'StartSideload')
    Invoke-ADB -Arguments "sideload `"$rf`"" -TimeoutSeconds 900
    Write-OK "Sideload complete"
}



function Show-MainMenu {
    $exit = $false
    while (-not $exit) {
        $s = Get-DeviceState
        Render-MainMenu $s
        $c = Get-Input "Select [0-6] or [R]efresh or [L]anguage"
        if ($c -eq "2") { 
            Start-ExtractOnly
            continue
        }
        if ($c -eq "R" -or $c -eq "r") { $s = Get-DeviceState; continue }
        if ($c -eq "L" -or $c -eq "l") { 
            if ($Script:Config.Language -eq "en") { $Script:Config.Language = "zh" }
            else { $Script:Config.Language = "en" }
            $configFile = Join-Path $Script:Config.ScriptDir "config.ini"
            "language=$($Script:Config.Language)" | Set-Content $configFile -Force
            Write-OK (T "LanguageSwitched")
            Start-Sleep -Seconds 1
            continue
        }
        switch ($c) {
            "1" { 
                if ($s -eq "offline") { Write-Err (T "NoDeviceConnected"); Get-Input "Press Enter to retry..."; continue }
                Start-CompleteFlash 
            }
            "3" { 
                if ($s -eq "offline") { Write-Err (T "NoDeviceConnected"); Get-Input "Press Enter to retry..."; continue }
                Start-FlashImagesOnly 
            }
            "4" { 
                if ($s -eq "offline") { Write-Err (T "NoDeviceConnected"); Get-Input "Press Enter to retry..."; continue }
                Start-SideloadOnly 
            }
            "5" { 
                if ($s -eq "offline") { Write-Err (T "NoDeviceConnected"); Get-Input "Press Enter to retry..."; continue }
                Show-DeviceMenu 
            }
            "6" { Show-ToolsVerify }
            "0" { $exit = $true; Write-Host (T "GoodBye") }
            default { Write-Warn (T "InvalidChoice"); Start-Sleep -Seconds 1 }
        }
    }
}

function Initialize-Language {
    param([string]$CmdLang = "")
    $configFile = Join-Path $Script:Config.ScriptDir "config.ini"
    $savedLang = ""
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw -ErrorAction SilentlyContinue
        if ($content -match 'language\s*=\s*(\w+)') { $savedLang = $matches[1] }
    }
    if ($CmdLang) {
        $Script:Config.Language = $CmdLang.ToLower()
    }
    elseif ($savedLang) {
        $Script:Config.Language = $savedLang.ToLower()
    }
    else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  $(T 'SelectLanguage')" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  [1] $(T 'LanguageChinese')"
        Write-Host "  [2] $(T 'LanguageEnglish')"
        Write-Host ""
        $c = Get-Input "Select [1-2]"
        if ($c -eq "2") { $Script:Config.Language = "en" }
        else { $Script:Config.Language = "zh" }
        if (Get-YesNo (T "SaveLanguage")) {
            "language=$($Script:Config.Language)" | Set-Content $configFile -Force
            Write-OK (T "LanguageSaved")
        }
    }
}

function Main {
    Initialize-Language -CmdLang $Language
    Initialize-Paths
    if ($Help) { Write-Host "AOSP Flash Tool"; Write-Host (T "Usage"); return }
    if ($RomFile) {
        if (-not (Test-Path $RomFile)) { Write-Err "$(T 'FileNotFound'): $RomFile"; return }
        if ($RomFile -match "\.zip`$") {
            $td = Join-Path $Script:Config.OutputDir "temp_extract"
            Expand-Archive -Path $RomFile -DestinationPath $td -Force
            $pp = Join-Path $td "payload.bin"
            if (Test-Path $pp) { Extract-PayloadBin $pp $Script:Config.OutputDir $Script:Config.FlashOrder; Start-FlashProcess $Script:Config.OutputDir }
        }
        elseif ($RomFile -match "payload\.bin`$") { Extract-PayloadBin $RomFile $Script:Config.OutputDir $Script:Config.FlashOrder; Start-FlashProcess $Script:Config.OutputDir }
        return
    }
    Show-MainMenu
}

Main
