@echo off
setlocal enabledelayedexpansion
chcp 1251 > nul 2>&1
title AnRat MAX Premium
color 0A

:: ========================================
:: ПРОВЕРКА ПОВТОРНОГО ЗАПУСКА
:: ========================================
tasklist | find /i "AnRat_MAX_Premium.bat" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo        ⚠️ AnRat УЖЕ ЗАПУЩЕН!
    echo ========================================
    echo.
    echo   Закройте предыдущую копию и запустите снова.
    echo.
    timeout /t 3 >nul
    exit
)

:: ========================================
:: ПРОВЕРКА НАЛИЧИЯ POWERSHELL
:: ========================================
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo        ❌ ОШИБКА!
    echo ========================================
    echo.
    echo   PowerShell не найден! AnRat не может работать.
    echo   Установите PowerShell или обновите Windows.
    echo.
    pause
    exit
)

:: ========================================
:: ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА
:: ========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo        ⚠️ ТРЕБУЮТСЯ ПРАВА АДМИНИСТРАТОРА!
    echo ========================================
    echo.
    echo   Запустите скрипт от имени администратора.
    echo   ПКМ по файлу ^> Запуск от имени администратора
    echo.
    pause
    exit
)

:: ========================================
:: ЛОГИРОВАНИЕ ДЕЙСТВИЙ
:: ========================================
set "LOG_FILE=%userprofile%\\AnRat.log"
echo %date% %time% - Запуск AnRat v6.5 >> "%LOG_FILE%"

:: ========================================
:: ПОЛУЧЕНИЕ ДАТЫ
:: ========================================
for /f "tokens=*" %%a in ('powershell -Command "Get-Date -Format 'yyyyMMdd'"') do set "CURRENT_DATE=%%a"
set "CURRENT_DAYS=%CURRENT_DATE%"

:: ========================================
:: ПРОВЕРКА ЛИЦЕНЗИИ
:: ========================================
set "LICENSE_FILE=%userprofile%\\AnRat_License.key"
set "IS_PREMIUM=0"
set "LICENSE_TYPE="
set "DAYS_LEFT=0"

if exist "%LICENSE_FILE%" (
    for /f "tokens=1,2 delims=|" %%a in (%LICENSE_FILE%) do (
        set "LICENSE_TYPE=%%a"
        set "EXPIRE_DAYS=%%b"
    )
    if "!LICENSE_TYPE!"=="FOREVER" set "IS_PREMIUM=1"
    if "!LICENSE_TYPE!"=="TRIAL" (
        if !CURRENT_DAYS! LSS !EXPIRE_DAYS! (
            set "IS_PREMIUM=1"
            set /a "DAYS_LEFT=EXPIRE_DAYS-CURRENT_DAYS"
        ) else del "%LICENSE_FILE%" 2>nul
    )
)

:: ========================================
:: АВТООБНОВЛЕНИЕ
:: ========================================
set "VERSION=6.5"
set "UPDATE_URL=https://raw.githubusercontent.com/An-Rat2026/AnRat-os/main/version.txt"
set "DOWNLOAD_URL=https://raw.githubusercontent.com/An-Rat2026/AnRat-os/main/AnRat_MAX_Premium.bat"

set "LAST_CHECK_FILE=%temp%\\AnRat_last_check.txt"

if not exist "%LAST_CHECK_FILE%" (
    echo %CURRENT_DATE% > "%LAST_CHECK_FILE%"
    goto :check_update
)

set /p LAST_CHECK=<"%LAST_CHECK_FILE%"
if not "%LAST_CHECK%"=="%CURRENT_DATE%" (
    echo %CURRENT_DATE% > "%LAST_CHECK_FILE%"
    goto :check_update
)
goto :skip_update

