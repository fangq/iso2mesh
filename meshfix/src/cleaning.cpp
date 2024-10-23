#include "exttrimesh.h"
#include "jrs_predicates.h"

// Simulates the ASCII rounding error
void ExtTriMesh::asciiAlign()
{
 char outname[2048];
 Vertex *v;
 Node *m;
 float a;
 FOREACHVERTEX(v, m)
 {
  sprintf(outname,"%f",v->x); sscanf(outname,"%f",&a); v->x = a;
  sprintf(outname,"%f",v->y); sscanf(outname,"%f",&a); v->y = a;
  sprintf(outname,"%f",v->z); sscanf(outname,"%f",&a); v->z = a;
 }
}


// Return TRUE if the triangle is exactly degenerate
inline bool isDegenerateEdge(Edge *e)
{
 return ((*(e->v1))==(*(e->v2)));
}

bool isDegenerateTriangle(Triangle *t)
{
 double xy1[2], xy2[2], xy3[2];
 xy1[0] = t->v1()->x; xy1[1] = t->v1()->y;
 xy2[0] = t->v2()->x; xy2[1] = t->v2()->y;
 xy3[0] = t->v3()->x; xy3[1] = t->v3()->y;
 if (orient2d(xy1, xy2, xy3)!=0.0) return false;
 xy1[0] = t->v1()->y; xy1[1] = t->v1()->z;
 xy2[0] = t->v2()->y; xy2[1] = t->v2()->z;
 xy3[0] = t->v3()->y; xy3[1] = t->v3()->z;
 if (orient2d(xy1, xy2, xy3)!=0.0) return false;
 xy1[0] = t->v1()->z; xy1[1] = t->v1()->x;
 xy2[0] = t->v2()->z; xy2[1] = t->v2()->x;
 xy3[0] = t->v3()->z; xy3[1] = t->v3()->x;
 if (orient2d(xy1, xy2, xy3)!=0.0) return false;
 return true;
}

Edge *getLongestEdge(Triangle *t)
{
 double l1 = t->e1->squaredLength();
 double l2 = t->e2->squaredLength();
 double l3 = t->e3->squaredLength();
 if (l1>=l2 && l1>=l3) return t->e1;
 if (l2>=l1 && l2>=l3) return t->e2;
 return t->e3;
}

// Iterate on all the selected triangles as long as possible.
// Keep the selection only on the degeneracies that could not be removed.
// Return the number of degeneracies that could not be removed
int ExtTriMesh::swapAndCollapse()
{
 Node *n;
 Triangle *t;
 bool quiet = JMesh::quiet;
 if (epsilon_angle != 0.0)
 {
  FOREACHTRIANGLE(t, n) UNMARK_VISIT(t);
  JMesh::quiet = true; removeDegenerateTriangles(); JMesh::quiet = quiet;
  int failed = 0;
  FOREACHTRIANGLE(t, n) if (IS_VISITED(t)) failed++;
  return failed;
 }

 List triangles;
 Edge *e;
 const int MAX_ATTEMPTS = 10;

 FOREACHTRIANGLE(t, n) t->info=0;

 // VISIT2 means that the triangle is in the list
 FOREACHTRIANGLE(t, n) if (IS_VISITED(t))
 {
  UNMARK_VISIT(t);
  if (isDegenerateTriangle(t)) {triangles.appendTail(t); MARK_VISIT2(t);}
 }

 while ((t=(Triangle *)triangles.popHead())!=NULL)
 {
  UNMARK_VISIT2(t);
  if (t->isLinked())
  {
   if (isDegenerateEdge(t->e1)) t->e1->collapse();
   else if (isDegenerateEdge(t->e2)) t->e2->collapse();
   else if (isDegenerateEdge(t->e3)) t->e3->collapse();
   else if ((e=getLongestEdge(t))!=NULL)
   {
    if (e->swap())
    {
     t=e->t1;
     if (isDegenerateTriangle(t) && !IS_VISITED2(t) && ((long int)t->info < MAX_ATTEMPTS))
     {triangles.appendTail(t); MARK_VISIT2(t); t->info = (void *)(((long int)t->info)+1);}
     t=e->t2;
     if (isDegenerateTriangle(t) && !IS_VISITED2(t) && ((long int)t->info < MAX_ATTEMPTS))
     {triangles.appendTail(t); MARK_VISIT2(t); t->info = (void *)(((long int)t->info)+1);}
    }
   }
  }
 }

 removeUnlinkedElements();

 int failed=0;
 // This should check only on actually processed triangles
 FOREACHTRIANGLE(t, n) if (isDegenerateTriangle(t)) {failed++; MARK_VISIT(t);}

 JMesh::info("%d degeneracies selected\n",failed);
 return failed;
}

// returns true on success

