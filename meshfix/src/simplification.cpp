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

#include "simplification.h"
#include <stdlib.h>

// Macro to extract and cast the QEM from a vertex
#define GET_VERTEX_QEM(v) ((*((Q_matrix *)(v)->info)))


////////////////////////////////////////////////////////////
//
// Implementation of the class Q_matrix
//
////////////////////////////////////////////////////////////

// Allocation of static class members
char Q_matrix::use_check_collapse;
char Q_matrix::fast_check_collapse;
char Q_matrix::compute_optimal_point;

char EC_Cost::which_cost_function;


// Constructor of the initial Quadric Error Matrix.
// Add a plane equation for each of the incident triangles.

Q_matrix::Q_matrix(Vertex *v)
{
 a2=ab=ac=ad=b2=bc=bd=c2=cd=d2=0;
 Triangle *t;
 Node *n;
 List *vt = v->VT();
 FOREACHVTTRIANGLE(vt, t, n) addPlane(t);
 delete(vt);
}


// Add a triangle plane equation to the matrix.

void Q_matrix::addPlane(Triangle *t)
{
 Point abc = t->getNormal();
 add(abc.x, abc.y, abc.z, -(abc*(*t->v1())));
}


// Returns the optimal position within a quadric

Point Q_matrix::getOptimalPoint(Edge *e)
{
 if (IS_VISITED(e->v1)) return (*(e->v1));	// Check for sharp vertices
 if (IS_VISITED(e->v2)) return (*(e->v2));
 Point n;

 if (getMinimizer(&(n.x), &(n.y), &(n.z))) return n;
 // If not invertible, choose the best among mid, v1 and v2
 return bestAmongMidAndEndpoints(e);
}


// Computes the errors at the edge midpoint and at the two end-points.
// The point associated to the minimum error is returned.

Point Q_matrix::bestAmongMidAndEndpoints(Edge *e)
{
 if (IS_VISITED(e->v1)) return (*(e->v1));	// Check for sharp vertices
 if (IS_VISITED(e->v2)) return (*(e->v2)); 

 Point mp = e->getMidPoint();			// Get Edge Midpoint
 double erm = getError(&mp, e);			// Error at midpoint
 double er1 = getError(e->v1, e);		// Error at v1
 double er2 = getError(e->v2, e);		// Error at v2

 if (erm <= er1 && erm <= er2) return mp;
 if (er1 <= erm && er1 <= er2) return (*(e->v1));

 return (*(e->v2));
}


// Checks wether the collapse inverts one or more face normals.
// If so, 0 is returned. Otherwise returns 1 and the collapse
// can take place safely.

int Q_matrix::checkCollapse(Edge *e, Point *p)
{
 List *vt;
 Node *n;
 Triangle *t;
 Vertex *v;
 Point nb, na, fb;
 Edge *f, *f2;
 double x,y,z;
 
 if (fast_check_collapse)
 {
  for (v=e->v1; ; v=e->v2) // For each of the end-points v1 and v2
  {
   vt=v->VT();			// Compute the incident triangles
   FOREACHVTTRIANGLE(vt, t, n)	// For each incident triangle
    if (t != e->t1 && t != e->t2)	// not incident to 'e'
    {
     f = t->oppositeEdge(v); fb = f->toVector();
     f2 = t->prevEdge(f);
     nb = fb&f2->toVector();	// compute a vector orth. to the triangle
     x=v->x; y=v->y; z=v->z;	// store the coordinates of the end-point
     v->setValue(p);		// Simulate collapse (move the end-point)
     na = fb&f2->toVector();	// compute an orth. vector again
     v->x=x; v->y=y; v->z=z;	// restore the original end-point coords
     if (nb*na <= 0) {delete(vt); return 0;}	// Check for inversion
    }
   delete(vt);
   if (v==e->v2) break;
  }
 }
 else	// Slow version. Checks wether the resulting triangles become degenerate
 {
  for (v=e->v1; ; v=e->v2)
  {
   vt=v->VT();
   x=v->x; y=v->y; z=v->z;
   v->setValue(p);
   FOREACHVTTRIANGLE(vt, t, n)
    if (t != e->t1 && t != e->t2)
    {
     if (t->isDegenerate() || t->overlaps()) {v->x=x; v->y=y; v->z=z; delete(vt); return 0;}
    }
   v->x=x; v->y=y; v->z=z;
   delete(vt);
   if (v==e->v2) break;
  }
 }
 
 return 1; // No inversions have been detected
}


