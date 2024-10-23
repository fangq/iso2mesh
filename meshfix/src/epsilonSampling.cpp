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

#include "epsilonSampling.h"

//////////////////////////////////////////////////////////////////////////
//                                                                      //
//    Epsilon Sampling                                                  //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

void edgeSQLheap::push(Edge *e)
{
 // If the heap size is exceeded, automatically double its size
 if (insert(e)==-1)
 {
  void **nheap = new void *[maxels*2+1];
  for (int i=0; i<=maxels; i++) nheap[i]=heap[i];
  delete(heap);
  heap = nheap;
  maxels*=2;
  insert(e);
 }
}

int edgeSQLheap::compare(const void *e1, const void *e2)
{
 double l1 = ((Edge *)e1)->squaredLength();
 double l2 = ((Edge *)e2)->squaredLength();
 if (l1 > l2) return -1;
 if (l2 > l1) return 1;

 return 0;
}

int ExtTriMesh::epsilonSample(double epsilon, int numvertices)
{
 Node *n;
 Edge *e, *f;
 Point p;
 int bdr, missv;
 double asl, msl=0.0;
 edgeSQLheap *eh;

 JMesh::begin_progress();

 bool selection=0;
 Triangle *t;
 FOREACHTRIANGLE(t, n) if (IS_VISITED(t)) {selection=1; break;}

 if (numvertices)
 {
  if (numvertices <= V.numels()) {JMesh::end_progress(); return 0;}

  eh = new edgeSQLheap(numvertices*4);
  FOREACHEDGE(e, n) 
   if (!selection || ((!e->t1 || IS_VISITED(e->t1)) || (!e->t2 || IS_VISITED(e->t2))))
    eh->push(e);

  missv = numvertices-V.numels();
  while (!eh->isEmpty() && V.numels() < numvertices)
  {
   JMesh::report_progress("%d %% done   ", 100 - (100*(numvertices-V.numels()))/missv);
   e=eh->popHead();
   bdr = e->isOnBoundary();
   p = e->getMidPoint();
   splitEdge(e, &p, (bool)selection);
   eh->push(e);
   f = ((Edge *)E.head()->data);
   if (!selection || ((!f->t1 || IS_VISITED(f->t1)) || (!f->t2 || IS_VISITED(f->t2))))
    eh->push(f);
   f = ((Edge *)E.head()->next()->data);
   if (!selection || ((!f->t1 || IS_VISITED(f->t1)) || (!f->t2 || IS_VISITED(f->t2))))
    eh->push(f);
   if (!bdr) {f = ((Edge *)E.head()->next()->next()->data); eh->push(f);}
   if (IS_SHARPEDGE(e))
   {
    e = (!bdr)?((Edge *)E.head()->next()->next()->data):((Edge *)E.head()->next()->data);
    TAG_SHARPEDGE(e);
   }
  }
 }
 else if (epsilon == 0.0)
 {
  FOREACHEDGE(e, n) epsilon += e->length();
  epsilon /= E.numels();
  epsilon *= 2;
  epsilon *= epsilon;

  eh = new edgeSQLheap(E.numels());
  FOREACHEDGE(e, n)
   if (e->squaredLength() > epsilon) eh->push(e);

  missv = eh->getnum();
  while (!eh->isEmpty())
  {
   JMesh::report_progress("%d %% done   ", 100 - (100*(eh->getnum()))/missv);
   e=eh->popHead();
   bdr = e->isOnBoundary();
   p = e->getMidPoint();
   splitEdge(e, &p);
   if (e->squaredLength() > epsilon) eh->push(e);
   e = ((Edge *)E.head()->data);
   if (e->squaredLength() > epsilon) eh->push(e);
   e = ((Edge *)E.head()->next()->data);
   if (e->squaredLength() > epsilon) eh->push(e);
   if (!bdr)
   {
    e = ((Edge *)E.head()->next()->next()->data);
    if (e->squaredLength() > epsilon) eh->push(e);
   }
  }
 }
 else
 {
  if (selection) JMesh::warning("epsilonSample: Selections not supported when 'epsilon' is active!\nResampling everything.\n");

  FOREACHEDGE(e, n)
   if ((asl=e->squaredLength()) > msl) msl=asl;
  epsilon = msl*epsilon;

  eh = new edgeSQLheap(E.numels());
  FOREACHEDGE(e, n)
   if (e->squaredLength() > epsilon) eh->push(e);

  missv = eh->getnum();
  while (!eh->isEmpty())
  {
   JMesh::report_progress("%d %% done   ", 100 - (100*(eh->getnum()))/missv);
   e=eh->popHead();
   bdr = e->isOnBoundary();
   p = e->getMidPoint();
   splitEdge(e, &p);
   if (e->squaredLength() > epsilon) eh->push(e);
   e = ((Edge *)E.head()->data);
   if (e->squaredLength() > epsilon) eh->push(e);
   e = ((Edge *)E.head()->next()->data);
   if (e->squaredLength() > epsilon) eh->push(e);
   if (!bdr)
   {
    e = ((Edge *)E.head()->next()->next()->data);
    if (e->squaredLength() > epsilon) eh->push(e);
   }
  }
 }
 delete(eh);
 JMesh::end_progress();

 return 1;
}
