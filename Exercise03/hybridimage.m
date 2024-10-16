%% Uncomment the commented code lines and implement missing functions 
% (and anything else that is asked or needed)

%% Load test images.
man=double(imread('man.jpg'));
wolf=double(imread('wolf.jpg'));

% the pixel coordinates of eyes and chin have been manually found 
% from both images in order to enable affine alignment 
man_eyes_chin=[452 461;652 457;554 823];
wolf_eyes_chin=[851 919; 1159 947; 975 1451];
[A,b]=affinefit(man_eyes_chin', wolf_eyes_chin');

[X,Y]=meshgrid(1:size(man,2), 1:size(man,1));
pt=A*([X(:) Y(:)]')+b*ones(1,size(man,1)*size(man,2));
wolft=interp2(wolf,reshape(pt(1,:),size(man)),reshape(pt(2,:),size(man)));

%% Below we simply blend the aligned images using additive superimposition
additive_superimposition=man+wolft;

%% Next we create two different Gaussian kernels for low-pass filtering
sigmaA = 17;%7; 
sigmaB = 17;%2; 
filterA = fspecial('Gaussian', ceil(sigmaA*4+1), sigmaA);
filterB = fspecial('Gaussian', ceil(sigmaB*4+1), sigmaB);

man_lowpass = imfilter(man, filterA, 'replicate');
wolft_lowpass= imfilter(wolft, filterB, 'replicate');

%% Task:
% Your task is to create a hybrid image by combining a low-pass filtered 
% version of the human face with a high-pass filtered wolf face.
%
% HINT: You get a high-pass version by subtracting the low-pass filtered version
% from the original image. Experiment also by trying different values for
% 'sigmaA' and 'sigmaB' above.
%
% Thus, your task is to replace the zero image on the following line
% with a high-pass filtered version of 'wolft'
wolft_highpass = wolft - wolft_lowpass;
%wolft_highpass=zeros(size(man_lowpass));

% Calculate the Fourier transforms and their log magnitudes
man_fft = fft2(man);
man_lowpass_fft = fft2(man_lowpass);
man_highpass_fft = fft2(man - man_lowpass);

wolf_fft = fft2(wolf);
wolf_lowpass_fft = fft2(wolft_lowpass);
wolf_highpass_fft = fft2(wolft_highpass);

% Shift the zero frequency component to the center
man_fft_shifted = fftshift(man_fft);
man_lowpass_fft_shifted = fftshift(man_lowpass_fft);
man_highpass_fft_shifted = fftshift(man_highpass_fft);

wolf_fft_shifted = fftshift(wolf_fft);
wolf_lowpass_fft_shifted = fftshift(wolf_lowpass_fft);
wolf_highpass_fft_shifted = fftshift(wolf_highpass_fft);

% Calculate the log magnitudes
man_fft_log = log(abs(man_fft_shifted) + 1); % Add 1 to avoid log(0)
man_lowpass_fft_log = log(abs(man_lowpass_fft_shifted) + 1);
man_highpass_fft_log = log(abs(man_highpass_fft_shifted) + 1);

wolf_fft_log = log(abs(wolf_fft_shifted) + 1);
wolf_lowpass_fft_log = log(abs(wolf_lowpass_fft_shifted) + 1);
wolf_highpass_fft_log = log(abs(wolf_highpass_fft_shifted) + 1);

% Visualize the log magnitudes of the Fourier transforms
figure;
subplot(2, 3, 1); imshow(man_fft_log, []); title('Man FFT Log Magnitude');
subplot(2, 3, 2); imshow(man_lowpass_fft_log, []); title('Man Low-Pass FFT Log Magnitude');
subplot(2, 3, 3); imshow(man_highpass_fft_log, []); title('Man High-Pass FFT Log Magnitude');
subplot(2, 3, 4); imshow(wolf_fft_log, []); title('Wolf FFT Log Magnitude');
subplot(2, 3, 5); imshow(wolf_lowpass_fft_log, []); title('Wolf Low-Pass FFT Log Magnitude');
subplot(2, 3, 6); imshow(wolf_highpass_fft_log, []); title('Wolf High-Pass FFT Log Magnitude');

%% Replace also the zero image below with the correct hybrid image
%hybrid_image=zeros(size(man_lowpass));
hybrid_image = man_lowpass + wolft_highpass;

%% Visualization and interpretation
% Notice how strongly the interpretation of the hybrid image is affected 
% by the viewing distance
fighybrid=figure;colormap('gray');imagesc((hybrid_image));axis image;
%
% Display input images and both output images.
figure; clf;
set(gcf,'Name','Results of superimposition');

subplot(2,2,1); imagesc(man);
axis image; colormap gray;
title('Input Image A');

subplot(2,2,2); imagesc(wolf);
axis image; colormap gray;
title('Input Image B');

subplot(2,2,3); imagesc(additive_superimposition);
axis image; colormap gray;
title('Additive Superimposition');

subplot(2,2,4); imagesc(hybrid_image);
axis image; colormap gray;
title('Hybrid Image');

%figure(fighybrid)