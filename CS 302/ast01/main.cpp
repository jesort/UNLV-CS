/*
Assignment #1 - Bubble Sort on a doubly linked list
*/

#include <iostream>
#include <fstream>
#include <string>

#include "linkedList.h"

using namespace std;

int main() 
{
	linkedList<int> list;
	linkedList<int>::iterator it;
	linkedList<int>::iterator nil(nullptr);

	string fileName {};
	ifstream inFile;
	int input;
	bool error = false;

	while(!inFile.is_open()) //loops until user inputs proper file name that opens
	{
		if(error)
		{
			cout << "Error: Unable to open file stream with given file name, try again.";
		}
		cout <<  endl << "Enter file with list: ";
		cin >> fileName;
		inFile.open(fileName);
		error = true;
	}

	inFile >> input;

	cout << "Original List" << endl;

	while(!inFile.eof()) // inputs data from file into linked list
	{
		list.tailInsert(input);
		cout << input << " "; //output unsorted linked list
		inFile >> input;
	}

	inFile.close(); //close file
	inFile.clear();
	fileName.clear();
 
	cout << endl << endl << "Sorted List" << endl;


	//BubbleSort
	linkedList<int>::iterator it2, it3, itEnd;
	itEnd = list.end();

	while(itEnd != nil)
	{
		it2 = list.begin();
		it3 = it2;
		it3++;

		while(it3 != nil)
		{
			if(*it2 > *it3)
			{
				list.swapNodes(it2,it3);
				it3 = it2;
				it3++;
			}
			else
			{
				it2++;
				it3++;
			}
		}
		itEnd--;
	}


	it = list.begin();
	//output sorted linked list
	while(it != nil)
	{
		cout << *it << " ";
		it++;
	}
	cout << endl;
	return 0;
} 