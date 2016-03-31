% Carefull with this class. Matlab numbering starting with 1
% means register numbers in obj.register_data are of by one.

classdef iCmvReg < handle

	properties (SetAccess = protected)
		register_data
		file_path
	end

	methods

		function obj = iCmvReg(regdump_path)
			obj.file_path = regdump_path;
			if exist(obj.file_path)
				obj.load();
			else
				global idata_path;
                tmppath = strcat(idata_path, '/', regdump_path);
                if exist(tmppath)
                    obj.file_path = tmppath;
                    obj.load();
                else
                	obj = NaN;
                end
			end
		end

		function obj = load(obj)
			disp(['Processing: ' obj.file_path]);
    
    		fid = fopen(obj.file_path);
    		fileInfo = dir(obj.file_path);
    		tmp = NaN;
    		if fileInfo.bytes == 256
    			tmp = fread(fid,[128],'uint16');
    		end
    		fclose(fid);

    		obj.register_data = tmp;
		end

		function regdump = getAll(obj)
			regdump = obj.register_data;
		end

		function obj = dispRelevant(obj)
			disp('----------  General exposure + shot info');
			disp(sprintf('Number of lines: %d   (reg 1)', obj.register_data(2)));
			disp(sprintf('Number of frames: %d   (reg 1)', obj.register_data(81)));
			disp(sprintf('Exposure time: %d ms', obj.getExposureTimeMS()));

			disp(''); disp('----------  General sensor setup');
			if obj.register_data(69) == 0
				disp('Set to color sensor, no bining/subsampling.   (reg 68 == 0)');
			else
				disp('Sensor not in default subsampling/color mode, see register 68');
			end
			if obj.register_data(71) == 0
				disp('Internal exposure timer and no interleaved HDR readout');
			elseif obj.register_data(71) == 2
				disp('Internal exposure timer and WITH Interleaved HDR!');
			end
			if obj.register_data(90) >= 32768
				disp('Black column active');
			else
				disp('No Black column active');
			end
			disp(sprintf('Black sun protection: %d', bitand(obj.register_data(103), 127)));
			
			disp(''); disp('----------  AD / Conversion tuning');
			pga_div = 1;
			if obj.register_data(116) >= 8
				pga_div = 3;
			end
			pga_mult = 1;
			switch bitand(obj.register_data(116), bin2dec('111'))
				case 1
					pga_mult = 2;
				case 3
					pga_mult = 3;
				case 7
					pga_mult = 4;
			end
			disp(sprintf('Analog Gain (PGAmult/PGAdiv): %f', pga_mult/pga_div));

			disp(sprintf('Offset bottom: %d,  Offset top: %d', obj.register_data(88), obj.register_data(89)));
			vramp1 = bitand(obj.register_data(110), bin2dec('1111111'));
			vramp2 = bitshift(obj.register_data(110), -7);
			disp(sprintf('Vramp1: %d,   Vramp2: %d', vramp1, vramp2));
			disp(sprintf('ADC_range (slope): %d', bitand(obj.register_data(117), 255)));
			disp(sprintf('ADC_range (mult): %d   (register value, not factor)', bitshift(obj.register_data(117), -8)));
			disp(sprintf('ADC_range (mult2): %d   (register value, not factor)', bitand(obj.register_data(101), 3)));
			disp(sprintf('DIG_gain: %d   (register value, not factor)', bitand(obj.register_data(118), bin2dec('11111'))));

			disp('----------  HDR multisplope');
			disp(sprintf('Exposure time: %f ms', obj.getExposureTimeMS()));
			disp(sprintf('Exposure time 2: %f ms', obj.getExposureTime2MS()));
			disp(sprintf('Number of slopes: %d', obj.register_data(80)));
			disp(sprintf('Exposure Time Knee Point 1: %f ms', obj.getExposureKP1MS()));
			disp(sprintf('Exposure Time Knee Point 2: %f ms', obj.getExposureKP2MS()));
			vtfl2 = bitand(obj.register_data(107), 127);
			vtfl3 = bitshift(obj.register_data(107), -7);
			disp(sprintf('Vtfl2: %d   [left bit => en/dis; 64=Vlow, 127=Vhigh]', vtfl2));
			disp(sprintf('Vtfl3: %d   [left bit => en/dis; 64=Vlow, 127=Vhigh]', vtfl3));
		end


		function exp_ms = getExposureTimeMS(obj)
			exp_time = uint32(obj.register_data(73));
			exp_time = bitshift(exp_time, 16) + uint32(obj.register_data(72));
			exp_ms = obj.calcExposureTimeMS(exp_time);
		end
		function exp_ms = getExposureTime2MS(obj)
			exp_time = uint32(obj.register_data(75));
			exp_time = bitshift(exp_time, 16) + uint32(obj.register_data(74));
			exp_ms = obj.calcExposureTimeMS(exp_time);
		end
		function exp_ms = getExposureKP1MS(obj)
			exp_time = uint32(obj.register_data(77));
			exp_time = bitshift(exp_time, 16) + uint32(obj.register_data(76));
			exp_ms = obj.calcExposureTimeMS(exp_time);
		end
		function exp_ms = getExposureKP2MS(obj)
			exp_time = uint32(obj.register_data(79));
			exp_time = bitshift(exp_time, 16) + uint32(obj.register_data(78));
			exp_ms = obj.calcExposureTimeMS(exp_time);
		end

		function exp_ms = calcExposureTimeMS(obj, exp_time)
			lvds = 250e6;
			bitdepth = 12;
			reg85 = obj.register_data(86);
			reg82 = bitand(obj.register_data(83), 255);

			tmp1 = (double(exp_time) - 1)*(reg85+1);
			tmp2 = tmp1 - 1 + 34*reg82;
			exp_ms = tmp2/1e-9/(lvds/bitdepth)/1e6;
		end

	end


end