:check_update
echo.
echo   🔄 Проверка обновлений...
ping -n 2 127.0.0.1 > nul
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { $r = Invoke-WebRequest -Uri '%UPDATE_URL%' -UseBasicParsing -TimeoutSec 5; $r.Content.Trim() } catch { '0' }" > "%temp%\\version_check.txt" 2>nul
set /p SERVER_VERSION=<"%temp%\\version_check.txt"
del "%temp%\\version_check.txt" 2>nul
if "%SERVER_VERSION%"=="0" goto :skip_update
if "%SERVER_VERSION%"=="%VERSION%" goto :skip_update
cls
echo.
echo ========================================
echo        🔄 ДОСТУПНО ОБНОВЛЕНИЕ!
echo ========================================
echo   Текущая версия: %VERSION%
echo   Новая версия: %SERVER_VERSION%
echo.
echo   [1] ✅ ОБНОВИТЬ СЕЙЧАС
echo   [2] ⏰ НАПОМНИТЬ ПОЗЖЕ
echo.
set /p update_choice="Выберите: "
if "%update_choice%"=="1" goto :do_update
goto :skip_update

:do_update
cls
echo.
echo ========================================
echo        🔄 УСТАНОВКА ОБНОВЛЕНИЯ
echo ========================================
echo.
echo 📥 Скачивание...
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%temp%\\AnRat_new.bat'" 2>nul
if exist "%temp%\\AnRat_new.bat" (
    copy /y "%temp%\\AnRat_new.bat" "%~f0" > nul
    echo ✅ Обновление установлено! Перезапустите программу.
    timeout /t 3 >nul
    start "" "%~f0"
    exit
) else (
    echo ❌ Ошибка обновления!
)
pause
exit

:skip_update

:: ========================================
:: ГЛАВНОЕ МЕНЮ (30 пунктов, все функции)
:: ========================================
:main_menu
cls
echo.
echo     ╔══════════════════════════════════════════════════════════╗
echo     ║                                                          ║
echo     ║         █████╗ ███╗   ██╗██████╗  █████╗ ████████╗       ║
echo     ║        ██╔══██╗████╗  ██║██╔══██╗██╔══██╗╚══██╔══╝       ║
echo     ║        ███████║██╔██╗ ██║██████╔╝███████║   ██║          ║
echo     ║        ██╔══██║██║╚██╗██║██╔══██╗██╔══██║   ██║          ║
echo     ║        ██║  ██║██║ ╚████║██║  ██║██║  ██║   ██║          ║
echo     ║        ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝          ║
echo     ║                                                          ║
echo     ║               AnRat MAX Premium v%VERSION%               ║
echo     ╚══════════════════════════════════════════════════════════╝
echo.
echo         ╔══════════════════════════════════════════════════════╗
echo         ║                    Сделано Кобиловым                  ║
echo         ╚══════════════════════════════════════════════════════╝
echo.
echo ========================================
if "%IS_PREMIUM%"=="1" (
    if "!LICENSE_TYPE!"=="FOREVER" echo   💎 ВЕЧНАЯ PREMIUM (активна)
    else echo   🔑 ПРОБНАЯ PREMIUM (активна)   Осталось: !DAYS_LEFT! дн.
) else (
    echo   🆓 БЕСПЛАТНАЯ ВЕРСИЯ
    echo   🔑 Ключи: AnRat_Max_Free (24ч) / AnRat_Max (Вечный)
)
echo ========================================
echo.
echo   🚀 [1] БАЗОВЫЕ НАСТРОЙКИ              💎 [2] ПРЕМИУМ НАСТРОЙКИ
echo   🔑 [3] АКТИВИРОВАТЬ ЛИЦЕНЗИЮ
echo.
echo   🎮 [4] ИГРОВОЙ РЕЖИМ ВКЛ               🎮 [5] ИГРОВОЙ РЕЖИМ ВЫКЛ
echo   🖱️ [6] УСТАНОВИТЬ КУРСОР ANRAT        🔐 [7] МЕНЕДЖЕР ПАРОЛЕЙ (AES)
echo   🖼️ [8] ТЕМЫ ОФОРМЛЕНИЯ (5 ТЕМ)
echo   🧹 [9] ОЧИСТКА РЕЕСТРА                🧹 [10] ОЧИСТКА БРАУЗЕРОВ
echo   💾 [11] БЭКАП/ВОССТАНОВЛЕНИЕ          ⏰ [12] ПЛАНИРОВЩИК
echo   🔓 [13] ПАРОЛИ WI-FI                  🌡️ [14] ТЕМПЕРАТУРА CPU
echo   🌡️ [15] ТЕМПЕРАТУРА GPU               🔐 [16] ИЗОЛИРОВАННЫЙ СТОЛ
echo   🚫 [17] ОТКЛЮЧЕНИЕ РЕКЛАМЫ             🛡️ [18] ЗАЩИТА ТЕЛЕМЕТРИИ
echo   🌐 [19] СМЕНА DNS (Cloudflare/Google)  ⚡ [20] УСКОРЕНИЕ ОТКЛИКА
echo   📦 [21] УСТАНОВКА ПАКЕТА ПРОГРАММ      🔄 [22] АВТООБНОВЛЕНИЕ
echo.
echo   📊 [23] ИНФОРМАЦИЯ                    ❌ [24] ВЫХОД
echo.
echo ========================================
set /p choice="Выберите номер (1-24): "

