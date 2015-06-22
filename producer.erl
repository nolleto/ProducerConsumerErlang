-module (producer).
-export ([wakeUpTheBrewer/3]).

wakeUpTheBrewer(Id, Pid, Main) -> spawn(fun() -> newSlave(Id, Pid, Main) end).

newSlave(Id, Pid, Main) ->
	Main ! ["A slave Brewer 'HIRED'"],
	needCreateBeer(Id, Pid, Main, 0, 0).

needCreateBeer(Id, Pid, Main, Beers, Idle) ->
	Pacience = 1000,
	Pid ! {self(), isFull},
	receive
		true -> 
			Main ! ["Slave Brewer ~p is smoking", Id],
			timer:sleep(Pacience),
			if
				Idle >= 4 -> alertIdle(Id, Main);
				Idle < 4 -> doNothing
			end,
			needCreateBeer(Id, Pid, Main, Beers, Idle + 1);

		false -> createBeer(Id, Pid, Main, Beers)
	end.

createBeer(Id, Pid, Main, Beers) ->
	timer:sleep(5000),
	if 
		Beers >= 15 ->
			Main ! { Id, brewerDead };

		Beers < 15 ->
			Pid ! {self(), add},
			receive
				{From, true} -> 
					Main ! ["Slave Brewer ~p created a beer (~p)", Id, Beers + 1],
					needCreateBeer(Id, From, Main, Beers + 1, 0);

				{From, full} ->
					Main ! ["Slave Brewer ~p say 'the box of beer is full! Can a have some rest?'", Id],
					needCreateBeer(Id, From, Main, Beers, 0)

			end
	end.

alertIdle(Id, Main) -> 
	Main ! ["Slave Brewer ~p say 'finaly a can rest =)'", Id],
	Main ! {Id, brewerIdle}.