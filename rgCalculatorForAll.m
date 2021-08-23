% to get prefer nifti file from the stats.nii.gz
%% Setups
% basic setups
clear;close all
clc;
format;

% This script for BiON

% Folders
sDirResult = './'; 

% 'Results';
  % For BiMR 
    xlRelaxMRFile = 'ax_dwi1BiMRatRelax%d.nii';
    xlConvergenceMRFile = 'ax_dwi1BiMRatConvergence%d.nii';
  % For BiLR 
    xlRelaxLRFile = 'ax_dwi1BiLRatRelax%d.nii';
    xlConvergenceLRFile = 'ax_dwi1BiLRatConvergence%d.nii';
  % For BiON
    xlRelaxONFile = 'ax_dwi1BiONatRelax%d.nii';
    xlConvergenceONFile = 'ax_dwi1BiONatConvergence%d.nii';
    
    
% number of the files
 numOfRelax = 3;
 numOfConvergence = 3;
 % each xlFile means a single result struct
 xlFile = struct('fullfile',[],'nifti',[],'mean',[]);
 % each line of xlFiles includes the results of MR, LR and ON. 
 xlFiles = repmat(xlFile,[numOfRelax + numOfConvergence 3]);
 % each line of xlFiles includes the results of MR-ON, LR-ON and ON. 
 xlAnalysis = zeros(numOfRelax + numOfConvergence, 3);
 % 
 xlMR = zeros(1,6);
 xlLR = zeros(1,6);
 xlON = zeros(1,6);
%RelaxFiles Process
for ii = 1:numOfRelax
    % For BiMR
    xlFiles(ii,1).fullfile = fullfile( sDirResult, sprintf( xlRelaxMRFile, ii) );  
    xlFiles(ii,1).nifti = squeeze( niftiread(xlFiles(ii,1).fullfile));
    % For BiLR
    xlFiles(ii,2).fullfile = fullfile( sDirResult, sprintf( xlRelaxLRFile, ii) );
    xlFiles(ii,2).nifti = squeeze( niftiread(xlFiles(ii,2).fullfile));
    % For BiON
    xlFiles(ii,3).fullfile = fullfile( sDirResult, sprintf( xlRelaxONFile, ii) );
    xlFiles(ii,3).nifti = squeeze( niftiread(xlFiles(ii,3).fullfile));
end

%ConvergenceFiles
for ii = numOfRelax + 1:numOfRelax + numOfConvergence
    % For BiMR
    xlFiles(ii,1).fullfile = fullfile( sDirResult, sprintf( xlConvergenceMRFile, ii-numOfRelax) );
    xlFiles(ii,1).nifti = squeeze( niftiread(xlFiles(ii,1).fullfile));
    % For BiLR
    xlFiles(ii,2).fullfile = fullfile( sDirResult, sprintf( xlConvergenceLRFile, ii-numOfRelax) );
    xlFiles(ii,2).nifti = squeeze( niftiread(xlFiles(ii,2).fullfile));
    % For BiON
    xlFiles(ii,3).fullfile = fullfile( sDirResult, sprintf( xlConvergenceONFile, ii-numOfRelax) );
    xlFiles(ii,3).nifti = squeeze( niftiread(xlFiles(ii,3).fullfile));
end

%% statistic
disp('Results:');
disp('When relax');
for ii = 1:numOfRelax
    fprintf("Result %d:  ",ii);
    % For BiMR
    [~,xlFiles(ii,1).mean]= stas_muscle1(xlFiles(ii,1).nifti);
    fprintf("MR: %8.4f ",xlFiles(ii,1).mean);
    xlMR(1,ii) = xlFiles(ii,1).mean;
    % For BiLR
    [~,xlFiles(ii,2).mean]= stas_muscle1(xlFiles(ii,2).nifti);
    fprintf("LR: %8.4f ",xlFiles(ii,2).mean);
    xlLR(1,ii) = xlFiles(ii,2).mean;
    % For BiON
    [~,xlFiles(ii,3).mean]= stas_muscle1(xlFiles(ii,3).nifti);
    fprintf("ON: %8.4f \n",xlFiles(ii,3).mean);
    xlON(1,ii) = xlFiles(ii,3).mean;

    %Analysis
    xlAnalysis(ii,1) = xlFiles(ii,1).mean - xlFiles(ii,3).mean;
    xlAnalysis(ii,2) = xlFiles(ii,2).mean - xlFiles(ii,3).mean;
    xlAnalysis(ii,3) = xlFiles(ii,3).mean;
end

disp('When convergence')
for ii = numOfRelax + 1:numOfRelax + numOfConvergence
    fprintf("Result %d:  ",ii - numOfRelax);
    % For BiMR
    [~,xlFiles(ii,1).mean] = stas_muscle1(xlFiles(ii,1).nifti);
    fprintf("MR: %8.4f ",xlFiles(ii,1).mean);
    xlMR(1,3+ii-numOfRelax) = xlFiles(ii,1).mean;
    % For BiLR
    [~,xlFiles(ii,2).mean]= stas_muscle1(xlFiles(ii,2).nifti);
    fprintf("LR: %8.4f ",xlFiles(ii,2).mean);
    xlLR(1,3+ii-numOfRelax) = xlFiles(ii,2).mean;
    % For BiON
    [~,xlFiles(ii,3).mean]= stas_muscle1(xlFiles(ii,3).nifti);
    fprintf("ON: %8.4f \n",xlFiles(ii,3).mean);
    xlON(1,3+ii-numOfRelax) = xlFiles(ii,3).mean;

    % For analysis
    xlAnalysis(ii,1) = xlFiles(ii,1).mean - xlFiles(ii,3).mean;
    xlAnalysis(ii,2) = xlFiles(ii,2).mean - xlFiles(ii,3).mean;
    xlAnalysis(ii,3) = xlFiles(ii,3).mean;
end

%Analysis
disp(' ');
disp('Analysis:');

disp('When relax');
fprintf("No    MR-ON     LR-ON     ON \n"); 
for ii = 1 : numOfRelax
    fprintf("%d   ",ii);
    for jj = 1 : 3
           fprintf("%8.4f  ",xlAnalysis(ii,jj));
    end
    fprintf("\n");
end

disp('When convergence')
fprintf("No    MR-ON     LR-ON     ON \n"); 
for ii = numOfRelax + 1:numOfRelax + numOfConvergence
    fprintf("%d   ",ii - numOfRelax);
    for jj = 1 : 3
           fprintf("%8.4f  ",xlAnalysis(ii,jj));
    end
    fprintf("\n");
end