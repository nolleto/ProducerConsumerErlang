-module (app).
-export ([init/0,doit/0,test/0]).
-import (producer, [wakeUpTheBrewer/3]).
-import (consumer, [inviteDrunkGuy/3]).
-import (brewery, [createCaseOfBeer/1]).

test() ->
	io:format("Oi!!!"),
	timer:sleep(2000),
	io:format("\r"),
	test().

doit() ->
	FileName = '\\console.txt',
	case file:read_file_info(FileName) of
			{ok, FileInfo} ->
								file:write_file(FileName, "Abhimanyu", [append]);
			{error, enoent} ->
								% File doesn't exist
								donothing
	end.

init() ->
	Self = self(),
	B = brewery:createCaseOfBeer(Self),
	producer:wakeUpTheBrewer(1, B, Self),
	consumer:inviteDrunkGuy(1, B, Self),
	loop(B, 1, 1).

loop(B, ProducerId, GuyId) ->
	receive
		[ Phrase | Args ] ->
			printSomething(Phrase, Args),
			loop(B, ProducerId, GuyId);

		{ Id, guyDead } ->
			Main = self(),
			printSomething("Guy ~p is dead! Inviting other guy", [Id]),
			NewGuyId = GuyId + 1,
			spawn(fun() -> inviteGuy(NewGuyId, B, Main) end),
			loop(B, ProducerId, NewGuyId);

		{ Id, brewerDead } ->
			Main = self(),
			NewProducerId = ProducerId + 1,
			printSomething("Brewer ~p is dead! Hiring other slav... I mean Brewer", [Id]),
			hireBrewer(NewProducerId, B, Main),
			loop(B, NewProducerId, GuyId);

		{ Id, brewerIdle } ->
			loop(B, ProducerId, GuyId);

		{ Id, guyThirsty } ->
			NewProducerId = ProducerId + 1,
			SuperNewProducerId = NewProducerId + 1,
			hireBrewer(NewProducerId, B, self()),
			hireBrewer(SuperNewProducerId, B, self()),
			loop(B, SuperNewProducerId, GuyId);

		{ Id, inviteGuy } ->
			Main = self(),
			NewGuyId = GuyId + 1,
			spawn(fun() -> inviteGuy(NewGuyId, B, Main) end),
			loop(B, ProducerId, NewGuyId)

	end.

printSomething(P, A) ->
	io:nl(),
	io:format(P, A).

hireBrewer(Id, B, Main) ->
	producer:wakeUpTheBrewer(Id, B, Main).

inviteGuy(Id, B, Main) ->
	timer:sleep(2000),
	consumer:inviteDrunkGuy(Id, B, Main).


% cd('C:\\ErlangProblema').
% c(app).
% app:init().
% c(brewery).
% P = brewery:wakeUpTheBrewer().
% c(producer).
% c(consumer).
% c(brewery).
