@echo off
PowerShell -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"irm christitus.com/win ^| iex\"' -Verb RunAs"
