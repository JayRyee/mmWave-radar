function exit = begin()
filename = input('Enter filename: ');
FeautureParsing(filename);
fprintf('Post feature parsing');
exit = 0;
end

%automate to keep asking for filenames until user types "exit"