clear all
clc
close all
%% Image inspection 
disp_option = 1; % 1 to do visual inspection

image_list = dir('image/*.mat');
mask_list = dir('mask/*.mat');
index = 1;
for i=1:length(image_list)
    image_name = image_list(i).name;
    mask_name = mask_list(i).name;
    num1 = strsplit(image_name,{'_','.'});
    num2 = strsplit(mask_name,{'_','.'});
    if strcmpi(num1,num2) ~= 1
        disp('Image and Mask do not match')
        disp(image_name, mask_name)
        return 
    end

    image = load(strcat(image_list(i).folder,'\',image_name));
    mask = load(strcat(mask_list(i).folder,'\',mask_name));
    mask = mask.mask;
    image = image.img;

    
    dim = size(mask);
    for j=1:dim(2)
        if contains(mask{j}.name,'cord','IgnoreCase',true) == 1
            mask_new = mask{j}.data;
            
            % Display for Visual Inspection
            if disp_option == 1
            disp('---------------------------')
            disp(mask{j}.name)
            disp(size(image))
            disp(size(mask_new))
            sz = size(mask_new);
            clims = [0,500];
            for k=1:sz(1)
                mask_slice = squeeze(mask_new(k,:,:));
                if sum(mask_slice(:)) ~= 0
                    image_slice = squeeze(image(k,:,:));
                    subplot(1,2,1)
                    imagesc(image_slice,clims)
                    subplot(1,2,2)
                    imagesc(mask_slice)
                    colormap gray
                    pause(0.1)
                end
            end
            end
            
            % CT Number Analysis
            maxTotalCTnum(index) = max(image(:));
            minTotalCTnum(index) = min(image(:));
            type = class(image);
            mask_new = cast(mask_new,type);
            CTnum = image.*mask_new;
            maxCTnum(index) = max(CTnum(:));
            minCTnum(index) = min(CTnum(:));
            avgCTnum(index) = sum(CTnum(:))/sum(int16(mask_new(:)));
            index = index + 1;
            
            break;
        end
    end
        
end

figure;
plot(maxCTnum)
hold on
plot(minCTnum)
plot(avgCTnum)
hold off
title('CT number in cord')
legend('max','min','avg')

figure;
plot(maxTotalCTnum)
hold on
plot(minTotalCTnum)
hold off
title('CT number in image')
legend('max','min')
axis([0 inf -1000 10000])
