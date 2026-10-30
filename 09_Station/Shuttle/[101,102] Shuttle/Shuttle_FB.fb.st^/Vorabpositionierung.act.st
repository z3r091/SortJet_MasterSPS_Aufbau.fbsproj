(* METADATA
{
	"v3Meta": {
		"objectGuid": "e50934dc-6f5c-4d2e-b362-e4b913ccf137"
	}
}
*)
ACTION Vorabpositionierung
(***************************************************************************************************)
(* AKTION VORABPOSITIONIERUNG *)
(***************************************************************************************************)
(* Anmerkung:
   - Auftragsart = 3 => Verfahrauftrag zu einer bestimmten Position.[ Ohne Ein- oder Austransport von Glas]
     Dieser Auftrag wird nur ausgeführt und nicht quittiert zum MMI.
   - Auftrag kann jederzeit abgebrochen werden wenn ein Ein- bzw. Austransport Auftrag aktiv wird [Auftragsart 0 bzw. 1]
   WICHTIG:
   -  Der Positionier-Auftrag soll jetzt auch fuer das MANUELLE POSITIONIEREN genutzt werden.     
*)

blMerkerEinOderAustransportAktiv := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blMerkerEinOderAustransportAktiv := blMerkerEinOderAustransportAktiv OR BasisStationsParameter.bEintransport[wlIndex] OR BasisStationsParameter.bAustransport[wlIndex];
END_FOR

IF        BasisStationsParameter.bVorabpositionieren
  AND NOT blMerkerEinOderAustransportAktiv
THEN
  CASE steplVorabpositionierung OF
(*POSITIONIEREN ==============================*)
    STEP_0_E:
      BasisStationsParameter.bVorabpositionierenAbgeschlossen := FALSE;

      steplVorabpositionierung := STEP_10_E;

(*POSITIONIEREN ==============================*)
    STEP_10_E:
      (* Shuttle auf Position fahren
      *)
        Querfahrt.rpDestinationPosition := BasisStationsParameter.pAuftragVorabPositionierung.rVorabPosition;

        steplVorabpositionierung := STEP_20_E;

(*POSITIONIEREN ==============================*)
    STEP_20_E:
      Querfahrt.bpVerfahreShuttle := TRUE;

      IF ( Querfahrt.bpAntriebLaeuft
        OR Querfahrt.bpDone )
      THEN
        blUpdateTimer := TRUE;
        steplVorabpositionierung := STEP_30_E;
      END_IF

      (* Fehlerbehandlung
         - Querfahrt [VERFAHRLOGIK]
      *)
      IF ( Querfahrt.bpFehler ) THEN
        Querfahrt.bpVerfahreShuttle  := FALSE;
        BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
        steplVorabpositionierung := STEP_900_E;
      END_IF

(*POSITIONIEREN ==============================*)
    STEP_30_E:
      (* Anmerkung:
         - Sollte das Verfahren frueher abgeschlossen werden als der Zeitwert des Timers "tonlUpdateTimer"
           muss das Bit "bpUpdate" gesetzt werden. Damit ist Sichergestellt ist das wir in der Steuerung
           das Verfahren abgeschlossen werden kann
           => Senden der Positionsnachricht [Steuerung]
      *)
      IF ( Querfahrt.bpDone (* AND blZielPositionErreicht *) ) THEN

        IF ( NOT tonlUpdateTimer.Q  )THEN
          tonlUpdateTimer(IN := FALSE);
          blUpdateTimer := FALSE;
          BasisStationsParameter.bUpdateVorabPositionieren := TRUE;
        END_IF

        Querfahrt.bpVerfahreShuttle  := FALSE;

        steplVorabpositionierung := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Senden der Positionsnachricht [Steuerung]
      *)
      IF ( tonlUpdateTimer.Q  )THEN
        tonlUpdateTimer(IN := FALSE);
        blUpdateTimer := FALSE;
        BasisStationsParameter.bUpdateVorabPositionieren := TRUE;
      END_IF

      (* Fehlerbehandlung:
         - Verfahrlogik
      *)
      IF ( Querfahrt.bpFehler ) THEN
        Querfahrt.bpVerfahreShuttle  := FALSE;
        BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
        steplVorabpositionierung := STEP_900_E;
      END_IF

(*POSITIONIEREN ==============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*POSITIONIEREN ==============================*)
    STEP_1000_E:
      BasisStationsParameter.bVorabpositionierenAbgeschlossen := TRUE;

(*POSITIONIEREN ==============================*)
  END_CASE
END_IF
IF ( NOT BasisStationsParameter.bVorabpositionieren ) THEN

  IF (steplVorabpositionierung > STEP_0_E) THEN
    BasisStationsParameter.bVorabpositionierenAbgeschlossen := FALSE;
    BasisStationsParameter.bUpdateVorabPositionieren := FALSE;
    blUpdateTimer := FALSE;
    tonlUpdateTimer(IN := FALSE);
    Querfahrt.bpVerfahreShuttle := FALSE;
    steplVorabpositionierung := STEP_0_E;
  END_IF

END_IF
END_ACTION