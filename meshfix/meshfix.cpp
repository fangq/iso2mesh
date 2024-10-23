#include "exttrimesh.h"
#include <string.h>
#include <stdlib.h>

const char *input_filename;

double closestPair(List *bl1, List *bl2, Vertex **closest_on_bl1, Vertex **closest_on_bl2)
{
 Node *n, *m;
 Vertex *v,*w;
 double adist, mindist = DBL_MAX;

 FOREACHVVVERTEX(bl1, v, n)
  FOREACHVVVERTEX(bl2, w, m)
   if ((adist = w->squaredDistance(v))<mindist)
   {
    mindist=adist;
    *closest_on_bl1 = v;
    *closest_on_bl2 = w;
   }

 return mindist;
}

/**
 * Joins the closest components, that have boundaries (holes).
 */
bool joinClosestComponents(ExtTriMesh *tin, bool justconnect = false, bool refine = true, bool fair = true) {
    Vertex *v,*w, *gv, *gw;
    Triangle *t, *s;
    Node *n;
    List triList, boundary_loops, *one_loop;
    List **bloops_array;
    int i, j, numloops;

    i=0;
    // delete info of all triangles
    FOREACHVTTRIANGLE((&(tin->T)), t, n) t->info = NULL;
    // initialize info of all triangles with their component number starting by 1.
    FOREACHVTTRIANGLE((&(tin->T)), t, n) {
        if (t->info == NULL) {
            i++;
            triList.appendHead(t);
            t->info = (void *)i;
            while(triList.numels()) {
                t = (Triangle *)triList.popHead();
                if ((s = t->t1()) != NULL && s->info == NULL) {triList.appendHead(s); s->info = (void *)i;}
                if ((s = t->t2()) != NULL && s->info == NULL) {triList.appendHead(s); s->info = (void *)i;}
                if ((s = t->t3()) != NULL && s->info == NULL) {triList.appendHead(s); s->info = (void *)i;}
            }
        }
    }
    // if less then 2 components
    if (i<2) {
        // unset info again
        FOREACHVTTRIANGLE((&(tin->T)), t, n) t->info = NULL;
        JMesh::info("Mesh is a single component. Nothing done.");
        return false;
    }
    // copy triangle component number to the vertices
    FOREACHVTTRIANGLE((&(tin->T)), t, n) {
        t->v1()->info = t->v2()->info = t->v3()->info = t->info;
    }
    // create list boundary loop lists (= lists of connected vertices on a boundary)
    FOREACHVVVERTEX((&(tin->V)), v, n) {
        // find next vertex of an unmarked boundary
        if (!IS_VISITED2(v) && v->isOnBoundary()) {
            w = v;
            one_loop = new List;
            // mark all vertices at this boundary
            do {
                one_loop->appendHead(w);
                MARK_VISIT2(w);
                w = w->nextOnBoundary();
            } while (w != v);
            boundary_loops.appendHead(one_loop);
        }
    }
    FOREACHVVVERTEX((&(tin->V)), v, n) UNMARK_VISIT2(v);

    bloops_array = (List **)boundary_loops.toArray();
    numloops = boundary_loops.numels();

    int numtris = tin->T.numels();
    double adist, mindist=DBL_MAX;

    gv=NULL;
    for (i=0; i<numloops; i++) {
        for (j=0; j<numloops; j++) {
            // if i,j are indices of vertices of different boundary loops, search for the closes pair of vertices and update mindist
            if (((Vertex *)bloops_array[i]->head()->data)->info != ((Vertex *)bloops_array[j]->head()->data)->info) {
                adist = closestPair(bloops_array[i], bloops_array[j], &v, &w);
                if (adist<mindist) {mindist=adist; gv=v; gw=w;}
            }
        }
    }
    if (gv!=NULL) tin->joinBoundaryLoops(gv, gw, justconnect, refine, fair);

    FOREACHVTTRIANGLE((&(tin->T)), t, n) t->info = NULL;
    FOREACHVVVERTEX((&(tin->V)), v, n) v->info = NULL;

    free(bloops_array);
    while ((one_loop=(List *)boundary_loops.popHead())!=NULL) delete one_loop;

    return (gv!=NULL);
}

//#define DISCLAIMER

