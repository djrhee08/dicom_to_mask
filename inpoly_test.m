clear all
clc
close all
%%
list = dir('MRI1/*.dcm');
for i = 1:length(list)
    if strcmp(list(i).name,'str.dcm') == 1
        str = dicominfo(strcat('MRI1/',list(i).name));
    else
        info = dicominfo(strcat('MRI1/',list(i).name));
        img(:,:,info.InstanceNumber) = dicomread(strcat('MRI1/',list(i).name));
        img_pos(info.InstanceNumber,:) = info.ImagePositionPatient;
    end
end
img_orientation = info.ImageOrientationPatient;
img_pixsize = info.PixelSpacing;
img_pixsize = [img_pixsize;1]';
img_pos_temp = img_pos(1,:);
img_pos_temp(3) = 0;
img_size = [info.Rows, info.Columns];
%%
item = struct2cell(str.ROIContourSequence);
item_name = struct2cell(str.StructureSetROISequence);
index = 1;
for i=1:length(item)
    sequence = struct2cell(item{i}.ContourSequence);
    if strcmp(sequence{i}.ContourGeometricType,'CLOSED_PLANAR') == 1
        data_name{index} = item_name{i}.ROIName;
        data_temp = [];
        for j=1:length(sequence)
            data = sequence{j}.ContourData;
            data = reshape(data,3,[]);
            data = data';
            data_temp = [data_temp;data;data(1,:)];
        end
        %data_temp = sort(data_temp,'descend');
        data_temp = data_temp - img_pos_temp; 
        data_temp = data_temp./img_pixsize;
        data_total{index} = data_temp;
        index = index + 1;
    end
end
%%
%for i=1:length(data_total)
img_temp = img(:,:,13);
contour_temp = data_temp(1:36,:);

figure;
imagesc(img_temp)
colormap gray
hold on
plot(contour_temp(:,1),contour_temp(:,2))
hold off
%%
qq = double(0:img_size(1)-1);
qq = qq + 0.5;
xq = repmat(qq,512,1);
yq = repmat(qq',1,512);

xv = contour_temp(:,1);
yv = contour_temp(:,2);

[in,on] = inpolygon(xq,yq,xv,yv);

img_temp(in) = 5000;
figure;
imagesc(img_temp)
colormap gray