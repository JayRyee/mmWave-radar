done = 0;

% Put the data input and output directory here
%%%%%%% EDIT THIS LINE %%%%%%
cd '~/class/ECE-480/ECE-480/Newdata'

while done == 0
    
    % prompt the user for the file to label
    filename = input('Enter the file you would like to label: ', 's');
    if strcmp(filename, 'done')
        done = 1;
        break;
    end
    
    % Load the data from file
    % if it fails here your file is wrong
    oldfile = load(filename, '-mat');
    
    % Prompt user for a list of all the human targets
    human = input('Enter the human targets for the data file: ');
    
    % Generate an array for all targets
    labels = zeros(256,1);
    for i = 1:length(human)
        target = human(i);
        labels(target+1) = 1;
    end
    
    % Save the file
    data = oldfile.fHist;
    % On windows
    %newfilename = strcat(pwd,'\','labeled_', filename);
    
    % On macos or linux
    newfilename = strcat(pwd,'/','labeled_', filename);
    
    save(newfilename, 'data', 'labels');
end
