/*
Assignment 9: Ancestors
*/

#include <iostream>
#include <fstream>
#include <vector>
#include <unordered_map>
#include <list>
#include <string>
#include <algorithm>

using namespace std;

bool ancestry(string current, string descendant, unordered_map<string, list<string>> famTree, unordered_map<string, bool>& ancestors, unordered_map<string, bool>& visited)
{
	bool returnBoolean = false;

	//base case
	if(current == descendant)
	{
		return true;
	}

	//wrapper function within the main function.
	//it's purpose is to iterate through each ancestor found in famTree and trigger recursion
	if(current == "wrapper")
	{
		for(auto it = famTree.begin(); it != famTree.end(); it++)
		{
			if(!visited[it->first])
			{
				if(ancestry(it->first, descendant, famTree, ancestors, visited))
				{
					returnBoolean = true;
				}
			}
		}
	}
	else
	{
		//traverse graph and determine if current is an ancestor of descendant
		visited[current] = true;
		if(famTree[current].size() != 0)
		{
		for(auto it = famTree[current].begin(); it != famTree[current].end(); it++)
			{
				if(ancestry(*it, descendant, famTree, ancestors, visited))
				{
					ancestors[current] = returnBoolean = true;
				}
			}	
		}
	}
	
	return returnBoolean;
}

int main()
{
	//variables for opening file stream
	string fileName{};
	ifstream inFile;
	bool error = false;

	string line, from, to; //variables used in parsing input file

	unordered_map<string, list<string>> adjList; //out-neighbor adjacency list
	unordered_map<string, vector<string>> orderedTree; //<descendant, list of ancestors>
	unordered_map<string, bool> ancestors; //<family member, (if family member is an ancestor of the descendant)>
	unordered_map<string, bool> visited; //<family member, (if family member has been visited during recursion)>
	unordered_map<string, bool> null; //reset ancestors and visited back to their original states
	vector<string> names; //names of all family members stored alphabetically
	vector<string> outputVector; //the value of orderedTree, exists to make the output iteration easier
	
	//open file stream
	while(!inFile.is_open())
		{
			if(error)
			{
				cout << "\nError: Unable to open file stream with given file name, try again.\n";
			}
			cout <<  "Enter file: ";
			cin >> fileName;
			inFile.open(fileName);
			error = true;
		}

	cout << endl;

	//parse through file and record data
	getline(inFile, line);	
	while(!inFile.eof())
		{
			from = line.substr(0, line.find(" ->"));
			to = line.substr( line.find("->")+3 , line.length()-1);

			visited[from] = false;
			visited[to] = false;

			adjList[from].push_back(to);
			
			getline(inFile, line);
			if(line.empty())
			{
				inFile >> line; //ensure file iterator reaches the end of the file
			}
		}
	
	inFile.close();


	//record all names into `names` to have it sorted alphabetically used for iteration
	for(auto it = visited.begin(); it != visited.end(); it++)
		{
			names.push_back(it->first); 
		}
	sort(names.begin(), names.end());
	
	ancestors = null = visited;

	for(long unsigned int i = 0; i < names.size(); i++)
		{
			visited[names[i]] = true;
			if(ancestry("wrapper", names[i], adjList, ancestors, visited)) //if names[i] does have ancestors
			{
				for(auto it = ancestors.begin(); it != ancestors.end(); it++)
					{
						if(it->second)
						{
							orderedTree[names[i]].push_back(it->first); //record ancestors
						}
					}
			}
			else
			{
				orderedTree[names[i]].push_back("None"); //if names[i] doesn't have ancestors, record "None"
			}
			visited = ancestors = null; //return variables to original state
		}

		//alphabetically sorts the vector<string> value of the hash map orderedTree
		for(auto it = orderedTree.begin(); it != orderedTree.end(); it++)
		{
			sort(it->second.begin(), it->second.end());
		}


		//output the results
		for(long unsigned int i = 0; i < names.size(); i++)
			{
				cout << "Relative Name: " << names[i] << "\nList of ancestors\n";
				outputVector = orderedTree[names[i]];
				for(long unsigned int i = 0; i < outputVector.size(); i++)
					{
						cout << outputVector[i] << endl;
					}
				cout << endl;
			}

	return 0; //chicken
}
