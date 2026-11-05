(* METADATA
{
  "v3Meta": {
    "objectGuid": "281ccc1c-3965-40cf-8682-0228b96383da"
  }
}
*)
FUNCTION_BLOCK Basic_Station_Austransport_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
VAR_INPUT

  // Bausteine
  Kippen          : REFERENCE TO Kippen_FB_V01_00_00;
  Hub             : REFERENCE TO Hub_FB_V01_00_00;
  Geblaese        : REFERENCE TO Geblaese_Schuetz_FB_V01_00_00;

  (* Hinweis:
     - Nur mit der Ausbaustufe bMessachse wird die Referenz benutzt,
       ohne diese Ausbaustufe muss die Station sie nicht uebergeben
  *)
  Messachse       : REFERENCE TO Messachse_FB_V01_00_00;

END_VAR
VAR

  // BOOLEAN
  blQuelleWandLeer        : BOOL; // Auftrag: die Quellstation ist nach dem Austransport leer
  blVortransportGestartet : BOOL; // Vortransport vor dem Austransport (Option der Station) laeuft gemeinsam mit den Vorbewegungen
  blMessachseFertig       : BOOL; // Messachse auf Position oder nicht vorhanden

END_VAR
//-------------------------------------------------------------------------------------------------
// AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
blQuelleWandLeer := BasisStationsParameter.pAuftrag[wWand].stAuftragsInformationen.cBIT_SRCSTATION_EMPTY;

IF ( BasisStationsParameter.bAustransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    Glastransport.bpReferenz                 := FALSE;
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
    Hub.bpStartHubAuf := FALSE;
    Hub.bpStartHubAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Hub.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( bpGeblaeseFehler ) THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Geblaese.bpFehler )THEN
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

  CASE steplAktion OF
    // AUSTRANSPORT =====================
    STEP_0_E:
      (* Hinweis:
         - Geblaese aktiv und die Querfahrt hat die Zielposition erreicht (ohne Querfahrt immer erreicht)
      *)
      bpFehler := FALSE;
      blVortransportGestartet := FALSE;

      IF ( bpGeblaeseAktiv
           AND bpZielPositionErreicht )
      THEN
        Kippen.bpPositionieren := FALSE;
        bpDrosselklappeOeffnen := TRUE;
        steplAktion := STEP_10_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_10_E:
      (* Hinweis:
         - Ansteuerung Kippen
         - Hub auf die Sollposition des Auftrags fahren (nur Oben / Unten, sonst keine Bewegung)
         - Messachse auf die Auftragshoehe fahren (maximal bis zur Maximalposition)
         - Vortransport (Option der Station): Scheibe vor dem Austransport positionieren,
           laeuft gemeinsam mit den Bewegungen
      *)
      Kippen.epZielPosition  := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
      Kippen.bpPositionieren := TRUE;

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
        Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Oben );
        Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Unten );
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
        IF ( ( BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) >= Messachse.Antrieb.rpMaxPosition ) THEN
          Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
        ELSE
          Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset;
        END_IF
        Messachse.bpPositionierung := TRUE;
      END_IF

      blVortransportGestartet := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bVortransport;
      Glastransport.pAuftrag                   := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpVortransport             := blVortransportGestartet AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpVortransportRueckwaertig := blVortransportGestartet AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_20_E;

    // AUSTRANSPORT =====================
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Bewegungen und der Vortransport fertig sind
         - Der Vortransport wird abgebrochen, sobald der Empfaenger bereit zum Eintransport ist
      *)
      blMessachseFertig := TRUE;

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
        blMessachseFertig := Messachse.bpDone;
      END_IF

      Glastransport.bpAbbruchVortransport := blVortransportGestartet AND BasisStationsParameter.InGlasTransportNachfolger[wWand].bBereitZumEintransport;

      IF ( ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
           AND blMessachseFertig
           AND ( Hub.bpDone OR NOT ( Hub.bpStartHubAuf OR Hub.bpStartHubAb ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHub )
           AND ( Glastransport.bpDone OR NOT blVortransportGestartet ) )
      THEN
        Kippen.bpPositionieren                   := FALSE;
        Hub.bpStartHubAuf                        := FALSE;
        Hub.bpStartHubAb                         := FALSE;
        Glastransport.bpAbbruchVortransport      := FALSE;
        Glastransport.bpVortransport             := FALSE;
        Glastransport.bpVortransportRueckwaertig := FALSE;
        blVortransportGestartet                  := FALSE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
          Messachse.bpPositionierung := FALSE;
        END_IF

        steplAktion := STEP_100_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_100_E:
      (* Hinweis:
         - Austransport starten
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpAustransport             := BasisStationsParameter.bAustransport[wWand] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpAustransportRueckwaertig := BasisStationsParameter.bAustransport[wWand] AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_110_E;

    // AUSTRANSPORT =====================
    STEP_110_E:
      (* Hinweis:
         - Bei letzter Scheibe und Station leer -> Kippen
      *)
      IF ( Glastransport.bpFreigabeFremdprozess
           AND BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe
           AND blQuelleWandLeer )
      THEN
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
        Kippen.bpPositionieren := TRUE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
          Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachAustransport = eHub_Oben );
          Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachAustransport = eHub_Unten );
        END_IF
      END_IF

      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport             := FALSE;
        Glastransport.bpAustransportRueckwaertig := FALSE;
        bpDrosselklappeOeffnen                   := FALSE;

        steplAktion := STEP_200_E;

      END_IF

    // AUSTRANSPORT =====================
    STEP_200_E:
      (* Hinweis:
         - Austransport ist vorbei: die Achsen des Glastransports abnullen (Zaehlerueberlauf des Gebers),
           ein Slave-Antrieb des eigenen Glastransports wird dabei vom Master abgekoppelt
         - Nur nach dem Austransport, nie im Eintransport
         - Bei letzter Scheibe und Station leer -> Kippen, gemeinsam mit dem Abnullen
      *)
      Glastransport.bpReferenz := TRUE;

      IF BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe
         AND blQuelleWandLeer
      THEN
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
        Kippen.bpPositionieren := TRUE;

        (* Hinweis:
           - Hub auf die Sollposition nach dem Austransport fahren (nur Oben / Unten, sonst keine Bewegung)
        *)
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
          Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachAustransport = eHub_Oben );
          Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub_NachAustransport = eHub_Unten );
        END_IF
      END_IF

      steplAktion := STEP_210_E;

    // AUSTRANSPORT =====================
    STEP_210_E:
      IF ( ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
           AND ( Hub.bpDone OR NOT ( Hub.bpStartHubAuf OR Hub.bpStartHubAb ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHub )
           AND Glastransport.bpDone )
      THEN
        Kippen.bpPositionieren   := FALSE;
        Hub.bpStartHubAuf        := FALSE;
        Hub.bpStartHubAb         := FALSE;
        Glastransport.bpReferenz := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := TRUE;

  // AUSTRANSPORT =====================
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    bpDrosselklappeOeffnen := FALSE;
    BasisStationsParameter.bAustransportAbgeschlossen[wWand] := FALSE;

    Kippen.bpPositionieren                   := FALSE;
    Hub.bpStartHubAuf                        := FALSE;
    Hub.bpStartHubAb                         := FALSE;
    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    Glastransport.bpAbbruchVortransport      := FALSE;
    Glastransport.bpReferenz                 := FALSE;
    blVortransportGestartet                  := FALSE;

    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
      Messachse.bpPositionierung := FALSE;
    END_IF

    steplAktion := STEP_0_E;
  END_IF

END_IF