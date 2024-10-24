function run_iso2mesh_test(tests)
%
% run_iso2mesh_test
%   or
% run_iso2mesh_test(tests)
% run_iso2mesh_test({'prim', 'utils', 'core', 'surf'})
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
%         'bugs': test specific bug fixes
%
% license:
%     GPL version 3, see LICENSE_{BSD,GPLv3}.txt files for details
%
% -- this function is part of Iso2Mesh toolbox (http://iso2mesh.sf.net/)
%

if (nargin == 0)
    tests = {'prim', 'utils', 'core', 'surf'};
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

    [no, fc, el] = meshunitsphere(0.1, 100);
    test_iso2mesh('meshunitsphere face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[12.5119]');
    test_iso2mesh('meshunitsphere elem', @savejson, round_to_digits(sum(elemvolume(no, el)), 4), '[4.1547]');

    [no, fc, el] = meshasphere([1, 1, 1], 2, 0.2, 100);
    test_iso2mesh('meshasphere face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[50.0476]');
    test_iso2mesh('meshasphere elem', @savejson, round_to_digits(sum(elemvolume(no, el)), 4), '[33.2376]');

    [no, el] = meshgrid5(1:2, -1:0, 2:3);
    test_iso2mesh('meshgrid5 elem', @savejson, sum(el), '[545,577,532,586]');
    test_iso2mesh('meshgrid5 elem(:,1)', @savejson, el(:, 4)', '[13,5,11,14,5,5,15,3,14,3,7,17,13,14,13,9,17,15,14,5,19,14,13,20,23,15,14,20,21,11,17,23,23,13,25,27,23,23,15,15]');

    [no, el] = meshgrid6(1:2, -1:0, 2:0.5:3);
    test_iso2mesh('meshgrid6', @savejson, el, '[[1,2,8,4],[5,6,12,8],[1,3,4,8],[5,7,8,12],[1,2,6,8],[5,6,10,12],[1,5,8,6],[5,9,12,10],[1,3,8,7],[5,7,12,11],[1,5,7,8],[5,9,11,12]]');

    [no, fc, el] = meshanellip([1, 1, 1], [2, 4, 1], 0.2, 100);
    test_iso2mesh('meshanellip face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[62.4487]');
    test_iso2mesh('meshanellip elem', @savejson, round_to_digits(sum(elemvolume(no, el(:, 1:4))), 4), '[32.5608]');

    [no, fc, el] = meshacylinder([1 1 1], [2 3 4], [10, 12], 0.1, 10);
    test_iso2mesh('meshacylinder face', @savejson, round_to_digits(sum(elemvolume(no, fc)), 4), '[1045.2322]');
    test_iso2mesh('meshacylinder elem', @savejson, round_to_digits(sum(elemvolume(no, el(:, 1:4))), 4), '[1402.8993]');

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

    test_iso2mesh('binsurface face', @savejson, fc, '[[10,4,1],[7,10,1],[12,6,5],[2,3,9],[11,5,4],[1,2,8],[11,12,5],[2,9,8],[10,11,4],[1,8,7],[8,9,12],[6,3,2],[7,8,11],[5,2,1],[8,12,11],[5,6,2],[7,11,10],[4,5,1]]');
    test_iso2mesh('binsurface node', @savejson, sum(no'), '[3,4,5,4,5,6,4,5,6,5,6,7]');
    test_iso2mesh('surfedge', @savejson, surfedge(fc), '[[6,3],[3,9],[12,6],[9,12]]');

    [no, fc] = binsurface(im, 4);
    test_iso2mesh('binsurface quad face', @savejson, fc, '[[1,3,7,5],[2,4,8,6],[5,7,11,9],[6,8,12,10],[1,2,6,5],[3,4,8,7],[5,6,10,9],[7,8,12,11],[1,2,4,3]]');

    no = binsurface(im, 0);
    test_iso2mesh('binsurface mask', @savejson, no, '{"_ArrayType_":"double","_ArraySize_":[2,2,2],"_ArrayData_":[0,0,0,0,0,0,-1,-1]}');

    [no, fc] = v2s(im, 0.5, 0.03);
    test_iso2mesh('v2s face', @savejson, round_to_digits(sum(elemvolume(no, fc(:, 1:3))), 4), '[5.0082]');

    [no, el, fc] = v2m(im, 0.5, 0.03, 10);
    test_iso2mesh('v2m face', @savejson, round_to_digits(sum(elemvolume(no, fc(:, 1:3))), 4), '[5.0082]');
    test_iso2mesh('v2m elem', @savejson, round_to_digits(sum(elemvolume(no, el(:, 1:4))), 4), '[0.8786]');
end
