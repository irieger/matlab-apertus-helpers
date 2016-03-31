% simple raw debayering, based on an algorithm implementation by Jan Fröhlich.

function rgbfloat = simple_half_bayer(arifloat)
    rgbfloat(:,:,1) = arifloat(1:2:end,2:2:end);
    rgbfloat(:,:,2) = (arifloat(1:2:end,1:2:end) + arifloat(2:2:end,2:2:end)) ./2;
    rgbfloat(:,:,3) = arifloat(2:2:end,1:2:end);
end