(* METADATA
{
	"v3Meta": {
		"objectGuid": "9d81c253-8159-4cb9-9043-a22c56ba0597"
	}
}
*)
METHOD checkGlastransportOptionen
VAR_INPUT
  Basis                : REFERENCE TO StationBasisParameter_ST;
  bAustransportPruefen : BOOL; // Austransport-Option wird nur vom Shuttle (Vorab) gebraucht
END_VAR
VAR
  n : WORD;
END_VAR

// Lage der letzten Scheibe im Eintransport (eGlastransport) muss je konfiguriertem Partner gesetzt sein,
// im Austransport nur beim Shuttle (Vorab). Transfershuttle als Partner hat die Option nicht.
// eGlastransport_Default gilt als fehlende Konfiguration, die SPS bleibt stehen.
FOR n := cERSTES_SHUTTLE TO cLETZTE_FREMDANLAGE_EINLAUF DO

  IF (     ( Basis.stMKs.stSchnittstellendaten.aEintransporte.Station[n] <> TransportRichtung_EN.Default )
       AND NOT ( ( n >= cERSTES_TRANSFERSHUTTLE ) AND ( n <= cLETZTES_TRANSFERSHUTTLE ) )
       AND ( Basis.stMKs.stSchnittstellendaten.aEintransporte.Glastransport[n] = eGlastransport_Default ) )
  THEN
    CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'aEintransporte.Glastransport darf bei konfiguriertem Partner nicht Default sein');
    SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
    NullRef := TRUE;
  END_IF

  IF (     bAustransportPruefen
       AND ( Basis.stMKs.stSchnittstellendaten.aAustransporte.Station[n] <> TransportRichtung_EN.Default )
       AND ( Basis.stMKs.stSchnittstellendaten.aAustransporte.Glastransport[n] = eGlastransport_Default ) )
  THEN
    CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'aAustransporte.Glastransport darf bei konfiguriertem Partner nicht Default sein');
    SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
    NullRef := TRUE;
  END_IF

END_FOR
END_METHOD