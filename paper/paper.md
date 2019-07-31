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
Markerless tracking is a crucial experimental requirement for behavioral studies conducted across species in different enviroments. A recently developed toolbox called DeepLabCut (DLC) (@Mathis2018) leverages neural network based computer vision to make precise markerless tracking possible for scientific experiments. DLC uses a deep convolutional neural network, ResNet(@He2016) pre-trained on ImageNet database(@Imagenet) for object recognition task and retraining it for tracking task. 

While DLC provides excellent tools for 2D tracking, there is scope for development in 3D reconstruction tools particularly when 2D tracking is made from more than two cameras. Anipose (@Anipose), is an available option and is based on OpenCV toolbox in Python. To our knowledge, Matlab currently does not have a similar toolbox to perform 3D reconstruction of 2D points tracked from 'n' cameras. However, Matlab (The MathWorks Inc., Natick, Massachusetts) supports camera calibration, an essential step for 3D reconstruction, with extremely user-friendly graphical user interfaces (GUIs) providing visual feedback to help detect and eliminate errors during the calibration procedure.
recon3D is a toolbox in Matlab for 3D reconstruction of features tracked in 2D using DLC or any other tracking software. The core of this toolbox is a one-shot implementation of triangulation for 3D reconstruction applicable to n cameras. It includes two main modes of 3D reconstruction to be selected based on the design experimental design. The first mode uses, 2D data from all n cameras that are used to track the feature in 2D while the second mode selects the best camera pair for every time point and feature of interest. By default we recommend using the ‘all’ mode, however, only if by design only 2 cameras can detect a feature at any given time point we recommend switching to the ‘best-pair’ mode.
Furthermore, validation of the approach is provided in example implementations show-casing the toolkit capabilities. Tools to perform preprocessing steps such as image undistortion, automatic selection of cameras containing well tracked 2D features and applying temporal filters to smooth the tracked 2D trajectories are included in recon3D. 

# Example dataset and method validation 
Example datasets provided in recon3D were acquired by moving a Rubik’s cube on a table along different directions and by recording it simultaneously from a 5 camera tracking system. In this demo experiment we track the corners of the cube manually in the first example and using DLC in the second example. Manual annotations are used to mimic how one would use recon3D when any software other than DLC for 2D tracking. From the 2D tracked corners we use recon3D to track corners in 3D over 2000 example frames with DLC and 20 with manual annotations. Following this, we reconstruct the edges of the cube and compare it to the standard edge length of Rubik’s cube (57 mm). In using both manual as well as DLC 2D annotations, we obtain on average < 2 mm error in 3D reconstructed edges when using our recommended ‘all’ mode for 3D and higher errors when using the other 2 modes. This dataset thus serves as a tutorial into the application of the different features in our toolbox and importantly also validates our approach. Given the popularity of MATLAB in academia and its well documented and easy to use core functions for camera calibration, we believe this toolbox will help make 3D reconstruction of tracked 2D behavior easier for researchers to use.


For a detailed mathematical consideration of our implementation of 3D reconstruction please refer to our <br/>
[supporting document](Appendix.pdf)



# References
