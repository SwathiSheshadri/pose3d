# 3D reconstrution toolbox for behavior tracked with multiple cameras 

## What is pose3D?<br/>
pose3D is a toolbox for researchers working on computer vision based behavior tracking. Functions necessary to reconstruct behavioral features tracked from multiple cameras in 2D to 3D are provided with this toolbox. The core of this toolbox is a one shot implementation of triangulation for 3D reconstruction applicable to n cameras. It includes two main modes of 3D reconstruction to be selected based on the design of one's experiment.  The first mode uses, 2D data from all n cameras that are used to track the feature in 2D while the second mode selects the best camera pair for every time point and feature of interest. Furthermore, validation of the approach is included in example implementations showcasing the capabilities of the this toolbox. The examples also include illustration of 2D to 3D reconstruction workflow with preprocessing steps such as image undistortion, automatic selection of cameras containing well tracked 2D features and application of suitable temporal filters on the reconstructed 3D trajectories.

## Table of Contents
  * [Why pose3D?](#Why-pose3D)
  * [Running demo functions](#Running-demo-functions)
  * [Before using pose3d for your own data](#Before-using-pose3d-for-your-own-data)
  * [Using the toolbox for your own data](#Using-the-toolbox-for-your-own-data)
  * [Troubleshooting and some tips on stereo camera calibration](#Troubleshooting-and-some-tips-on-stereo-camera-calibration)
  * [Dependencies](#dependencies)
  * [Installation](#installation)
  * [Citation](#citation)
  * [Acknowledgements](#acknowledgements)

## Why pose3D?

Behavior tracking in lab environments was recently revolutionized by [DeepLabCut (DLC)](https://github.com/AlexEMG/DeepLabCut): a markerless tracking software.
While DLC provides excellent tools for 2D tracking, scope for development of 3D reconstruction workflows especially for 2D behavior tracking made from more than two cameras still exists. [Anipose](https://github.com/lambdaloop/anipose) and [DLC](https://www.nature.com/articles/s41596-019-0176-0) offer implementations in python using OpenCV package in Python for camera calibration and 3D reconstruction. Camera calibration is a necessary step for 3D reconstruction in which checkboard images acquired from a camera are used to estimate its lens properties such as focal length and principal point. When checker board images are acquired simultaneous from 2 cameras, the position of one camera with respect to the other can also be obtained. In comparison to openCV, Matlab (The MathWorks Inc., Natick, Massachusetts), has a very user-friendly and graphical user interface (GUI) based camera calibration routine which makes camera calibration much easier to perform. recon3D takes advantage of this function in Matlab and provides a toolbox for 3D reconstruction of features tracked using DLC or any other 2D tracking software as illustrated in Figure 1. Given the popularity of Matlab in academia, we believe this toolbox will help make 3D reconstruction of tracked 2D behavior easier for researchers to use.

![](ExampleGrasping_2Dto3D.gif)<br/>
*Figure 1: Reconstruction in 3D of grasping behavior tracked in 2D using DeepLabCut*


## Running demo functions
1) Download the repository and from the main folder of the repository run **./Codes/main_demo_DLC2d.m** to perform 3D reconstruction of corners of a standard Rubik's cube tracked in 2D using DLC.<br/>
2) Simliar to the first example from the main folder of the repository, run **./Codes/main_demo_other2d.m** to perform 3D reconstruction of corners of a standard Rubik's cube tracked in 2D using any other 2D tracking software. Here we mimick other software by manual 2D tracking.<br/>

## Using the toolbox for your own data
Run the below functions in the following order from the main folder of this repository. <br/>
1) Edit **template_config_file.m** file to enter your project specific information. <br/>
2) Run **./Codes/main_pose3d.m** with your config file to save 3D reconstructed data for your project. <br/>
3) The code pops up message boxes in Matlab when user input is required. Follow the messages to perform 3D reconstruction.

## Before using pose3d for your own data
1) Record behavior of interest from multiple cameras and track features of interest across these cameras using DLC or any other 2D tracking software. <br/>
2) Save 2D tracked data in .csv format and keep these files accessible from the computer in which you want to use pose3d toolbox on.<br/>
3) Record checkerboard calibration videos by fixing one of your setup cameras as primary. Primary camera should be selected such that you can obtain checker board images simulataneously with the primary and every other camera in full view. For instance, if you have 3 cameras select one as primary and arbitrarily assign the remaining cameras to be secondary 1 and secondary 2. Then, record checkerboard videos with primary and secondary 1 simultaneously. Simlarly, next record checkerboard videos with primary and secondary 2 simultaneously. Save these videos and have them accesible from your computer. <br/>

## Troubleshooting and some tips on stereo camera calibration
1) Our toolbox is designed to work with [stereoCameraCalibrator](https://www.mathworks.com/help/vision/ug/stereo-camera-calibrator-app.html) GUI in MATLAB.<br/>
2) In case you are acquiring images for calibration, ensure to save images into different folders with same file names as this is required by stereoCameraCalibrator.<br/>
### Below listed are some of the common cases where we observed a failure in 3D reconstruction <br/>
1) Mismatch between 2D tracked csv file and calibration matricies. This will cause mismatch in camera matrix and tracked 2D data and results in failure. To avoid this, ensure that the order of 2D data and calibration files is maintained across the config file. Refer to the comments in the template config file for more details.
2) Problems with stereo camera calibration. To avoid this, ensure to present checkboard in varied angles when recording calibration videos and check the re-projection errors in the stereo camera calibration GUI to remove outlier calibration files.

## Dependencies 
In-built functions of Matlab, Computer Vision Toolbox. Code has been tested on MATLAB 2018b across linux, MAC and Windows operating systems.

## Installation
To install this toolbox, add all contents of this repository to Matlab path. 

## Citation
For questions on the toolbox and citation please contact us at swathishesh@gmail.com or HScherberger@dpz.eu


## Acknowledgements
We are very thankful to Mackenzie Mathis and Alexandar Mathis for their help in getting us going with using vision based tracking with DLC. Discussions with several colleagues at the German Primate Center including Andrej Fillipow, Michael Berger, Sebastian Mueller and Daniela Buchwald were very useful for the development of our tracking experimental setup. Thanks also to Viktorija Schek who helped with testing out some of our implementations. 

