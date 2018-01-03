function [lu_val, u_ptr, icode] = ILU0(n, row_ptr, col_idx, a_val)
% Incomplete LU Factorization for sparse matrix in CSR format
% Modified from Yousef Saad's ``Iterative Methods for Sparse Linear Systems'', 
% FORTRAN code list in section 10.3.2, variable names are changed 
% according to ALgorithm 10.4 in the same section
% row_ptr, col_idx, a_val : Standard CSR arrays, column index start from 1
% n      : Dimension of matrix
% lu_val : The CSR value array to replace a_val after ILU(0). L and U are stored 
%          together. In each row, the L values are followed by the U values. The 
%          diagonal elements of U is NOT INVERTED. 
% u_ptr  : Pointer to the diagonal elements in the value array (iu_val)
% icode  : 0 for normal return, k for zero pivot at step k

	lu_val = a_val;
	u_ptr  = zeros(1, n);
	col_idx_mapper = zeros(1, n);
	
	for i = 1 : n
		j1 = row_ptr(i);
		j2 = row_ptr(i + 1) - 1;
		
		% Set mapper
		for j = j1 : j2
			col_idx_mapper(col_idx(j)) = j;
		end
		
		% ILU factorization IKJ version k-loop
		for j = j1 : j2
			k = col_idx(j);
			if (k < i)
				lu_val(j) = lu_val(j) / lu_val(u_ptr(k));
				for jj = u_ptr(k) + 1 : row_ptr(k + 1) - 1;
					jw = col_idx_mapper(col_idx(jj));
					if (jw ~= 0)
						lu_val(jw) = lu_val(jw) - lu_val(j) * lu_val(jj);
					end
				end
			else
				break;
			end
		end
		u_ptr(i) = j;
		
		% Error: zero pivot
		if ((k ~= i) || (lu_val(j) == 0.0))
			icode = i;
			return;
		end
		
		% Reset mapper
		for j = j1 : j2
			col_idx_mapper(col_idx(j)) = 0;
		end
	end
	icode = 0;
end