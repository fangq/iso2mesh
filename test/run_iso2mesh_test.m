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
%         'bugs': test specific bug fixes
%
% license:
%     GPL version 3, see LICENSE_{BSD,GPLv3}.txt files for details
%
% -- this function is part of Iso2Mesh toolbox (http://iso2mesh.sf.net/)
%

if (nargin == 0)
    tests = {'prim', 'utils', 'core', 'surf', 'bool', 'vol'};
end

%%
if (ismember('prim', tests))
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));
    fprintf('Test primitive meshing functions\n');
    fprintf(sprintf('%s\n', char(ones(1, 79) * 61)));

    [no, fc, el] = meshabox([0 0 0], [1 1 1], 1);
    test_iso2mesh('meshabox face', @savejson, fc, '[[9,2,1],[2,10,1],[9,1,10],[2,9,12],[11,10,2],[2,12,11],[12,13,3],[14,12,3],[14,3,13],[8,4,9],[4,8,13],[4,13,9],[15,10,5],[10,16,5],[15,5,16],[7,6,14],[7,16,6],[14,6,11],[16,11,6],[14,8,7],[15,7,8],[15,16,7],[15,8,9],[13,8,14],[15,9,10],[13,12,9],[10,11,16],[14,11,12]]');
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

    test_iso2mesh('removeisolatednode', @savejson, round_to_digits(mean(removeisolatednode(no, fc)), 4), '[1.44,1.8799,2.3198]');
    test_iso2mesh('meshreorient', @savejson, all(meshreorient(no, el(:, [1, 2, 4, 3])) == el(:, 1:4)), '[1,1,1,1]');

    el1 = el;
    el1(el(:, 1:4) < 2) = size(no, 1) + el1(el(:, 1:4) < 2);

    test_iso2mesh('removedupnodes', @savejson, round_to_digits(mean(removedupnodes([no; no(1:2, :)], el1(:, 1:4))), 5), '[1.43802,1.87576,2.31368]');
    test_iso2mesh('removedupelem', @savejson, removedupelem([el(:, 1:4); el(1:end - 5, 1:4)]), '[[47,34,53,45],[47,45,53,25],[25,45,53,46],[34,43,53,32],[32,43,53,28]]');

    [no1, fc1] = surfreorient(no, fc);

    test_iso2mesh('surfreorient', @savejson, size(no1), '[50,3]');
    test_iso2mesh('surfreorient face', @savejson, any(elemvolume(no1, fc1) <= 0), '[false]');

    [no1, fc1] = meshcheckrepair(no, fc, 'deep');

    test_iso2mesh('meshcheckrepair deep node', @savejson, size(no1), '[50,3]');
    test_iso2mesh('meshcheckrepair deep face', @savejson, any(elemvolume(no1, fc1) <= 0), '[false]');

    [no2, fc2] = meshcheckrepair(no1, fc1(5:end, :), 'meshfix');

    test_iso2mesh('meshcheckrepair face', @savejson, abs(sum(elemvolume(no1, fc1)) - sum(elemvolume(no2, fc2))) < 1e-8, '[true]');

    [no2, fc2] = meshresample(no1, fc1, 0.1);
    [no1, el1] = s2m(no2, fc2, 1, 100);

    test_iso2mesh('meshresample', @savejson, round_to_digits(no2, 4), '[[1.1003,1.12,2.0523],[1.2139,2.26,3.0045],[1.2466,1.5028,1.5301],[1.7892,3.1657,3.9598],[1.7951,2.6816,2.5312],[2.0394,1.9501,2.9362]]');
    test_iso2mesh('meshresample with s2m node', @savejson, round_to_digits(no1, 4), '[[1.1003,1.12,2.0523],[1.2139,2.26,3.0045],[1.2466,1.5028,1.5301],[1.7892,3.1657,3.9598],[1.7951,2.6816,2.5312],[2.0394,1.9501,2.9362]]');
    test_iso2mesh('meshresample with s2m elem', @savejson, el1, '[[6,2,1,3,0],[5,2,4,6,0],[2,6,5,3,0]]');

    [no1, el1] = meshrefine(no, el, fc, [0, 0, 0; 2, 3, 5]);

    test_iso2mesh('meshrefine insert node outside', @savejson, size(no1) == size(no), '[1,1]');
    test_iso2mesh('meshrefine insert node outside elem', @savejson, size(el1) == size(el), '[1,1]');

    [no2, el2] = mergemesh(no, el, no1, el1);
    [no1, el1] = removedupnodes(no2, el2(:, 1:4), 1e-6);
    el2 = unique(sort(el1')', 'rows');
    test_iso2mesh('mergemesh removedupnodes', @savejson, size(no1) == size(no), '[1,1]');
    test_iso2mesh('mergemesh removedupelem', @savejson, size(el2, 1) == size(el, 1), '[true]');

    [no1, el1, fc1] = meshrefine(no, el, fc, [[1 1 1] + 0.01; [2, 3, 4] - 0.01]);
    test_iso2mesh('meshrefine insert node', @savejson, size(no1) - size(no), '[2,0]');
    test_iso2mesh('meshrefine insert node elem', @savejson, size(el1) - size(el), '[16,0]');
    test_iso2mesh('meshrefine insert node face', @savejson, size(fc1) - size(fc), '[0,1]');

    [no1, el1, fc1] = meshrefine(no, el, fc, ones(size(no, 1), 1) * 0.5);
    test_iso2mesh('meshrefine node sizefield node', @savejson, size(no1) - size(no), '[24,0]');
    test_iso2mesh('meshrefine node sizefield elem', @savejson, size(el1) - size(el), '[76,0]');
    test_iso2mesh('meshrefine node sizefield face', @savejson, size(fc1) - size(fc), '[48,1]');

    [no1, el1, fc1] = meshrefine(no, el, ones(size(el, 1), 1) * 0.02);
    test_iso2mesh('meshrefine elem sizefield node', @savejson, size(no1) - size(no), '[34,0]');
    test_iso2mesh('meshrefine elem sizefield elem', @savejson, size(el1) - size(el), '[105,0]');
    test_iso2mesh('meshrefine elem sizefield face', @savejson, size(fc1) - size(fc), '[64,1]');

    [no1, el1, fc1] = meshrefine(no, el, struct('maxvol', 0.02));
    test_iso2mesh('meshrefine elem sizefield node', @savejson, size(no1) - size(no), '[34,0]');
    test_iso2mesh('meshrefine elem sizefield elem', @savejson, size(el1) - size(el), '[105,0]');
    test_iso2mesh('meshrefine elem sizefield face', @savejson, size(fc1) - size(fc), '[64,1]');

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
