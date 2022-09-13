function [reference] = read_biospace_reference(folder_name, refernce_reflectance)
%READ_BIOSPACE_REFERENCE returns the reference measurement for BIOSPACE
%   a vector corresponding to the different wavelengths of BIOSPACE in
%   increasing order
%   you need to draw a rectangle for the relevant area
load_constants();
ROI =0;
[exp_time, gain, ~] = read_nodefile(folder_name);
linear_gain = 10^(gain/10);
reference = zeros(length(lambda_LEDs),1);
for lambda_ind=1:length(lambda_LEDs)
    fn=[folder_name '\scatter_0_yaw_0_roll_0\' num2str(lambda_LEDs(lambda_ind)) '_nm.tiff'];
    im = imread(fn);
    if ROI == 0
        figure
        imagesc(im);colormap gray;
        ROI = getrect;
        colInd=floor(ROI(1)):(ceil(ROI(1))+ceil(ROI(3)));
        rowInd=floor(ROI(2)):(ceil(ROI(2))+ceil(ROI(4)));
    end
    reference(lambda_ind) = mean(mean(im(rowInd,colInd)))/(exp_time*linear_gain*refernce_reflectance);
end
end

