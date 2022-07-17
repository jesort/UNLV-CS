#ifndef HASH_MAP_H
#define HASH_MAP_H

/*
Assignment #8 - Stock Brokerage Account
*/

#include <iostream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

struct stockType
{
	string name;
	int timesPurchased;
	double dividend, price;

	stockType(); //default constructor, sets member variables to null
	stockType(string, double); //parameter constructor
	bool operator<(const stockType&) const; //overload the less-than operator (<)
	// bool operator!=(const stockType&) const; //overload the not-equivalent-to operator (!=)
	const stockType& operator=(const stockType&); //overload the assignment operator (=)
};

stockType::stockType()
{
	name =  "";
	timesPurchased = dividend = price = 0;
}

stockType::stockType(string n, double d)
{
	name = n;
	timesPurchased = 0;
	dividend = d;
	price = 0;
}

bool stockType::operator<(const stockType& rhs) const
{
	//priority: (price, <), (timesPurchased, >), (dividend, >), and (name, <)
	bool priority = false;
	int strLength = 0;

	//to prevent going out of bounds, determine which string's length is smaller and assign that value to strLength
	if(this->name.length() <= rhs.name.length()) 
	{
		strLength = this->name.length();
	}
	else
	{
		strLength = rhs.name.length();	
	}

	if(this->price < rhs.price) //if `this` is cheaper
	{
		priority = true;
	}
	else if(this->price == rhs.price) //if both objects share the same price
	{
		if(this->timesPurchased > rhs.timesPurchased) // if `this` has been purchased more times
		{
			priority = true;
		}
		else if(this->timesPurchased == rhs.timesPurchased) //if both objects share the same timesPurchased
		{
			if(this->dividend > rhs.dividend) //if `this`' dividend is greater
			{
				priority = true;
			}
			else if(this->dividend == rhs.dividend) //if both objects offer the same dividends
			{
				for(int i = 0; i < strLength; i++) //determine priority according to alphabetical order
					{
						if(int(tolower(this->name[i])) < int(tolower(rhs.name[i])))
						{
							priority = true;
							break;
						}
					}
			}
		}
	}
	return priority;
}

const stockType& stockType::operator=(const stockType& rhs)
{
	this->name = rhs.name;
	this->timesPurchased = rhs.timesPurchased;
	this->dividend = rhs.dividend;
	this->price = rhs.price;
	
	return *this;
}

template <class Type>
class priorityQ
{
	public:
		priorityQ(int = 10); //constructor that sets the capacity of the heap with cap, allocates the heapArray with this capacity and sets the size variable
		priorityQ(vector<Type>); //load the contents of the passed vector into heapArray
		priorityQ(const priorityQ<Type>&); //deep copy the contents of passed object into heapArray
		~priorityQ(); //deconstructor, deallocate and nullify heapArray
		const priorityQ<Type>& operator=(const priorityQ<Type>&);
		void insert(Type); //insert element into heapArray, increment size, and bubbleUp
		void deletePriority();  //overwrite the contents of heapArray[1] with heapArray[size], then decrement and bubbleDown
		Type getPriority() const; //returns object located in heapArray[1]
		bool isEmpty() const; //returns true if `size` is equal to zero
		void bubbleUp(int); //shifts objects higher in the priority queue
		void bubbleDown(int); //shifts objects lower in the priority queue
		int getSize() const; //returns private variable `size`

	private:
		int capacity; //denotes the max size of the heap structure
		int size; //denotes the amount of elements stored in the heap
		Type *heapArray; //a dynamic array of elements contained in the heap structure
};

template <class Type>
priorityQ<Type>::priorityQ(int cap)
{
	capacity = cap;
	size = 0;
	heapArray = new Type[capacity];
	// for(int i = 0; i < capacity; i++)
	// 	{
	// 		heapArray[i] = Type();
	// 	}
}

template <class Type>
priorityQ<Type>::priorityQ(vector<Type> v)
{
	// cout << "constructor\n";
	capacity = v.size() + 1;
	size = 0;
	heapArray = new Type[capacity];
	for(int i = 1; i < capacity; i++)
		{
			size++;
			heapArray[i] = v[i-1];
		}
	for(int i = size; i >= 1; i--)
		{
			// cout << "i: \n";
			bubbleDown(i);
		}
}

