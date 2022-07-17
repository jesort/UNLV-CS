// Assignment #4: Matrix Multiplication in Parallel (Due 2/25/22 @ 11:59 P.M.)
	
#include <iostream>
#include <fstream>
#include <vector>
#include <thread>

using namespace std;

//global variable
vector<vector<int>> matrixOne, matrixTwo, matrixResult;

//the purpose of this void function is to calculate the entry (r, c) of MatrixResult when doing
//matrix multiplication between matrixOne and matrixTwo
void const indexCalc(int r, int c)
{
	int entry {0};
	
	for(int i = 0; i < int(matrixOne[r].size()); i++)
		{
			entry = entry + (matrixOne[r][i])*(matrixTwo[i][c]);		
		}

	matrixResult[r][c] = entry;
	
	return;
};

int main() 
{
	string fileName {};
	ifstream inFile;
	int input;
	bool error = false;
	vector<int> matrixSize;
  vector<thread> threadPool;
	int maxThreads = thread::hardware_concurrency(); //repli.it, maxThreads = 8

	while(!inFile.is_open()) //loops until user inputs proper file name that opens
	{
		if(error)
		{
			cout << "Error: Unable to open file stream with given file name, try again.";
		}
		cout <<  "Enter filename: ";
		cin >> fileName;
		cout << endl;
		inFile.open(fileName);
		error = true;
	}

	//read values from the .txt file, generate matrixOne and matrixTwo, and populate the matrices.
	while(!inFile.eof())
	{
		//read matrixOne's dimensions
		inFile >> input;
		matrixSize.push_back(input);
		inFile >> input;
		matrixSize.push_back(input);

		//generate matrixOne
		matrixOne.resize(matrixSize[0], vector<int>(matrixSize[1],0));

		//populate matrixOne
		for (int i = 0; i < matrixSize[0]; i++)
			{
				for(int j = 0; j < matrixSize[1]; j++)
					{
						inFile >> input;
						matrixOne[i][j] = input; 
					}
			}

		//read matrixTwo's dimensions
		inFile >> input;
		matrixSize.push_back(input);
		inFile >> input;
		matrixSize.push_back(input);

		//generate matrixTwo
		matrixTwo.resize(matrixSize[2], vector<int>(matrixSize[3],0));

		//populate matrixTwo
		for (int i = 0; i < matrixSize[2]; i++)
			{
				for(int j = 0; j < matrixSize[3]; j++)
					{
						inFile >> input;
						matrixTwo[i][j] = input; 
					}
			}

		//extra fstream call to reach the end of the file 
		inFile >> input;
	}

	inFile.close(); //close file
	inFile.clear();
	fileName.clear();

	//If the matrices are compatiable for matrix multiplication, following code will execute
	//Instead of calculate the matrix product of the matrices sequentially, we will utilize threads to 
	//individually caculate the entries of matrixResult. ENTRY/THREAD
	if(matrixSize[1] == matrixSize[2])
	{
		matrixResult.resize(matrixSize[0], vector<int>(matrixSize[3],0));

		
		for(int i = 0; i < matrixSize[0]; i++) //iterate through each row of matrixResult
			{
				for(int j = 0; j < matrixSize[3]; j++) //iterate through each column of matrixResult
					{
						if(int(threadPool.size()) == maxThreads) //if threadPool reaches its size limit, join threads
						{
							for(int i = 0; i < threadPool.size(); i++)
							{
								threadPool[i].join();
							}
							threadPool.clear();
						}
							threadPool.push_back(thread(indexCalc,i,j)); //push threads into the threadPool
					}
			}

		for(int i = 0; i < int(threadPool.size()); i++) //join the remaining threads
		{
			threadPool[i].join();
		}

		//output matrixResult
		for (int i = 0; i < matrixSize[0]; i++)
		{
			for(int j = 0; j < matrixSize[3]; j++)
				{
					cout << matrixResult[i][j] << " ";
				}
			cout << endl;
		}		
	}

	return 0;
}