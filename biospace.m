% Scripts for reading and evaluating the data for BIOSAPCE
% Author: Hampus Manefjord 2023
% Licence: CC BY 2.0 https://creativecommons.org/licenses/by/2.0/
% You are free to:
% Share and copy and redistribute the material in any medium or format
% Adapt and remix, transform, and build upon the material for any purpose, even commercially.
% Under the following terms:
% Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made.
% For example consider citing my work or reaching out to hampus.manefjord @forbrf.lth.se

%% Reading the data from the folder structure stored by BIOSPACE
% this takes some time if the folders are large
% First the reference is read or loaded (this is typically only needed once per instrument)
% The foldername of a measurement along with the output from the reference is sent into read_biospace_data
% In the case of [pre april 2022] biospace code, separate copol and depol
% measurements are read and then merged
% the biospace_data.data is ordered: 
% [y x wavelength scatter_angles yaw_angles roll_angles polarization_angle]

% To get access to the raw data used for
% these examples, download using these links, reach out to me if they have
% expired
% Download link: https://lunduniversityo365-my.sharepoint.com/:f:/g/personal/ha0261ma_lu_se/Eidnpf9DN7BPkN0NZ3Jc7mUBwOq1WNQvu6dQdncnVGnhkw?e=I0hBOW

%edit the local path below
local_path = 'C:\Users\Hampus\OneDrive - Lund University\temp3\biospace_example_data\';


ref_folder_copol = strcat(local_path, 'reference_copol');
ref_folder_depol = strcat(local_path, 'reference_depol');
sample_folder_copol = strcat(local_path, 'sample_copol');
sample_folder_depol = strcat(local_path, 'sample_depol');

[reference,flatfield_shape] = read_biospace_reference(ref_folder_copol, 0.7,0);
biospace_data = read_biospace_data(sample_folder_copol, reference,flatfield_shape); % This can take some time
sample_depol = read_biospace_data(sample_folder_depol, reference, flatfield_shape); % 
biospace_data.data(:,:,:,:,:,:,2)=sample_depol.data;
biospace_data.polarization_angles = [0,90];

close all
%% In case you have read and saved the measurement as a .mat file, you  can load that file instead of reading again
% load('biospace_data.mat') 

%% clip negative values to 0
biospace_data.data = max(biospace_data.data,0);
%% Visualizing images in monocrome color, we can multiply the intensity or take the square root to increase the brightness of the sample
figure(2)
yaw_angle_index = 1;
im_xy = biospace_data.data(:,:,6,1,yaw_angle_index,1,1); % 
im_xy= max(im_xy,0); % clips all negative values to 0
im_for_visualization = 2*sqrt(im_xy); % increasing the values so it is easier to see
imagesc(im_for_visualization );colormap gray; colorbar;xlabel('\bfx (pixel)');ylabel('\bfy (pixel)');
caxis([0,1]); % This "clips" all values >1 to white
title(['Yaw angle: ', num2str(biospace_data.scatter_angles(yaw_angle_index))])

%% make a false color image
% we can chose multiple things to display as the R, G, and B components of
% a colorimage, one example is selecting different wavelengths

figure(3)
false_color_im = cat(3, biospace_data.data(:,:,8,1,1,1,1),biospace_data.data(:,:,7,1,1,1,1), biospace_data.data(:,:,6,1,1,1,1));
false_color_im=max(false_color_im,0);
imagesc(biospace_data.x, biospace_data.y,2*sqrt(false_color_im(:,:,:)))
xlabel('\bfx (mm)');ylabel('\bfy (mm)');
title(['R:', num2str(biospace_data.wavelengths(8)), 'nm, G:', num2str(biospace_data.wavelengths(7)), ' nm, B:', num2str(biospace_data.wavelengths(6)), 'nm'])

%% make a degree of linear polarization (DoLP) image
figure(4)
pol_falsecolor = cat(3,biospace_data.data(:,:,7,1,1,1,2),biospace_data.data(:,:,7,1,1,1,1)-biospace_data.data(:,:,7,1,1,1,2), 0*biospace_data.data(:,:,7,1,1,1,2));
imagesc(5*pol_falsecolor)
title('R = depol, G = copol-depol')
%% make a region of interest (ROI)
figure(2)
disp('draw a ROI for the body')
mask_body = make_mask();
%% Find spectrum for the ROI
figure(5)
spectrum_matrix = biospace_data.data(:,:, :,1,yaw_angle_index,1,1); % cube with x, y,lambda
spectrum_matrix=spectrum_matrix.*mask_body;
spectrum = squeeze(sum(spectrum_matrix, [1,2])/sum(mask_body, [1,2])); 
spectrum=spectrum*100; % percent
plot(biospace_data.wavelengths,spectrum);
xlabel('wavelength (nm)')
ylabel('reflectance (%)')

%% make a gif, we can make a for loop and e.g. rotate the yaw angle

figure(6)
for yaw_angle = 1:length(biospace_data.yaw_angles)
    false_color_im = cat(3, biospace_data.data(:,:,6,1,yaw_angle,1,1),biospace_data.data(:,:,5,1,yaw_angle,1,1), biospace_data.data(:,:,4,1,yaw_angle,1,1));
    imagesc(biospace_data.x,biospace_data.y,5*false_color_im)
    title(['yaw angle: ', num2str(biospace_data.yaw_angles(yaw_angle)), '^\circ'])
    xlabel('\bfx (mm)')
    ylabel('\bfy (mm)')
    if yaw_angle == 1
        gif('loop_yaw.gif','DelayTime',0.8)
    else
        gif
    end
end
web('loop_yaw.gif')

%% or loop the wavelength
figure(7)

for wavelength_idx = 1:length(biospace_data.wavelengths)
    mono_im = biospace_data.data(:,:,wavelength_idx,1,1,1,1);
    imagesc(biospace_data.x,biospace_data.y,2*sqrt(mono_im));colormap gray;
    title(['Wavelength: ', num2str(biospace_data.wavelengths(wavelength_idx)), ' nm'])
    xlabel('\bfx (mm)')
    ylabel('\bfy (mm)')
    if wavelength_idx == 1
        gif('loop_wavelength.gif','DelayTime',0.8)
    else
       gif 
    end
end
web('loop_wavelength.gif')

%% make a polarplot
figure(8)
ax = polaraxes;
roll_data_copol = squeeze(mean(biospace_data.data(:,:,6,1,:,1,1),[1, 2])); % we take the mean over the whole images in this case
polarplot(roll_data_copol, 'DisplayName', 'Copol');
hold on
roll_data_depol = squeeze(mean(biospace_data.data(:,:,6,1,:,1,2),[1, 2])); % we take the mean over the whole images in this case
polarplot(roll_data_depol, 'DisplayName', 'Depol');
legend show;
ax.RAxis.Label.String = 'Intensity';
ax.ThetaAxis.Label.String =  'Degrees (^\circ)';

