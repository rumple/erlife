%% The MIT License (MIT)

%% Copyright (c) 2014 rumple

%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:

%% The above copyright notice and this permission notice shall be included in all
%% copies or substantial portions of the Software.

%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.

-module(erlife).
-compile(export_all).
-import(lists, [sum/1, seq/2, sublist/3, nth/2]).

%% This is initial grid
grid() -> {grid, 5, 5,
            [0,0,0,0,0,
             0,0,1,0,0,
             0,0,1,0,0,
             0,0,1,0,0,
             0,0,0,0,0]
          }.

%% Accessors for the grid
get_gx({grid, GX, _, _}) -> GX.
get_gy({grid, _, GY, _}) -> GY.
get_grid({grid, _, _, G}) -> G.

%% Print a grid
show_grid(G) ->
    [io:format("~p~n", [sublist(get_grid(G), N * get_gx(G) + 1,
                    get_gx(G))]) || N <- seq(0, get_gx(G)-1)],
    io:format("~n"),
    ok.

%% Get value of a cell given X and Y (0 based)
get_cell(X, Y, G) ->
    nth((Y * get_gx(G)) + X + 1, get_grid(G)).

%% Get number alive neighbours of a cell given X and Y (0 based)
get_neighbours(X,Y,G) ->
    Gx = get_gx(G),
    Gy = get_gy(G),
    Xrange = if (X > 0) and (X < (Gx - 1)) -> seq(X-1, X+1);
        (X > 0) and (X =:= (Gx - 1)) -> seq(X-1, X);
        (X =:= 0) and (X < (Gx - 1)) -> seq(X, X+1)
    end,
    Yrange = if (Y > 0) and (Y < (Gy - 1)) -> seq(Y-1, Y+1);
        (Y > 0) and (Y =:= (Gy - 1)) -> seq(Y-1, Y);
        (Y =:= 0) and (Y < (Gy - 1)) -> seq(Y, Y+1)
    end,
    sum([get_cell(A,B,G) || A <- Xrange, B <- Yrange, (A =/= X) or (B =/= Y)]).

%% Get cell for next generation
get_newcell(X, Y, G) ->
    Cell_value = get_cell(X, Y, G),
    Cell_Neighbours = get_neighbours(X, Y, G),
    if (Cell_value =:= 1) and (Cell_Neighbours < 2) -> 0;
        (Cell_value =:= 1) and (Cell_Neighbours > 3) -> 0;
        (Cell_value =:= 0) and (Cell_Neighbours =:= 3) -> 1;
        true -> Cell_value
    end.

%% New generation from current generation
get_newgen(G) ->
    Gx = get_gx(G),
    Gy = get_gy(G),
    Grid = [get_newcell(B, A, G) || A <- seq(0, Gx - 1), B <- seq(0, Gy - 1)],
    {grid, Gx, Gy, Grid}.

run(_, 0) -> ok;

run(G, N) ->
    show_grid(G),
    run(get_newgen(G), N-1).

