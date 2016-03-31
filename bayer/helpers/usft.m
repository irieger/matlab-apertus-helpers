% shift upwards
function mat = usft(in, shift)
    if nargin < 2
        shift = 1;
    end
    mat = vertcat(in(1+shift:end,:), transpose(repmat(false,size(in,2), shift)));
end