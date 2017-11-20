@echo off
:: A script to make Pictures-to-Sound easy to use.
:: It calls unprocess.m, with the file supplied to it as an argument.
call set_path.cmd
set fn=%1
set fn=%fn:"=%
echo unprocess('%fn%') | octave