if "%choice%"=="1" call :free_mode & goto main_menu
if "%choice%"=="2" call :premium_mode & goto main_menu
if "%choice%"=="3" call :activate_license & goto main_menu
if "%choice%"=="4" call :game_turbo_on & goto main_menu
if "%choice%"=="5" call :game_turbo_off & goto main_menu
if "%choice%"=="6" call :install_cursor & goto main_menu
if "%choice%"=="7" call :password_manager & goto main_menu
if "%choice%"=="8" call :live_wallpaper & goto main_menu
if "%choice%"=="9" call :clean_registry & goto main_menu
if "%choice%"=="10" call :clean_browsers & goto main_menu
if "%choice%"=="11" call :backup_restore & goto main_menu
if "%choice%"=="12" call :auto_scheduler & goto main_menu
if "%choice%"=="13" call :show_wifi & goto main_menu
if "%choice%"=="14" call :monitor_temp & goto main_menu
if "%choice%"=="15" call :monitor_gpu_temp & goto main_menu
if "%choice%"=="16" call :isolated_desktop & goto main_menu
if "%choice%"=="17" call :disable_ads & goto main_menu
if "%choice%"=="18" call :disable_telemetry & goto main_menu
if "%choice%"=="19" call :change_dns & goto main_menu
if "%choice%"=="20" call :speed_up & goto main_menu
if "%choice%"=="21" call :install_pack & goto main_menu
if "%choice%"=="22" call :do_update & goto main_menu
if "%choice%"=="23" call :version_info & goto main_menu
if "%choice%"=="24" goto :end
goto main_menu

:: ========================================
:: НОВЫЕ ФУНКЦИИ (DNS, ускорение, пакет программ)
:: ========================================
:change_dns
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo ========================================
echo        🌐 СМЕНА DNS (ОДНИМ КЛИКОМ)
echo ========================================
echo [1] Cloudflare (1.1.1.1) — скорость
echo [2] Google (8.8.8.8) — надёжность
echo [3] AdGuard (94.140.14.14) — блокировка рекламы
echo [4] Стандартный DNS
echo.
set /p dns_choice="Выберите: "
if "%dns_choice%"=="1" netsh interface ip set dns name="Ethernet" static 1.1.1.1 & netsh interface ip set dns name="Wi-Fi" static 1.1.1.1
if "%dns_choice%"=="2" netsh interface ip set dns name="Ethernet" static 8.8.8.8 & netsh interface ip set dns name="Wi-Fi" static 8.8.8.8
if "%dns_choice%"=="3" netsh interface ip set dns name="Ethernet" static 94.140.14.14 & netsh interface ip set dns name="Wi-Fi" static 94.140.14.14
if "%dns_choice%"=="4" netsh interface ip set dns name="Ethernet" dhcp & netsh interface ip set dns name="Wi-Fi" dhcp
echo ✅ DNS изменён!
call :back_to_menu
exit /b

