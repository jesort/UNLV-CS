/* 
Assignment #8 - Stock Brokerage Account
*/

#include "priorityQ.h"
#include <iostream>
#include <string>
#include <fstream>
#include <vector>
#include <iomanip>


using namespace std;

int main()
{
	cout << fixed << setprecision(2); //set output precision
	
	//variables for opening file stream
	string fileName{};
	ifstream inFile;
	bool error = false;

	priorityQ<stockType> q; //priorityQ
	vector<vector<vector<stockType>>> stocks; //[day][stock][start/end]
	vector<stockType> purchase; //keep track of the amount of times a stock has been purchased
	stocks.resize(1);
	stocks[0].resize(2);

	string line, stockName, numStr;
	double div{0}, balance{0}, price{0}, begBalance{0}, dividends{0};
	int stockCounter{0}, daysSim{0}, day{0}, start{0}, end{0}, it{0};
	
	
	

	while(!inFile.is_open()) //loops until user inputs proper file name that opens
	{
		if(error)
		{
			cout << "\nError: Unable to open file stream with given file name, try again.\n";
		}
		cout <<  "Stocks file: ";
		cin >> fileName;
		inFile.open(fileName);
		error = true;
	}

	cout << endl;
	error = false;

	while(!inFile.eof()) //loads the parsed data from Stocks.csv into stocks and purchases
		{
			getline(inFile, line);
			stockName = line.substr(0,line.find(","));
			numStr = line.substr(line.find(",")+1, line.length()-1);
			div = stod(numStr);
			stocks[0][0].push_back(stockType(stockName, div));
			purchase.push_back(stockType(stockName, div));
			stockCounter++;
		}

	stocks[0][1] = stocks[0][0]; //duplicates data to represent price at opening and closing
	
	inFile.close();
	inFile.clear();

	while(!inFile.is_open()) //loops until user inputs proper file name that opens
	{
		if(error)
		{
			cout << "\nError: Unable to open file stream with given file name, try again.\n";
		}
		cout <<  "Sim file: ";
		cin >> fileName;
		inFile.open(fileName);
		error = true;
	}

	cout << "\nAmount of days to simulate: ";
	cin >> daysSim;

	stocks.resize(daysSim, stocks[0]);
	
	cout << "\nAmount you wish to transfer into brokerage account: ";
	cin >> balance;


	while(day < daysSim) //day
		{
			for(int i = 0; i < 2; i++) //0 if opening, 1 if closing
				{
					start = end = it = 0;
					getline(inFile, line);
					// cout << line << endl;

					while(it < stockCounter) //parse lines from sim file and load data into stocks
						{
							end = line.find(",", start) - start;
							numStr = line.substr(start, end);
							price = stod(numStr);
							stocks[day][i][it].price = price;
							start = line.find(",", start) + 1;
							it++;
						}
				}
			day++;
		}

	inFile.close();
	inFile.clear();

	for(int i = 0; i < daysSim; i++)
		{
			for(int j = 0; j < stockCounter; j++)
				{
					stocks[i][0][j].timesPurchased = purchase[j].timesPurchased; //update the stocks' timesPurchased
				}
			
			begBalance = balance;
			
			cout << "\nDay " << i+1 << " Current balance $ " << balance << endl << endl;

			q = priorityQ<stockType>(stocks[i][0]); //generate priorityQueue using vector
			while((balance > 0) && (q.getSize() > 0)) 
				{
					if(q.getPriority().price < balance) //if stock can be purchased with the given balance, do so
					{
						balance -= q.getPriority().price;
						cout << "Buying one share of " << q.getPriority().name << " valued at $ " << q.getPriority().price << " per share\n";
						for(int j = 0; j < stockCounter; j++)
							{
								if(purchase[j].name == q.getPriority().name) //keep track of purchase history
								{
									purchase[j].timesPurchased++;
									stocks[i][1][j].timesPurchased++;
								}
							}
						q.deletePriority(); 
					}
					else
					{
						break;
					}
				}

			for(int j = 0; j < stockCounter; j++) //sell of stocks and add profits to balance
				{
					if(stocks[i][1][j].timesPurchased == 1)
					{
						balance += stocks[i][1][j].price;
					}
				}
			
			cout << "\nProfit made today $ " << (balance - begBalance)  << endl;
		}

	cout << "\nBalance after " << daysSim << " days $ " << balance;

	for(int i = 0; i < stockCounter; i++) //calculate dividends from stocks
		{
			dividends += purchase[i].timesPurchased * purchase[i].dividend;
		}
	cout << "\nAmount in dividends $ " << dividends << endl;

	return 0;
}
