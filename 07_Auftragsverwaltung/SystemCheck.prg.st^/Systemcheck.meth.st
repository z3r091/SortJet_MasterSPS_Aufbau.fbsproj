(* METADATA
{
  "v3Meta": {
    "objectGuid": "db7a5787-dcad-4426-bbf6-73751d4de64b"
  }
}
*)
METHOD PRIVATE Systemcheck : BOOL
VAR_INPUT
  wpAutomatikkreis : WORD;
  wpZyklus         : WORD;
END_VAR

VAR

  blSystemcheckdatenErhalten : BOOL;

  wlIndex          : WORD;
  wlSubIndex       : WORD;
  wlIndexStationen : WORD;

END_VAR

//-------------------------------------------------------------------------------------------------
// SYSTEMCHECK - AUTOMATIKKREIS X
//-------------------------------------------------------------------------------------------------

IF ablCheck[wpAutomatikkreis, wpZyklus] THEN

  CASE asteplCheck[wpAutomatikkreis, wpZyklus] OF

    // SYSTEMCHECK ==================================
    STEP_0_E:
      (* Anmerkung:
         - -
      *)
      atonlWarnungSystemCheckBeginnt[wpAutomatikkreis](IN:= FALSE);
      atonlCheck[wpAutomatikkreis](IN := FALSE);

      IF ( NOT agbResetAktiv[wpAutomatikkreis] )THEN
        ailAnzahlShuttleCheckAktiv[wpAutomatikkreis]      := 0;
        ailAnzahlStationenCheckAktiv[wpAutomatikkreis]    := 0;
        ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis]  := 0;

        ablTimeOutMeldungGenerieren[wpAutomatikkreis] := TRUE;

        // Status zurueck setzen
        FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
          IF    ( StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) )
                AND ( starrStationBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus )
          THEN
            ablStationCheckAktiv[wlIndex] := FALSE;
          END_IF
        END_FOR        

        FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
          IF    ( StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) )
                AND ( starrShuttleBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus )
          THEN
            ablShuttleCheckAktiv[wlIndex] := FALSE;
          END_IF
        END_FOR

        FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
          IF    ( StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) )
                AND ( starrFaecherwagenBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus )
          THEN
            ablFWCheckAktiv[wlIndex] := FALSE;
          END_IF
        END_FOR

        IF NOT TransferShuttleBetriebsstopAktiv(wpAutomatikkreis) THEN
          asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_10_E;
        ELSE
          SpsError( eFehler_Station, 
                    cMELDUNG_SYSTEMCHECK_NICHT_MOEGLICH_TS_BETRIEBSSTOP, 
                    0, 
                    wpAutomatikkreis, 
                    wpgFehlerdaten );
          asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_900_E;
        END_IF
      END_IF

    // SYSTEMCHECK ==================================
    STEP_10_E:
      (* Hinweis:
         - SystemCheck starten sobald;
           => Daten eingetroffen sind
           => Sicherheitskreise / Druckluft / NotAus etc. okay melden
      *)
      IF (  atonlWaitCheck[wpAutomatikkreis].Q  ) THEN
        atonlCheckWarteAufMMIDaten[wpAutomatikkreis]( IN :=  FALSE );
        asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_20_E;
      END_IF

    // SYSTEMCHECK ==================================
    STEP_20_E:
      (* Hinweis:
         - SystemCheck starten sobald;
           => Daten eingetroffen sind
           => Sicherheitskreise / Druckluft / NotAus etc. okay melden
      *)
      blSystemcheckdatenErhalten := TRUE;

      FOR wlIndexStationen := cERSTE_STATION TO cLETZTE_STATION DO
        IF ( starrStationBasisParameter[wlIndexStationen].stMKs.eSystemcheckZyklus = wpZyklus )
           AND ( StationInAutomatikkreis(starrStationBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wpAutomatikkreis) )
           AND ( NOT starrStationBasisParameter[wlIndexStationen].stMKs.bDeaktivieren )
        THEN
          IF NOT abpStationsDatenErhalten[wlIndexStationen, cWAND_1] THEN
            blSystemcheckdatenErhalten := FALSE;
          END_IF
        END_IF
      END_FOR

      FOR wlIndexStationen := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
        IF (starrShuttleBasisParameter[wlIndexStationen].stMKs.eSystemcheckZyklus = wpZyklus )
           AND ( StationInAutomatikkreis(starrShuttleBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wpAutomatikkreis) )
           AND ( NOT starrShuttleBasisParameter[wlIndexStationen].stMKs.bDeaktivieren )
        THEN
          IF NOT abpStationsDatenErhalten[wlIndexStationen, cWAND_1] THEN
            blSystemcheckdatenErhalten := FALSE;
          END_IF
        END_IF
      END_FOR

      IF blSystemcheckdatenErhalten OR bgInbetriebnahmeBit THEN
        atonlCheckWarteAufMMIDaten[wpAutomatikkreis]( IN :=  FALSE );
        asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_30_E;
      END_IF

      (* Hinweis:
         - Nicht alle Daten in der vorgeschriebenen Zeit eingetroffen
      *)
      atonlCheckWarteAufMMIDaten[wpAutomatikkreis]( IN :=  TRUE, PT := T#5S);
      IF atonlCheckWarteAufMMIDaten[wpAutomatikkreis].Q THEN
        atonlCheckWarteAufMMIDaten[wpAutomatikkreis]( IN :=  FALSE );
        SpsError( eFehler_Station, 
                  cMELDUNG_SYSTEMCHECK_AUFTRAGSDATEN_TIMEOUT, 
                  0, 
                  wpAutomatikkreis, 
                  wpgFehlerdaten );

        asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_900_E;
      END_IF

    // SYSTEMCHECK ==================================
    STEP_30_E:
      (* Hinweis:
         - Vor dem Starten des SystemChecks wird ein akustisches Signal ausgegeben [Horn]
           => 3 - 5 Sekunden zur Fluchtmoeglichkeit geben bevor die Anlage gestartet wird [Fals noch jemand im Sicherheitskreis ist]
      *)
      FOR wlSubIndex := 1 TO cANZAHL_HUPEN DO
        Horn_AK[wpAutomatikkreis,wlSubIndex].wpStatusArt      := 1;
        Horn_AK[wpAutomatikkreis,wlSubIndex].tpHornZeit       := T#3S;
        Horn_AK[wpAutomatikkreis,wlSubIndex].bpHornAktivieren := TRUE;
      END_FOR

      atonlWarnungSystemCheckBeginnt[wpAutomatikkreis]( IN := TRUE,
                                                        PT := T#3s );

      IF ( atonlWarnungSystemCheckBeginnt[wpAutomatikkreis].Q ) THEN
        atonlWarnungSystemCheckBeginnt[wpAutomatikkreis](IN:= FALSE);
        asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_40_E;
      END_IF

    // SYSTEMCHECK ==================================
    STEP_40_E:
      (* Hinweis:
         - Verbund- SystemCheck
      *)
      Steuerung_VerbundCheck( wpAutomatikkreis, wpZyklus );

      (* Hinweis:
         - Zuweisen der Systemcheckdaten
      *)
      FOR wlIndexStationen := cERSTE_STATION TO cLETZTE_STATION DO
        IF    starrStationBasisParameter[wlIndexStationen].stMKs.eSystemcheckZyklus = wpZyklus 
              AND StationInAutomatikkreis(starrStationBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wpAutomatikkreis)
        THEN
          starrStationBasisParameter[wlIndexStationen].pAuftrag[cWAND_1] := abgDateStationCheck[wlIndexStationen, cWAND_1];
        END_IF
      END_FOR

      FOR wlIndexStationen := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
        IF    starrShuttleBasisParameter[wlIndexStationen].stMKs.eSystemcheckZyklus = wpZyklus
              AND StationInAutomatikkreis(starrShuttleBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wpAutomatikkreis)
        THEN
          starrShuttleBasisParameter[wlIndexStationen].pAuftrag[cWAND_1] := abgDateStationCheck[wlIndexStationen, cWAND_1];
        END_IF
      END_FOR

      // Auftragsdaten aufbereiten
      Auftraege_Shuttle( wpAutomatikkreis );

      (* Hinweis:
         - Starten des Baustein- SystemChecks
      *)
      // STATION
      FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO

        IF   StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
             AND (   starrStationBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus 
                   OR starrStationBasisParameter[wlIndex].bCheckMitVorgaenger[cWAND_1]
                   OR starrStationBasisParameter[wlIndex].bCheckMitNachfolger[cWAND_1] )
        THEN
          starrStationBasisParameter[wlIndex].bCheck := TRUE;
          ailAnzahlStationenCheckAktiv[wpAutomatikkreis] := ailAnzahlStationenCheckAktiv[wpAutomatikkreis] + 1;
          ablStationCheckAktiv[wlIndex] := TRUE;
        END_IF

      END_FOR

      // SHUTTLE
      FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

        IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND (   starrShuttleBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus 
                 OR starrShuttleBasisParameter[wlIndex].bCheckMitVorgaenger[cWAND_1]
                 OR starrShuttleBasisParameter[wlIndex].bCheckMitNachfolger[cWAND_1] )
        THEN
          starrShuttleBasisParameter[wlIndex].bCheck := TRUE;
          ailAnzahlShuttleCheckAktiv[wpAutomatikkreis] := ailAnzahlShuttleCheckAktiv[wpAutomatikkreis] + 1;
          ablShuttleCheckAktiv[wlIndex] := TRUE;
        END_IF

      END_FOR

      // FW
      FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

        IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND ( starrFaecherwagenBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus  )
        THEN
          starrFaecherwagenBasisParameter[wlIndex].bCheck := TRUE;
          ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis] := ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis] + 1;
          ablFWCheckAktiv[wlIndex] := TRUE;
        END_IF

      END_FOR

      asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_100_E;

    // SYSTEMCHECK ==================================
    STEP_100_E:
      (* Hinweis:
         - Initalisierung des Timers fuer dei SystemCheck Ueberwachung
      *)
      atonlCheck[wpAutomatikkreis](IN := TRUE, PT := tgTimeWarteAufCheckDone );

      (* Hinweis:
         - Warten bis die Stationen [Einlaufstrecke] ihren SystemCheck beendet haben
      *)
      // SHUTTLE
      FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

        IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND (   starrShuttleBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus 
                 OR starrShuttleBasisParameter[wlIndex].bCheckMitVorgaenger[cWAND_1]
                 OR starrShuttleBasisParameter[wlIndex].bCheckMitNachfolger[cWAND_1] )
        THEN

          IF (   starrShuttleBasisParameter[wlIndex].bCheckAbgeschlossen
               AND starrShuttleBasisParameter[wlIndex].bCheck )
          THEN
            starrShuttleBasisParameter[wlIndex].bCheck := FALSE;
            ailAnzahlShuttleCheckAktiv[wpAutomatikkreis] := ailAnzahlShuttleCheckAktiv[wpAutomatikkreis] - 1;
            ablShuttleCheckAktiv[wlIndex] := FALSE;
          END_IF

        END_IF

      END_FOR

      // STATION
      FOR wlIndex :=   cERSTE_STATION TO cLETZTE_STATION DO

        IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND (   starrStationBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus 
                 OR starrStationBasisParameter[wlIndex].bCheckMitVorgaenger[cWAND_1]
                 OR starrStationBasisParameter[wlIndex].bCheckMitNachfolger[cWAND_1] )
        THEN

          IF (   starrStationBasisParameter[wlIndex].bCheckAbgeschlossen
               AND starrStationBasisParameter[wlIndex].bCheck )
          THEN
            starrStationBasisParameter[wlIndex].bCheck := FALSE;
            ailAnzahlStationenCheckAktiv[wpAutomatikkreis] := ailAnzahlStationenCheckAktiv[wpAutomatikkreis] - 1;
            ablStationCheckAktiv[wlIndex] := FALSE;
          END_IF

        END_IF

      END_FOR

      // FW
      FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

        IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND (   starrFaecherwagenBasisParameter[wlIndex].stMKs.eSystemcheckZyklus = wpZyklus  )
        THEN

          IF (   starrFaecherwagenBasisParameter[wlIndex].bCheckAbgeschlossen
               AND starrFaecherwagenBasisParameter[wlIndex].bCheck )
          THEN
            starrFaecherwagenBasisParameter[wlIndex].bCheck := FALSE;
            ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis] := ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis] - 1;
            ablFWCheckAktiv[wlIndex] := FALSE;
          END_IF

        END_IF

      END_FOR

      IF (  ailAnzahlShuttleCheckAktiv[wpAutomatikkreis]         = 0
           AND ailAnzahlStationenCheckAktiv[wpAutomatikkreis]       = 0
           AND ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis]     = 0 )
      THEN
        asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_1000_E;

      END_IF

      // zeitliche Überwachung des Systemchecks !
      IF ( atonlCheck[wpAutomatikkreis].Q ) THEN

        // SHUTTLE
        FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

          IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
             AND starrShuttleBasisParameter[wlIndex].bCheck
          THEN
            starrShuttleBasisParameter[wlIndex].bCheck := FALSE;

            IF ( NOT starrShuttleBasisParameter[wlIndex].bCheckAbgeschlossen ) THEN
              ablTimeOutMeldungGenerieren[wpAutomatikkreis] := FALSE;
              wpgFehlerdaten[0] := wlIndex;
              SpsError( eFehler_Station,  
                        cMELDUNG_SYSTEMCHECK_STATION_BEENDET_DIESEN_NICHT, 
                        wlIndex, 
                        AutomatikkreisBestimmen(wlIndex), 
                        starrShuttleBasisParameter[wlIndex].awFehlerInformationen );
            END_IF

          END_IF

        END_FOR

        // STATION
        FOR wlIndex :=   cERSTE_STATION TO cLETZTE_STATION DO

          IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
             AND starrStationBasisParameter[wlIndex].bCheck
          THEN
            starrStationBasisParameter[wlIndex].bCheck := FALSE;

            IF ( NOT starrStationBasisParameter[wlIndex].bCheckAbgeschlossen ) THEN
              ablTimeOutMeldungGenerieren[wpAutomatikkreis] := FALSE;
              wpgFehlerdaten[0] := wlIndex;
              SpsError( eFehler_Station, 
                        cMELDUNG_SYSTEMCHECK_STATION_BEENDET_DIESEN_NICHT, 
                        wlIndex, AutomatikkreisBestimmen(wlIndex), 
                        starrStationBasisParameter[wlIndex].awFehlerInformationen );
            END_IF

          END_IF

        END_FOR

        // FW
        FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

          IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
             AND starrFaecherwagenBasisParameter[wlIndex].bCheck
          THEN
            starrFaecherwagenBasisParameter[wlIndex].bCheck := FALSE;

            IF ( NOT starrFaecherwagenBasisParameter[wlIndex].bCheckAbgeschlossen ) THEN
              ablTimeOutMeldungGenerieren[wpAutomatikkreis] := FALSE;
              wpgFehlerdaten[0] := wlIndex;
              SpsError( eFehler_Station, 
                        cMELDUNG_SYSTEMCHECK_STATION_BEENDET_DIESEN_NICHT, 
                        wlIndex, AutomatikkreisBestimmen(wlIndex), 
                        starrFaecherwagenBasisParameter[wlIndex].awFehlerInformationen );
            END_IF

          END_IF

        END_FOR

        (* Hinweis:
           - Time Out Fehler generieren wenn sonst kein Fehler generiert wurde
        *)
        IF ( ablTimeOutMeldungGenerieren[wpAutomatikkreis] ) THEN
          wpgFehlerdaten[0] := wpAutomatikkreis;
          SpsHinweis( eFehler_Station,  
                      cMELDUNG_SYSTEMCHECK_TIMEOUT, 
                      0, 
                      AutomatikkreisBestimmen(wpAutomatikkreis), 
                      wpgFehlerdaten );
        END_IF

        asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_900_E;

      END_IF

      // Fehler:
      //   - Bausteinfehler waerend des SystemCheks
      // SHUTTLE
      FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

        IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND starrShuttleBasisParameter[wlIndex].bFehler
           AND starrShuttleBasisParameter[wlIndex].bCheck
        THEN
          starrShuttleBasisParameter[wlIndex].bCheck := FALSE;
          wpgFehlerdaten[0] := starrShuttleBasisParameter[wlIndex].wFehlerNummer;
          SpsError( eFehler_Station, 
                    starrShuttleBasisParameter[wlIndex].wFehlerNummer, 
                    wlIndex, 
                    AutomatikkreisBestimmen(wlIndex), 
                    starrShuttleBasisParameter[wlIndex].awFehlerInformationen );

          asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_900_E;

        END_IF

      END_FOR

      // STATION
      FOR wlIndex :=   cERSTE_STATION TO cLETZTE_STATION DO

        IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
           AND starrStationBasisParameter[wlIndex].bFehler
           AND starrStationBasisParameter[wlIndex].bCheck
        THEN
          starrStationBasisParameter[wlIndex].bCheck := FALSE;
          wpgFehlerdaten[0] := starrStationBasisParameter[wlIndex].wFehlerNummer;
          SpsError( eFehler_Station, 
                    starrStationBasisParameter[wlIndex].wFehlerNummer, 
                    wlIndex, AutomatikkreisBestimmen(wlIndex), 
                    starrStationBasisParameter[wlIndex].awFehlerInformationen );

          asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_900_E;
        END_IF
  
        // FW
        FOR wlIndex :=   cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
  
          IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis)
             AND starrFaecherwagenBasisParameter[wlIndex].bFehler
             AND starrFaecherwagenBasisParameter[wlIndex].bCheck
          THEN
            starrFaecherwagenBasisParameter[wlIndex].bCheck := FALSE;
            wpgFehlerdaten[0] := starrFaecherwagenBasisParameter[wlIndex].wFehlerNummer;
            SpsError( eFehler_Station, 
                      starrFaecherwagenBasisParameter[wlIndex].wFehlerNummer, 
                      wlIndex, AutomatikkreisBestimmen(wlIndex), 
                      starrFaecherwagenBasisParameter[wlIndex].awFehlerInformationen );
                
            asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_900_E;
          END_IF
  
        END_FOR

      END_FOR

    // SYSTEMCHECK ==================================
    STEP_900_E:
      abpFehler[wpAutomatikkreis] := TRUE;
      ablCheck[wpAutomatikkreis, wpZyklus] := FALSE;

    // SYSTEMCHECK ==================================
    STEP_1000_E:
      abpFehler[wpAutomatikkreis] := FALSE;
      ablCheckDone[wpAutomatikkreis, wpZyklus] := TRUE;

  // SYSTEMCHECK ==================================
  END_CASE

