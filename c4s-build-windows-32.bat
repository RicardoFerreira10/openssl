echo off
setlocal

rem ########################################################
rem ########################################################
rem ################### OPENSSL SOURCE #####################
rem ########################################################
rem ########################################################

set VERSION="1.0.2n"
set URL="https://www.openssl.org/source/openssl-1.0.2n.tar.gz"
set SOURCE="openssl-1.0.2n"
set LIB_ROOT_DIR=%CD%
set SOURCE_DIR=%LIB_ROOT_DIR%\openssl-1.0.2n
set LIB_OUTPUT_DIR=%LIB_ROOT_DIR%\c4s.build\libs\%WIN_VERSION%\32\
set INCLUDE_OUTPUT_DIR=%LIB_ROOT_DIR%\c4s.build\include\

:clean 

if exist %SOURCE%.tar.gz del %SOURCE%.tar.gz
if exist %SOURCE%.tar del %SOURCE%.tar
if exist %SOURCE_DIR% rmdir /s/q %SOURCE_DIR%
if exist c4s.build\libs\ rmdir /s/q c4s.build\libs\
if exist c4s.build\include\ rmdir /s/q c4s.build\include\
if exist pax_global_header del pax_global_header

:download
call ..\config\windows\tools\wget.exe %URL% && ^
call %ZIP_PATH%\7z x %SOURCE%.tar.gz && ^
call %ZIP_PATH%\7z x %SOURCE%.tar && ^

:build
echo "Building %SOURCE% for Windows x86"

cd %SOURCE_DIR%
call perl Configure VC-WIN32 no-comp -no-shared no-asm  --prefix=. && ^
call ms\do_ms.bat && ^
call nmake -f ms\nt.mak  && ^
call nmake -f ms\nt.mak install  && ^


if exist %LIB_OUTPUT_DIR% rmdir /s/q %LIB_OUTPUT_DIR%
mkdir %LIB_OUTPUT_DIR%
xcopy /s/e/y %SOURCE_DIR%\out32\*.lib  %LIB_OUTPUT_DIR%

if exist %INCLUDE_OUTPUT_DIR% rmdir /s/q %INCLUDE_OUTPUT_DIR%
mkdir %INCLUDE_OUTPUT_DIR%
robocopy %SOURCE_DIR% %INCLUDE_OUTPUT_DIR% /S /IF *.h

dir %LIB_OUTPUT_DIR%
dir %INCLUDE_OUTPUT_DIR%


endlocal