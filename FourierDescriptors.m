clc
clear all
close all

%% Parameters
K=128; % Number of coefficients
threshold = 8; % Threshold to prune coefficients below

%% Main
I = imread('images/leg_bone.tif');

boundary = getSequenceOf2DPoints(I);
sampledBoundary = subsample(boundary,K);
s = writeEachPointAsComplex(sampledBoundary);
a = fft(s);

optimalCoefficients(a)

aPruned = highPassPrune(a,threshold); %fourier descriptors

figure()    
identify(I,aPruned,s);
rotation(I,aPruned,s,50);
scaling(I,aPruned,s,0.75);
starting_point(I,aPruned,s,100);
translation(I,aPruned,s,[100, 50]);
Lgnd = legend('Fourier Descriptor','Translated Boundary');
Lgnd.Position(1) = -0.05;
Lgnd.Position(2) = 0.48;
sgtitle("Fourier Descriptors (# of coefficients="+K+")");

%% Transformations

function identify(I,fourier_descriptors,boundary)
    aApprox = ifft(fourier_descriptors);
    subplot(1,5,1)
    imshow((I));
    hold on, plot(aApprox,'r'),plot(boundary,'g'),title('Identity');
end

function rotation(I,fourier_descriptors,boundary,theta)
    boundary=boundary*exp(j*theta);
    fourier_descriptors = fourier_descriptors*exp(j*theta);
    aApprox = ifft(fourier_descriptors);

    subplot(1,5,2)
    imshow((I));
    hold on, plot(aApprox,'r'),plot(boundary,'g'),title("Rotation (\theta="+theta+")");
end

function scaling(I,fourier_descriptors,boundary,alpha)
    boundary=boundary*alpha;
    fourier_descriptors = fourier_descriptors*alpha;
    aApprox = ifft(fourier_descriptors);

    subplot(1,5,3)
    imshow((I));
    hold on, plot(aApprox,'r'),plot(boundary,'g'),title("Scaling (\alpha="+alpha+")");
end


function starting_point(I,fourier_descriptors,boundary,k0)
    
    % Transform boundary
    [cols rows] = size(boundary);
    for k = 1:rows
        try
            boundary(k) = boundary(k-k0); %Is this the right way to deal with k-k0 <1 ?
        catch
            
        end
    end
    % Transform fourier descriptor
    for u = 1:rows
        fourier_descriptors = fourier_descriptors*exp(-j*2*pi*k0*u/rows); % Use N or K? Inconsistency within slides..
    end
    
    aApprox = ifft(fourier_descriptors);
    subplot(1,5,4)
    imshow((I));
    hold on, plot(aApprox,'r'),plot(boundary,'g'),title("Starting Point (\alpha="+k0+")");
end

function y = ddelta(x)
    if x ==1
        y=1;
    else
        y=0;
    end
end

function translation(I,fourier_descriptors,boundary,delta)
    % Transform boundary
    boundary=boundary+complex(delta(1),delta(2));
    [cols rows] = size(fourier_descriptors);

    % Transform fourier descriptor
    for u = 1:rows
        fourier_descriptors(u)=fourier_descriptors(u)+complex(delta(1),delta(2)).*ddelta(u); %dirac does nothing here?
    end
    aApprox = ifft(fourier_descriptors);
    subplot(1,5,5)
    imshow((I));
    hold on, plot(aApprox,'r'),plot(boundary,'g'),title("Translation (\delta=["+delta(1)+","+delta(2)+"])");
end

%% Functions
function points = getSequenceOf2DPoints(img)
    [rows cols] = find(img~=0);
    points = bwtraceboundary(img, [rows(1), cols(1)], 'N');
end


function sampled = subsample(points, numberOfDesiredSamples)
    sampleFactor = length(points)/numberOfDesiredSamples;
    dist = 1;

    for row = 1:numberOfDesiredSamples
        sampled(row,2)=points(round(dist),2);
        sampled(row,1)=points(round(dist),1);
        dist = dist + sampleFactor;
    end

end

function s = writeEachPointAsComplex(points)    
    [rows cols] = size(points);
    for row = 1:rows
        s(row)=complex(points(row,2),points(row,1));
    end
end

function pruned = highPassPrune(a,threshold)
   [rows cols] = size(a);
    pruned = a;
    for u=1:cols
        if u > threshold & u < cols-threshold
            pruned(u) = 1;
        end
    end
end

function optimalCoefficients(a)
    N = 50
    for n = 2:N
        aPruned = highPassPrune(a,n); %fourier descriptors

        pow = aPruned.*conj(aPruned)
        totalpow(n-1) = sum(pow);
    end
    figure()
    plot(totalpow)
    ylabel("Energy (J)")
    xlabel("Coefficients")
    title("Coefficient Signal Energy")
    grid()
    grid minor
end