// Computes the error of the quadric at a point 'v'.
// If the collapse would produce an inversion, the
// error is assigned an infinite value.

double Q_matrix::getError(Point *v, Edge *e)
{
 if (use_check_collapse && !checkCollapse(e, v)) return DBL_MAX;

 double a,b,c,d;
 a = v->x*a2 + v->y*ab + v->z*ac + ad;
 b = v->x*ab + v->y*b2 + v->z*bc + bd;
 c = v->x*ac + v->y*bc + v->z*c2 + cd;
 d = v->x*ad + v->y*bd + v->z*cd + d2;
 return (v->x*a + v->y*b + v->z*c + d);
}


////////////////////////////////////////////////////////////
//
// Functions that compute costs and point positions
//
////////////////////////////////////////////////////////////

////////////// According to the QEMs ///////////////////////

// Returns the cost of contracting the edge 'e'.

double quaderr_costFunction(Edge *e)
{
 Q_matrix qs = GET_VERTEX_QEM(e->v1)+GET_VERTEX_QEM(e->v2);

 Point vm = (qs.compute_optimal_point)?(qs.getOptimalPoint(e)):(qs.bestAmongMidAndEndpoints(e));
 return qs.getError(&vm,e);
}

// Returns the optimal point representing a contraction.
// Computes the actual 'optimum' only if the static member
// 'compute_optimal_point' is set within the current state.

Point quaderr_optimalPoint(Edge *e)
{
 Q_matrix qs = GET_VERTEX_QEM(e->v1)+GET_VERTEX_QEM(e->v2);

 return (qs.compute_optimal_point)?(qs.getOptimalPoint(e)):(qs.bestAmongMidAndEndpoints(e));
}


////////////// According to the edge lengths ////////////////

Point edgelen_optimalPoint(Edge *e)
{
 if (IS_VISITED(e->v1) && !IS_VISITED(e->v2)) return (*(e->v1));
 if (IS_VISITED(e->v2) && !IS_VISITED(e->v1)) return (*(e->v2));
 if (IS_VISITED2(e->v1) && !IS_VISITED2(e->v2)) return (*(e->v1));
 if (IS_VISITED2(e->v2) && !IS_VISITED2(e->v1)) return (*(e->v2));
 return e->getMidPoint();
}

double edgelen_costFunction(Edge *e)
{
 if (IS_VISITED(e->v1) && IS_VISITED(e->v2) && !IS_SHARPEDGE(e)) return DBL_MAX;
 if (IS_VISITED2(e->v1) && IS_VISITED2(e->v2)) return DBL_MAX;
 List *vv;
 Node *n;
 Vertex *v;
 double len=0.0;

 vv = e->v1->VV();
 FOREACHVVVERTEX(vv, v, n) len += (((*v)-(*(e->v1)))*((*v)-(*(e->v1))));
 delete(vv);
 vv = e->v2->VV();
 FOREACHVVVERTEX(vv, v, n) len += (((*v)-(*(e->v2)))*((*v)-(*(e->v2))));
 delete(vv);

 return len;
}


////////////////////////////////////////////////////////////
//
// Implementation of the class EC_Cost
//
////////////////////////////////////////////////////////////


EC_Cost::EC_Cost(Edge *e, int ind)     // Simple constructor
{
 index = ind;
 if (ind >= 0) updateCost(e);
}


// Updates the cost using the proper cost function

