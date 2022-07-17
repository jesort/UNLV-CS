/*
Assignment 6: Word Classification
*/

#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <unordered_map>

using namespace std;

struct categories
{
	bool accounted; //If keyword is found within test case, bool is assigned true.
	string category, keyword;
	
	categories()
	{
		accounted = false;
		category = keyword = "";
	}

	categories(string c, string k)
	{
		accounted = false;
		category = c;
		keyword = k;
	}
};

struct reference
{
	//numNecessary is the exact amount of keyword occurrences in the test case required for it to be classified as the category
	//count is the number of actual occurrances of keywords found in the test case
	int numNecessary, count;

	reference()
	{
		numNecessary = count = 0;
	}

	reference(int num)
	{
		numNecessary = num;
		count = 0;
	}
};


int main()
{
	//hash maps
	vector<unordered_map<string, reference>> ref; //string stores the category name
	vector<unordered_map<string, categories>> terms; //string stores the keyword name

	//iterators
	unordered_map<string, categories>::iterator it;
	unordered_map<string, reference>::iterator itR;

	//variables for opening file stream
	string fileName{};
	ifstream inFile;
	bool error = false;

	//variables for inputting data from file stream
	int testCases, numCategories, numWords, numNec{};
	string word, upperWord, cateName, tempStr{};
	vector<string> text;
	

	//variables for calculation/outputting
	int start, end;
	vector<vector<string>> identity;
	vector<bool> outputBool;

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

	//size vectors of hash maps to the appropriate size
	inFile >> testCases;
	ref.resize(testCases);
	terms.resize(testCases);
	
	int caseCount = 0;
  while(!inFile.eof())
		{
			//inputting test case, category names, keywards, and number of required occurrences into hash maps
			inFile >> numCategories;
			identity.push_back(vector<string>(numCategories,""));
			for(int i = 0; i < numCategories; i++)
			{	
				inFile >> cateName;
				inFile >> numWords;
				inFile >> numNec;
				ref[caseCount][cateName] = numNec;
				identity[caseCount][i] = cateName;
				for(int j = 0; j < numWords; j++)
				{
					inFile >> word;
					upperWord = word;
					upperWord[0] = toupper(upperWord[0]);
					terms[caseCount][upperWord] = categories(cateName, word);
				}							
			}

			//this body of code is reponsible for loading the entire abstract into a single string
			 getline(inFile, tempStr);
			 text.push_back(tempStr);
			 while(true)
			 	{
					getline(inFile, tempStr);
				 	if(tempStr.empty())
					{
						break;
					}
		 			text[caseCount] = text[caseCount] + " " + tempStr;
				} 
			 text[caseCount] = text[caseCount] + " ";
			
			 caseCount++; //increment the case count for the vectors
			
			if(caseCount == testCases)
			{
				inFile >> tempStr; //to reach the end of the file
			}
	 	}

	inFile.close(); //close file
	inFile.clear();
	// fileName.clear();

	for(unsigned long i = 0; i < text.size(); i++)
		{
			start = 1; // start of the word
			end = text[i].find(" ", start); //end of the word
			
			while(start != text[i].size()) //while start hasn't reached the end of the string
				{
					tempStr = text[i].substr(start, end-start);
					tempStr[0] = toupper(tempStr[0]); //transform to match hash map index's formatting

					if(terms[i][tempStr].keyword.empty()) //if the substring isn't found in the hash map
					{
						terms[i].erase(tempStr); //delete useless entry
					}
					else
					{
						terms[i][tempStr].accounted = true; //if substring found in hash map, account for keyword
					}

					start = end + 1; //increment to the start next word
					end = text[i].find(" ", start); //increment to the end of the next word
				}
		}

	//Goes through hash maps and count the number of keywords found in the abstract
	for(unsigned long i = 0; i < terms.size(); i++)
	{
		for(it = terms[i].begin(); it != terms[i].end(); it++)
			{
				if(it->second.accounted == true)
				{
					ref[i][it->second.category].count++;
				}
			}
	}

	//check if the number of occurrences matches with the exact requirement of occurrences
	for(unsigned long i = 0; i < ref.size(); i++)
	{
		outputBool.push_back(false);
		for(itR = ref[i].begin(); itR != ref[i].end(); itR++)
			{
				if(itR->second.numNecessary == itR->second.count)
				{
					outputBool[i] = true;
				}
				else
				{
					for(unsigned long j = 0; j < identity[i].size(); j++)
						{
							if(identity[i][j] == itR->first)
							{
								identity[i][j] = "SQF Problem";
							}
						}
				}
			}
	}

	//output results
	for(unsigned long j = 0; j < terms.size(); j++)
		{
			cout << "Test case " << j+1 << endl;
			for(unsigned long i = 0; i < identity[j].size(); i++)
			{	
				if(outputBool[j] && (identity[j][i] != "SQF Problem"))
				{
					cout << identity[j][i] << endl;
				}

				if(!outputBool[j])
				{
					cout << identity[j][i] << endl;
					break;
				}
			}
		}
	return 0;
}
