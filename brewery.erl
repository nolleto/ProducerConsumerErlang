-module (brewery).
-export ([createCaseOfBeer/1]).
-import (str, [to_string/1]).

createCaseOfBeer(Main) -> spawn(fun() -> initLoop(Main) end).

initLoop(Main) ->
  Self = self(),
  %spawn(fun() -> infoTimer(Main, Self) end),
  loop([], 0, 12).

infoTimer(Main, Brewery) ->
  timer:sleep(10000),
  Brewery ! {self(), info},
  receive
    {From, Stock, Max} ->
      Main ! ["********************** INFO: ~p/~p **********************", Stock, Max],
      infoTimer(Main, From)
  end.

loop(Stock, Count, FullValue) ->
  receive
    {From, isEmpty} ->
      From ! list_empty(Stock),
      loop(Stock, Count, FullValue);

    {From, isFull} ->
      Beers = list_length(Stock),
      From ! Beers >= FullValue,
      loop(Stock, Count, FullValue);

    {From, add} ->
      Beers = list_length(Stock),
      if
        Beers >= FullValue ->
          From ! {self(), full},
          loop(Stock, Count, FullValue);

        Beers < FullValue ->
          NewCount = Count + 1,
          Temp = str:to_string(NewCount),
          Beer = "beer " ++ Temp,
          From ! {self(), true, Beer},
          loop(Stock ++ [Beer], NewCount, FullValue)
      end;

    {From, remove} ->
      Beers = list_length(Stock),
      if
        Beers =:= 0 ->
          From ! {self(), empty},
          loop(Stock, Count, FullValue);

        Beers =/= 0 ->
          {B, L} = remove_list(Stock),
          From ! {self(), true, B},
          loop(L, Count, FullValue)
      end;

    {From, info} ->
      From ! {self(), list_length(Stock), FullValue},
      loop(Stock, Count, FullValue)
  end.

list_empty([_|_]) -> false;
list_empty([]) -> true.

remove_list([H|T]) -> { H, T }.

list_length(L) -> list_length(L, 0).

list_length([_|T], V) -> list_length(T, V+1);
list_length([], V) -> V.
