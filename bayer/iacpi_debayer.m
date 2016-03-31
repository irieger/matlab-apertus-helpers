% The following algorithm was implemented with help of the Book "Computergrafik und
% Bildverarbeitung, Band II: Bildverarbeitung". 3. Auflage, 2011
% by Alfred Nischwitz,Max Fischer, Peter Haber?cker, Gudrun Socher

% Adaptive Color Plane Interpolation (improved)
function rgbfloat = iacpi_debayer(arifloat)
    % numbers for GRBG pattern are G1,R2;B3,G4
    g1 = expand_matrix(arifloat(1:2:end,1:2:end), 1,1,1,1);
    r2 = expand_matrix(arifloat(1:2:end,2:2:end), 1,1,1,1);
    b3 = expand_matrix(arifloat(2:2:end,1:2:end), 1,1,1,1);
    g4 = expand_matrix(arifloat(2:2:end,2:2:end), 1,1,1,1);

    % helper for calculations
    z = false(size(g1)); % false
    t = ~z; % true

    % prepare variable for interpolated colors
    g2 = zeros(size(g1));
    g3 = zeros(size(g1));
    r1 = zeros(size(g1));
    r3 = zeros(size(g1));
    r4 = zeros(size(g1));
    b1 = zeros(size(g1));
    b2 = zeros(size(g1));
    b4 = zeros(size(g1));


    % :SECTION: Interpolate green for red hotpixels after gradient selection of edge direction
    grh = z; % green gradient for red hotpixels, horizontal
    grv = z; % green gradient for red hotpixels, vertical

    idx = z;
    idx(2:end-1,2:end-1) = true;
    grh(idx) = abs( g1(idx)-g1(rsft(idx)) ) + abs( 2*r2(idx) - r2(lsft(idx)) - r2(rsft(idx)) );
    grv(idx) = abs( g4(usft(idx))-g4(idx) ) + abs( 2*r2(idx) - r2(usft(idx)) - r2(dsft(idx)) );

    hidx = grh<grv;
    vidx = ~hidx & idx;
    g2(hidx) = ( g1(hidx) + g1(rsft(hidx)) )/2 + ( 2*r2(hidx) - r2(lsft(hidx)) - r2(rsft(hidx)) )/4;
    g2(vidx) = ( g4(usft(vidx)) + g4(vidx) )/2 + ( 2*r2(vidx) - r2(usft(vidx)) - r2(dsft(vidx)) )/4;

    % :SECTION: Interpolate green for blue hotpixels after gradient selection of edge direction
    gbh = z; % green gradient for blue hotpixels, horizontal
    gbv = z; % green gradient for blue hotpixels, vertical

    gbh(idx) = abs( g4(lsft(idx))-g4(idx) ) + abs( 2*b3(idx) - b3(lsft(idx)) - b3(rsft(idx)) );
    gbv(idx) = abs( g1(idx)-g1(dsft(idx)) ) + abs( 2*b3(idx) - b3(usft(idx)) - b3(dsft(idx)) );

    hidx = gbh<gbv;
    vidx = ~hidx & idx;
    g3(hidx) = ( g4(lsft(hidx)) + g4(hidx) )/2 + ( 2*b3(hidx) - b3(lsft(hidx)) - b3(rsft(hidx)) )/4;
    g3(vidx) = ( g1(vidx) + g1(dsft(vidx)) )/2 + ( 2*b3(vidx) - b3(usft(vidx)) - b3(dsft(vidx)) )/4;


    % :SECTION: Interpolate blue for red hotpixels
    gdn = z;
    gdp = z;

    idx = z;
    idx(2:end,1:end-1) = true;

    gdn(idx) = abs( b3(usft(idx)) - b3(rsft(idx)) ) + abs( 2 * g2(idx) - g3(usft(idx)) - g3(rsft(idx)) );
    gdp(idx) = abs( b3(rsft(usft(idx))) - b3(idx) ) + abs( 2 * g2(idx) - g3(rsft(usft(idx))) - g3(idx) );

    dnidx = gdn<gdp;
    dpidx = ~dnidx & idx;
    b2(dnidx) = ( b3(usft(dnidx)) + b3(rsft(dnidx)) )/2 + ( 2 * g2(dnidx) - g3(usft(dnidx)) - g3(rsft(dnidx)) )/4;
    b2(dpidx) = ( b3(rsft(usft(dpidx))) + b3(dpidx) )/2 + ( 2 * g2(dpidx) - g3(rsft(usft(dpidx))) - g3(dpidx) )/4;


    % :SECTION: Interpolate red for blue hotpixels
    gdn = z;
    gdp = z;

    idx = z;
    idx(1:end-1,2:end) = true;

    gdn(idx) = abs( r2(lsft(idx)) - r2(dsft(idx)) ) + abs( 2*g3(idx) - g2(lsft(idx)) - g2(dsft(idx)) );
    gdp(idx) = abs( r2(idx) - r2(lsft(dsft(idx))) ) + abs( 2*g3(idx) - g2(idx) - g2(lsft(dsft(idx))) );

    dnidx = gdn<gdp;
    dpidx = ~dnidx & idx;
    r3(dnidx) = ( r2(lsft(dnidx)) + r2(dsft(dnidx)) )/2 + ( 2*g3(dnidx) - g2(lsft(dnidx)) - g2(dsft(dnidx)) )/4;
    r3(dpidx) = ( r2(dpidx) + r2(lsft(dsft(dpidx))) )/2 + ( 2*g3(dpidx) - g2(dpidx) - g2(lsft(dsft(dpidx))) )/4;


    % :SECTION: Interpolate red for green1 hotpixels after gradient selection of edge direction
    grh = z;
    grv = z;

    idx = z;
    idx(2:end-1,2:end-1) = true;
    grh(idx) = abs( r2(lsft(idx))-r2(idx) ) + abs( 2*g1(idx) - g2(lsft(idx)) - g2(idx) );
    grv(idx) = abs( r3(usft(idx))-r3(idx) ) + abs( 2*g1(idx) - g3(usft(idx)) - g3(idx) );

    hidx = grh<grv;
    vidx = ~hidx & idx;
    r1(hidx) = ( r2(lsft(hidx))+r2(hidx) )/2 + ( 2*g1(hidx) - g2(lsft(hidx)) - g2(hidx) )/4;
    r1(vidx) = ( r3(usft(vidx))+r3(vidx) )/2 + ( 2*g1(vidx) - g3(usft(vidx)) - g3(vidx) )/4;

    % :SECTION: Interpolate red for green4 hotpixels after gradient selection of edge direction
    grh = z;
    grv = z;

    idx = z;
    idx(2:end-1,2:end-1) = true;
    grh(idx) = abs( r3(idx)-r3(rsft(idx)) ) + abs( 2*g4(idx) - g3(idx) - g3(rsft(idx)) );
    grv(idx) = abs( r2(idx)-r2(dsft(idx)) ) + abs( 2*g4(idx) - g2(idx) - g2(dsft(idx)) );

    hidx = grh<grv;
    vidx = ~hidx & idx;
    r4(hidx) = ( r3(hidx)+r3(rsft(hidx)) )/2 + ( 2*g4(hidx) - g3(hidx) - g3(rsft(hidx)) )/4;
    r4(vidx) = ( r2(vidx)+r2(dsft(vidx)) )/2 + ( 2*g4(vidx) - g2(vidx) - g2(dsft(vidx)) )/4;


    % :SECTION: Interpolate blue for green1 hotpixels after gradient selection of edge direction
    grh = z;
    grv = z;

    idx = z;
    idx(2:end-1,2:end-1) = true;
    grh(idx) = abs( b2(lsft(idx))-b2(idx) ) + abs( 2*g1(idx) - g2(lsft(idx)) - g2(idx) );
    grv(idx) = abs( b3(usft(idx))-b3(idx) ) + abs( 2*g1(idx) - g3(usft(idx)) - g3(idx) );

    hidx = grh<grv;
    vidx = ~hidx & idx;
    b1(hidx) = ( b2(lsft(hidx))+b2(hidx) )/2 + ( 2*g1(hidx) - g2(lsft(hidx)) - g2(hidx) )/4;
    b1(vidx) = ( b3(usft(vidx))+b3(vidx) )/2 + ( 2*g1(vidx) - g3(usft(vidx)) - g3(vidx) )/4;

    % :SECTION: Interpolate blue for green4 hotpixels after gradient selection of edge direction
    grh = z;
    grv = z;

    idx = z;
    idx(2:end-1,2:end-1) = true;
    grh(idx) = abs( b3(idx)-b3(rsft(idx)) ) + abs( 2*g4(idx) - g3(idx) - g3(rsft(idx)) );
    grv(idx) = abs( b2(idx)-b2(dsft(idx)) ) + abs( 2*g4(idx) - g2(idx) - g2(dsft(idx)) );

    hidx = grh<grv;
    vidx = ~hidx & idx;
    b4(hidx) = ( b3(hidx)+b3(rsft(hidx)) )/2 + ( 2*g4(hidx) - g3(hidx) - g3(rsft(hidx)) )/4;
    b4(vidx) = ( b2(vidx)+b2(dsft(vidx)) )/2 + ( 2*g4(vidx) - g2(vidx) - g2(dsft(vidx)) )/4;


    % :SECTION: Interpolate Red and Blue for Green hotpixels
    %idx = z;
    %idx(2:end-1, 2:end-1) = true;
    %b1(idx) = ( b3(usft(idx)) + b3(idx) )/2 + ( 2*g1(idx) - g3(usft(idx)) - g3(idx) )/2;
    %b4(idx) = ( b3(idx) + b3(rsft(idx)) )/2 + ( 2*g4(idx) - g3(idx) - g3(rsft(idx)) )/2;
    %r1(idx) = ( r2(lsft(idx)) + r2(idx) )/2 + ( 2*g1(idx) - g2(lsft(idx)) - g2(idx) )/2;
    %r4(idx) = ( r2(idx) + r2(dsft(idx)) )/2 + ( 2*g4(idx) - g2(idx) - g2(dsft(idx)) )/2;


    % :SECTION: Combine channels
    rgbfloat = zeros([size(arifloat), 3]);

    rgbfloat(1:2:end, 1:2:end, 1) = r1(2:end-1,2:end-1);
    rgbfloat(1:2:end, 1:2:end, 2) = g1(2:end-1,2:end-1);
    rgbfloat(1:2:end, 1:2:end, 3) = b1(2:end-1,2:end-1);

    rgbfloat(1:2:end, 2:2:end, 1) = r2(2:end-1,2:end-1);
    rgbfloat(1:2:end, 2:2:end, 2) = g2(2:end-1,2:end-1);
    rgbfloat(1:2:end, 2:2:end, 3) = b2(2:end-1,2:end-1);

    rgbfloat(2:2:end, 1:2:end, 1) = r3(2:end-1,2:end-1);
    rgbfloat(2:2:end, 1:2:end, 2) = g3(2:end-1,2:end-1);
    rgbfloat(2:2:end, 1:2:end, 3) = b3(2:end-1,2:end-1);

    rgbfloat(2:2:end, 2:2:end, 1) = r4(2:end-1,2:end-1);
    rgbfloat(2:2:end, 2:2:end, 2) = g4(2:end-1,2:end-1);
    rgbfloat(2:2:end, 2:2:end, 3) = b4(2:end-1,2:end-1);
end