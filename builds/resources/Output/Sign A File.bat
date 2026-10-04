@echo off
setlocal

:: Demanar nom de l'arxiu a signar
set /p arxiu="File to sign (with extension): "

:: Verificar que s'hagi introduït algun valor
if "%arxiu%"=="" (
    echo You did not enter any value. Stopping...
    goto :fi
)

:: Executar signtool amb l'arxiu indicat
signtool.exe sign /f Nagema_Game_Studio.pfx /fd SHA256 /p k58396745jj88 "%arxiu%"

:fi
endlocal
pause