(* METADATA
{
	"v3Meta": {
		"objectGuid": "9404f6fa-2a6f-44db-8f42-3f6f32f76ed1"
	}
}
*)
FUNCTION_BLOCK Shuttle_Ansteuerung_Ressourcen_FB_V01_00_00 EXTENDS Basic_Shuttle_Aktion_FB_V01_00_00
VAR_INPUT

  // GREIFER [Ausbaustufe stStationsAufbau.bGreifer]
  bpGreiferAktiv : BOOL;
  Greifer        : REFERENCE TO Shuttle_Greifer_FB_V01_00_00;

END_VAR
VAR
  tonlTimeout : TON;

  // BOOL
  blMitGreifer : BOOL; // Vorab-Auftrag mit Greiferseite und Greifer vorhanden
  blGlasUeberspringen : BOOL; // Vorab ohne Glasaktion: Eintransport aktiv oder gerade gewesen
END_VAR
//-------------------------------------------------------------------------------------------------
// AKTION ANSTEUERUNG RESOURCEN WAEHREND DER QUERFAHRT
//-------------------------------------------------------------------------------------------------
(* Wichtig:
   - Es handelt isch hier um eine Aktion die waehrend der Shuttlequerfahrt [Verfahrauftrag] abgearbeitet wird.
   - Zu beachten ist das:
     => Wenn der Riemen verfahrern werden soll pruefen ob der autarke Vortransport aktiv ist
     => Aktion laeuft parallel zum Verfahrauftrag der Oberflaeche
*)
IF (  BasisStationsParameter.bVorabKomponentenAnsteuerung[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport              := FALSE;
    Glastransport.bpVortransportRueck         := FALSE;
    Glastransport.bpStarteVorabPositionierung := FALSE;
    Glastransport.bpStarteVorabPositionierungRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartePositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Wandverstellung.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( blMitGreifer AND Greifer.bpFehler ) THEN
    Greifer.bpPositionieren                         := FALSE;
    Greifer.bpStarteVorabPositionierungEintransport := FALSE;
    BasisStationsParameter.awFehlerInformationen    := Greifer.awpFehlerInformationen;
    BasisStationsParameter.wFehlerNummer            := Greifer.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplAktion OF
    // VORAB KOMPONENTEN ANSTEUERUNG ========================
    STEP_0_E:
      BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] := FALSE;
      tonlTimeout( IN := FALSE );

      blMitGreifer :=     bpGreiferAktiv
                      AND ( BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGreiferTyp <> eGreiferDefault );

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.bVorAbKomponentenAnsteuerung ) THEN
        steplAktion := STEP_10_E;
      ELSE
        steplAktion := STEP_1000_E;
      END_IF


    // VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ========================
    STEP_10_E:
      (* Hinweis:
         - Wandverstellung ansteuern
         - Kippen ansteuern
      *)
      Wandverstellung.epSollStellung         := BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eDickenverstellung;
      Wandverstellung.bpStartePositionierung := TRUE;

      IF BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition <> eKippen_Default THEN
        Kippen.epZielPosition := BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;
      END_IF

      steplAktion := STEP_20_E;

    // VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ========================
    STEP_20_E:
      (* Hinweis:
         - Glastransport ansteuern
         - Laeuft der Eintransport noch (bEintransport) oder ist er gerade abgeschlossen (Eintransport gewesen),
           liegt die Scheibe definiert: die Glasaktion der Vorab entfaellt, es wird nicht gewartet
         - Jede weitere Vorab positioniert die Scheibe neu (Sensor erst freifahren, dann neu anfahren)
      *)
      blGlasUeberspringen := BasisStationsParameter.bEintransport[wWand]
                             OR BasisStationsParameter.bEintransportGewesen[wWand];
      BasisStationsParameter.bEintransportGewesen[wWand] := FALSE;

      IF ( NOT blGlasUeberspringen
           AND NOT Glastransport.bpEintransport
           AND NOT Glastransport.bpRueckwaertsEintransportieren )
      THEN

        CASE BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGlastransport OF

          eGlastransport_Default:
            ;

          eGlastransport_AufEinlauf:
            Glastransport.bpStarteVorabPositionierungRueckwaertig := NOT Glastransport.bpAuftragAktiv;

          eGlastransport_AufEinlaufVorab:
            Glastransport.bpVortransportRueck := TRUE;

          eGlastransport_AufAuslauf,
            eGlastransport_AufAuslaufVorab:
            Glastransport.bpStarteVorabPositionierung := NOT Glastransport.bpAuftragAktiv;

        END_CASE

      END_IF

      (* Hinweis:
         - Greifer [Ausbaustufe] waehrend der Querfahrt vorpositionieren
           => Austransport: Greifer hinter die Glaskante stellen
           => Eintransport: Greifer an die Wandseite stellen und ausfahren
         - Entfaellt solange der Eintransport noch aktiv ist
      *)
      IF (     blMitGreifer
           AND NOT Greifer.bpAuftragAktiv
           AND NOT BasisStationsParameter.bEintransport[wWand] )
      THEN
        Greifer.epGreiferTyp := BasisStationsParameter.pVorAbAuftragsdaten[wWand].stAuftragsOptionen.eGreiferTyp;

        IF ( BasisStationsParameter.pVorAbAuftragsdaten[wWand].wAuftragstyp.0 ) THEN
          Greifer.rpGlaslaenge    := BasisStationsParameter.pVorAbAuftragsdaten[wWand].rLaenge;
          Greifer.bpPositionieren := TRUE;
        ELSE
          Greifer.bpStarteVorabPositionierungEintransport := NOT Greifer.bpVorpositioniertEintransport;
        END_IF
      END_IF

      tonlTimeout( IN := FALSE );
      steplAktion := STEP_100_E;

    // VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ========================
    STEP_100_E:
      (* Hinweis:
         - Einsammeln aller ausgelösten Ereignisse auf bpDone
      *)
      // Nach 60s Fehler melden, dass die Komponenten nicht fertig werden
      tonlTimeout(IN := TRUE, PT := T#60S);

      IF (   ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
           AND (( Glastransport.bpVortransport AND Glastransport.bpDone) OR NOT Glastransport.bpVortransport)
           AND (( Glastransport.bpVortransportRueck AND Glastransport.bpDone) OR NOT Glastransport.bpVortransportRueck)
           AND (( Glastransport.bpStarteVorabPositionierung AND Glastransport.bpDone) OR NOT Glastransport.bpStarteVorabPositionierung)
           AND (( Glastransport.bpStarteVorabPositionierungRueckwaertig AND Glastransport.bpDone) OR NOT Glastransport.bpStarteVorabPositionierungRueckwaertig)
           AND (( Wandverstellung.bpStartePositionierung AND Wandverstellung.bpDone) OR NOT Wandverstellung.bpStartePositionierung)
           AND (    NOT blMitGreifer
                 OR (     (( Greifer.bpPositionieren AND Greifer.bpPositionierungAbgeschlossen ) OR NOT Greifer.bpPositionieren )
                      AND (( Greifer.bpStarteVorabPositionierungEintransport AND Greifer.bpVorabPositionierungEintransportAbgeschlossen ) OR NOT Greifer.bpStarteVorabPositionierungEintransport ) ) ) )
      THEN

        Glastransport.bpVortransport                    := FALSE;
        Glastransport.bpVortransportRueck               := FALSE;
        Glastransport.bpStarteVorabPositionierung       := FALSE;
        Glastransport.bpStarteVorabPositionierungRueckwaertig := FALSE;

        Wandverstellung.bpStartePositionierung          := FALSE;
        Kippen.bpPositionieren                          := FALSE;

        IF ( blMitGreifer ) THEN
          Greifer.bpPositionieren                         := FALSE;
          Greifer.bpStarteVorabPositionierungEintransport := FALSE;
        END_IF

        steplAktion := STEP_1000_E;
      END_IF

      IF tonlTimeout.Q THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_VORABKOMPONENTENANSTEUERUN_NOT_DONE;
        steplAktion := STEP_900_E;
      END_IF

    // VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ========================
    STEP_1000_E:

      Glastransport.bpVortransport                    := FALSE;
      Glastransport.bpVortransportRueck               := FALSE;
      Glastransport.bpStarteVorabPositionierung       := FALSE;
      Glastransport.bpStarteVorabPositionierungRueckwaertig := FALSE;

      Wandverstellung.bpStartePositionierung          := FALSE;
      Kippen.bpPositionieren                          := FALSE;

      BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] := TRUE;

  // VORAB KOMPONENTEN ANSTEUERUNG WAND 1 ========================
  END_CASE

END_IF

IF ( NOT BasisStationsParameter.bVorabKomponentenAnsteuerung[wWand] ) THEN

  IF ( steplAktion > STEP_0_E ) THEN

    IF ( NOT BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] ) THEN

      Glastransport.bpVortransport                    := FALSE;
      Glastransport.bpVortransportRueck               := FALSE;
      Glastransport.bpStarteVorabPositionierung       := FALSE;
      Glastransport.bpStarteVorabPositionierungRueckwaertig := FALSE;

      Wandverstellung.bpStartePositionierung          := FALSE;
      Kippen.bpPositionieren                                   := FALSE;
    END_IF

    IF ( blMitGreifer ) THEN
      Greifer.bpPositionieren                         := FALSE;
      Greifer.bpStarteVorabPositionierungEintransport := FALSE;
      blMitGreifer := FALSE;
    END_IF

    BasisStationsParameter.bVorabKomponentenAnsteuerungAbgeschlossen[wWand] := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK