clear all
clc
close all
%%
list = dir('H&N_DATASET');
list = list(~ismember({list.name},{'.','..'}));
string_to_contain = ["cord"];
string_not_to_contain = ["exp","+","0.5","aryte","hot","mm","cm","avoid","prv","ptv","pv","off"];

for i=4:length(list)
    if list(i).isdir == 1
        tic
        dcm2binary_special_v2(list(i).folder, list(i).name, string_to_contain,string_not_to_contain);
        disp(i);
        toc
    end
end