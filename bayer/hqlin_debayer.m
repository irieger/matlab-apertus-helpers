% The following algorithm was implemented with help of the Book "Computergrafik und
% Bildverarbeitung, Band II: Bildverarbeitung". 3. Auflage, 2011
% by Alfred Nischwitz,Max Fischer, Peter Haber?cker, Gudrun Socher

% High quality linear demosaicing
% Cutting the outer two pixel lines where no sufficient debayering is possible
function rgbfloat = hqlin_debayer(arifloat)
    rgbfloat(:,:,1) = arifloat(:,:);
    rgbfloat(:,:,2) = arifloat(:,:);
    rgbfloat(:,:,3) = arifloat(:,:);


    % calculate green for non-green pixels
    rgbfloat(3:2:(end-2),4:2:(end-2),2) = ( arifloat(2:2:(end-3),4:2:(end-2)) + arifloat(3:2:(end-2),3:2:(end-3)) + arifloat(4:2:(end-1),4:2:(end-2)) + arifloat(3:2:(end-2),5:2:(end-1)) )/4 + ( 4*arifloat(3:2:(end-2),4:2:(end-2)) - arifloat(1:2:(end-4),4:2:(end-2)) - arifloat(3:2:(end-3),2:2:(end-4)) - arifloat(3:2:(end-2),6:2:(end)) - arifloat(5:2:(end),4:2:(end-2)) )/8;
    rgbfloat(4:2:(end-2),3:2:(end-2),2) = (arifloat(4:2:(end-2),2:2:(end-4)) + arifloat(5:2:(end),3:2:(end-2)) + arifloat(4:2:(end-2),4:2:(end-1)) + arifloat(3:2:(end-3),3:2:(end-2)))/4 + ( 4*arifloat(4:2:(end-2),3:2:(end-2)) - arifloat(4:2:(end-2),1:2:(end-4)) - arifloat(6:2:(end),3:2:(end-2)) - arifloat(4:2:(end-2),5:2:(end)) - arifloat(2:2:(end-4),3:2:(end-2)) )/8;


    % calculate red for non-red pixels
    rgbfloat(4:2:(end-2),3:2:(end-2),1) = ( arifloat(3:2:(end-3),2:2:(end-3)) + arifloat(5:2:(end-1),2:2:(end-3)) + arifloat(5:2:(end-1),4:2:(end-1)) + arifloat(3:2:(end-3),4:2:(end-1)) )/4 + ( 4*arifloat(4:2:(end-2),3:2:(end-2)) - arifloat(2:2:(end-4),3:2:(end-2)) - arifloat(4:2:(end-2),1:2:(end-4)) - arifloat(6:2:(end),3:2:(end-2)) - arifloat(4:2:(end-2),5:2:(end)) )*3/16;
    rgbfloat(3:2:(end-2),3:2:(end-2),1) = ( arifloat(3:2:(end-2),2:2:(end-3)) + arifloat(3:2:(end-2),4:2:(end-1)) )/2 + ( 5*arifloat(3:2:(end-2),3:2:(end-2)) + arifloat(1:2:(end-4),3:2:(end-2))/2 + arifloat(5:2:(end),3:2:(end-2))/2 - arifloat(2:2:(end-3),2:2:(end-3)) - arifloat(2:2:(end-3),4:2:(end-1)) - arifloat(4:2:(end-1),2:2:(end-3)) - arifloat(4:2:(end-1),4:2:(end-1)) - arifloat(3:2:(end-2),1:2:(end-4)) - arifloat(3:2:(end-2),5:2:(end)) )/8;
    rgbfloat(4:2:(end-2),4:2:(end-2),1) = ( arifloat(3:2:(end-3),4:2:(end-2)) + arifloat(5:2:(end-1),4:2:(end-2)) )/2 + ( 5*arifloat(4:2:(end-2),4:2:(end-2)) - arifloat(3:2:(end-3),3:2:(end-3)) - arifloat(5:2:(end-1),3:2:(end-3)) + arifloat(4:2:(end-2),2:2:(end-4))/2 - arifloat(5:2:(end-1),5:2:(end-1)) + arifloat(4:2:(end-2),6:2:(end))/2 - arifloat(3:2:(end-3),5:2:(end-1)) - arifloat(2:2:(end-4),4:2:(end-2)) - arifloat(6:2:(end),4:2:(end-2)) )/8;


    % calculate blue for non-blue pixels
    rgbfloat(3:2:(end-2),4:2:(end-2),3) = ( arifloat(2:2:(end-3),3:2:(end-3)) + arifloat(4:2:(end-1),3:2:(end-3)) + arifloat(4:2:(end-1),5:2:(end-1)) + arifloat(2:2:(end-3),5:2:(end-1)) )/4 + ( 4*arifloat(3:2:(end-2),4:2:(end-2)) - arifloat(1:2:(end-4),4:2:(end-2)) - arifloat(3:2:(end-3),2:2:(end-4)) - arifloat(3:2:(end-2),6:2:(end)) - arifloat(5:2:(end),4:2:(end-2)) )*3/16;
    rgbfloat(3:2:(end-2),3:2:(end-2),3) = ( arifloat(2:2:(end-3),3:2:(end-2)) + arifloat(4:2:(end-1),3:2:(end-2)) )/2 + ( 5*arifloat(3:2:(end-2),3:2:(end-2)) - arifloat(1:2:(end-4),3:2:(end-2)) - arifloat(5:2:(end),3:2:(end-2)) - arifloat(2:2:(end-3),2:2:(end-3)) - arifloat(2:2:(end-3),4:2:(end-1)) - arifloat(4:2:(end-1),2:2:(end-3)) - arifloat(4:2:(end-1),4:2:(end-1)) + arifloat(3:2:(end-2),1:2:(end-4))/2 + arifloat(3:2:(end-2),5:2:(end))/2 )/8;
    rgbfloat(4:2:(end-2),4:2:(end-2),3) = ( arifloat(4:2:(end-2),3:2:(end-3)) + arifloat(4:2:(end-2),5:2:(end-1)) )/2 + ( 5*arifloat(4:2:(end-2),4:2:(end-2)) - arifloat(3:2:(end-3),3:2:(end-3)) - arifloat(5:2:(end-1),3:2:(end-3)) - arifloat(4:2:(end-2),2:2:(end-4)) - arifloat(5:2:(end-1),5:2:(end-1)) - arifloat(4:2:(end-2),6:2:(end)) - arifloat(3:2:(end-3),5:2:(end-1)) + arifloat(2:2:(end-4),4:2:(end-2))/2 + arifloat(6:2:(end),4:2:(end-2))/2 )/8;

    
    rgbfloat = rgbfloat(3:(end-2), 3:(end-2), :);
end