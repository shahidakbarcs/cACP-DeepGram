% This make.m is used under Windows
clear all;
close all;

addpath D:\asif_E_and_F_GIST_2009\MultiSVM_asif_Practice\libsvm-mat-2.88-1;

mex -O -c svm.cpp
mex -O -c svm_model_matlab.c
mex -O svmtrain.c svm.obj svm_model_matlab.obj
mex -O svmpredict.c svm.obj svm_model_matlab.obj
mex -O read_sparse.c
