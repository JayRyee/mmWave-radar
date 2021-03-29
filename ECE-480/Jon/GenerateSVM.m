% Example data folder.  Replace with your data folders location
datafolder = './data';
addpath(datafolder);

% MASTER FILES LIST
% Remove a few files from this list when training to save some data for
% testing and validation
% files = {
% 'labeled_a1_data.mat',  'labeled_a5_data.mat',  'labeled_b1_data.mat',  'labeled_b5_data.mat',  'labeled_b9_data.mat',  'labeled_c4_data.mat',  'labeled_d3_data.mat', ...
% 'labeled_a2_data.mat',  'labeled_a6_data.mat',  'labeled_b2_data.mat',  'labeled_b6_data.mat',  'labeled_c1_data.mat',  'labeled_c5_data.mat',  'labeled_d4_data.mat', ...
% 'labeled_a3_data.mat',  'labeled_a7_data.mat',  'labeled_b3_data.mat',  'labeled_b7_data.mat',  'labeled_c2_data.mat',  'labeled_d1_data.mat',  'labeled_d5_data.mat', ...
% 'labeled_a4_data.mat',  'labeled_a8_data.mat',  'labeled_b4_data.mat',  'labeled_b8_data.mat',  'labeled_c3_data.mat',  'labeled_d2_data.mat',  'labeled_d6_data.mat'};

% Our selected training data
files = {
'labeled_a1_data.mat',  'labeled_a5_data.mat',  'labeled_b1_data.mat',  'labeled_b5_data.mat',  'labeled_b9_data.mat',  'labeled_d3_data.mat', ...
'labeled_a2_data.mat',  'labeled_a6_data.mat',  'labeled_b2_data.mat',  'labeled_c1_data.mat',  'labeled_c4_data.mat', ...
'labeled_a3_data.mat',  'labeled_b3_data.mat',  'labeled_b7_data.mat',  'labeled_c2_data.mat',  'labeled_d1_data.mat',  'labeled_d5_data.mat', ...
'labeled_a4_data.mat',  'labeled_a8_data.mat',  'labeled_b4_data.mat',  'labeled_b8_data.mat',  'labeled_c3_data.mat',  'labeled_d2_data.mat',  'labeled_d6_data.mat'};

bigarray = [];
labels = [];
for i = 1:length(files)
    output = FeatureParsing(files{i});
    bigarray = [bigarray; output{1}];
    labels = [labels output{2}];
end

% Different possible classifiers.  Hyperparameter optimization may be
% useful

% fitcsvm linear
%svm = fitcsvm(bigarray, labels)

% fitckernel
%svm = fitckernel(bigarray, labels)

% fitcsvm rbf
svm = fitcsvm(bigarray, labels, 'KernelFunction','rbf')

% These are able to do multiclass, simply add more labeles to the data to
% perform multiclass classification
% ECOC
%svm = fitcecoc(bigarray, labels)
% KNN
%svm = fitcknn(bigarray, labels) 

% Save classifier to file
save('svm.mat', 'svm', 'files');


