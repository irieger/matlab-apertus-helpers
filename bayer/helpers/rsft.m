% shift right
function mat = rsft(in, shift)
    if nargin < 2
        shift = 1;
    end
    mat = horzcat(repmat(false,size(in,1), shift), in(:,1:end-shift));
end