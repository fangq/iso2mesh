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

#include "exttrimesh.h"
#include <stdio.h>
#include <stdlib.h>

/*
Point laplacianDisplacement(Vertex *v)
{
 List *vv = v->VV();
 Vertex *w;
 Node *m;
 Point np;
 FOREACHVVVERTEX(vv, w, m) np = np+(*w);
 np = (np)/(vv->numels());
 delete(vv);
 return np;
}
*/

Point sharpLaplacianDisplacement(Vertex *v)
{
 List *ve = v->VE();
 Vertex *w;
 Node *m;
 Edge *e;
 Point np;
 int nse=0;

 FOREACHVEEDGE(ve, e, m)
  if (IS_SHARPEDGE(e) || e->isOnBoundary())
  {
   if (nse==0) np.setValue(e->oppositeVertex(v));
   else if (nse==1) np = np + (*(e->oppositeVertex(v)));
   else {delete(ve); return (*v);}
   nse++;
  }
  else if (!nse) {w = e->oppositeVertex(v); np = np+(*w);}

 if (!nse) np = (np)/(ve->numels());
 else if (nse == 1) np = (*v);
 else np = np/2;

 delete(ve);
 return np;
}

int ExtTriMesh::laplacianSmooth(int ns, double l)
{
 Triangle *t;
 Edge *e;
 Vertex *v;
 Node *n;
 int i = 0, is_selection = 0, ins = ns;
 double ln = 1.0-l;
 Point np;

 FOREACHTRIANGLE(t, n) if (IS_VISITED(t))
  {MARK_VISIT(t->e1); MARK_VISIT(t->e2); MARK_VISIT(t->e3);}
 FOREACHEDGE(e, n) if (IS_VISITED(e))
  {MARK_VISIT(e->v1); MARK_VISIT(e->v2); is_selection = 1;}

 List vts;
 FOREACHVERTEX(v, n) if (!is_selection || IS_VISITED(v)) vts.appendHead(v);

 coord *xyz = (coord *)malloc(sizeof(coord)*vts.numels()*3);
 if (xyz == NULL) {JMesh::warning("Not enough memory for vertex coordinates.\n"); return 0;}

 JMesh::begin_progress();
 for (; ns>0; ns--)
 {
  i=0;
  FOREACHVVVERTEX((&vts), v, n)
  {
   np = sharpLaplacianDisplacement(v);
   if (!(i%3000)) JMesh::report_progress("%d %% done - %d steps left",((i*33)/(vts.numels()) + (100*(ins-ns)))/ins, ns);
   xyz[i++] = np.x*l+v->x*ln; xyz[i++] = np.y*l+v->y*ln; xyz[i++] = np.z*l+v->z*ln; 
  }

  i=0;
  FOREACHVVVERTEX((&vts), v, n)
  {
   v->x = xyz[i++]; v->y = xyz[i++]; v->z = xyz[i++];
  }
 }
 JMesh::end_progress();
 free(xyz);

 FOREACHEDGE(e, n) UNMARK_VISIT(e);
 FOREACHVERTEX(v, n) UNMARK_VISIT(v);

 return 1;
}
