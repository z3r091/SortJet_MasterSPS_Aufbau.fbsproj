(* METADATA
{
	"v3Meta": {
		"objectGuid": "00eb9e03-2e2c-414f-a437-451e0f99c47c"
	}
}
*)
FUNCTION TransferShuttleBetriebsstopAktiv : BOOL
VAR_INPUT
  eAutomatikkreis : Automatikkreis_EN;
END_VAR
VAR
  wlIndex : WORD;
END_VAR

TransferShuttleBetriebsstopAktiv := FALSE;

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  
  IF NOT starrTransfershuttleBasisParameter[wlIndex].stMKs.bDeaktivieren THEN

    IF StationInAutomatikkreis(starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, eAutomatikkreis) THEN
      IF aTransfershuttles[wlIndex].bpAnforderungBetriebsstopp THEN
        TransferShuttleBetriebsstopAktiv := TRUE;
        RETURN;
      END_IF
    END_IF
  END_IF
END_FOR
END_FUNCTION