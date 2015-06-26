-module(filehelper).
-export([print_list/1,create_file/1,print_line/2]).

print_list(List) ->
  Filename = "log.txt",
  case file:open(Filename, [write, append]) of
    {ok, Device} ->
      delete_content(Device),
      print(Device, List);

    {error, Msg} ->
      Msg
  end.

create_file(Id) ->
  Filename = "\\log\\process_" ++ Id ++ ".txt",
  case file:open(Filename, [write]) of
    {ok, Device} -> Device;
    {error, Msg} -> Msg
  end.

print_line(Device, Message) -> print(Device, [Message]).

print(Id, Content) ->
  Filename = "\\log\\process_" ++ id ++ ".txt",
  case file:open(Filename, [write, append]) of
    {ok, Device} ->
      delete_content(Device),
      print(Device, List),
      Device;

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