double EC_Cost::updateCost(Edge *e)
{
 // Currently only tow cost functions are supported.
 cost = (which_cost_function)?(edgelen_costFunction(e)):(quaderr_costFunction(e));
 return cost;
}


////////////////////////////////////////////////////////////
//
// Implementation of the class edgeHeap
//
////////////////////////////////////////////////////////////

edgeHeap::edgeHeap(int n, Edge **edg) : abstractHeap(n)
{
 positions = new int[n+1];
 edges = edg;
}

edgeHeap::~edgeHeap() {delete(positions);}

void edgeHeap::remove(Edge *e)
{
 EC_Cost *ecc = ((EC_Cost *)e->info);
 ecc->cost = -1;
 int i=positions[ecc->index];
 if (i) {upheap(i); removeHead();}
}

void edgeHeap::update(Edge *e)
{
 EC_Cost *ecc = ((EC_Cost *)e->info);
 ecc->updateCost(e);
 if (!positions[ecc->index]) push(e);
 else downheap(upheap(positions[ecc->index]));
}

int edgeHeap::compare(const void *e1, const void *e2)
{
 Edge *a = edges[(j_voidint)e1];
 Edge *b = edges[(j_voidint)e2];
 double l1 = ((EC_Cost *)a->info)->cost;
 double l2 = ((EC_Cost *)b->info)->cost;
 if (l1 < l2) return -1;
 if (l2 < l1) return 1;

 return 0;
}


// This functions analyses the neighborhood of a vertex. If there
// are one or more than two incident sharp edges, the vertex is
// marked as 'corner or deadend' and it will moved as less as
// possible during the simplification.

void mark_if_corner_or_deadend(Vertex *v)
{
 Edge *e;
 Node *n;
 List *ve = v->VE();
 int se=0;

 FOREACHVEEDGE(ve, e, n) if (IS_SHARPEDGE(e)) se++;
 delete(ve);

 if (se==1 || se > 2) MARK_VISIT2(v);
}


//////////////////////////////////////////////////////////////////////////////////////////
//
// Main method: SIMPLIFY
//
// Parameters:
// numver: indicates the number of vertices requested for the simplified mesh.
// optimal: if set, the method uses the QEM inverse to compute optimal points.
// edgelen: if set, the method sorts the edges based on their length instead of
//	    their cost computed through the QEMs.
// check:   if set, each collapse inverting triangles is assigned infinite cost
//          if set with a value >1, then a slower check is performed, but it
//	    guarantees that the resulting mesh has no degenerate faces
//
//////////////////////////////////////////////////////////////////////////////////////////

