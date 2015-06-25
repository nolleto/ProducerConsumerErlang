-module(filehelper).
-export([print_list/1]).

print_list(List) ->
  Filename = "log.txt",
  case file:open(Filename, [write, append]) of
    {ok, Device} ->
      delete_content(Device),
      print(Device, List);

    {error, Msg} ->
      Msg
  end.

delete_content(Device) ->
  file:truncate(Device).

print(Device, [H|T]) ->
  file:write(Device, H ++ "\n"),
  print(Device, T);

print(Device, []) ->
  file:write(Device, "\n").
