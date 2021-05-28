function [X,reprojErr] = triangulate_ncams(points,cam_mat,idx_goodness,reconMode)
% triangulation function for 3D reconstruction
%
% Inputs: 
% Required: 
% ---------
% 1) points size(2*ncams); 
% points are the (x,y) pixel coordinates obtained from 2D tracking
%
% 2) cam_mat size(3*4*ncams)
% Camera matrices are obtained as described below assuming you have stereo calibrated cameras in pairs:
% Example for primary camera 
% cam_mat = cameraMatrix(stereoParams.CameraParameters1, eye(3), [0 0 0])'; 
% For secondary camera
% cam_mat = cameraMatrix(stereoParams.CameraParameters2,stereoParams.RotationOfCamera2, stereoParams.TranslationOfCamera2)';
%
% Optional Inputs:
% ----------------
% 3)idx_goodness size(ncams*1)
% Rank for cameras based on 
% 4)reconMode select from below 3 options
%
% 1. 'all' (Recommended mode) 2D tracked data from all cameras is used for reconstruction
% 
% 2. 'bestpair' (2D tracked data from best camera pair is used for 3D
% reconstruction for every time point and feature)
% 3. 'avg' (3D reconstructed data averaged over all pairs)
%
% Outputs: 
% --------
% X : 3D reconstructed point
% reprojErr : reprojection error 

% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d

% Check number of inputs.
if nargin > 4
    error('Too many inputs, function requires at most 4 inputs');
end
if nargin < 2
    error('Not enough inputs');
end
numCams = size(points,2);
% Filling in unset optional values.
switch nargin
    case 2
        idx_goodness = ones(numCams,1);
        reconMode = 'all';
    case 3
        reconMode = 'all'; 
end



%Triangulation for reconstruction
switch reconMode

    case 'all'
        
        A = zeros(numCams * 2, 4);

        for i = 1:numCams    
            idx = 2 * i;
            A(idx-1:idx,:) = points(:, i) * cam_mat(3,:,i) - cam_mat(1:2,:,i);
        end

        [~,~,V] = svd(A);
        X = V(:, end);
        X = X/X(end);
        X = X(1:3);
        
        % calculate reprojection error
        reprojErr = nan(1,numCams);
        for i = 1:numCams  
          reprojPoint = cam_mat(:,:,i)*[X; 1];
          reprojPoint = reprojPoint/reprojPoint(end);
          reprojErr(i) = norm(points(:, i) - reprojPoint(1:2));
        end
        
    case 'bestpair' %Use this case if by design only 2 cams can see a feature at a time
        
        points = points(:,idx_goodness(1:2));
        cam_mat = cam_mat(:,:,idx_goodness(1:2));
        
        A = zeros(2*2, 4); %2 cams, 2 independent equations per camera, 4 variables (X, Y, Z, scale=1)

        for i = 1:2    
            idx = 2 * i;
            A(idx-1:idx,:) = points(:, i) * cam_mat(3,:,i) - cam_mat(1:2,:,i);
        end

        [~,~,V] = svd(A);
        X = V(:, end);
        X = X/X(end);
        X = X(1:3);

        % calculate reprojection error
        reprojErr = nan(1,numCams);
        for i = 1:2  
          reprojPoint = cam_mat(:,:,i)*[X; 1];
          reprojPoint = reprojPoint/reprojPoint(end);
          reprojErr(idx_goodness(i)) = norm(points(:, i) - reprojPoint(1:2));
        end
        
    case 'avg' % this is included for comparison purposes only 
        
        combos_2 = nchoosek(1:numCams,2); %list of all camera pairs

        A = zeros(2 * 2, 4); %2 cams, 2 independent equations per camera, 4 variables (X, Y, Z, scale=1)
        num_pairs = size(combos_2,1);
        Xall = nan(3,num_pairs); % all pairwise 3D reconstructions
        
        for ipairs = 1:num_pairs
            
            for i = 1:2
                idx = 2 * i;
                A(idx-1:idx,:) = points(:, combos_2(ipairs,i)) * cam_mat(3,:,combos_2(ipairs,i)) - cam_mat(1:2,:,combos_2(ipairs,i));
            end

            [~,~,V] = svd(A);
            X = V(:, end);
            X = X/X(end);
            Xall(1:3,ipairs) = X(1:3);
            
        end
        X = mean(Xall,2); %average across all pairs

        % calculate reprojection error
        reprojErr = nan(1,numCams);
        for i = 1:numCams  
          reprojPoint = cam_mat(:,:,i)*[X; 1];
          reprojPoint = reprojPoint/reprojPoint(end);
          reprojErr(i) = norm(points(:, i) - reprojPoint(1:2));
        end
end
