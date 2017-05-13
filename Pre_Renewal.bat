@echo off
rem This is and auto-restart script for the rAthena Ragnarok Online Server Emulator.
rem It will also keep the map server OPEN after it crashes to that errors may be
rem more easily identified
rem Writen by Jbain
start cmd /k tools\batches\logserv-pre.bat
start cmd /k tools\batches\charserv-pre.bat
start cmd /k tools\batches\mapserv-pre.bat
