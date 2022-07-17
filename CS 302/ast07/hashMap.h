#ifndef HASH_MAP_H
#define HASH_MAP_H

/*
Assignment #7 - Vote Counter
*/

#include <iostream>
#include <string>

using namespace std;

template <typename t1, typename t2>
class hashMap
{
	public:
		struct hashPair //contains the (key, value) pair for each entry in the hash table
		{
			t1 key; //stores hash key
			t2 value; //stores hash value
			hashPair *link; //points to the next node in hash table's linked list. MAXIMUM OF 2 LINK LIST NODES PER INDEX IN HASH TABLE.
		};

		struct iteratorPair //linked list that stores a shallow copy of table's hashPair nodes - order done in chronological input order
		{
			t1 *key; //points to the "key" field of a hashPair node
			t2 *value; //points to the "value" field of a hashPair node
			iteratorPair *link; //points to next node in iteratorPair linked list
		};

		class iterator
		{
			public:
				friend class hashMap; //allows class "hashMap" to access private members of class "iterator"
				iterator(); //constructor generates object with element assigned to nullptr
				const iterator& operator++(int); //increments element to next node in iteratorPair linked list
				bool operator==(const iterator&) const; //returns true if element points to the same address the passed iterator's element points to
				bool operator!=(const iterator&) const; //returns false if element doesn't to the same address the passed iterator's element points to
				t1 first(); //returns the "key" data field of the node element points to
				t2 second(); //returns the "value" data field of the node element points to

			private:
				iterator(iteratorPair*); //constructor generates object with element assigned to passed pointer
				iteratorPair *element; //pointer iterator
		};

		hashMap(); //default constructor that initializes private member variables and allocates an array of linked list for table
		~hashMap(); //deconstructor deallocates table's linked-list/pointer-array and deallocates the linked list head points to
		t2& operator[](t1); //do a bunch of shit
		iterator begin() const; //return iterator(head)
		iterator end() const; //return null iterator

	private:
		void resize(); //resize the pointer array length
		int h(string) const; //calculate an in-bounds index using the string key 
		int items; //maintain count of the number of nodes within table
		int size; //denotes the size of the hash table
		hashPair **table; //is the hash table, it's an array of linked lists.
		iteratorPair *head; //is the head pointer of the linked list that maintains all the existing entries in the has table.
};

template <typename t1, typename t2>
hashMap<t1, t2>::hashMap()
{
	size = 5;
	items = 0;
	head = nullptr;
	table = new hashPair*[size];

	for(int i = 0; i < size; i++)
		{
			table[i] = nullptr;
		}
}


template <typename t1, typename t2>
hashMap<t1, t2>::~hashMap()
{
	//deallocate existing second nodes then first nodes in linked list, then set pointers to nullptr
	for(int i = 0; i < size; i++)
		{
			if(table[i] == nullptr)
			{
				continue;
			}
			if(table[i]->link != nullptr)
			{
				delete table[i]->link;
				table[i]->link = nullptr;
			}
			delete table[i];
			table[i] = nullptr;
		}
	//deallocate pointer array then set pointer to nullptr
	delete[] table;
	table = nullptr;

	iteratorPair *delIT = nullptr;

	//deallocate the linked list head points to and set pointers to nul
	while(head != nullptr)
	{
		head->key = nullptr;
		head->value = nullptr;
		delIT = head;
		head = head->link;
		delete delIT;
		delIT = nullptr;
	}
}

template <typename t1, typename t2>
t2& hashMap<t1,t2>::operator[] (t1 key)
{
	int x = 0; //table index
	bool collision = false; // expression that triggers cycle of do while loop
	bool duplication = false; //prevents duplicates being written to iterator linked list
	iterator it(head); //iterator for the linked list head points to
	
	
	if((double(items)/double(size)) >= .5) //checking load factor
	{
		cout << "key: " << key << endl;
		resize();
	}

	x = h(key);








	
	
	do
	{
		//if table[x] is a nullptr: increment items, allocate memory, initialize allocated node's members variables
		if(table[x] == nullptr)
		{
			table[x] = new hashPair;
			table[x]->key = key;
			table[x]->value = t2();
			table[x]->link = nullptr;

			//if the linked list head points to is empty, allocate memory and assign the newly allocated hairPair node's data field's addresses into the associated pointers in new node.
			if(head == nullptr)
			{
				head = new iteratorPair;
				head->key = &(table[x]->key);
				head->value = &(table[x]->value);
				head->link = nullptr;
			}
			else
			{
				//while loop to reach the end of the linked list, then allocate memory and assign the newly allocated hairPair node's data field's addresses into the associated pointers in new node.
				it = begin();
				while(it.element->link != nullptr)
					{
						if(*(it.element->key) == key)
						{
							duplication = true;
							break;
						}
						it++;
					}

					if(*(it.element->key) == key)
						{
							duplication = true;
						}

				//prevent duplications be written to linked list pointed to by head
				if(!duplication)
				{
					it.element->link = new iteratorPair;
					it++;
					it.element->link = nullptr;
				}
				it.element->key = &(table[x]->key);
				it.element->value = &(table[x]->value);
			}
			//set it's element pointer to nullptr
			it = end();
			
			return table[x]->value;
		}
		//if a node exists in the table at index x and the existing node's key matches the passed key, return the node's value
		else if(table[x]->key == key)
		{
			it = end();
			
			return table[x]->value;
		}
		//if the previously checked node at index x is alone, allocate memory and *copy paste*
		else if(table[x]->link == nullptr)
		{
			items++;
			table[x]->link = new hashPair;
			table[x]->link->key = key;
			table[x]->link->value = t2();
			table[x]->link->link = nullptr;

			//while loop to reach the end of the linked list, then allocate memory and assign the newly allocated hairPair node's data field's addresses into the associated pointers in new node.
			it = begin();
			while(it.element->link != nullptr)
				{
					if(*(it.element->key) == key)
					{
						duplication = true;
						break;
					}
					it++;
				}

			if(*(it.element->key) == key)
			{
				duplication = true;
			}

			//prevent duplications be written to linked list pointed to by head
			if(!duplication)
			{
				it.element->link = new iteratorPair;
				it++;
				it.element->link = nullptr;
			}
			it.element->key = &(table[x]->link->key);
			it.element->value = &(table[x]->link->value);

			//set it's element pointer to nullptr
			it = end();
			
			return table[x]->link->value;
		}
		//if a second node exists within index x's linked lists and the second node's key matches the passed key, return the second node's value.
		else if(table[x]->link->key == key)
		{
			it = end();
			
			return table[x]->link->value;
		}
		//if collision occurs, increment x, set collison boolean to true, and trigger loop
		else
		{
			x = (x+1) % size;
			collision = true;
		}
	}
	while(collision);
}

template <typename t1, typename t2>
typename hashMap<t1, t2>::iterator hashMap<t1,t2>::begin() const
{
	return iterator(head);
}

template <typename t1, typename t2>
typename hashMap<t1, t2>::iterator hashMap<t1, t2>::end() const
{
	return iterator();
}

template <typename t1, typename t2>
void hashMap<t1, t2>::resize()
{
	cout << "resize\n";
	hashPair **tempTable = table;
	int prevSize = size;
	size *= 2;
	items = 0; //necessary so that a premature resize isn't triggered
	table = nullptr;
	table = new hashPair*[size];

		iteratorPair *del = nullptr;

	while(head != nullptr)
	{
		head->key = nullptr;
		head->value = nullptr;
		del = head;
		head = head->link;
		delete del;
		del = nullptr;
	}
















	

	for(int i = 0; i < size; i++)
		{
			table[i] = nullptr; //initialize each index of the pointer array
		}

	//extract the data from tempTable and submit it to table
	for(int i = 0; i < prevSize; i++)
		{
			if(tempTable[i] != nullptr) //if there exists one node
			{
				(*this)[tempTable[i]->key] = tempTable[i]->value;
				if(tempTable[i]->link != nullptr) //if there exists two nodes
				{
					(*this)[tempTable[i]->link->key] = tempTable[i]->link->value;
				}
			}
		}


	//Deallocate tempTable and set it nullptr
	for(int i = 0; i < prevSize; i++)
		{
			if(tempTable[i] == nullptr)
			{
				continue;
			}
			if(tempTable[i]->link != nullptr)
			{
				delete tempTable[i]->link;
				tempTable[i]->link = nullptr;
			}
			delete tempTable[i];
			tempTable[i] = nullptr;
		}
	delete[] tempTable;
	tempTable = nullptr;
}

template <typename t1, typename t2>
int hashMap<t1, t2>::h(string key) const
{
	int count = 0;
	for(long unsigned int i = 0; i < key.length(); i++)
		{
			count += int(key[i]);
		}
	return (count%size);
}

template <typename t1, typename t2>
hashMap<t1, t2>::iterator::iterator()
{
	element = nullptr;
}

template <typename t1, typename t2>
hashMap<t1, t2>::iterator::iterator(iteratorPair *p)
{
	element = p;
}

template <typename t1, typename t2>
const typename hashMap<t1, t2>::iterator& hashMap<t1, t2>::iterator::operator++(int)
{
	if(element != nullptr)
	{
		element = element->link;
	}
	return *this;
}

template <typename t1, typename t2>
bool hashMap<t1, t2>::iterator::operator==(const hashMap<t1, t2>::iterator& rhs) const
{
	return (this->element == rhs.element);
}

template <typename t1, typename t2>
bool hashMap<t1, t2>::iterator::operator!=(const hashMap<t1, t2>::iterator& rhs) const
{
	return (this->element != rhs.element);
}

template <typename t1, typename t2>
t1 hashMap<t1, t2>::iterator::first()
{
	return *(element->key);
}

template <typename t1, typename t2>
t2 hashMap<t1, t2>::iterator::second()
{
	return *(element->value);
}

#endif
