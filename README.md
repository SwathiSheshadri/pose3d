# 3D reconstrution toolbox for behavior tracked with multiple cameras 

## What is pose3d?
pose3D is a toolbox for researchers working on computer vision based behavior tracking. Functions necessary to reconstruct behavioral features tracked from multiple cameras in 2D to 3D are provided with this toolbox. The core of this toolbox is a one shot implementation of triangulation for 3D reconstruction applicable to n cameras. It includes two main modes of 3D reconstruction to be selected based on the design of one's experiment.  The first mode uses, 2D data from all n cameras that are used to track the feature in 2D while the second mode selects the best camera pair for every time point and feature of interest. Furthermore, validation of the approach is included in example implementations showcasing the capabilities of the this toolbox. The examples also include illustration of 2D to 3D reconstruction workflow with preprocessing steps such as image undistortion, automatic selection of cameras containing well tracked 2D features and application of suitable temporal filters on the reconstructed 3D trajectories.

## Table of Contents
  * [Why pose3d?](#Why-pose3d)
  * [Running demos](#Running-demos)
  * [Using pose3d for your data](#Using-pose3d-for-your-data)
  * [Data requirements for pose3d](#Data-requirements-for-pose3d)
  * [Dependencies](#dependencies)
  * [Troubleshooting](#Troubleshooting)
  * [Installation](#installation)
  * [Citation](#citation)
  * [Acknowledgements](#acknowledgements)

## Why pose3d?
Behavior tracking in lab environments was recently revolutionized by [DeepLabCut (DLC)](https://github.com/AlexEMG/DeepLabCut): a markerless tracking software.
While DLC provides excellent tools for 2D tracking, scope for development of 3D reconstruction workflows especially for 2D behavior tracking made from more than two cameras still exists. [Anipose](https://github.com/lambdaloop/anipose) and [DLC](https://www.nature.com/articles/s41596-019-0176-0) offer implementations in python using OpenCV package in Python for camera calibration and 3D reconstruction. Camera calibration is a necessary step for 3D reconstruction in which checkboard images acquired from a camera are used to estimate its lens properties such as focal length and principal point. When checker board images are acquired simultaneous from 2 cameras, the position of one camera with respect to the other can also be obtained. In comparison to openCV, Matlab (The MathWorks Inc., Natick, Massachusetts), has a very user-friendly and graphical user interface (GUI) based camera calibration routine which makes camera calibration much easier to perform. recon3D takes advantage of this function in Matlab and provides a toolbox for 3D reconstruction of features tracked using DLC or any other 2D tracking software as illustrated in Figure 1. Given the popularity of Matlab in academia, we believe this toolbox will help make 3D reconstruction of tracked 2D behavior easier for researchers to use.<br/>

![](ExampleGrasping_2Dto3D_whitebg.gif)<br/>
*Figure 1: Reconstruction in 3D of grasping behavior tracked in 2D using DeepLabCut*


## Running demos
1) Download the repository and from the main folder of the repository run **./Codes/demo_DLC2d.m** to perform 3D reconstruction of corners of a Rubik's cube tracked in 2D using DLC. Since all the pre-processing steps have been already done for the demo, click proceed when message boxes pop-up.
2) Similiar to the first demo from the main folder of the repository, run **./Codes/demo_other2d.m** to perform 3D reconstruction of corners of a Rubik's cube tracked in 2D using any other 2D tracking software. Here we mimick other software by manual 2D tracking.<br/>

## Using pose3d for your data
Follow the below steps to perform 3D reconstruction of your 2D tracked data. <br/>
1) Edit **./Codes/template_config_file.m** file to enter your project specific information. <br/>
2) Run **./Codes/main_pose3d.m** with your config file to save 3D reconstructed data for your project. <br/>
3) The main_pose3d script is semi-automated. When user input is required message boxes pop-up in Matlab and wait for your response. Follow the messages to perform 3D reconstruction. <br/>

## Data requirements for pose3d
1) Record behavior of interest from multiple cameras (n > 2) and track features of interest across these cameras using DLC or any other 2D tracking software. <br/>
2) Save 2D tracked data in .csv format and keep these files accessible from the computer in which you want to use pose3d toolbox on. <br/>
3) Record checkerboard calibration videos by fixing one of your setup cameras as primary. Primary camera should be selected such that you can obtain checker board images simulataneously with the primary and every other camera in full view. For instance, if you have 3 cameras, let us call one as primary and the remaining cameras as secondary 1 and secondary 2. From this setup,first record checkerboard videos with cameras primary and secondary 1 simultaneously. Next record checkerboard videos with cameras primary and secondary 2 simultaneously. Save these videos and have them accesible from your computer. <br/>
Note : If you are using DLC for 2D tracking and have saved the csv files after analysing videos you already meet requirements 1 & 2 stated above.

## Dependencies 
In-built functions of Matlab, Computer Vision Toolbox. Code has been tested on MATLAB 2018b across linux, MAC and Windows operating systems.<br/>

## Troubleshooting 
1) Mismatch between 2D tracked csv and calibration files. <br/>
-- In this case there will be failure in 3D reconstruction since data from one camera will be transformed using camera matrix of a different camera.  To avoid this, ensure that the order of 2D data and calibration files is maintained across the config file. Refer to the comments in the template config file for more details.<br/>
2) Poor estimation of the intrinsic and extrinsic parameters.<br/>
-- To avoid this case, present the checker board in different angles and record it in full view from both the primary and secondary cameras. If you are making calibration videos, ensure that the whole checkboard is clearly visible in most if not all frames. In addition, check the re-projection errors in the stereo camera calibration GUI to remove outliers and recalibrate for better results. <br/>
3) Camera movement between recording calibration videos and behavior. <br/>
-- Ensure that your cameras are fixed between recording sessions. Everytime you suspect that the cameras have moved record new calibration videos. <br/>
4) Positioning of the cameras is not optimal or number of cameras is not sufficient for the behavior of interest. <br/>
-- For every feature of interest you want to track, you must be able to perform 2D tracking reliably from atleast two cameras. Ensure to have sufficent number of cameras to track the behavior of interest and position them such that their centers are not along a single line or a plane. <br/>
5) Our toolbox is designed to work with [stereoCameraCalibrator](https://www.mathworks.com/help/vision/ug/stereo-camera-calibrator-app.html) GUI in MATLAB. The GUI requires simulataneously acquired images from the two cameras to have the same name and saved it different folders. In case you have acquired calibration videos, all you need ot do is edit the config file to enter the path and name of the calibration videos and pose3d automatically does the rest for you. In case you have acquired images from calibration, please ensure that the simultaneously acquired images have same names and are saved in different folders. <br/>


## Installation
To install this toolbox, add all contents of this repository to Matlab path. 

## Citation
For questions on the toolbox and citation please contact us at swathishesh@gmail.com or HScherberger@dpz.eu

## Acknowledgements
We are very thankful to Mackenzie Mathis and Alexandar Mathis for their help in getting us going with using vision based tracking with DLC. Discussions with several colleagues at the German Primate Center including Andrej Fillipow, Michael Berger, Sebastian Mueller and Daniela Buchwald were very useful for the development of our tracking experimental setup. Thanks also to Viktorija Schek for testing out some of our implementations. 

