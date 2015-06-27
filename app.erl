-module (app).
-export ([init/0,test/1]).
-import (producer, [wakeUpTheBrewer/3]).
-import (consumer, [inviteDrunkGuy/3]).
-import (brewery, [createCaseOfBeer/1]).
-import (filehelper, [create_file/1,print_line/2]).

test(N) -> filehelper:create_file(N).

init() ->
	Self = self(),
	Id = 1,
	B = brewery:createCaseOfBeer(Self),
	hireBrewer(Id, B),
	inviteGuy(Id, B),
	loop(B, Id, Id).

loop(B, ProducerId, GuyId) ->
	receive
		{ M, message } ->
			printSomething(M),
			loop(B, ProducerId, GuyId);

		[ Phrase | Args ] ->
			printSomething(Phrase, Args),
			loop(B, ProducerId, GuyId);

		{ guyDead } ->
			NewGuyId = GuyId + 1,
			SuperNewGuyId = NewGuyId + 1,
			inviteGuy(NewGuyId, B),
			inviteGuy(SuperNewGuyId, B),
			loop(B, ProducerId, SuperNewGuyId);

		{ brewerDead } ->
			NewProducerId = ProducerId + 1,
			hireBrewer(NewProducerId, B),
			loop(B, NewProducerId, GuyId);

		{ brewerIdle } ->
			loop(B, ProducerId, GuyId);

		{ guyThirsty } ->
			NewProducerId = ProducerId + 1,
			hireBrewer(NewProducerId, B),
			loop(B, NewProducerId, GuyId);

		{ inviteGuy } ->
			Main = self(),
			NewGuyId = GuyId + 1,
			inviteGuy(NewGuyId, B),
			loop(B, ProducerId, NewGuyId)

	end.

printSomething(M) ->
	io:nl(),
	io:format(M).

printSomething(P, A) ->
	io:nl(),
	io:format(P, A).

hireBrewer(Id, B) ->
	producer:wakeUpTheBrewer(Id, B, self()).

inviteGuy(Id, B) ->
	consumer:inviteDrunkGuy(Id, B, self()).


% cd('C:\\ProducerConsumerErlang').
% c(str).
% c(producer).
% c(consumer).
% c(brewery).
% c(filehelper).
% c(app).
% app:init().
