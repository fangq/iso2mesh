#include "jmesh.h"
#include <stdlib.h>

int main(int argc, char *argv[])
{
 JMesh::init();

 Triangulation tin;

 if (argc < 3)
  JMesh::error("\nUsage: %s infile.off outfile.off\n",argv[0]);

 if (tin.load(argv[1]) != 0) JMesh::error("Can't open file.\n");
 printf("Saving Manifold Oriented Triangulation ...\n");
 tin.saveOFF(argv[2]);

 return 0;
}