ELSIF ( asteplCheck[wpAutomatikkreis, wpZyklus] <> STEP_0_E ) THEN

  ablCheckDone[wpAutomatikkreis, wpZyklus] := FALSE;
      
  // SHUTTLE
  FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) THEN
      starrShuttleBasisParameter[wlIndex].bCheck := FALSE;
    END_IF
  END_FOR

  // STATION
  FOR wlIndex :=   cERSTE_STATION TO cLETZTE_STATION DO
    IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) THEN
      starrStationBasisParameter[wlIndex].bCheck := FALSE;
    END_IF
  END_FOR

  // FW
  FOR wlIndex :=   cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
    IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) THEN
      starrFaecherwagenBasisParameter[wlIndex].bCheck := FALSE;
    END_IF
  END_FOR

  ailAnzahlShuttleCheckAktiv[wpAutomatikkreis]      := 0;
  ailAnzahlStationenCheckAktiv[wpAutomatikkreis]    := 0;
  ailAnzahlFWStationenCheckAktiv[wpAutomatikkreis]  := 0;

  // SHUTTLE
  FOR wlIndex :=   cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) THEN
      starrShuttleBasisParameter[wlIndex].bCheck := FALSE;
      starrShuttleBasisParameter[wlIndex].bCheckMitVorgaenger[cWAND_1] := FALSE;
      starrShuttleBasisParameter[wlIndex].bCheckMitNachfolger[cWAND_1] := FALSE;
    END_IF
  END_FOR

  // STATION
  FOR wlIndex :=   cERSTE_STATION TO cLETZTE_STATION DO
    IF StationInAutomatikkreis(starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) THEN
      starrStationBasisParameter[wlIndex].bCheck := FALSE;
      starrStationBasisParameter[wlIndex].bCheckMitVorgaenger[cWAND_1] := FALSE;
      starrStationBasisParameter[wlIndex].bCheckMitNachfolger[cWAND_1] := FALSE;
    END_IF
  END_FOR

  // FW
  FOR wlIndex :=   cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
    IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wpAutomatikkreis) THEN
      starrFaecherwagenBasisParameter[wlIndex].bCheck := FALSE;
    END_IF
  END_FOR

  atonlCheckWarteAufMMIDaten[wpAutomatikkreis]( IN :=  FALSE );

  asteplCheck[wpAutomatikkreis, wpZyklus] := STEP_0_E;

END_IF
END_METHOD