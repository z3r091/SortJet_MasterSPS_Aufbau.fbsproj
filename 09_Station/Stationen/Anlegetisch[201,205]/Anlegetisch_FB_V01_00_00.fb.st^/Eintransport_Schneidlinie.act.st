(* METADATA
{
	"v3Meta": {
		"objectGuid": "76406fdf-1ca3-4f4b-9279-634b620e5f73"
	}
}
*)
ACTION Eintransport_Schneidlinie
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT SCHNEIDLINIE (VSG-SCHNITTSTELLE)
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Mit der VSG-Schnittstelle entscheidet die Station selbst, ob angelegt oder von der Schneidlinie eingetragen wird
     (Option bAnlegetischMitEintransportVorgaenger). Sonst entscheidet das MMI ueber die Transferstation im Auftrag
   - Das Anlegen gibt ab (bpUebernahmeEintransport), solange es auf den Bediener wartet
*)
blVSG_Automatik_Eintransport := BasisStationsParameter.stMKs.stStationsOptionen.stAnlegetisch.bAnlegetischMitEintransportVorgaenger
                                AND NOT blAnlegenErzwingen
                                AND BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bAutomatikBetriebAktiv                             // Automatik Betrieb aktiv
                                AND NOT ( BasisStationsParameter.eStatusAuftrag = eAuftragWiederholen )                                           // Messung Fehlerhaft. Scheibe muss angelegt werden
                                AND NOT ( BasisStationsParameter.eStatusAuftrag = eAuftragAktivWiederholen )                                      // Messung Fehlerhaft. Scheibe muss angelegt werden
                                AND NOT Glastransport.bpSensorEinlauf                                                                             // Einlaufsensor belegt
                                AND NOT Glastransport.bpSensorAuslauf                                                                             // Auslaufsensor belegt
                                AND ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe >= BasisStationsParameter.stMKs.stStationsParameter.rMinGlasHoeheAutomatischenEintransport )    // Scheibe zu niedrig
                                AND ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsLaenge >= BasisStationsParameter.stMKs.stStationsParameter.rMinGlasLaengeAutomatischenEintransport ); // Scheibe zu kurz

// Uebernahme merken, solange das Anlegen auf den Bediener wartet; mit dem Ende des Anlegen-Auftrags zuruecksetzen
IF ( NOT BasisStationsParameter.bAnlegen ) THEN
  blVSGUebernahme := FALSE;
ELSIF ( Anlegen.bpBedienerEingriff
        AND blVSG_Automatik_Eintransport ) THEN
  blVSGUebernahme := TRUE;
END_IF

IF( BasisStationsParameter.bAnlegen
    AND blVSGUebernahme
    AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplEintransportSchneidlinie := STEP_900_E;
  END_IF

  CASE steplEintransportSchneidlinie OF
    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_0_E:
      steplEintransportSchneidlinie := STEP_200_E;

    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_200_E:
      (* Anmerkung:
         - Glastransport Ausfahren
         - Anschlaege einfahren
         - Hoehenkontrolle auf Min Pos positionieren
      *)
      Hubrahmen.bpStartAusfahren := TRUE;
      Anschlag.bpStartEinfahren  := TRUE;

      (* Anmerkung:
         - Drosselklappe oeffnen, damit auch sehr schweres Glas transportiert werden kann, indem die Luft das Glas leicht anhebt
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

      steplEintransportSchneidlinie := STEP_210_E;

    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_210_E:
      (* Anmerkung:
         - Glastransport Ausfahren
         - Anschlaege einfahren
         - Messachse.positionieren
      *)
      IF ( Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen )
         AND Messachse.bpDone
         AND ( Anschlag.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag )
      THEN
        Anschlag.bpStartEinfahren  := FALSE;
        Hubrahmen.bpStartAusfahren := FALSE;
        Messachse.bpPositionierung := FALSE;

        steplEintransportSchneidlinie := STEP_220_E;
      END_IF

    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_220_E:
      // Glastransport Eintransport starten
      Glastransport.eGlastyp := BasisStationsParameter.wGlastyp[cWAND_1];
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpEintransport := TRUE;

      steplEintransportSchneidlinie := STEP_230_E;

    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_230_E:
      blLampeSchneidlinie := TRUE;

      // Scheibe wird nicht Eintransportiert sondern soll angelegt werden
      IF rtlFussleisteStart.Q THEN
        Glastransport.bpEintransport := FALSE;
        blLampeSchneidlinie := FALSE;
        blVSGUebernahme := FALSE;
        blNeustartSchneidlinie := TRUE;
        steplEintransportSchneidlinie := STEP_0_E;
      END_IF

      // Auf den Glastransport warten
      IF Glastransport.bpDone THEN
        blLampeSchneidlinie := FALSE;

        Glastransport.bpEintransport := FALSE;
        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;
        steplEintransportSchneidlinie := STEP_1010_E;
      END_IF

    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_900_E:
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT SCHNEIDLINIE ==================================
    STEP_1010_E:
      // Scheibe wurde von der VSG Eintransportiert und muss vermessen werden
      epTypeHoehenmessung := Modus_Vermessen_OberUndUnterkante_2_Sensoren;

      BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;

  // EINTRANSPORT SCHNEIDLINIE ==================================
  END_CASE
ELSE

  IF( steplEintransportSchneidlinie > STEP_0_E ) THEN
    Glastransport.bpEintransport := FALSE;
    Hubrahmen.bpStartAusfahren   := FALSE;
    Anschlag.bpStartEinfahren    := FALSE;
    Messachse.bpPositionierung   := FALSE;
    blLampeSchneidlinie          := FALSE;

    steplEintransportSchneidlinie := STEP_0_E;
  END_IF

END_IF
END_ACTION