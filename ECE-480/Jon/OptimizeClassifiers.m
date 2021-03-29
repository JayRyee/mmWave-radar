cd('/home/master93/class/ECE-480')
addpath('Evan')
addpath('Newdata')
%cd '~/class/ECE-480/Newdata'
% MASTER FILES LIST
% files = {
% 'labeled_a1_data.mat',  'labeled_a5_data.mat',  'labeled_b1_data.mat',  'labeled_b5_data.mat',  'labeled_b9_data.mat',  'labeled_c4_data.mat',  'labeled_d3_data.mat', ...
% 'labeled_a2_data.mat',  'labeled_a6_data.mat',  'labeled_b2_data.mat',  'labeled_b6_data.mat',  'labeled_c1_data.mat',  'labeled_c5_data.mat',  'labeled_d4_data.mat', ...
% 'labeled_a3_data.mat',  'labeled_a7_data.mat',  'labeled_b3_data.mat',  'labeled_b7_data.mat',  'labeled_c2_data.mat',  'labeled_d1_data.mat',  'labeled_d5_data.mat', ...
% 'labeled_a4_data.mat',  'labeled_a8_data.mat',  'labeled_b4_data.mat',  'labeled_b8_data.mat',  'labeled_c3_data.mat',  'labeled_d2_data.mat',  'labeled_d6_data.mat'};
files = {
'labeled_a1_data.mat',  'labeled_a5_data.mat',  'labeled_b1_data.mat',  'labeled_b5_data.mat',  'labeled_b9_data.mat',  'labeled_d3_data.mat', ...
'labeled_a2_data.mat',  'labeled_a6_data.mat',  'labeled_b2_data.mat',  'labeled_c1_data.mat',  'labeled_c5_data.mat', ...
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

%cd '~/class/ECE-480/ClassifierTests'
%Train the classifier
% Different classifiers, uncomment below!!!
% 'OptimizeHyperparameters','auto',...
%    'HyperparameterOptimizationOptions',...
%    struct('AcquisitionFunctionName','expected-improvement-plus'))


% Linear
%[Mdl,FitInfo,HyperparameterOptimizationResults] = fitcsvm(bigarray, labels, 'OptimizeHyperparameters','auto',...
%   'HyperparameterOptimizationOptions',...
%   struct('AcquisitionFunctionName','expected-improvement-plus'))


% No idea what this is, but it works #2 overall, .82 AP Gaussian
% [Mdl,FitInfo,HyperparameterOptimizationResults] = fitckernel(bigarray, labels, 'OptimizeHyperparameters','auto',...
%   'HyperparameterOptimizationOptions',...
%   struct('AcquisitionFunctionName','expected-improvement-plus'))

% EoC
%[Mdl] = fitcecoc(bigarray, labels, 'OptimizeHyperparameters','auto',...
%   'HyperparameterOptimizationOptions',...
%   struct('AcquisitionFunctionName','expected-improvement-plus'))

% The absolute clasic RBF function, .84 AP
%[Mdl,FitInfo,HyperparameterOptimizationResults] = fitcsvm(bigarray, labels, 'KernelFunction','rbf', 'OptimizeHyperparameters','auto',...
%   'HyperparameterOptimizationOptions',...
%   struct('AcquisitionFunctionName','expected-improvement-plus'))

% KNN BABY
[Mdl] = fitcknn(bigarray, labels, 'OptimizeHyperparameters','auto',...
   'HyperparameterOptimizationOptions',...
   struct('AcquisitionFunctionName','expected-improvement-plus'))

%save('svm.mat', 'svm', 'files');

%save('CT/Test.mat', 'bigarray');
save('CT/EoC.mat','Mdl')

cd '~/class/ECE-480/Newdata'
%file2 = 'labeled_S2_Data.mat';
file2s = { 'labeled_a7_data.mat', 'labeled_b6_data.mat', 'labeled_c4_data.mat', 'labeled_d4_data.mat', 'labeled_S2_Data.mat'};
%file2s = { 'labeled_b6_data.mat'}
posdata = [];
negdata = [];
for c = 1:length(file2s);
    test_cont = FeatureParsing(file2s{c});
    test_data = test_cont{1};
    test_labels = test_cont{2};
    %guesses = zeros(length(test_data),1);
    for w = 1:length(test_data)
        [guess, score] = predict(Mdl,test_data(w, :));
        
        label = test_labels(w);
        if label == 1
            posdata = [posdata, score(2)];
        elseif label == 0
            % False Negative
            negdata = [negdata, score(2)];
        end
    end
%     [AP, h] = prCurve(posdata, negdata, '-b')
%     posdata = [];
%     negdata = [];
end
%[AP, h] = prCurve(posdata, negdata, '-b')
AP = prCurve(posdata, negdata, {})
%matrix;
%b = array2table(matrix, 'RowNames', file2s, 'VariableNames', {'Precision', 'Recall'})
% stuff2 = FeatureParsingInfo(file2);
% test_data = stuff2{1};
% test_labels = stuff2{2};
% display = zeros(length(test_data),2);
% display(:,1) = test_labels(:);
% correct = zeros(length(test_data),1);



%guesses = zeros(length(test_data),1);
% for j = 1:length(test_data)
%     % Get frame from data
%     frame = test_data(j,:);
%     label = test_labels(j);
%     
%     %check this aganst the svm
%     [guess, other] = predict(svm, frame);
%     guesses(j) = guess;
%     display(j, 2) = guess;
%     %display(j, 3) = other; 
%     %someone find a better way to do this
%     
%     if guess == label
%         correct(j) = 1;
%     else 
%         correct(j) = 0;
%     end
% end
% names = {'Correct', 'Guess'} ;
%T = table(names(:); display);
%T = array2table(display,'VariableNames', names)


%percent_correct = mean(correct)

% tp = 0;
% tn = 0;
% fp = 0;
% fn = 0;
% for w = 1:length(guesses)
%     guess = guesses(w);
%     label = test_labels(w);
%     if guess == 1 && label == 1
%         % True positive
%         tp = tp + 1;
%     elseif guess == 0 && label == 1
%         % False Negative
%         fn = fn + 1;
%         
%     elseif guess == 1 && label == 0
%         % False Positive
%         fp = fp + 1;
%     else
%         % True negative
%         tn = tn + 1;
%     end
%     
% end
% 
% precision = tp/(tp+fp)
% recall = tp/(tp+fn)
    

