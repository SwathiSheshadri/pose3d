% reconstruct_3D is called by the main_pose3d script to perform 3D reconstruction 
% There are 3 possible modes of 3D reconstruction
% Edit modes_3drecon in your config file to set mode of 3D construction
% 1. 'all' (2D tracked data from all cameras is used for reconstruction
% (recommended)
% 2. 'bestpair' (2D tracked data from best camera pair is used for 3D
% reconstruction for every time point and feature)
% 3. 'avg' (3D reconstructed data averaged over all pairs)
%
% Copyright (c) 2019 Swathi Sheshadri
% German Primate Center
% swathishesh AT gmail DOT com
%
% If used in published work please see repository README.md for citation
% and license information: https://github.com/SwathiSheshadri/pose3d

if ~flag_mis == 1
%% Remove badly tracked 2D data based on likelihood values from DLC

if usingdlc
    DataAll(DataAll_llh <= llh_thresh) = nan; 
end

%% 3D reconstruction using 2D coordinates tracked from every camera with    

coords3d = nan(nframes,3*nfeatures,length(modes_3drecon));
coords3d_reproj_err = nan(nframes,nfeatures,ncams,length(modes_3drecon));
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
            
            for imodes = 1:length(modes_3drecon)
                [coords3d(t,3*(i-1)+1:3*i,imodes),coords3d_reproj_err(t,i,cams_to_use,imodes)] =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,modes_3drecon{1,imodes});
            end
            
        else
            idx_goodness = ones(ncams,1);
            
            for imodes = 1:length(modes_3drecon)
                [coords3d(t,3*(i-1)+1:3*i,imodes),coords3d_reproj_err(t,i,cams_to_use,imodes)] =  triangulate_ncams(squeeze(DataAll(t,2*(i-1)+1:2*i,cams_to_use)),cam_mat_all(:,:,cams_to_use),idx_goodness,modes_3drecon{1,imodes});
            end
       end

    end
end
%saving 3D data without post-processing (in our experience using triangulate_ncams in 'all' mode
%works best, therefore, saving only that to Data3d folder of your
%experiment
if ~exist([exp_path '/' exp_name '/Data3d/Data3d.mat'],'file') 
    mkdir([exp_path '/' exp_name '/Data3d'])
    save([exp_path '/' exp_name '/Data3d/Data3d.mat'],'coords3d','coords3d_reproj_err')
else
    answer = questdlg('3D data has been previously saved, do you want to save again?','Save latest 3D reconstructed data','Yes','No','Yes');
        % Handle response
        switch answer

            case 'Yes'
                save([exp_path '/' exp_name '/Data3d/Data3d.mat'],'coords3d','coords3d_reproj_err')
                disp('Saved the new results')

            case 'No'
                disp('Previously saved 3D data retained in saved file')

        end        
end
else
    return
end