(* METADATA
{
	"v3Meta": {
		"objectGuid": "85ab8f83-af0d-4158-a31f-3e8e16326790"
	}
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AKTION: STEUERUNG AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  bpAustransport
     AND bpAutomatikAktiv )
THEN

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplAustransport OF
    // AUSTRANSPORT ==============================
    STEP_0_E:
      bpDone:= FALSE;
      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      tonlWartenAufSenken(IN:=FALSE);
      blAustransportDefaultLuftabfrage := FALSE;

      IF ( Antrieb.bpReglerBereit ) THEN
        steplAustransport := STEP_5_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_5_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
      steplAustransport := STEP_6_E;

    // AUSTRANSPORT ==============================
    STEP_6_E:
      IF Antrieb.bpDone THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_10_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  AUSTRANSPORT IM TRANSFERSHUTTLE VERBUND
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( bpTransfershuttleVerbundAktiv ) THEN

        blSchnittstelle_bAnforderungTransportVerbund := TRUE;

        IF ( stpInTransportVerbund.bBereitZumTransportVerbund ) THEN
          steplAustransport := STEP_20_E;
        END_IF

      ELSE
        steplAustransport := STEP_20_E;

      END_IF

    // AUSTRANSPORT ==============================
    STEP_20_E:
      blAustransportDefaultLuftabfrage := TRUE;
      steplAustransport := STEP_100_E;

    // AUSTRANSPORT ==============================
    STEP_100_E:
      IF ( blAbgeschlossenAustransport ) THEN
        blAustransportDefaultLuftabfrage := FALSE;

        steplAustransport := STEP_1000_E;

      END_IF

      (* Ausnahmefehler:
         - Aktionen zuruecksetzen
      *)
      IF ( bpFehler ) THEN
        blAustransportDefaultLuftabfrage := FALSE;

        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      bpFehler := TRUE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      bpDone:=TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE

  IF ( steplAustransport > STEP_0_E ) THEN
    bpDone := FALSE;
    blSchnittstelle_bAnforderungTransportVerbund := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlAntriebNichtFreigegeben( IN := FALSE );

    blAustransportDefaultLuftabfrage := FALSE;

    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION