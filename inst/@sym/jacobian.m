%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn  {Function File} {@var{J} =} jacobian (@var{f})
%% @deftypefnx {Function File} {@var{J} =} jacobian (@var{f}, @var{x})
%% Symbolic Jacobian of symbolic expression.
%%
%% @var{x} can be a scalar, vector or cell list.  If omitted,
%% it is determined using @code{symvar}.
%%
%% @seealso{divergence, gradient, curl, laplacian, hessian}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function g = jacobian(f,x)

  assert (isvector(f), 'jacobian: defined for vectors expressions')

  if (nargin == 1)
    x = symvar(f);
    if (isempty(x))
      x = sym('x');
    end
  end

  if (~iscell(x) && isscalar(x))
    x = {x};
  end

  cmd = { '(f, x) = _ins'
          'if not f.is_Matrix:'
          '    f = Matrix([f])'
          'G = f.jacobian(x)'
          'return G,' };

  g = python_cmd (cmd, sym(f), x);

end


%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = x^2;
%! assert (isequal (jacobian(f), diff(f,x)))
%! assert (isequal (jacobian(f,{x}), diff(f,x)))
%! assert (isequal (jacobian(f,x), diff(f,x)))

%!test
%! % const
%! f = sym(1);
%! g = sym(0);
%! assert (isequal (jacobian(f), g))
%! assert (isequal (jacobian(f,x), g))

%!test
%! % double const
%! f = 1;
%! g = sym(0);
%! assert (isequal (jacobian(f,x), g))

%!test
%! % diag
%! f = [x y^2];
%! g = [sym(1) 0; 0 2*y];
%! assert (isequal (jacobian(f), g))
%! assert (isequal (jacobian(f, [x y]), g))
%! assert (isequal (jacobian(f, {x y}), g))

%!test
%! % anti-diag
%! f = [y^2 x];
%! g = [0 2*y; sym(1) 0];
%! assert (isequal (jacobian(f), g))
%! assert (isequal (jacobian(f, {x y}), g))

%!test
%! % shape
%! f = [x y^2];
%! assert (isequal (size(jacobian(f, {x y z})), [2 3]))
%! assert (isequal (size(jacobian(f, [x y z])), [2 3]))
%! assert (isequal (size(jacobian(f, [x; y; z])), [2 3]))
%! assert (isequal (size(jacobian(f.', {x y z})), [2 3]))

%!test
%! % scalar f
%! f = x*y;
%! assert (isequal (size(jacobian(f, {x y})), [1 2]))
%! g = gradient(f, {x y});
%! assert (isequal (jacobian(f, {x y}), g.'))

%!test
%! % vect f wrt 1 var
%! f = [x x^2];
%! assert (isequal (size(jacobian(f, x)), [2 1]))
%! f = f.';  % same shape output
%! assert (isequal (size(jacobian(f, x)), [2 1]))

