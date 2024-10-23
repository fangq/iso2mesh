#ifndef COMPONENT_H
#define COMPONENT_H
#include "triangle.h"

//! ComponentStruct references triangles and vertices of a Triangulation
//! and provides serveral convenience functions.

class ComponentStruct {
public:
    List *triangles;
    List *vertices;
    List *boundaries;
    // component = triangles of list
    ComponentStruct() {
        triangles = vertices = boundaries = NULL;
    }
    void clear() {
        if(triangles) triangles->removeNodes();
        if(vertices) vertices->removeNodes();
        if(boundaries) while(List *l = (List*) boundaries->popHead()) delete(l);
    }
    ComponentStruct(List* l) {
        this->triangles = new List(l);
        vertices = boundaries = NULL;
    }
    // component = triangles connected to t
    ComponentStruct(Triangle *t, unsigned b = 2) {
        this->triangles = new List();
        Triangle *t1, *t2, *t3;
        MARK_BIT(t,b);
        List todo(t);
        while (todo.numels()) {
            t = (Triangle *)todo.popHead();
            this->triangles->appendHead(t);
            t1 = t->t1(); t2 = t->t2(); t3 = t->t3();
            if (t1 != NULL && !IS_BIT(t1,b)) {MARK_BIT(t1,b); todo.appendHead(t1);}
            if (t2 != NULL && !IS_BIT(t2,b)) {MARK_BIT(t2,b); todo.appendHead(t2);}
            if (t3 != NULL && !IS_BIT(t3,b)) {MARK_BIT(t3,b); todo.appendHead(t3);}
        }
        this->unmarkBit(b);
        vertices = boundaries = NULL;
    }
    void initializeBoundaries() {
        vertices = getVertices();
        boundaries = getBoundaryLoops();
    }
    void markBit(unsigned b) {
        Triangle *t; Node *n;
        FOREACHVTTRIANGLE(triangles, t, n) MARK_BIT(t,b);
    }
    void unmarkBit(unsigned b) {
        Triangle *t; Node *n;
        FOREACHVTTRIANGLE(triangles, t, n) UNMARK_BIT(t,b);
    }
    // get the vertices of the the component
    List* getVertices(unsigned b = 2) {
        Triangle *t = (Triangle*)this->triangles->head()->data;
        Vertex *v, *v1, *v2, *v3;
        Triangle *t1, *t2, *t3;
        Node *n;
        MARK_BIT(t,b);
        List todo(t), *vertexList = new List();
        while (todo.numels()) {
            t = (Triangle *)todo.popHead();
            t1 = t->t1(); t2 = t->t2(); t3 = t->t3();
            v1 = t->v1(); v2 = t->v2(); v3 = t->v3();
            if (!IS_BIT(v1,b)) {MARK_BIT(v1,b); vertexList->appendHead(v1);}
            if (!IS_BIT(v2,b)) {MARK_BIT(v2,b); vertexList->appendHead(v2);}
            if (!IS_BIT(v3,b)) {MARK_BIT(v3,b); vertexList->appendHead(v3);}
            if (t1 != NULL && !IS_BIT(t1,b)) {MARK_BIT(t1,b); todo.appendHead(t1);}
            if (t2 != NULL && !IS_BIT(t2,b)) {MARK_BIT(t2,b); todo.appendHead(t2);}
            if (t3 != NULL && !IS_BIT(t3,b)) {MARK_BIT(t3,b); todo.appendHead(t3);}
        }
        this->unmarkBit(b);
        FOREACHVVVERTEX(vertexList, v, n) {UNMARK_BIT(v,0); UNMARK_BIT(v,2);}
        return vertexList;
    }
    // get list of boundary loops of the component (= list of list of vertices)
    List* getBoundaryLoops(unsigned b = 2) {
        Vertex *v, *w;
        Node *n;
        List *loopList = new List(), *loop;
        this->vertices = this->getVertices();
        FOREACHVVVERTEX(this->vertices, v, n) {
            // find next vertex of an unmarked boundary
            if (!IS_BIT(v,b) && v->isOnBoundary()) {
                w = v;
                loop = new List();
                do { // mark all vertices at this boundary
                    loop->appendHead(w);
                    MARK_BIT(w,b);
                    w = w->nextOnBoundary();
                } while (w != v);
                loopList->appendHead(loop);
            }
        }
        FOREACHVVVERTEX(this->vertices, v, n) {UNMARK_BIT(v,2);}
        return loopList;
    }
};
#endif // COMPONENT_H