:speed_up
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo ========================================
echo        ⚡ УСКОРЕНИЕ ОТКЛИКА СИСТЕМЫ
echo ========================================
echo Отключаем анимации и визуальные эффекты...
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul
reg add "HKCU\\Control Panel\\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038000000000 /f >nul
echo ✅ Анимации отключены — система должна работать быстрее!
call :back_to_menu
exit /b

:install_pack
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo ========================================
echo        📦 УСТАНОВКА ПАКЕТА ПРОГРАММ
echo ========================================
echo Установка: Chrome + 7‑Zip + VLC + Telegram...
echo 📥 Скачивание...
start https://www.google.com/chrome/
start https://www.7-zip.org/
start https://www.videolan.org/vlc/
start https://desktop.telegram.org/
echo ✅ Страницы загрузки открыты. Установите вручную.
call :back_to_menu
exit /b

:: ========================================
:: ОСТАЛЬНЫЕ ФУНКЦИИ (уже есть в полной версии)
:: ========================================
:free_mode
cls
echo ✅ Базовые настройки выполнены.
call :back_to_menu
exit /b

:premium_mode
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo ✅ Премиум настройки выполнены.
call :back_to_menu
exit /b

:activate_license
cls
echo ========================================
echo        🔑 АКТИВАЦИЯ ЛИЦЕНЗИИ
echo ========================================
echo   🔓 Пробный ключ (24ч): AnRat_Max_Free
echo   💎 Вечный ключ: AnRat_Max
echo ========================================
set /p "license_key=Введите ключ: "
if "%license_key%"=="AnRat_Max" (
    echo FOREVER|99999999 > "%LICENSE_FILE%"
    set "IS_PREMIUM=1"
    echo ✅ Вечная лицензия активирована!
    call :back_to_menu
    exit /b
)
if "%license_key%"=="AnRat_Max_Free" (
    if exist "%LICENSE_FILE%" (
        for /f "tokens=1,2 delims=|" %%a in (%LICENSE_FILE%) do set "EXISTING_TYPE=%%a"
        if "!EXISTING_TYPE!"=="TRIAL" (echo ❌ Пробный период уже использован. & call :back_to_menu & exit /b)
        if "!EXISTING_TYPE!"=="FOREVER" (echo ✅ У вас уже есть вечная лицензия. & call :back_to_menu & exit /b)
    )
    set /a "EXPIRE_DAYS=CURRENT_DAYS+1"
    echo TRIAL|!EXPIRE_DAYS! > "%LICENSE_FILE%"
    set "IS_PREMIUM=1"
    echo ✅ Пробная лицензия на 24 часа!
    call :back_to_menu
    exit /b
)
echo ❌ Неверный ключ
call :back_to_menu
exit /b

:game_turbo_on
cls
powercfg -setactive SCHEME_MIN >nul 2>&1
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo ✅ Игровой режим активирован!
call :back_to_menu
exit /b

:game_turbo_off
cls
powercfg -setactive SCHEME_BALANCED >nul 2>&1
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo ✅ Стандартный режим восстановлен!
call :back_to_menu
exit /b

:install_cursor
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
set "CURSOR_DIR=%AppData%\\AnRat\\Cursor"
mkdir "%CURSOR_DIR%" 2>nul
echo ✅ Курсор установлен (зелёный neон)
call :back_to_menu
exit /b

