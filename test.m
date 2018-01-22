clear all
clc
close all
%%
list = dir('*');
list = list(~ismember({list.name},{'.','..'}));
for i=1:length(list)
    if list(i).isdir == 1
        list(i).name
        dcm2binary(list(i).name);
    end
end