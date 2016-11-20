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

