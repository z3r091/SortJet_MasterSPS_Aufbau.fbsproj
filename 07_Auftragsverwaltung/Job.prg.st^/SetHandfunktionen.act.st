(* METADATA
{
	"v3Meta": {
		"objectGuid": "1bd08ff4-0500-44a4-97b6-86b1335f3cd9"
	}
}
*)
ACTION SetHandfunktionen
//-------------------------------------------------------------------------------------------------
// HANDFUNKTIONEN SETZEN
//-------------------------------------------------------------------------------------------------

// STATIONEN
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  starrStationBasisParameter[wlIndex].dwHandfunktionen := adwgHandfunktionenStationen[wlIndex];
END_FOR

// SHUTTLE
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  starrShuttleBasisParameter[wlIndex].dwHandfunktionen := adwgHandfunktionenShuttle[wlIndex];
END_FOR

// TRANSFERSHUTTLE
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  starrTransfershuttleBasisParameter[wlIndex].dwHandfunktionen := adwgHandfunktionenTransfershuttle[wlIndex];
END_FOR

// FW
FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
  starrFaecherwagenBasisParameter[wlIndex].dwHandfunktionen := adwgHandfunktionenFaecherwagenStationen[wlIndex];
END_FOR


//-------------------------------------------------------------------------------------------------
// HANDFUNKTIONEN ZURUECKSETZEN
//-------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//  Hinweis:
//  -Zuruecksetzen der Handfunktionen
// ---------------------------------------------------------------------------------------

FOR wIndexReset := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF (    M_Automatik_Aktiv[wIndexReset]
       OR NOT NotHalt.bpNotHaltOK )
  THEN

    // STATIONEN
    FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO

      IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wIndexReset) THEN
        adwgHandfunktionenStationen[wlIndex] := 0;
      END_IF

    END_FOR

    // SHUTTLE
    FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

      IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wIndexReset) THEN
        adwgHandfunktionenShuttle[wlIndex] := 0;
      END_IF

    END_FOR

    // TRANSFERSHUTTLE
    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO

      IF StationInAutomatikkreis(starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wIndexReset) THEN
        adwgHandfunktionenTransfershuttle[wlIndex] := 0;
      END_IF

    END_FOR

    // FAECHERWAGEN
    FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR  TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

      IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wIndexReset) THEN
        adwgHandfunktionenFaecherwagenStationen[wlIndex] := 0;
      END_IF

    END_FOR

  END_IF

END_FOR

// ---------------------------------------------------------------------------------------
//  SPEICHER ALLGEMEIN [TRANSFERSHUTTLE]
//
//  Hinweis:
//  -Zuruecksetzen der Handfunktionen
// ---------------------------------------------------------------------------------------

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  IF AutomatikAktiv(wlIndex) OR NOT Nothalt.bpNotHaltOK THEN
    adwgHandfunktionenTransfershuttle[wlIndex] := 0;
  END_IF
END_FOR
END_ACTION