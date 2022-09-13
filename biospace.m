% Scripts for reading and evaluating the data for BIOSAPCE
% Author: Hampus Manefjord 2022
% Licence: CC BY 2.0 https://creativecommons.org/licenses/by/2.0/
% You are free to:
% Share and copy and redistribute the material in any medium or format
% Adapt and remix, transform, and build upon the material for any purpose, even commercially.
% Under the following terms:
% Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made.
% For example if this code helps you for a scientfic publication consider citing my work or reaching out to hampus.manefjord @forbrf.lth.se

%% Reading the data from the folder structure stored by BIOSPACE
% this takes some time if the folders are large
% First the reference is read or loaded (this is typically only needed once per instrument)
% The foldername of a measurement along with the output from the reference is sent into read_biospace_data
% In the case of [pre april 2022] biospace code, separate copol and depol
% measurements are read and then merged
% the biospace_data.data is ordered: 
% [x y wavelength scatter_angles yaw_angles roll_angles polarization_angle]

% If you downloaded this and dont have access to the raw data used for
% these examples, this section of the code wont run. Instead download the
% .mat files and load them using the code in the following section.
% Download link 1: https://lunduniversityo365-my.sharepoint.com/:u:/g/personal/ha0261ma_lu_se/EScK5PHkQQdDmrJjuUmynHMBMxvPKJoWgOQ4hhvdFRIrpA?e=113Si3
% Download link 2: https://lunduniversityo365-my.sharepoint.com/:u:/g/personal/ha0261ma_lu_se/EZ03GwBqPAFOvqRUbRdyNC0Bq8s_v4j_YXO8kB7MwTK0bg?e=I6Y1YV

reference = read_biospace_reference('F:\biospace\Bees_GH\20220315-183436_ref_copol', 0.75)
reference_depol = read_biospace_reference('F:\biospace\Bees_GH\20220315-181608_ref_depol', 0.75) 
biospace_data_ref = read_biospace_data('F:\biospace\Bees_GH\20220315-183436_ref_copol', reference); % We read the data of the reference as if it was our sample to make sure it looks ok
biospace_data_ref_depol = read_biospace_data('F:\biospace\Bees_GH\20220315-181608_ref_depol', reference_depol); 
biospace_ref_combined(:,:,:,:,:,:,1) = biospace_data_ref.data; % Merging the copol and depol data
biospace_ref_combined(:,:,:,:,:,:,2) = biospace_data_ref_depol.data;
biospace_data_ref.data=biospace_ref_combined;

sample_folder_copol = 'F:\biospace\Bees_GH\20220320-Meli_CoPol_BkScattering';
sample_folder_depol = 'F:\biospace\Bees_GH\20220320-Meli_DePol_BkScattering';
biospace_data = read_biospace_data(sample_folder_copol, reference); % Read the sample data. This can take some time
biospace_data_depol = read_biospace_data(sample_folder_depol, reference_depol); % This takes some minutes
biospace_combined(:,:,:,:,:,:,1) = biospace_data.data; % Merging the copol and depol data
biospace_combined(:,:,:,:,:,:,2) = biospace_data_depol.data;
biospace_data.polarization_angles = [0,90];
biospace_data.data=biospace_combined;

%% In case you have read and saved the measurement as a .mat file, you  can load that file instead of reading again
load('biospace_data_meli_back.mat') 
load('biospace_data_ref.mat') 

%% Displaying the reference to verify that we get ~70% reflectance
figure(1)
image_of_reference = biospace_data_ref.data(:,:,1:8,1,1,1,1); % looking at wavelegnth indexes of the reference
mean_intensities = squeeze(mean(mean(image_of_reference(160:240,260:340, :)))) % looking at the values approximately at the center, the values are here calibrated and show reflectance
imagesc(biospace_data_ref.x,biospace_data_ref.y, image_of_reference(:,:,8));colormap gray;colorbar;caxis([0,1])
xlabel('\bfx (mm)');ylabel('\bfy (mm)');
%% Visualizing images in monocrome color, we can multiply the intensity or take the square root to increase the brightness of the sample
figure(2)
roll_angle_index = 10;
im_xy = biospace_data.data(:,:,6,1,1,roll_angle_index,1); % 
im_for_visualization = 4*sqrt(im_xy); % increasing the values so it is easier to see
imagesc(biospace_data.x, biospace_data.y, im_for_visualization );colormap gray; colorbar;xlabel('\bfx (mm)');ylabel('\bfy (mm)');
max(max(im_xy))
caxis([0,1]); % This "clips" all values >1 to white
title(['Roll angle: ', num2str(biospace_data.roll_angles(roll_angle_index))])

