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

#ifndef EPSILON_SAMPLING_H
#define EPSILON_SAMPLING_H

#include "exttrimesh.h"
#include "heap.h"

//////////////////////////////////////////////////////////////////////////
//                                                                      //
//    Priority queue for epsilon sampling                               //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

class edgeSQLheap : abstractHeap
{
 public:

 edgeSQLheap(int n) : abstractHeap(n) {};

 void push(Edge *);
 inline Edge *popHead() {return (Edge *)removeHead();}
 inline int isEmpty() {return (numels==0);}
 int compare(const void *, const void *);
 int getnum() const {return numels;}
};

#endif // EPSILON_SAMPLING_H
