(* METADATA
{
  "v3Meta": {
    "objectGuid": "edf7705f-c0ef-41fa-b3e2-cf58cf9abf17"
  }
}
*)
ACTION Einschleusen
// EINSCHLEUSEN

(* Hinweis:
   - Fächerwageneintransport
     => Anforderung Einschleusen -> Taste blinkt grün, kontrollieren -> wenn Ok, Taste grün an
     => Wagen einschleusen und mit Taster betätigen
     => Lichtschranke wird mit Muting Hardwaremässig überbrückt
     => Wagen anheben, Anschlagleiste hoch
     => Wagen reinziehen
     => Zentrierung OK?
     => Taste grün aus, alles OK
     => Baustein-Ausgangsvariable: blOUTBereitfuerEintransport setzen
*)

rtlQuittierungEinschleusen( CLK := in_bStartSchleusen );

// Optimierung: Lineareinheit faehrt schon zum FW vor, waehrend das Rolltor hochfaehrt (Sensor unten frei).
// Reinziehen (STEP_140) erst, wenn Rolltor oben meldet.
blLinVorBeiRolltorFahrt :=     BasisStationsParameter.bEintransport[1]
                           AND ( steplEinschleusen >= STEP_125_E )
                           AND ( steplEinschleusen <= STEP_140_E )
                           AND blRolltorAuf
                           AND NOT bpRolltorUnten;

IF BasisStationsParameter.bEintransport[1] AND
   ( blBetriebsartAutomatik OR
     blBetriebsartHand OR
     blBetriebartCheck )