void usage()
{
 printf("%s v%s - by %s.\n================================================================================\n", JMesh::app_name, JMesh::app_version, JMesh::app_authors);
 printf("USAGE: meshfix <file1> [<file2>] [OPTIONS]\n");
 printf("  Processes file1 and saves the result to <file1>_fixed.off.\n");
 printf("  An optionally passed file2 is merged with the first one.\n");
 printf("OPTIONS:\n");
 printf(" -a <epsilon_angle>  Allowed range: 0 < epsilon_angle < 2, default: 0 (degrees).\n");
 printf(" -j                  Join 2 biggest components if they overlap, remove the rest.\n");
 printf(" -jc                 Join the closest pair of components.\n");
 printf(" -h, --help          Print this help and exit.\n");
 printf(" --shells <n>        Only the n biggest shells are kept.\n");
 printf(" -o <output>         Set the output filename (without extension).\n");
 printf(" -q                  Quiet mode, don't write much to stdout.\n");
 printf(" --remove-handles    Remove all handles of the mesh.\n");
 printf(" -u <steps>          Uniform remeshing of the whole mesh, steps > 0\n");
 printf("   --vertices <n>    Constrain number of vertices to n (only with -u)\n");
 printf(" --no-clean          Don't clean.\n");
 printf(" --smooth <n>        Apply n laplacian smoothing steps.\n");
 printf(" -s, --stl           Result is saved in STL     format instead of OFF.\n");
 printf(" -w, --wrl           Result is saved in VRML1.0 format instead of OFF.\n");
 printf(" --fsmesh            Result is saved in FreeSurfer format instead of OFF.\n");
 printf(" --xshift <d>        Shift x-coordinates of vertices by d when saving output.\n");
 printf("                     Only works with --fsmesh; used to deal with small FreeSurfer glitch\n");
 printf(" --msh               Result is saved in gmsh format for debugging (including vertex and triangle masks)\n");
 printf(" == Cutting, decoupling, dilation ==\n");
 printf(" --cut-outer <d>     Remove triangles of 1st that are outside of the 2nd shell.\n");
 printf(" --cut-inner <d>     Remove triangles of 1st that are inside  of the 2nd shell.\n");
 printf("                     Dilate 2nd by d; Fill holes and keep only 1st afterwards.\n");
 printf(" --decouple-inin <d> Treat 1st file as inner, 2nd file as outer component.\n");
 printf("                     Resolve overlaps by moving inners triangles inwards.\n");
 printf(" --decouple-outin <d> Treat 1st file as outer, 2nd file as inner component.\n");
 printf("                     Resolve overlaps by moving outers triangles inwards.\n");
 printf(" --decouple-outout <d> Treat 1st file as outer, 2nd file as inner component.\n");
 printf("                     Resolve overlaps by moving outers triangles outwards.\n");
 printf("                     Constrain the min distance between the components > d.\n");
 printf(" --fineTuneIn <d> <n> Used to fine-tune the minimal distance between surfaces \n");
 printf("                     A minimal distance d is ensured, and reached in n substeps \n");
 printf("                     When using the surfaces for subsequent volume meshing by gmsh\n");
 printf("                     this step prevent too flat tetrahedra\n");
 printf(" --fineTuneOut <d> <n> Similar to --fineTuneIn, but ensures minimal distance in the other direction\n");
 printf(" --dilate <d>        Dilate the surface by d. d < 0 means shrinking.\n");
 printf(" --intersect         If the mesh contains intersections, return value = 1.\n");
 printf(" --intersect -o fname.msh  If the mesh contains intersections, return value = 1.\n");
 printf("                     In addtion, save mesh with highlighted intersections in Gmsh format\n");
 printf("Accepted input formats are OFF, PLY and STL.\nOther formats are supported only partially.\n");
 printf("See http://jmeshlib.sourceforge.net for details on supported formats.\n");
 printf("\nIf MeshFix is used for research purposes, please cite the following paper:\n");
 printf("M. Attene - A lightweight approach to repairing digitized polygon meshes.\nThe Visual Computer, 2010. (c) Springer.\n");
 exit(0);
}

char *createFilename(const char *iname, const char *subext, const char *newextension, bool stripExt)
{
 static char tname[2048];
 char *oname = (char *)malloc(strlen(iname)+strlen(subext)+strlen(newextension)+1);
 strcpy(tname, iname);
 if(!stripExt)
 {
  int tl = strlen(tname), nl = strlen(newextension);
  stripExt = true;
  for (int n=0; n < nl; n++) stripExt &= tname[tl-nl+n] == newextension[n]; // strip if identical extension found
 }
 if(stripExt) for (int n=strlen(tname)-1; n>0; n--) if (tname[n]=='.') {tname[n] = '\0'; break;}
 sprintf(oname,"%s%s%s",tname,subext,newextension);
 return oname;
}

