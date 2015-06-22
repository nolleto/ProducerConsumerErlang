-module (consumer).
-export ([inviteDrunkGuy/3]).

inviteDrunkGuy(Id, Pid, Main) -> spawn(fun() -> newGuy(Id, Pid, Main) end).

newGuy(Id, Pid, Main) ->
	Main ! ["A drunk guy enter in the party"],
	canIDrink(Id, Pid, Main, 0, 0).

canIDrink(Id, Pid, Main, Drinks, Thirsty) ->
	Pacience = 5000,
	Pid ! {self(), isEmpty},
	receive
		true -> 
			Main ! ["Guy ~p want a beer but doens't have any!", Id],
			timer:sleep(Pacience),
			if
				Thirsty >= 1 -> alertThirsty(Id, Main);
				Thirsty < 1 ->	doNothing
			end,
			canIDrink(Id, Pid, Main, Drinks, Thirsty + 1);

		false -> drink(Id, Pid, Main, Drinks)
	end.


drink(Id, Pid, Main, Drinks) ->
	timer:sleep(1000),
	if
		Drinks >= 10 ->
			Main ! { Id, guyDead };

		Drinks < 10 ->
			Pid ! {self(), remove},
			receive
				{From, true} when Drinks == 5 -> 
					Main ! ["Guy ~p is really drank  (~p)", Id, Drinks + 1],
					%inviteFriend(Id, Main),
					canIDrink(Id, From, Main, Drinks + 1, 0);

				{From, true} when Drinks == 8 -> 
					Main ! ["Guy ~p must stop  (~p)", Id, Drinks + 1],
					canIDrink(Id, From, Main, Drinks + 1, 0);

				{From, true} -> 
					Main ! ["Guy ~p drank a beer  (~p)", Id, Drinks + 1],
					canIDrink(Id, From, Main, Drinks + 1, 0);

				{From, empty} ->
					Main ! ["Guy ~p NEED some beer! =(", Id],
					canIDrink(Id, From, Main, Drinks, 0)

			end
	end.

alertThirsty(Id, Main) -> 
	Main ! ["Guy ~p NEED some beer! =(", Id],
	Main ! {Id, guyThirsty}.

inviteFriend(Id, Main) -> 
	Main ! {Id, inviteGuy}.