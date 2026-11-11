(* METADATA
{
	"v3Meta": {
		"objectGuid": "1fe72243-ca8e-4332-9b86-e73fbf76fe1f"
	}
}
*)
FUNCTION StationHatShuttleNachbar : BOOL
VAR_IN_OUT CONSTANT
  stpBasis : StationBasisParameter_ST;
END_VAR
VAR
  wlNachbar : WORD;
  stlNachbar : REFERENCE TO StationBasisParameter_ST;
END_VAR

(* Hinweis:
   - TRUE, wenn ein konfigurierter Ein- oder Austransport-Partner der Station ein Shuttle ist
     [MK stSchnittstellendaten.bStationIstShuttle, kann auch bei einer Station gesetzt sein]
   - Im Systemcheck kann eine Scheibe dann zum Teil noch auf dem Shuttle liegen,
     eine abweichende Belegung ist deshalb nur ein Hinweis und kein Fehler
*)
StationHatShuttleNachbar := FALSE;

IF NOT __ISVALIDREF( stpBasis.stMKs ) THEN
  RETURN;
END_IF

FOR wlNachbar := cERSTES_SHUTTLE TO cLETZTE_FREMDANLAGE_EINLAUF DO

  IF    ( stpBasis.stMKs.stSchnittstellendaten.aEintransporte.Station[wlNachbar] <> TransportRichtung_EN.Default )
     OR ( stpBasis.stMKs.stSchnittstellendaten.aAustransporte.Station[wlNachbar] <> TransportRichtung_EN.Default )
  THEN
    stlNachbar REF= getBasis( wlNachbar );

    IF     __ISVALIDREF( stlNachbar )
       AND_THEN __ISVALIDREF( stlNachbar.stMKs )
       AND_THEN stlNachbar.stMKs.stSchnittstellendaten.bStationIstShuttle
    THEN
      StationHatShuttleNachbar := TRUE;
      RETURN;
    END_IF
  END_IF

END_FOR
END_FUNCTION