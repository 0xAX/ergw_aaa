-module(eradius_test_handler).

-behaviour(eradius_server).

-export([start/0, stop/0, send_request/1, radius_request/3, ready/0]).

-include_lib("eradius/include/eradius_lib.hrl").
-include_lib("eradius/include/eradius_dict.hrl").
-include_lib("eradius/include/dictionary.hrl").

start() ->
    application:stop(eradius),
    application:load(eradius),
    application:set_env(eradius, radius_callback, ?MODULE),
    application:set_env(eradius, session_nodes, local),
    application:set_env(eradius, one, [{{"ONE", []}, [{"127.0.0.1", "secret"}]}]),
    application:set_env(eradius, servers, [{one, {"127.0.0.1", [1812, 1813]}}]),
    application:set_env(eradius, metrics, []),
    application:ensure_all_started(eradius).

stop() ->
    application:stop(eradius),
    application:unload(eradius),
    application:start(eradius).

ready() ->
    eradius:modules_ready([?MODULE]).

send_request(IP) ->
    {ok, R, A} = eradius_client:send_request({IP, 1812, "secret"}, #radius_request{cmd = request}, []),
    #radius_request{cmd = Cmd} = eradius_lib:decode_request(R, <<"secret">>, A),
    Cmd.

radius_request(#radius_request{cmd = request} = _Req, _Nasprop, _Args) ->
    IEs = [{?Acct_Interim_Interval, 1800}],
    {reply, #radius_request{cmd = accept, attrs = IEs}};
radius_request(#radius_request{cmd = accreq} = _Req, _Nasprop, _Args) ->
    {reply, #radius_request{cmd = accresp}};
radius_request(_Req, _Nasprop, _Args) ->
    {reply, #radius_request{cmd = accept}}.