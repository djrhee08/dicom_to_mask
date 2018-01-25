clear all
clc
close all
%%
list = dir('AQA');
list = list(~ismember({list.name},{'.','..'}));

for i=1:length(list)
    if list(i).isdir == 1
        tic
        dcm2binary(list(i).folder, list(i).name);
        toc
    end
end