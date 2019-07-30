% Main script for 3D recondstruction and calibration
% Before running this function create your own config file
% using the template_config_your_experiment_DLC2d.m as reference

clear 
close all
clc
%For the DEMO most of the calibration and pre-processing steps have been
%done for you so you can simple click proceed on every message box to go 
%directly to data visualization
%% Generic steps across experiments
% Initializes experiment parameters as provided in your config file 
config_DLC2d

%% Call for calibration (Skipping this step as calibfiles are given for demo)
% calibration_helper

%% Load/undistort 2D data, threshold by likelihood from DLC
load_preprocess_2d_data 

%% Perform 3D reconstruction
reconstruct_3D

%% Experiment specific plotting & filtering function
demo_DLC2d_plotter

