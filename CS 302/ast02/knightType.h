#ifndef KNIGHT_TYPE_H
#define KNIGHT_TYPE_H

// Assignment #2: Knight Problem

#include <vector>
#include <iostream>

using namespace std;

class knightType
{
	public:
		struct position
		{
			position(int r = 0, int c = 0, int o = 0)
			{
				row = r;
				col = c;
				onwardMoves = o;
			}

			int row;
			int col;
			int onwardMoves;
		};
	
		knightType(int = 8);
		bool knightTour(int, int);
		void outputTour() const;

	private:
		bool knightTour(int, int, int);
		std::vector<position> getAvailableMoves(int, int);
		bool fullBoard();
		std::vector<std::vector<int>> board;
		int functionsCalled;
};

//KnightType constructor, arg `dim` sets size of the 2D vector
knightType::knightType(int dim)
{
	board.resize(dim); //sets row size of 2D vector to `dim`

	for(int i = 0; i < dim; i++)
	{
		board[i].resize(dim); //sets column size of 2D vector to `dim`
	}

	functionsCalled = 0;
}

vector<knightType::position> knightType::getAvailableMoves(int r, int c)
{
	knightType::position tempObj;
	vector<knightType::position> returnObj;
	//2D vector calculating all the potentional tiles the knight can move to from (r,c)
	vector<vector<int>> testPosition = {{r-1,c-2}, {r-1,c+2}, {r-2,c-1}, {r-2,c+1}, {r+1,c-2}, {r+1,c+2}, {r+2,c-1}, {r+2,c+1}};  

	for(int i = 0; i < 8; i++)
	{
		tempObj.row = testPosition[i][0];
		tempObj.col = testPosition[i][1];

		//check if coordinates are within the board's range
		if(tempObj.row >= 0 && tempObj.row < (int(board.size())) && tempObj.col >= 0 && tempObj.col < int(board.size()))
		{
			//check if coordinates point to an unused tile
			if(board[tempObj.row][tempObj.col] == 0)
			{
				//add coordinates to list of potentional tiles knight can legally move to from tile (r,w)
				returnObj.push_back(tempObj); 
			}
		}
	}

	int tempR{0}, tempC{0};

	//following code's purpose is to count the amount of onwardMoves of each tile defined in returnObj's list
	for(int i = 0; i < int(returnObj.size()); i++)
	{
		tempR = returnObj[i].row;
		tempC = returnObj[i].col;

		//creates list of potentional tiles knight can move to from position (returnObj[i].row, returnObj[i].col)
		testPosition = {{tempR-2,tempC-1},{tempR-2,tempC+1},{tempR+2,tempC-1},{tempR+2,tempC+1},{tempR-1,tempC-2},{tempR+1,tempC-2},{tempR-1,tempC+2},{tempR+1,tempC+2}};

		for(int j = 0; j < 8; j++)
		{
			tempObj.row = testPosition[j][0];
			tempObj.col = testPosition[j][1];
			//check if coordinates are within the board's range
			if(tempObj.row >= 0 && tempObj.row < (int(board.size())) && tempObj.col >= 0 && tempObj.col < int(board.size()))
			{
				//check if coordinates point to an unused tile
				if(board[tempObj.row][tempObj.col] == 0)
				{
					//add coordinates to list of potentional tiles knight can legally move to from tile (r,w)
					returnObj[i].onwardMoves++; 
				}
			}
		}		
	}

	//following code's purpose is to sort returnObj based on onwardMoves from least to greatest
	//BubbleSort

	int swapRow{0}, swapCol{0}, swapOM{0};

	for(int i = 0; i < int(returnObj.size()-1); i++)
	{
		for(int j = 0; j < int(returnObj.size()-i-1); j++)
		{
			if(returnObj[j].onwardMoves > returnObj[j+1].onwardMoves)
			{
				swapRow =	returnObj[j].row; 
				swapCol = returnObj[j].col;
				swapOM = returnObj[j].onwardMoves;

				returnObj[j].row = returnObj[j+1].row; 
				returnObj[j].col = returnObj[j+1].col;
				returnObj[j].onwardMoves = returnObj[j+1].onwardMoves;

				returnObj[j+1].row = swapRow; 
				returnObj[j+1].col = swapCol;
				returnObj[j+1].onwardMoves = swapOM;

				swapRow = 0;
				swapCol = 0;
				swapOM = 0;
			}
		}
	}

	//return sorted obj contain the knight's possible moves
	return returnObj;
}

bool knightType::fullBoard()
{
	bool boardFull = true;

	//check through ever entry to confirm the board has been completely filled
	for(int i = 0; i < int(board.size()); i++)
	{
		for(int j = 0; j < int(board[i].size()); j++)
		{
			if(board[i][j] == 0)
			{
				boardFull = false;
				break;
			}
		}

		if(!boardFull)
		{
			break;
		}
	}
	//returns true if ever entry in the 2D vector is filled
	return boardFull;
}

void knightType::outputTour() const
{
	vector<char> alpha = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
	
	if(int(board.size())>53)
	{
		cout << "Board dimensions are too large to output" << endl;
		return;
	}

	//output top row of letters
	cout << endl << "    ";
	for(int i = 0; i < int(board.size()); i++)
	{
		cout << alpha[i] << "   ";
	}

	cout << endl;

	//output row letter followed by the entries associated with that row
	for(int i = 0; i < int(board.size()); i++)
	{
		cout << alpha[i] << "   ";
		
		for(int j = 0; j < int(board.size()); j++)
		{
			cout << board[i][j];
			if(board[i][j] < 10)
			{
				cout <<  "   ";
			}
			else
			{
				if(board[i][j] < 100)
				{
				cout << "  ";
				}	
				else
				{	
					cout << " ";
				}
			}
		}
		cout << endl;
	}

	cout << endl << "Functions called:  " << functionsCalled << endl << endl;

	return;
}

bool knightType::knightTour(int r, int c)
{
	return knightTour(r,c,1);	
}

bool knightType::knightTour(int r, int c, int tourIndex)
{
	bool escape = false;
	board[r][c] = tourIndex;
	functionsCalled++;
	
	vector<knightType::position> avaPos;

	tourIndex++;

	//exit condition to escape the recursion
	if(fullBoard() || functionsCalled == 5)
	{
		escape = true;
	}
	else
	{
		avaPos = getAvailableMoves(r,c);

		//if the chosen path is a dead end, changes will be reverted and function returns false
		if(avaPos.empty() && !fullBoard())
		{
			board[r][c] = 0;
		}
		else
		{
			outputTour();
			cout << "tourIndex: " << tourIndex << endl;
			for(int i = 0; i < int(avaPos.size()); i++)
				{
					cout << "[" <<i<<"].row:" << avaPos[i].row <<endl;
					cout << "[" <<i<<"].col:" << avaPos[i].col <<endl;
					cout << "[" <<i<<"].onwardMoves:" << avaPos[i].onwardMoves <<endl << endl;
			
				}





			
			for(int i = 0; i < int(avaPos.size()); i++)
			{
				// if conditionl is true, escape for loop and function returns true
				if(knightTour(avaPos[i].row, avaPos[i].col, tourIndex))
				{	
					escape = true;
					break;
				}
			}
		}
	}

	return escape;
}

#endif
