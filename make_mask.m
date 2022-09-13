function [mask,mask_ind1,mask_ind2,mask_handle] = make_mask()
%MAKE_MASK of imagesc
mask_handle=drawfreehand;
mask=createMask(mask_handle);
[mask_ind1,mask_ind2]=find(mask);

end

