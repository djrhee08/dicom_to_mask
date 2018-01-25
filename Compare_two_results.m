clear all
clc
close all
%%
m1 = load('mask_1.mat');
m1_mex = load('mask_1_mex.mat');

m1 = m1.mask;
m1_mex = m1_mex.mask;

for i=1:length(m1)
    data_m1 = m1{i}.data;
    data_m1_mex = m1_mex{i}.data;
    
    if data_m1 == data_m1_mex
        disp("okay")
        sum(data_m1(:))
        sum(data_m1_mex(:))
    else
        disp("not okay")
    end
end