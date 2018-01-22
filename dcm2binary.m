function [] = dcm2binary( dirname )
    %% Extract useful data from DICOM image files
    list = dir(strcat(dirname,'\*.dcm'));
    length(list)
    for i = 1:length(list)
        if strcmp(list(i).name,'str.dcm') == 1
            str = dicominfo(strcat(list(i).folder,'\',list(i).name));
        else
            info = dicominfo(strcat(list(i).folder,'\',list(i).name));
            img(info.InstanceNumber,:,:) = dicomread(strcat(dirname,'\',list(i).name));
            img_pos(info.InstanceNumber,:) = info.ImagePositionPatient;
        end
    end

    % Apply Slope and intercept to dicom image
    if isfield(info,'RescaleSlope') == 1
        slope = info.RescaleSlope;
    else
        slope = 1;
    end

    if isfield(info,'RescaleIntercept') == 1
        intercept = info.RescaleIntercept;
    else
        intercept = 0;
    end
    
    img = img.*slope + intercept;

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
                mask{i}.data(z,:,:) = (in&~on);
            
                % Prepare for the next indices
                index_end = index_end + 1;
                index_start = index_end;
            end
        end      
    end

    %% Save the data
    save(strcat('image_',dirname,'.mat'),'img');
    save(strcat('mask_',dirname,'.mat'),'mask');

end

