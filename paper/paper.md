---
title: '3D reconstruction toolbox for behavior tracked with multiple cameras'
tags:
  - 3D reconstruction
  - Multiple cameras
  - Pose extraction
  - Behavior tracking
authors:
 - name: Swathi Sheshadri
   orcid: 0000-0003-2850-107X
   affiliation: "1, 2"
 - name: Benjamin Dann
   orcid: 0000-0003-4332-0285
   affiliation: "1"
 - name: Timo Hueser
   orcid: 0000-0003-3998-4222
   affiliation: "1"
 - name: Hansjoerg Scherberger
   orcid: 0000-0001-6593-2800
   affiliation: "1, 2"
affiliations:
 - name: German Primate Center, Goettingen, Germany
   index: 1
 - name: Department of Biology and Psychology, University of Goettingen, Germany
   index: 2
date: 16 July 2019
bibliography: paper.bib
---

# Summary
Markerless tracking is a crucial experimental requirement for behavioral studies conducted across species in different enviroments. A recently developed toolbox called DeepLabCut (DLC) (@Mathis2018) leverages Artificial Neural Network (ANN) based computer vision to make precise markerless tracking possible for scientific experiments. DLC uses a deep convolutional neural network, ResNet(@He2016) pre-trained on ImageNet database(@Imagenet) and adapts it to make it applicable for behavioral tracking tasks. <br/>
To track complex behaviors such as grasping with object interaction in 3D, experimental setups with multiple cameras have to be developed. Development of such systems can largely benefit from a robust and easy to use camera calibration and 3D reconstruction toolbox. <br/> 
To map features tracked from multiple cameras using DLC to 3D world coordinates there exists OpenCV (@opencv) based implementations (@Nath2019). In comparison to OpenCV, Matlab (The MathWorks Inc., Natick, Massachusetts) provides a feature-rich graphical user interface (GUI) for camera calibration: an essential step for 3D reconstruction. The GUI provides visual feedback and helps to quickly detect and reduce errors during the calibration process. However, existing functions in Matlab cannot be trivially used to reconstruct 3D behavior from 2D tracked data for more than two cameras. <br/>

Our toolbox pose3d is implemented in Matlab for 3D reconstruction of features tracked in 2D using DLC or any other tracking software. Our toolbox provides a semi-automated 3D reconstruction workflow that take users through the entire process of camera calibration, undistortion, triangulation as well as some post processing steps such as filtering to reduce outliers. pose3d also allows users to try different pre- and post-processing parameters that can be set by simply editing a configuration file and running the main function of the repository called main_pose3d. In addition, pose3d visualizes the results for every run of the main program and helps perform manual parameter sweeping before deciding on saving results. <br/>
The core of our 3D reconstruction workflow is the ‘n’ camera triangulation function available for users in three modes that users can select from based on the knowledge of their experimental design.  The first mode of triangulation is referred to as ‘all’ and uses 2D data from all n cameras that are used to track the feature in 2D. The second mode is referred to as ‘avg’ and performs triangulation over all pairs of cameras in the setup and provides the average over all pairs as the result. The third mode is referred to as ‘best-pair’ and selects the best camera pair for every time point and feature of interest for triangulation. While the first and second modes can be used for 3D reconstruction of features tracked with any software, the third mode is applicable only when 2D features are tracked with DLC.
Furthermore, we provide two demo datasets (details of which are provided in the next paragraph) illustrating the different capabilities of pose3d that users can refer to get a quick introduction to using the toolbox. <br/>
Given the popularity of Matlab in academia and its well documented and easy to use core functions for camera calibration, we believe this toolbox will help make 3D reconstruction of tracked 2D behavior easier for researchers to use. <br/>
# Demo datasets and error measurement in 3D reconstruction 
Demo datasets provided in pose3d were acquired by moving a Rubik’s cube on a table along different directions and by recording it simultaneously from a 5-camera tracking system. For the demos, we track the corners of the cube using DLC in the first example and manually in the second example. Manual annotations are used to mimic the usage of pose3d for any other 2D tracking software. <br/>
The key difference between the two examples is as follows. DLC, in addition to providing 2D tracking provides users with a likelihood value for every tracked feature that informs the users on how confident the network is about the inferred location of that particular feature of interest at any given time point. pose3d makes use of this information, to apply a threshold and automatically select the cameras that cross this threshold for 3D reconstruction. 
From the 2D tracked corners we use pose3d to track corners in 3D over 1000 example frames with DLC and 20 with manual annotations. Following this, we reconstruct the edges of the cube and compare it to the standard edge length of Rubik’s cube (57 mm). In the demo data using DLC based 2D annotations, we obtain an on average error of 1.39 mm in 3D reconstructed edge lengths computed over all 12 edges of the cube across 1000 example frames.  For the demo data using manual annotations across 20 frames we obtain an on average error of 1.16 mm. Furthermore, using ‘all’ mode of triangulation provided significantly better results in both our demo datasets than the other two modes of triangulation (tests included in the demo functions). <br/>
For further reading on details of triangulation for 3D reconstruction please refer to our <br/>
[supporting document](Appendix.pdf)

# References
