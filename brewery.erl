-module (brewery).
-export ([createCaseOfBeer/1]).

createCaseOfBeer(Main) -> spawn(fun() -> initLoop(Main) end).

initLoop(Main) ->
	Self = self(),
	spawn(fun() -> infoTimer(Main, Self) end),
	loop(0, 12).

infoTimer(Main, Brewery) ->
	timer:sleep(10000),
	Brewery ! {self(), info},
	receive
		{From, Stock, Max} -> 
			Main ! ["********************** INFO: ~p/~p **********************", Stock, Max],
			infoTimer(Main, From)
	end.

loop(Stock, FullValue) -> 
	receive
		{From, isEmpty} -> 
			From ! Stock =:= 0,
			loop(Stock, FullValue);

		{From, isFull} -> 
			From ! Stock >= FullValue,
			loop(Stock, FullValue);

		{From, add} when Stock >= FullValue-> 
			From ! {self(), full},
			loop(Stock + 1, FullValue);

		{From, add} ->
			From ! {self(), true},
			loop(Stock + 1, FullValue);

		{From, remove} when Stock =:= 0 -> 
			From ! {self(), empty},
			loop(Stock, FullValue);

		{From, remove} -> 
			From ! {self(), true},
			loop(Stock - 1, FullValue);

		{From, info} -> 
			From ! {self(), Stock, FullValue},
			loop(Stock, FullValue);

		{From, newBox} ->
			NewFullValue = FullValue +12,
			From ! {self(), newBoxCreated, NewFullValue},
			loop(Stock, NewFullValue)
	end.