% Template code to perform 3D reconstruction for your data
% Fill in template_config_your_experiment_DLC2d.m file with your experiment parameters before running this
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/recon3D

if ~flag_mis == 1
%% Remove badly tracked 2D data based on likelihood values from DLC

if usingdlc
    DataAll(DataAll_llh <= llh_thresh) = nan; 
end

%% 3D reconstruction using 2D coordinates tracked from every camera with    
coords3dall = nan(nframes,3*nfeatures); %one-shot 3D reconstruction
coords3dbp = nan(nframes,3*nfeatures); %3D reconstructed from best pair
coords3davg = nan(nframes,3*nfeatures); %averaging 3D reconstructions over pairs
for t = 1:nframes
    
    for i=1:nfeatures
        cams_to_use = ~squeeze(isnan(DataAll(t,2*(i-1)+1,:))); %identifying cameras with 2D tracked points with low likelihood 
        %Need the feature to be visible in atleast 2 cameras for 3D
        if sum(cams_to_use) < 2
            continue
        end
        %Ranking cameras by 2D tracking likelihood, to select best cameras
        %for 3D reconstruction
        if usingdlc
            [~,idx_goodness] = sort(squeeze((DataAll_llh(t,2*(i-1)+1,cams_to_use))),'descend');
            coords3dall(t,3*(i-1)+1:3*i) =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,'all');
            coords3dbp(t,3*(i-1)+1:3*i) =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,'bestpair');
            coords3davg(t,3*(i-1)+1:3*i) =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,'avg');
        else
            idx_goodness = ones(ncams,1);
            coords3dall(t,3*(i-1)+1:3*i) =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,'all');
            coords3davg(t,3*(i-1)+1:3*i) =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,'avg');
        end

    end
end
%saving 3D data without post-processing
if ~exist([exp_path '/' exp_name '/Data3d/Data3d.mat'],'file') 
    mkdir([exp_path '/' exp_name '/Data3d'])
    save([exp_path '/' exp_name '/Data3d/Data3d.mat'],'coords3dall')
else
    disp('3D reconstructed data already exists, therefore not saving again')
end
else
    return
end