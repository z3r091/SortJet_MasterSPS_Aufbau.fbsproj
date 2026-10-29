(* METADATA
{
	"v3Meta": {
		"objectGuid": "ecb0d066-6da3-496b-a292-2b223c7d481e"
	}
}
*)
ACTION Reset
(* @TEXT_IMPLEMENTATION := 'ST' *)
(***************************************************************************************************)
(* S T A R T - Reset *)
(***************************************************************************************************)
tonlMaxWarteAufResetErfolgreich(IN := (bpReset AND (steplReset < STEP_900_E)),pt:=tgMaxWartezeitReset-t#1s);

IF ( bpReset ) THEN
  CASE steplReset OF
(*RESET ==============================*)
    STEP_0_E:
      bpDone                       := FALSE;
      bprtScheibe                  := FALSE;
      out_bShuttleAnheben          := FALSE;
      bpScheibeFaehrtUeberAuslauf  := FALSE;
      bpScheibeFaehrtUeberEinlauf  := FALSE;
      blFehlerAusloesen            := FALSE;
      blLetzteScheibeEintransport  := FALSE;

      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      bpAnforderungBetriebsstopp := FALSE;

      blSchnittstelle_bBereitZumTransportVerbund   := FALSE;
      blSchnittstelle_bAnforderungTransportVerbund := FALSE;

      out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
      blScheibenKontrolleAuslaufseiteEin    := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
      blScheibenKontrolleEinlaufseiteEin    := FALSE;

      wpAusnahmefehlerTyp := cMELDUNG_NULL;

      steplReset := STEP_10_E;

(*RESET ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Aktionen zuruecksetzen
      *)
      blAustransportDefaultLuftabfrage := FALSE;
      blEintransportDefaultLuftabfrage := FALSE;

	    (* Hinweis:
	       - Betriebsarten zuruecksetzen
      *) 
	  bpStarteHebeVorgang := FALSE;
	  bpEintransport      := FALSE;
      bpAustransport      := FALSE;
      bpVortransport      := FALSE;

	    steplReset          := STEP_20_E;

(*RESET ==============================*)
    STEP_20_E:
      Antrieb.wpBetriebsart := KEINE_FUNKTION;
	  
	  IF NOT Antrieb.bpAntrieblaeuft THEN
        steplReset := STEP_30_E;
	  END_IF

(*RESET ==============================*)
    STEP_30_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;
      steplReset := STEP_40_E;

(*RESET ==============================*)
    STEP_40_E:
      IF( Antrieb.bpDone )THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReset := STEP_1000_E;
      END_IF

      IF ( NOT Antrieb.bpDone AND tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

(*RESET ==============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler := TRUE;

(*RESET ==============================*)
    STEP_1000_E:
      wpFehlerNr          := cMELDUNG_NULL;
      wpAusnahmefehlerTyp := cMELDUNG_NULL;

      bpFehler :=FALSE;
      bpDone   :=TRUE;

(*RESET ==============================*)
  END_CASE
ELSE
  IF( steplReset > STEP_0_E )THEN
    bpDone:=FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplReset := STEP_0_E;
  END_IF
END_IF

(***************************************************************************************************)
(* E N D E - Reset *)
(***************************************************************************************************)
END_ACTION