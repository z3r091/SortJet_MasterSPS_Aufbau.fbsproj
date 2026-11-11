(* METADATA
{
	"v3Meta": {
		"objectGuid": "0e6ffebb-2f8e-4d3e-883f-b07758de8e3e"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Eintransport_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
VAR_INPUT

  // Bausteine
  Kippen          : REFERENCE TO Kippen_FB_V01_00_00;
  Hub             : REFERENCE TO Hub_FB_V01_00_00;
  Roellchenleiste : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;
  Wandverstellung : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;
  Geblaese        : REFERENCE TO Geblaese_Schuetz_FB_V01_00_00;

  (* Hinweis:
     - Nur mit den Ausbaustufen bMessachse und bTransportVerstellung wird die Referenz benutzt,
       ohne diese Ausbaustufe muss die Station sie nicht uebergeben
  *)
  Messachse         : REFERENCE TO Messachse_FB_V01_00_00;
  Dickenverstellung : REFERENCE TO ZylinderPneumatik_3Wege_FB_V01_00_00;

  (* Hinweis:
     - Nur mit der Ausbaustufe bDurchlaufSperreZumNachfolger wird die Referenz benutzt,
       ohne diese Ausbaustufe muss die Station sie nicht uebergeben
  *)
  Abschrankung      : REFERENCE TO ZylinderPneumatik_FB_V01_00_00;

END_VAR
VAR

  // BOOLEAN
  blVortransportGestartet : BOOL; // Vortransport zum Vorab-Sensor laeuft gemeinsam mit den Nachbewegungen
  blMessachseFertig       : BOOL; // Messachse auf Position oder nicht vorhanden
  blDickenverstellungFertig : BOOL; // Dickenverstellung auf Position oder nicht vorhanden
  blMitAbschrankung         : BOOL; // Rueckwaertiger Eintransport vom Nachfolger durch die bewegliche Abschrankung
  blAbschrankungFertig      : BOOL; // Abschrankung in der Endlage oder nicht beteiligt

END_VAR
//-------------------------------------------------------------------------------------------------
// EINTRANSPORT
//-------------------------------------------------------------------------------------------------
blMitAbschrankung := (     BasisStationsParameter.stMKs.stStationsAufbau.bDurchlaufSperreZumNachfolger
                       AND BasisStationsParameter.bRueckwaertsTransportieren[wWand] );

IF ( BasisStationsParameter.bEintransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    bpDrosselklappeOeffnen                   := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Hub.bpFehler ) THEN
    Hub.bpStartHubAb  := FALSE;
    Hub.bpStartHubAuf := FALSE;
    BasisStationsParameter.wFehlerNummer := Hub.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Roellchenleiste.bpFehler ) THEN
    Roellchenleiste.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Roellchenleiste.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartPneumatik := FALSE;
    BasisStationsParameter.wFehlerNummer := Wandverstellung.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( bpGeblaeseFehler ) THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Geblaese.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    steplAktion := STEP_900_E;
  END_IF

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
    IF ( Messachse.bpFehler ) THEN
      Messachse.bpPositionierung := FALSE;
      BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) THEN
    IF ( Dickenverstellung.bpFehler ) THEN
      Dickenverstellung.bpStartPneumatik := FALSE;
      BasisStationsParameter.wFehlerNummer := Dickenverstellung.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  IF ( blMitAbschrankung ) THEN
    IF ( Abschrankung.bpFehler ) THEN
      Abschrankung.bpStartEinfahren := FALSE;
      Abschrankung.bpStartAusfahren := FALSE;
      BasisStationsParameter.wFehlerNummer := Abschrankung.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  CASE steplAktion OF
    // EINTRANSPORT ===============================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      bpFehler := FALSE;
      blVortransportGestartet := FALSE;

      (* Hinweis:
         - Pruefen ob die Querfahrt die Zielposition erreicht hat (ohne Querfahrt immer erreicht)
      *)
      IF ( bpZielPositionErreicht ) THEN
        steplAktion := STEP_10_E;
      END_IF

    // EINTRANSPORT ===============================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Geblase aktiv sind
      *)
      IF ( bpGeblaeseAktiv ) THEN
        bpDrosselklappeOeffnen := TRUE;

        Roellchenleiste.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
        Roellchenleiste.bpStartPneumatik := TRUE;

        Wandverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
        Wandverstellung.bpStartPneumatik := TRUE;

        (* Hinweis:
           - Dickenverstellung nach der Glasdicke aus dem Auftrag (entschieden in der Basis-Schrittkette)
           - Messachse auf die Auftragshoehe fahren
        *)
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) THEN
          Dickenverstellung.epOeffnungsStellung := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
          Dickenverstellung.bpStartPneumatik := TRUE;
        END_IF

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
          Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset;
          Messachse.bpPositionierung := TRUE;
        END_IF

        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;

        (* Hinweis:
           - Hub auf die Sollposition des Auftrags fahren (nur Oben / Unten, sonst keine Bewegung)
        *)
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
          Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Oben );
          Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Unten );
        END_IF

        (* Hinweis:
           - Bewegliche Abschrankung zum Nachfolger oeffnen (einfahren)
        *)
        IF ( blMitAbschrankung ) THEN
          Abschrankung.bpStartAusfahren := FALSE;
          Abschrankung.bpStartEinfahren := TRUE;
        END_IF

        steplAktion := STEP_20_E;
      END_IF

    // EINTRANSPORT ===============================
    STEP_20_E:
      blMessachseFertig         := TRUE;
      blDickenverstellungFertig := TRUE;

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
        blMessachseFertig := Messachse.bpDone;
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) THEN
        blDickenverstellungFertig := Dickenverstellung.bpDone;
      END_IF

      blAbschrankungFertig := TRUE;

      IF ( blMitAbschrankung ) THEN
        blAbschrankungFertig := Abschrankung.bpDone;
      END_IF

      IF ( ( Kippen.bpDone )
           AND blMessachseFertig
           AND blDickenverstellungFertig
           AND blAbschrankungFertig
           AND ( Roellchenleiste.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bRoellchenleiste[wWand] )
           AND ( Wandverstellung.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bWandverstellung[wWand] )
           AND ( Hub.bpDone OR NOT ( Hub.bpStartHubAuf OR Hub.bpStartHubAb ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHub ) )
      THEN
        Roellchenleiste.bpStartPneumatik := FALSE;
        Wandverstellung.bpStartPneumatik := FALSE;
        Kippen.bpPositionieren           := FALSE;
        Hub.bpStartHubAuf                := FALSE;
        Hub.bpStartHubAb                 := FALSE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) THEN
          Dickenverstellung.bpStartPneumatik := FALSE;
        END_IF

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
          Messachse.bpPositionierung := FALSE;
        END_IF

        steplAktion := STEP_100_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORTS
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------
      Glastransport.eGlastyp                   := BasisStationsParameter.wGlasTyp[wWand];
      Glastransport.bpScheibentrennen          := BasisStationsParameter.bScheibentrennen[wWand];
      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpEintransport             := BasisStationsParameter.bEintransport[wWand] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpEintransportRueckwaertig := BasisStationsParameter.bEintransport[wWand] AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_110_E;

    // EINTRANSPORT =====================
    STEP_110_E:
      IF  ( Glastransport.bpFreigabeFremdprozess
            AND BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe )
      THEN
        (* Hinweis:
           - Richtung ist Invertiert zur Eintransport- Position
        *)
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
        Kippen.bpLangsamKippen := (     ( Kippen.epZielPosition = eKippen_Position_90Grad )
                                    AND ( BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke < 3 )
                                    AND ( BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe > 1200 ) );
        Kippen.bpPositionieren := TRUE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
          Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachEintransport = eHub_Oben );
          Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachEintransport = eHub_Unten );
        END_IF
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport             := FALSE;
        Glastransport.bpEintransportRueckwaertig := FALSE;
        bpDrosselklappeOeffnen                   := FALSE;

        (* Hinweis:
           - Bewegliche Abschrankung zum Nachfolger schliessen (ausfahren)
        *)
        IF ( blMitAbschrankung ) THEN
          Abschrankung.bpStartEinfahren := FALSE;
          Abschrankung.bpStartAusfahren := TRUE;
        END_IF

        steplAktion := STEP_150_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_150_E:
      (* Hinweis:
         - Warten bis die bewegliche Abschrankung geschlossen ist (ohne Abschrankung sofort weiter)
      *)
      blAbschrankungFertig := TRUE;

      IF ( blMitAbschrankung ) THEN
        blAbschrankungFertig := Abschrankung.bpDone;
      END_IF

      IF ( blAbschrankungFertig ) THEN
        IF ( blMitAbschrankung ) THEN
          Abschrankung.bpStartAusfahren := FALSE;
        END_IF

        IF ( BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe) THEN
          steplAktion := STEP_200_E;
        ELSE
          steplAktion := STEP_1000_E;
        END_IF
      END_IF

    // EINTRANSPORT =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONAL - KOMPONENTEN STEUERUNG
      //
      //  Hinweis:
      //  - Ausrichtung der Station fuer den Austransport
      //  - Der Vortransport zum Vorab-Sensor laeuft gleichzeitig mit den Nachbewegungen
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Richtung ist Invertiert zur Eintransport- Position
      *)
      Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport;
      Kippen.bpLangsamKippen := (     ( Kippen.epZielPosition = eKippen_Position_90Grad )
                                  AND ( BasisStationsParameter.pAuftrag[wWand].rAuftragsDicke < 3 )
                                  AND ( BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe > 1200 ) );
      Kippen.bpPositionieren := TRUE;

      (* Hinweis:
         - Hub auf die Sollposition nach dem Eintransport fahren (nur Oben / Unten, sonst keine Bewegung)
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
        Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachEintransport = eHub_Oben );
        Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachEintransport = eHub_Unten );
      END_IF

      (* Hinweis:
         - Auslauf-Vorab (rueckwaerts Einlauf-Vorab): nach dem Sammeln positioniert der Vortransport die Scheibe auf den Vorab-Sensor
      *)
      blVortransportGestartet := (     (     NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand]
                                         AND ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGlastransport = eGlastransport_AufAuslaufVorab ) )
                                   OR  (     BasisStationsParameter.bRueckwaertsTransportieren[wWand]
                                         AND ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGlastransport = eGlastransport_AufEinlaufVorab ) ) );
      Glastransport.bpVortransport             := blVortransportGestartet AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpVortransportRueckwaertig := blVortransportGestartet AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_210_E;

    // EINTRANSPORT =====================
    STEP_210_E:
      (* Hinweis:
         - Warten bis die Nachbewegungen und der Vortransport fertig sind
      *)
      IF ( ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
           AND ( Hub.bpDone OR NOT ( Hub.bpStartHubAuf OR Hub.bpStartHubAb ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHub )
           AND ( Glastransport.bpDone OR NOT blVortransportGestartet ) )
      THEN
        Kippen.bpPositionieren                   := FALSE;
        Kippen.bpLangsamKippen                   := FALSE;
        Hub.bpStartHubAuf                        := FALSE;
        Hub.bpStartHubAb                         := FALSE;
        Glastransport.bpVortransport             := FALSE;
        Glastransport.bpVortransportRueckwaertig := FALSE;
        blVortransportGestartet                  := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := TRUE;

  // EINTRANSPORT =====================
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    bpDrosselklappeOeffnen := FALSE;
    BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;

    Roellchenleiste.bpStartPneumatik         := FALSE;
    Wandverstellung.bpStartPneumatik         := FALSE;
    Kippen.bpPositionieren                   := FALSE;
    Kippen.bpLangsamKippen                   := FALSE;
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    Hub.bpStartHubAb                         := FALSE;
    Hub.bpStartHubAuf                        := FALSE;
    blVortransportGestartet                  := FALSE;

    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wWand] ) THEN
      Dickenverstellung.bpStartPneumatik := FALSE;
    END_IF

    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
      Messachse.bpPositionierung := FALSE;
    END_IF

    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bDurchlaufSperreZumNachfolger ) THEN
      Abschrankung.bpStartEinfahren := FALSE;
      Abschrankung.bpStartAusfahren := FALSE;
    END_IF

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK