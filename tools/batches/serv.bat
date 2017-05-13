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
CHOICE /C:rc /N /T:R,15 ���� 15 ��֮������������򣬰� 'C' ������ȡ��.
IF NOT ERRORLEVEL 2 GOTO START
GOTO END

REM Windows 2000, XP, Vista, 7
:RESTART_NT
REM There is no CHOICE in 2000 and XP, but you get asked whether to
REM abort the batch file, when pressing Ctrl+C in PING.
ECHO ���� 15 ��֮������������򣬰� Ctrl+C ����ȡ��.
PING -n 15 127.0.0.1 > NUL

:START
%1
ECHO.
REM Return value > 1 is exception&~0xC0000000
IF ERRORLEVEL 2 GOTO CRASHED
REM Return value 1 is EXIT_FAILURE
IF ERRORLEVEL 1 GOTO EXIT1
REM Return value 0 is EXIT_SUCCESS
ECHO %2 �Ѿ��ɹ��ر�.
GOTO RESTART_NT

:EXIT1
ECHO %2 ���쳣��ֹ.
GOTO RESTART_NT

:CRASHED
ECHO %2 �Ѿ�����!
GOTO RESTART_NT

:DIRECT
ECHO �벻Ҫֱ����������ļ�. ����ļ���Ϊ�˸������������ļ����ö���Ƶ�.
GOTO END

:NOTFOUND
ECHO �ܱ�Ǹ���Ҳ��� %1 ����ȷ�����Ѿ������� %2.
GOTO END

:END
PAUSE