bool ExtTriMesh::cleanDegenerateTriangles(int max_iters, int num_to_keep)
{
 int n, iter_count = 0, iter_count2 = 0;
 bool quiet = JMesh::quiet;
 JMesh::info("Removing degeneracies...\n");
 while ((++iter_count) <= max_iters && swapAndCollapse())
 {
  for (n=1; n<iter_count; n++) growSelection();
  removeSelectedTriangles();
  removeSmallestComponents(num_to_keep);
  JMesh::quiet = true; fillSmallBoundaries(E.numels()); JMesh::quiet = quiet;
  if(removeOverlappingTriangles()) {
      JMesh::quiet = true; fillSmallBoundaries(E.numels()); JMesh::quiet = quiet;
      while((++iter_count2) <= max_iters && removeOverlappingTriangles()) {
          // remove and fill didn't help => region growing
          JMesh::quiet = true; fillSmallBoundaries(E.numels()); JMesh::quiet = quiet;
          for(n=1; n<iter_count2; n++) growSelection();
          this->removeSelectedTriangles();
          JMesh::quiet = true; fillSmallBoundaries(E.numels()); JMesh::quiet = quiet;
          this->deselectTriangles();
      }
  }
  asciiAlign();
 }
 if (iter_count > max_iters) return false;
 return true;
}

bool appendCubeToList(Triangle *t0, List& l)
{
 if (!IS_VISITED(t0) || IS_VISITED2(t0)) return false;

 Triangle *t, *s;
 Vertex *v;
 List triList(t0);
 MARK_VISIT2(t0);
 double minx=DBL_MAX, maxx=-DBL_MAX, miny=DBL_MAX, maxy=-DBL_MAX, minz=DBL_MAX, maxz=-DBL_MAX;

 while(triList.numels())
 {
  t = (Triangle *)triList.popHead();
  v = t->v1();
  minx=MIN(minx,v->x); miny=MIN(miny,v->y); minz=MIN(minz,v->z);
  maxx=MAX(maxx,v->x); maxy=MAX(maxy,v->y); maxz=MAX(maxz,v->z);
  v = t->v2();
  minx=MIN(minx,v->x); miny=MIN(miny,v->y); minz=MIN(minz,v->z);
  maxx=MAX(maxx,v->x); maxy=MAX(maxy,v->y); maxz=MAX(maxz,v->z);
  v = t->v3();
  minx=MIN(minx,v->x); miny=MIN(miny,v->y); minz=MIN(minz,v->z);
  maxx=MAX(maxx,v->x); maxy=MAX(maxy,v->y); maxz=MAX(maxz,v->z);
  if ((s = t->t1()) != NULL && !IS_VISITED2(s) && IS_VISITED(s)) {triList.appendHead(s); MARK_VISIT2(s);}
  if ((s = t->t2()) != NULL && !IS_VISITED2(s) && IS_VISITED(s)) {triList.appendHead(s); MARK_VISIT2(s);}
  if ((s = t->t3()) != NULL && !IS_VISITED2(s) && IS_VISITED(s)) {triList.appendHead(s); MARK_VISIT2(s);}
 }

 l.appendTail(new Point(minx, miny, minz));
 l.appendTail(new Point(maxx, maxy, maxz));
 return true;
}

bool isVertexInCube(Vertex *v, List& loc)
{
 Node *n;
 Point *p1, *p2;
 FOREACHNODE(loc, n)
 {
  p1 = (Point *)n->data; n=n->next(); p2 = (Point *)n->data;
  if (!(v->x < p1->x || v->y < p1->y || v->z < p1->z ||
      v->x > p2->x || v->y > p2->y || v->z > p2->z)) return true;
 }

 return false;
}

void ExtTriMesh::selectTrianglesInCubes()
{
 Triangle *t;
 Vertex *v;
 Node *n;
 List loc;
 FOREACHTRIANGLE(t, n) appendCubeToList(t, loc);
 FOREACHVERTEX(v, n) if (isVertexInCube(v, loc)) MARK_VISIT(v);
 FOREACHTRIANGLE(t, n)
 {
  UNMARK_VISIT2(t);
  if (IS_VISITED(t->v1()) || IS_VISITED(t->v2()) || IS_VISITED(t->v3())) MARK_VISIT(t);
 }
 FOREACHVERTEX(v, n) UNMARK_VISIT(v);
 loc.freeNodes();
}

// returns true on success

bool ExtTriMesh::removeSelfIntersections(int max_iters, int number_components_to_keep)
{
 int n, iter_count = 0;
 bool quiet = JMesh::quiet;
 printf("Removing self-intersections...\n");
 while ((++iter_count) <= max_iters && selectIntersectingTriangles())
 {
  for (n=1; n<iter_count; n++) growSelection();
  removeSelectedTriangles();
  removeSmallestComponents(number_components_to_keep);
  JMesh::quiet = true; fillSmallBoundaries(E.numels()); JMesh::quiet = quiet;
  asciiAlign();
  selectTrianglesInCubes();
 }

 if (iter_count > max_iters) return false;
 return true;
}

