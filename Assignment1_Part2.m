clc
clear all
close all

BW = (imread('images/licoln.tif'));
%BW = imresize(BW, 0.5)
%BW = (imread('images/circles.png'));
%BW = rgb2gray(BW);
%BW = BW/255;

% a = getPoints(68,18,BW);
% 
% b = nonZero(a);
% 
% c = logicalAND(a(2), a(4), a(6))
% 
% g = checkTransitions([1, 0, 1, 0, 1, 0, 1, 1, 0])
% 
% d = getPoints(0,0,BW);
% 
% e = nonZero(d);
% 
% f = logicalAND(d(4), d(6), d(8))

tImg = BW;
same = 0;
prevI = tImg;
counter = 0
while same == 0
    tImg = step1(tImg);
    tImg = step2(tImg);
    same = sameArray(prevI, tImg);
    prevI = tImg;
    counter = counter + 1;
end

BW = BW*255;
tImg = tImg*255;

figure();
imshow(BW);

figure();
imshow(tImg);

function tImg = step1(img)
    [rows,cols] = size(img);
    tImg = img;
    %Step 1
    for i = 1:rows
        for j = 1:cols
            %Loop through Image
            pWindow = getPoints(i, j, img);
            a = nonZero(pWindow);
            b = checkTransitions(pWindow);
            c = logicalAND(pWindow(2), pWindow(4), pWindow(6));
            d = logicalAND(pWindow(4), pWindow(6), pWindow(8));
            
           if a == true && b == true &&...
                   c == true && d == true
               tImg(i, j) = 0;
           end
            
        end
    end
end

function tImg = step2(img)
    [rows,cols] = size(img);
    tImg = img;
    %Step 1
    for i = 1:rows
        for j = 1:cols
            %Loop through Image
            pWindow = getPoints(i, j, img);
            a = nonZero(pWindow);
            b = checkTransitions(pWindow);
            c = logicalAND(pWindow(2), pWindow(4), pWindow(8));
            d = logicalAND(pWindow(2), pWindow(6), pWindow(8));
            
           if a == true && b == true &&...
                   c == true && d == true
               tImg(i, j) = 0;
           end
            
        end
    end
end

function pArray = getPoints(x, y, array)
    
    p1 = checkPoint(x, y, array);
    p2 = checkPoint(x, y - 1, array);
    p3 = checkPoint(x + 1, y - 1, array);
    p4 = checkPoint(x + 1, y, array);
    p5 = checkPoint(x + 1, y + 1, array);
    p6 = checkPoint(x, y + 1, array);
    p7 = checkPoint(x - 1, y + 1, array);
    p8 = checkPoint(x - 1, y, array);
    p9 = checkPoint(x - 1, y - 1, array);
    pArray = [p1, p2, p3, p4, p5, p6, p7, p8,p9];
end

function point = checkPoint(x, y, array)
    try 
        point = array(x, y);
    catch
        point = 0; 
    end
end

function result = nonZero(pArray)
    %2 <= N(p1) <= 6
    N = width(pArray);
    sum = 0;
    for i = 2: N

        sum = sum + pArray(i);
    end
    if 2 <= sum && sum <= 6
        result = true;
    else
        result = false;
    end
end

function result = checkTransitions(pArray)
    %T(p1)
    N = width(pArray);
    sum = 0;
    prevP = pArray(1);
    
    for i = 2: N
        if prevP < pArray(i)
            sum = sum + 1;
        end
        prevP = pArray(i);
    end
    
    if pArray(9) <  pArray(2)
        sum = sum + 1;
    end
    
    if sum == 1
        result = true;
    else
        result = false;
    end
end

function result = logicalAND(a, b, c)
    %p2 . p4 . p6
    %p4 . p6 . p8
    sum = a * b * c;
     if sum == 0
         result = true;
     else
         result = false;
     end
     
end

function result = sameArray(pred, target)
    comparedArray = (pred == target);    %returns array with values 1 (same index element equal)
                                        % or 0 (same index element different)
    if all(comparedArray==1)            % checks all values are 1 (a==b was true for every element)
        result = true;
    else
        result = false;
    end
end
