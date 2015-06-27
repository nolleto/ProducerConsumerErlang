-module (consumer).
-export ([inviteDrunkGuy/3]).
-import (filehelper, [create_file/2,print_line/2]).
-import (str, [to_string/1]).

inviteDrunkGuy(Id, Brewery, App) -> spawn(fun() -> newGuy(Id, Brewery, App) end).

newGuy(Id, Brewery, App) ->
	File = filehelper:create_file(self(), Id),
	changeStatus(Id, App, File, "enter in the party"),
	timer:sleep(10000),
	canIDrink(Id, Brewery, App, File, 0).

canIDrink(Id, Brewery, App, File, Drinks) ->
	Pacience = 5000,
	Brewery ! {self(), isEmpty},
	receive
		true ->
			changeStatus(Id, App, File, "want a beer but doens't have any!"),
			alertThirsty(App),
			timer:sleep(Pacience),
			canIDrink(Id, Brewery, App, File, Drinks);

		false -> drink(Id, Brewery, App, File, Drinks)
	end.


drink(Id, Brewery, App, File, Drinks) ->
	timer:sleep(1000),
	if
		Drinks >= 10 ->
			alertDead(Id, App, File);

		Drinks < 10 ->
			Brewery ! {self(), remove},
			receive
				{From, true, Beer} when Drinks == 5 ->
					drinking(),
					changeStatus(Id, App, File, "drink " ++ Beer ++ " and is really drank"),
					canIDrink(Id, From, App, File, Drinks + 1);

				{From, true, Beer} when Drinks == 8 ->
					drinking(),
					changeStatus(Id, App, File, "drink " ++ Beer ++ " and must stop"),
					canIDrink(Id, From, App, File, Drinks + 1);

				{From, true, Beer} ->
					drinking(),
					changeStatus(Id, App, File, "drink " ++ Beer),
					canIDrink(Id, From, App, File, Drinks + 1);

				{From, empty} ->
					changeStatus(Id, App, File, "NEED some beer! =("),
					canIDrink(Id, From, App, File, Drinks)

			end
	end.

drinking() ->
	timer:sleep(2000).

changeStatus(Id, App, File, Status) ->
	NewId = str:to_string(Id),
	Message =  "Drunk guy " ++ NewId ++ " -> " ++ Status,
	filehelper:print_line(File, Message),
	App ! { Message, message }.

alertThirsty(App) ->
	App ! { guyThirsty }.

alertDead(Id, App, File) ->
	changeStatus(Id, App, File, "dead =("),
	App ! { guyDead }.
