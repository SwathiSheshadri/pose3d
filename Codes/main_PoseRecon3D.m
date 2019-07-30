% Main script for 3D recondstruction and calibration
% Before running this function create your own config file
% using the template_config_your_experiment_DLC2d.m as reference

clear 
close all
clc

%% Initializes experiment parameters as provided in your config file 
template_config_file %Edit this

%% Call for calibration 
calibration_helper

%% Load and undistort 2D data if requested in config file
load_preprocess_2d_data

%% Perform 3D reconstruction
reconstruct_3D

%% Plot 3D reconstructed data
simple_3Ddata_plotter %To quickly vizualizate 3D reconstruction results