int ExtTriMesh::simplify(int numver, int optimal, int edgelen, int check)
{
 if (numver >= V.numels()) return 0;		// Check for bad input
 Q_matrix::use_check_collapse = check;		// Activate the check_collapse
 Q_matrix::fast_check_collapse = (check>1)?(0):(1); // Do it fast (don't check for new degeneracies)
 Q_matrix::compute_optimal_point = optimal;	// Activate the optimal point computation
 EC_Cost::which_cost_function = edgelen;	// Set the function for cost computation

 Node *n;
 Vertex *v, *ov;
 Edge *e, *e1, *e2, *e3, *e4;
 List *ve;
 Point np;
 int i, nsteps = V.numels()-numver;

 Edge **edges = new Edge *[E.numels()];	// Edge array for queue re-indexing
 edgeHeap eh(E.numels(), edges);		// Allocate the priority queue

 FOREACHVERTEX(v, n) v->info = new Q_matrix(v);	// Create a QEM for each vertex

 // Mark creases and boundaries for particular treatment
 FOREACHEDGE(e, n) if (e->isOnBoundary() || IS_SHARPEDGE(e)) {MARK_VISIT(e->v1); MARK_VISIT(e->v2);}
 FOREACHVERTEX(v, n) if (IS_VISITED(v)) mark_if_corner_or_deadend(v);

 // Associate costs to edges and fill the priority queue
 i=0; FOREACHEDGE(e, n) {edges[i] = e; e->info = new EC_Cost(e, i++); eh.push(e);}

 JMesh::begin_progress();

 while (!eh.isEmpty())	// Enter only if there are edges to be processed
 {
  e = eh.popHead();		// Pick the first one (which is the one with minimum cost)
  if (check>1 && ((EC_Cost *)e->info)->cost == DBL_MAX)
  {
   JMesh::warning("Can't simplify further due to precision requirements.\n");
   break;
  }

  v = e->v1; ov = e->v2;	// Store its end-point vertex pointers

  // Store the four edges bounding the quadrilateral defined by the two incident triangles
  e1 = (e->t1)?(e->t1->nextEdge(e)):(NULL); e4 = (e->t2)?(e->t2->prevEdge(e)):(NULL);
  e2 = (e->t1)?(e->t1->prevEdge(e)):(NULL); e3 = (e->t2)?(e->t2->nextEdge(e)):(NULL);

  if (!((e->t1 && e1->isOnBoundary() && e2->isOnBoundary()) || 
        (e->t2 && e3->isOnBoundary() && e4->isOnBoundary())))	// Prevent ear-cut
  {
   // Retrieve the proper representative point for the collapse
   np = (edgelen)?(edgelen_optimalPoint(e)):(quaderr_optimalPoint(e));
   // Try to collapse
   if (e->collapse(&np))		// If successful
   {
    if (IS_VISITED(ov)) MARK_VISIT(v);	// Transmit possible marks to the remaining vertex
    if (IS_VISITED2(ov)) MARK_VISIT2(v);

    // Remove deleted elements from the queue and transmit edge-marks
    if (e1) {eh.remove(e1); if (IS_SHARPEDGE(e1)) TAG_SHARPEDGE(e2);}
    if (e2 && !e2->isLinked()) eh.remove(e2);
    if (e3 && !e3->isLinked()) eh.remove(e3);
    if (e4) {eh.remove(e4); if (IS_SHARPEDGE(e4)) TAG_SHARPEDGE(e3);}
    GET_VERTEX_QEM(v) += GET_VERTEX_QEM(ov);	// Update the QEM associated to the remaining vertex
    ve = v->VE();				// Update the incident edges in the queue
    FOREACHVEEDGE(ve, e, n) eh.update(e);

    if (check>1)	// If we want to guarantee mesh quality
    {
     FOREACHVEEDGE(ve, e, n) MARK_BIT(e, 3);
     List *ve2;
     Node *m;
     FOREACHVEEDGE(ve, e, n)
     {
      ve2 = e->oppositeVertex(v)->VE();
      FOREACHVEEDGE(ve2, e1, m) if (!IS_BIT(e1, 3)) eh.update(e1);
      delete(ve2);
     }
     FOREACHVEEDGE(ve, e, n) UNMARK_BIT(e, 3);
    }

    delete(ve);
    JMesh::report_progress("%d%% Done ",(100*(V.numels()-numver-nsteps))/(V.numels()-numver));
    if (!--nsteps) break;
   }
  }
 }

 JMesh::end_progress();

 delete(edges);

 FOREACHVERTEX(v, n) {delete((Q_matrix *)v->info); v->info = NULL; UNMARK_VISIT(v); UNMARK_VISIT2(v);}
 FOREACHEDGE(e, n) {delete((EC_Cost *)e->info); e->info = NULL;}
 removeUnlinkedElements();

 return 1;
}


//////////////////////////////////////////////////////////////////////////////////////////
//
// Extension: MULTIPLE CHOICE APPROACH
//
// Parameters:
// numver: indicates the number of vertices requested for the simplified mesh.
// optimal: if set, the method uses the QEM inverse to compute optimal points.
// numchoices: this is the number of choices from which to choose for each pick
//	       (default = 8).
// check:   if set, each collapse inverting triangles is assigned infinite cost
//
//////////////////////////////////////////////////////////////////////////////////////////

