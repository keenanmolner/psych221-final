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

%% Import an image and turn it into an ISET scene
% Assumes the image is displayed on an Apple LCD
imgFileName = 'macbeth.tif';
dispLCDFile = 'LCD-Apple.mat';

% check the file names
if ~exist(imgFileName,'file'), error('Image file not found'); end
if ~exist(dispLCDFile,'file'), error('LCDDisplay file not found.'); end

scene = sceneFromFile(imgFileName,'rgb',[],dispLCDFile);
scene = sceneSet(scene,'name','Scene generated in Unity');
vcAddAndSelectObject('scene',scene); sceneWindow;

%% change the field of view of the scene
scene = sceneSet(scene,'hfov',0.5);  % In degrees of visual angle
hFOV = sceneGet(scene,'hfov')

%% change the distance to the scene
scene = sceneSet(scene,'distance',1.0);  % In degrees of visual angle
distance = sceneGet(scene,'distance')

%% look at some info about the scene 
degreesPerSample = sceneGet(scene, 'degrees per sample')

%% Now let's create some human optics and a human sensor
oi = oiCreate; %human optics
oi = oiSet(oi,'hfov',0.5); % set teh field of view of the eye
oiGet(oi, 'hfov') %make sure it was set
fNumber = 10; %desired fNumber of the eye
oi  = oiSet(oi,'optics fNumber',fNumber); %set the fNumber
oiGet(oi, 'optics fNumber') %make sure it was set

oi = oiCompute(oi,scene); % image the scene
% Let's have a look
vcNewGraphWin;
oiShowImage(oi);


%% Now, let's compute the cone absorptions for a sample human retina

% This is a default spatial array of human cones on a rectangular lattice.
cones = sensorCreate('human');

% We combine the oi and the cones to calculate the cone absorption rates
cones = sensorCompute(cones,oi);

% The lightness of each point indicates the cone absorption rate
vcNewGraphWin;
img = coneImageActivity(cones);
imagesc(img); axis off; axis image


