# AOSP Flasher

Windows 平台 AOSP ROM 刷机工具 / Windows tool for flashing AOSP ROMs to Android devices

## 环境要求 / Requirements

- Windows 10/11
- PowerShell 5.1 或更高版本 / PowerShell 5.1 or later
- 已安装设备 USB 驱动 / USB drivers installed for your device

## 目录结构 / Directory Structure

```
AOSPFlasher/
├── Flash-AOSP.ps1      # 主脚本 / Main script
├── Start.bat           # 启动器 / Launcher
├── config.ini          # 配置文件 / Configuration
├── platform-tools/     # ADB & Fastboot
├── tools/              # Payload Dumper
```

## 使用方法 / Usage

1. 运行 `Start.bat` 或直接执行 `Flash-AOSP.ps1` / Run `Start.bat` or execute `Flash-AOSP.ps1`
2. 按屏幕提示操作 / Follow on-screen instructions

## 主菜单 / Main Menu

| 选项 Option | 说明 Description |
|------------|------------------|
| [1] 全量刷机 / Full Flash | 完整流程：重启Fastboot → 刷分区镜像 → 刷recovery → 双清 → sideload刷入ROM → (可选)刷入GApps / Complete process: reboot to Fastboot → flash partition images → flash recovery → factory reset → sideload ROM → (optional) flash GApps |
| [2] 仅提取 / Extract Only | 仅提取 payload.bin 镜像文件 / Extract payload.bin images only |
| [3] 刷入镜像 / Flash Images | 刷写已提取的镜像到设备 / Flash extracted images to device |
| [4] 仅Sideload / Sideload Only | 通过 ADB sideload 刷入 ROM ZIP / Flash ROM ZIP via ADB sideload |
| [5] 设备工具 / Device Tools | 查看设备、重启、进入 Recovery/Fastboot / View devices, reboot, enter Recovery/Fastboot |
| [6] 工具 / Tools | 安装 ADB、验证工具、安装 Payload Dumper / Install ADB, verify tools, install Payload Dumper |
| [L] 切换语言 / Switch Language | 中文/English 切换 / Toggle Chinese/English |
| [0] 退出 / Exit | 退出程序 / Exit program |

## 全量刷机流程 / Complete Flash Process

1. Step 1: 重启到 Fastboot 模式 / Reboot to Fastboot mode
2. Step 2: 刷写分区镜像 (boot, init_boot, dtbo, vendor_boot) / Flash partition images (boot, init_boot, dtbo, vendor_boot)
3. Step 3: 刷写 recovery / Flash recovery
4. Step 4: 重启到 Recovery 模式 / Reboot to Recovery mode
5. Step 5: 在设备上执行双清 (Factory Reset) / Perform factory reset on device
6. Step 6: Sideload 刷入 ROM ZIP / Flash ROM ZIP via sideload
7. Step 7: (可选) Sideload 刷入 GApps / (Optional) Flash GApps via sideload
8. 完成: 重启系统 / Complete: Reboot to system

## 驱动安装 / Driver Installation

**请提前下载并安装设备驱动 / Please download and install device drivers in advance:**

- 驱动下载 / Driver download: https://lsdy.top/azqddownload
- 操作步骤 / Steps: 开启设备的 USB 调试，用数据线连接电脑，进入 ADB 模式后手动安装驱动 / Enable USB debugging on device, connect to PC, enter ADB mode, then install drivers manually

## 配置文件 / Configuration

编辑 `config.ini` / Edit `config.ini`:
- `language=zh` - 中文
- `language=en` - English

## 注意事项 / Notes

- 刷写分区时设备需处于 Fastboot 模式 / Device must be in Fastboot mode for flashing partitions
- 刷入 ROM/GApps 时设备需处于 Sideload 模式 / Device must be in Sideload mode for ROM/GApps installation
- 刷机将清除数据，请提前备份！/ Flashing will wipe data, please backup first!
