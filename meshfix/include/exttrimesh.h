/****************************************************************************
* JMeshExt                                                                  *
*                                                                           *
* Consiglio Nazionale delle Ricerche                                        *
* Istituto di Matematica Applicata e Tecnologie Informatiche                *
* Sezione di Genova                                                         *
* IMATI-GE / CNR                                                            *
*                                                                           *
* Authors: Marco Attene                                                     *
*                                                                           *
* Copyright(C) 2006: IMATI-GE / CNR                                         *
*                                                                           *
* All rights reserved.                                                      *
*                                                                           *
* This program is free software; you can redistribute it and/or modify      *
* it under the terms of the GNU General Public License as published by      *
* the Free Software Foundation; either version 2 of the License, or         *
* (at your option) any later version.                                       *
*                                                                           *
* This program is distributed in the hope that it will be useful,           *
* but WITHOUT ANY WARRANTY; without even the implied warranty of            *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
* GNU General Public License (http://www.gnu.org/licenses/gpl.txt)          *
* for more details.                                                         *
*                                                                           *
****************************************************************************/

#ifndef _EXTTRIMESH_H
#define _EXTTRIMESH_H

#include "jmesh.h"
#include <set>
#include <map>
using std::set;

class ExtTriMesh : public Triangulation
{
 public:
 double epsilon_angle;
 // Constructors
 ExtTriMesh() : Triangulation() { epsilon_angle = 0; }
 ExtTriMesh(const char *s) : Triangulation(s) { epsilon_angle = 0; }
 ExtTriMesh(const Triangulation *t) : Triangulation(t) { epsilon_angle = 0; }
 ExtTriMesh(const Triangle *t, const bool keep_ref =false) : Triangulation(t, keep_ref) { epsilon_angle = 0; }

 Edge	*joinBoundaryLoops(bool =0, bool =1, bool =1); // (in "ALGORITHMS/holeFilling.cpp")
 Edge	*joinBoundaryLoops(Vertex *, Vertex *, bool =0, bool =1, bool =1); // (in "ALGORITHMS/holeFilling.cpp")
 int     fillSmallBoundaries(int, bool =0, bool =0);   // (in "ALGORITHMS/holeFilling.cpp")
 int     TriangulateHole(Edge *);		       // (in "ALGORITHMS/holeFilling.cpp")
 void    FillHole(Edge *, bool =0);		       // (in "ALGORITHMS/holeFilling.cpp")
 int refineSelectedHolePatches(Triangle * =NULL);      // (in "ALGORITHMS/holeFilling.cpp")
 void fairSelection(Triangle * =NULL);		       // (in "ALGORITHMS/holeFilling.cpp")

 // Mirko's functions
 int  joinOverlappingComponentPair();
 int  joinOverlappingComponentPair2();
 // returns the number of joined boundaries
 int joinComponentsBiggestBoundaryPair(List *nl, List *ml, double maxDistanceToJoin);
 bool loopsHaveAllVerticesCloserThanDistance(List *loop, List *loop2, const double &distance);
 //! Determines the closest pair of vertices of the lists l1,l2. Good for boundary loops.
 double closestPair(List *l1, List *l2, Vertex **closest1, Vertex **closest2);
 //! Determines the closest partner of a vertex in a list of vertices
 double getClosestPartner(Vertex *v, List *l, Vertex **closestParnter);
 double mostDistantPartner(Vertex *v, List *l, Vertex **distantPartner);
 bool joinBoundaryPair(List *bl1, List *bl2);
 int moveVerticesInwards(Point &componentCenter, std::map<Vertex*,Point> &origin, double stepsize = 1.0, double distance = 1.0);
 //! Iteratively moves overlapping parts of the first component out or inwards (in terms of normal orientation), to resolve
 //! overlaps. There are 3 possibilities to resolve overlaps of 2 components (outer and inner):
 //! 1) Move the vertices of the outer component outwards, such that it the outer component contains the inner component.
 //! 2) Move the vertices of the outer component inwards, such that it doesn't overlap anymore.
 //! 3) Move the vertices of the inner component inwards, such that it the outer component contains the inner component.
 //! Mesh is cleaned in each iteration. At the end the second component is removed.
 bool decoupleFirstFromSecondComponent(double minAllowedDistance = 1.0, unsigned max_iterations = 10, bool treatFirstAsOuter = true, bool outwards = true);
 //! Removes all parts of the first component, that are outside/inside the second component and fills the holes again.
 //! Use decoupleFirstFromSecondComponent() afterwards, to remove overlaps produces by the hole filling.
 void cutFirstWithSecondComponent(double minAllowedDistance = 1.0, bool cutOuter = true);
 //! Marks triangles of component1 that are inside of component2. Components triangles must be marked accordingly.
 int markTrianglesInsideComponent(short targetMarkBit = 0, short componentMarkBit1 = 5, short componentMarkBit2 = 4, bool treatIntersectionsAsOutside = false);
 //! Moves vertices of component1 that are closer than d to any triangle of component2.
 int moveTooCloseVerticesOutwards(double minAllowedDistance = 1.0, short componentMarkBit1 = 5, short componentMarkBit2 = 4);
 //! Dilates the surface by d into the direction of the mean normal at each vertex
 void dilate(double d = 1.0);
 //! fine-tunes the triangle distances
 int fineTune(double dist = 0.2, int nsteps = 4, bool secondIn = false);

 // Cleaning functions (src/cleaning.cpp)
 void asciiAlign();
 int  swapAndCollapse();
 bool cleanDegenerateTriangles(int max_iters = 10, int num_to_keep = 1);
 bool removeSelfIntersections(int max_iters, int number_components_to_keep = 1);
 bool removeSelfIntersections2(int max_iterations, int number_components_to_keep = 1);
 bool isDegeneracyFree();
 void selectTrianglesInCubes();
 bool clean(int max_iters = 10, int inner_loops = 3, int number_components_to_keep = 1);
 //! Iteratively increases the radius of the handles to select, removes the selected triangles and fills the holes
 bool removeHandles();
 // Misc Algorithms (Implemented in "ALGORITHMS/*.C")

 void loopSubdivision(int);
 void modbutSubdivision();
 void sqrt3Subdivision();
 int laplacianSmooth(int =1, double =1.0);
 int uniformRemesh(int num_steps, int num_vertices = 0, int max_swaps = 10);
 int spherize(int);
 int featureRecover(double, double);
 int simplify(int, int =0, int =0, int =0);
 int multiplechoice_simplify(int, int =0, int =8, int =0);
 void mc_resample(int, int =0, int =0);
 int epsilonSample(double, int =0);

 //! Note: applies unmark bit 0,1,3!
 int  selectIntersectingTriangles(UINT16 tri_per_cell=100);

 void tagPlanarRegionsBoundaries(double max_distance);

 //! Normalize all the shells and distribute them on a virtual sphere. O(N).
 void placeShellsOnVirtualSphere();
 Edge *flatten(Edge * =NULL);

 bool plumberSelect(Vertex *start, double radius);
};

#endif // _EXTTRIMESH_H
