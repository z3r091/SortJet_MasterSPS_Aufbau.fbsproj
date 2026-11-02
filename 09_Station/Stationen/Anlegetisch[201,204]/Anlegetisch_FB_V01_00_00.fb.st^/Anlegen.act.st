(* METADATA
{
  "v3Meta": {
    "objectGuid": "c2a98566-bcfc-4553-95c7-15cc04b86743"
  }
}
*)
ACTION Anlegen
//-------------------------------------------------------------------------------------------------
// AKTION ANLEGEN
//-------------------------------------------------------------------------------------------------

blVSG_Automatik_Eintransport := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bAnlegetischMitEintransportVorgaenger 
                                AND NOT blAnlegenErzwingen 
                                AND BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bAutomatikBetriebAktiv                             // Automatik Betrieb aktiv
                                AND NOT ( BasisStationsParameter.eStatusAuftrag = eAuftragWiederholen )                                           // Messung Fehlerhaft. Scheibe muss angelegt werden
                                AND NOT ( BasisStationsParameter.eStatusAuftrag = eAuftragAktivWiederholen )                                      // Messung Fehlerhaft. Scheibe muss angelegt werden
                                AND NOT Glastransport.bpSensorEinlauf                                                                             // Einlaufsensor belegt
                                AND NOT Glastransport.bpSensorAuslauf                                                                             // Auslaufsensor belegt
                                AND ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe >= BasisStationsParameter.stMKs.stStationsParameter.rMinGlasHoeheAutomatischenEintransport )    // Scheibe zu niedrig
                                AND ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsLaenge >= BasisStationsParameter.stMKs.stStationsParameter.rMinGlasLaengeAutomatischenEintransport ); // Scheibe zu kurz


