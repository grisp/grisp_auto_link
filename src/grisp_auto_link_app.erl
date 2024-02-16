% @doc grisp_auto_link public API.
-module(grisp_auto_link_app).

-behavior(application).

% Callbacks
-export([start/2]).
-export([stop/1]).

%--- Callbacks -----------------------------------------------------------------

% @private
start(_Type, _Args) -> grisp_auto_link_sup:start_link().

% @private
stop(_State) -> ok.
