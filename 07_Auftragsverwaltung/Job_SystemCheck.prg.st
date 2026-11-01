(* METADATA
{
  "v3Meta": {
    "objectGuid": "5553795f-6afb-4bc3-99ad-34d496c885e5"
  }
}
*)
PROGRAM Job_SystemCheck
VAR

  // WORD
  wlIndex   : WORD := 0;

END_VAR
//-------------------------------------------------------------------------------------------------
// AUFTRAEGE: SYSTEMCHECK STATUS STATION
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Informationen ueber die Stationen
     => SystemCheck
*)
IF ( M_SB0_MMI_SYSTEMCHECKSTATION ) THEN
  M_SB0_MMI_SYSTEMCHECKSTATION := FALSE;

  CASE tMmi2SpsInfo.wSystemCheckStationMmiNummer OF
    
    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE: ;

      cERSTES_SHUTTLE..cLETZTES_SHUTTLE,
        cERSTE_STATION..cLETZTE_STATION:

      IF NOT ( PruefungWertImIntervall( wpWert:= tMmi2SpsInfo.wSystemCheckStationSlot, wpIntervallMin := cWAND_1, wpIntervallMax := cANZAHL_WAENDE )  ) THEN
        wpgFehlerdaten[0] := tMmi2SpsInfo.wSystemCheckStationMmiNummer;
        wpgFehlerdaten[1] := tMmi2SpsInfo.wSystemCheckStationSlot;
        SpsHinweis( eFehler_Station, 
                    cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_WAND, 
                    tMmi2SpsInfo.wSystemCheckStationMmiNummer, 
                    AutomatikkreisBestimmen(tMmi2SpsInfo.wSystemCheckStationMmiNummer),
                    wpgFehlerdaten );

      ELSE

        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].stAuftragsInformationen.wAuftragsInformationen := tMmi2SpsInfo.wSystemCheckStationTyp;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].rStationsZielposition                          := tMmi2SpsInfo.rSystemCheckStationSollPosition;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].wAnzahlScheiben                                := tMmi2SpsInfo.wSystemCheckStationScheibenanzahl;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].rAuftragsLaenge                                := tMmi2SpsInfo.rSystemCheckStationScheibenlaenge;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].wTransferstationsNr1                           := tMmi2SpsInfo.wSystemCheckStationZielstation;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].bLetzteScheibe                                 := tMmi2SpsInfo.wSystemCheckStationLetzteScheibe.0;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].wTransferwand                                  := tMmi2SpsInfo.wSystemCheckStationSlot;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].rModellVersatzVorne                            := tMmi2SpsInfo.rSystemCheckModellVersatzVorne;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].rModellVersatzHinten                           := tMmi2SpsInfo.rSystemCheckModellVersatzHinten;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].bModell                                        := tMmi2SpsInfo.wSytstemCheckStationModellaktiv.0;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].wBeschichtung                                  := tMmi2SpsInfo.wSystemCheckStationBeschichtungsSeite;
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].rAuftragsDicke                                 := WORD_TO_REAL(tMmi2SpsInfo.wSystemCheckScheibenDicke);
        abgDateStationCheck[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot].rAuftragsGewicht                               := tMmi2SpsInfo.rSystemcheckGlasGewicht;

        SystemCheck.abpStationsDatenErhalten[tMmi2SpsInfo.wSystemCheckStationMmiNummer, tMmi2SpsInfo.wSystemCheckStationSlot]  := TRUE;

      END_IF

    ELSE
      wpgFehlerdaten[0] := tMmi2SpsInfo.wSystemCheckStationMmiNummer;
      SpsHinweis( eFehler_Station,
                  cMELDUNG_SYSTEMCHECK_AUFTRAGSDATEN_UNGUELTIG,
                  tMmi2SpsInfo.wSystemCheckStationMmiNummer,
                  AutomatikkreisBestimmen(tMmi2SpsInfo.wSystemCheckStationMmiNummer),
                  wpgFehlerdaten );

  END_CASE

END_IF
END_PROGRAM