(* METADATA
{
	"v3Meta": {
		"objectGuid": "64956d77-da35-4a2e-90f0-c969659e6e9b"
	}
}
*)
FUNCTION getAnzahlSystemcheckZyklen : WORD
VAR_INPUT
END_VAR
VAR
  wIndex : WORD;
	bByte  : BYTE;
	ptNull : REFERENCE TO BYTE := 0;
END_VAR

getAnzahlSystemcheckZyklen := 0;

// Alle Shuttles durchlaufen
FOR wIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  // Null-Pointer wenn kein Zyklus in den MKs zugewiesen wurde
  IF starrShuttleBasisParameter[wIndex].stMKs.eSystemcheckZyklus = eSystemcheckZyklus_Undefiniert THEN
    SysExceptGenerateException( RtsExceptions.RTSEXCPT_ARRAYBOUNDS );
    //bByte := ptNull; (*cause access violation *)
  ELSE // Ansonsten den definierten Zyklus in das Array übernehmen
    // Neuer höherer Wert? Dann wegspeichern
    IF getAnzahlSystemcheckZyklen < starrShuttleBasisParameter[wIndex].stMKs.eSystemcheckZyklus THEN
      getAnzahlSystemcheckZyklen := starrShuttleBasisParameter[wIndex].stMKs.eSystemcheckZyklus;
    END_IF
  END_IF
END_FOR

// Alle Stationen durchlaufen
FOR wIndex := cERSTE_STATION TO cLETZTE_STATION DO
  // Null-Pointer wenn kein Zyklus in den MKs zugewiesen wurde
  IF NOT __ISVALIDREF(starrStationBasisParameter[wIndex].stMKs) THEN
    CONTINUE;
  ELSIF starrStationBasisParameter[wIndex].stMKs.eSystemcheckZyklus = eSystemcheckZyklus_Undefiniert AND NOT starrStationBasisParameter[wIndex].stMKs.bDeaktivieren THEN
    SysExceptGenerateException( RtsExceptions.RTSEXCPT_ARRAYBOUNDS );
    //bByte := ptNull; (*cause access violation *)
  ELSE // Ansonsten den definierten Zyklus in das Array übernehmen
    // Neuer höherer Wert? Dann wegspeichern
    IF getAnzahlSystemcheckZyklen < starrStationBasisParameter[wIndex].stMKs.eSystemcheckZyklus THEN
      getAnzahlSystemcheckZyklen := starrStationBasisParameter[wIndex].stMKs.eSystemcheckZyklus;
    END_IF
  END_IF
END_FOR

// Null-Pointer wenn kein Ergebnis gefunden wurde (fehlerhafter Zustand)
IF ( getAnzahlSystemcheckZyklen = 0 ) THEN
  SysExceptGenerateException( RtsExceptions.RTSEXCPT_ARRAYBOUNDS );
  //bByte := ptNull; (*cause access violation *)
END_IF
END_FUNCTION