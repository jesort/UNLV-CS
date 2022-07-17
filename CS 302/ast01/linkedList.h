#ifndef LINKED_LIST_H
#define LINKED_LIST_H

/*
Assignment #1 - Bubble Sort on a doubly linked list
*/

using namespace std;

template <typename type>
class linkedList
{
	struct node
	{
		type data;
		node* prev;
		node* next;
	};

	public:

		class iterator
		{
			public:
				friend class linkedList;
				iterator();
				iterator(node*);
				type operator*() const;
				const iterator& operator++(int);
				const iterator& operator--(int);
				bool operator==(const iterator&) const;
				bool operator!=(const iterator&) const;
			private:
				node* current;
		};

		linkedList();
		linkedList(const linkedList<type>&);
		const linkedList<type>& operator=(const linkedList<type>&);
		~linkedList();
		void tailInsert(const type&);
		iterator begin() const;
		iterator end() const;
		void swapNodes(iterator&, iterator&);
	private:
		node* head;
		node* tail;
};





//Iterator's default constructor, sets `current` to null.
template<typename type>
linkedList<type>::iterator::iterator()
{
	current = nullptr;
}

//Iterator's copy constructor, sets `current` to passed pointer.
template<typename type>
linkedList<type>::iterator::iterator(node* ptr)
{
	current = ptr;
}

//function returns data of the node the iterator's current points to.
template<typename type>
type linkedList<type>::iterator::operator*() const
{
		return current->data;
}

//Shifts the iterator one place to right in the linked list. Returns `this` object
template<typename type>
const typename linkedList<type>::iterator& linkedList<type>::iterator::operator++(int)
{
	current = current->next;	
	return *this;
}

//Shifts the iterator one place to left in the linked list. Returns `this` object
template<typename type>
const typename linkedList<type>::iterator& linkedList<type>::iterator::operator--(int)
{
	current = current->prev;
	return *this;
}

//Function will return true if `this` object's `current` points to the same address
//the passed object's `current` points to.
template<typename type>
bool linkedList<type>::iterator::operator==(const iterator& rhs) const
{
	return (current == rhs.current);
}

//Function will return false if `this` object's `current` points to the same address
//the passed object's `current` points to.
template<typename type>
bool linkedList<type>::iterator::operator!=(const iterator& rhs) const
{
	return (current != rhs.current);
}




//linkedList's default constructor, sets `head` and `tail` to null.
template <typename type>
linkedList<type>::linkedList()
{
	head = nullptr;
	tail = nullptr;
}

//linkedList's copy constructor, first sets `head` and `tail` to nullptr. Afterwards, it preforms a deepcopy of the obj passed;
template <typename type>
linkedList<type>::linkedList(const linkedList<type>& copy)
{
	head = nullptr;
	tail = nullptr; 
	if(copy.head != nullptr)
	{
		iterator copyIt(copy.head);
		iterator nil(nullptr);
		do
		{
			tailInsert(*copyIt);
			copyIt++;
		}
		while(copyIt != nil);
	}
}


template <typename type>
const linkedList<type>& linkedList<type>::operator=(const linkedList<type>& rhs)
{
	//if `this` already has a linked list, it must be deleted;
	if(head != nullptr)
	{
		iterator it(head);
		head = nullptr;
		do
		{
			it.current->prev = nullptr;
			if(it.current->next != nullptr)
			{
				it++;
				it.current->prev->next = nullptr;
				delete it.current->prev;
			}
			else
			{
				delete it.current;
				it.current = nullptr;
			}
		}
		while(it.current != nullptr);
		tail = nullptr;
	}


	//at this point, `head` and `tail` == nullptr
	//like the copy constructor, this function will now deepycopy the passed obj to `*this`
	if(rhs.head != nullptr)
	{
		iterator rhsIt(rhs.head);
		iterator nil(nullptr);
		do
		{
			tailInsert(*rhsIt);
			rhsIt++;
		}
		while(rhsIt != nil);
	}

	//Return *this to main
	return *this;
}

