% Demo 3D reconstruction workflow for 2D tracked data from any 2D tracking
% software
% This code is for demo only, not to be edited
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d

clear 
close all
clc
%For the DEMO most of the calibration and pre-processing steps have been
%done for you so you can simple click proceed on every message box to go 
%directly to data visualization
%% Generic steps across experiments
% Initializes experiment parameters as provided in your config file 
config_other2d

%% Call for calibration (Skipping this step as calibfiles are given for demo)
% calibration_helper

%% Load/undistort 2D data, threshold by likelihood from DLC
load_preprocess_2d_data 

%% Perform 3D reconstruction
reconstruct_3D

%% Experiment specific plotting & filtering function
demo_other2d_plotter
