-module(tcpserver).
-export([start/1]).
-export([stop/0]).

start(Port) ->
	ListenPID = spawn(fun() -> startListen(Port) end),
	put("ListenPID", ListenPID),
	ListenPID.

stop() ->
	ListenPID = get("ListenPID"),
	exit(ListenPID, "STOP"),
	ListenPID.

startListen(Port) ->
	case gen_tcp:listen(Port, [binary, {packet, 0},
					 {reuseaddr, true},
					 {active, once}]) of
		
		{ok, Listen} ->
			io:format("The server is started.~n"),
    		acceptLoop(Listen);
		
		{error, Reason} ->
			io:format("The server failed to start.~n"),
			{error, Reason}
	end.

acceptLoop(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
		io:format("New client accepted.~n"),
		PID = spawn(fun() -> clientLoop(Socket) end),
	    gen_tcp:controlling_process(Socket, PID),
		acceptLoop(Listen).

clientLoop(S) ->	
	inet:setopts(S, [{active, once}]),	
	receive
	{tcp, Socket, Data} ->
%%	    io:format("Server received binary = ~p~n", [Data]),
%% 	    Str = binary_to_term(Bin),
%% 	    io:format("Server (unpacked)  ~p~n",[Str]),
%% 	    Reply = lib_misc:string2value(Str),
%% 	    io:format("Server replying = ~p~n",[Reply]),
	    gen_tcp:send(Socket, Data),
	    clientLoop(Socket);
	{tcp_closed, Socket} ->
	    io:format("Socket ~p closed~n", [Socket]);
	{tcp_error, Socket, Reason} ->
        io:format("Error on socket ~p reason: ~p~n", [Socket, Reason])
    end.