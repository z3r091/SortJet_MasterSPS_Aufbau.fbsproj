(* METADATA
{
  "v3Meta": {
    "objectGuid": "ea05f2f9-b5af-46e3-bd29-192be094b3c3"
  }
}
*)
PROGRAM FachkontrolleTransfershuttle
VAR_INPUT

  // BOOLEAN
  bpReset               : BOOL;
  bpAktiv               : BOOL := FALSE;
  bpStarteFachkontrolle : BOOL;
  bpPositionKorrigieren : BOOL := FALSE; 

  // WORD
  wpStationNumber : WORD := 0;
  wpSpeicherNr    : WORD;
  wpFachNr        : WORD;

  // REAL
  rpPosition : REAL := 0;
  ipGerundetePosition : INT := 0;
END_VAR
VAR

  // ENUM
  steplKontrolle : STEPS_TE;

  // TIMER
  tonlWartezeit    : TON; // EINSCHALTVERZOEGERUNG:
  tonlUeberwachung : TON; // EINSCHALTVERZOEGERUNG:

  // REAL
  rpErmitteltePosition : REAL;

END_VAR
VAR CONSTANT

  // TIME
  tZeitRiemenBewegung : TIME := T#3500ms;
  tZeitUeberwachung   : TIME := T#5s;

END_VAR

//-------------------------------------------------------------------------------------------------
// FACHKONTROLLE MITTELS TRANSFERSHUTTLE
//-------------------------------------------------------------------------------------------------
IF ( bpReset ) THEN
  wpStationNumber := WORD#0;
  rpPosition      := REAL#0;

  steplKontrolle := STEP_0_E;

  tonlWartezeit(IN := FALSE);
  tonlUeberwachung(IN := FALSE);

  bpReset := FALSE;
  bpStarteFachkontrolle := FALSE;

