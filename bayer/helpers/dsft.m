% shift downwards
function mat = dsft(in, shift)
    if nargin < 2
        shift = 1;
    end
    mat = vertcat(transpose(repmat(false,size(in,2), shift)), in(1:end-shift,:));
end