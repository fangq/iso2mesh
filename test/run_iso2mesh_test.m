function run_iso2mesh_test(tests)
%
% run_iso2mesh_test
%   or
% run_iso2mesh_test(tests)
% run_iso2mesh_test({'prim', 'utils', 'core', 'surf','bool','vol'})
%
% Unit testing for Iso2Mesh
%
% authors:Qianqian Fang (q.fang <at> neu.edu)
% date: 2024/10/24
%
% input:
%      tests: is a cell array of strings, possible elements include
%         'prim': primitive shape meshing
%         'utils': utilities
%         'core':  core functions
%         'surf': surface processing
%         'bool': surface boolean operations
%         'vol': volume processing
%         'io': mesh file writers and readers, tested as round trips
%         'invariant': properties a mesh operation must preserve
%         'bugs': test specific bug fixes
%
% license:
%     GPL version 3, see LICENSE_{BSD,GPLv3}.txt files for details
%
% -- this function is part of Iso2Mesh toolbox (http://iso2mesh.sf.net/)
%

if (nargin == 0)
    tests = {'prim', 'utils', 'core', 'surf', 'bool', 'vol', 'io', 'invariant', 'bugs'};
end

test_iso2mesh('reset');

%%
if (ismember('prim', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test primitive meshing functions\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    [no, fc, el] = meshabox([0 0 0], [1 1 1], 1);
    % the exact triangulation differs between tetgen builds, so check that the
    % surface is closed, outward-facing and covers the 6 unit faces
    test_iso2mesh('meshabox face closed', @savejson, isempty(surfedge(fc(:, 1:3))), '[true]');
    test_iso2mesh('meshabox face area', @savejson, round_to_digits(sum(elemvolume(no, fc(:, 1:3))), 6), '[6]');
    test_iso2mesh('meshabox face outward', @savejson, round_to_digits(surfvolume(no, fc(:, 1:3)), 6), '[1]');
    test_iso2mesh('meshabox elem', @savejson, round_to_digits(sum(elemvolume(no, el)), 2), '[1]');
    [no, fc] = meshabox([0 10 5], [10 20 30], 1);
    test_iso2mesh('meshabox offset', @savejson, round_to_digits(sum(elemvolume(no, fc)), 2), '[1200]');

    [no, fc, el] = meshunitsphere(0.05, 100);
    test_iso2mesh('meshunitsphere face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[12.5527]');
    test_iso2mesh('meshunitsphere elem', @savejson, round_to_digits(sum(elemvolume(no, el)), 4), '[4.1802]');

    [no, fc, el] = meshasphere([1, 1, 1], 2, 0.05, 100);
    test_iso2mesh('meshasphere face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[50.2519]');
    test_iso2mesh('meshasphere elem', @savejson, round_to_digits(sum(elemvolume(no, el)), 4), '[33.4933]');

    [no, el] = meshgrid5(1:2, -1:0, 2:3);
    test_iso2mesh('meshgrid5 elem', @savejson, sum(el), '[545,577,532,586]');
    test_iso2mesh('meshgrid5 elem(:,1)', @savejson, el(:, 4)', '[13,5,11,14,5,5,15,3,14,3,7,17,13,14,13,9,17,15,14,5,19,14,13,20,23,15,14,20,21,11,17,23,23,13,25,27,23,23,15,15]');

    [no, el] = meshgrid6(1:2, -1:0, 2:0.5:3);
    test_iso2mesh('meshgrid6', @savejson, el, '[[1,2,8,4],[5,6,12,8],[1,3,4,8],[5,7,8,12],[1,2,6,8],[5,6,10,12],[1,5,8,6],[5,9,12,10],[1,3,8,7],[5,7,12,11],[1,5,7,8],[5,9,11,12]]');

    [no, fc, el] = meshanellip([1, 1, 1], [2, 4, 1], 0.05, 100);
    test_iso2mesh('meshanellip face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[63.4078]');
    test_iso2mesh('meshanellip elem', @savejson, round_to_digits(sum(elemvolume(no, el(:, 1:4))), 4), '[33.4419]');

    % [no, fc, el] = meshacylinder([1 1 1], [2 3 4], [10, 12], 0.1, 10);
    % test_iso2mesh('meshacylinder face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[1045.2322]');
    % test_iso2mesh('meshacylinder elem', @savejson, round_to_digits(sum(elemvolume(no, el(:, 1:4))), 4), '[1402.8993]');

    [no, fc] = meshacylinder([1 1 1], [2 3 4], [0.5, 0.8], 0, 0, 8);
    test_iso2mesh('meshacylinder plc', @savejson, fc, '[[[[1,9,10,2],1]],[[[2,10,11,3],1]],[[[3,11,12,4],1]],[[[4,12,13,5],1]],[[[5,13,14,6],1]],[[[6,14,15,7],1]],[[[7,15,16,8],1]],[[[8,16,9,1],1]],[[[1,2,3,4,5,6,7,8],2]],[[[9,10,11,12,13,14,15,16],3]]]');

    [no, fc, c0] = latticegrid(1:2, -1:0, 2:0.5:3);
    test_iso2mesh('latticegrid fc', @savejson, fc, '[[[1,2,6,5]],[[1,3,4,2]],[[1,5,7,3]],[[2,6,8,4]],[[3,4,8,7]],[[5,6,10,9]],[[5,7,8,6]],[[5,9,11,7]],[[6,10,12,8]],[[7,8,12,11]],[[9,11,12,10]]]');
    test_iso2mesh('latticegrid centroid', @savejson, c0, '[[1.5,-0.5,2.25],[1.5,-0.5,2.75]]');

    [no, fc] = meshcylinders([1 1 1], [2 3 4], [1, 2], 0.5, 0, 0, 8);
    test_iso2mesh('meshcylinders face', @savejson, fc, '[[[6,14,12,4],1],[[4,12,10,2],1],[[2,10,9,1],1],[[1,9,11,3],1],[[3,11,13,5],1],[[5,13,15,7],1],[[7,15,16,8],1],[[8,16,14,6],1],[[6,4,2,1,3,5,7,8],2],[[14,12,10,9,11,13,15,16],3],[[14,22,20,12],1],[[12,20,18,10],1],[[10,18,17,9],1],[[9,17,19,11],1],[[11,19,21,13],1],[[13,21,23,15],1],[[15,23,24,16],1],[[16,24,22,14],1],[[22,20,18,17,19,21,23,24],3]]');
end

%%
if (ismember('core', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test core functions\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    im = zeros(3, 3, 3);
    im(2, 2, 2:3) = 1;
    [no, fc] = binsurface(im);

    test_iso2mesh('binsurface face', @savejson, fc, '[[4,5,1],[7,11,10],[5,6,2],[8,12,11],[5,2,1],[7,8,11],[6,3,2],[8,9,12],[1,8,7],[10,11,4],[2,9,8],[11,12,5],[1,2,8],[11,5,4],[2,3,9],[12,6,5],[7,10,1],[10,4,1]]');
    test_iso2mesh('binsurface node', @savejson, sum(no'), '[3,4,5,4,5,6,4,5,6,5,6,7]');
    test_iso2mesh('surfedge', @savejson, surfedge(fc), '[[6,3],[3,9],[12,6],[9,12]]');

    [no, fc] = binsurface(im, 4);
    test_iso2mesh('binsurface quad face', @savejson, fc, '[[1,3,7,5],[2,4,8,6],[5,7,11,9],[6,8,12,10],[1,2,6,5],[3,4,8,7],[5,6,10,9],[7,8,12,11],[1,2,4,3]]');

    no = binsurface(im, 0);
    test_iso2mesh('binsurface mask', @savejson, no, '{"_ArrayType_":"double","_ArraySize_":[2,2,2],"_ArrayData_":[0,0,0,0,0,0,-1,-1]}');

    [no, fc] = v2s(im, 0.5, 0.03);
    test_iso2mesh('v2s face', @savejson, round_to_digits(sum(elemvolume(no, fc(:, 1:3))), 2), '[5.01]');

    [no, el, fc] = v2m(im, 0.5, 0.03, 10);
    test_iso2mesh('v2m face', @savejson, round_to_digits(sum(elemvolume(no, fc(:, 1:3))), 2), '[5.01]');
    test_iso2mesh('v2m elem', @savejson, round_to_digits(sum(elemvolume(no, el(:, 1:4))), 4), '[0.8787]');
end

%%
if (ismember('utils', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test utilities\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    [no, el] = meshgrid6(1:2, -1:0, 2:0.5:3);
    fc = volface(el);

    test_iso2mesh('volface', @savejson, fc, '[[2,1,4],[1,2,6],[1,3,4],[3,1,7],[5,1,6],[1,5,7],[2,4,8],[2,8,6],[3,8,4],[3,7,8],[5,6,10],[7,5,11],[9,5,10],[5,9,11],[6,8,12],[6,12,10],[7,12,8],[7,11,12],[9,10,12],[9,12,11]]');
    test_iso2mesh('uniqfaces', @savejson, uniqfaces(el), '[[1,2,4],[1,2,6],[1,2,8],[1,3,4],[1,3,7],[1,3,8],[1,8,4],[1,5,6],[1,5,7],[1,5,8],[1,6,8],[1,8,7],[2,8,4],[2,6,8],[3,4,8],[3,8,7],[5,6,8],[5,6,10],[5,6,12],[5,7,8],[5,7,11],[5,7,12],[5,12,8],[5,9,10],[5,9,11],[5,9,12],[5,10,12],[5,12,11],[6,12,8],[6,10,12],[7,8,12],[7,12,11],[9,12,10],[9,11,12]]');
    test_iso2mesh('meshedge', @savejson, unique(meshedge(el), 'rows'), '[[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8],[2,4],[2,6],[2,8],[3,4],[3,7],[3,8],[4,8],[5,6],[5,7],[5,8],[5,9],[5,10],[5,11],[5,12],[6,8],[6,10],[6,12],[7,8],[7,11],[7,12],[8,4],[8,6],[8,7],[8,12],[9,10],[9,11],[9,12],[10,12],[11,12],[12,8],[12,10],[12,11]]');
    test_iso2mesh('uniqedges', @savejson, uniqedges(el), '[[1,2],[1,3],[1,4],[1,5],[1,6],[1,7],[1,8],[2,4],[2,6],[2,8],[3,4],[3,7],[3,8],[8,4],[5,6],[5,7],[5,8],[5,9],[5,10],[5,11],[5,12],[6,8],[6,10],[6,12],[7,8],[7,11],[7,12],[12,8],[9,10],[9,11],[9,12],[10,12],[12,11]]');
    test_iso2mesh('meshconn', @savejson, meshconn(el, size(no, 1)), '[[[2,3,4,5,6,7,8]],[[1,4,6,8]],[[1,4,7,8]],[[1,2,3,8]],[[1,6,7,8,9,10,11,12]],[[1,2,5,8,10,12]],[[1,3,5,8,11,12]],[[1,2,3,4,5,6,7,12]],[[5,10,11,12]],[[5,6,9,12]],[[5,7,9,12]],[[5,6,7,8,9,10,11]]]');
    test_iso2mesh('neighborelem', @savejson, neighborelem(el, size(no, 1)), '[[[1,3,5,7,9,11]],[[1,5]],[[3,9]],[[1,3]],[[2,4,6,7,8,10,11,12]],[[2,5,6,7]],[[4,9,10,11]],[[1,2,3,4,5,7,9,11]],[[8,12]],[[6,8]],[[10,12]],[[2,4,6,8,10,12]]]');
    test_iso2mesh('faceneighbors', @savejson, faceneighbors(el), '[[5,0,3,0],[6,7,4,0],[0,9,1,0],[11,10,2,0],[0,1,7,0],[0,2,8,0],[11,0,5,2],[12,0,6,0],[3,0,11,0],[4,0,12,0],[0,7,9,4],[0,8,10,0]]');
    test_iso2mesh('faceneighbors surface', @savejson, faceneighbors(el, 'surface'), '[[1,3,4],[1,2,6],[5,6,10],[1,5,7],[5,9,11],[1,2,4],[1,5,6],[5,9,10],[1,3,7],[5,7,11],[2,4,8],[6,8,12],[3,4,8],[7,8,12],[2,6,8],[6,10,12],[9,10,12],[3,7,8],[7,11,12],[9,11,12]]');
    test_iso2mesh('edgeneighbors', @savejson, edgeneighbors(fc), '[[2,3,7],[1,8,5],[4,9,1],[3,6,10],[6,2,11],[5,12,4],[1,9,8],[7,15,2],[10,7,3],[4,17,9],[5,16,13],[6,14,18],[14,11,19],[13,20,12],[8,17,16],[15,19,11],[18,15,10],[12,20,17],[13,16,20],[19,18,14]]');
    test_iso2mesh('edgeneighbors general', @savejson, edgeneighbors(uniqfaces(el), 'general'), '[[[2,3,4,7,13]],[[1,3,8,11,14]],[[1,2,6,7,10,11,12,13,14]],[[1,5,6,7,15]],[[4,6,9,12,16]],[[3,4,5,7,10,11,12,15,16]],[[1,3,4,6,10,11,12,13,15]],[[2,9,10,11,17,18,19]],[[5,8,10,12,20,21,22]],[[3,6,7,8,9,11,12,17,20,23]],[[2,3,6,7,8,10,12,14,17,29]],[[3,5,6,7,9,10,11,16,20,31]],[[1,3,7,14,15]],[[2,3,11,13,17,29]],[[4,6,7,13,16]],[[5,6,12,15,20,31]],[[8,10,11,14,18,19,20,23,29]],[[8,17,19,24,27,30]],[[8,17,18,22,23,26,27,28,29,30]],[[9,10,12,16,17,21,22,23,31]],[[9,20,22,25,28,32]],[[9,19,20,21,23,26,27,28,31,32]],[[10,17,19,20,22,26,27,28,29,31]],[[18,25,26,27,33]],[[34,21,24,26,28]],[[34,19,22,23,24,25,27,28,33]],[[18,19,22,23,24,26,28,30,33]],[[34,19,21,22,23,25,26,27,32]],[[11,14,17,19,23,30,31]],[[18,19,27,29,33]],[[12,16,20,22,23,29,32]],[[34,21,22,28,31]],[[34,24,26,27,30]],[[25,26,28,32,33]]]');
    test_iso2mesh('meshquality', @savejson, unique(round_to_digits(meshquality(no, el), 6)), '[[0.620322],[0.686786]]');
    test_iso2mesh('meshquality face', @savejson, unique(round_to_digits(meshquality(no, fc), 6)), '[[0.69282],[0.866025]]');
    test_iso2mesh('meshface', @savejson, unique(sort(meshface(el)), 'rows'), '[[1,2,4],[1,3,6],[1,4,7],[1,5,7],[1,5,8],[1,6,8],[2,6,8],[3,7,8],[5,7,8],[5,8,8],[5,8,10],[5,8,11],[5,9,11],[5,9,12],[5,10,12],[5,11,12],[6,12,12],[7,12,12],[9,12,12]]');
    test_iso2mesh('surfacenorm', @savejson, surfacenorm(no, fc), '[[0,0,-1],[0,-1,0],[0,0,-1],[-1,0,0],[0,-1,0],[-1,0,0],[1,0,0],[1,0,0],[0,1,0],[0,1,0],[0,-1,0],[-1,0,0],[0,-1,0],[-1,0,0],[1,0,0],[1,0,0],[0,1,0],[0,1,0],[0,0,1],[0,0,1]]');
    test_iso2mesh('nodesurfnorm', @savejson, round_to_digits(nodesurfnorm(no, fc), 6), '[[-0.57735,-0.57735,-0.57735],[0.816497,-0.408248,-0.408248],[-0.408248,0.816497,-0.408248],[0.408248,0.408248,-0.816497],[-0.707107,-0.707107,0],[0.707107,-0.707107,0],[-0.707107,0.707107,0],[0.707107,0.707107,0],[-0.408248,-0.408248,0.816497],[0.408248,-0.816497,0.408248],[-0.816497,0.408248,0.408248],[0.57735,0.57735,0.57735]]');
    test_iso2mesh('meshcentroid', @savejson, meshcentroid(no, el), '[[1.75,-0.5,2.125],[1.75,-0.5,2.625],[1.5,-0.25,2.125],[1.5,-0.25,2.625],[1.75,-0.75,2.25],[1.75,-0.75,2.75],[1.5,-0.75,2.375],[1.5,-0.75,2.875],[1.25,-0.25,2.25],[1.25,-0.25,2.75],[1.25,-0.5,2.375],[1.25,-0.5,2.875]]');
    test_iso2mesh('meshcentroid face', @savejson, round_to_digits(meshcentroid(no, fc), 3), '[[1.667,-0.667,2],[1.667,-1,2.167],[1.333,-0.333,2],[1,-0.333,2.167],[1.333,-1,2.333],[1,-0.667,2.333],[2,-0.333,2.167],[2,-0.667,2.333],[1.667,0,2.167],[1.333,0,2.333],[1.667,-1,2.667],[1,-0.333,2.667],[1.333,-1,2.833],[1,-0.667,2.833],[2,-0.333,2.667],[2,-0.667,2.833],[1.667,0,2.667],[1.333,0,2.833],[1.667,-0.667,3],[1.333,-0.333,3]]');
    test_iso2mesh('nodevolume', @savejson, round_to_digits(nodevolume(no, el), 6), '[[0.125],[0.041667],[0.041667],[0.041667],[0.166667],[0.083333],[0.083333],[0.166667],[0.041667],[0.041667],[0.041667],[0.125]]');
    test_iso2mesh('nodevolume face', @savejson, round_to_digits(nodevolume(no, fc), 6), '[[0.666667],[0.416667],[0.416667],[0.5],[0.5],[0.5],[0.5],[0.5],[0.5],[0.416667],[0.416667],[0.666667]]');
    test_iso2mesh('elemvolume', @savejson, unique(round_to_digits(elemvolume(no, el), 6)), '[0.083333]');
    test_iso2mesh('surfvolume', @savejson, surfvolume(no, fc), '[1]');
    test_iso2mesh('insurface', @savejson, insurface(no, fc, [1.5, -0.9, 2.1; 1, 0, 2; -1, 0 2; 1.2, -0, 2.5])', '[1,1,0,1]');

    [nx, nv, ne, nf, nb, ng] = mesheuler(fc);
    test_iso2mesh('mesheuler surface', @savejson, [nx, nv, ne, nf, nb, ng], '[2,12,30,20,0,0]');
    [nx, nv, ne, nf, nb, ng] = mesheuler(el);
    test_iso2mesh('mesheuler tet', @savejson, [nx, nv, ne, nf, nb, ng], '[1,12,33,34,0,0]');
    [nx, nv, ne, nf, nb, ng] = mesheuler(fc(2:end - 1, :));
    test_iso2mesh('mesheuler open-surface', @savejson, [nx, nv, ne, nf, nb, ng], '[0,12,30,18,2,0]');

    [no1, fc1] = highordertet(no, el);
    test_iso2mesh('highordertet', @savejson, fc1, '[[1,7,3,10,8,14],[15,21,17,24,22,28],[2,3,7,11,13,14],[16,17,21,25,27,28],[1,5,7,9,10,22],[15,19,21,23,24,32],[4,7,5,17,15,22],[18,21,19,31,29,32],[2,7,6,13,12,25],[16,21,20,27,26,33],[4,6,7,16,17,25],[18,20,21,30,31,33]]');
end

%%
if (ismember('surf', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test surface processing\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    [no, fc, el] = meshacylinder([1 1 1], [2 3 4], [0.5, 0.7], 1, 100, 8);

    % tetgen output shifts with the last bits of its input (libm/BLAS differ
    % across platforms), so the checks below compare each result with the
    % input mesh rather than with stored node coordinates or element lists
    no2 = removeisolatednode(no, fc);
    test_iso2mesh('removeisolatednode', @savejson, isequal(no2, no(unique(fc(:)), :)), '[true]');
    test_iso2mesh('removeisolatednode center', @savejson, max(abs(mean(no2) - [1.44 1.88 2.32])) < 0.01, '[true]');
    test_iso2mesh('meshreorient', @savejson, all(meshreorient(no, el(:, [1, 2, 4, 3])) == el(:, 1:4)), '[1,1,1,1]');

    el1 = el;
    el1(el(:, 1:4) < 2) = size(no, 1) + el1(el(:, 1:4) < 2);

    [no2, el2] = removedupnodes([no; no(1:2, :)], el1(:, 1:4));
    test_iso2mesh('removedupnodes', @savejson, size(no2, 1) == size(no, 1) && max(abs(mean(no2) - mean(no))) < 1e-12, '[true]');
    test_iso2mesh('removedupnodes elem', @savejson, max(max(abs(no2(el2, :) - no(el(:, 1:4), :)))) < 1e-12, '[true]');
    test_iso2mesh('removedupelem', @savejson, isequal(sortrows(sort(removedupelem([el(:, 1:4); el(1:end - 5, 1:4)]), 2)), ...
                                                      sortrows(sort(el(end - 4:end, 1:4), 2))), '[true]');

    [no1, fc1] = surfreorient(no, fc);

    test_iso2mesh('surfreorient', @savejson, size(no1), '[50,3]');
    test_iso2mesh('surfreorient face', @savejson, any(elemvolume(no1, fc1) <= 0), '[false]');

    [no1, fc1] = meshcheckrepair(no, fc, 'deep');

    test_iso2mesh('meshcheckrepair deep node', @savejson, size(no1), '[50,3]');
    test_iso2mesh('meshcheckrepair deep face', @savejson, any(elemvolume(no1, fc1) <= 0), '[false]');

    [no2, fc2] = meshcheckrepair(no1, fc1(5:end, :), 'meshfix');

    test_iso2mesh('meshcheckrepair face', @savejson, abs(sum(elemvolume(no1, fc1)) - sum(elemvolume(no2, fc2))) < 1e-8, '[true]');

    [no2, fc2] = meshresample(no1, fc1, 0.1);
    [no3, el3] = s2m(no2, fc2, 1, 100);

    test_iso2mesh('meshresample', @savejson, size(no2, 1) < size(no1, 1) && isempty(surfedge(fc2)), '[true]');
    test_iso2mesh('meshresample with s2m node', @savejson, max(max(abs(no3(1:size(no2, 1), :) - no2))) < 1e-6, '[true]');
    test_iso2mesh('meshresample with s2m elem', @savejson, all(elemvolume(no3, el3(:, 1:4)) > 0) && ...
                  abs(sum(elemvolume(no3, el3(:, 1:4))) - surfvolume(no2, fc2)) < 1e-6, '[true]');

    [no1, el1] = meshrefine(no, el, fc, [0, 0, 0; 2, 3, 5]);

    test_iso2mesh('meshrefine insert node outside', @savejson, size(no1) == size(no), '[1,1]');
    test_iso2mesh('meshrefine insert node outside elem', @savejson, size(el1) == size(el), '[1,1]');

    [no2, el2] = mergemesh(no, el, no1, el1);
    [no1, el1] = removedupnodes(no2, el2(:, 1:4), 1e-6);
    el2 = unique(sort(el1')', 'rows');
    test_iso2mesh('mergemesh removedupnodes', @savejson, size(no1) == size(no), '[1,1]');
    test_iso2mesh('mergemesh removedupelem', @savejson, size(el2, 1) == size(el, 1), '[true]');

    vol0 = sum(elemvolume(no, el(:, 1:4)));

    [no1, el1, fc1] = meshrefine(no, el, fc, [[1 1 1] + 0.01; [2, 3, 4] - 0.01]);
    test_iso2mesh('meshrefine insert node', @savejson, size(no1) - size(no), '[2,0]');
    test_iso2mesh('meshrefine insert node elem', @savejson, size(el1) - size(el), '[16,0]');
    test_iso2mesh('meshrefine insert node face', @savejson, size(fc1) - size(fc), '[0,1]');

    % the number of added nodes depends on the tetgen build; check that the
    % mesh was refined without changing its volume or opening its boundary
    [no1, el1, fc1] = meshrefine(no, el, fc, ones(size(no, 1), 1) * 0.2);
    test_iso2mesh('meshrefine node sizefield node', @savejson, size(no1, 1) > size(no, 1), '[true]');
    test_iso2mesh('meshrefine node sizefield elem', @savejson, abs(sum(elemvolume(no1, el1(:, 1:4))) - vol0) < 1e-8, '[true]');
    test_iso2mesh('meshrefine node sizefield face', @savejson, size(fc1, 2) == 4 && isempty(surfedge(fc1(:, 1:3))), '[true]');

    [no1, el1, fc1] = meshrefine(no, el, ones(size(el, 1), 1) * 0.02);
    test_iso2mesh('meshrefine elem sizefield node', @savejson, size(no1, 1) > size(no, 1), '[true]');
    test_iso2mesh('meshrefine elem sizefield elem', @savejson, abs(sum(elemvolume(no1, el1(:, 1:4))) - vol0) < 1e-8, '[true]');
    test_iso2mesh('meshrefine elem sizefield face', @savejson, size(fc1, 2) == 4 && isempty(surfedge(fc1(:, 1:3))), '[true]');

    [no1, el1, fc1] = meshrefine(no, el, struct('maxvol', 0.02));
    test_iso2mesh('meshrefine maxvol node', @savejson, size(no1, 1) > size(no, 1), '[true]');
    test_iso2mesh('meshrefine maxvol elem', @savejson, abs(sum(elemvolume(no1, el1(:, 1:4))) - vol0) < 1e-8 && ...
                  max(elemvolume(no1, el1(:, 1:4))) <= 0.02 * (1 + 1e-6), '[true]');
    test_iso2mesh('meshrefine maxvol face', @savejson, size(fc1, 2) == 4 && isempty(surfedge(fc1(:, 1:3))), '[true]');

    [no, el] = meshgrid5(1:2, -1:0, 2:0.5:3);
    [no, el] = removeisolatednode(no, volface(el));
    no1 = sms(no, el, 10);
    [no2, el2] = s2m(no1, el, 1, 100);
    test_iso2mesh('sms laplacianhc', @savejson, sum(elemvolume(no2, el2(:, 1:4))) > 0.8, '[true]');

    no1 = sms(no, el, 10, 0.5, 'laplacian');
    [no2, el2] = s2m(no1, el, 1, 100);
    test_iso2mesh('sms laplacian', @savejson, sum(elemvolume(no2, el2(:, 1:4))) < 0.1, '[true]');

    no1 = sms(no, el, 10, 0.5, 'lowpass');
    [no2, el2] = s2m(no1, el, 1, 100);
    test_iso2mesh('sms lowpass', @savejson, sum(elemvolume(no2, el2(:, 1:4))) > 0.55, '[true]');
end

%%
if (ismember('bool', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test surface boolean operations\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    [no1, el1] = meshgrid5(1:2, 1:2, 1:2);
    el1 = volface(el1);
    [no1, el1] = removeisolatednode(no1, el1);
    [no2, el2] = meshgrid6(1.7:4, 1.7:4, 1.7:4);
    el2 = volface(el2);
    [no2, el2] = removeisolatednode(no2, el2);

    [no3, el3] = surfboolean(no1, el1, 'and', no2, el2);
    [no3, el3] = meshcheckrepair(no3, el3, 'dup', 'tolerance', 1e-4);
    [node, elem] = s2m(no3, el3, 1, 100);

    test_iso2mesh('surfboolean and', @savejson, round_to_digits(sum(elemvolume(node, elem(:, 1:4))), 5), '[0.027]');

    [no3, el3] = surfboolean(no1, el1, 'or', no2, el2);
    [no3, el3] = meshcheckrepair(no3, el3, 'dup', 'tolerance', 1e-4);
    [node, elem] = s2m(no3, el3, 1, 100);
    test_iso2mesh('surfboolean or', @savejson, round(sum(elemvolume(node, elem(:, 1:4))) * 1000), '[8973]');

    [no3, el3] = surfboolean(no1, el1, 'diff', no2, el2);
    [no3, el3] = meshcheckrepair(no3, el3, 'dup', 'tolerance', 1e-4);
    [node, elem] = s2m(no3, el3, 1, 100);
    test_iso2mesh('surfboolean diff', @savejson, round_to_digits(sum(elemvolume(node, elem(:, 1:4))), 5), '[0.973]');

    [no3, el3] = surfboolean(no1, el1, 'first', no2, el2);
    [no3, el3] = meshcheckrepair(no3, el3, 'dup', 'tolerance', 1e-4);
    [node, elem] = s2m(no3, el3, 1, 100, 'tetgen', [1.5, 1.5, 1.5]);
    test_iso2mesh('surfboolean first region 1', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 1, 1:4))), 5), '[0.973]');
    test_iso2mesh('surfboolean first region 0', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 0, 1:4))), 5), '[0.027]');

    [no3, el3] = surfboolean(no1, el1, 'second', no2, el2);
    [no3, el3] = meshcheckrepair(no3, el3, 'dup', 'tolerance', 1e-4);
    [node, elem] = s2m(no3, el3, 1, 100, 'tetgen', [2.6, 2.6, 2.6]);
    test_iso2mesh('surfboolean second region 1', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 1, 1:4))), 5), '[7.973]');
    test_iso2mesh('surfboolean second region 0', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 0, 1:4))), 5), '[0.027]');

    [no3, el3] = surfboolean(no1, el1, 'resolve', no2, el2);
    [no3, el3] = meshcheckrepair(no3, el3, 'dup', 'tolerance', 1e-4);
    [node, elem] = s2m(no3, el3, 1, 100, 'tetgen', [1.5, 1.5, 1.5; 2.6, 2.6, 2.6]);
    test_iso2mesh('surfboolean resolve region 0', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 0, 1:4))), 5), '[0.027]');
    test_iso2mesh('surfboolean resolve region 1', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 1, 1:4))), 5), '[0.973]');
    test_iso2mesh('surfboolean resolve region 2', @savejson, round_to_digits(sum(elemvolume(node, elem(elem(:, 5) == 2, 1:4))), 5), '[7.973]');
    test_iso2mesh('surfboolean self intersecting test', @savejson, surfboolean(no1, el1, 'self', no2, el2), '[1]');

    % [no3, el3] = meshgrid5(1:0.4:1.4, 1:0.4:1.4, 1:0.4:1.4);
    % el3 = volface(el3);
    % [no3, el3] = removeisolatednode(no3, el3);

    % [no4, el4] = surfboolean(no1, el1, 'separate', no3, el3);
    % [node, elem] = s2m(no4, el4, 1, 100, 'tetgen', [1.5, 1.5, 1.5]);
    % test_iso2mesh('surfboolean separate', @savejson, unique(elem(:, 5))', '[0,1]');
end

%%
if (ismember('vol', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test binary volume processing\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    vol = zeros(3, 4, 3);
    vol(2, 2:3, 2) = 1;

    test_iso2mesh('volgrow 1', @savejson, volgrow(vol), '[[[0,0,0],[0,1,0],[0,1,0],[0,0,0]],[[0,1,0],[1,1,1],[1,1,1],[0,1,0]],[[0,0,0],[0,1,0],[0,1,0],[0,0,0]]]', 'NestArray', 1);
    test_iso2mesh('volgrow 2', @savejson, volgrow(vol, 2), '[[[0,1,0],[1,1,1],[1,1,1],[0,1,0]],[[1,1,1],[1,1,1],[1,1,1],[1,1,1]],[[0,1,0],[1,1,1],[1,1,1],[0,1,0]]]', 'NestArray', 1);
    test_iso2mesh('volgrow nonbinary 2', @savejson, volgrow(vol * 2.5, 2), '[[[0,1,0],[1,1,1],[1,1,1],[0,1,0]],[[1,1,1],[1,1,1],[1,1,1],[1,1,1]],[[0,1,0],[1,1,1],[1,1,1],[0,1,0]]]', 'NestArray', 1);

    mask = zeros(3, 3, 3);
    mask(1:13:end) = 1;

    test_iso2mesh('volgrow user mask', @savejson, volgrow(vol, 1, mask), '[[[0,0,1],[0,0,1],[0,0,0],[0,0,0]],[[0,0,0],[0,1,0],[0,1,0],[0,0,0]],[[0,0,0],[0,0,0],[1,0,0],[1,0,0]]]', 'NestArray', 1);
    test_iso2mesh('volgrow 2d', @savejson, volgrow(vol(:, :, 2)), '[[0,1,1,0],[1,1,1,1],[0,1,1,0]]', 'NestArray', 1);
    test_iso2mesh('volgrow 2d with user mask', @savejson, volgrow(vol(:, :, 2), 1, [1 1 0; 1 1 1; 0 0 1]), '[[1,1,0,0],[1,1,1,1],[0,1,1,1]]', 'NestArray', 1);
    test_iso2mesh('volgrow 2d with logical inputs', @savejson, volgrow(logical(squeeze(vol(:, 2, :))), 1, logical([0 1 0; 0 1 1; 0 0 1])), '[[1,0,0],[1,1,0],[0,1,0]]', 'NestArray', 1);

    vol1 = volgrow(magic(60) > 2000, 2);
    test_iso2mesh('volgrow 2d with complex mask', @savejson, sum(vol1(:)), '[3380]', 'NestArray', 1);
    test_iso2mesh('volgrow 2d with simple mask', @savejson, volgrow([0 0 0 0; 0 0 1 0; 0 0 0 0], 2), '[[0,1,1,1],[1,1,1,1],[0,1,1,1]]', 'NestArray', 1);
    test_iso2mesh('volgrow 2d with ones mask', @savejson, volgrow([0 0 0 0; 0 0 1 0; 0 0 0 0], 1, ones(3)), '[[0,1,1,1],[0,1,1,1],[0,1,1,1]]');

    vol1 = volgrow(full(sparse([2, 5, 7], [3, 3, 6], [1 1 1], 10, 8)), 10, [0 0 0; 1 1 1; 0 0 0]);
    mask = repmat([0, 1, 0, 0, 1, 0, 1, 0, 0, 0]', 1, 8);
    test_iso2mesh('volgrow 2d x-line mask', @savejson, all(vol1(:) == mask(:)), '[true]');

    vol1 = volgrow(full(sparse([2, 5, 7], [3, 3, 6], [1 1 1], 10, 8)), 10, [0 1 0; 0 1 0; 0 1 0]);
    mask = repmat([0, 0, 1, 0, 0, 1, 0, 0], 10, 1);
    test_iso2mesh('volgrow 2d y-line mask', @savejson, all(vol1(:) == mask(:)), '[true]');

    vol = ones(3, 4, 5);
    vol(1:6) = 0;
    vol(end) = 0;

    test_iso2mesh('volshrink 3d 1', @savejson, volshrink(vol), '[[[0,0,1,1,1],[0,0,1,1,1],[0,1,1,1,1],[1,1,1,1,1]],[[0,0,1,1,1],[0,0,1,1,1],[0,1,1,1,1],[1,1,1,1,0]],[[0,0,1,1,1],[0,0,1,1,1],[0,1,1,1,0],[1,1,1,0,0]]]', 'NestArray', 1);

    vol1 = volshrink(volgrow(volshrink(vol), 1, ones(3, 3, 3)), 1, ones(3, 3, 3));
    test_iso2mesh('volshrink 3d ones', @savejson, vol1, '[[[0,0,1,1,1],[0,0,1,1,1],[1,1,1,1,1],[1,1,1,1,1]],[[0,0,1,1,1],[0,0,1,1,1],[1,1,1,1,1],[1,1,1,1,1]],[[0,0,1,1,1],[0,0,1,1,1],[1,1,1,1,1],[1,1,1,1,1]]]', 'NestArray', 1);
    test_iso2mesh('volshrink 3d 2x user mask', @savejson, volshrink(~vol1, 2, repmat([0 0 0; 0 1 0; 0 1 0], 1, 1, 3)), '[[[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]],[[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]],[[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]]', 'NestArray', 1);

    vol1 = volshrink([0 1 1 1; 0 1 1 1; 0 1 1 0]);
    mask = [0 0 1 1; 0 0 1 0; 0 0 0 0];
    test_iso2mesh('volshrink 2d', @savejson, all(vol1(:) == mask(:)), '[true]');
    test_iso2mesh('volshrink 2d 2x', @savejson, volshrink(vol1), '[[0,0,0,0],[0,0,0,0],[0,0,0,0]]');

    vol1 = volshrink((magic(10) > 20), 2, logical([0 1 0; 1 1 1; 0 1 1]));
    mask = [0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 1 1 1 1; 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 1 1 1 1; 0 0 0 0 0 1 1 1 1 1; 0 0 0 0 0 1 1 1 1 1; 0 0 0 0 1 1 1 1 1 1; 0 0 0 0 1 1 1 1 1 1];
    test_iso2mesh('volshrink 2d 2x user mask', @savejson, all(vol1(:) == mask(:)), '[true]');

    vol = zeros(30, 40, 50);
    vol(10:20, 20:35, 20:40) = 1;
    vol(13:18, 25:30, 25:30) = 0;
    vol(14:17, 26:28, 1:30) = 0;

    vol1 = volclose(vol, 2);
    test_iso2mesh('volclose 2x', @savejson, sum(vol1(:)), '[3566]');
    vol1 = volclose(vol, 4);
    test_iso2mesh('volclose 4x', @savejson, sum(vol1(:)), '[3682]');
    vol1 = volopen(volclose(vol, 2), 2);
    test_iso2mesh('volopen/volclose 2x', @savejson, sum(vol1(:)), '[2994]');
    vol1 = volclose(volopen(vol, 2), 2);
    test_iso2mesh('volopen/volclose 2x', @savejson, sum(vol1(:)), '[2604]');

    vol1 = fillholes3d(volclose(vol, 2));
    test_iso2mesh('fillholes3d + volclose', @savejson, sum(vol1(:)), '[3682]');

    vol1 = fillholes3d(vol, 2);
    test_iso2mesh('fillholes3d 2x', @savejson, sum(vol1(:)), '[3682]');

    vol1 = fillholes3d(vol, 1);
    test_iso2mesh('fillholes3d 1x', @savejson, sum(vol1(:)), '[3478]');

    vol1 = fillholes3d(vol, 5);
    test_iso2mesh('fillholes3d 5x', @savejson, sum(vol1(:)), '[4097]');

    vol1 = fillholes3d(vol, 4, permute(repmat([0 0 0; 0 1 0; 0 0 0], 1, 1, 3), [3 1 2]));
    test_iso2mesh('fillholes3d x-axis mask', @savejson, sum(vol1(:)), '[3696]');

    vol1 = fillholes3d(vol, 4, repmat([0 0 0; 0 1 0; 0 0 0], 1, 1, 3));
    test_iso2mesh('fillholes3d z-axis mask', @savejson, sum(vol1(:)), '[3682]');

    vol1 = laplacefill(volclose(vol, 2));
    test_iso2mesh('laplacefill', @savejson, sum(vol1(:)), '[3682]');

    vol1 = laplacefill(volclose(vol, 2), [], 'bicgstab', 1e-6);
    test_iso2mesh('laplacefill bicgstab', @savejson, sum(vol1(:)), '[3682]');

    vol1 = laplacefill(volclose(vol, 2), [2, 2, 2]);
    vol1 = (vol1 < 1e-10);
    test_iso2mesh('laplacefill close seed', @savejson, sum(vol1(:)), '[3682]');

    vol1 = laplacefill(vol, [2, 2, 2]);
    vol1 = (vol1 > 1e-10);
    test_iso2mesh('laplacefill open seed', @savejson, sum(vol1(:)), '[56580]');
end

%%
if (ismember('bugs', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test specific bug fixes\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    % meshreorient must swap node columns only, not a trailing region label
    no = [0 0 0; 1 0 0; 0 1 0; 0 0 1];
    negel = [1 2 3 4];
    if (elemvolume(no, negel, 'signed') > 0)
        negel = [1 3 2 4];
    end
    el1 = meshreorient(no, [negel 7]);
    test_iso2mesh('meshreorient keeps region label', @savejson, el1(5), '[7]');
    test_iso2mesh('meshreorient labeled elem is positive', @savejson, ...
                  elemvolume(no, el1(1:4), 'signed') > 0, '[true]');
    test_iso2mesh('meshreorient unlabeled elem is positive', @savejson, ...
                  elemvolume(no, meshreorient(no, negel), 'signed') > 0, '[true]');

    % uniqfaces/uniqedges must accept a plain triangle/edge list
    [no, fc, el] = meshabox([0 0 0], [1 1 1], 1);
    test_iso2mesh('uniqfaces of a triangle list', @savejson, ...
                  size(uniqfaces(fc(:, 1:3))), sprintf('[%d,3]', size(fc, 1)));
    test_iso2mesh('uniqedges of an edge list', @savejson, ...
                  uniqedges([1 2; 2 3; 3 1]), '[[1,2],[3,1],[2,3]]');

    % facedihedral's 2-input form must not error inside edgeneighbors
    test_iso2mesh('facedihedral 2-input form', @savejson, ...
                  size(facedihedral(no, fc(:, 1:3))), sprintf('[%d,3]', size(fc, 1)));

    % polylineinterp must not touch nodes when only 2 outputs are requested
    [pidx, pweight] = polylineinterp([2, 2, 1], 5);
    test_iso2mesh('polylineinterp at polyline end', @savejson, [pidx pweight], '[3,1]');

    % rotmat2vec must satisfy R*u*s=v for anti-parallel vectors
    [rmat, rs] = rotmat2vec([0 0 1], [0 0 -1]);
    test_iso2mesh('rotmat2vec anti-parallel', @savejson, ...
                  round_to_digits((rmat * [0; 0; 1] * rs)', 6), '[0,0,-1]');
    test_iso2mesh('rotmat2vec anti-parallel is a rotation', @savejson, ...
                  round_to_digits(det(rmat), 6), '[1]');
    test_iso2mesh('rotmat2vec parallel', @savejson, rotmat2vec([0 0 2], [0 0 5]), ...
                  '[[1,0,0],[0,1,0],[0,0,1]]');

    % sortmesh must return the face list together with nodemap
    [sno, sel, sfc, snodemap] = sortmesh([0 0 0], no, el(:, 1:4), 1:4, fc(:, 1:3), 1:3);
    test_iso2mesh('sortmesh 4-output form', @savejson, ...
                  [size(sfc, 1) length(snodemap)], sprintf('[%d,%d]', size(fc, 1), size(no, 1)));

    % savestl must not treat a labeled triangular surface as a tet mesh
    stlfile = mwpath('post_savestl_test.stl');
    deletemeshfile(stlfile);
    savestl(no, [fc(:, 1:3) ones(size(fc, 1), 1)], stlfile);
    test_iso2mesh('savestl of a labeled surface', @savejson, ...
                  length(strfind(fileread(stlfile), 'facet normal')), ...
                  sprintf('[%d]', size(fc, 1)));
    deletemeshfile(stlfile);

    % smoothsurf 'laplacianhc' must keep masked nodes fixed
    nconn = meshconn(fc(:, 1:3), size(no, 1));
    nmask = zeros(size(no, 1), 1);
    nmask(1:2:end) = 1;
    psm = smoothsurf(no, nmask, nconn, 3, 0.5, 'laplacianhc', 0.5);
    test_iso2mesh('smoothsurf laplacianhc honors mask', @savejson, ...
                  isequal(psm(nmask == 1, :), no(nmask == 1, :)), '[true]');
    test_iso2mesh('smoothsurf laplacianhc moves free nodes', @savejson, ...
                  any(any(abs(psm(nmask == 0, :) - no(nmask == 0, :)) > 1e-12)), '[true]');
end

%%
if (ismember('io', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test mesh file writers and readers\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    % a save/load round trip needs no external binary and checks the writer and
    % the reader against each other rather than against a stored byte pattern,
    % so unlike the golden values elsewhere in this file it does not have to be
    % updated when a mesher binary is rebuilt
    [no, fc, el] = meshabox([0 0 0], [1 1 1], 1);
    no = no(:, 1:3);
    fc = fc(:, 1:3);
    el = el(:, 1:4);

    fname = mwpath('post_iotest.off');
    deletemeshfile(fname);
    saveoff(no, fc, fname);
    [no2, fc2] = readoff(fname);
    test_iso2mesh('off round trip node', @savejson, round_to_digits(no2, 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('off round trip face', @savejson, fc2, savejson('', fc, 'compact', 1));
    deletemeshfile(fname);

    fname = mwpath('post_iotest.smf');
    deletemeshfile(fname);
    savesmf(no, fc, fname);
    [no2, fc2] = readsmf(fname);
    test_iso2mesh('smf round trip node', @savejson, round_to_digits(no2, 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('smf round trip face', @savejson, fc2, savejson('', fc, 'compact', 1));
    deletemeshfile(fname);

    fname = mwpath('post_iotest.asc');
    deletemeshfile(fname);
    saveasc(no, fc, fname);
    [no2, fc2] = readasc(fname);
    test_iso2mesh('asc round trip node', @savejson, round_to_digits(no2, 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('asc round trip face', @savejson, fc2, savejson('', fc, 'compact', 1));
    deletemeshfile(fname);

    % gts stores the surface as edges, so the triangles come back in a
    % different vertex order; compare them as unordered node sets
    fname = mwpath('post_iotest.gts');
    deletemeshfile(fname);
    savegts(no, fc, fname);
    [no2, fc2] = readgts(fname);
    test_iso2mesh('gts round trip node', @savejson, round_to_digits(no2, 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('gts round trip face', @savejson, sortrows(sort(fc2, 2)), savejson('', sortrows(sort(fc, 2)), 'compact', 1));
    deletemeshfile(fname);

    fname = mwpath('post_iotest.mesh');
    deletemeshfile(fname);
    savemedit(no, fc, el, fname);
    [no2, el2, fc2] = readmedit(fname);
    test_iso2mesh('medit round trip node', @savejson, round_to_digits(no2(:, 1:3), 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('medit round trip elem', @savejson, el2(:, 1:4), savejson('', el, 'compact', 1));
    test_iso2mesh('medit round trip face', @savejson, size(fc2, 1), sprintf('[%d]', size(fc, 1)));
    deletemeshfile(fname);

    fname = mwpath('post_iotest.jmsh');
    deletemeshfile(fname);
    savejmesh(no, fc, el, fname);
    jmsh = loadjmesh(fname);
    test_iso2mesh('jmesh round trip node', @savejson, round_to_digits(jmsh.MeshVertex3, 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('jmesh round trip tri', @savejson, jmsh.MeshTri3, savejson('', fc, 'compact', 1));
    test_iso2mesh('jmesh round trip tet', @savejson, jmsh.MeshTet4, savejson('', el, 'compact', 1));
    deletemeshfile(fname);

    % tetgen splits a mesh over .node/.ele/.face
    fstub = mwpath('post_iotest.1');
    deletemeshfile([fstub '.*']);
    savetetgennode(no, [fstub '.node']);
    savetetgenele([el ones(size(el, 1), 1)], [fstub '.ele']);
    savetetgenele([fc ones(size(fc, 1), 1)], [fstub '.face']);
    [no2, el2, fc2] = readtetgen(fstub);
    test_iso2mesh('tetgen round trip node', @savejson, round_to_digits(no2(:, 1:3), 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('tetgen round trip elem', @savejson, el2(:, 1:4), savejson('', el, 'compact', 1));
    test_iso2mesh('tetgen round trip face', @savejson, size(fc2, 1), sprintf('[%d]', size(fc, 1)));
    deletemeshfile([fstub '.*']);

    % nirfast writes a group of files sharing one stub
    fstub = mwpath('post_iotest_nirfast');
    deletemeshfile([fstub '.*']);
    savenirfast(no, el, fstub);
    nirfast = readnirfast(fstub);
    test_iso2mesh('nirfast round trip node', @savejson, round_to_digits(nirfast.nodes, 6), savejson('', round_to_digits(no, 6), 'compact', 1));
    test_iso2mesh('nirfast round trip elem', @savejson, nirfast.elements(:, 1:4), savejson('', el, 'compact', 1));
    deletemeshfile([fstub '.*']);

    % the writers without a matching reader must still produce a non-empty file
    fname = mwpath('post_iotest.stl');
    deletemeshfile(fname);
    savestl(no, fc, fname);
    stlinfo = dir(fname);
    test_iso2mesh('stl file is written', @savejson, stlinfo.bytes > 0, '[true]');
    test_iso2mesh('stl facet count', @savejson, length(strfind(fileread(fname), 'facet normal')), sprintf('[%d]', size(fc, 1)));
    deletemeshfile(fname);
end

%%
if (ismember('invariant', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test properties preserved by mesh operations\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    % these assert relationships rather than stored values, so they keep their
    % meaning when a mesher binary is rebuilt and its output shifts slightly
    [no, fc, el] = meshabox([0 0 0], [1 1 1], 1);
    no = no(:, 1:3);
    fc = fc(:, 1:3);
    el = el(:, 1:4);
    vol0 = sum(elemvolume(no, el));

    % the boundary of a tetrahedral mesh encloses the same volume as the sum of
    % its elements; this cross-checks surfvolume against elemvolume
    test_iso2mesh('boundary encloses element volume', @savejson, ...
                  abs(surfvolume(no, volface(el)) - vol0) < 1e-8, '[true]');

    % renumbering nodes must not change the geometry
    [no2, el2] = removedupnodes(no, el);
    test_iso2mesh('removedupnodes keeps volume', @savejson, ...
                  abs(sum(elemvolume(no2, el2)) - vol0) < 1e-8, '[true]');
    [no3, el3] = sortmesh([0 0 0], no, el, 1:4);
    test_iso2mesh('sortmesh keeps volume', @savejson, ...
                  abs(sum(elemvolume(no3, el3)) - vol0) < 1e-8, '[true]');
    test_iso2mesh('sortmesh keeps node count', @savejson, size(no3, 1), sprintf('[%d]', size(no, 1)));

    % reorientation must leave every element positive, and must be idempotent
    elflip = el;
    elflip(1:2:end, [3 4]) = elflip(1:2:end, [4 3]);
    elfix = meshreorient(no, elflip);
    test_iso2mesh('meshreorient makes volumes positive', @savejson, ...
                  all(elemvolume(no, elfix, 'signed') > 0), '[true]');
    test_iso2mesh('meshreorient is idempotent', @savejson, ...
                  isequal(meshreorient(no, elfix), elfix), '[true]');
    test_iso2mesh('meshreorient keeps volume', @savejson, ...
                  abs(sum(elemvolume(no, elfix)) - vol0) < 1e-8, '[true]');

    % a closed genus zero surface has Euler characteristic 2
    test_iso2mesh('box surface euler number', @savejson, mesheuler(fc), '[2]');
    [nos, fcs] = meshunitsphere(0.1);
    test_iso2mesh('sphere surface euler number', @savejson, mesheuler(fcs(:, 1:3)), '[2]');

    % every face of a closed surface is shared by exactly two triangles, so it
    % has no open edge
    test_iso2mesh('box surface has no open edge', @savejson, isempty(surfedge(fc)), '[true]');
    test_iso2mesh('tet mesh boundary has no open edge', @savejson, isempty(surfedge(volface(el))), '[true]');

    % the extracted boundary is exactly the surface it was built from
    test_iso2mesh('volface matches the input surface', @savejson, ...
                  isequal(sortrows(sort(volface(el), 2)), sortrows(sort(fc, 2))), '[true]');

    % scaling a mesh scales its volume by the cube of the factor
    test_iso2mesh('volume scales cubically', @savejson, ...
                  abs(sum(elemvolume(no * 2, el)) - 8 * vol0) < 1e-8, '[true]');

    % dropping unused nodes must not change the surface area
    area0 = sum(elemvolume(no, fc));
    [nor, fcr] = removeisolatednode(no, fc);
    test_iso2mesh('removeisolatednode keeps area', @savejson, ...
                  abs(sum(elemvolume(nor, fcr)) - area0) < 1e-8, '[true]');
end

%%
[total, failed, faillist] = test_iso2mesh('summary');

fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
fprintf('Totals: %d passed, %d failed, %d total\n', total - failed, failed, total);
fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

if (total == 0)
    error('no unit test was executed, please check the requested test categories');
end

if (failed > 0)
    failnames = sprintf('\n\t%s', faillist{:});
    error('%d of %d unit tests failed:%s', failed, total, failnames);
end
