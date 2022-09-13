% Some example scripts for evaluating the data in the biophotonics project 2021
% Author Hampus Manefjord

%% specify path
folder_path='images\';
example_folder='scatter_0_yaw_0_roll_80\';

load_constants();
% Load images
images = zeros(400,640,8);
for lambda_ind=1:length(lambda_LEDs)
   fn=[folder_path example_folder num2str(lambda_LEDs(lambda_ind)) '_nm.tiff']; 
   images(:,:,lambda_ind)= imread(fn);
end
% Calibrate images
dn_grey_ref ='grey_reference';
ROI =0;
light_source_int = zeros(length(lambda_LEDs),1);
for lambda_ind=1:length(lambda_LEDs)
    fn=[dn_grey_ref '\' num2str(lambda_LEDs(lambda_ind)) '_nm.tiff'];
    im = imread(fn);
    if ROI == 0
        figure
        imagesc(im)
        ROI = getrect;
        colInd=floor(ROI(1)):(ceil(ROI(1))+ceil(ROI(3)));
        rowInd=floor(ROI(2)):(ceil(ROI(2))+ceil(ROI(4)));
    end
    light_source_int(lambda_ind) = mean(mean(im(rowInd,colInd)));
end
cal_images = zeros(size(images));
for lambda_ind=1:length(lambda_LEDs)
   cal_images(:,:,lambda_ind)=images(:,:,lambda_ind)./light_source_int(lambda_ind);
end
% Construct  a false color image
color_im=false_color(cal_images, 6,5,4); % 5 corresponds to lambda_LEDs(5) = 525nm etc
% display color/mono images
figure
imagesc(sqrt(color_im)*2)
%%
figure
imagesc(cal_images(:,:,5))
%% Make a mask/crop out
[mask,mask_ind1,mask_ind2,~] = make_mask();
%% Present a cropped out image
figure
imagesc(cal_images(:,:,5).*mask)
%% load/process data from multiple angles
lambda_ind=3;
for sample_angle = 80:5:85
     im_1=imread([folder_path 'scatter_0_yaw_0_roll_'  num2str(sample_angle) '\' num2str(lambda_LEDs(lambda_ind)) '_nm.tiff' ]);
     im_1= im_1./light_source_int(lambda_ind); % Calibrate
     figure
     imagesc(im_1)
     intensity = mean(mean(im_1))
end
