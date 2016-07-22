# This is a helper script to generate some large trees for performance and scale testing

function New-Node
{
    param([ref]$tree, [string]$id, [string]$type, [string[]]$directs)
    Add-Member -InputObject $tree.value -type NoteProperty -Name $id -Value @{"id"=$id; "type"=$type; "directs"= $directs}
}

function Add-Direct
{
    param([ref]$tree, [string]$manager, [string[]]$directs)
    $tree.value.$manager.directs += $directs
}

function Build-Tree
{
    param([ref]$tree, [string]$id, [int]$depth, [int]$branchFactor)

    if($depth -ge 1){
        
        $directs = @()
        
        foreach($i in 1..$branchFactor){
            $directs += $([string]$id + "_" + [string]$i)
        }

        New-Node $tree $id "Manager" $directs
    
        foreach($direct in $directs){
            Build-Tree $tree $direct ($depth-1) $branchFactor
        }
    } elseif($depth -eq 0) {
        New-Node $tree $id "Developer"
    }

}

function New-Tree
{
    param([string]$root, [int]$depth, [int]$branchFactor)

    # Usage 
    # $bigtree = New-Tree -root "bigtree" -depth 2 -branchFactor 3

    $nodeCount = ([math]::pow($branchFactor,$depth+1)-1)/($depth-1) #goooo MATH!

    $confirm = Read-Host "This will create a tree $depth deep, with $branchFactor children on each node, for a total of $nodeCount nodes.`n`
        Are you sure you want to procede? (y/n)"

    if($confirm -ne "y") { 
        Write-Host "Goodbye" 
        return
    }

    $tree = New-Object PSObject
   
    Build-Tree ([ref]$tree) $root $depth $branchFactor
    
    return $tree
}

function Export-Tree
{
    param($path,$tree)

    # Usage
    # Export-Tree -Path <export path> -tree $(New-Tree -root "small" -depth 2 -branchFactor 3)
    # Export-Tree -Path <export path> -tree $tree

    Set-Content -Path $path -Value $(ConvertTo-Json $tree)
}