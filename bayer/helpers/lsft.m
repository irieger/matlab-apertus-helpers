% shift left
function mat = lsft(in, shift)
    if nargin < 2
        shift = 1;
    end
    mat = horzcat(in(:,1+shift:end) , repmat(false,size(in,1), shift));
end