load("S2_Data.mat", '-mat')

% change start and end index based on valid frame ranges
start_frame = 190;
end_frame = 260;
% Set target Id to TID being tracked in frame range, e.g. target being
% tracked
target_id = 0;
label = 1; % 1 as human, -1 as non human
offset = 5;
block_size = 30;

% # of rows in feature array is equal to 
% [(total # of frames) - blocksize] / offset
% where block size is 30, offset is 5
 
feature_arr_size = ((end_frame-start_frame) - block_size)/offset;
feature_arr = zeros(feature_arr_size, 5);

% block_count is used to insert feature vectors at correct locations in arr
block_index = 1;
% 5 frame offsets for calculating frame blocks
for frame_index = (start_frame+offset): 5: (end_frame - block_size)
   
    udCoM = zeros(1, block_size);
    udUpperEnv = zeros(1,block_size);
    udLowerEnv = zeros(1,block_size);
    
    % iterate over 30 frame blocks
    for blockCnt = 1:block_size
        frame_num = frame_index + blockCnt;     % Get frame number
        disp(frame_index)
        indx = find(fHist(frame_num).indexArray == target_id);     % Find index of valid points from TID
        currDoppler = fHist(frame_num).pointCloud(4, indx);     % Extract doppler 
        currPower = fHist(frame_num).pointCloud(5, indx);     % Extract SNR
        
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
    
    feature_arr(block_index, 1) = udBW;
    feature_arr(block_index, 2) = udOffset;
    feature_arr(block_index, 3) = udTorsoBW;
    feature_arr(block_index, 4) = udCenterMassAvg;
    feature_arr(block_index, 5) = udCenterMassStd;
    feature_arr(block_index, 6) = label;

    
    %feature_vector = [udBW udOffset udTorsoBW udCenterMassAvg udCenterMassStd]
    %feature_arr(block_index) = feature_vector;
    block_index = block_index + 1;
end

% append features to excel file with all the other features
xlsappend('extracted_features.xlsx',feature_arr,'Sheet 1')
%Citation: Brett Shoelson (2020). XLSAPPEND (https://www.mathworks.com/matlabcentral/fileexchange/28600-xlsappend), MATLAB Central File Exchange. Retrieved November 16, 2020.







