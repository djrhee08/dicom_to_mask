clear all
clc
close all
%% Extract useful data from DICOM image files
list = dir('*.dcm');
for i = 1:length(list)
    if strcmp(list(i).name,'str.dcm') == 1
        str = dicominfo(list(i).name);
    else
        info = dicominfo(list(i).name);
        img(info.InstanceNumber,:,:) = dicomread(list(i).name);
        img_pos(info.InstanceNumber,:) = info.ImagePositionPatient;
    end
end
img_orientation = info.ImageOrientationPatient;
img_pixsize = info.PixelSpacing;
img_pixsize = [img_pixsize;1]';
img_pos_temp = img_pos(1,:);
img_pos_temp(3) = 0;
img_size = [info.Rows, info.Columns];
%% Extract useful data from RT Structure file
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
        
        data_temp = data_temp - img_pos_temp;
        data_temp = data_temp./img_pixsize;
        
        data_original{i} = data_temp;
        
        [~,idx] = sort(data_temp(:,3)); % sort just the third column (z coord)
        data_temp = data_temp(idx,:);   % sort all 
        
        data_total{index} = data_temp;
        index = index + 1;
    end
end
%%
qq = double(1:img_size(1));  % This part has been changed!
xq = repmat(qq,img_size(1),1);
yq = repmat(qq',1,img_size(2));

for i=1:length(data_total)
    mask{i}.data = false(size(img));
    mask{i}.name = data_name{i};
    contour_temp = data_total{i};
    cpoint = logical(diff(contour_temp(:,3))); % When z coord changes
    index_start = 1; index_end = 1;
    for j=1:length(contour_temp)-1
        if cpoint(j) == 0
            index_end = index_end + 1;
        elseif cpoint(j) == 1
            z = find(img_pos(:,3) == contour_temp(j,3));
            
            % Create mask
            xv = contour_temp(index_start:index_end,1);
            yv = contour_temp(index_start:index_end,2);

            [in, on] = inpolygon(xq,yq,xv,yv);
            %mask{i}.data(:,:,z) = on;
            mask{i}.data(z,:,:) = (in&~on);
            
            % Prepare for the next indices
            index_end = index_end + 1;
            index_start = index_end;
        end
    end      
end

%% Save the data
save('image.mat','img');
save('mask.mat','mask');
%% test code, need to develop more for RT structure display
c1 = mask{1}.data;
c2 = mask{2}.data;
c3 = mask{3}.data;
c4 = mask{4}.data;

q1 = data_original{1};
q2 = data_original{2};
q3 = data_original{3};
q4 = data_original{4};

figure;
img(c3) = 10000;
in = 73;
out = 126;
%for i=1:30
    i = 13;
    imagesc(squeeze(img(i,:,:)))
    colormap gray
    hold on
    plot(q3(in:out,1),q3(in:out,2))
    hold off
%end