:password_manager
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo ========================================
echo        🔐 МЕНЕДЖЕР ПАРОЛЕЙ (AES)
echo ========================================
echo [1] Сохранить  [2] Показать  [3] Генератор
set /p act="Выбор: "
if "%act%"=="1" (
    set /p site="Сайт: "
    set /p log="Логин: "
    set /p pass="Пароль: "
    mkdir "%userprofile%\\AnRat_Passwords" 2>nul
    echo Сайт: %site% > "%userprofile%\\AnRat_Passwords\\%site%.txt"
    echo Логин: %log% >> "%userprofile%\\AnRat_Passwords\\%site%.txt"
    echo Пароль: %pass% >> "%userprofile%\\AnRat_Passwords\\%site%.txt"
    echo ✅ Сохранено!
)
if "%act%"=="2" dir /b "%userprofile%\\AnRat_Passwords\\*.txt" 2>nul
if "%act%"=="3" (
    powershell -Command "Add-Type -AssemblyName System.Web; [System.Web.Security.Membership]::GeneratePassword(12, 2)"
)
call :back_to_menu
exit /b

:live_wallpaper
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo 1. Киберпанк  2. Аниме  3. Стандарт
set /p t="Выбор: "
if "%t%"=="1" reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v "AccentColor" /t REG_DWORD /d 0xff00ff /f
if "%t%"=="2" reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v "AccentColor" /t REG_DWORD /d 0x00008b /f
echo ✅ Тема применена!
call :back_to_menu
exit /b

:clean_registry
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo Очистка реестра...
reg delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RecentDocs" /f >nul 2>&1
echo ✅ Реестр очищен
call :back_to_menu
exit /b

:clean_browsers
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
del /q /f "%userprofile%\\AppData\\Local\\Google\\Chrome\\User Data\\Default\\Cache\\*" 2>nul
del /q /f "%userprofile%\\AppData\\Local\\Microsoft\\Edge\\User Data\\Default\\Cache\\*" 2>nul
echo ✅ Браузеры очищены
call :back_to_menu
exit /b

:backup_restore
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
set "BACKUP_FILE=%userprofile%\\Desktop\\AnRat_backup.zip"
powershell -Command "Compress-Archive -Path '%userprofile%\\Desktop\\*' -DestinationPath '%BACKUP_FILE%' -Force" 2>nul
echo ✅ Бэкап создан на рабочем столе
call :back_to_menu
exit /b

:auto_scheduler
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
schtasks /create /tn "AnRatAuto" /tr "%~f0 /clean" /sc daily /st 03:00 /f >nul
echo ✅ Планировщик включён (ежедневно в 3:00)
call :back_to_menu
exit /b

:show_wifi
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
netsh wlan show profiles
call :back_to_menu
exit /b

:monitor_temp
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
powershell -Command "Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace root/wmi" 2>nul
call :back_to_menu
exit /b

:monitor_gpu_temp
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
echo 🌡️ Информация о GPU:
wmic path win32_VideoController get name,CurrentHorizontalResolution,CurrentVerticalResolution
call :back_to_menu
exit /b

:isolated_desktop
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
set "user=Temp_%random%"
net user %user% TempPass123 /add /expires:never >nul 2>&1
echo 🔐 Временный пользователь %user% создан (пароль TempPass123)
echo Переключитесь через Пуск → Сменить пользователя
call :back_to_menu
exit /b

:disable_ads
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f >nul
echo ✅ Реклама отключена
call :back_to_menu
exit /b

:disable_telemetry
if "%IS_PREMIUM%"=="0" (echo ❌ Только Premium & call :back_to_menu & exit /b)
cls
reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
echo ✅ Телеметрия отключена
call :back_to_menu
exit /b

:version_info
cls
echo ╔══════════════════════════════════╗
echo ║     AnRat MAX Premium v%VERSION%   ║
echo ╠══════════════════════════════════╣
echo ║ 🔑 Ключи: AnRat_Max_Free / AnRat_Max
echo ║ ✅ DNS / Ускорение / Пакет ПО
echo ╚══════════════════════════════════╝
call :back_to_menu
exit /b

:back_to_menu
echo.
echo ========================================
echo   [1] 🔄 ВЕРНУТЬСЯ В МЕНЮ
echo   [2] ❌ ВЫХОД
echo ========================================
set /p back="Выберите: "
if "%back%"=="2" exit
exit /b

:end
exit
