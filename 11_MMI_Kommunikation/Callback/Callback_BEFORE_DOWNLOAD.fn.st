(* METADATA
{
	"v3Meta": {
		"objectGuid": "aff58b34-1c39-4329-9848-976d484037fa"
	}
}
*)
FUNCTION Callback_BEFORE_DOWNLOAD : BOOL
(*
  Import function to close open sockets from the application.
  Return: None
*)
VAR_INPUT
END_VAR
VAR
END_VAR

TCP_Global.bgCallback_BEFORE_DOWNLOAD := TRUE;
Callback_Shutdown();
END_FUNCTION