function result = FeautureParsing(filename)   
    file = load(filename, '-mat');

    targets_list = file.labels;

    % Pull out important data for each index
    % Cell array for storing the resultant data vectors
    targets_data = cell(1,256);

    data_size = length(file.data);
    for frame_index = 1:data_size 
        %check if indexArray available at this index, if not move on to next
        %index
        if isempty(file.data(frame_index).indexArray)
            continue
        else
            % Get a list of all (with valid target ID) the indexes present in this frame
            if (unique(file.data(frame_index).indexArray)< 249)
                index_set = unique(file.data(frame_index).indexArray);
            else
                continue;
            end
        end
        for i = 1:length(index_set)
            current_index = index_set(i);
            % For each valid index, pull out the valid data and add it to the
            % valid data cell array
            arr = (file.data(frame_index).indexArray);
            indx = find(abs(arr - current_index) == 0);
            %indx = find(fHist(frame_number).indexArray == current_index);
            if(length(file.data(frame_index).pointCloud(4,:)) < length(indx))
                % Somehow the list of valid indexes is longer than the
                % actual number of datapoints??????
                continue;
            end
            currDoppler = file.data(frame_index).pointCloud(4, indx);     % Extract doppler 
            currPower = file.data(frame_index).pointCloud(5, indx);     % Extract SNR

            % CoM - Center of Mass
            udCoM = sum(currPower.*currDoppler)/sum(currPower);
            if ~isnan(udCoM)
                % Only continue if the data is valid
                udUpperEnv = max(currDoppler - udCoM);
                udLowerEnv = min(currDoppler - udCoM);
                data = [udCoM, udUpperEnv, udLowerEnv];
                if isempty(targets_data{current_index + 1})
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
    
    stepsize = 1;
    windowsize = 20;
    bigarray = zeros(1,5);
    labelarray = 0;
    bigarray = [];
    labelarray = [];
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
        if num_frames < windowsize && num_frames > 4
            udCoM = data(1:num_frames,1);
            udUpperEnv = data(1:num_frames,2);
            udLowerEnv = data(1:num_frames,3);
            % Actual features used
            udBW = max(udUpperEnv) - min(udLowerEnv);
            udOffset = mean(udUpperEnv) - mean(udLowerEnv);
            udTorsoBW = min(udUpperEnv) - max(udLowerEnv);
            %udTorsoBW = max(udUpperEnv) - min(udLowerEnv);
            udCenterMassAvg = mean(udCoM);
            udCenterMassStd = std(udCoM);
            newdata = [udBW udOffset udTorsoBW udCenterMassAvg udCenterMassStd];
            %Probably isnt required anymore
            if isnan(newdata)
                continue
            end
            bigarray = [bigarray; newdata];
            labelarray = [labelarray ishuman];
        end
            
        for data_index = 1:stepsize:(num_frames - windowsize)
            udCoM = data(data_index:(data_index + windowsize),1);
            udUpperEnv = data(data_index:(data_index + windowsize),2);
            udLowerEnv = data(data_index:(data_index + windowsize),3);
            % Actual features used
            udBW = max(udUpperEnv) - min(udLowerEnv);
            udOffset = mean(udUpperEnv) - mean(udLowerEnv);
            %udTorsoBW = min(udUpperEnv) - max(udLowerEnv);
            udTorsoBW = max(udUpperEnv) - min(udLowerEnv);
            udCenterMassAvg = mean(udCoM);
            udCenterMassStd = std(udCoM);
            newdata = [udBW udOffset udTorsoBW udCenterMassAvg udCenterMassStd];
            %Probably isnt required anymore
            if isnan(newdata)
                continue
            end
            bigarray = [bigarray; newdata];
            labelarray = [labelarray ishuman];
        end
    end
    result = {bigarray, labelarray};
end