IF( BasisStationsParameter.bAnlegen
    AND NOT BasisStationsParameter.bEintransport[cWAND_1]
    AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Anschlag.bpFehler ) THEN
    Anschlag.bpStartAusfahren := FALSE;
    Anschlag.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
    steplAnlegen := STEP_900_E;
  END_IF
  
  IF ( Hubrahmen.bpFehler ) THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    Hubrahmen.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplAnlegen := STEP_900_E;
  END_IF

  CASE steplAnlegen OF
    // ANLEGEN ==================================
    STEP_0_E:
      (* Hinweis:
         - Variablen initalisieren
         - Starten des Anlegevorgangs
         - Sicherung des Geblaeses muss in Ordnung sein [Oeffner-Kontakt]
      *)
      blFreigabeGeblaeseStartenSensor := FALSE;

      // Auftrag nach Status neu setzen. Sollte vorher ein VSG Eintransport aktiv gewesen sein, will die Scheibe neu eintransportiert werden 
      IF ( BasisStationsParameter.eStatusAuftrag = eAuftragWiederholen ) THEN
        BasisStationsParameter.eStatusAuftrag := eAuftragAktivWiederholen;
      ELSE
        BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;
      END_IF 

      IF (  NOT in_bSensorKipparmeNichtUnten
           AND NOT in_bSensorKipparmeAnschlaegeOben )

      THEN
        out_bAmpelSignalGruenScheibeAnlegen := FALSE;
        Anschlag.bpStartEinfahren           := FALSE;
        Anschlag.bpStartAusfahren           := FALSE;

        IF blVSG_Automatik_Eintransport THEN // Es müssen bestimmte Bedingungen aktiv sein
          steplAnlegen := STEP_200_E;
        ELSE
          blAnlegenErzwingen:= FALSE;
          steplAnlegen := STEP_10_E;
        END_IF

      END_IF

    // ANLEGEN ==============================
    STEP_10_E:
      (* Hinweis:
         - Hubrahmen einfahren sofern er es nicht ist
         - Anschlag Ausfahren sofern gefordert
         - Höhenkontrolle auf Position fahren
      *)
      Hubrahmen.bpStartEinfahren := NOT ( Hubrahmen.epStatusZylinder = eZylinderEingefahren );
      Anschlag.bpStartAusfahren  := blAnschlagAutomatischFahren;

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen ) THEN
        IF Messachse.Antrieb.rpMaxPosition < ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
          Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
        ELSE
          Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
        END_IF
      ELSE
        Messachse.rpZielPosition := BasisStationsParameter.stMKs.stGlasdaten[cWAND_1].rlMinGlasHoehe;
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplAnlegen := STEP_20_E;

    // ANLEGEN ==============================
    STEP_20_E:
      (* Anmerkung:
         - Korrekte Stati der Zylinder und Achsen abfragen
      *)
      IF ( ( ( Hubrahmen.epStatusZylinder = eZylinderEingefahren ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen )
           AND ( ( Anschlag.epStatusZylinder = eZylinderAusgefahren ) OR NOT blAnschlagAutomatischFahren OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag )
           AND ( ( Messachse.bpDone ) OR NOT BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen ) )
      THEN

        Hubrahmen.bpStartEinfahren       := FALSE;
        Anschlag.bpStartAusfahren        := FALSE;
        Messachse.bpPositionierung := FALSE;

        IF NOT blAnschlagAutomatischFahren THEN
          steplAnlegen := STEP_30_E;
        ELSE

          tlZeitBereitAnzulegen := TIME();

          blMerkerDrosselklappeAuf := TRUE;

          steplAnlegen := STEP_100_E;
        END_IF

      END_IF

    // ANLEGEN ==============================
    STEP_30_E:
      (* Anmerkung:
         - Anschläge ausfahren
      *)
      out_bAmpelSignalGruenScheibeAnlegen  := gbFlashbit05sec;

      // Automatikbetrieb wurde von der VSG beendet, es muss neu ausgewertet werden, ob Angelegt oder Eintransportiert werden muss 
      IF ftlVSGAutomatikBetriebBeendet.Q THEN
        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;    
        out_bAmpelSignalGruenScheibeAnlegen  := FALSE;
        steplAnlegen := STEP_1000_E;
      END_IF

      // Automatikbetrieb wurde von der VSG gestartet
      IF blVSG_Automatik_Eintransport THEN // Es müssen bestimmte Bedingungen aktiv sein
        steplAnlegen := STEP_200_E;
      END_IF

      IF rtlFussleisteStart.Q THEN
        Anschlag.bpStartAusfahren := TRUE;
        out_bAmpelSignalGruenScheibeAnlegen  := FALSE;
        steplAnlegen := STEP_40_E;
      END_IF

      (* Hinweis:
         - Knebelschlater [Glastransport zurueck / Hubpalette heben]
      *)
      IF ( in_bKnebelRiemenZurueck ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := TRUE;

      ELSE
        Hubrahmen.bpStartEinfahren := TRUE;
        Hubrahmen.bpStartAusfahren := FALSE;

      END_IF
      Glastransport.bpAnforderungHandfunktion := TRUE;

      IF (  Hubrahmen.epStatusZylinder = eZylinderAusgefahren ) THEN
        Glastransport.bpScheibeZurueckFahren := in_bKnebelRiemenZurueck;
      ELSE
        Glastransport.bpScheibeZurueckFahren := FALSE;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette senkt / heben nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( Hubrahmen.bpFehler ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := FALSE;

        BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
        BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;

        steplAnlegen := STEP_900_E;
      END_IF


    // ANLEGEN ==============================
    STEP_40_E:
      (* Anmerkung:
         - Anschläge ausfahren
      *)
      IF (    ( Anschlag.bpDone AND ( Anschlag.epStatusZylinder = eZylinderAusgefahren ) )
           OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag )
      THEN

        tlZeitBereitAnzulegen := TIME();

        Anschlag.bpStartAusfahren := FALSE;

        blMerkerDrosselklappeAuf        := TRUE;
        out_bAmpelSignalGruenScheibeAnlegen := TRUE;

        blFreigabeGeblaeseStartenSensor := TRUE;

        steplAnlegen := STEP_100_E;

      END_IF

    // ANLEGEN ==============================
    STEP_100_E:
      (* Anmerkung:
         - Warten bis der Bediener die Scheibe angelegt und quittierthat
         - Geblaese starten wenn dieses nicht schon gestartet ist
           => Belegen des Einlaufsensors
      *)
      IF ( Glastransport.bpSensorEinlauf 
           AND NOT Glastransport.bpSensorAuslauf ) 
         OR ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell ) 
      THEN
        out_bAmpelSignalGruenScheibeAnlegen  := TRUE;
      ELSE
        out_bAmpelSignalGruenScheibeAnlegen  := gbFlashbit05sec;
      END_IF

      blFreigabeGeblaeseStartenSensor := TRUE;

      // Automatikbetrieb wurde von der VSG beendet, es muss neu ausgewertet werden, ob Angelegt oder Eintransportiert werden muss 
      IF ftlVSGAutomatikBetriebBeendet.Q THEN
        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;       
        out_bAmpelSignalGruenScheibeAnlegen  := FALSE;
        steplAnlegen := STEP_1000_E;
      END_IF

      // Automatikbetrieb wurde von der VSG gestartet
      IF blVSG_Automatik_Eintransport THEN // Es müssen bestimmte Bedingungen aktiv sein
        steplAnlegen := STEP_200_E;
      END_IF
      // Scheibe wurde angelegt
      IF ( rtlFussleisteStart.Q 
           AND ( ( Glastransport.bpSensorEinlauf 
                   AND NOT Glastransport.bpSensorAuslauf ) 
                 OR ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell ) ) ) 
      THEN

        out_bAmpelSignalGruenScheibeAnlegen := FALSE;

        blFreigabeGeblaeseStartenSensor := FALSE;

        BasisStationsParameter.dwWartezeit[cWAND_1] := TIME_TO_DWORD(TIME()- tlZeitBereitAnzulegen);

        blMerkerDrosselklappeAuf := FALSE;

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        // Wenn Modellscheibe -> Anschläge einfahren
        IF ( BasisStationsParameter.wGlastyp[cWAND_1] = cMODELLSCHEIBE ) THEN
          Anschlag.bpStartEinfahren  := TRUE;
          Anschlag.bpStartAusfahren  := FALSE;
          steplAnlegen := STEP_300_E;
        ELSE
          steplAnlegen := STEP_1000_E;
        END_IF

      END_IF

      (* Hinweis:
         - Der Auslauf- Sensor am Anlegetisch muss frei sein, um mit dem Einschleusen des Glases zu beginnen
      *)
      IF (  Glastransport.bpSensorAuslauf
           AND rtlFussleisteStart.Q ) AND ( BasisStationsParameter.wGlastyp[cWAND_1] <> eScheibe_Modell )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SENSOR_AUSLAUF_BELEGT,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );
      END_IF

      (* Hinweis:
         - Der Einlaufsensor am Anlegetisch muss belegt sein
      *)
      IF ( NOT Glastransport.bpSensorEinlauf
           AND rtlFussleisteStart.Q ) AND ( BasisStationsParameter.wGlastyp[cWAND_1] <> eScheibe_Modell )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SENSOR_EINLAUF_NICHT_BELEGT,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );
      END_IF

      (* Hinweis:
         - Knebelschlater [Glastransport zurueck / Hubpalette heben]
      *)
      IF ( in_bKnebelRiemenZurueck ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := TRUE;

      ELSIF NOT Hubrahmen.epStatusZylinder = eZylinderEingefahren THEN
        Hubrahmen.bpStartEinfahren := TRUE;
        Hubrahmen.bpStartAusfahren := FALSE;

      ELSE
        Hubrahmen.bpStartEinfahren := FALSE;
      END_IF
      Glastransport.bpAnforderungHandfunktion := TRUE;

      IF (  Hubrahmen.epStatusZylinder = eZylinderAusgefahren ) THEN
        Glastransport.bpScheibeZurueckFahren := in_bKnebelRiemenZurueck;
      ELSE
        Glastransport.bpScheibeZurueckFahren := FALSE;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette senkt / heben nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( Hubrahmen.bpFehler ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := FALSE;

        BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
        BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;

        steplAnlegen := STEP_900_E;
      END_IF

    // ANLEGEN ==================================
    STEP_200_E:
      (* Anmerkung:
         - Glastransport Ausfahren
         - Anschläge einfahren
         - Hoehenkontrolle auf Min Pos positionieren
      *)
      Hubrahmen.bpStartAusfahren := TRUE;
      Anschlag.bpStartEinfahren  := TRUE;

      (* Anmerkung:
         - Drosselklappe öffnen, damit auch sehr schweres Glas transportiert werden kann, indem die Luft das Glas leicht anhebt
      *)
      blMerkerDrosselklappeAuf := TRUE;

      IF BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen THEN
        IF ( Messachse.Antrieb.rpMaxPosition  < BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe ) THEN
          Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
        ELSE
          Messachse.rpZielPosition := BasisStationsParameter.stMKs.stGlasdaten[cWAND_1].rlMinGlasHoehe;
        END_IF
      ELSE
        Messachse.rpZielPosition := BasisStationsParameter.stMKs.stGlasdaten[cWAND_1].rlMinGlasHoehe;
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplAnlegen := STEP_210_E;

    // ANLEGEN ==================================
    STEP_210_E:
      (* Anmerkung:
         - Glastransport Ausfahren
         - Anschläge einfahren
         - Messachse.positionieren
      *)
      IF ( Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen )
         AND Messachse.bpDone
         AND ( Anschlag.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag )
      THEN
        Anschlag.bpStartEinfahren  := FALSE;
        Hubrahmen.bpStartAusfahren := FALSE;
        Messachse.bpPositionierung := FALSE;

        steplAnlegen := STEP_220_E;
      END_IF

    // ANLEGEN ==================================
    STEP_220_E:
      // Glastransport Eintransport starten
      Glastransport.eGlastyp := BasisStationsParameter.wGlastyp[cWAND_1];
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpEintransport := TRUE;

      steplAnlegen := STEP_230_E;

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF Glastransport.bpFehler THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAnlegen := STEP_900_E;
      END_IF

    // ANLEGEN ==================================
    STEP_230_E:

      out_bAmpelSignalGruenScheibeAnlegen  := TRUE;

      // Scheibe wird nicht Eintransportiert sondern soll angelegt werden 
      IF rtlFussleisteStart.Q THEN
        Glastransport.bpEintransport := FALSE;
        steplAnlegen := STEP_10_E;
      END_IF

      // Auf den Glastransport warten
      IF Glastransport.bpDone THEN

        out_bAmpelSignalGruenScheibeAnlegen  := FALSE;

        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;
        steplAnlegen := STEP_1010_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF Glastransport.bpFehler THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAnlegen := STEP_900_E;
      END_IF

    // ANLEGEN ==================================
    STEP_300_E:      
      (* Anmerkung:
         - Anschlaege gesenkt
      *)
      IF (  Anschlag.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag )  THEN
        Anschlag.bpStartEinfahren  := FALSE;

        steplAnlegen := STEP_1000_E;
      END_IF

    // ANLEGEN ==================================
    STEP_900_E:
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      BasisStationsParameter.bFehler := TRUE;
      Glastransport.bpAnforderungHandfunktion := FALSE;

    // ANLEGEN ==================================
    STEP_1000_E:
      epTypeHoehenmessung := Modus_Positionieren_Auf_Oberkante_2_Sensoren;

      BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;
      Glastransport. bpAnforderungHandfunktion := FALSE;

    // ANLEGEN ==================================
    STEP_1010_E:
      // Scheibe wurde von der VSG Eintransportiert und muss vermessen werden
      epTypeHoehenmessung := Modus_Vermessen_OberUndUnterkante_2_Sensoren;

      BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;
      Glastransport.bpAnforderungHandfunktion := FALSE;

  // ANLEGEN ==================================
  END_CASE
ELSE

  IF( steplAnlegen > STEP_0_E )THEN

    BasisStationsParameter.bAnlegenAbgeschlossen := FALSE;
    out_bAmpelSignalGruenScheibeAnlegen := FALSE;
    out_bAmpelSignalRot                 := FALSE;
    blFreigabeGeblaeseStartenSensor     := FALSE;

    Glastransport.bpAnforderungHandfunktion := FALSE;

    Hubrahmen.bpStartEinfahren       := FALSE;
    Messachse.bpPositionierung := FALSE;
    Anschlag.bpStartAusfahren        := FALSE;

    steplAnlegen := STEP_0_E;
  END_IF

END_IF
END_ACTION