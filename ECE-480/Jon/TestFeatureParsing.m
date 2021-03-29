cd '~/class/ECE-480/ECE-480/Newdata'
% MASTER FILES LIST
% files = {
% 'labeled_a1_data.mat',  'labeled_a5_data.mat',  'labeled_b1_data.mat',  'labeled_b5_data.mat',  'labeled_b9_data.mat',  'labeled_c4_data.mat',  'labeled_d3_data.mat', ...
% 'labeled_a2_data.mat',  'labeled_a6_data.mat',  'labeled_b2_data.mat',  'labeled_b6_data.mat',  'labeled_c1_data.mat',  'labeled_c5_data.mat',  'labeled_d4_data.mat', ...
% 'labeled_a3_data.mat',  'labeled_a7_data.mat',  'labeled_b3_data.mat',  'labeled_b7_data.mat',  'labeled_c2_data.mat',  'labeled_d1_data.mat',  'labeled_d5_data.mat', ...
% 'labeled_a4_data.mat',  'labeled_a8_data.mat',  'labeled_b4_data.mat',  'labeled_b8_data.mat',  'labeled_c3_data.mat',  'labeled_d2_data.mat',  'labeled_d6_data.mat'};
files = {
'labeled_a1_data.mat',  'labeled_a5_data.mat',  'labeled_b1_data.mat',  'labeled_b5_data.mat',  'labeled_b9_data.mat',  'labeled_d3_data.mat', ...
'labeled_a2_data.mat',  'labeled_a6_data.mat',  'labeled_b2_data.mat',  'labeled_c1_data.mat',  'labeled_c4_data.mat', ...
'labeled_a3_data.mat',  'labeled_b3_data.mat',  'labeled_b7_data.mat',  'labeled_c2_data.mat',  'labeled_d1_data.mat',  'labeled_d5_data.mat', ...
'labeled_a4_data.mat',  'labeled_a8_data.mat',  'labeled_b4_data.mat',  'labeled_b8_data.mat',  'labeled_c3_data.mat',  'labeled_d2_data.mat',  'labeled_d6_data.mat'};
bigarray = zeros(1,5);
labels = 0;
for i = 1:length(files)
    stuff = FeatureParsing(files{i});
    stuff{1};
    stuff{2};
    if bigarray(1) == [0 0 0 0 0]
        % replace
        bigarray = stuff{1};
        labels = stuff{2};
    else
        % add
        bigarray = [bigarray; stuff{1}];
        labels = [labels stuff{2}];
    end
end


% fitcsvm linear
%svm = fitcsvm(bigarray, labels)

% fitckernel
%svm = fitckernel(bigarray, labels)

% fitcsvm rbf
%svm = fitcsvm(bigarray, labels, 'KernelFunction','rbf')

% These are able to do multiclass, simply add more labeles to the data to
% perform multiclass classification
% ECOC
%svm = fitcecoc(bigarray, labels)
% KNN
%svm = fitcknn(bigarray, labels) 

%save('svm.mat', 'svm', 'files');

%file2 = 'labeled_S2_Data.mat';
%file2s = { 'labeled_a7_data.mat', 'labeled_b6_data.mat', 'labeled_c4_data.mat', 'labeled_d4_data.mat'};
%file2s = { 'labeled_b6_data.mat'}
%posdata = [];
%negdata = [];
%correct = [];
%alllabels = [];
%correct = zeros(length(test_data))
% for c = 1:length(file2s);
%     test_cont = FeatureParsingInfo(file2s{c});
%     test_data = test_cont{1};
%     test_labels = test_cont{2};
    %guesses = zeros(length(test_data),1);
%     for w = 1:length(test_data)
%         [guess, score, test] = predict(svm,test_data(w, :));
%         realscore = test;
%         label = test_labels(w);
%         if label == 1
%             posdata = [posdata, realscore];
%         elseif label == 0
%             % False Negative
%             negdata = [negdata, realscore];
%         end
%     end
    
%     [AP, h] = prCurve(posdata, negdata, '-b')
%     posdata = [];
%     negdata = [];
    
%     for w = 1:length(test_data)
%         guess = predict(svm,test_data(w,:));
%         is_correct = test_labels(w) == guess;
%         correct = [correct, is_correct];
%     end
%     alllabels = [alllabels, test_labels];
% end
% mean(correct)
%mean(alllabels)
% [AP, h] = prCurve(posdata, negdata, '-b')
% xlim([0 1])
% ylim([0 1])



test_file = 'labeled_c5_data.mat';

test_cont = FeatureParsingInfo(test_file);
test_data = test_cont{1};
test_labels = test_cont{2};
test_targets = test_cont{3};
test_target_labels = test_cont{4};
guess_labels = predict(svm, test_data(:,:));

unique_targets = unique(test_targets)
%unique_targets = [2,3];
output = []
for i = 1:length(unique_targets)
    target = unique_targets(i);
    correct = [];
    for j = 1:length(test_data)
        if (test_targets(j) == target)
            correct = [correct, test_labels(j) == guess_labels(j)];
        end
    end

        target;
        avg = mean(correct);
        human = test_target_labels(target+1);
        output = [output; target, avg, human]; 

       
end
collab = {'Target ID', 'Accuracy', 'Human'};
sTable = array2table(output,'VariableNames',collab)





%AP = prCurve(posdata, negdata, {})
%matrix;
%b = array2table(matrix, 'RowNames', file2s, 'VariableNames', {'Precision', 'Recall'})
% stuff2 = FeatureParsingInfo(file2);
% test_data = stuff2{1};
% test_labels = stuff2{2};
% display = zeros(length(test_data),2);
% display(:,1) = test_labels(:);
% correct = zeros(length(test_data),1);