template <class Type>
priorityQ<Type>::priorityQ(const priorityQ<Type>& copy)
{
	heapArray = nullptr;
	*this = copy; //deep copy the contents of passed object in `this` object
}


template <class Type>
priorityQ<Type>::~priorityQ()
{
	delete [] heapArray; 
	heapArray = nullptr; //set to null
}

template <class Type>
const priorityQ<Type>& priorityQ<Type>::operator=(const priorityQ<Type>& rhs)
{
	if(heapArray != nullptr)
	{
		delete [] heapArray;
		heapArray = nullptr;
	}
	
	size = rhs.getSize();
	capacity = size + 1;
	heapArray = new Type[capacity];
	
	for(int i = 1; i < capacity; i++)
		{
			heapArray[i] = rhs.heapArray[i];
		}
	
	for(int i = size; i >= 1; i--)
		{
			bubbleDown(i);
		}
	
	return *this;
}

template <class Type>
void priorityQ<Type>::insert(Type item)
{
	Type *tempHeap;
	
	size++; //increment size
	
	if(size == capacity)
	{
		tempHeap = heapArray; //shallow copy
		heapArray = new Type[capacity*2]; //allocate new pointer array of appropriate capacity
		
		for(int i = 0; i < capacity; i++)
			{
				heapArray[i] = tempHeap[i]; //deep copy
			}
		
		delete [] tempHeap; //deallocate old pointer array
		tempHeap = nullptr;
		capacity *= 2;
	}

	heapArray[size] = item;
	bubbleUp(size);
}

template <class Type>
void priorityQ<Type>::deletePriority()
{
	
	heapArray[1] = heapArray[size]; //overwrite first element with the last element in heep
	size--; 
	if(size > 1)
	{
		bubbleDown(1); //bubbleDown starting from index 1
	}
	// bubbleDown(1); //bubbleDown starting from index 1
}

template <class Type>
Type priorityQ<Type>::getPriority() const
{
	Type returnObj;
	if(size >= 1)
	{
		returnObj = heapArray[1];
	}
	return returnObj; //return first node
}

template <class Type>
bool priorityQ<Type>::isEmpty() const
{
	return (size == 0);
}

template <class Type>
void priorityQ<Type>::bubbleUp(int index)
{
	Type swapVar; //temporary variable used in the process of swapping around values

	//calculates the parent of index
	int level = log2(index);
	int place = index - (pow(2, level)-1);
	int parentsPlace = (place-1)/2;
	int parent = pow(2, level-1) + parentsPlace;

	if(parent >= 1) //since heapArray[0] is treated like a root node, this prevents going out of bounds
	{
		if(heapArray[index] < heapArray[parent]) //if the child is less than the parent, swap positions
		{
			swapVar = heapArray[parent];
			heapArray[parent] = heapArray[index];
			heapArray[index] = swapVar;
			bubbleUp(parent); //trigger bubbleUp recursion
		}
	}
}

template <class Type>
void priorityQ<Type>::bubbleDown(int index)
{
	int chosenChild = 0;
	Type swapVar;
	bool left{false}, right{false};

	//calculate the children of the parent, `index`
	int level = log2(index);
	int place = index - (pow(2,level) - 1);
	int leftChild = pow(2,level+1) + 2*(place-1);

	if(leftChild <= size) //check if object is null
	{
		left = heapArray[leftChild] < heapArray[index]; //check if child has higher priority than parent
	}
	if(leftChild+1 <= size) //check if object is null
	{
		right = heapArray[leftChild+1] < heapArray[index]; //check if child has higher priority than parent
	}

	if(left && right) //if both children own higher priority than the parent
	{
		//true if left child has higher priority than right child
		left = heapArray[leftChild] < heapArray[leftChild+1]; 
		//true if right child has higher priority than left child
		right = heapArray[leftChild+1] < heapArray[leftChild]; 
	}

	if(left)
	{
		chosenChild = leftChild; //left child chosen for the swap
	}
	if(right)
	{
		chosenChild = leftChild+1; //right child chosen for the swap
	}

	if(chosenChild != 0) //if a child has been chosen to be swapped
	{
		swapVar = heapArray[index];
		heapArray[index] = heapArray[chosenChild];
		heapArray[chosenChild] = swapVar;
		bubbleDown(chosenChild); //trigger bubbleDown recursion 
	}
}

template <class Type>
int priorityQ<Type>::getSize() const
{
	return size;
}

#endif
