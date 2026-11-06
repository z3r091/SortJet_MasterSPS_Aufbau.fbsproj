(* METADATA
{
  "v3Meta": {
    "objectGuid": "acd5983d-167d-4071-a6a9-aefc553f060d"
  }
}
*)
FUNCTION_BLOCK Anlegetisch_Eintransport_FB_V01_00_00 EXTENDS Basic_Station_Eintransport_FB_V01_00_00
(* Hinweis:
   - Eintransport des Anlegetisches von einer Fremdanlage (z.B. Brechanlage): Hubrahmen ausfahren, Anschlaege
     einfahren, Hoehenkontrolle positionieren, dann Eintransport
   - Mit dem Taster (oder wenn der Automatikbetrieb der Schneidlinie endet) wird die Scheibe nicht eintransportiert,
     sondern angelegt (bpAnlegenUmschalten)
   - Der Rumpf ersetzt den Rumpf des Basic-Eintransports, die Komponenten (Messachse, Glastransport) kommen vom Basic-Baustein
*)
VAR_INPUT

  // BOOLEAN
  bpAnlegenUmschalten : BOOL; // Station: Scheibe soll angelegt statt eintransportiert werden

  // Bausteine
  Anschlag  : REFERENCE TO ZylinderPneumatik_Anschlag_FB_V01_00_00;
  Hubrahmen : REFERENCE TO ZylinderPneumatik_Riemen_FB_V01_00_00;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpAnlegenLampe : BOOL; // Ampel gruen / Signal Scheibe anlegen

END_VAR
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT
//-------------------------------------------------------------------------------------------------
IF( BasisStationsParameter.bEintransport[wWand]
    AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF Hubrahmen.bpFehler THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF
  
  IF Anschlag.bpFehler THEN
    Anschlag.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF
  
  IF Messachse.bpFehler THEN
    Messachse.bpPositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  
  CASE steplAktion OF
    // EINTRANSPORT ==================================
    STEP_0_E:

      bpFehler := FALSE;

      BasisStationsParameter.eStatusAuftrag   := eAuftragAktiv;

      IF ( bpGeblaeseFehler ) THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAktion := STEP_900_E;

      ELSE
        steplAktion := STEP_10_E;

      END_IF

    // EINTRANSPORT ==================================
    STEP_10_E:

      (* Anmerkung:
         - Glastransport Ausfahren
         - Anschläge einfahren
         - Messachse positionieren
      *)
      Hubrahmen.bpStartAusfahren := TRUE;
      Anschlag.bpStartEinfahren  := TRUE;

      IF Messachse.Antrieb.rpMaxPosition < ( BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
        Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
      ELSE
        Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[wWand].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplAktion := STEP_20_E;

    // EINTRANSPORT ==================================
    STEP_20_E:

      (* Anmerkung:
         - Glastransport Ausfahren
         - Anschläge einfahren
         - Messachse.positionieren
      *)
      IF (     ( Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen )
           AND Messachse.bpDone
           AND ( Anschlag.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) )
      THEN
        Anschlag.bpStartEinfahren        := FALSE;
        Hubrahmen.bpStartAusfahren       := FALSE;
        Messachse.bpPositionierung := FALSE;
        steplAktion := STEP_30_E;
      END_IF

    // EINTRANSPORT ==================================
    STEP_30_E:

      (* Anmerkung:
         - Drosselklappe öffnen, damit auch sehr schweres Glas transportiert werden kann, indem die Luft das Glas leicht anhebt
      *)
      bpDrosselklappeOeffnen := TRUE;

      (* Anmerkung:
         - Glastransport Eintransport starten
      *)
      Glastransport.eGlastyp := BasisStationsParameter.wGlastyp[wWand];
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpEintransport := TRUE;

      steplAktion := STEP_40_E;

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF Glastransport.bpFehler THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT ==================================
    STEP_40_E:

      bpAnlegenLampe  := TRUE;

      // Scheibe wird nicht Eintransportiert sondern soll angelegt werden
      IF bpAnlegenUmschalten THEN
        bpAnlegenLampe := FALSE;
        BasisStationsParameter.bAnlegen := TRUE;
        BasisStationsParameter.bEintransport[wWand] := FALSE;
      END_IF

      (* Anmerkung:
         - Auf den Glastransport warten
      *)
      IF Glastransport.bpDone THEN

        bpAnlegenLampe  := FALSE;

        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.eStatusAuftrag   := eAuftragErfolgreich;
        steplAktion := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
         - Anschlag
      *)
      IF Glastransport.bpFehler THEN
        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF
      IF Anschlag.bpFehler THEN
        Anschlag.bpStartAusfahren := FALSE;
        BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT ==================================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.eStatusAuftrag   := eAuftragFehler;
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT ==================================
    STEP_1000_E:
      BasisStationsParameter.dwWartezeit[wWand] := 0;
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := TRUE;

  // EINTRANSPORT ==================================
  END_CASE
ELSE

  IF( steplAktion > STEP_0_E )THEN
    bpFehler                              := FALSE;
    bpDrosselklappeOeffnen                := FALSE;
    Glastransport.bpEintransport          := FALSE;
    Anschlag.bpStartEinfahren             := FALSE;
    Anschlag.bpStartAusfahren             := FALSE;
    bpAnlegenLampe   := FALSE;
    Hubrahmen.bpStartAusfahren            := FALSE;
    Messachse.bpPositionierung      := FALSE;
    Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;
    BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;
    steplAktion := STEP_0_E;
  END_IF

END_IF
