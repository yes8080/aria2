@echo off
setlocal enabledelayedexpansion

REM 切换到 UTF-8 编码，并隐藏命令输出
chcp 65001 >nul

REM 获取当前批处理文件所在的目录路径
set "script_dir=%~dp0"

REM 设置默认保存路径为用户下载目录
set "save_path=%USERPROFILE%\Downloads"

REM 检查是否提供了自定义保存路径
if not "%~2"=="" (
    set "save_path=%~2"
)

REM 检查是否提供了下载链接
if "%~1"=="" (
    echo 请提供下载链接作为第一个参数。
    exit /b 1
)

REM 禁用文件空间预分配
set "allocation_option=--file-allocation=none"

REM 尝试通过 Content-Disposition 获取文件名
for /f "tokens=2 delims==;" %%i in ('curl -I "%~1" ^| findstr /r /c:"Content-Disposition"') do (
    set "contentDisposition=%%i"
)

REM 如果存在 Content-Disposition，清理并设置文件名
if not "!contentDisposition!"=="" (
    set "filename=!contentDisposition:*filename="=!"
    set "filename=!filename:"=! "
) else (
    REM 如果没有 Content-Disposition，从 URL 中提取文件名
    for %%a in ("%~1") do set "filename=%%~nxa"
)

REM 如果文件名仍然无效，使用默认文件名
if "!filename!"=="" (
    set "filename=defaultFile"
)

REM 定义常见文件扩展名列表
set "commonExtensions= .doc .docx .xls .xlsx .ppt .pptx .pdf .txt .csv .html .htm .xml .json .log .jpg .jpeg .png .gif .bmp .svg .ico .webp .mp4 .mov .avi .mkv .wmv .flv .m4v .mp3 .wav .aac .ogg .flac .wma .zip .rar .7z .tar .gz .bz2 .exe .dll .msi .bat .sh .cmd .iso .img .vmdk .ova "

REM 获取文件扩展名
set "fileExtension=!filename:~-4!"

REM 检查文件扩展名是否常见
echo !commonExtensions! | findstr /i " !fileExtension! " >nul
if errorlevel 1 (
    echo 检测到非常见的文件扩展名: !fileExtension!
    set /p userInput=请输入保存的文件名（包括扩展名）:
    if not "!userInput!"=="" (
        set "filename=!userInput!"
    )
)

REM 构建 aria2c.exe 的完整路径并调用进行下载
"%script_dir%aria2c.exe" %allocation_option% -d "%save_path%" -o "%filename%" "%~1"

endlocal
