@echo off
REM Usage: run_main.cmd [RUN_ID] [ORDER] [OMEGA] [ZETA]
REM Example: run_main.cmd EX-001-R010 2 12.0 1.0
REM No args = default test run

if "%~1"=="" (
    chuck src/main.ck
) else (
    chuck src/main.ck:%~1:%~2:%~3:%~4
)
