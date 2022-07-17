/*
Extra Credit Assignment
Thanks again for the good times, Jimi.
*/

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <unordered_map>
#include <queue>
#include <list>
#include <stack>
using namespace std;

struct node
{
	int weight; //vertex weight
	int pathWeight; //edgeWeight
	string name; //vertex name

	node()
	{
		weight = 0;
		pathWeight = 0;
		name = "";
	}

	node(int w, int pW, string n)
	{
		weight = w;
		pathWeight = pW;
		name = n;
	}

	bool operator>(const node& rhs) const //minHeap
	{
		return (weight < rhs.weight);
	}

	bool operator<(const node& rhs) const //minHeap
	{
		return (weight > rhs.weight);
	}

	
};

void findPath(string current, unordered_map<string, string> predecessor, stack<string>& path, unordered_map<string, node> weight)
{
	if(path.size() == 0 && predecessor[current] == "-1") //base case, when dijkstra's algorithm cannot find a path
	{
		path.push("No path found");
		return;
	}
	path.push(current);
	current = predecessor[current];
	if(current != "-1") //if it isn't the start node
	{
		findPath(current, predecessor, path, weight); //pre-order recursion
	}
}

void dijkstra(string start, unordered_map<string, list<node>> adjList, unordered_map<string, string>& predecessor, unordered_map<string, node>& weight)
{
	node u;
	priority_queue<node> bfsPQ;
	weight[start].weight = 0;
	bfsPQ.push(weight[start]);

	while(!bfsPQ.empty())
		{
			u = bfsPQ.top(); //push and pop node with greatest priority in bfsPQ's minHeap
			bfsPQ.pop();

			for(auto it = adjList[u.name].begin(); it != adjList[u.name].end(); it++) //iterate through adjList
				{
						if(weight[it->name].weight >= it->pathWeight + weight[u.name].weight) //if a better path is found
						{
							weight[it->name].weight = weight[u.name].weight; //set the descendant's weight to ancestor's
							
							if(it->pathWeight - weight[u.name].weight > 0) //add the positive edge difference
							{
								weight[it->name].weight += (it->pathWeight - weight[u.name].weight);
							}
							
							predecessor[it->name] = u.name; //set the predecessor of the descendant
							bfsPQ.push(weight[it->name]); //push new vertex into bfsPQ
						}
				}
		}
}




int main()
{
	//variables for opening file stream
	string fileName{};
	ifstream inFile;
	bool error = false;

	//variables for parsing
	int pathWeight = 0;
	string start, end, line, from, to, num;

	unordered_map<string, list<node>> adjList; //adjacency list, <from-node, to-nodes>
	unordered_map<string, string> predecessor; //<descendant node, ancestor node>
	unordered_map<string, node> weight; //<node name, node.weight>
	stack<string> path; //used to reverse the order in predecessor
	
	//open file stream
	while(!inFile.is_open())
		{
			if(error)
			{
				cout << "\nError: Unable to open file stream with given file name, try again.\n";
			}
			cout <<  "\nEnter file: ";
			cin >> fileName;
			inFile.open(fileName);
			error = true;
		}
	
	getline(inFile, line);
	start = line.substr(0, line.find(" ")); //starting vertex
	end = line.substr(line.find(" ")+1, line.size()-1); //ending vertex
	getline(inFile, line); //skip empty line
	
	getline(inFile, line);
	while(!inFile.eof()) //parse and assign data from input file
		{
			from = line.substr(0, line.find(" "));
			to = line.substr(line.find(" ")+1, (line.find_last_of(" ")-line.find(" ")-1));
			num = line.substr(line.find_last_of(" ")+1, line.size()-1);
			pathWeight = stoi(num);

			predecessor[from] = predecessor[to] = "-1";
			adjList[from].push_back(node(10000, pathWeight, to)); //bi-directional
			adjList[to].push_back(node(10000, pathWeight, from)); //bi-directional
			weight[from] = node(10000,0,from);
			weight[to] = node(10000,0,to);
			
			getline(inFile, line);
			if(line.empty())
			{
				break;
			}
		}

	//finds the minimum weighted path from start vertex to end vertex
	dijkstra(start, adjList, predecessor, weight);

	//generates FILO stack of the path from start vertex to end vertex
	findPath(end, predecessor, path, weight);

	//output results
	if(weight[end].weight != 10000)
	{
		cout << "\nCost: " << weight[end].weight << endl;
		cout << endl << "Path:";
	}
		
	cout << endl << path.top();
		
	path.pop();
	while(!path.empty())
		{
			cout << " -> " << path.top();
			path.pop();
		}
	cout << endl;

	return 0;
}
