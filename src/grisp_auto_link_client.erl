-module(grisp_auto_link_client).
%--- Exports -------------------------------------------------------------------

% API
-export([start_link/0]).

-behaviour(gen_statem).
-export([init/1, terminate/3, code_change/4, callback_mode/0, handle_event/4]).

%--- Includes ------------------------------------------------------------------
-include_lib("kernel/include/logger.hrl").

%--- Macros --------------------------------------------------------------------
-define(STD_TIMEOUT, 1000).

% API
start_link() ->
    gen_statem:start_link({local, ?MODULE}, ?MODULE, [], []).

% gen_statem CALLBACKS ---------------------------------------------------------

init([]) -> {ok, waiting_connection, []}.

terminate(_Reason, _State, _Data) -> ok.

code_change(_Vsn, State, Data, _Extra) -> {ok, State, Data}.

callback_mode() -> [handle_event_function, state_enter].

%%% STATE CALLBACKS ------------------------------------------------------------

handle_event(enter, _OldState, done, _Data) ->
    keep_state_and_data;

% WAITING CONNECTION
handle_event(enter, _OldState, waiting_connection, _Data) ->
    {keep_state_and_data, [{state_timeout, 0, check}]};
handle_event(state_timeout, check, waiting_connection, Data) ->
    case grisp_io:is_connected() of
        false ->
            {keep_state_and_data, [{state_timeout, ?STD_TIMEOUT, check}]};
        true ->
            {next_state, pinging, Data}
    end;

% PINGING
handle_event(enter, _OldState, pinging, _Data) ->
    {keep_state_and_data, [{state_timeout, 0, ping}]};
handle_event(state_timeout, ping, pinging, Data) ->
    ?LOG_NOTICE(#{event => ping}),
    case grisp_io:ping() of
        {ok, <<"pong">>} ->
            ?LOG_NOTICE(#{event => pong, msg => "Device already linked"}),
            {next_state, done, Data};
        {ok, <<"pang">>} ->
            ?LOG_NOTICE(#{event => pang, msg => "Device not linked"}),
            {next_state, linking, Data};
        {error, disconnected} ->
            {next_state, waiting_connection, Data}
    end;

% LINKING
handle_event(enter, _OldState, linking, _Data) ->
    ?LOG_NOTICE(#{event => linking, msg => "Trying to link the device..."}),
    {keep_state_and_data, [{state_timeout, 0, retry}]};
handle_event(state_timeout, retry, linking, Data) ->
    case grisp_io:link_device() of
        {ok, <<"ok">>} ->
            ?LOG_NOTICE(#{event => linked, msg => "Device linked!"}),
            {next_state, done, Data};
        {error, disconnected} ->
            {next_state, waiting_connection, Data};
        {error, invalid_token} ->
            ?LOG_ERROR(#{event => invalid_token, msg => "Invalid Token!"}),
            {next_state, done, Data};
        Error ->
            ?LOG_ERROR(#{event => unexpected, error => Error}),
            {next_state, linking, Data,[{state_timeout, ?STD_TIMEOUT, retry}]}
    end;


handle_event( E, OldS, NewS, Data) ->
    ?LOG_ERROR(#{event => unhandled_event,
                 gen_statem_event => E,
                 old_state => OldS,
                 new_state => NewS,
                 data => Data}),
    keep_state_and_data.
