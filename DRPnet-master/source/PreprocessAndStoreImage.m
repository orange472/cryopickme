function PreprocessAndStoreImage(image_path, output_dir, resize_factor, is_negative, is_train)
% Read micrograph mrc format
startSlice=1;
numSlices=1;
debug=0;
[img_0,s,hdr,extraHeader]=ReadMRC(image_path, startSlice, numSlices, debug);

% Normalize
if (max(img_0(:)) > 255 * 255)
    mi=min(img_0(:));
    ma=max(img_0(:));
    img_0=(img_0-mi)/(ma-mi);
elseif (max(img_0(:)) > 255)
    img_0=img_0/(255*255);
else
    img_0=img_0/(255);
end

% Resize, rotate and smooth filter
img_1=imresize(img_0, 1/resize_factor);
img_1 = imrotate(img_1, 90);
img_1 = flipud(img_1);
if (is_train == 1)
	fsize = 0.5;
else
	fsize = 2;
end
img_2 = imgaussfilt(img_1, fsize);

% Stretch intensity range
lohib = stretchlim(img_2,[.01 .99]);
img_3 = imadjust(img_2,lohib,[]);
mi = mean(img_3(:));
if (mi < 0.5) || (mi > 0.6)
    dist = 0.55 - mi;
    img_3b = round(img_3*255) + round(dist*255);
    img_3b(img_3b<0) = 0;
    img_3b(img_3b>255) = 255;
    img_3b = uint8(img_3b);
    img_3c = im2double(img_3b);
    img_3 = img_3c;
end

% Illumination correction
lpf = imgaussfilt(img_3, 100);
meanLpf = mean(lpf(:));
img_4 = img_3 - lpf + meanLpf;
img_4 = double(img_4);
clean_image = im2uint8(img_4);

% Switch to negative stain
if is_negative == 1
    clean_image = imcomplement(clean_image);
end

% Save processed image to output directory
[~, filename, ~] = fileparts(image_path);

if is_train == 1 
    output_path = fullfile(output_dir, [filename, '_preprocessed1.png']);
else
    output_path = fullfile(output_dir, [filename, '_preprocessed.png']);
end

imwrite(clean_image, output_path);
end
