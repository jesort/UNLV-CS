/*
Assignment #7 - Vote Counter
*/

#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include "hashMap.h"

using namespace std;

struct ballot
{
	string name, party;
	int votes;

	ballot()
	{
		name = party = "";
		votes = 0;
	}

	ballot(string n, string p)
	{
		name = n;
		party = p;
		votes = 0;
	}
};

int main()
{
	//variables for opening file stream
	string fileName{};
	ifstream inFile;
	bool error = false;
	
	//variables for hashMap
	vector<hashMap<string, ballot>> map; //hashMap
	vector<ballot> result; //winning candidate
	int numCases, numCandidates, caseCount, numBallots{0};
	string numStr, candName, candParty, eofStr{};
	bool tie = false;

	
	while(!inFile.is_open()) //loops until user inputs proper file name that opens
	{
		if(error)
		{
			cout << "\nError: Unable to open file stream with given file name, try again.\n";
		}
		cout <<  "Enter filename: ";
		cin >> fileName;
		inFile.open(fileName);
		error = true;
	}

	//record the number cases within the text file and resize vectors to necessary size
	getline(inFile, numStr);
	numCases = stoi(numStr);
	map.resize(numCases);
	result.resize(numCases);

	caseCount = 0;

	while(!inFile.eof())
		{
			//record the number of candidates in case
			getline(inFile, numStr);
			numCandidates = stoi(numStr);

			//record and submit the candidates' ballot information into the hash map
			for(int i = 0; i < numCandidates; i++)
				{
					getline(inFile, candName);
					getline(inFile, candParty);
					map[caseCount][candName] = ballot(candName,candParty);
				}

			//record the number of ballots casted
			getline(inFile, numStr);
			numBallots = stoi(numStr);

			//record and increment the votes candidates earned 
			for(int i = 0; i < numBallots; i++)
				{
					getline(inFile, candName);
					map[caseCount][candName].votes++;
				}

			//increment onto the next case
			caseCount++;

			//if all cases have been recorded and submitted, inFile to reach the end of the file
			if(caseCount == numCases)
			{
				inFile >> eofStr;
				inFile >> eofStr;
			}
		}

	inFile.close();

	//determine the winning candidate's party
	for(int i = 0; i < numCases; i++)
		{
			for(hashMap<string, ballot>::iterator it = map[i].begin(); it != map[i].end(); it++)
			{
				if(it.second().votes > result[i].votes)
				{
					tie = false;
					result[i].name = it.first();
					result[i].party = it.second().party;
					result[i].votes = it.second().votes;
				}
				else if(it.second().votes == result[i].votes)
				{
					tie = true;
				}
			}
		}

	//output the election results for each case
	for(int i = 0; i < numCases; i++)
		{
			cout << "Case " << i+1 << " results: ";
			if(!tie)
			{
				cout << result[i].party << endl;
			}
			else
			{
				cout << "tie\n";
			}
		}

	return 0;
}
