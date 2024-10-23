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
#include <stdlib.h>


Point unrm_tangentRepel(Vertex *v, double len)
{
 Node *m;
 Point nor = v->getNormal(), sp1, sp2;
 Edge *e, *se1=NULL, *se2=NULL;
 if (nor.isNull()) return (*v);
 nor.normalize(); 
 double l, l1, l2;
 int nse=0;

 Vertex *w;
 Point tp, np;
 List *ve = v->VE();
 FOREACHVEEDGE(ve, e, m)
 {
  w = e->oppositeVertex(v);
  np = ((*v)-(*w));
  l = np.length();
  if(l != 0.0) np.normalize();
  l = len-l;
  np = np*l;
  if (IS_SHARPEDGE(e) || e->isOnBoundary()) {nse++; se2=se1; se1=e; if (nse>2) break;}
  np.project(&nor);
  tp = tp+np;
 }

 if (!nse) tp = (*v)+(tp/ve->numels());
 else if (nse==2)
 {
  sp1 = *(se1->oppositeVertex(v)); l1 = se1->length();
  sp2 = *(se2->oppositeVertex(v)); l2 = se2->length();
  tp = (*v)+((sp1-sp2)*((l1-l2)/(2*(l1+l2))));
 }
 else tp = *v;

 delete(ve);

 return tp;
}

int ExtTriMesh::uniformRemesh(int ns, int numver, int max_swaps)
{
 Node *n;
 Vertex *v;
 Edge *e;
 Point np;
 int i, swaps, totits, ins = ns;
 double l, avelen, varian;

 deselectTriangles();

 if (numver)
 {
  JMesh::info("Reaching the number of vertices ...\n");
  if (numver > V.numels()) epsilonSample(0, numver);
  else if (numver < V.numels()) simplify(numver, 0, 1, 0);
 }

 double *elens = (double *)malloc(sizeof(double)*E.numels());
 coord *xyz = (coord *)malloc(sizeof(coord)*V.numels()*3);

 JMesh::info("Relaxation in progress ...\n");
 JMesh::begin_progress();
 for (; ns > 0; ns--)
 {
  i=0; avelen=0.0; FOREACHEDGE(e, n) avelen += (elens[i++]=e->length()); avelen /= E.numels();
  i=0; varian=0.0; FOREACHEDGE(e, n) {varian += (avelen-elens[i])*(avelen-elens[i]); i++;} varian /= E.numels();

  i=0; FOREACHVERTEX(v, n)
   {np = unrm_tangentRepel(v, avelen); xyz[i++]=np.x; xyz[i++]=np.y; xyz[i++]=np.z;}
  i=0; FOREACHVERTEX(v, n) {v->x=xyz[i++]; v->y=xyz[i++]; v->z=xyz[i++];}

  swaps=totits=1;
  while (swaps && totits++ < max_swaps)
  {
   swaps = 0; FOREACHEDGE(e, n) if (!IS_SHARPEDGE(e))
   {
    l = e->length();
    if (e->swap())
     {if (e->length() >= l*0.999999) e->swap(1); else swaps++;}
   }
  }
  if (totits >= max_swaps) JMesh::warning("Can't optimize!\n");
  JMesh::report_progress("%d %% done   ",((ins-ns)*100)/ins);
 }
 JMesh::end_progress();
 free(xyz);
 free(elens);

 return 1;
}