int ExtTriMesh::multiplechoice_simplify(int numver, int optimal, int numchoices, int check)
{
 if (numver >= V.numels()) return 0;		// Check for bad input
 Q_matrix::use_check_collapse = check;		// Activate the check_collapse
 Q_matrix::fast_check_collapse = 1;		// Do it fast (don't check for new degeneracies)
 Q_matrix::compute_optimal_point = optimal;	// Activate the optimal point computation
 EC_Cost::which_cost_function = 0;		// Always use the QEMs

 Node *n,*m;
 Vertex *v, *ov;
 Edge *e, *e1, *e2, *e3, *e4;
 Point np;
 int i, nsteps = V.numels()-numver;
 double ac, mc;
 List *ve;

 FOREACHVERTEX(v, n) v->info = new Q_matrix(v);	// Set a QEM for each vertex

 // Mark creases and boundaries for particular treatment
 FOREACHEDGE(e, n) if (e->isOnBoundary() || IS_SHARPEDGE(e)) {MARK_VISIT(e->v1); MARK_VISIT(e->v2);}
 FOREACHVERTEX(v, n) if (IS_VISITED(v)) mark_if_corner_or_deadend(v);

 // Assign an initial fake cost to each edge.
 // We pass '-1' as index because we don't want to actually compute a cost
 FOREACHEDGE(e, n) {e->info = new EC_Cost(e, -1); MARK_VISIT(e);}

 JMesh::begin_progress();
 n=E.head();

 do
 {
  for (i=0, mc=DBL_MAX, e=NULL; i<numchoices && n!=NULL; i++)
  {
   e1 = (Edge *)n->data;
   if (!e1->isLinked())
   {
    delete((EC_Cost *)e1->info);
    if (n->next()) {n=n->next(); E.freeCell(n->prev());}
    else {n=E.head(); E.freeCell(E.tail());}
    i--;
   }
   else
   {
    n=n->next(); if (n==NULL) n=E.head();
    if (IS_VISITED(e1)) {((EC_Cost *)e1->info)->updateCost(e1); UNMARK_VISIT(e1);}
    if ((ac=((EC_Cost *)e1->info)->cost)<=mc) {e=e1; mc=ac;}
   }
  }

  v = e->v1; ov = e->v2;
  e1 = (e->t1)?(e->t1->nextEdge(e)):(NULL); e4 = (e->t2)?(e->t2->prevEdge(e)):(NULL);
  e2 = (e->t1)?(e->t1->prevEdge(e)):(NULL); e3 = (e->t2)?(e->t2->nextEdge(e)):(NULL);
  if (!((e->t1 && e1->isOnBoundary() && e2->isOnBoundary()) || 
        (e->t2 && e3->isOnBoundary() && e4->isOnBoundary())))	// Prevent ear-cut
  {
   np = quaderr_optimalPoint(e);
   if (e->collapse(&np))
   {
    if (IS_VISITED(ov)) MARK_VISIT(v);
    if (IS_VISITED2(ov)) MARK_VISIT2(v);
    if (e1 && IS_SHARPEDGE(e1)) TAG_SHARPEDGE(e2);
    if (e4 && IS_SHARPEDGE(e4)) TAG_SHARPEDGE(e3);
    GET_VERTEX_QEM(v) += GET_VERTEX_QEM(ov);
    ve = v->VE();
    FOREACHVEEDGE(ve, e, m) MARK_VISIT(e);
    delete(ve);
    JMesh::report_progress("%d%% done ",(100*(V.numels()-numver-nsteps))/(V.numels()-numver));
    nsteps--;
   }
  }
 } while (nsteps);

 JMesh::end_progress();

 FOREACHVERTEX(v, n) {delete((Q_matrix *)v->info); v->info = NULL; UNMARK_VISIT(v); UNMARK_VISIT2(v);}
 FOREACHEDGE(e, n) {delete((EC_Cost *)e->info); e->info = NULL; UNMARK_VISIT(e);}
 removeUnlinkedElements();

 return 1;
}

