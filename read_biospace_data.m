function [biospace_data] = read_biospace_data(folder_name, reference,flatfield_shape)
%READ_BIOSPACE_DATA returns a struct with data from the input folder containing a BIOSPACE measurement 
% the struct also contains information of regarding the data such as how
% many angles of scatter, yaw, roll, and polarization it uses.
% the order is [x y wavelength scatter_angles yaw_angles roll_angles polarization_angle]


load_constants(); 
biospace_data.wavelengths = lambda_LEDs;
biospace_data.reference = reference;

% Read the protocol file and save info on what angles were used
protocol = csvread([folder_name '\protocol.csv']);
if size(protocol,2)==3
    polarization = 0;
else
    polarization = 1;
end
biospace_data.scatter_angles = unique(protocol(:,1));
biospace_data.yaw_angles = unique(protocol(:,2));
biospace_data.roll_angles = unique(protocol(:,3));
if polarization
   biospace_data.polarization_angels = unique(protocol(:,4));
end

% Find exposure time and gain
[biospace_data.exp_time, biospace_data.gain, biospace_data.binning]  = read_nodefile(folder_name);
biospace_data.resolution = resolution*biospace_data.binning/3;
biospace_data.linear_gain = 10^(biospace_data.gain/10);

%% read all data and save in a data cube
biospace_data.data_order = {'y', '(mm)';'x', '(mm)'; 'wavelength', '(nm)';
    'scatter_angles', '(degree)';'yaw_angles', '(degree)';'roll_angles', '(degree)'; 'polarization_angle' '(degree)'};
% biospace_data.data = zeros(1920/biospace_data.binning, 1200/biospace_data.binning,...
%                         length(lambda_LEDs), length(biospace_data.scatter_angles),...
%                         length(biospace_data.yaw_angles), length(biospace_data.roll_angles));
for scatter_ind = 1:length(biospace_data.scatter_angles)
   scatter=biospace_data.scatter_angles(scatter_ind);
   for yaw_ind = 1:length(biospace_data.yaw_angles)
      yaw=biospace_data.yaw_angles(yaw_ind);
      for roll_ind = 1:length(biospace_data.roll_angles)
          roll=biospace_data.roll_angles(roll_ind);
          for lambda_ind=1:length(lambda_LEDs)
              if polarization
                  for pol_ind = 1:length(biospace_data.polarization_angels)
                      pol=biospace_data.polarization_angels(pol_ind);
                      im_1=imread([folder_name '\scatter_' num2str(scatter) ,'_yaw_' num2str(yaw), '_roll_', num2str(roll), '_polarization_', num2str(pol), '\' num2str(biospace_data.wavelengths(lambda_ind)) 'nm.tiff' ]);
                      background =imread([folder_name, '\scatter_' num2str(scatter) ,'_yaw_' num2str(yaw), '_roll_', num2str(roll), '_polarization_', num2str(pol), '\background.tiff' ]);
                      data = im_1-background;
                      data = data.*flatfield_shape;
                      biospace_data.data(:,:,lambda_ind,scatter_ind,yaw_ind,roll_ind,pol_ind)= data/(biospace_data.exp_time*biospace_data.linear_gain*biospace_data.reference(lambda_ind));  
                  end
              else
                im_1=imread([folder_name '\scatter_' num2str(scatter) ,'_yaw_' num2str(yaw), '_roll_', num2str(roll), '\' num2str(biospace_data.wavelengths(lambda_ind)) 'nm.tiff' ]);
                background =imread([folder_name, '\scatter_' num2str(scatter) ,'_yaw_' num2str(yaw), '_roll_', num2str(roll), '\background.tiff' ]);
                data = im_1-background;
                data = data.*flatfield_shape;
                biospace_data.data(:,:,lambda_ind,scatter_ind,yaw_ind,roll_ind,1)= data/(biospace_data.exp_time*biospace_data.linear_gain*biospace_data.reference(lambda_ind));
%                 figure;imagesc(data)
%                 title(num2str(biospace_data.wavelengths(lambda_ind)))
              end
          end
      end 
   end   
end
biospace_data.x = [1:size(im_1,2)]*biospace_data.resolution;
biospace_data.y = [1:size(im_1,1)]*biospace_data.resolution;






% fid=fopen([folder_name '\protocol.csv'],'r','b');
% protocol_data=fread(fid,'*int16');
% fclose(fid);
% spect_pixels = protocol_data(2); %spect
% range_pixels = raw_data(4); %range
% nbr_images = raw_data(6);% nbr




%end

