clear all
clc
close all
%%
name_dir = 'cord';
if exist(strcat('..\',name_dir),'dir') == 0
    mkdir(strcat('..\',name_dir,'\','training_set\image'));
    mkdir(strcat('..\',name_dir,'\training_set\mask'));
    mkdir(strcat('..\',name_dir,'\validation_set\image'));
    mkdir(strcat('..\',name_dir,'\validation_set\mask'));
end


validation_ratio = 0.1;
string_to_contain = ["cord","spinal"];
string_not_to_contain = ["exp","+","0.5","aryte","hot","mm","cm","avoid","prv","ptv","pv","off"];

index = 0;
list = dir('mask*.mat');

for i = 1:length(list)
    load(list(i).name);
    %list_str = '';
    for j=1:length(mask)
        if contains(mask{j}.name,string_to_contain,'IgnoreCase',true) == 1 && contains(mask{j}.name,string_not_to_contain,'IgnoreCase',true) == 0
            X = [mask{j}.name, ',', num2str(i),',',list(i).name];
            disp(X);
            C = strsplit(list(i).name,'_');
            imgfilename = strcat('image_',C{2});
            
            % if less than validation_ratio, copy file to validation set
            if rand() < validation_ratio
                copyfile(list(i).name,strcat('..\',name_dir,'\','validation_set\mask'));
                copyfile(imgfilename,strcat('..\',name_dir,'\','validation_set\image'));
            else
                copyfile(list(i).name,strcat('..\',name_dir,'\','training_set\mask'));
                copyfile(imgfilename,strcat('..\',name_dir,'\','training_set\image'));
            end
            
            break;
        end
    end
    %disp(list_str)
end