% The following algorithm was implemented with help of the Book "Computergrafik und
% Bildverarbeitung, Band II: Bildverarbeitung". 3. Auflage, 2011
% by Alfred Nischwitz,Max Fischer, Peter Haber?cker, Gudrun Socher

% bilinear interpolation with cutting of the outer lines on each side
% to simplyfy handling of edge pixel
function rgbfloat = bilinear_interpolation_debayer(arifloat)
    rgbfloat(:,:,1) = arifloat(:,:);
    rgbfloat(:,:,2) = arifloat(:,:);
    rgbfloat(:,:,3) = arifloat(:,:);

    % calculate green for non-green pixels
    rgbfloat(2:2:(end-1),3:2:(end-1),2) = (arifloat(2:2:(end-1),2:2:(end-1)) + arifloat(3:2:(end),3:2:(end)) + arifloat(2:2:(end-1),4:2:(end)) + arifloat(1:2:(end-3),3:2:(end-1))) / 4;
    rgbfloat(3:2:(end-1),2:2:(end-1),2) = (arifloat(2:2:(end-1),2:2:(end-1)) + arifloat(3:2:(end),3:2:(end)) + arifloat(4:2:(end),2:2:(end-1)) + arifloat(3:2:(end-1),1:2:(end-3))) / 4;
    
    % calculate red for non-red pixels
    rgbfloat(1:2:(end),3:2:(end),1) = (arifloat(1:2:(end),2:2:(end-2)) + arifloat(1:2:(end),4:2:(end)))/2;
    rgbfloat(2:2:(end-1),2:2:(end),1) = (arifloat(1:2:(end-2),2:2:(end)) + arifloat(3:2:(end),2:2:(end)))/2;
    rgbfloat(2:2:(end-1),3:2:(end-1),1) = ( arifloat(1:2:(end-2),2:2:(end-2)) + arifloat(1:2:(end-2),4:2:(end)) + arifloat(3:2:(end),2:2:(end-2)) + arifloat(3:2:(end),4:2:(end)) ) / 4;

    % calculate blue for non-blue pixels
    rgbfloat(2:2:end,2:2:(end-1),3) = (arifloat(2:2:end,1:2:(end-2)) + arifloat(2:2:end,3:2:end)) / 2;
    rgbfloat(3:2:(end-1),1:2:end,3) = (arifloat(2:2:(end-2),1:2:end) + arifloat(4:2:end,1:2:end)) / 2;
    rgbfloat(3:2:(end-1),2:2:(end-1),3) = (arifloat(2:2:(end-2), 1:2:(end-2)) + arifloat(2:2:(end-2),3:2:end) + arifloat(4:2:end,1:2:(end-2)) + arifloat(4:2:end,3:2:end)) / 4;
    
    rgbfloat = rgbfloat(2:(end-1), 2:(end-1), :);
end