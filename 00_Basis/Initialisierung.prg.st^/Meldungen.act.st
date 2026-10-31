(* METADATA
{
  "v3Meta": {
    "objectGuid": "be7255e2-35ee-42ee-b8a2-02ab90da329a"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION: MELDUNGEN *)
(***************************************************************************************************)

// WatchIO Meldungen
WatchIo(bpInitialisierung AND (steplInitialisierung > STEP_0_E) AND (steplInitialisierung < STEP_900_E), ioccInitAktiv);
WatchIo(bpInitialisierung AND NOT NotHalt.bpNotHaltOK, ioccInitBlockNotAus);

// Alle Druckluftabfragen abfragen und Meldung abgeben
blDruckluftOK := TRUE;
FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  IF NOT StatusAnlage.abpDruckluftOK[wlIndex] THEN
    blDruckluftOK := FALSE;
  END_IF
END_FOR
WatchIo(bpInitialisierung AND NOT blDruckluftOK, ioccInitBlockDruckluft);

// Alle SK's abfragen und Meldung abgeben
// Init darf nur blocken, wenn:
//   - ein SK offen ist
//   - UND es mindestens eine Station gibt, die diesen SK nutzt
//   - UND diese Station NICHT referenziert ist
blAlleSkGeschlossen := TRUE; 

IF NOT M_Init_Ok THEN
FOR wlIndex := cERSTER_SICHERHEITSKREIS  TO cLETZTER_SICHERHEITSKREIS DO
  
  IF NOT Sicherheitskreis[wlIndex].bpSicherheitskreisGeschlossen THEN
  
      // SK ist offen -> nur relevant, falls eine NICHT referenzierte Station diesen SK braucht
      FOR wlSubIndex := cERSTE_STATION TO cLETZTE_STATION DO
        IF StationInSicherheitskreis(starrStationBasisParameter[wlSubIndex].stMKs.eaSicherheitskreis, wlIndex) THEN
          IF NOT starrStationBasisParameter[wlSubIndex].bIstReferenziert THEN
            blAlleSkGeschlossen := FALSE;
            EXIT;
          END_IF
        END_IF
      END_FOR
      FOR wlSubIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
        IF StationInSicherheitskreis(starrShuttleBasisParameter[wlSubIndex].stMKs.eaSicherheitskreis, wlIndex) THEN
          IF NOT starrShuttleBasisParameter[wlSubIndex].bIstReferenziert THEN
            blAlleSkGeschlossen := FALSE;
            EXIT;
          END_IF
        END_IF
      END_FOR
      FOR wlSubIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
        IF StationInSicherheitskreis(starrTransferShuttleBasisParameter[wlSubIndex].stMKs.eaSicherheitskreis, wlIndex) THEN
          IF NOT starrTransferShuttleBasisParameter[wlSubIndex].bIstReferenziert THEN
    blAlleSkGeschlossen := FALSE;   
            EXIT;
          END_IF
        END_IF
      END_FOR
  
    END_IF
  
    IF blAlleSkGeschlossen THEN
      EXIT; // SK-Schleife reicht
  END_IF
  
END_FOR
END_IF

WatchIo(bpInitialisierung AND NOT blAlleSkGeschlossen, ioccInitBlockSK);

// Shuttle
blShuttleErreichbar := TRUE;
wlMeldungsnummer := ioccInit101Referenz;
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  IF NOT aShuttle[wlIndex].blShuttleErreichbar 
     AND NOT starrShuttleBasisParameter[wlIndex].stMKs.bDeaktivieren 
  THEN 
    blShuttleErreichbar := FALSE;
  END_IF
  WatchIo((bpInitialisierung AND starrShuttleBasisParameter[wlIndex].bReferenz AND NOT starrShuttleBasisParameter[wlIndex].bIstReferenziert),wlMeldungsnummer);
  wlMeldungsnummer := wlMeldungsnummer + 1;
END_FOR

// Transfershuttle
wlMeldungsnummer := ioccInit151Referenz;
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  WatchIo((bpInitialisierung AND starrTransfershuttleBasisParameter[wlIndex].bReferenz AND NOT starrTransfershuttleBasisParameter[wlIndex].bIstReferenziert),wlMeldungsnummer);
  wlMeldungsnummer := wlMeldungsnummer + 1;
END_FOR

// Stationen
wlMeldungsnummer := ioccInit201Referenz;
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  WatchIo((bpInitialisierung AND starrStationBasisParameter[wlIndex].bReferenz AND NOT starrStationBasisParameter[wlIndex].bIstReferenziert),wlMeldungsnummer);
  wlMeldungsnummer := wlMeldungsnummer + 1;
END_FOR
END_ACTION