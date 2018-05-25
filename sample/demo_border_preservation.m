vol = uint8(zeros(100, 100, 100));
vol(1:50, 1:50, 1:50) = 1;
[no, ~, fa] = v2m(vol+1, 0.5, 1, 1000, 'cgalmesh');
figure; title('Without border preservation');
plotmesh(no, fa);
[no, el, fa] = v2m(vol+1, 0.5, 1, 1000, 'cgalmesh2');
figure; title('With border preservation');
plotmesh(no, fa);