int main(int argc, char *argv[])
{
 JMesh::init();
 JMesh::app_name = "MeshFix";
 JMesh::app_version = "1.2-alpha";
 JMesh::app_year = "2011";
 JMesh::app_authors = "Marco Attene, Mirko Windhoff, Axel Thielscher";
 JMesh::app_maillist = "attene@ge.imati.cnr.it, mirko.windhoff@tuebingen.mpg.de, axel.thielscher@tuebingen.mpg.de";
 ExtTriMesh tin;

#ifdef DISCLAIMER
 printf("\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
 printf("This software can be used ONLY with an explicit authorization of the author.\n");
 printf("If you do not have such an authorization, you must delete this software.\n");
 printf("In no event this version of MeshFix can be redistributed.\n");
 printf("\n*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*\n");
#endif

 if (argc < 2) usage();

 float par = 0;
 unsigned numberComponentsToKeep = 1;
 bool joinOverlappingComponents = false;
// float minAllowedDistance = 0;
 bool haveJoinClosestComponents = false;
 int uniformRemeshSteps = 0, numberOfVertices = 0;
 int smoothingSteps = 0, nsteps = -1;
 double cutOuterMinDist = -1, cutInnerMinDist = -1;
 double decoupleOuterOutMinDist = -1, decoupleOuterInMinDist = -1, decoupleInnerInMinDist = -1;
 double dilateDist = 0;
 double fineTuneIn = -1, fineTuneOut = -1;
 bool clean = true;
 bool removeHandles = false;
 bool save_vrml = false;
 bool save_stl = false;
 bool save_msh = false;
 bool save_fsmesh = false;
 float xshift = 0.0; // used by saveFSMESH
 bool haveOutputFile = false;
 bool haveIntersectText = false;
 const char *outputFile;
 if (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) usage();
 for (int i=2; i<argc; i++)
 {
  if (!strcmp(argv[i], "-a"))
  {
   if (i<argc-1) par = (float)atof(argv[i+1]); else par = 0;
   if (par < 0) JMesh::error("Epsilon angle must be > 0.\n");
   if (par > 2) JMesh::error("Epsilon angle must be < 2 degrees.\n");
   tin.epsilon_angle = par;
   if (tin.epsilon_angle)
   {
    JMesh::acos_tolerance = asin((M_PI*tin.epsilon_angle)/180.0);
	printf("Fixing asin tolerance to %e\n",JMesh::acos_tolerance);
    i++;
   }
  }
  else if (!strcmp(argv[i], "-h") || !strcmp(argv[i], "--help")) usage();
  else if (!strcmp(argv[i], "--shells")) {
      if (i<argc-1) {
          numberComponentsToKeep = atoi(argv[i+1]);
          if (numberComponentsToKeep < 1)
              JMesh::error("# components to keep must be >= 1.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "-w") || !strcmp(argv[i], "--wrl")) save_vrml = true;
  else if (!strcmp(argv[i], "-s") || !strcmp(argv[i], "--stl")) save_stl = true;
  else if (!strcmp(argv[i], "--msh")) save_msh = true;
  else if (!strcmp(argv[i], "--fsmesh")) save_fsmesh = true;
  else if (!strcmp(argv[i], "-j")) joinOverlappingComponents = true;
  else if (!strcmp(argv[i], "-u")) {
      if (i>=argc-1 || (uniformRemeshSteps = atoi(argv[i+1]))<1)
          JMesh::error("# uniform remesh steps must be >= 1.\n");
      i++;
  }
  else if (!strcmp(argv[i], "--xshift")) {
      if (i>=argc-1) JMesh::error("error reading xshift\n");
      xshift = (float) atof(argv[i+1]);
      JMesh::info("xshift set to %f\n",xshift);
      i++;
  }
  else if (!strcmp(argv[i], "--vertices")) {
      if (i>=argc-1 || (numberOfVertices = atoi(argv[i+1]))<1)
          JMesh::error("# of vertices must be >= 0.\n");
      i++;
  }
  else if (!strcmp(argv[i], "--smooth")) {
      if (i>=argc-1 || (smoothingSteps = atoi(argv[i+1]))<1)
          JMesh::error("# smoothing steps must be >= 1.\n");
      i++;
  }
  else if (!strcmp(argv[i], "--cut-outer")) {
      if (i<argc-1) {
          cutOuterMinDist = atof(argv[i+1]);
          if (cutOuterMinDist < 0)
              JMesh::error("cutOuterMinDist must be >= 0.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "--cut-inner")) {
      if (i<argc-1) {
          cutInnerMinDist = atof(argv[i+1]);
          if (cutInnerMinDist < 0)
              JMesh::error("cutInnerMinDist must be >= 0.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "--decouple-outout")) {
      if (i<argc-1) {
          decoupleOuterOutMinDist = atof(argv[i+1]);
          if (decoupleOuterOutMinDist < 0)
              JMesh::error("decoupleOuterOutMinDist must be >= 0.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "--decouple-outin")) {
      if (i<argc-1) {
          decoupleOuterInMinDist = atof(argv[i+1]);
          if (decoupleOuterInMinDist < 0)
              JMesh::error("decoupleOuterInMinDist must be >= 0.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "--decouple-inin")) {
      if (i<argc-1) {
          decoupleInnerInMinDist = atof(argv[i+1]);
          if (decoupleInnerInMinDist < 0)
              JMesh::error("decoupleInnerInMinDist must be >= 0.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "--decouple-inin")) {
      if (i<argc-1) {
          decoupleInnerInMinDist = atof(argv[i+1]);
          if (decoupleInnerInMinDist < 0)
              JMesh::error("decoupleInMinDist must be >= 0.\n");
          else
              i++;
      }
  }
  else if (!strcmp(argv[i], "--dilate")) {
      if (i<argc-1) {
          dilateDist = atof(argv[i+1]);
          i++;
      }
  }
  else if (!strcmp(argv[i], "--fineTuneIn")) {
      if (i<argc-1) { fineTuneIn = atof(argv[i+1]);  i++; }
      if (fineTuneIn <= 0) JMesh::error("fineTuneIn MinDist must be > 0.\n");

      if (i<argc-1) { nsteps = atoi(argv[i+1]);  i++; }
      if (nsteps <= 0) JMesh::error("number of substeps must be > 0.\n");
  }
  else if (!strcmp(argv[i], "--fineTuneOut")) {
      if (i<argc-1) { fineTuneOut = atof(argv[i+1]);  i++; }
      if (fineTuneOut <= 0) JMesh::error("fineTuneOut MinDist must be > 0.\n");

      if (i<argc-1) { nsteps = atoi(argv[i+1]);  i++; }
      if (nsteps <= 0) JMesh::error("number of substeps must be > 0.\n");
  }
  else if (!strcmp(argv[i], "--remove-handles")) removeHandles = true;
  else if (!strcmp(argv[i], "--intersect")) haveIntersectText = true;
  else if (!strcmp(argv[i], "--no-clean")) clean = false;
  else if (!strcmp(argv[i], "-jc")) haveJoinClosestComponents = true;
  else if (!strcmp(argv[i], "-o")) {
      if (i<argc-1) {
          haveOutputFile = true;
          outputFile = argv[i+1];
          i++;
      }
  }
  else if (!strcmp(argv[i], "-q")) JMesh::quiet = true;
  else if (argv[i][0] == '-') JMesh::warning("%s - Unknown operation.\n",argv[i]);
 }

 printf("meshfix %s\n", argv[1]);
 // The loader performs the conversion to a set of oriented manifolds
 if (tin.load(argv[1]) != 0) JMesh::error("Can't open file '%s'.\n", argv[1]);

 // Join the second input argument if existing
 if (tin.append(argv[2]) == 0)
     JMesh::info("%s was joined.\n", argv[2]);
 input_filename = argv[1];

 // Keep only the biggest components
 tin.removeSmallestComponents( numberComponentsToKeep );

 // Fill holes by taking into account both sampling density and normal field continuity
 tin.fillSmallBoundaries(tin.E.numels(), true, true);

 if (joinOverlappingComponents) {
     tin.removeSmallestComponents(2);
     if(!tin.joinOverlappingComponentPair2()) {
         if(!joinClosestComponents(&tin, false, true, false))
             JMesh::warning("Joining didn't succeed.\n");
     } else numberComponentsToKeep = 1; // for subsequent cleaning
 }
 if (haveJoinClosestComponents)
 {
  printf("\nJoining input components ...\n");
  JMesh::begin_progress();
  while (joinClosestComponents(&tin, false, true, true)) JMesh::report_progress("Num. components: %d       ",tin.shells());
  JMesh::end_progress();
  tin.deselectTriangles();
 }

 if (removeHandles) {
     printf("Removing all handles ...\n");
     if(tin.shells() > 1)
         JMesh::warning("Remove handles works only on single component meshes. Keeping only biggest shell.\n");
     if(!tin.removeHandles()) JMesh::warning("Remove handles didn't succeed.\n");
 }

 if (dilateDist != 0.0) {
     printf("Dilating by %g.\n", dilateDist);
     tin.dilate(dilateDist);
 }
 if (cutOuterMinDist >= 0) {
     printf("Cutting triangles of the first component away, that are outside of the second one; Fill holes.\n");
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't cut. Having %d and should have 2.\n", tin.shells());
     else tin.cutFirstWithSecondComponent(cutOuterMinDist, true);
 }
 if (cutInnerMinDist >= 0) {
     printf("Cutting triangles of the first component away, that are inside of the second one; Fill holes.\n");
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't cut. Having %d and should have 2.\n", tin.shells());
     else tin.cutFirstWithSecondComponent(cutInnerMinDist, false);
 }
 if (decoupleOuterOutMinDist >= 0) {
     if(numberComponentsToKeep == 1) JMesh::warning("Use --shells 2 for decoupling.\n");
     printf("Decoupling first (outer) component from second one (move outwards). Min. distance: %g.\n", decoupleOuterOutMinDist);
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't decouple. Having %d and should have 2.\n", tin.shells());
     else tin.decoupleFirstFromSecondComponent(decoupleOuterOutMinDist, 15, true, true);
     numberComponentsToKeep = 1; // for subsequent cleaning
 } else if(decoupleOuterInMinDist >= 0) {
     if(numberComponentsToKeep == 1) JMesh::warning("Use --shells 2 for decoupling.\n");
     printf("Decoupling first (outer) component from second one (move inwards). Min. distance: %g.\n", decoupleInnerInMinDist);
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't decouple. Having %d and should have 2.\n", tin.shells());
     else tin.decoupleFirstFromSecondComponent(decoupleOuterInMinDist, 15, true, false);
     numberComponentsToKeep = 1; // for subsequent cleaning
 } else if(decoupleInnerInMinDist >= 0) {
     if(numberComponentsToKeep == 1) JMesh::warning("Use --shells 2 for decoupling.\n");
     printf("Decoupling first (inner) component from second one (move inwards). Min. distance: %g.\n", decoupleInnerInMinDist);
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't decouple. Having %d and should have 2.\n", tin.shells());
     else tin.decoupleFirstFromSecondComponent(decoupleInnerInMinDist, 15, false, false);
     numberComponentsToKeep = 1; // for subsequent cleaning
 }

 if (fineTuneIn >=0) {
     printf("Fine-tuning for later volume meshing ...\n");
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't decouple. Having %d and should have 2.\n", tin.shells());
     else tin.fineTune(fineTuneIn, nsteps, true);
 } else if (fineTuneOut >=0) {
     printf("Fine-tuning for later volume meshing ...\n");
     if(tin.shells() != 2) JMesh::warning("Incorrect number of components, won't decouple. Having %d and should have 2.\n", tin.shells());
     else tin.fineTune(fineTuneOut, nsteps, false);
 }


 if (uniformRemeshSteps) {
     printf("Uniform remeshing ...\n");
     tin.uniformRemesh(uniformRemeshSteps, numberOfVertices, tin.E.numels());
 } else if(numberOfVertices) { JMesh::warning("--vertices works only together with -u."); }

 if(smoothingSteps) {
     printf("Smoothing %d steps.\n", smoothingSteps);
     tin.laplacianSmooth(smoothingSteps, 1);
 }
 // Run geometry correction
 if (clean) {
     printf("Cleaning intersections, degeneracies ...\n");
     if (!tin.clean(20, 3, numberComponentsToKeep)) {
      fprintf(stderr,"MeshFix failed!\n");
      fprintf(stderr,"Please try manually using ReMESH: http://remesh.sourceforge.net\n");
      FILE *fp = fopen("meshfix_log.txt","a");
      fprintf(fp,"MeshFix failed on %s\n", input_filename);
      fclose(fp);
     }
 }

 if (haveIntersectText) {
     printf("Testing for intersections ...\n");
     tin.deselectTriangles();

     int its = tin.selectIntersectingTriangles();

     if(haveOutputFile) tin.saveMSH(outputFile);

     if(its) return 0;
     return 1;
 }

 char *fname = createFilename( haveOutputFile ? outputFile : argv[1], haveOutputFile ? "": "_fixed", (save_vrml? ".wrl" : (save_stl? ".stl": (save_msh? ".msh" : (save_fsmesh? ".fsmesh" : ".off")))), !haveOutputFile);
 printf("Saving output mesh to '%s'\n",fname);
 if (save_vrml)
     tin.saveVRML1(fname);
 else if (save_stl)
     tin.saveSTL(fname);
 else if (save_msh)
     tin.saveMSH(fname);
 else if (save_fsmesh)
     tin.saveFSMESH(fname,xshift);
 else
     tin.saveOFF(fname);
 return 0;
}
