// Assignment 5: Hungry for (Red) Apples

#ifndef CS302_BINTREE_H
#define CS302_BINTREE_H

#include <vector>
#include <cmath>
#include <iostream>

using namespace std;

class binTree
{
public:
    struct binTreeNode
    {
			bool apple;
			binTreeNode *left;
			binTreeNode *right;
    };

    binTree();
    binTree(vector<bool>);
    ~binTree();
    int minTime();

private:
    void destroyTree(binTreeNode*);
    double buildTree(binTreeNode *r, vector<bool>, long unsigned); //Jimi approved the alterations
    int minTime(binTreeNode *r, int);
		void inOrder(binTreeNode *r);
		void preOrder(binTreeNode *r);
		void postOrder(binTreeNode *r);
    binTreeNode *root;
};

binTree::binTree() //default constructor
{
    root = nullptr;
}

binTree::binTree(vector<bool> apples) //constructor with parameters
{
    if(!apples.empty()) //if vector isn't empty, allocate first leaf.
    {
			cout << "Input: ";
			for(unsigned long i = 0; i < apples.size(); i++)
				{
					cout << apples[i] << " ";
				}
			cout << endl << endl;
			root = new binTreeNode;
			root->apple = apples[0];
			root->left = root->right = nullptr;
			if(apples.size() > 1) //if vector size is greater than 1, initiate buildTree recursion.
			{
					buildTree(root,apples,0);
        }
    }
    else
    {
        root = nullptr; //if vector is empty, set root to null
    }
}

binTree::~binTree() //Deconstructor, wrapper function for destroyTree(binTreeNode *r)
{
		std::cout << "preOrder(): ";
		preOrder(root);
		std::cout << std::endl << std::endl;
	
		std::cout << "inOrder(): ";
		inOrder(root);
		std::cout << std::endl << std::endl;
		
		std::cout << "postOrder(): ";
		postOrder(root);
		std::cout << std::endl << std::endl;
    destroyTree(root);
}

int binTree::minTime() //wrapper function for minTime(binTreeNode *r, int time)
{
    return minTime(root, 0);
}

double binTree::buildTree(binTreeNode *r, vector<bool> apples, long unsigned i)
{
    double counter = 0;
    unsigned long vecSize = apples.size();
    if(r == root)
    {
        if(r->left == nullptr) //Allocate left branch if vecSize >= 2
        {
            i++;
            r->left = new binTreeNode;
            r->left->apple = apples[i];
            r->left->left = r->left->right = nullptr;
            if(i+1 < vecSize) //Allocate right branch if vecSize >= 3
            {
                i++;
                r->right = new binTreeNode;
                r->right->apple = apples[i];
                r->right->left = r->right->right = nullptr;
            }
            if(i+1 == vecSize) //If vecSize <= 3, return to escape recursion.
            {
                return 0;
            }
        }
        while(i < vecSize) //Pivot point of the tree, escapes once tree if full allocated.
        {
            counter = buildTree(root->left,apples,i);
            i += int(pow(double(2),counter)); 

            counter = buildTree(root->right,apples,i);
            i += int(pow(double(2),counter));
        }
        return 0;
    }
    else
    {
        if(r->left == nullptr && i+1 < vecSize) //Allocate new left leaf
        {
            i++;
            r->left = new binTreeNode;
            r->left->apple = apples[i];
            r->left->left = r->left->right = nullptr;
            if(i+1 < vecSize) //Allocate new right leaf
            {
                i++;
                r->right = new binTreeNode;
                r->right->apple = apples[i];
                r->right->left = r->right->right = nullptr;
            }
            return 1; //return 1 to indicate level
        }
        else if(i+1 < vecSize)
        {
            counter = buildTree(r->left,apples,i);
            i += int(pow(double(2),counter));
            buildTree(r->right,apples,i);
        }
    }
    return counter + 1; //return to indicate level
}

void binTree::destroyTree(binTreeNode *r) //deallocate tree using (post-order?/in-order?) recursion
{
    if(r == nullptr) //base case
    {
        return;
    }
    if(r->left != nullptr) //Deallocate left branch
    {
        destroyTree(r->left);
        delete r->left;
        r->left = nullptr;
    }
    if(r->right != nullptr) //Deallocate right branch
    {
        destroyTree(r->right);
        delete r->right;
        r->right = nullptr;
    }
		if(r == root) //Root leaf is last to deallocate
		{
			delete r;
			r = nullptr;
			root = nullptr;
		}
    return;
}

int binTree::minTime(binTreeNode *r, int time)
{
	int  startTime{time};
	bool leftEmpty{false}, rightEmpty{false};

	
	if(!(r == root && root == nullptr)) //if the the tree isn't empty
	{
		if(r == root) //like buildTree, utilizing a special case for leaf pointed to by root.
		{
			if(r->left != nullptr)
			{
				time = minTime(r->left, time+1);
			}
			if(r->right != nullptr)
			{
				time = minTime(r->right, time+1);
			}
			
		}
		else
		{
			if(r->left == r->right && r->apple) //if r points to a leaf node with a true bool
			{
				return time+1;
			}
			else if(r->left == r->right && !r->apple) //if r points to a lead node with a false bool
			{
				return time-1;
			}
	
			if(r->left != nullptr) 
			{
				time = minTime(r->left, time+1);
			}
			if(startTime == time)
			{
				leftEmpty = true; //if left daughter node is false
			}
			else
			{
				startTime = time; //update startTime if left daughter node is true
			}
		
			if(r->right != nullptr)
			{
				time = minTime(r->right, time+1);
			}
			if(startTime == time)
			{
				rightEmpty = true; //if right daughter node is false
			}
		
			if(leftEmpty && rightEmpty && !r->apple) //if root node, left daughter, and right daughter are all false
			{
				time--;
			}
			else
			{
				time++; //records back track if red apple is present in current path
			}
		}
	}
	else
	{
		time = 0; //if tree is empty, return 0.
	}

	return time;
}

	void binTree::inOrder(binTreeNode *r)
{
	if(r == nullptr)
	{
		return;
	}
	inOrder(r->left);
	cout << r->apple << " ";
	inOrder(r->right);
}

void binTree::preOrder(binTreeNode *r)
{
	if(r == nullptr)
	{
		return;
	}
	cout << r->apple << " ";
	preOrder(r->left);
	preOrder(r->right);
}

void binTree::postOrder(binTreeNode *r)
{
	if(r == nullptr)
	{
		return;
	}
	postOrder(r->left);
	postOrder(r->right);
	cout << r->apple << " "; 
}

#endif //CS302_BINTREE_H
