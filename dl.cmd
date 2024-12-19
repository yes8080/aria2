@echo off
setlocal enabledelayedexpansion

REM 切换到 UTF-8 编码，并隐藏命令输出
chcp 65001 >nul

:: 设置默认保存路径为%USERPROFILE%\Downloads
set "default_save_path=%USERPROFILE%\Downloads"

:: 检查是否提供了下载地址
if "%~1"=="" (
    echo 下载地址是必填参数。
    exit /b 1
)
set "url=%~1"

:: 检查是否提供了保存路径
if "%~2"=="" (
    :: 获取文件名
    for %%I in ("%url%") do set "file_name=%%~nxI"

    :: 获取文件后缀
    for %%I in ("%file_name%") do set "file_extension=%%~xI"

    :: 常见的100种文件后缀
    set "common_extensions=.txt .pdf .jpg .png .zip .rar .exe .mp3 .mp4 .avi .mkv .doc .docx .xls .xlsx .ppt .pptx .html .htm .css .js .json .xml .csv .tar .gz .7z .iso .bmp .gif .tiff .svg .webp .psd .ai .eps .indd .ps .eps .ttf .otf .woff .woff2 .eot .md .cpp .c .py .java .rb .php .go .swift .sh .bat .cmd .pl .rs .kt .dart .ts .tsx .vue .jsx .xhtml .jsp .asp .aspx .cer .crt .pem .p12 .pfx .der .csr .key .jks .p7b .p7c .p8 .pem .der .p10 .p7r .srl .csr .cer .crt .pem .pfx .p7s .spc .sst .stl .obj .fbx .3ds .blend .dae .step .iges"

    :: 检查文件后缀是否在常见后缀列表中
    set "is_common=0"
    for %%E in (%common_extensions%) do (
        if /i "%%E"=="%file_extension%" set "is_common=1"
    )

    if "!is_common!"=="0" (
        :: 如果文件后缀不在常见列表中，提示用户输入文件名称（包含后缀）
        set /p "file_name=请输入文件名称（包含后缀）："
    )

    set "save_path=%default_save_path%\%file_name%"
) else (
    set "save_path=%~2"
)

:: 确保保存目录存在
if not exist "%default_save_path%" mkdir "%default_save_path%"

:: 构建aria2命令
set "command=aria2c --dir=%default_save_path% --out=%file_name% "%url%""

:: 执行命令
call %command%

endlocal
exit /b 0
