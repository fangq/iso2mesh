[no, fa] = extrudesurf([[1 0 0]; [0 1 0]; [0 0 1]], [1 2 3], [5 5 5]);
[no, fa] = meshcheckrepair(no, fa);
figure; title('Original polyhedral mesh'); plotmesh(no, fa)
[nn, el, ff] = s2m(no, fa, 1, 1000, 'cgalpoly');
figure; title('Tetra mesh without feature preservation');
plotmesh(nn, ff)
[nn, el, ff] = s2m(no, fa, 1, 1000, 'cgalpoly2');
figure; title('Tetra mesh with feature preservation');
plotmesh(nn, ff)