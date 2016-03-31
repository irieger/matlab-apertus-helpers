% Expand a matrix (2 dimensional) with the specified number of lines/columns
% at its edges by copying the nearest values
function rep = expand_matrix(matrix, top, right, bottom, left)
	rep = vertcat( repmat(matrix(1,:),[top, 1]), matrix, repmat(matrix(end,:),[bottom, 1]) );
	rep = horzcat( repmat(rep(:,1),[1, left]), rep, repmat(rep(:,end),[1, right]) );
end