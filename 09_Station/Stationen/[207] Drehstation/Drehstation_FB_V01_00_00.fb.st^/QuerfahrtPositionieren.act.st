(* METADATA
{
	"v3Meta": {
		"objectGuid": "71753eb2-e168-4665-b3c5-2a0499218d20"
	}
}
*)
ACTION QuerfahrtPositionieren
//-------------------------------------------------------------------------------------------------
// POSITIONIEREN [QUERFAHRT]
//-------------------------------------------------------------------------------------------------
//Der Auftragsstatus [cSHUTTLE_VORABPOSITIONIEREN] muss zurueck gesetzt werden
BasisStationsParameter.bPositionierAuftragZuruecksetzen := Querfahrt.bpAuftragsstatusZuruecksetzen;

//Quittierungsmeldung das der Auftrag zurueck gesetzt worden ist
IF ( BasisStationsParameter.bQuittungPositionierungZurueckgesetzt ) THEN
  BasisStationsParameter.bQuittungPositionierungZurueckgesetzt := FALSE;
  Querfahrt.bpQuittungAuftragsstatusZurueckgesetzt := TRUE;
END_IF

(* Hinweis:
   - Gibt an wann wann sich der Antrieb melden muss
     => rlUpdateZeit: Wird von der Oberflaeche gesendet und entspricht der Zeit wann der Antrieb sich zurueck melden soll [Status]
*)
tonlUpdateTimer(IN := blUpdateTimer, PT := REAL_TO_TIME(BasisStationsParameter.pAuftragVorabPositionierung.rVorabUpdateZeit) );



IF (  BasisStationsParameter.bVorabpositionieren
     AND NOT BasisStationsParameter.bEintransport[cWAND_1]
     AND NOT BasisStationsParameter.bAustransport[cWAND_1] )
THEN

  CASE steplPositionierungQuerfahrt OF
    // POSITIONIEREN ==============================
    STEP_0_E:
      steplPositionierungQuerfahrt := STEP_10_E;

    // POSITIONIEREN ==============================
    STEP_10_E:
      (* Hinweis:
         - Station auf eine definierte Position verfahren
      *)
      Querfahrt.rpZielPosition  := BasisStationsParameter.pAuftragVorabPositionierung.pPositionierAuftrag.rSollPosition;
      Querfahrt.bpPositionieren := TRUE;

      steplPositionierungQuerfahrt := STEP_20_E;

    // POSITIONIEREN ==============================
    STEP_20_E:
      IF ( Querfahrt.Antrieb.bpAntrieblaeuft
           OR Querfahrt.bpDone )
      THEN
        blUpdateTimer := TRUE;
        steplPositionierungQuerfahrt := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Querfahrt [VERFAHRLOGIK]
      *)
      IF ( Querfahrt.bpFehler ) THEN
        Querfahrt.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_QUERFAHRT;
        steplPositionierungQuerfahrt := STEP_900_E;
      END_IF

    // POSITIONIEREN ==============================
    STEP_30_E:
      (* Anmerkung:
         - Sollte das Verfahren frueher abgeschlossen werden als der Zeitwert des Timers "tonlUpdateTimer"
           muss das Bit "bpUpdate" gesetzt werden. Damit ist Sichergestellt ist das wir in der Steuerung
           das Verfahren abgeschlossen werden kann
           => Senden der Positionsnachricht [Steuerung]
      *)
      IF (  Querfahrt.bpDone
         (* AND blZielPositionErreicht *) )
      THEN

        IF ( NOT tonlUpdateTimer.Q  )THEN
          tonlUpdateTimer(IN := FALSE);
          blUpdateTimer := FALSE;
          BasisStationsParameter.bUpdateVorabPositionieren := TRUE;
        END_IF

        Querfahrt.bpPositionieren := FALSE;

        steplPositionierungQuerfahrt := STEP_1000_E;
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
        Querfahrt.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_QUERFAHRT;
        steplPositionierungQuerfahrt := STEP_900_E;
      END_IF

    // POSITIONIEREN ==============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // POSITIONIEREN ==============================
    STEP_1000_E:
      BasisStationsParameter.bVorabpositionierenAbgeschlossen := TRUE;

  // POSITIONIEREN ==============================
  END_CASE
END_IF

IF ( NOT BasisStationsParameter.bVorabpositionieren ) THEN

  IF (steplPositionierungQuerfahrt > STEP_0_E) THEN
    BasisStationsParameter.bVorabpositionierenAbgeschlossen := FALSE;
    BasisStationsParameter.bUpdateVorabPositionieren := FALSE;
    blUpdateTimer := FALSE;
    tonlUpdateTimer(IN := FALSE);
    Querfahrt.bpPositionieren := FALSE;
    steplPositionierungQuerfahrt := STEP_0_E;
  END_IF

END_IF
END_ACTION