%% make a false color image
% we can chose multiple things to display as the R, G, and B components of
% a colorimage, one example is selecting different wavelengths
figure(3)
false_color_im = cat(3, biospace_data.data(:,:,6,1,1,1,1),biospace_data.data(:,:,5,1,1,1,1), biospace_data.data(:,:,4,1,1,1,1));
imagesc(biospace_data.x, biospace_data.y,6*false_color_im(:,:,:))
xlabel('\bfx (mm)');ylabel('\bfy (mm)');
title(['R:', num2str(biospace_data.wavelengths(6)), 'nm, G:', num2str(biospace_data.wavelengths(5)), ' nm, B:', num2str(biospace_data.wavelengths(4)), 'nm'])
%% make a degree of linear polarization (DoLP) image
figure(4)
pol_falsecolor = cat(3,biospace_data_ref.data(:,:,5,1,1,1,2),biospace_data_ref.data(:,:,5,1,1,1,1)-biospace_data_ref.data(:,:,5,1,1,1,2), 0*biospace_data.data(:,:,5,1,1,1,2));
imagesc(5*pol_falsecolor)
title('R = depol, G = copol-depol')
%% make a square region of interest (ROI)
figure(2)
ROI = getrect;
col_ind=floor(ROI(1)):(ceil(ROI(1))+ceil(ROI(3)));
row_ind=floor(ROI(2)):(ceil(ROI(2))+ceil(ROI(4)));
%% Find spectrum for the ROI
spectrum_matrix = biospace_data.data(row_ind,col_ind, :,1,1,roll_angle_index,1);
spectrum = squeeze(mean(spectrum_matrix, [1,2])); % wee take the mean over the row and column pixels
figure(5)
h = plot(biospace_data.wavelengths,spectrum);
xlabel('\bfWavelength (nm)')
ylabel('\bfIntsensity')
plotFixer(h)
%% Make a mask/crop out
figure(2)
%example_image = biospace_data.data(:,:, 5,1,1,roll_angle_index,1);
%figure(5);imagesc(image)
[mask,mask_ind1,mask_ind2,~] = make_mask();

%% Present a cropped out image and spectrum
figure(6)
imagesc(im_for_visualization.*mask);colormap gray
figure (7)
spectrum_matrix = biospace_data.data(mask_ind1,mask_ind2,:,1,1,roll_angle_index,1);
spectrum = squeeze(mean(spectrum_matrix, [1,2])); % wee take the mean over the row and column pixels
h = plot(biospace_data.wavelengths,spectrum);
xlabel('\bfWavelength (nm)')
ylabel('\bfIntsensity')
plotFixer(h)
%% make a gif, we can make a for loop and e.g. rotate the roll angle

figure(8)
for roll_angle_idx = 1:length(biospace_data.roll_angles)
    false_color_im = cat(3, biospace_data.data(:,:,6,1,1,roll_angle_idx,1),biospace_data.data(:,:,5,1,1,roll_angle_idx,1), biospace_data.data(:,:,4,1,1,roll_angle_idx,1));
    imagesc(biospace_data.x,biospace_data.y,5*false_color_im)
    title(['Roll angle: ', num2str(biospace_data.roll_angles(roll_angle_idx)), '^\circ'])
    xlabel('\bfx (mm)')
    ylabel('\bfy (mm)')
    if roll_angle_idx == 1
        gif('meliponula_roll.gif')
    else
        gif
    end
end
web('meliponula_roll.gif')

%% or loop the wavelength
figure(9)

for wavelength_idx = 1:length(biospace_data.wavelengths)
    mono_im = biospace_data.data(:,:,wavelength_idx,1,1,1,1);
    imagesc(biospace_data.x,biospace_data.y,15*mono_im);colormap gray;
    title(['Wavelength: ', num2str(biospace_data.wavelengths(wavelength_idx)), ' nm'])
    xlabel('\bfx (mm)')
    ylabel('\bfy (mm)')
    if wavelength_idx == 1
        gif('meliponula_wavelength.gif','DelayTime',0.8)
    else
       gif 
    end
end
web('meliponula_wavelength.gif')
%% make a polarplot
figure(10)
ax = polaraxes;
roll_data_copol = squeeze(mean(biospace_data.data(:,:,6,1,1,:,1),[1, 2])); % we take the mean over the whole images in this case
polarplot(roll_data_copol, 'DisplayName', 'Copol');
hold on
roll_data_depol = squeeze(mean(biospace_data.data(:,:,6,1,1,:,2),[1, 2])); % we take the mean over the whole images in this case
polarplot(roll_data_depol, 'DisplayName', 'Depol');
legend show;
ax.RAxis.Label.String = 'Intensity';
ax.ThetaAxis.Label.String =  'Degrees (^\circ)';

