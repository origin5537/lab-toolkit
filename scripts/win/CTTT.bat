:: Opens Chris Titus Tech Tools website in a new PowerShell window with elevated privileges. 
::Double click to run.

@echo off
PowerShell -Command "Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"irm christitus.com/win ^| iex\"' -Verb RunAs"
