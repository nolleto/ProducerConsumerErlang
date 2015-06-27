-module(filehelper).
-export([print_list/1,create_file/2,print_line/2]).
-import (str, [to_string/1]).

print_list(List) ->
  Filename = "log.txt",
  case file:open(Filename, [write, append]) of
    {ok, Device} ->
      delete_content(Device),
      print(Device, List);

    {error, Msg} ->
      Msg
  end.

create_file(From, Id) ->
  NewId = str:to_string(Id),
  Filename = "process_" ++ NewId ++ " (" ++ getProcessName(From) ++ ").txt",
  case file:open(Filename, [write]) of
    {ok, Device} ->
      delete_content(Device),
      Device;

    {error, Msg} -> Msg
  end.

print_line(Device, Message) -> print(Device, [Message]).

delete_content(Device) ->
  file:truncate(Device).

print(Device, [H|T]) ->
  file:write(Device, H),
  print(Device, T);

print(Device, []) ->
  file:write(Device, "\n").

getProcessName(P) ->
  S = str:to_string(P),
  T = re:replace(S, "<", "", [global, {return, list}]),
  re:replace(T, ">", "", [global, {return, list}]).
