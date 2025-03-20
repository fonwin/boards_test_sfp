::@echo off
pushd %~dp0

xcopy /y ..\si_0001_sfp\si_0001_sfp.runs\impl_1\si_0001_pcspma.bit
xcopy /y ..\si_0001_sfp\si_0001_sfp.runs\impl_1\si_0001_pcspma.ltx
xcopy /y ..\si_0002_sfp\si_0002_sfp.runs\impl_1\si_0002_pcspma.bit
xcopy /y ..\si_0002_sfp\si_0002_sfp.runs\impl_1\si_0002_pcspma.ltx
xcopy /y ..\si_xc7k325t_sfp\si_xc7k325t_sfp.runs\impl_1\si_xc7k325t_pcspma.bit
xcopy /y ..\si_xc7k325t_sfp\si_xc7k325t_sfp.runs\impl_1\si_xc7k325t_pcspma.ltx

del /q *.zip
"c:\Program Files\7-Zip\7z.exe" a si_pcspma.zip si_*.bit si_*.ltx

popd