THEN

  IF BasisStationsParameter.bFehler THEN
    steplEinschleusen := STEP_900_E;
  END_IF

  CASE steplEinschleusen OF
    // EINSCHLEUSEN ==========================
    STEP_0_E:
      (* Hinweis:
         - Initialisierung der Variablen
      *)
      bpEinschleusenAbgeschlossen := FALSE;
      blLineareinheitVor          := FALSE;
      blLineareinheitZurueck      := FALSE;
      blLineareinheitShuttle      := FALSE;
      blEntriegelungOeffnen       := FALSE;
      blEntriegelungSchliessen    := FALSE;
      blGegenhalterOeffnen        := FALSE;
      blGegenhalterSchliessen     := FALSE;
      blGreiferOeffnen            := FALSE;
      blGreiferSchliessen         := FALSE;
      blRolltorAuf                := FALSE;
      blRolltorAb                 := FALSE;
      blRFID_Auslesen             := FALSE;
      blRFID_DataWasValid         := FALSE;

      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Starten_0;

      IF ( NOT bpStatusStationInBeladePosition ) THEN

        steplEinschleusen := STEP_100_E;

      ELSE
        steplEinschleusen := STEP_180_E;

      END_IF


    // EINSCHLEUSEN ==========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Überprüfen, das ein Wagen zum Andocken bereit steht
      // ---------------------------------------------------------------------------------------

      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Warte_Auf_Faecherwagen_In_Box_100;
      
      IF ( tonlFWInBox.Q ) THEN
        (* Hinweis:
           - Nachricht ans HMI
        *)
        wSps2FaecherwagenStationNr := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        MsgToMmi( auftragsnr_w := SB0_SPS_RACKLOGIN );
        
        steplEinschleusen := STEP_105_E;
      END_IF


    // EINSCHLEUSEN ==========================
    STEP_105_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Nach start des Bedieners  wird der Vorgang gestartet
      // - LS muss quittiert sein und noch immer ein Wagen in der Box stehen
      // - es wird direkt der Gegenhalter unter dem Wagen ausgefahren um sicherzustellen, das der Wagen nicht verrutscht
      // ---------------------------------------------------------------------------------------

      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Warten_Auf_Lichtschranke_Und_Quittierung_105;

      IF  ( rtlQuittierungEinschleusen.Q
            OR  blMerkerEinschleusenQuittiert )
          AND tonlFWInBox.Q
          AND bpLichtschranke_OK
      THEN

        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Gegenhalter_Schliessen_110;

        blMerkerEinschleusenQuittiert := FALSE;
        blGegenhalterSchliessen := TRUE;

        steplEinschleusen := STEP_110_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - sobald der Gegenhalter Ausgefahren wird wird das auslesen des RFID-Chips gestartet
      //
      // ---------------------------------------------------------------------------------------

      IF ( blGegenhalterSchliessenDone )
      THEN
      
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_RFID_Auslesen_Gegenhalter_Schliessen_115;

        blRFID_Auslesen := TRUE;
        blGegenhalterSchliessen := FALSE;
        steplEinschleusen := STEP_115_E;
      ELSE
        blGegenhalterSchliessen := TRUE;
      END_IF


    // EINSCHLEUSEN ==========================
    STEP_115_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - sobald der RFID-Chip ausgelesen wurde, wird das Rolltor geöffnet und die Verriegelung geöffnet
      //
      // ---------------------------------------------------------------------------------------

      tonlTimeoutReadRFID(IN := TRUE, PT := T#5S); // Timer falls der Chip nicht ausgelesen werden kann

      blRFID_Auslesen := TRUE;
        
      IF ( blRFID_DataValid ) THEN
   
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120;

        wlRFID_NummerMerker   := wlRFID_Nummer;//Merken der Ausgelesenen RFID-Nummer um sie später ans MMI zu schicken
        blRFID_DataWasValid   := TRUE;//Merker setzten das der RFID-Sensor ordnungsgemäß ausgelesen wurde
        blRFID_Auslesen       := FALSE;
        blRolltorAuf          := TRUE;
        steplEinschleusen     := STEP_120_E;
    
      ELSIF tonlTimeoutReadRFID.Q AND BasisStationsParameter.stMKs.stStationsAufbau.bRFID THEN

        blRFID_Auslesen := FALSE;
        tonlTimeoutReadRFID(IN := FALSE); // Timer falls der Chip nicht ausgelesen werden kann

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_RFID_CHIP_NICHT_LESBAR;
        SpsError( eFehler_Station,
                  wpFehlernr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_950_E;

      END_IF

    // EINSCHLEUSEN ==========================
    STEP_120_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - wenn das Rolltor und die Verriegelung geöffnet sind müssen die Greiferbacken geöffnet werden
      //
      // ---------------------------------------------------------------------------------------

      // Rolltor bleibt angesteuert bis STEP_140 (oben). Weiter, sobald der Sensor unten frei ist.
      blRolltorAuf := TRUE;

      IF ( blRolltorAufDone OR NOT bpRolltorUnten )
      THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Greifer_Oeffnen_125;

        blGreiferOeffnen      := TRUE;
        steplEinschleusen     := STEP_125_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_125_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Wenn der Greifer offen ist wird die Lineareinheit auf die Greifposition gefahren
      //
      // ---------------------------------------------------------------------------------------

      blRolltorAuf := TRUE; // Rolltor bleibt angesteuert bis STEP_140 (sonst bricht Rolltor() ab und blRolltorAufDone wird nie TRUE)
      IF ( blGreiferOeffnenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Lineareinheit_Vor_130;

        blGreiferOeffnen   := FALSE;
        blLineareinheitVor := TRUE;
        steplEinschleusen  := STEP_130_E;
      ELSE
        blGreiferOeffnen   := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_130_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Wenn die LinearEinheit vorne ist wird der Wagen das erste mal gegriffen
      //
      // ---------------------------------------------------------------------------------------

      blRolltorAuf := TRUE; // Rolltor bleibt angesteuert bis STEP_140
      IF ( blLineareinheitVorDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Greifer_Schliessen_135;

        blLineareinheitVor      := FALSE;
        blGreiferSchliessen     := TRUE;
        steplEinschleusen       := STEP_135_E;
      ELSE
        blLineareinheitVor      := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_135_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - WSobald der Wagen gegriffen wurde kann die Verriegelung geöffnet werden
      //
      // ---------------------------------------------------------------------------------------

      blRolltorAuf := TRUE; // Rolltor bleibt angesteuert bis STEP_140
      IF ( blGreiferSchliessenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Entrieglung_Oeffnen_140;

        blGreiferSchliessen   := FALSE;
        blEntriegelungOeffnen := TRUE;
        steplEinschleusen     := STEP_140_E;
      ELSE
        blGreiferSchliessen   := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_140_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Wenn der Wagen entriegelt wurde wird der Wagen soweit wie möglich auf die Station gezogen, damit umgegriffen werden kann
      //
      // ---------------------------------------------------------------------------------------

      // Reinziehen erst, wenn Rolltor oben meldet (Rolltor bleibt bis dahin angesteuert)
      blRolltorAuf := TRUE;
      IF ( blEntriegelungOeffnenDone ) AND ( blRolltorAufDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Lineareinheit_zurueck_145;

        blRolltorAuf           := FALSE;
        blEntriegelungOeffnen  := FALSE;
        blLineareinheitZurueck := TRUE;
        steplEinschleusen      := STEP_145_E;
      ELSE
        blEntriegelungOeffnen  := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_145_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Sobald die Lineareinheit hinten angekommen ist wird der Greifer geöffnet, damit wir erneut nach vorne fahren können
      //
      // ---------------------------------------------------------------------------------------
      
      IF ( blLineareinheitZurueckDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Greifer_Oeffnen_150;

        blLineareinheitZurueck := FALSE;
        blGreiferOeffnen       := TRUE;
        steplEinschleusen      := STEP_150_E;
      ELSE
        blLineareinheitZurueck := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_150_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Sobald der GReifer geöffnet wurde kann erneut nach vorne gefahren werden, um den Wagen erneut zu greifen
      //
      // ---------------------------------------------------------------------------------------

      IF ( blGreiferOeffnenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Lineareinheit_Vor_155;

        blGreiferOeffnen     := FALSE;
        blLineareinheitVor   := TRUE;
        steplEinschleusen    := STEP_155_E;
      ELSE
        blGreiferOeffnen := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_155_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Lineareinheit ist erneut vorne und der Greifer kann in die hinteren Löcher greifen
      //
      // ---------------------------------------------------------------------------------------

      IF ( blLineareinheitVorDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Greifer_Schliessen_160;

        blLineareinheitVor  := FALSE;
        blGreiferSchliessen := TRUE;
        steplEinschleusen   := STEP_160_E;
      ELSE
        blLineareinheitVor  := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_160_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Greifer sind geschlossen und die Lineareinheit kann zum Shuttle fahren
      //
      // ---------------------------------------------------------------------------------------

      IF ( blGreiferSchliessenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Lineareinheit_Shuttle_165;

        blLineareinheitShuttle := TRUE;
        blGreiferSchliessen    := FALSE;
        steplEinschleusen      := STEP_165_E;
      ELSE
        blGreiferSchliessen    := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_165_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Lineareinheit ist am Shuttle angekommen und das Rolltor kann geschlossen werden
      //
      // ---------------------------------------------------------------------------------------

      IF ( blLineareinheitShuttleDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Rolltor_Ab_170;

        blLineareinheitShuttle := FALSE;
        blRolltorAb            := TRUE;
        steplEinschleusen      := STEP_170_E;
      ELSE
        blLineareinheitShuttle := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_170_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - DEFAULT FAECHERWAGENSTATION
      //
      // Hinweis:
      // - Rolltor wurde geschlossen und der Einschleusevorgang ist abgeschlossen
      // - Nachfolgend Meldung an das MMI
      //
      // ---------------------------------------------------------------------------------------

      IF ( blRolltorAbDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Auswertung_180;

        blRolltorAb            := FALSE;
        steplEinschleusen      := STEP_180_E;
      ELSE
        blRolltorAb            := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_180_E:
      IF ( bpStatusStationInBeladePosition ) THEN

        // Mit RFID Chip
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bRFID ) THEN

          IF ( blRFID_DataWasValid OR BasisStationsParameter.bCheck ) THEN
            wSps2MmiRackPositionNummer:= BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
            wSps2MmiRackPosition := 0;
            wSps2MmiRackNumber   := wlRFID_NummerMerker;
            MsgToMmi(auftragsnr_w := SB0_SPS_RACKONLOADINGSTATION );
    
            eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Abgeschlossen_InBeladeposition;

            steplEinschleusen := STEP_1000_E;

          END_IF

        ELSE // Ohne RFID CHip
          wSps2MmiRackPositionNummer:= BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
          wSps2MmiRackPosition := 0;
          wSps2MmiRackNumber   := 0;
          MsgToMmi(auftragsnr_w := SB0_SPS_RACKONLOADINGSTATION );
    
          eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Abgeschlossen_InBeladeposition;

          steplEinschleusen := STEP_1000_E;

        END_IF
        
      ELSE
        
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_IN_LADEPOSITION;
        SpsError( eFehler_Station,
                  wpFehlernr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;

      END_IF

    // EINSCHLEUSEN ==========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bEintransport[1] := FALSE;

    // EINSCHLEUSEN ==========================
    STEP_950_E:
      // ---------------------------------------------------------------------------------------
      // GEGENHALTER WIEDER ÖFFNEN
      //
      // ---------------------------------------------------------------------------------------

      blGegenhalterOeffnen := TRUE;
      IF blGegenhalterOeffnenDone THEN
      
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_InGrundstellung;
        blGegenhalterOeffnen := FALSE;
        steplEinschleusen := STEP_1000_E;
      END_IF


    // EINSCHLEUSEN ==========================
    STEP_1000_E:
      BasisStationsParameter.bFehler := FALSE;
      wlRFID_NummerMerker   := 0;
      blRFID_DataWasValid   := FALSE;
      bpEinschleusenAbgeschlossen := TRUE;
      BasisStationsParameter.bEintransport[1] := FALSE;

  // EINSCHLEUSEN ==========================
  END_CASE
ELSE

  IF ( steplEinschleusen > STEP_0_E ) THEN
    bpEinschleusenAbgeschlossen   := FALSE;
    blLineareinheitVor            := FALSE;
    blLineareinheitZurueck        := FALSE;
    blLineareinheitShuttle        := FALSE;
    blEntriegelungOeffnen         := FALSE;
    blEntriegelungSchliessen      := FALSE;
    blGegenhalterOeffnen          := FALSE;
    blGegenhalterSchliessen       := FALSE;
    blGreiferOeffnen              := FALSE;
    blGreiferSchliessen           := FALSE;
    blRolltorAuf                  := FALSE;
    blRolltorAb                   := FALSE;
    blMerkerEinschleusenQuittiert := FALSE;
    blRFID_Auslesen               := FALSE;

    WatchIo( FALSE , wlioccFWStationAusrichtPositionNichtOK );
    tonlTimeoutReadRFID(IN := FALSE);
    steplEinschleusen := STEP_0_E;
  END_IF

END_IF
END_ACTION