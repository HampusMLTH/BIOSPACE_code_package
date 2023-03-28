function [led_intensities, homogeneity] = read_biospace_reference(folder_name, refernce_reflectance, pol)
%READ_BIOSPACE_REFERENCE returns the led_intensities for BIOSPACE
%   a vector corresponding to the different wavelengths of BIOSPACE in
%   increasing order
%   the homogeneity is describing how the intensity varies in the field of
%   view
if nargin < 3
   pol = 0; 
end
if pol 
   subFolderName = '\scatter_0_yaw_0_roll_0_polarization_0\'; 
else
    subFolderName = '\scatter_0_yaw_0_roll_'; 
end
load_constants();
ROI =0;
[exp_time, gain, ~] = read_nodefile(folder_name);
linear_gain = 10^(gain/10);

% Read the protocol file and save info on what angles were used
protocol = csvread([folder_name '\protocol.csv']);
% scatter_angles = unique(protocol(:,1));
% yaw_angles = unique(protocol(:,2));
roll_angles = unique(protocol(:,3));



led_intensities = zeros(length(lambda_LEDs),length(roll_angles));
% homogeneity = zeros([size(background),length(lambda_LEDs)]);
for roll = 1:length(roll_angles)
    background = imread([folder_name subFolderName num2str(roll_angles(roll)) '\'  'background.tiff']);

    for lambda_ind=1:length(lambda_LEDs)

        fn=[folder_name subFolderName  num2str(roll_angles(roll)) '\' num2str(lambda_LEDs(lambda_ind)) 'nm.tiff'];
        im = imread(fn);
        im = im - background; 
    %     if ROI == 0
    %         figure
    %         imagesc(im);colormap gray;
    %         disp('THIS IS NOT DOING ANYTHING draw a Region of Interest')
    %         ROI = getrect;
    %         colInd=floor(ROI(1)):(ceil(ROI(1))+ceil(ROI(3)));
    %         rowInd=floor(ROI(2)):(ceil(ROI(2))+ceil(ROI(4)));
    %     end
        im_hat = regression_2d_3rd_order(im);
        led_intensities(lambda_ind,roll) = mean(im,'all')/(exp_time*linear_gain*refernce_reflectance);
        homogeneity(:,:,lambda_ind,roll) = im_hat/(exp_time*linear_gain*refernce_reflectance);
    end
end
    homogeneity=mean(homogeneity,[3,4]);
    homogeneity=homogeneity/mean(homogeneity,'all');
    led_intensities=mean(led_intensities,2);
end

