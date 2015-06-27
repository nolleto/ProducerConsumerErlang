-module (str).
-export ([format/1,format/2,to_string/1]).

to_string(M) -> lists:flatten(io_lib:format("~p", [M])).

format(S,A) -> lists:flatten(io_lib:format(S, [A])).

format([S|A]) -> lists:flatten(io_lib:format(S, A)).
