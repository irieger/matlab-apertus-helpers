% The following algorithm was implemented with help of the Book "Computergrafik und
% Bildverarbeitung, Band II: Bildverarbeitung". 3. Auflage, 2011
% by Alfred Nischwitz,Max Fischer, Peter Haber?cker, Gudrun Socher

% Adaptive Homogeneity Directed Demosaicing (improved)
function rgbfloat = iahd_debayer(arifloat)

    fl_min = min(min(arifloat));
    scaled_float = (arifloat-fl_min)/2.5;
    
    r = expand_matrix(scaled_float, 4, 4, 4, 4);
    g = r;
    b = r;

    % helper for calculations
    f = false(size(r)); % false
    z = zeros(size(r));
    t = ~z; % true
    
    
  % :SECTION: Interpolate Green  (1)
    % prepare green variables
    g_h = g;
    g_v = g;
    
    % prepare green matrizes for red & blue hotpixels hotpixels
    % using r as the source in both cases is possible due to the fact that they contain the same value at this time
    idx = f;
    idx(3:2:end-2, 4:2:end-2) = true;
    idx(4:2:end-2, 3:2:end-2) = true;
    g_h(idx) = ( g(lsft(idx)) + g(rsft(idx)) )/2 + ( 2*r(idx) - r(lsft(idx,2)) - r(rsft(idx,2)) )/4;
    g_v(idx) = ( g(usft(idx)) + g(dsft(idx)) )/2 + ( 2*r(idx) - r(usft(idx,2)) - r(dsft(idx,2)) )/4;


    g_h(idx) = median([g_h(idx), g(lsft(idx)), g(rsft(idx))], 2);
    g_v(idx) = median([g_h(idx), g(usft(idx)), g(dsft(idx))], 2);
    
    
  % :SECTION: Interpolate Red + Blue
    
    % calculate blue for red hotpixels
    b_h = b;
    b_v = b;
    
    idx = f;
    idx(3:2:end-2, 4:2:end-2) = true;
    b_h(idx) = ( b(usft(lsft(idx))) + b(usft(rsft(idx))) + b(dsft(lsft(idx))) + b(dsft(rsft(idx))) )/4 + ( 4*g_h(idx) - g_h(usft(lsft(idx))) - g_h(usft(rsft(idx))) - g_h(dsft(lsft(idx))) - g_h(dsft(rsft(idx))) )/4;
    b_v(idx) = ( b(usft(lsft(idx))) + b(usft(rsft(idx))) + b(dsft(lsft(idx))) + b(dsft(rsft(idx))) )/4 + ( 4*g_v(idx) - g_v(usft(lsft(idx))) - g_v(usft(rsft(idx))) - g_v(dsft(lsft(idx))) - g_v(dsft(rsft(idx))) )/4;

    % calculate red for blue hotpixels
    r_h = r;
    r_v = r;
    
    idx = f;
    idx(4:2:end-2, 3:2:end-2) = true;
    r_h(idx) = ( r(usft(lsft(idx))) + r(usft(rsft(idx))) + r(dsft(lsft(idx))) + r(dsft(rsft(idx))) )/4 + ( 4*g_h(idx) - g_h(usft(lsft(idx))) - g_h(usft(rsft(idx))) - g_h(dsft(lsft(idx))) - g_h(dsft(rsft(idx))) )/4;
    r_v(idx) = ( r(usft(lsft(idx))) + r(usft(rsft(idx))) + r(dsft(lsft(idx))) + r(dsft(rsft(idx))) )/4 + ( 4*g_v(idx) - g_v(usft(lsft(idx))) - g_v(usft(rsft(idx))) - g_v(dsft(lsft(idx))) - g_v(dsft(rsft(idx))) )/4;
    
    % calculate red & blue for green hotpixels
    idx = f;
    idx(4:2:end-2, 4:2:end-2) = true;
    r_h(idx) = ( r_h(usft(idx)) + r_h(dsft(idx)) )/2 + ( 2*g(idx) - g_h(usft(idx)) - g_h(dsft(idx)) )/2;
    r_v(idx) = ( r_v(usft(idx)) + r_v(dsft(idx)) )/2 + ( 2*g(idx) - g_v(usft(idx)) - g_v(dsft(idx)) )/2;
    b_h(idx) = ( b_h(lsft(idx)) + b_h(rsft(idx)) )/2 + ( 2*g(idx) - g_h(rsft(idx)) - g_h(lsft(idx)) )/2;
    b_v(idx) = ( b_v(lsft(idx)) + b_v(rsft(idx)) )/2 + ( 2*g(idx) - g_v(rsft(idx)) - g_v(lsft(idx)) )/2;
    
    idx = f;
    idx(3:2:end-2, 3:2:end-2) = true;
    r_h(idx) = ( r_h(lsft(idx)) + r_h(rsft(idx)) )/2 + ( 2*g(idx) - g_h(lsft(idx)) - g_h(rsft(idx)) )/2;
    r_v(idx) = ( r_v(lsft(idx)) + r_v(rsft(idx)) )/2 + ( 2*g(idx) - g_v(lsft(idx)) - g_v(rsft(idx)) )/2;
    b_h(idx) = ( b_h(usft(idx)) + b_h(dsft(idx)) )/2 + ( 2*g(idx) - g_h(usft(idx)) - g_h(dsft(idx)) )/2;
    b_v(idx) = ( b_v(usft(idx)) + b_v(dsft(idx)) )/2 + ( 2*g(idx) - g_v(usft(idx)) - g_v(dsft(idx)) )/2;
    
    
  % :SECTION: XYZ
    x_h = z;
    y_h = z;
    z_h = z;
    x_v = z;
    y_v = z;
    z_v = z;
    
    % XYZ for green hotpixels
    idx = f;
    idx(3:2:end-2, 3:2:end-2) = true;
    idx(4:2:end-2, 4:2:end-2) = true;
    x_h(idx) = 0.8508299 * r_h(idx) + 0.2110959 * g(idx) + 0.0274502 * b_h(idx);
    y_h(idx) = 0.3327920 * r_h(idx) + 1.0430 * g(idx) + -0.2272918 * b_h(idx);
    z_h(idx) = 0.0270920 * r_h(idx) + -0.3406631 * g(idx) + 1.4520 * b_h(idx);
    x_v(idx) = 0.8508299 * r_v(idx) + 0.2110959 * g(idx) + 0.0274502 * b_v(idx);
    y_v(idx) = 0.3327920 * r_v(idx) + 1.0430 * g(idx) + -0.2272918 * b_v(idx);
    z_v(idx) = 0.0270920 * r_v(idx) + -0.3406631 * g(idx) + 1.4520 * b_v(idx);
    
    % XYZ for red hotpixels
    idx = f;
    idx(3:2:end-2, 4:2:end-2) = true;
    x_h(idx) = 0.8508299 * r(idx) + 0.2110959 * g_h(idx) + 0.0274502 * b_h(idx);
    y_h(idx) = 0.3327920 * r(idx) + 1.0430 * g_h(idx) + -0.2272918 * b_h(idx);
    z_h(idx) = 0.0270920 * r(idx) + -0.3406631 * g_h(idx) + 1.4520 * b_h(idx);
    x_v(idx) = 0.8508299 * r(idx) + 0.2110959 * g_v(idx) + 0.0274502 * b_v(idx);
    y_v(idx) = 0.3327920 * r(idx) + 1.0430 * g_v(idx) + -0.2272918 * b_v(idx);
    z_v(idx) = 0.0270920 * r(idx) + -0.3406631 * g_v(idx) + 1.4520 * b_v(idx);
    % XYZ for blue hotpixels
    idx = f;
    idx(4:2:end-2, 3:2:end-2) = true;
    x_h(idx) = 0.8508299 * r_h(idx) + 0.2110959 * g_h(idx) + 0.0274502 * b(idx);
    y_h(idx) = 0.3327920 * r_h(idx) + 1.0430 * g_h(idx) + -0.2272918 * b(idx);
    z_h(idx) = 0.0270920 * r_h(idx) + -0.3406631 * g_h(idx) + 1.4520 * b(idx);
    x_v(idx) = 0.8508299 * r_v(idx) + 0.2110959 * g_v(idx) + 0.0274502 * b(idx);
    y_v(idx) = 0.3327920 * r_v(idx) + 1.0430 * g_v(idx) + -0.2272918 * b(idx);
    z_v(idx) = 0.0270920 * r_v(idx) + -0.3406631 * g_v(idx) + 1.4520 * b(idx);
    
   
  % :SECTION: LAB
    x_h = create_cbrt(x_h);
    y_h = create_cbrt(y_h);
    z_h = create_cbrt(z_h);
    x_v = create_cbrt(x_v);
    y_v = create_cbrt(y_v);
    z_v = create_cbrt(z_v);

    lab_l_h = 64*(116*y_h - 16);
    lab_a_h = 64*500*(x_h-y_h);
    lab_b_h = 64*500*(y_h-z_h);
    lab_l_v = 64*(116*y_v - 16);
    lab_a_v = 64*500*(x_v-y_v);
    lab_b_v = 64*500*(y_v-z_v);
    
  % :SECTION: Homogenity-Map
    l_hr = z;
    l_hl = z;
    l_ht = z;
    l_hb = z;
    l_vr = z;
    l_vl = z;
    l_vt = z;
    l_vb = z;

    idx = f;
    idx(3:end-2,3:end-2) = true;
    l_hr(idx) = abs(lab_l_h(rsft(idx)) - lab_l_h(idx));
    l_hl(idx) = abs(lab_l_h(lsft(idx)) - lab_l_h(idx));
    l_ht(idx) = abs(lab_l_h(usft(idx)) - lab_l_h(idx));
    l_hb(idx) = abs(lab_l_h(dsft(idx)) - lab_l_h(idx));
    l_vr(idx) = abs(lab_l_v(rsft(idx)) - lab_l_v(idx));
    l_vl(idx) = abs(lab_l_v(lsft(idx)) - lab_l_v(idx));
    l_vt(idx) = abs(lab_l_v(usft(idx)) - lab_l_v(idx));
    l_vb(idx) = abs(lab_l_v(dsft(idx)) - lab_l_v(idx));

    ab_hr = z;
    ab_hl = z;
    ab_ht = z;
    ab_hb = z;
    ab_vr = z;
    ab_vl = z;
    ab_vt = z;
    ab_vb = z;

    ab_hr(idx) = power(lab_a_h(rsft(idx)) - lab_a_h(idx), 2) + power(lab_b_h(rsft(idx)) - lab_b_h(idx), 2);
    ab_hl(idx) = power(lab_a_h(lsft(idx)) - lab_a_h(idx), 2) + power(lab_b_h(lsft(idx)) - lab_b_h(idx), 2);
    ab_ht(idx) = power(lab_a_h(usft(idx)) - lab_a_h(idx), 2) + power(lab_b_h(usft(idx)) - lab_b_h(idx), 2);
    ab_hb(idx) = power(lab_a_h(dsft(idx)) - lab_a_h(idx), 2) + power(lab_b_h(dsft(idx)) - lab_b_h(idx), 2);
    ab_vr(idx) = power(lab_a_v(rsft(idx)) - lab_a_v(idx), 2) + power(lab_b_v(rsft(idx)) - lab_b_v(idx), 2);
    ab_vl(idx) = power(lab_a_v(lsft(idx)) - lab_a_v(idx), 2) + power(lab_b_v(lsft(idx)) - lab_b_v(idx), 2);
    ab_vt(idx) = power(lab_a_v(usft(idx)) - lab_a_v(idx), 2) + power(lab_b_v(usft(idx)) - lab_b_v(idx), 2);
    ab_vb(idx) = power(lab_a_v(dsft(idx)) - lab_a_v(idx), 2) + power(lab_b_v(dsft(idx)) - lab_b_v(idx), 2);

    leps = min(max(l_hr, l_hl), max(l_vt, l_vb));
    abeps = min(max(ab_hr, ab_hl), max(ab_vt, ab_vb));

    homo_h = z;
    homo_v = z;

    idx = f; idx(l_hr<= leps & ab_hr<= abeps) = true;
    homo_h(idx) = homo_h(idx)+1;
    idx = f; idx(l_hl<= leps & ab_hl<= abeps) = true;
    homo_h(idx) = homo_h(idx)+1;
    idx = f; idx(l_ht<= leps & ab_ht<= abeps) = true;
    homo_h(idx) = homo_h(idx)+1;
    idx = f; idx(l_hb<= leps & ab_hb<= abeps) = true;
    homo_h(idx) = homo_h(idx)+1;

    idx = f; idx(l_vr<= leps & ab_vr<= abeps) = true;
    homo_v(idx) = homo_v(idx)+1;
    idx = f; idx(l_vl<= leps & ab_vl<= abeps) = true;
    homo_v(idx) = homo_v(idx)+1;
    idx = f; idx(l_vt<= leps & ab_vt<= abeps) = true;
    homo_v(idx) = homo_v(idx)+1;
    idx = f; idx(l_vb<= leps & ab_vb<= abeps) = true;
    homo_v(idx) = homo_v(idx)+1;
    
  % :SECTION: h/v-decission

    h_h = z;
    h_v = z;

    idx = f;
    idx(2:end-1,2:end-1) = true;

    h_h(idx) = homo_h(usft(lsft(idx))) + homo_h(usft(idx)) + homo_h(usft(rsft(idx))) + homo_h(rsft(idx)) + homo_h(idx) + homo_h(rsft(idx)) + homo_h(dsft(lsft(idx))) + homo_h(dsft(idx)) + homo_h(dsft(rsft(idx)));
    h_v(idx) = homo_v(usft(lsft(idx))) + homo_v(usft(idx)) + homo_v(usft(rsft(idx))) + homo_v(rsft(idx)) + homo_v(idx) + homo_v(rsft(idx)) + homo_v(dsft(lsft(idx))) + homo_v(dsft(idx)) + homo_v(dsft(rsft(idx)));

    id_h = h_h > h_v;
    id_v = h_h < h_v;
    id_m = ~(id_h | id_v);

    r(id_h) = r_h(id_h);
    g(id_h) = g_h(id_h);
    b(id_h) = b_h(id_h);

    r(id_v) = r_v(id_v);
    g(id_v) = g_v(id_v);
    b(id_v) = b_v(id_v);

    r(id_m) = (r_h(id_m) + r_v(id_m))/2;
    g(id_m) = (g_h(id_m) + g_v(id_m))/2;
    b(id_m) = (b_h(id_m) + b_v(id_m))/2;



  % :SECTION: Median-Output
    
  % :SECTION: Output
    
    % prepare output and recalculate to original linear values
    rgbfloat = zeros([size(arifloat), 3]);
    
    rgbfloat(:,:,1) = r(5:end-4,5:end-4);
    rgbfloat(:,:,2) = g(5:end-4,5:end-4);
    rgbfloat(:,:,3) = b(5:end-4,5:end-4);
    
    rgbfloat = rgbfloat*2.5+fl_min;

end


function cbrt = create_cbrt(input )
    cbrt = input;
    r = input;
    r(r>1.0) = 1.0;
    r(r<0.0) = 0.0;
    cbrt(r>0.008856) = power(r(r>0.008856), 1.0/3);
    cbrt(r<=0.008856) = 7.787*r(r<=0.008856) + 16/116.0;
end

%function val = myconvert(input)
%    val = input * 65535 + 1;
%    val(val > 65536) = 65536;
%end
