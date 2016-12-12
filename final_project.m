% Psych 221
% Final Project
% Robert Konrad & Keenan Molner

%% install ISETBIO
clc; close all; clear all;
projDir = pwd; %project directory
cd(fullfile(userpath, 'Add-Ons/isetbio')); % Asumses ISETBIO is stored in MATLAB directory on user machine
addpath(genpath(pwd)); % add all of ISETBIO
cd(projDir); %cd to proj directory
ieInit; % initialize ISETBIO

%% import images from the directory
dispLCDFile = 'LCD-Apple.mat';
degrees = [0 0.2 0.4 0.6 0.8 1];
numScenes = length(degrees);
scenes = {};
for i = 1:numScenes
    name = ['near-far-stimuli/img_', num2str(degrees(i)), '_2.bmp'];
    scenes{i} = sceneFromFile(name,'rgb',[],dispLCDFile);
    sceneName = [num2str(degrees(i)) ,' degree shift, 1m distance'];
    scenes{i} = sceneSet(scenes{i},'name',sceneName);
    %vcAddAndSelectObject('scene',scene); sceneWindow;
end

%% change the field of view and viewing distance of the scene
close all
clc
hFOV = 2; %degrees
desiredDistance = 1; %1m focus
for i = 1:numScenes
    scenes{i} = sceneSet(scenes{i},'hfov',hFOV);  % In degrees of visual angle
    scenes{i} = sceneSet(scenes{i},'distance',desiredDistance);  % In meters
  
end
'done'
%% Now let's create some human optics and a human sensor
clc
oi = oiCreate; %human optics
oi = oiSet(oi,'hfov',hFOV); % set teh field of view of the eye
%oiGet(oi, 'hfov') %make sure it was set
aperture = 4e-3; %human pupil diameter
focal_length = 17e-3; % human focal length
fNumber = focal_length / aperture; %human fNumber
oi  = oiSet(oi,'optics fNumber',fNumber); %set the fNumber
%oiGet(oi, 'optics fNumber') %make sure it was set
'done'
%% compute the optical image of each scene
clc
opticalImages = figure;
for i = 1:numScenes
    oiComputed{i} = oiCompute(oi,scenes{i}); % image the scene
    % Let's have a look
    subplot(1, numScenes, i)
    oiComputedImages{i} = oiShowImage(oiComputed{i});

end
'done'

%% optical flow the retinal images
opticFlow = opticalFlowHS;
reset(opticFlow);
for i = 1:numScenes
    flow{i} = estimateFlow(opticFlow,rgb2gray(oiComputedImages{i}));
    flowPlot{i} = figure;
    plot(flow{i}, 'ScaleFactor', 100)
    title(['Optical flow at image', num2str(i)])
end


%% Now, let's compute the cone absorptions for a sample human retina
clc
close all
% This is a default spatial array of human cones on a rectangular lattice.
cones = sensorCreate('human');
%cones = sensorSet(cones, 'rows', 1000);
%cones = sensorSet(cones, 'cols', 1000);
cones = sensorSet(cones, 'fov', hFOV);
sensorGet(cones, 'rows')
sensorGet(cones, 'cols')
%% We combine the oi and the cones to calculate the cone absorption rates
for i = 1:numScenes
    coneImages{i} = sensorCompute(cones,oiComputed{i});
    retinaVolts{i} = coneImages{i}.data.volts;
    subplot(1, numScenes, i)    
    %img = coneImageActivity(coneImages{i});
    imshow(retinaVolts{i},'Border','tight')
end
'done'
%%
clc
for i = 1:numScenes
    imRescaled{i} = retinaVolts{i}./max(max(retinaVolts{i}));
    bwImages{i} = im2bw(imRescaled{i}, graythresh(imRescaled{i}));
    bwImages{i} = imfill(bwImages{i},'holes');
    centers{i} = regionprops(bwImages{i},'Centroid');
    xCenter(i) = centers{i}(1).Centroid(1);
end

coneDifference = diff(xCenter) % in cones

%%

%delta = img - imgShifted;
fused = imfuse(img, imgShifted );
%numBins = 5;
%fusedEq = histeq(fused,numBins);
imtool(fused)

