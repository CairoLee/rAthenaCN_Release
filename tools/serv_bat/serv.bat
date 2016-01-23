@ECHO OFF
IF "%1"=="" GOTO DIRECT
IF "%2"=="" GOTO DIRECT
IF NOT EXIST "%1" GOTO NOTFOUND
GOTO START

REM == How RESTART_9X and RESTART_NT works =========================
REM On Windows 9x only the first 8 characters are significant for
REM labels, and the first matching one is called (RESTART_(9X)).
REM Windows NT calls the exact named label (RESTART_NT).
REM Separation between 9X and NT is required, because CHOICE has
REM different syntax on these platforms or does not exist as all.
REM ================================================================

REM Windows 95, 98, ME
:RESTART_9X
REM Old Ctrl+C in PING does not work, because that only stops ping,
REM not the batch file.
CHOICE /C:rc /N /T:R,15 将在 15 秒之内重启服务程序，按 'C' 键可以取消.
IF NOT ERRORLEVEL 2 GOTO START
GOTO END

REM Windows 2000, XP, Vista, 7
:RESTART_NT
REM There is no CHOICE in 2000 and XP, but you get asked whether to
REM abort the batch file, when pressing Ctrl+C in PING.
ECHO 将在 15 秒之内重启服务程序，按 Ctrl+C 可以取消.
PING -n 15 127.0.0.1 > NUL

:START
%1
ECHO.
REM Return value > 1 is exception&~0xC0000000
IF ERRORLEVEL 2 GOTO CRASHED
REM Return value 1 is EXIT_FAILURE
IF ERRORLEVEL 1 GOTO EXIT1
REM Return value 0 is EXIT_SUCCESS
ECHO %2 已经成功关闭.
GOTO RESTART_NT

:EXIT1
ECHO %2 被异常终止.
GOTO RESTART_NT

:CRASHED
ECHO %2 已经崩溃!
GOTO RESTART_NT

:DIRECT
ECHO 请不要直接运行这个文件. 这个文件是为了给其他批处理文件调用而设计的.
GOTO END

:NOTFOUND
ECHO 很抱歉，找不到 %1 请先确认您已经编译了 %2.
GOTO END

:END
PAUSE
