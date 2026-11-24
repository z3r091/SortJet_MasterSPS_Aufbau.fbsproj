(* METADATA
{
	"v3Meta": {
		"objectGuid": "e70b4212-04d3-4e87-811c-4965fb106fb4"
	}
}
*)
FUNCTION Callback_BEFORE_RESET : BOOL
//  Import function to close open sockets from the application.
//  Return: None
VAR_INPUT
  dwEvent:DWORD;
  dwFilter:DWORD;
  dwOwner:DWORD;
END_VAR
VAR
END_VAR

TCP_Global.bgCallback_BEFORE_RESET := TRUE;
Callback_Shutdown();
END_FUNCTION