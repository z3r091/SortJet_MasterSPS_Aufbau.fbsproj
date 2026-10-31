(* METADATA
{
  "v3Meta": {
    "objectGuid": "b602f436-2d06-46cb-9d80-1c5ce9f0f7bc"
  }
}
*)
FUNCTION Callback_Shutdown : DWORD
(*
  Import function to close open sockets from the application.
  Return: None
*)
VAR_INPUT
END_VAR
VAR
END_VAR

TCPMain.l_fb_SortjetHMI.M_CloseSocket();

TCP_Global.bgCallback_Shutdown := TRUE;
END_FUNCTION