function im_hat = regression_2d_3rd_order(im)
% returns a regressed image based on second order polinomial in two
% dimensions


[x,y] = meshgrid(linspace(-1,1,size(im,2)),linspace(-1,1,size(im,1)));

regr =[x(:).^0, x(:).^1, x(:).^2, x(:).^3 y(:).^1, y(:).^2, y(:).^3, x(:).^1.*y(:).^1, x(:).^1.*y(:).^2, x(:).^2.*y(:).^1];
coef = regr\im(:);
im_hat = regr*coef;
im_hat = reshape(im_hat,size(im));

% figure;plot(mean(im, 1));
% hold on;plot(mean(im_hat, 1));
% 
% figure;plot(mean(im, 2));
% hold on;plot(mean(im_hat, 2));
% 
% figure;plot(mean(im-im_hat, 1));
% hold on;plot(mean(im-im_hat, 2));

end