-module (producer).
-export ([wakeUpTheBrewer/3]).
-import (filehelper, [create_file/2,print_line/2]).
-import (str, [to_string/1]).

wakeUpTheBrewer(Id, Brewery, App) -> spawn(fun() -> newSlave(Id, Brewery, App) end).

newSlave(Id, Brewery, App) ->
	File = filehelper:create_file(self(), Id),
	changeStatus(Id, App, File, "'HIRED'"),
	needCreateBeer(Id, Brewery, App, File, 0, 0).

needCreateBeer(Id, Brewery, App, File, Beers, Idle) ->
	Pacience = 1000,
	Brewery ! {self(), isFull},
	receive
		true ->
			%changeStatus(Id, App, File, "is smoking"),
			timer:sleep(Pacience),
			if
				Idle >= 4 -> alertIdle(Id, App);
				Idle < 4 -> doNothing
			end,
			needCreateBeer(Id, Brewery, App, File, Beers, Idle + 1);

		false -> createBeer(Id, Brewery, App, File, Beers)
	end.

createBeer(Id, Brewery, App, File, Beers) ->
	timer:sleep(5000),
	if
		Beers >= 15 ->
			alertDead(Id, App, File);

		Beers < 15 ->
			Brewery ! {self(), add},
			receive
				{From, true, Beer} ->
					changeStatus(Id, App, File, "created " ++ Beer),
					needCreateBeer(Id, From, App, File, Beers + 1, 0);

				{From, full} ->
					%changeStatus(Id, App, File, "say 'the box of beer is full! Can a have some rest?'"),
					needCreateBeer(Id, From, App, File, Beers, 0)

			end
	end.

changeStatus(Id, App, File, Status) ->
	NewId = str:to_string(Id),
	Message =  "Slave Brewer " ++ NewId ++ " -> " ++ Status,
	filehelper:print_line(File, Message),
	App ! { Message, message }.

alertDead(Id, App, File) ->
	changeStatus(Id, App, File, "dead"),
	App ! { brewerDead }.

alertIdle(Id, App) ->
	%App ! ["Slave Brewer ~p say 'finaly a can rest =)'", Id],
	App ! {Id, brewerIdle}.
