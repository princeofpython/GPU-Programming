#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <fstream>
#include <iomanip>
using namespace std;

bool checkOutput(string filename1, string filename2);
float studentKernelExecTime;

int main(int argc, char *argv[])
{
		if(argc != 3)
		{
				cout << "Usage: " << argv[0] << " <studentOutputFile> <seqOutputFile>" << endl;
				exit(0);
		}
		string studentOutputFile = argv[1];
		string seqOutputFile = argv[2];
		cout << fixed;
		cout << setprecision(6);
		bool isCorrect = checkOutput(studentOutputFile, seqOutputFile);
		if(isCorrect)
				cout << "Success " << endl;
		else
				cout << "Failure " << endl;
		return 0;
}

bool checkOutput(string studentOutputFile, string seqOutputFile)
{
	fstream studentFile(studentOutputFile.c_str(), ios_base::in);
	fstream baselineFile(seqOutputFile.c_str(), ios_base::in);
	int x, y;
	int flag=0;
	while(baselineFile >> x)
	{
		flag=1;
		studentFile >> y;
		if(x != y)
				return false;
	}
	if(flag==0)
	return false;

	return true;
}
