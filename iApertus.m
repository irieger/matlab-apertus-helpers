classdef iApertus < handle

	% Some code was inspired by Jan Fröhlich

	properties (SetAccess = protected)
		settings
		exposure
		lines
		count
		cmvreg
		note
		subdir
		last_base_path
		fpn_mat
	end

	methods

		function obj = iApertus(settings)
			% set up default sensor setup and a base set of capture parameters.
			obj.exposure = 20;
			obj.lines = 3072;
			obj.count = 1;
			obj.cmvreg = containers.Map;
			obj.note = '';
			obj.subdir = '';

			obj.setCmvReg( 68, 0);
			obj.setCmvReg( 84, 257);
			obj.setCmvReg( 87, 2047);
			obj.setCmvReg( 88, 2047);
			obj.setCmvReg( 89, 35477);
			obj.setCmvReg(102, 8192+90);
			obj.setCmvReg(107, 10462);
			obj.setCmvReg(109, 14448);
			obj.setCmvReg(110, 12368);
			obj.setCmvReg(113, 542);
			obj.setCmvReg(114, 200);
			obj.setCmvReg(115, 1);
			obj.setCmvReg(124, 15);

			if nargin == 1
				obj.settings = settings;
			else
				disp('No settings given');
				obj = NaN;
			end
		end

		function info = getCurrentSettings(obj)
			info = 'Current control settings:\n';
			info = strcat(info, 'Exposure: ', int2str(obj.exposure), 'ms\n');
			info = strcat(info, 'Lines: ', int2str(obj.lines), '\n');
			info = strcat(info, 'Count: ', int2str(obj.count), ' per Capture\n');
			info = strcat(info, 'Note: ', obj.note, '\n');
			info = strcat(info, 'Subdir: ', obj.subdir, '\n\n');
			cmvcmd = strrep(strrep(obj.getCmvregCmd(), '" ', ''), '"', '');
			info = strcat(info, 'CMVreg-Settings:', '\n', strrep(cmvcmd, '; ', '\n'));
		end

		function dispState(obj)
			disp(sprintf(obj.getCurrentSettings));
		end

		function obj = setExposure(obj, exposure)
			obj.exposure = exposure;
		end

		function obj = setNote(obj, note)
			obj.note = note;
		end
		function obj = setSubdir(obj, subdir)
			obj.subdir = subdir;
		end

		function obj = setLines(obj, lines)
			obj.lines = lines;
		end

		function obj = setCount(obj, count)
			maxlines = 37.33*3072.0;

			if count * obj.lines <= maxlines
				obj.count = count;
			else
				maxcount = floor(maxlines / obj.lines);
				error(sprintf('A max of 37*3072 lines is supported.\n\nYou have %d lines recording active so you can use a max of %d frames.'));
			end
		end

		function obj = setBlackOffset(obj, value)
			obj.setCmvReg(87, value);
			obj.setCmvReg(88, value);
		end


		function img = captureAndCorrect(obj)
			img = obj.capture();
			img.applyOffsetFPNgain;
		end

		function img = capture(obj)
			t = datetime('now');
			datefolder = datestr(t, 'yyyy-mm-dd');
			timestr = datestr(t, 'HH-MM-SS');

			if ~exist(strcat(obj.settings('data_path_base'), '/', datefolder))
				mkdir(strcat(obj.settings('data_path_base'), '/', datefolder));
			end

			notestr = '';
			if ~isempty(obj.note)
				notestr = strcat(obj.note, '__');
			end

			subdir = '';
			if ~isempty(obj.subdir)
				subdir = strcat('/', obj.subdir);
				if ~exist(strcat(obj.settings('data_path_base'), '/', datefolder, subdir))
					mkdir(strcat(obj.settings('data_path_base'), '/', datefolder, subdir));
				end
			end

			file_basename = strcat(obj.settings('data_path_base'), '/', datefolder, subdir, '/', timestr, '___', notestr, int2str(obj.exposure), 'ms');

			params = strcat({' '}, int2str(obj.count), {' '}, int2str(obj.lines), {' '}, int2str(obj.exposure*10^6), {'ns '}, file_basename, {' '}, {obj.getCmvregCmd()});
			[status, cmdout] = system(cell2mat(strcat(obj.settings('apertus_script'), params)));
			%disp(cell2mat(strcat(obj.settings('apertus_script'), params)));
			%disp(cmdout);

			filename = '';
			if obj.count > 1
				filename = strcat(file_basename, '.01.raw12');
			else
				filename = strcat(file_basename, '.raw12');
			end

			obj.last_base_path = file_basename;

			img = iImage(filename);
			if obj.fpn_mat
				img.applyFPNcor(obj.fpn_mat);
			end
		end

		function live_preview(obj)
			if exist(obj.settings('tmp_dir'))
				figure;

				preview_filename = strcat(obj.settings('tmp_dir'), '/live_preview');
				params = strcat({' 1 '}, int2str(obj.lines), {' '}, int2str(obj.exposure*10^6), {'ns '}, preview_filename);
				[status, cmdout] = system(cell2mat(strcat(obj.settings('apertus_script'), params, {' '}, {obj.getCmvregCmd()}, {' -live'})));
				while true
					img = iImage(strcat(preview_filename, '.raw12'));
					bay = img.getBayer();
					blackoff = mean(mean(bay(:,1:8)));
					if obj.fpn_mat
						%img.applyFPNcor(obj.fpn_mat);
						%img.applyOffsetFPNgain;
						img.applyFPNcor(obj.fpn_mat);
					end
					bay = img.getBayer();
					img.debayer(@simple_half_bayer).showGA_nofig();
					
					% ignore black cols
					bay = bay(:,9:end-8);
					
					disp(sprintf('Max: %d,   Min: %d,   Mean: %f', max(bay(:)), min(bay(:)), mean(bay(:))));
					bay = bay(1001:1001+1000, 1536:1536+1024);
					mn1 = mean(mean( bay(1:2:end,1:2:end) -blackoff ));
					mn2 = mean(mean( bay(1:2:end,2:2:end) -blackoff ));
					mn3 = mean(mean( bay(2:2:end,1:2:end) -blackoff ));
					mn4 = mean(mean( bay(2:2:end,2:2:end) -blackoff ));
					%disp(sprintf('Mean-Offseted: %f; %f; %f; %f   (Offset: %f)', mn1, mn2, mn3, mn4, blackoff));
					disp('---------');
					[status, cmdout] = system(cell2mat(strcat(obj.settings('apertus_script'), params, {' "" -live'})));
				end
			else
				disp('No temp dir set');
			end
        end
        
        function live_preview_HC(obj)
			if exist(obj.settings('tmp_dir'))
				figure;

				preview_filename = strcat(obj.settings('tmp_dir'), '/live_preview');
				params = strcat({' 1 '}, int2str(obj.lines), {' '}, int2str(obj.exposure*10^6), {'ns '}, preview_filename);
				[status, cmdout] = system(cell2mat(strcat(obj.settings('apertus_script'), params, {' '}, {obj.getCmvregCmd()}, {' -live'})));
				while true
					img = iImage(strcat(preview_filename, '.raw12'));
					bay = img.getBayer();
					img.applyOffset(250);
					rgb = img.debayer(@simple_half_bayer).getRGB;
					%iImage(rgb(600:1100,950:1450,:)).showGA_nofig();
					iImage(rgb).showGA_nofig();
					
					disp(sprintf('Max: %d,   Min: %d,   Mean: %f', max(bay(:)), min(bay(:)), mean(bay(:))));
					disp('---------');
					[status, cmdout] = system(cell2mat(strcat(obj.settings('apertus_script'), params, {' "" -live'})));
				end
			else
				disp('No temp dir set');
			end
		end

		function img = captureStack(obj, count)
            oldcount = obj.count;
			obj.setCount(count);
			obj.capture();
			img = iImage.loadRawStack(obj.last_base_path, count);
			if obj.fpn_mat
				img.applyFPNcor(obj.fpn_mat);
            end
            obj.setCount(oldcount);
		end

		function obj = setCmvReg(obj, reg, val)
			obj.cmvreg(int2str(reg)) = int2str(val);
		end

		function cmd = getCmvregCmd(obj)
			cmd = '"';
			cmvkeys = obj.cmvreg.keys;
			cmvvals = obj.cmvreg.values;
			for i=1:size(obj.cmvreg,1)
				if ~strcmp(cmd, '"')
					cmd = strcat(cmd, ';');
				end
				cmd = strcat(cmd, {' ./ingmar/cmvreg.bash '}, cmvkeys(i), {' '}, cmvvals(i));
			end
			cmd = cell2mat(strcat(cmd,{'"'}));
		end

		function map = getCmvRegMap(obj)
			map = obj.cmvreg;
		end

		function obj = enableBlackCol(obj)
			if str2num(obj.cmvreg('89')) < 32768
				obj.cmvreg('89') = int2str(str2num(obj.cmvreg('89')) + bin2dec('1000000000000000'));
			end
		end
		function obj = disableBlackCol(obj)
			if str2num(obj.cmvreg('89')) >= 32768
				obj.cmvreg('89') = int2str(str2num(obj.cmvreg('89')) - bin2dec('1000000000000000'));
			end
		end

		function obj = setFpnMatrix(obj, fpnMat)
			obj.fpn_mat = fpnMat;
		end

	end

end