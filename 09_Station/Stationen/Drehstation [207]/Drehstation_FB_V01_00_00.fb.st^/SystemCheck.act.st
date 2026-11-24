(* METADATA
{
	"v3Meta": {
		"objectGuid": "f097c686-4b8c-4f9b-b9f9-8ce3825c4bfb"
	}
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
IF( blBetriebartCheck )THEN

  // Ausnahmesituation


  CASE ( steplCheck ) OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1]  := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen := FALSE;

      (* Hinweis:
         - Sollte es sich z.B. um eine Station handeln die in einen anderen SK transportiert
           kann die <<Freigabe>> [Hardware-] entzogen sein wenn dieser geoeffnet ist.
      *)
      IF ( BasisStationsParameter.stFreigabe.bGlastransport AND BasisStationsParameter.stFreigabe.bGeblaese ) THEN
        steplCheck := STEP_10_E;

      ELSE

        IF ( NOT (  BasisStationsParameter.bCheckMitNachfolger[cWAND_1] OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]) ) THEN

          IF ( Glastransport.bpSensorEinlauf
               OR Glastransport.bpSensorEinlaufVorAb
               OR Glastransport.bpSensorEinlaufVorAb
               OR Glastransport.bpSensorauslauf )
          THEN
            BasisStationsParameter.bStationBelegt[cWAND_1] := TRUE;
            steplCheck := STEP_800_E;
          ELSE
            steplCheck := STEP_800_E;
          END_IF

        ELSE
          BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_KANN_NICHT_DURCHGEFUEHRT_WERDEN;
          steplCheck := STEP_900_E;

        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      IF ( blGeblaeseAktiv ) THEN
        steplCheck := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler )  THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES SYSTEMCHECKS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Zielposition und Transportrichtung der Drehstation vor dem Glastransport bestimmen, da sie die Ablage der Scheibe bestimmen
         - Transferstation aus den Auftragsdaten, 0 => Standard-Transferstation aus der MK
         - Die Transportrichtung kommt aus der Stationszuweisung (Station[x] der Ein- bzw. Austransporte) der Transferstation
         - Die Zielposition kommt vom MMI (bDrehpositionenVomMMI) oder aus der Stationszuweisung (Drehen[x])
      *)
      wlCheckTransferstation := BasisStationsParameter.pAuftrag[cWAND_1].wTransferstationsNr1;
      IF ( wlCheckTransferstation = 0 ) THEN
        wlCheckTransferstation := BasisStationsParameter.stMKs.stStationsOptionen.stDrehstation.wStandardTransferstation;
      END_IF

      blCheckRueckwaertig := FALSE;
      Drehen.epZielPosition := eDrehPositionUndefiniert;

      IF ( wlCheckTransferstation >= cERSTES_SHUTTLE ) AND ( wlCheckTransferstation <= cLETZTE_FREMDANLAGE_EINLAUF ) THEN
        IF ( BasisStationsParameter.stMKs.stSchnittstellendaten.aEintransporte.Station[wlCheckTransferstation] <> TransportRichtung_EN.Default ) THEN
          Drehen.epZielPosition := BasisStationsParameter.stMKs.stSchnittstellendaten.aEintransporte.Drehen[wlCheckTransferstation];
          blCheckRueckwaertig   := ( BasisStationsParameter.stMKs.stSchnittstellendaten.aEintransporte.Station[wlCheckTransferstation] = TransportRichtung_EN.Rueckwaertig );
        ELSIF ( BasisStationsParameter.stMKs.stSchnittstellendaten.aAustransporte.Station[wlCheckTransferstation] <> TransportRichtung_EN.Default ) THEN
          Drehen.epZielPosition := BasisStationsParameter.stMKs.stSchnittstellendaten.aAustransporte.Drehen[wlCheckTransferstation];
          blCheckRueckwaertig   := ( BasisStationsParameter.stMKs.stSchnittstellendaten.aAustransporte.Station[wlCheckTransferstation] = TransportRichtung_EN.Rueckwaertig );
        END_IF
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.stDrehstation.bDrehpositionenVomMMI ) THEN
        Drehen.epZielPosition := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rStationsZielposition);
      END_IF

      (* Hinweis:
         - MK bScheibeNachSystemcheckAufAuslauf: Scheibe bleibt in Transportrichtung vorne (TRUE) oder hinten (FALSE) liegen
         - Physischer Sensor: bei rueckwaertigem Transport vertauschen sich vorne und hinten
      *)
      blNachSystemcheckAufAuslauf := BasisStationsParameter.stMKs.stStationsOptionen.stSystemcheck.bScheibeNachSystemcheckAufAuslauf
                                     XOR blCheckRueckwaertig;

      Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
      Glastransport.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];

      Glastransport.bpRueckwaertigerTransport := BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpCheck                    := TRUE;

      steplCheck := STEP_110_E;

    // SYSTEM CHECK=========================
    STEP_110_E:
      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben + 1;
      END_IF

      IF ( ftlGlastransportCheckMitNachfolger.Q ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben - 1;
      END_IF

      (* Hinweis:
         - SystemCheck der Glastransport wurde beendet
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        steplCheck := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpCheck := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_120_E:
      (* Hinweis:
         - Pruefen ob die Station steht wo sie stehen soll
         - Wenn vom MMI -1 kommt (d. h. das MMI hat auf der Station keine Scheiben oder keine Drehpos für die Scheiben) muss das umgewandelt werden!
      *)
      tonlCheckWarteFreigabe( IN := FALSE );

      (* Hinweis:
         - Gueltige Drehpositionen: 90 Grad (Anlegewand 208), 0 / 180 Grad (Kipptisch 206 / Shuttle 101)
         - Kippen aus Drehposition und Letzter Scheibe (MK: Parameter_Drehen.astKippenJeDrehposition), leere Station wie ohne Letzte Scheibe
         - Gedreht / gekippt wird nur, wenn die Ist-Position von der Soll-Position abweicht
      *)
      CASE Drehen.epZielPosition OF

        eDrehPosition0Grad, eDrehPosition90Grad, eDrehPosition180Grad:
          Kippen.epZielPosition  := SEL( (     BasisStationsParameter.bStationBelegt[cWAND_1]
                                           AND BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe ),
                                         Drehen.ppParameterBaustein.astKippenJeDrehposition[ LIMIT( 0, TO_INT(Drehen.epZielPosition) / 90, 3 ) ].eKippenOhneLetzteScheibe,
                                         Drehen.ppParameterBaustein.astKippenJeDrehposition[ LIMIT( 0, TO_INT(Drehen.epZielPosition) / 90, 3 ) ].eKippenMitLetzterScheibe );
          Kippen.bpPositionieren := ( Kippen.epKippStatus <> Kippen.epZielPosition ); // nur kippen, wenn Ist <> Soll

          Drehen.bpStarteAbsolutPositionierung := ( Drehen.epDrehPositionsStatus <> Drehen.epZielPosition ); // nur drehen, wenn Ist <> Soll

          steplCheck := STEP_130_E;

        ELSE

          BasisStationsParameter.awFehlerInformationen[1] := Drehen.epZielPosition;
          BasisStationsParameter.wFehlerNummer := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_DREHPOSITION;
          steplCheck := STEP_900_E;

      END_CASE

    // SYSTEM CHECK =========================
    STEP_130_E:
      (* Hinweis:
         - Drehung abgeschlossen [Drehen von 0- 180 Grad ; 180 - 0 Grad ]
      *)
      IF ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        tonlCheckWarteFreigabe( IN := FALSE );
        steplCheck := STEP_210_E;
      END_IF

      (* Fehlerbehandlung:
         - Drehen muss drehen, hat aber keine Freigabe (z.B. Teilabschaltung durch offenen SK)
           => nicht endlos warten, nach der Wartezeit Systemcheck mit Meldung abbrechen
      *)
      tonlCheckWarteFreigabe( IN := Drehen.bpStarteAbsolutPositionierung AND NOT BasisStationsParameter.stFreigabe.bDrehen,
                              PT := T#10S );
      IF ( tonlCheckWarteFreigabe.Q ) THEN
        tonlCheckWarteFreigabe( IN := FALSE );
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        Kippen.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_KANN_NICHT_DURCHGEFUEHRT_WERDEN;
        steplCheck := STEP_900_E;
      END_IF

      (* Fehlerbehandlung:
         - Drehen
      *)
      IF ( Drehen.bpFehler ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        BasisStationsParameter.awFehlerInformationen[1] := Drehen.wpFehlerKennung;
        BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_210_E:
      (* Fehlerbehandlung:
         - Kippen muss kippen, hat aber keine Freigabe (z.B. Teilabschaltung durch offenen SK)
           => nicht endlos warten, nach der Wartezeit Systemcheck mit Meldung abbrechen
      *)
      tonlCheckWarteFreigabe( IN := Kippen.bpPositionieren AND NOT BasisStationsParameter.stFreigabe.bKippen,
                              PT := T#10S );
      IF ( tonlCheckWarteFreigabe.Q ) THEN
        tonlCheckWarteFreigabe( IN := FALSE );
        Kippen.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_KIPPEN_KEINE_FREIGABE;
        steplCheck := STEP_900_E;
      END_IF

      IF ( steplCheck = STEP_210_E ) AND ( Kippen.bpDone OR NOT Kippen.bpPositionieren ) THEN
        tonlCheckWarteFreigabe( IN := FALSE );
        Kippen.bpPositionieren := FALSE;

        steplCheck := STEP_800_E;
      END_IF

      // Ausnahmesituation
      //   - Komponenten
      IF ( Kippen.bpFehler) THEN
        Kippen.bpPositionieren  := FALSE;

        BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;

        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  AUSWERTEN DES BELADUNGSSTATUS MIT DEN MMI DATEN
      //
      //  Hinweis:
      // - Nachricht an den Bediener senden wenn die Daten nicht passen
      // ---------------------------------------------------------------------------------------

      steplCheck := STEP_1000_E;

      IF ( ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 ) AND BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );

        IF NOT StationHatShuttleNachbar( BasisStationsParameter ) THEN
          BasisStationsParameter.wFehlerNummer         := cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN;
          BasisStationsParameter.awFehlerInformationen := wpgFehlerdaten;
          steplCheck                                   := STEP_900_E;
        END_IF
      END_IF

      IF ( ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben <> 0 ) AND NOT BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );

        IF NOT StationHatShuttleNachbar( BasisStationsParameter ) THEN
          BasisStationsParameter.wFehlerNummer         := cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN;
          BasisStationsParameter.awFehlerInformationen := wpgFehlerdaten;
          steplCheck                                   := STEP_900_E;
        END_IF
      END_IF

    // SYSTEM CHECK=========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      blNachSystemcheckMerker := FALSE;

    // SYSTEM CHECK=========================
    STEP_1000_E:
      // Auftrag für erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;
      blNachSystemcheckMerker := TRUE;

  // SYSTEM CHECK=========================
  END_CASE;
ELSE
  IF (steplCheck > STEP_0_E ) THEN
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;

    BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] := FALSE;
    BasisStationsParameter.bCheckMitNachfolger[cWAND_1] := FALSE;

    BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1] := FALSE;

    Drehen.bpStarteAbsolutPositionierung := FALSE;
    Drehen.bpStarteDrehBewegung          := FALSE;

    Kippen.bpPositionieren := FALSE;

    Glastransport.bpCheck := FALSE;

    blNachSystemcheckMerker := FALSE;
    steplCheck := STEP_0_E;
  END_IF
END_IF
END_ACTION