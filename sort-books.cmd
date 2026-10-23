@echo off
rem Runs sort-books.ps1 without changing the computer's PowerShell script policy.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sort-books.ps1" %*
