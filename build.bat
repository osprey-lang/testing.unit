@echo off

rem Path to the compiler
set OSPC="%OSP%\Osprey\bin\Release\Osprey.exe"
rem Path to the library folder
set LIB=%OSP%\lib

if not exist "%LIB%\testing.unit\" (
	echo Creating directory %LIB%\testing.unit
	mkdir "%LIB%\testing.unit"
)

%OSPC% /libpath "%LIB%" /type module /out "%LIB%\testing.unit\testing.unit.ovm" /doc "%LIB%\testing.unit\testing.unit.ovm.json" /verbose src\testing.unit.osp
