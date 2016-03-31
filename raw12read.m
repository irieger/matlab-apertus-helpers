% raw12 file type definition see https://wiki.apertus.org/index.php?title=RAW16

function bayerdouble = raw12read(Path, output_uint_orgsize)
	% Read Apertus raw12 (simple raw format with just all pixels at 12 bit in a chain
	% no metadata/overhead
    disp(['Processing: ' Path]);
    
    fid = fopen(Path,'r');
    fileInfo = dir(Path);
    bytecount = fileInfo.bytes;

    number_of_pixels = bytecount*8/12;
    % if file has regdump attached ignore it for pixel count calculation.
    % Shouldn't change anything on integer division in fread but doesn't hurt
    if mod(bytecount, 4096*12/8) == 256
        number_of_pixels = (bytecount-256)*8/12;
    end

    readimg = fread(fid,[4096,number_of_pixels/4096],'ubit12','b').';
    fclose(fid);

    %disp(number_of_pixels);
    %size(readimg)
    %% Fix for line swap in Axiom Beta FPGA code
    tmp = zeros(size(readimg));
    tmp(1:2:end,:) = readimg(2:2:end,:);
    tmp(2:2:end,:) = readimg(1:2:end,:);

    if nargin == 2 && output_uint_orgsize
        bayerdouble = double(tmp);
    else
        bayerdouble = expand_matrix(double(tmp), 1, 1, 1, 1);
    end
    %bayerdouble = readimg;
end

function rep = expand_matrix(matrix, top, right, bottom, left)
	rep = vertcat( repmat(matrix(1,:),[top, 1]), matrix, repmat(matrix(end,:),[bottom, 1]) );
	rep = horzcat( repmat(rep(:,1),[1, left]), rep, repmat(rep(:,end),[1, right]) );
end
