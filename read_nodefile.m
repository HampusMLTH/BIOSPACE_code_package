function [exp_time,gain,binning] = read_nodefile(folder_name)
%READ_NODEFILE returns exp_time, gain and binning used by a Basler camera

nodefile = dir(fullfile(folder_name,'*.pfs'));
nodefile_name = nodefile.name;
nodefile = readmatrix([folder_name '\' nodefile_name], 'FileType', 'text', 'Delimiter', '\t', 'NumHeaderLines', 3, 'OutputType','string');
exp_time = str2num(nodefile(find(strcmp([nodefile(:,1)],'ExposureTime')),2))/1000;
gain = str2num(nodefile(find(strcmp([nodefile(:,1)],'Gain')),2));
binning = str2num(nodefile(find(strcmp([nodefile(:,1)],'BinningHorizontal')),2));
end

