%% Copyright (c) 2013-2019 EMQ Technologies Co., Ltd. All Rights Reserved.
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

-module(emqx_app).

-behaviour(application).

-export([ start/2
        , stop/1
        ]).

-define(APP, emqx).

%%--------------------------------------------------------------------
%% Application callbacks
%%--------------------------------------------------------------------

start(_Type, _Args) ->
    create_mnesia_dir("data/mnesia"),
    emqx_gen_config:generate_config("etc/emqx.conf", "etc/plugins", "data/configs", "releases/3.1.2/schema"),
    print_banner(),
    ekka:start(),
    {ok, Sup} = emqx_sup:start_link(),
    emqx_modules:load(),
    emqx_plugins:init(),
    emqx_plugins:load(),
    emqx_listeners:start(),
    start_autocluster(),
    register(emqx, self()),

    emqx_alarm_handler:load(),
    emqx_logger_handler:init(),

    print_vsn(),
    {ok, Sup}.

-spec(stop(State :: term()) -> term()).
stop(_State) ->
    emqx_listeners:stop(),
    emqx_modules:unload().

%%--------------------------------------------------------------------
%% Print Banner
%%--------------------------------------------------------------------

print_banner() ->
    io:format("Starting ~s on node ~s~n", [?APP, node()]).

print_vsn() ->
    {ok, Descr} = application:get_key(description),
    {ok, Vsn} = application:get_key(vsn),
    io:format("~s ~s is running now!~n", [Descr, Vsn]).

%%--------------------------------------------------------------------
%% Autocluster
%%--------------------------------------------------------------------

start_autocluster() ->
    ekka:callback(prepare, fun emqx:shutdown/1),
    ekka:callback(reboot,  fun emqx:reboot/0),
    ekka:autocluster(?APP).

create_mnesia_dir(Dir) ->
    MnesiaDir = filename:join(Dir, node()),
    filelib:ensure_dir(MnesiaDir),
    application:set_env(mnesia, dir, MnesiaDir).
