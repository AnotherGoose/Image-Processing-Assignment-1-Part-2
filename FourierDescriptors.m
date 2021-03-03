clc
clear all
close all

img = imread('images/chromosome.tif');
K=10; % Number of coefficients

%% The four main bullet points for Fourier Descriptors 1
points = getSequenceOf2DPoints(img);
s = writeEachPointAsComplex(points);
a=fft(s);
sHat = subset(a,K);

%% Display
cApprox = ifft(sHat);
% Show original boundary and approximated boundary
imshow((img));
hold on, plot(cApprox,'r');

%% Functions
function points = getSequenceOf2DPoints(img)
    [i,j,v] = find(img); %gets non-zero values
    N=nnz(img); %number of none zero elements
    points = zeros(N,2);
    for y = 1:N
        points(y,1)=i(y);
        points(y,2)=j(y);
    end
end

function s = writeEachPointAsComplex(points)
    [rows,cols]=size(points);
    s=zeros(rows,1);
    for row = 1:rows
        s(row)=complex(points(row,1),points(row,2));
    end
end

% From https://youtu.be/bG0k3zQSa7w?t=838
% I think the lecture slide has a mistake (indexing over n, rather than u)
function s = subset(a,P)
    [N,cols]=size(a);
    s=zeros(N,1);
    for k = 1:N
        for u = 1:P
            s(k)=s(k) + (a(u)*exp((2j*pi*u*k)/P));
        end
        s(k)=s(k)/P;
    end
end