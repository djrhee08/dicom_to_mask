function [] = dcm2binary_special_v2( rootdir, dirname, string_to_contain, string_not_to_contain )
     %% Extract useful data from DICOM image files
    % Directories are expected to be 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ?dcm2binary.m (in the same directory with rootdir)
    % ?InPolygon-MEX
    %   ?
    % ?rootdir
    %   ?dirname1
    %   ?dirname2
    %   ?dirname3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    addpath('InPolygon-MEX'); %
    
    rootdir = strcat(rootdir,'\',dirname);
    list = dir(strcat(rootdir,'\*.dcm')); 

    for i = 1:length(list)
        if strcmpi(list(i).name,'Structure.dcm') == 1
            str = dicominfo(strcat(list(i).folder,'\',list(i).name),'UseVRHeuristic',false);
        else
            info_temp = dicominfo(strcat(list(i).folder,'\',list(i).name));
            if isfield(info_temp,'Modality') == 1
            if info_temp.Modality == 'CT'
                info = info_temp;
                img(info.InstanceNumber,:,:) = dicomread(strcat(rootdir,'\',list(i).name));
                img_pos(info.InstanceNumber,:) = info.ImagePositionPatient;
            end
            end
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
        if isfield(item{i},'ContourSequence')
            sequence = struct2cell(item{i}.ContourSequence);
        
        if ~isempty(sequence)
            if strcmpi(sequence{1}.ContourGeometricType,'CLOSED_PLANAR') == 1
                %if contains(item_name{i}.ROIName,string_to_contain,'IgnoreCase',true)
                if contains(item_name{i}.ROIName,string_to_contain,'IgnoreCase',true) == 1 && contains(item_name{i}.ROIName,string_not_to_contain,'IgnoreCase',true) == 0
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
        end
        end
    end
    %% Only if there is given structure
    if index > 1
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
                    [c, z] = min(abs(img_pos(:,3) - contour_temp(j,3)));
            
                    % Create mask
                    xv = contour_temp(index_start:index_end,1);
                    yv = contour_temp(index_start:index_end,2);

                    %[in, on] = inpolygon(xq,yq,xv,yv);
                    [in, on] = InPolygon(xq,yq,xv,yv); % Use InPolygon mex instead to increase the speed
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
end