//linkedList deconstructor, deallocates memory and sets pointers to nullptr
template <typename type>
linkedList<type>::~linkedList()
{
	if(head != nullptr)
	{
		iterator it(head);
		head = nullptr;
		do
		{
			it.current->prev = nullptr;
			if(it.current->next != nullptr)
			{
				it++;
				it.current->prev->next = nullptr;
				delete it.current->prev;
			}
			else
			{
				delete it.current;
				it.current = nullptr;
			}
		}
		while(it.current != nullptr);
		tail = nullptr;
	}
}

//inserts passed value to the end of the list
template <typename type>
void linkedList<type>::tailInsert(const type& item)
{
	node *tempPtr = new node;
	tempPtr->data = item;
	tempPtr->next = nullptr;

	if(tail != nullptr)
	{
		tempPtr->prev = tail;
		tail->next = tempPtr;
		tail = tempPtr;
	}
	else
	{
		head = tempPtr;
		tail = tempPtr;
		tempPtr->prev = nullptr;
	}

	tempPtr = nullptr;
}

//returns an iterator obj with its current pointing to the head of the linked list
template <typename type>
typename linkedList<type>::iterator linkedList<type>::begin() const
{
	return iterator(head);
}

//returns an iterator obj with its current pointing to the tail of the linked list
template <typename type>
typename linkedList<type>::iterator linkedList<type>::end() const
{
	return iterator(tail);
}

template <typename type>
void linkedList<type>::swapNodes(iterator& it1, iterator& it2)
{
	iterator itFirst, itSecond;

	//check if either of the nodes point to a endpoint
	if(it1.current == head) {itFirst.current = it1.current;}
	if(it1.current == tail) {itSecond.current = it1.current;}
	if(it2.current == head) {itFirst.current = it2.current;}
	if(it2.current == tail) {itSecond.current = it2.current;}

	if(itFirst.current == itSecond.current) //if neither nodes are endpoint
	{
		if(it1.current->next == it2.current)
		{
			itFirst.current = it1.current;
			itSecond.current = it2.current;
		}
		else
		{
			itFirst.current = it2.current;
			itSecond.current = it1.current;
		}

		itSecond.current->prev = itFirst.current->prev;
		itFirst.current->prev->next = itSecond.current;

		itFirst.current->next = itSecond.current->next;
		itSecond.current->next->prev = itFirst.current;

		itFirst.current->prev = itSecond.current;
		itSecond.current-> next = itFirst.current;
	}
	else
	{
		bool first = (itFirst.current != nullptr); //true if itFirst points to head
		bool second = (itSecond.current != nullptr); //true if itSecond points to tail

		if(first && second) //if both nodes are endpoints
		{
			head = itSecond.current;
			tail = itFirst.current;

			itFirst.current->prev = itSecond.current;
			itSecond.current->next = itFirst.current;

			itFirst.current->next = nullptr;
			itSecond.current->prev = nullptr;
		}

		if(first && !second) // if one of the iterators points to the head of the linked list while the other iterator points to a node somewhere in between
		{
			if(itFirst.current == it1.current)
			{
				itSecond.current = it2.current;
			}
			else
			{
				itSecond.current = it1.current;
			}

			head = itSecond.current;
			itSecond.current->prev = nullptr;

			itFirst.current->next = itSecond.current->next;
			itFirst.current->prev = itSecond.current;

			itSecond.current->next->prev = itFirst.current;
			itSecond.current->next = itFirst.current;
		}

		if(!first && second) // if one of the iterators points to the tail of the linked list while the other iterator points to a node somewhere in between
		{
			if(itSecond.current == it1.current)
			{
				itFirst.current = it2.current;
			}
			else
			{
				itFirst.current = it1.current;
			}

			tail = itFirst.current;
			itFirst.current->next = nullptr;

			itSecond.current->prev = itFirst.current->prev;
			itSecond.current->next = itFirst.current;

			itFirst.current->prev->next = itSecond.current;
			itFirst.current->prev = itSecond.current;
		}
	}

	//set used pointers to null
	itFirst.current = nullptr;
	itSecond.current = nullptr;
}

#endif