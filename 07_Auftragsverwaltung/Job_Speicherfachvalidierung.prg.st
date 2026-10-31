(* METADATA
{
  "v3Meta": {
    "objectGuid": "98bc2d31-e6c9-4c6f-a95b-80ba3f2124c6"
  }
}
*)
PROGRAM Job_Speicherfachvalidierung
VAR

  // BOOL
  blTransfershuttleNummerPlausibel       : BOOL := FALSE;
  blTransfershuttleVerbundNichtPlausibel : BOOL := TRUE;

  // WORD
  wlStationsNummer : WORD;

END_VAR
(***************************************************************************************************)
(* BAUSTEIN: VALIDIERUNGSDATEN FUER DAS TRANSFERSHUTTLE *)
(***************************************************************************************************)
(* Hinweis:
    - Gesondertere Pruefung mittels Transfershuttles da der Einlauf- Auslauf- Sensor (oder beide) belegt 
      wurden und dies zu einem Stopp der Anlage gefuehrt hat. Das Fach wird nochmal ueberprüft bevor
      die Anlage wieder in den Automatikmodus versetzt werden kann.
*)
IF ( M_SB0_MMI_TRANSFERSHUTTLECHECK ) THEN
  M_SB0_MMI_TRANSFERSHUTTLECHECK := FALSE;

  blTransfershuttleNummerPlausibel :=  PruefungWertImIntervall ( wpWert:= tMmi2SpsInfo.wTransfershuttle_Nummer1,
                                                                 wpIntervallMin  := cERSTES_TRANSFERSHUTTLE,
                                                                 wpIntervallMax := cLETZTES_TRANSFERSHUTTLE );
                                 
  // Wenn die Station plausibel ist weiter, ansonsten Fehlermeldung ausgeben                                 
  IF ( blTransfershuttleNummerPlausibel ) THEN
    
  // Prüfen ob der Speichervalidierung noch aktiv ist, wenn ja -> Fehlermeldung
    IF ( Job_Shuttle.abpSpeicherfachValidierung[tMmi2SpsInfo.wTransfershuttle_Nummer1] ) THEN 
      wpgFehlerdaten[0] := tMmi2SpsInfo.wTransfershuttle_Nummer1;      
      wpgFehlerdaten[1] := tMmi2SpsInfo.wTransfershuttle_Nummer1;
      SpsHinweis( eFehler_Station, 
                  cMELDUNG_TS_SPEICHERVALIDIERUNG_NOCH_AKTIV,
                  tMmi2SpsInfo.wTransfershuttle_Nummer1, 
                  AutomatikkreisBestimmen(tMmi2SpsInfo.wTransfershuttle_Nummer1),
                  wpgFehlerdaten );
  ELSE
      (* ---------------------------------------------------------------------------------------
      //  PRUEFEN TRANSFERSHUTTLE VERBUND
      //         
      //  Hinweis:
      //  - wTransfershuttle_Nummer2 = 0   => Vortransport mit nur einem Transfershuttle
      //  - wTransfershuttle_Nummer2 <> 0  => Vortransport im Transfershuttle-Verbund
      // ---------------------------------------------------------------------------------------*)
     
      IF ( tMmi2SpsInfo.wTransfershuttle_Nummer2 <> 0 ) THEN
        VailiderenTransfershuttleVerbund ( wTransferstation1 := tMmi2SpsInfo.wTransfershuttle_Nummer1 ,
                                           wTransferstation2 := tMmi2SpsInfo.wTransfershuttle_Nummer2 ,
                                           wTransferstationMaster => tMmi2SpsInfo.wTransfershuttle_Nummer1,
                                           wTransferstationSlave  => tMmi2SpsInfo.wTransfershuttle_Nummer2,
                                           bpFehler               => blTransfershuttleVerbundNichtPlausibel );
      END_IF
     
      wlStationsNummer := tMmi2SpsInfo.wTransfershuttle_Nummer1;
     
      Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].wStationsNr           := tMmi2SpsInfo.wTransfershuttle_Nummer1;
     
      IF ( tMmi2SpsInfo.wTransfershuttle_GlasDicke = 0 ) THEN
        Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].rAuftragsDicke      := 4.0;
      ELSE
        Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].rAuftragsDicke      := 19.0;
      END_IF
     
      Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].rStationsZielposition := tMmi2SpsInfo.rTransfershuttle_SollPosition1;
      Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].wTransferstationsNr1  := 0;
      Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].rTransferposition1    := 0;
     
      IF ( NOT blTransfershuttleVerbundNichtPlausibel ) THEN
        Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].wTransferstationsNr2  := tMmi2SpsInfo.wTransfershuttle_Nummer2;
        Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].rTransferposition2    := tMmi2SpsInfo.rTransfershuttle_SollPosition2;
      ELSE
        Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].rTransferposition2    := 0;
        Job_Shuttle.starrAuftragsdatenSpeicherfachValidierung[wlStationsNummer].wTransferstationsNr2  := 0;
      END_IF
     
      Job_Shuttle.abpSpeicherfachValidierung[wlStationsNummer] := TRUE;
    END_IF   
  
  ELSE
    wpgFehlerdaten[0] := tMmi2SpsInfo.wTransfershuttle_Nummer1;
    wpgFehlerdaten[1] := tMmi2SpsInfo.wTransfershuttle_Nummer1;
    SpsHinweis( eFehler_Station, 
                cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_STATION,
                tMmi2SpsInfo.wTransfershuttle_Nummer1, 
                AutomatikkreisBestimmen(tMmi2SpsInfo.wTransfershuttle_Nummer1),
                wpgFehlerdaten );

  END_IF

END_IF
END_PROGRAM