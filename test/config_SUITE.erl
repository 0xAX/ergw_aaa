%% Copyright 2017, Travelping GmbH <info@travelping.com>

%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public License
%% as published by the Free Software Foundation; either version
%% 2 of the License, or (at your option) any later version.

-module(config_SUITE).

-compile(export_all).

-include_lib("common_test/include/ct.hrl").
-include("ergw_aaa_test_lib.hrl").

-define(error_option(Config),
	?match({error,{options, _}}, (catch ergw_aaa_config:load_config(Config)))).

-define(ok_option(Config),
	?match([_|_], ergw_aaa_config:load_config(Config))).

-define(def_app(Config),
        [{applications, [{default, Config}]}]).

-define(RADIUS_OK_CFG,
	[{nas_identifier,<<"NAS-Identifier">>},
	 {radius_auth_server,{{127,0,0,1},1812,<<"secret">>}},
	 {radius_acct_server,{{0,0,0,0,0,0,0,1},1813,<<"secret">>}},
	 {acct_interim_interval, 600},
	 {framed_protocol, 'PPP'},
	 {service_type, 'Framed-User'}]).

-define(RADIUS_CFG(Key, Value),
	lists:keystore(Key, 1, ?RADIUS_OK_CFG, {Key, Value})).

-define(DIAMETER_OK_CFG,
	[{nas_identifier,<<"NAS-Identifier">>},
	 {host, <<"127.0.0.1">>},
	 {realm, <<"example.com">>},
	 {connect_to, <<"aaa://127.0.0.1:3868">>},
	 {acct_interim_interval, 600},
	 {framed_protocol, 'PPP'},
	 {service_type, 'Framed-User'}]).

-define(DIAMETER_CFG(Key, Value),
	lists:keystore(Key, 1, ?DIAMETER_OK_CFG, {Key, Value})).

%%%===================================================================
%%% API
%%%===================================================================

all() ->
    [config].

config() ->
    [{doc, "Test the config validation"}].
config(_Config)  ->
    ?ok_option([{vsn, "1.0.0"}]),

    ?ok_option([{product_name, "PRODUCT"}]),
    ?ok_option([{product_name, <<"PRODUCT">>}]),
    ?error_option([{product_name, 1}]),

    ?error_option(?def_app({provider, invalid_option})),
    ?error_option(?def_app({provider, invalid_handler, []})),

    ?error_option(?def_app({provider, ergw_aaa_mock, [{invalid_option, []}]})),
    ?error_option(?def_app({provider, ergw_aaa_mock, [{shared_secret, invalid_secret}]})),
    ?ok_option(?def_app({provider, ergw_aaa_mock, []})),
    ?ok_option(?def_app({provider, ergw_aaa_mock, [{shared_secret, <<"secret">>}]})),

    ?error_option(?def_app({provider, ergw_aaa_radius, []})),
    ?error_option(?def_app({provider, ergw_aaa_radius, [{invalid_option, []} | ?RADIUS_OK_CFG]})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(nas_identifier, invalid_id)})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_auth_server, invalid_id)})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_acct_server, invalid_id)})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_acct_server, {"undefined.example.net",1812,<<"secret">>})})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_acct_server, {invalid_ip,1812,<<"secret">>})})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_acct_server, {{127,0,0,1},invalid_port,<<"secret">>})})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_acct_server, {{127,0,0,1},1812,invalid_secret})})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(disabled, [invalid])})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(acct_interim_interval, "10")})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(service_type, "Framed-User")})),
    ?error_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(framed_protocol, "PPP")})),

    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_OK_CFG})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(radius_acct_server, {"localhost",1812,<<"secret">>})})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(disabled, [acct, auth])})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(disabled, [acct])})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(disabled, [])})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(acct_interim_interval, 10)})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(service_type, 'Framed-User')})),
    ?ok_option(?def_app({provider, ergw_aaa_radius, ?RADIUS_CFG(framed_protocol, 'PPP')})),


    ?error_option(?def_app({provider, ergw_aaa_diameter, []})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, [{invalid_option, []} | ?DIAMETER_OK_CFG]})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(nas_identifier, invalid_id)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(host, invalid_host)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(realm, invalid_realm)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(connect_to, invalid_uri)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(host, <<"undefined.example.net">>)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(connect_to, <<"http://example.com:12345">>)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(acct_interim_interval, <<"100">>)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(service_type, <<"Framed-User">>)})),
    ?error_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_CFG(framed_protocol, <<"PPP">>)})),

    ?ok_option(?def_app({provider, ergw_aaa_diameter, ?DIAMETER_OK_CFG})),

    ok.
