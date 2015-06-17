@echo off

rem Path to the compiler
set OSPC="%OSP%\Osprey\bin\Release\Osprey.exe"
rem Path to the library folder
set LIB=%OSP%\lib

%OSPC% /libpath "%LIB%" /type module /out "%LIB%\testing.unit.ovm" /doc "%LIB%\testing.unit.ovm.json" /verbose testing.unit.osp
