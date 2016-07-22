# A simple tree traversal library to calculate branch weights (i.e. calculating pay allocation per manager in a department)

> Only tested with Powershell v4. Check your own `$PSVersionTable` if you are unsure.
> No other dependencies are needed

## Basic usage
```
Import-Module .\Calculate-Allocation.psm1 -Force

$d = New-Department -rates .\tests\default_rates.json -people .\tests\default_people.json

$d.CalculateDepartmentAllocation()

$d.CalculateManagerAllocation("ManagerA")
```

## Run tests

```
.\Calculate-Allocation-Test.ps1
```

## Have Fun: Generate your own trees

```
. .\Build-Tree.ps1

Export-Tree -path .\bigtree.json -tree $(New-Tree -root "bigtree" -depth 4 -branchFactor 4)
```

*`-root` The name of the root node (or Manager)

*`-depth` How tall the tree is (how many levels)

*`-branchFactor` How wide each branch is (how many direct reports each manager has)

#### Notes on Build-Tree.ps1
* Build-Tree only creates complete trees of equal weight.
* Leaf nodes are "Developer" and all other nodes are "Manager"
* Each node is named according to it's path

## How it works

* The `people` member is sort of a tree-ish dictionary, but not a dictionary tree. More like a hash tree but without the hash. Because of this, you can only do breadth-first search (because the links only go one way)
   * Each element of `people` has
      * `id` (which is identical to the key, but wouldn't need to be)
      * `type` (Manager|Developer|QA Tester)
      * `directs` (if of type `Manager`) which is an array of the elements which descend from there.
* The `rates` member is just a simple lookup to match `type` to `rate`.
* Because it is a dictionary, you can address a single element in O(1) and visit all its descendants in O(n). However, finding a child's parent would approach O(n), in the worst case. (`Build-Tree.ps1` gets around this by naming each node according to its own path (a la greatgrandparent_grandparent_parent_child) but this only works for statically generated trees of course and is just for convenience)
* Everything is exchanged as json. Either strings or files. This provides maximum flexibilty.
* However, we are using `System.Web.Script.Serialization.JavaScriptSerializer` instead of `ConvertFrom-Json` because

   1. `ConvertFrom-Json` returns a `PSCustomObject` wherein each element is also a `PSCustomObject`. This is not a "real" collection and is more difficult to enumerate reliably and comes at performance costs. Using the native assembly gives us a lower level ADT in the form of a dictionary object. This provides, not only better performance, but also simpler enumeration hooks.
   2. The default limit on string length when using `ConvertFrom-Json` is very low. We are able to change when we instantiate our own Serializer.

## How it does not work

* Not checking for name collisions or link collisions. Double counting is not prevented.
* Not checking for missing or duplicate rate types or names. These are ignored but not handled.
*Not checking circular links. It would be trivial to send this into an endless loop.
