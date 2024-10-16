%% Load images and corresponding camera matrices
im1=imread('im1.jpg');
im2=imread('im2.jpg');
load P1
load P2

% The given image coordinates were originally localized manually.
% The point correspondences are the same as in round 8.
% That is, 11 points (A,B,C,D,E,F,G,H,L,M,N) are marked from both images.
labels={'a','b','c','d','e','f','g','h','l','m','n'};

x1 = 1.0e+03 * ...
   [0.7435;...
    3.3315;...
    0.8275;...
    3.2835;...
    0.5475;...
    3.9875;...
    0.6715;...
    3.8835;...
    1.3715;...
    1.8675;...
    1.3835];
y1=1.0e+03 * ...
   [0.4455;...
    0.4335;...
    1.7215;...
    1.5615;...
    0.3895;...
    0.3895;...
    2.1415;...
    1.8735;...
    1.0775;...
    1.0575;...
    1.4415];

x2=1.0e+03*...
    [0.5835;...
    3.2515;...
    0.6515;...
    3.1995;...
    0.1275;...
    3.7475;...
    0.2475;...
    3.6635;...
    1.1555;...
    1.6595;...
    1.1755];

y2=1.0e+03*...
    [0.4135;...
    0.4015;...
    1.6655;...
    1.5975;...
    0.3215;...
    0.3135;...
    2.0295;...
    1.9335;...
    1.0335;...
    1.0255;...
    1.3975];
      
figure;imshow([im1 im2]);hold on
plot(x1,y1,'c+','MarkerSize',10);
plot(x2+size(im1,2),y2,'c+','MarkerSize',10);
for i=1:length(x1)
    ti=text(x1(i),y1(i),labels{i});
    ti.Color='cyan';
    ti.FontSize=20;
    ti=text(x2(i)+size(im1,2),y2(i),labels{i});
    ti.Color='cyan';
    ti.FontSize=20;
end

% F matrix can be computed from the projection matrices if they are known
FfromPs=vgg_F_from_P(P1, P2)
eplines=FfromPs*[x1(:)';y1(:)';ones(1,11)];
for i=1:length(x1)
    plot([1 size(im2,2)]+size(im1,2),(-eplines(1,i)*[1 size(im2,2)]-eplines(3,i))/eplines(2,i),'c-');
end

%% Implement the 8 point method and the normalized 8 point method for F-matrix estimation
% Uncomment the following lines after implementing 'estimateF' and 'estimateFnorm'

% % the eight-point algorithm
F=estimateF([x1 y1 ones(11,1)],[x2 y2 ones(11,1)]);

% % the normalized eight-point algorithm
Fnorm=estimateFnorm([x1 y1 ones(11,1)],[x2 y2 ones(11,1)])
 
eplinesA=F*[x1(:)';y1(:)';ones(1,11)];
for i=1:length(x1)
    plot([1 size(im2,2)]+size(im1,2),(-eplinesA(1,i)*[1 size(im2,2)]-eplinesA(3,i))/eplinesA(2,i),'m-');
end
% 
eplinesB=Fnorm*[x1(:)';y1(:)';ones(1,11)];
for i=1:length(x1)
    plot([1 size(im2,2)]+size(im1,2),(-eplinesB(1,i)*[1 size(im2,2)]-eplinesB(3,i))/eplinesB(2,i),'y-');
end

function F = estimateF(pts1, pts2)
    % Implement the eight-point algorithm
    A = zeros(size(pts1, 1), 9);

    for i = 1:size(pts1, 1)
        A(i, :) = kron(pts1(i, :), pts2(i, :));
    end

    [~, ~, V] = svd(A);
    F = reshape(V(:, end), 3, 3)';

    % Ensure rank 2
    [U, S, V] = svd(F);
    S(3, 3) = 0;
    F = U * S * V';

end

function [ptsNormalized, T] = normalizePoints(pts)
    % Normalize points by scaling and translating to have zero mean and
    % average distance 2 from the origin

    % Compute mean of points
    meanPts = mean(pts);

    % Translate points to have zero mean
    ptsCentered = pts - meanPts;

    % Compute average distance from the origin
    avgDist = 2/mean(sqrt(ptsCentered(:,1).^2 + ptsCentered(:,2).^2));

    % Scale points
    ptsNormalized = ptsCentered * avgDist;
    ptsNormalized(:,3)=1;

    % Transformation matrix for denormalization
    T = [avgDist, 0, -meanPts(1)*avgDist;
         0, avgDist, -meanPts(2)*avgDist;
         0, 0, 1];
    
end


function Fnorm = estimateFnorm(pts1, pts2)
    
    % Normalize coordinates
    [pts1, T1] = normalizePoints(pts1);
    [pts2, T2] = normalizePoints(pts2);

    Fnorm = estimateF(pts1, pts2);

    % Denormalize Fnorm
    Fnorm = T2' * Fnorm * T1;
end