bool ExtTriMesh::removeSelfIntersections2(int max_iterations, int number_components_to_keep)
{
    bool quiet = JMesh::quiet;
    int iteration_counter = 0, remove_and_fill_counter = 0, smooth_counter = 0, grow_counter = 0;
    JMesh::info("Removing self-intersections (using advanced method)...\n");
    int nintersecting = 0, nintersecting_new = 0;
    deselectTriangles();
    invertSelection();
    JMesh::info("Stage: Remove and Fill (1)\n");
    while (true)
    {
        iteration_counter++;
        asciiAlign();
        if((nintersecting_new = selectIntersectingTriangles(10)) > 0) {
            remove_and_fill_counter++;
            // remove intersecting triangles
            removeSelectedTriangles();
            // remove smallest shells
            removeSmallestComponents(number_components_to_keep);
            // fill, refine, fair, keep new triangles selected
            JMesh::quiet = true; fillSmallBoundaries(E.numels(), true); JMesh::quiet = quiet;
            // grow selection, recheck selection for intersections
            growSelection();
            if (nintersecting != nintersecting_new && remove_and_fill_counter < max_iterations*2) {
                // the last iteration resulted in different holes as before
                nintersecting = nintersecting_new;
                continue;
            }
        } else {
            deselectTriangles();
            if(iteration_counter == 1 || !selectIntersectingTriangles())
                return true; // we have reached the end
            continue;
        }
        remove_and_fill_counter = 0;
        JMesh::info("Stage: Laplacian Smooth (%d)\n", smooth_counter+1);
        // next step is smoothing
        deselectTriangles();
        removeSmallestComponents(number_components_to_keep);
        if(!selectIntersectingTriangles()) continue;
        if(smooth_counter++ < max_iterations) {
            JMesh::info("Laplacian smoothing of selected triangles.\n");
            // increase region to smooth
            for( int i = 0; i < smooth_counter; i++) growSelection();
            // smooth with 1 step, keep selection
            JMesh::quiet = true; laplacianSmooth(); JMesh::quiet = quiet;
            growSelection();
            nintersecting = 0;
            JMesh::info("Stage: Remove and Fill (%d)\n", iteration_counter+1);
            continue;
        }
        smooth_counter = 0;
        JMesh::info("Stage: Grow selection, Remove and Fill (%d)\n", grow_counter+1);
        deselectTriangles();
        removeSmallestComponents(number_components_to_keep);
        if(selectIntersectingTriangles()) {
            for (int i=0; i < grow_counter+1; i++)
                growSelection();
            removeSelectedTriangles();
            removeSmallestComponents(number_components_to_keep);
            JMesh::quiet = true; fillSmallBoundaries(E.numels(), true); JMesh::quiet = quiet;
            if (++grow_counter >= max_iterations) break;
            JMesh::info("Stage: Remove and Fill (%d)\n", iteration_counter+1);
        }
    }
    return false;
}


bool ExtTriMesh::isDegeneracyFree()
{
 Node *n;
 Triangle *t;

 if (epsilon_angle != 0.0)
 {FOREACHTRIANGLE(t, n) if (t->isDegenerate()) return false;}
 else
 {FOREACHTRIANGLE(t, n) if (isDegenerateTriangle(t)) return false;}

 return true;
}


// returns true on success

bool ExtTriMesh::clean(int max_iters, int inner_loops, int number_components_to_keep)
{
 bool ni, nd;

 deselectTriangles();
 invertSelection();

 for (int n=0; n<max_iters; n++)
 {
  JMesh::info("*** Cleaning iteration %d ***\n",n);
  this->removeOverlappingTriangles();
  nd = cleanDegenerateTriangles(inner_loops, number_components_to_keep);
  ni = removeSelfIntersections2(inner_loops, number_components_to_keep);
  if(boundaries()) {
      this->selectBoundaryTriangles();
      this->removeSelectedTriangles();
      this->fillSmallBoundaries(E.numels(), true, false);
  }
  if (ni && nd && isDegeneracyFree() && !this->checkGeometry()) {
      this->checkAndRepair();
      return true;
  }
 }

 return false;
}

bool ExtTriMesh::removeHandles() {
    double radius = 1;
    unsigned max_radius = this->bboxLongestDiagonal();
    while(this->handles() && radius < max_radius) {
        if(this->shells() > 1) this->removeSmallestComponents(1);
        this->selectTinyHandles(radius++);
        this->removeSelectedTriangles();
        this->fillSmallBoundaries(this->E.numels(), true, false);
        this->d_handles = this->d_shells = 1;
    }
    return this->handles() == 0;
}
