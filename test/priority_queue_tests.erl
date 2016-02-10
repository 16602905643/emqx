%%--------------------------------------------------------------------
%% Copyright (c) 2012-2016 Feng Lee <feng@emqtt.io>.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(priority_queue_tests).

-include("emqttd.hrl").

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

-define(PQ, priority_queue).

plen_test() ->
    Q = ?PQ:new(),
    ?assertEqual(0, ?PQ:plen(0, Q)),
    Q0 = ?PQ:in(z, Q),
    ?assertEqual(1, ?PQ:plen(0, Q0)),
    Q1 = ?PQ:in(x, 1, Q0),
    ?assertEqual(1, ?PQ:plen(1, Q1)),
    Q2 = ?PQ:in(y, 2, Q1),
    ?assertEqual(1, ?PQ:plen(2, Q2)),
    Q3 = ?PQ:in(z, 2, Q2),
    ?assertEqual(2, ?PQ:plen(2, Q3)),
    {_, Q4} = ?PQ:out(1, Q3),
    ?assertEqual(0, ?PQ:plen(1, Q4)),
    {_, Q5} = ?PQ:out(Q4),
    ?assertEqual(1, ?PQ:plen(2, Q5)),
    {_, Q6} = ?PQ:out(Q5),
    ?assertEqual(0, ?PQ:plen(2, Q6)),
    ?assertEqual(1, ?PQ:len(Q6)),
    {_, Q7} = ?PQ:out(Q6),
    ?assertEqual(0, ?PQ:len(Q7)).

out2_test() ->
    Els = [a, {b, 1}, {c, 1}, {d, 2}, {e, 2}, {f, 2}],
    Q  = ?PQ:new(),
    Q0 = lists:foldl(
            fun({El, P}, Q) ->
                    ?PQ:in(El, P, Q);
                (El, Q) ->
                    ?PQ:in(El, Q)
            end, Q, Els),
    {Val, Q1} = ?PQ:out(Q0),
    ?assertEqual({value, d}, Val),
    {Val1, Q2} = ?PQ:out(2, Q1),
    ?assertEqual({value, e}, Val1),
    {Val2, Q3} = ?PQ:out(1, Q2),
    ?assertEqual({value, b}, Val2),
    {Val3, Q4} = ?PQ:out(Q3),
    ?assertEqual({value, f}, Val3),
    {Val4, Q5} = ?PQ:out(Q4),
    ?assertEqual({value, c}, Val4),
    {Val5, Q6} = ?PQ:out(Q5),
    ?assertEqual({value, a}, Val5),
    {empty, _Q7} = ?PQ:out(Q6).

-endif.

