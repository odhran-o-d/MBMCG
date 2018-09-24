function params = readParamFile(file)

if ~exist(file, 'file')
    error('Experiment File Not Found. Check File Extension.')
end

fileID = fopen(file,'r');
formatSpec = '%[^= ]%*[= ]%[^;]%*s';
params = textscan(fileID, formatSpec, 'EndOfLine', '\n', 'CommentStyle', '%');
fclose(fileID);

end