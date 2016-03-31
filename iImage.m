classdef iImage < handle

	% Some code was inspired by Jan Fröhlich

	properties (SetAccess = protected)
		img_path
		save_counter
		data_bayer
		dng_info
		data_rgb
		data_bayer_stack
		history
		cmv_registers
	end

	methods

		function obj = iImage(img)
			if nargin == 1
				obj.setHistory('Create image class');
				obj.save_counter = 1;
                if size(img,1) > 1 && size(img,2) > 1
                    if size(img,3) == 3
                        obj.data_rgb = img;
                    	obj.img_path = 'from_matrix';
                    	obj.setHistory('From RGB matrix');
                    elseif size(img,3) == 1
                        obj.data_bayer = img;
                    	obj.img_path = 'from_matrix';
                    	obj.setHistory('From bayer matrix');
                    else
                        obj.data_bayer_stack = img;
                    	obj.img_path = 'from_matrix';
                    	obj.setHistory('From bayer stack matrix');
                    end
                else
                    if ~exist(img)
                        global idata_path;
                        tmppath = strcat(idata_path, '/', img);
                        if exist(tmppath)
                            obj.img_path = tmppath;
                        end
                    else
                        obj.img_path = img;
                    end
                    if obj.img_path
                        obj = obj.load();
                    else
                        disp('File not found');
                        obj = NaN;
                    end
                end
			else
				disp('No filename given');
				obj = NaN;
			end
		end

		%% Function to add and get History
		function obj = setHistory(obj,text)
			curTime = fix(clock); % Date and Time according to ISO 8601
			obj.history = cat(1,obj.history,{[num2str(curTime(1),'%04.0f') '-' ...
				num2str(curTime(2),'%02.0f') '-' num2str(curTime(3),'%02.0f'), ' ' ...
				num2str(curTime(4),'%02.0f') ':' num2str(curTime(5),'%02.0f'), ':'...
				num2str(curTime(6),'%02.0f') ' | ' text]});
		end
		function history = getHistory(obj,type)
			if ~exist('type','var')
				history = obj.history;
			elseif strcmpi(type,'plain')||strcmpi(type,'char')
				% ToDo: Nice format...
				history = strjoin(obj.history, '\n');
			else
				error('getHistory mut be uses with no argument, to get native history, or plain or string, to get string')
			end
		end

		function obj = load(obj)
			[pathstr,name,ext] = fileparts(obj.img_path);

			if strcmpi(ext, '.raw12')
				obj = obj.setHistory(strcat('Load dng raw12 file  [BAYER]: ', obj.img_path));
				obj.data_bayer = raw12read(obj.img_path);

				regdump_path = strcat(pathstr, '/', regexprep(name, '\.[0-9]+$', ''), '.register_dump');
				if exist(regdump_path)
					obj.cmv_registers = iCmvReg(regdump_path);
				end
			elseif strcmpi(ext, '.exr')
				obj = obj.setHistory(strcat('Load exr image file   [RGB]: ', obj.img_path));
				obj.data_rgb = exrread(obj.img_path);
			elseif strcmpi(ext, '.tiff') || strcmpi(ext, '.tif')
				obj = obj.setHistory(strcat('Load tiff image file:    [RGB]', obj.img_path));
				obj.data_rgb = imread(obj.img_path);
				iinfo = imfinfo(obj.img_path)
				if iinfo.BitDepth/3 == 8 || iinfo.BitDepth/3 == 16
					obj.data_rgb = double(obj.data_rgb)/(iinfo.bitdepth/3-1)
				end
			else
				obj = obj.setHistory(strcat('Load raw file via dcraw  [BAYER]: ', obj.img_path));
				obj.data_bayer = read_cr2(obj.img_path);

				if strcmpi(ext, '.dng')
					obj.dng_info = imfinfo(obj.img_path);
				end

				% expand bayer matrix for used algorithms here (may not apply to all camera sources)
				obj.data_bayer = expand_matrix(obj.data_bayer, 1, 1, 1, 1);
			end
		end

		function obj = save(obj, ftype)
			[pathstr,name,ext] = fileparts(obj.img_path);
			if nargin == 1
				ftype = '.exr';
			end
			
			save_path_woext = sprintf('%s/%s.%d', pathstr, name, obj.save_counter);
			while (exist(strcat(save_path_woext, ftype)) || exist(strcat(save_path_woext, '.log')))
				obj.save_counter = obj.save_counter+1;
				save_path_woext = sprintf('%s/%s.%d', pathstr, name, obj.save_counter);
			end
			obj.save_counter = obj.save_counter+1;

			if ~isempty(obj.data_rgb) && (strcmpi(ftype, '.exr') || strcmpi(ftype, '.tiff') || strcmpi(ftype, '.tif'))
				fileID = fopen(strcat(save_path_woext, '.log'),'w');
				fprintf(fileID,'iImage history:\n\n');

				if strcmpi(ftype, '.exr')
					obj = obj.setHistory(strcat('Save exr image file: ', strcat(save_path_woext, ftype)));
					exrwrite(obj.data_rgb, strcat(save_path_woext, ftype));
				elseif strcmpi(ftype, '.tiff') || strcmpi(ftype, '.tif')
					obj = obj.setHistory(strcat('Save tif image file: ', strcat(save_path_woext, ftype)));
					imwrite(obj.data_rgb, strcat(save_path_woext, ftype));
				end

				fprintf(fileID,'%s',obj.getHistory('plain'));
				fclose(fileID);
			else
				disp('No rgb data to save or unknown file type.');
			end
		end

		function fname = getFileName(obj)
			[pathstr,name,ext] = fileparts(obj.img_path);
			fname = strcat(name,ext);
		end

		function obj = setFilePath(obj, path)
			obj.img_path = path;
		end

		function cmv_reg = getCmvReg(obj)
			cmv_reg = obj.cmv_registers;
		end

		function obj = show(obj)
			if ~isempty(obj.data_rgb)
				figure;
				title(strcat('Image (no gamma): ', obj.getFileName()));
				imshow(obj.data_rgb);
			else
				disp('No image RGB data found');
			end
		end

		function obj = showGA(obj)
			if ~isempty(obj.data_rgb)
				figure;
				title(strcat('Image (Gamma corrected): ', obj.getFileName()));
				maxval = max(max(max(double(obj.data_rgb))));
				imshow((obj.data_rgb/maxval).^(1/2.35));
			else
				disp('No image RGB data found');
			end
		end
		function obj = showGA_aces2srgb(obj)
			aces2srgb = [ 2.55234146, -1.12944317, -0.42289785; -0.27734214, 1.37825143, -0.10090926; -0.01713354, -0.14988193, 1.16701543 ];
			if ~isempty(obj.data_rgb)
				figure;
				transformedimg = apply_colormatrix_helper(obj.data_rgb, aces2srgb);
				title(strcat('Image (Gamma corrected): ', obj.getFileName()));
				maxval = max(transformedimg(:));
				imshow((transformedimg/maxval).^(1/2.35));
			else
				disp('No image RGB data found');
			end
		end

		function obj = showGAtool(obj)
			if ~isempty(obj.data_rgb)
				maxval = max(max(max(double(obj.data_rgb))));
				imshow_helper((obj.data_rgb/maxval).^(1/2.35));
			else
				disp('No image RGB data found');
			end
		end
		function obj = showGA_nofig(obj)
			if ~isempty(obj.data_rgb)
				%figure(strcat('Image (Gamma corrected): ', obj.name));
				maxval = max(max(max(double(obj.data_rgb))));
				imshow((obj.data_rgb/maxval).^(1/2.35));
			else
				disp('No image RGB data found');
			end
		end

		function obj = showBayer(obj)
			if ~isempty(obj.data_bayer)
				figure;
				title(strcat('Bayer: ', obj.getFileName()));
				imshow(obj.data_bayer);
			else
				disp('No image bayer data found');
			end
		end

		function obj = showBayerGA(obj)
			if ~isempty(obj.data_bayer)
				figure;
				title(strcat('Bayer: ', obj.getFileName()));
				%maxval = max(max(double(obj.data_bayer)));
				maxval = 4096;
				imshow((obj.data_bayer/maxval).^(1/2.35));
			else
				disp('No image bayer data found');
			end
		end

		function obj = showBayerGAtool(obj)
			if ~isempty(obj.data_bayer)
				maxval = max(max(obj.data_bayer));
				imshow_helper((obj.data_bayer/maxval).^(1/2.35));
			else
				disp('No image bayer data found');
			end
		end

		function obj = debayer(obj, bayerfunc)
			if nargin ~= 2
				bayerfunc = @iacpi_debayer;
			end
			obj.data_rgb = bayerfunc(obj.data_bayer);
			obj.setHistory(strcat('Debayer with: ', func2str(bayerfunc)));
		end

		function obj = white_balance(obj, wb)
			obj.setHistory(strcat('White balance multiply: ', mat2str(wb)));
			obj.data_rgb(:,:,1) = wb(1)*obj.data_rgb(:,:,1);
			obj.data_rgb(:,:,2) = wb(2)*obj.data_rgb(:,:,2);
			obj.data_rgb(:,:,3) = wb(3)*obj.data_rgb(:,:,3);
		end
		function obj = colormatrix(obj, M)
			obj = obj.setHistory(strcat('Multiply with color matrix: ', mat2str(M)));
			obj.data_rgb = apply_colormatrix_helper(obj.data_rgb, M);
		end
		function obj = multRGB(obj, val)
			obj = obj.setHistory(strcat('Multiply all channels with: %d', val));
			obj.data_rgb = obj.data_rgb*val;
		end

		function info = getDngInfo(obj)
			info = obj.dng_info;
		end

		function img = getBayer(obj)
			img = obj.data_bayer;
		end
		function img = getBayerStack(obj)
			img = obj.data_bayer_stack;
		end
		function img = getRGB(obj)
			img = obj.data_rgb;
		end
		function img = getRGBn(obj)
			maxval = max(max(max(double(obj.data_rgb))));
			img = obj.data_rgb/maxval;
		end

		function img = getRGBga(obj)
			if ~isempty(obj.data_rgb)
				maxval = max(max(max(double(obj.data_rgb))));
				img = (obj.data_rgb/maxval).^(1/2.35);
			else
				img = false;
			end
		end


		function res = calculateStackMean(obj)
			res = iImage(mean(obj.data_bayer_stack, 3));
		end
		function res = calculateStackMin(obj)
			res = iImage(min(obj.data_bayer_stack, [], 3));
		end
		function res = calculateStackMax(obj)
			res = iImage(max(obj.data_bayer_stack, [], 3));
		end

		function img = getStackFrame(obj, num)
			img = NaN;
			if ~isempty(obj.data_bayer_stack) && num < size(obj.data_bayer_stack,3)+1
				img = iImage(obj.data_bayer_stack(:,:,num));
			end
		end

		function res = calculateStdVar(obj)
			res = std2(obj.data_bayer);
		end

		function obj = applyOffset(obj, offset)
			if ~isempty(obj.data_bayer_stack)
				obj = obj.setHistory('Apply Offset correction scalar to data_bayer_stack');
				for ii=1:size(obj.data_bayer_stack, 3)
					obj.data_bayer_stack(:,:,ii) = obj.data_bayer_stack(:,:,ii) - offset;
				end
			elseif ~isempty(obj.data_bayer)
				obj = obj.setHistory('Apply Offset correction scalar to data_bayer');
				obj.data_bayer = obj.data_bayer - offset;
			else
				disp('Image object not suitable for called action');
				obj = NaN;
			end
		end

		function obj = applyFPNcor(obj, fpnMat)
			if ~isempty(obj.data_bayer_stack)
				obj = obj.setHistory('Apply FPN correction matrix to data_bayer_stack');
				for ii=1:size(obj.data_bayer_stack, 3)
					obj.data_bayer_stack(:,:,ii) = obj.data_bayer_stack(:,:,ii) - fpnMat;
				end
			elseif ~isempty(obj.data_bayer)
				obj = obj.setHistory('Apply FPN correction matrix to data_bayer');
				obj.data_bayer = obj.data_bayer - fpnMat;
			else
				disp('Image object not suitable for called action');
				obj = NaN;
			end
		end

		function obj = applyPixelGain(obj, gainmat)
			if ~isempty(obj.data_bayer_stack)
				obj = obj.setHistory('Apply Pixel Gain correction matrix to data_bayer_stack');
				for ii=1:size(obj.data_bayer_stack, 3)
					obj.data_bayer_stack(:,:,ii) = obj.data_bayer_stack(:,:,ii).*gainmat;
				end
			elseif ~isempty(obj.data_bayer)
				obj = obj.setHistory('Apply Pixel Gain correction matrix to data_bayer');
				obj.data_bayer = obj.data_bayer./gainmat;
			else
				disp('Image object not suitable for called action');
				obj = NaN;
			end
		end

		% :TODO: Check/what to do ...
		function obj = applyBlackColFix(obj)
			if ~isempty(obj.data_bayer)
				noisecols = cat(2, obj.data_bayer(1:end,2:9), obj.data_bayer(1:end, (end-8):(end-1)));
				correction = mean(noisecols, 2) - mean(noisecols(:));

				cormat = repmat(correction, [1 4098]);
				obj = obj.setHistory('Apply Black Col mean offset');
				obj.data_bayer = obj.data_bayer - cormat;
			end
		end


		function obj = applyOffsetFPNgain(obj)
			fid = fopen('/Users/ingmar/thesis/data/tmp/fpnmat2.bin','r');
			fpnmat = fread(fid,[3072,4098],'double');
			fclose(fid);

			fid = fopen('/Users/ingmar/thesis/data/tmp/gaincorrectionmat2.bin','r');
			gainmat = fread(fid,[3072,4098],'double');
			fclose(fid);

			%obj.applyOffset(80);
			obj.applyFPNcor(fpnmat);
			obj.applyPixelGain(gainmat);
		end


		function obj = applyDNGoffset(obj)
			obj.applyOffset(obj.getDngInfo.SubIFDs{1}.BlackLevel);
		end

	end


	methods (Static)

		%% Be carefully. Doesn't work with count=1 or count=3 currently
		function obj = loadRawStack(basepath, count)
			tmp = iImage(sprintf('%s.%02d.raw12', basepath, 0)).getBayer();
			for ii=1:(count-1)
				tmp = cat(3, tmp, iImage(sprintf('%s.%02d.raw12', basepath, ii)).getBayer());
			end
			obj = iImage(tmp);
		end

		function obj = loadDngStack(basepath, count)
			tmp = iImage(sprintf('%s.%02d.dng', basepath, 0)).applyDNGoffset().getBayer();
			for ii=1:(count-1)
				tmp = cat(3, tmp, iImage(sprintf('%s.%02d.dng', basepath, ii)).applyDNGoffset().getBayer());
			end
			obj = iImage(tmp);
		end


		%% Be carefully. Doesn't work with count=1 or count=3 currently
		function obj = loadRawStackWithFPNfix(basepath, count, fpnMat)
			tmp = iImage(sprintf('%s.%02d.raw12', basepath, 0)).applyFPNcor(fpnMat).getBayer();
			for ii=1:(count-1)
				tmp = cat(3, tmp, iImage(sprintf('%s.%02d.raw12', basepath, ii)).applyFPNcor(fpnMat).getBayer());
			end
			obj = iImage(tmp);
		end

	end

end

function imshow_helper(img)
	bFig = figure('Toolbar','none', 'Menubar','none');
	bImg = imshow(img);
	bSP = imscrollpanel(bFig, bImg);
	set(bSP, 'Units', 'normalized', 'Position', [0 .1 1 .9]);
	hMagBox = immagbox(bFig,bImg);
	pos = get(hMagBox,'Position');
	set(hMagBox,'Position',[0 0 pos(3) pos(4)])
	imoverview(bImg);
end


function outimg = apply_colormatrix_helper(inimg, M)
	outimg = reshape(reshape(inimg, size(inimg,1) * size(inimg,2), 3) * M', size(inimg,1), size(inimg,2), 3);
end