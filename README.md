TreesAndClustering
==================

Core Data test, binary trees, linear data clustering thing

It's a test for binary trees operations and data clustering by means of selforganizing maps.

NB. This project has no particular application or physical/statistical sence 

##Statup

**DTAppDelegate** starts with creating point cloud forming some kind of a blurred spiral. Points have random coordinates but they tend to be in this spiral.

![Spiral Image](https://lh4.googleusercontent.com/-0NtCwexgeug/UtKlFmIW3zI/AAAAAAAACSk/jhGD725n-i8/w568-h496-no/spiral.png)

Each point is represented by **NodeX** CoreData entity for it's x-coordinate and **NodeY** for it's y.
All graphs are managed objects of core data.


##Part I: Binary Trees
###Forming Trees

All randomly generated **NodeX**s are put into **GraphX** entity forming a binary tree for it's x coordinates. See the pseudo pic below explaining it for example of x sequence 4, 7, 2, 8, 0, 3:

```
     4       4      4          4          4
4 =>  \  => / \ => / \    =>  / \   =>   / \
       7   2   7  2   7      2   7      2   7
                       \    /     \    / \   \
                        8  0       8  0   3   8

```
Same thing for **NodeY**s.

###Balancing Trees
####Main Idea
Trees filled with random valus are by default not fully balanced. This means that some branches might be much longer than others. The less random values provides more disbalance.
So I added (just for fun) an operation into the root view controller **DTViewController** for balancing **GraphX** and **GraphY** in parallel.
Also I added two views to roughly show trees structure.
Since CoreData is not thread safe there are two ways to make CoreData calculation in parallel.

1. Create separate contexts for each thread
2. Trigger calculations from different concurring threads but perform them in main one particular thread only

I've chosen second option for this project.
####Median Balancing Method
Personally I love median filters for their simplisity and results so I implemented this method here.
Let me show it with pseudographics once again

```
Let's assume we
have the following tree
 0
  \      
   2     
  / \    
 1   3 - 8   
        / \
       4   9
```
All it's nodes could be sorted out like this *0123489*

Now we have to find central node and put it as a root

```
                 3     
      |         / \   
   0123489 => 012 489 
      ^               
    median            
 (central element)    
```
Now we perform same operation with the rest of nodes:

```
  012   489
   ^     ^
```
And we've got a perfectly balanced tree now

```
       3
      / \   
     1   8
    /|   |\
   0 2   4 9
```

It's the most symmetric tree possible ever!

Now it's time to proceed to part two

##Part II: Clustering
###Idea
Statistical data sometimes needs clustering. In most cases clustering is multidimensional. In this project I made linear clustering algorithm.

It's physical sence in this particular case is to transform point cloud into one-dimension space -- map them onto a single line. After doing this, we could findout approximate coordinate of each node on a spiral and answer the question like 'what are the really closest points around our target?'.

Points may be close to each other but they could belong to different sleeves of a spiral in our particular case. Clustering could provide approximate one coordinate measurements for nodes.

In real world we could, for an instance, cluster multidimensional data onto a surface with similiar approach.

###Self Organizing Clusters
In this project I used simplified linear clusters (**DTCluster** class) which tend to cover random parts of a point cloud forming a big curvy line.
Clustering could be started in **DTClusteringViewController** by pressing button with an obvious caption 'Do clustering'.
![Clustering](https://lh4.googleusercontent.com/-rUcwNBikpFs/UtKlFlziqEI/AAAAAAAACSo/0-5_bzlw4j0/w568-h496-no/clustering.png)

**DTClusteringViewController** creates a list of **DTCluster** entities and starts clustering operation same as in root **DTViewController**. While this operation is in progress, **DTGraphRepresentationView** represents covering of the point cloud by growing and conflicting clusters. Also it draws approximate resulting cluster.
This process is infinite, since there is no rule to findout really optimal cloud coverage.

##Notes
App is not reusable. Once the process started user can't go back. There is no stop/restart buttons yet. I could make them though.

Data model @ 12.1.2014 looks like this
![DataModel](https://lh5.googleusercontent.com/-52E0O-GJtgw/UtKqdIkBkvI/AAAAAAAACU4/n217HHwB4G8/w640-h448-no/Datamodel.png)