ELSE

  IF ( bpAktiv ) THEN

    (* Hinweis:
       - Starten der Fachkontrolle mittels Transfershuttle
    *)
    IF ( bpStarteFachkontrolle ) THEN

      (* Hinweis:
         - Sicherstellen das auch eine Stationsnummer uebergeben wurde
      *)
      CASE wpStationNumber OF

        cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
          ;

        ELSE
          wpgFehlerdaten[0] := wpStationNumber;
          SpsHinweis( eFehler_Station,
                      cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_STATION,
                      0,
                      AutomatikkreisBestimmen(0), 
                      wpgFehlerdaten);

          RETURN;

      END_CASE

      (* Hinweis:
         - Starten der Fachkontrolle
      *)
      CASE steplKontrolle OF
        // ----------------------------------------------------------
        STEP_0_E:
          IF ( NOT ( M_Automatik_Aktiv[cAUTOMATIKKREIS_1] ) )
          THEN
            tonlUeberwachung( IN := FALSE );
            tonlWartezeit( IN := FALSE );
            rpErmitteltePosition := 0;
            steplKontrolle := STEP_5_E;
          END_IF

        // ----------------------------------------------------------
        STEP_5_E:
          tonlWartezeit(IN := NOT aTransfershuttles[wpStationNumber].Querfahrt.Antrieb.bpReglerBereit 
                         AND NOT aTransfershuttles[wpStationNumber].Querfahrt.Antrieb.bpFreigabe, 
                         PT := T#2S);
          IF tonlWartezeit.Q THEN
            tonlWartezeit(IN := FALSE);
            steplKontrolle := STEP_10_E;
          END_IF

        // ----------------------------------------------------------
        STEP_10_E:
          tonlUeberwachung( IN := TRUE,
                            PT := tZeitUeberwachung  );


          bgVisuTFSRiemenAnheben[wpStationNumber] := TRUE;

          tonlWartezeit(IN := aTransfershuttles[wpStationNumber].in_bSensorShuttleOben, PT := T#1S);
          IF tonlWartezeit.Q THEN
            tonlWartezeit(IN := FALSE);
            steplKontrolle := STEP_20_E;
          END_IF

          // Fehler:
          //   - Riemen nicht angehoben
          IF ( tonlUeberwachung.Q ) THEN
            bpReset := TRUE;
            bgVisuTFSRiemenAnheben[wpStationNumber] := FALSE;

            wpgFehlerdaten[0] := wpStationNumber;
            SpsError( eFehler_Station, 
                      cMELDUNG_TS_MELDET_NICHT_OBEN,
                      wpStationNumber, 
                      AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wpStationNumber].stMKs.stStationsNummern.NummerIntern),
                      wpgFehlerdaten 
                    );
          END_IF


        // ----------------------------------------------------------
        STEP_20_E:
          tonlWartezeit(IN := FALSE);
          bgVISUGlastransportVor[wpStationNumber, cWAND_1] := TRUE;

          steplKontrolle := STEP_30_E;

        // ----------------------------------------------------------
        STEP_30_E:
          tonlWartezeit(IN := TRUE, PT := tZeitRiemenBewegung );

          IF ( tonlWartezeit.Q ) THEN
            bgVISUGlastransportVor[wpStationNumber, cWAND_1] := FALSE;
            steplKontrolle := STEP_40_E;
          END_IF

        // ----------------------------------------------------------
        STEP_40_E:
          tonlWartezeit(IN := FALSE);
          IF ( NOT aTransfershuttles[wpStationNumber].Glastransport.Antrieb.bpAntrieblaeuft ) THEN
            steplKontrolle := STEP_50_E;
          END_IF

        // ----------------------------------------------------------
        STEP_50_E:
          bgVISUGlastransportZurueck[wpStationNumber, cWAND_1] := TRUE;
          steplKontrolle := STEP_60_E;

        // ----------------------------------------------------------
        STEP_60_E:
          tonlWartezeit( IN := TRUE,
                         PT := tZeitRiemenBewegung);

          IF ( tonlWartezeit.Q ) THEN
            bgVISUGlastransportZurueck[wpStationNumber, cWAND_1] := FALSE;
            steplKontrolle := STEP_70_E;
          END_IF

        // ----------------------------------------------------------
        STEP_70_E:
          tonlWartezeit(IN := FALSE);
          IF ( NOT aTransfershuttles[wpStationNumber].Glastransport.Antrieb.bpAntrieblaeuft ) THEN
            steplKontrolle := STEP_80_E;
          END_IF

        // ----------------------------------------------------------
        STEP_80_E:
          (* Hinweis:
             - Position des Antriebs abfragen
          *)
          rpErmitteltePosition := starrTransfershuttleBasisParameter[wpStationNumber].rAktuellePositionQuerfahrt;

          (* Hinweis:
             - Transfershuttle wieder senken
          *)
          bgVisuTFSRiemenAnheben[wpStationNumber] := FALSE;

          steplKontrolle := STEP_90_E;

        // ----------------------------------------------------------
        STEP_90_E:
          IF ( aTransfershuttles[wpStationNumber].in_bSensorShuttleUnten ) THEN
            steplKontrolle := STEP_1000_E;
          END_IF

        // ----------------------------------------------------------
        STEP_1000_E:
          (* Hinweis:
             - Nachricht ans HMI absetzen
          *)
          wgSps2MmiShuttleNr           := wpStationNumber;
          IF bpPositionKorrigieren THEN
            ipGerundetePosition := REAL_TO_INT(rpErmitteltePosition); // Runden damit keine Nachkommastellen zum MMI geschickt werden
            wSps2MmiValidierungsPosition := INT_TO_REAL(ipGerundetePosition); // Die aktuelle Antriebsposition hochmelden, damit diese im MMI korrigiert wird
          ELSE
            wSps2MmiValidierungsPosition := rpPosition; // Die geschickte Position vom MMI zurückmelden, damit nichts geändert wird
          END_IF
          wSps2MmiValidierungsSpeicher := wpSpeicherNr;
          wSps2MmiValidierungsFach := wpFachNr;
          MsgToMmi(auftragsnr_w := SB0_SPS_TRANSFERSHUTTLEBUFFERSLOTPOS );

          IF rpPosition <> rpErmitteltePosition THEN
            wpgFehlerdaten[0] := REAL_TO_WORD(rpPosition); 
            wpgFehlerdaten[1] := REAL_TO_WORD(rpErmitteltePosition);
            wpgFehlerdaten[2] := REAL_TO_WORD(wpSpeicherNr);
            wpgFehlerdaten[3] := REAL_TO_WORD(wpFachNr);
            IF ABS(rpPosition - rpErmitteltePosition) > 2 THEN
              SpsHinweis( eFehler_Station, 
                          999,
                          wpStationNumber, 
                          AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wpStationNumber].stMKs.stStationsNummern.NummerIntern), 
                          wpgFehlerdaten );
            END_IF
          END_IF  
          bpStarteFachkontrolle := FALSE;
      END_CASE

    END_IF

    IF ( NOT bpStarteFachkontrolle ) THEN

      IF ( steplKontrolle > STEP_0_E ) THEN
        IF steplKontrolle <> STEP_1000_E THEN
          bgVISUGlastransportZurueck[wpStationNumber, cWAND_1] := FALSE;
          bgVISUGlastransportVor[wpStationNumber, cWAND_1] := FALSE;
          bgVisuTFSRiemenAnheben[wpStationNumber] := FALSE;
        END_IF

        wpStationNumber      := WORD#0;

        steplKontrolle := STEP_0_E;
      END_IF

    END_IF

  END_IF

END_IF
END_PROGRAM