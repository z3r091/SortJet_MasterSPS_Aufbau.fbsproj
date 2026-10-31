(* METADATA
{
  "v3Meta": {
    "objectGuid": "77446a83-5414-4511-a85e-8d0f27ae2e7b"
  }
}
*)
FUNCTION getRealShuttleMinPos : REAL
VAR_INPUT
	wShuttleNummer : WORD;
END_VAR


getRealShuttleMinPos := aShuttle[wShuttleNummer].Querfahrt.Antrieb.rpMinPosition;
END_FUNCTION