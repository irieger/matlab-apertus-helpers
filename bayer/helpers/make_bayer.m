% generate a bayer pattern image from a source rgb image. Uses the Arri Alexa
% bayer pattern (GRBG).
% Remeber: Optical imperfections helping a smooth debayering will not be simulated.
% Just a technical bayer pattern image will be generated.
function bayer_image = make_bayer(rgbimg)
	bayer_image = rgbimg(:,:,2); % copy green
	bayer_image(1:2:end, 2:2:end) = rgbimg(1:2:end, 2:2:end, 1); % overwrite red hotpixel
	bayer_image(2:2:end, 1:2:end) = rgbimg(2:2:end, 1:2:end, 3); % overwrite blue hotpixel
end