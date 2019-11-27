# 3D reconstrution toolbox for behavior tracked with multiple cameras 

## What is pose3d?
pose3d is implemented in Matlab (The MathWorks Inc., Natick, Massachusetts) for 3D reconstruction of features tracked in 2D using DeepLabCut (DLC) or any other tracking software. It provides a semi-automated 3D reconstruction workflow that takes users through the process of camera calibration, undistortion, triangulation as well as post processing steps such as filtering to reduce outliers. In addition to providing an easy to use workflow, the key component in our implementation is the ‘n’ camera triangulation function that allows users to select 2D tracked data from the best pair of cameras for every feature and time point using an automated selection criterion or use data from all cameras for 3D reconstruction.

## Table of Contents
  * [Why pose3d?](#Why-pose3d)
  * [Running demos](#Running-demos)
  * [Using pose3d for your data](#Using-pose3d-for-your-data)
  * [Data requirements for pose3d](#Data-requirements-for-pose3d)
  * [Checkerboard images or videos for calibration](#Checkerboard-images-or-videos-for-calibration)
  * [Dependencies](#dependencies)
  * [Video tutorial and troubleshooting](#Video-tutorial-and-troubleshooting)
  * [Installation](#installation)
  * [Citation](#citation)
  * [Acknowledgements](#acknowledgements)

## Why pose3d?
Markerless tracking is a crucial experimental requirement for behavioral studies conducted in many species in different enviroments. A recently developed toolbox called [DeepLabCut (DLC)](https://github.com/AlexEMG/DeepLabCut) leverages Artificial Neural Network (ANN) based computer vision to make precise markerless tracking possible for scientific experiments. To track complex behaviors such as grasping with object interaction in 3D as illustrated in Figure 1, experimental setups with multiple cameras have to be developed. Development of such systems can largely benefit from a robust and easy to use camera calibration and 3D reconstruction toolbox. To this end, we developed pose3d, a semi-automated 3D reconstruction toolbox in Matlab. Given the popularity of Matlab in academia, we believe this toolbox will help make 3D reconstruction of 2D tracked behavior easier for researchers to use.<br/>

![](ExampleGrasping_2Dto3D.gif)<br/>
*Figure 1: Reconstruction in 3D of grasping behavior tracked in 2D using DeepLabCut*

## Running demos
1) Download or clone our pose3d repository. From the main folder of the repository run **./Codes/demo_DLC2d.m** to perform 3D reconstruction of the corners of a Rubik's cube tracked in 2D using DLC. <br/>
-- Since undistortion, camera calibration and 3D reconstruction have already been done and saved for the demo, click 'no' when message boxes pop-up and ask if you want to save. 2D tracked data and videodata used for this demo are included in the DemoData folder for reference. 
2) Similiar to the first demo from the main folder of the repository, run **./Codes/demo_other2d.m** to perform 3D reconstruction of the corners of a Rubik's cube tracked in 2D using any other 2D tracking software. Here we mimick other software by manual 2D tracking.<br/>

## Using pose3d for your data
Follow the below steps to perform 3D reconstruction of your 2D tracked data. <br/>
1) Edit **./Codes/template_config_file.m** file to enter your project specific information. <br/>
2) Run **./Codes/main_pose3d.m** with your config file to save 3D reconstructed data for your project. <br/>
3) The main_pose3d script is semi-automated. When user input is required message boxes pop-up in Matlab and wait for your response. Follow the messages to perform 3D reconstruction. <br/>
-- Upon running main_pose3d.m, you will find a folder created for all your experiments with a sub-folder for your current experiment using names provided by you in the config file. Calibration images will be extracted from calibration videos (or directly copied if you already have calibration images) and sorted for you as illustrated in ./DemoExperiments/Imagesforcalibration/ folder. Furthermore, within your current experiment folder, a folder for 3D reconstructed data called Data3d will be created where results of 3D reconstruction will be saved as Data3d.mat file. Furthermore, if undistortion and filtering are chosen by you in your config file, a folder each for 2D undistorted data called UndistortedData2d and for filtered 3D data called FilteredData3d will be created. <br/>

## Data requirements for pose3d
1) Record behavior of interest from multiple cameras (n >= 2) and track features of interest across these cameras using DLC or any other 2D tracking software. <br/>
2) Save 2D tracked data in .csv format and keep these files accessible from the computer on which you want to use pose3d toolbox. <br/>
3) Record checkerboard calibration videos by fixing one of your setup cameras as primary. Primary camera should be selected such that you can obtain checker board images simultaneously with the primary and every other camera in full view. For instance, if you have 3 cameras, let us call one as primary and the remaining cameras as secondary 1 and secondary 2. From this setup, first record checkerboard videos with cameras primary and secondary 1 simultaneously. Next record checkerboard videos with cameras primary and secondary 2 simultaneously. Save these videos and have them accessible from your computer. <br/>
Note: If you are using DLC for 2D tracking from 2 or more cameras and have saved the .csv files after analyzing videos you already meet requirements 1 & 2 stated above.<br/>

## Checkerboard images or videos for calibration
1) Print checkerboard for camera calibration
-- This can be done by first typing 'open checkerboardPattern.pdf' in Matlab command line and then printing out the checkerboard layout. Please make sure the layout is attached to a smooth and stable surface before using it for calibration.
2) Present the checkboard to your primary and secondary cameras simultaneously so that the whole frame of the checkerboard is within the field of view of the two cameras. Acquire images or videos of the checkboard being presented at varied angles and distances from the camera. 
3) Matlab's stereoCameraCalibrator GUI recommends using between 10 and 20 frames for calibration. However, we recommend collecting between ~50-100 frames (especially in low light conditions where the checkerboard would be harder to detect), since some of the frames automatically get rejected by the GUI based on the inability to detect whole checkboard or due to the tilt angle of the board being > 45 degree relative to the camera plane.
For tips on acquiring calibration files can be obtained at: [Mathworks' Camera Calibration](https://www.mathworks.com/help/vision/ug/single-camera-calibrator-app.html#bt19jdq-1)<br/>


## Dependencies 
In-built functions of Matlab, Computer Vision Toolbox. Code has been tested on Matlab 2018b across linux, MAC and Windows operating systems. <br/>

## Video tutorial and troubleshooting
Video tutorials to use pose3d can be found at the below links:
[Case 1: 3D reconstruction when calibrating with images](https://www.dropbox.com/s/zp2wh5ltzuwmsvo/Tutorial_with_calib_frames.mov?dl=0) <br/>
[Case 2: For calibration with recorded videos](https://www.dropbox.com/s/fb7mas4fm20q4rj/Tutorial_with_calib_videos.mp4?dl=0) <br/>
Pose3d incorporates message-based interaction to inform the user when problems are detected while using pose3d. This includes checking entries made by the user in the configuration file to check for congruency in the entered values. For instance, if the user sets number of cameras in the setup to 5 but provides lesser number of .csv files containing 2D tracked data, a message informing the user about this problem is provided. However, some problems can occur without producing explicit error messages and are listed below to help users with troubleshooting.
1) Mismatch in the correspondence between 2D tracked .csv files and calibration files. <br/>
-- This issue can occur when the user is editing the configuration file to enter his/her experiment details. When entering file names into variables secondary2D_datafullpath and calibvideos_secondary, the order in which the files corresponding to secondary cameras is entered must be maintained. Otherwise, there will be failure in 3D reconstruction since data from one camera will be transformed using camera matrix of a different camera. To avoid this problem, ensure that the order of 2D data files and calibration files is maintained. See the comments in the template config file for more details. <br/>
2) Poor estimation of the relative positioning of the camera and lens properties such as level of magnification and image distortion.<br/>
-- This can happen if calibration frames are too few and the workspace is not covered sufficiently (at varied distances and angles) by the frames used for calibration. To avoid this case, present the checker board in different angles and record it in full view from both the primary and secondary cameras by moving it about the entire workspace. If you are making calibration videos, ensure that the whole checkboard is clearly visible in most if not all frames. In addition, check the re-projection errors in the stereo camera calibration GUI to remove outliers (right click on the images displayed on the data browser of the GUI and select remove and recalibrate) for better results. If you are unsure of the kind of calibration videos or images to take, please see our example calibration images in the ./DemoExperiments/Imagesforcalibration/ folder. See section [Checkerboard images or videos for calibration](#Checkerboard-images-or-videos-for-calibration) in this readme for more details on calibration. <br/>
3) Camera movement between recording calibration videos and behavior. <br/>
-- Ensure that your cameras are fixed between recording sessions. Record and use new calibration videos everytime you suspect that the cameras in your setup have moved. <br/>
4) Positioning of the cameras is not optimal or number of cameras is not sufficient for the behavior of interest. <br/>
-- For every feature of interest you want to track, you must be able to perform 2D tracking reliably from at least two cameras. Ensure to have sufficent number of cameras to track the behavior of interest and position the cameras such that they cover the tracking workspace as much as possible. <br/>
5) Our toolbox is designed to work with [stereoCameraCalibrator](https://www.mathworks.com/help/vision/ug/stereo-camera-calibrator-app.html) GUI in Matlab. The GUI requires simulataneously acquired images from the two cameras to have the same name and saved it different folders. In case you have acquired calibration videos, all you need to do is edit the config file to enter the path and name of the calibration videos and pose3d automatically does the rest for you. In case you have acquired images from calibration, please have your images labelled as shown in ./DemoExperiments/Imagesforcalibration/ folder. pose3d automatically goes through every primary and secondary camera pairs and prompts you to select all calibration images per camera. <br/>

## Installation
To install this toolbox, add all contents of this repository to Matlab path. 

## Citation
For questions on the toolbox and citation please contact us at swathishesh@gmail.com or HScherberger@dpz.eu

## Acknowledgements
We are very thankful to Mackenzie Mathis and Alexander Mathis for their help in getting us going with using vision based tracking with DLC. Discussions with several colleagues at the German Primate Center including Andrej Fillipow, Michael Berger, Sebastian Mueller, Attila Trunk and Daniela Buchwald were very useful for the development of our tracking experimental setup. Thanks also to Viktorija Schek for testing out some of our implementations. 
Our implementation in Matlab was inspired by [Anipose](https://github.com/lambdaloop/anipose) - a python toolbox for 3D reconstruction. 

