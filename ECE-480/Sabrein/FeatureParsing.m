function result = FeautureParsing(filename)   
    load("S2_Data.mat", '-mat')

    human  =  [0 3 4 6 7] ;

    % Since matlab indexes from 1, array indice 1 is target 0 and so on
    targets_list = zeros(1,256);
    for item = 1:length(human)
        targets_list(human(item) + 1) = 1;
    end



    % Pull out important data for each index

    for current_target_in  = 1:length(targets_list)
        % current_target_in is the index into the array
        % current_target is the target id with respect to the data
        current_target = current_target_in - 1;

    end
    % Cell array for storing the resultant data vectors
    targets_data = cell(1,256);

    data_size = length(fHist);
    for frame_index = 1:data_size 
        %check if indexArray available at this index, if not move on to next
        %index
        if isempty(fHist(frame_index).indexArray)
            continue
        else
            % Get a list of all (with valid target ID) the indexes present in this frame
            if (unique(fHist(frame_index).indexArray)< 249)
                index_set = unique(fHist(frame_index).indexArray);
            else
                continue;
            end
        end
        for i = 1:length(index_set)
            current_index = index_set(i);
            % For each valid index, pull out the valid data and add it to the
            % valid data cell array
            arr = (fHist(frame_index).indexArray);
            indx = find(abs(arr - current_index) == 0);
            %indx = find(fHist(frame_number).indexArray == current_index);
            currDoppler = fHist(frame_index).pointCloud(4, indx);     % Extract doppler 
            currPower = fHist(frame_index).pointCloud(5, indx);     % Extract SNR

            % CoM - Center of Mass
            udCoM = sum(currPower.*currDoppler)/sum(currPower);
            %disp('gaming')
            %disp(current_index);
            if ~isnan(udCoM)
                % Only continue if the data is valid
                udUpperEnv = max(currDoppler - udCoM);
                udLowerEnv = min(currDoppler - udCoM);
                data = [udCoM, udUpperEnv, udLowerEnv];
                if length(targets_data{current_index + 1}) == 0
                    % Just assign the cell array
                    targets_data{current_index + 1} = data;
                else 
                    % Get the existing array, append the new data, and put it back
                    olddata = targets_data{current_index + 1};
                    newmatrix = [olddata; data];
                    targets_data{current_index + 1} = newmatrix;
                end

            end


        end
    end

    targets_data{1}
    stepsize = 1;
    windowsize = 20;
    bigarray = zeros(1,5);
    labelarray = 0
    for current_target_index = 1:240
        num_frames = length(targets_data{current_target_index});
        if num_frames == 0
            continue
        end
        % For each valid array index, compute all the cool stuff and add it to
        % the end of the big data list
        current_target = current_target_index - 1;
        data = targets_data{current_target_index};
        ishuman = targets_list(current_target_index);
        for data_index = 1:stepsize:(num_frames - windowsize)
            udCoM = data(data_index:(data_index + windowsize),1);
            udUpperEnv = data(data_index:(data_index + windowsize),2);
            udLowerEnv = data(data_index:(data_index + windowsize),3);
            % Actual features used
            udBW = max(udUpperEnv) - min(udLowerEnv);
            udOffset = mean(udUpperEnv) - mean(udLowerEnv);
            udTorsoBW = min(udUpperEnv) - max(udLowerEnv);
            udCenterMassAvg = mean(udCoM);
            udCenterMassStd = std(udCoM);
            newdata = [udBW udOffset udTorsoBW udCenterMassAvg udCenterMassStd];
            %Probably isnt required anymore
            if isnan(newdata)
                continue
            end

            if bigarray(1) == [0 0 0 0 0]
                % replace
                bigarray = newdata;
                labelarray = ishuman;
            else
                % add
                bigarray = [bigarray; newdata];
                labelarray = [labelarray ishuman];
            end
        end


    end

    % actually generate the svm
    svm = fitcsvm(bigarray, labelarray)



    w = load('S2_Data.mat'); % in this data target 0 is human but target 3 is not...
    % Test the svm against some of the data in this datastructure
    udCoM = zeros(1, 20);
    udUpperEnv = zeros(1,20);
    udLowerEnv = zeros(1,20);
    % iterate over 30 frame blocks
    for blockCnt = 200:219
        frame_num = blockCnt;     % Get frame number
        w.fHist(frame_num).indexArray;
        indx = find(w.fHist(frame_num).indexArray == 0);    % Find index of valid points from TID
        currDoppler = w.fHist(frame_num).pointCloud(4, indx);     % Extract doppler 
        currPower = w.fHist(frame_num).pointCloud(5, indx);     % Extract SNR

        % CoM - Center of Mass
        udCoM(blockCnt) = sum(currPower.*currDoppler)/sum(currPower);
        udUpperEnv(blockCnt) = max(currDoppler - udCoM(blockCnt));
        udLowerEnv(blockCnt) = min(currDoppler - udCoM(blockCnt));

    end
    % Now extract features from the 30 frame block
    udBW = max(udUpperEnv) - min(udLowerEnv);
    udOffset = mean(udUpperEnv) - mean(udLowerEnv);
    udTorsoBW = min(udUpperEnv) - max(udLowerEnv);
    udCenterMassAvg = mean(udCoM);
    udCenterMassStd = std(udCoM);

    a = [udBW udOffset udTorsoBW udCenterMassAvg udCenterMassStd]

    human = predict(svm,a)

    % Try again with some noise
    udCoM = zeros(1, 20);
    udUpperEnv = zeros(1,20);
    udLowerEnv = zeros(1,20);
    % iterate over 30 frame blocks
    for blockCnt = 300:317
        frame_num = blockCnt;     % Get frame number
        w.fHist(frame_num).indexArray;
        indx = find(w.fHist(frame_num).indexArray == 3);    % Find index of valid points from TID
        currDoppler = w.fHist(frame_num).pointCloud(4, indx);     % Extract doppler 
        currPower = w.fHist(frame_num).pointCloud(5, indx);     % Extract SNR

        % CoM - Center of Mass
        udCoM(blockCnt) = sum(currPower.*currDoppler)/sum(currPower);
        udUpperEnv(blockCnt) = max(currDoppler - udCoM(blockCnt));
        udLowerEnv(blockCnt) = min(currDoppler - udCoM(blockCnt));

    end
    % Now extract features from the 30 frame block
    udBW = max(udUpperEnv) - min(udLowerEnv);
    udOffset = mean(udUpperEnv) - mean(udLowerEnv);
    udTorsoBW = min(udUpperEnv) - max(udLowerEnv);
    udCenterMassAvg = mean(udCoM);
    udCenterMassStd = std(udCoM);

    b = [udBW udOffset udTorsoBW udCenterMassAvg udCenterMassStd]

    reflection = predict(svm,b)

    result = 0;

end


%fix empty indx variable bug
%SVM
%feature_arr
%label_arr
%SVMModel = fitcsvm(feature_arr,label_arr)

%SVMModel.ClassNames

%sv = SVMModel.SupportVectors
%figure
%gscatter(feature_arr(:,1),feature_arr(:,2),label_arr)
%hold on
%plot(sv(:,1),sv(:,2),'ko','MarkerSize',10)
%legend('Properties', 'Methods', 'Support Vector')
%hold off
%append to excel file 
% append features to excel file with all the other features
%xlsappend('extracted_features.xlsx',feature_arr,'Sheet 1')
%these might be the wrong variables
%Citation: Brett Shoelson (2020). XLSAPPEND (https://www.mathworks.com/matlabcentral/fileexchange/28600-xlsappend), MATLAB Central File Exchange. Retrieved November 16, 2020.











