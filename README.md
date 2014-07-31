SKShapeNode Cuttable Category
=============================

## About

This project provides a method for splitting a SKShapeNode in half, an effect
found in many physics games. This implementation relies heavily on
[AGGeometryKit](https://github.com/hfossli/AGGeometryKit/).

A restrictions is there can be no
[mouths](https://en.wikipedia.org/wiki/Vertex_(geometry)#Mouths) in a polygon
that is being cut. This feature may be added in a later implementation.

![# Preview](/preview.png?raw=true "Preview")

## Getting Started

Open the file `CuttableCategory.xcworkspace` in XCode and run.

## How SKShapeNode+Cuttables works

The path from the SKShapeNode is extracted using CGPathApply and then each point
is translated and rotated using the position and zRotation members of
SKShapeNode.

The shape node's line segments are then each checked to see if they intersect
with the cutLine. If intersections occur, create two new shapes using the
normalized path calculated above and the intersection line.

Finally if the shape node had a physics body, apply a matching body to the new
shape nodes and set their velocity to be the same as their parent.

