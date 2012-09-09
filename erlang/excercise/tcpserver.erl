-module(tcpserver).
-export([start/1]).
-export([stop/0]).

start(Port) ->
	ListenPID = spawn_link(fun() -> startListen(Port) end),
	put("ListenPID", ListenPID),
	ListenPID.

stop() ->
	ListenPID = get("ListenPID"),
	exit(ListenPID, "STOP"),
	ListenPID.

startListen(Port) ->
	case gen_tcp:listen(Port, [binary, {packet, line},
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
		PID = spawn_link(fun() -> loopClient(Socket) end),
	    gen_tcp:controlling_process(Socket, PID),
		acceptLoop(Listen).

loopClient(S) ->	
	inet:setopts(S, [{active, once}]),	
	receive
		{tcp, Socket, Line} ->
			gen_tcp:send(Socket, Line),
			loopClient(Socket);
		{tcp_closed, Socket} ->
		    io:format("Socket ~p closed~n", [Socket]);
		{tcp_error, Socket, Reason} ->
	        io:format("Error on socket ~p reason: ~p~n", [Socket, Reason])
    end.
