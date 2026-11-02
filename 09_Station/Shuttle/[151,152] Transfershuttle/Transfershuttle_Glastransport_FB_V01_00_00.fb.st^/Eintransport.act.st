(* METADATA
{
  "v3Meta": {
    "objectGuid": "0b6f2faf-7b9d-446d-a233-29b8c61da25d"
  }
}
*)
ACTION Eintransport
//-------------------------------------------------------------------------------------------------
// AKTION: STEUERUNG EINTRANSPORT
//-------------------------------------------------------------------------------------------------
IF (  bpEintransport
     AND bpAutomatikAktiv )
THEN

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplEintransport OF
    // EINTRANSPORT ==============================
    STEP_0_E:
      bpDone:= FALSE;
      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      tonlWartenAufSenken(IN:=FALSE);
      blEintransportDefaultLuftabfrage := FALSE;

      IF Antrieb.bpReglerBereit THEN
        steplEintransport := STEP_5_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_5_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
      steplEintransport := STEP_6_E;

    // EINTRANSPORT ==============================
    STEP_6_E:
      IF Antrieb.bpDone THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_10_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT IM TRANSFERSHUTTLE VERBUND
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( bpTransfershuttleVerbundAktiv ) THEN

        blSchnittstelle_bAnforderungTransportVerbund := TRUE;

        IF ( stpInTransportVerbund.bBereitZumTransportVerbund ) THEN
          steplEintransport := STEP_20_E;
        END_IF

      ELSE
        steplEintransport := STEP_20_E;

      END_IF

    // EINTRANSPORT ==============================
    STEP_20_E:
      blEintransportDefaultLuftabfrage := TRUE;
      steplEintransport := STEP_100_E;

    // EINTRANSPORT ==============================
    STEP_100_E:
      IF ( blAbgeschlossenEintransport ) THEN
        blEintransportDefaultLuftabfrage := FALSE;

        steplEintransport := STEP_1000_E;

      END_IF

      (* Ausnahmefehler:
         - Aktionen zuruecksetzen
      *)
      IF ( bpFehler ) THEN
        blEintransportDefaultLuftabfrage := FALSE;

        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_900_E:
      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      bpFehler := TRUE;

    // EINTRANSPORT ==============================
    STEP_1000_E:

      bpDone:=TRUE;

  // EINTRANSPORT ==============================
  END_CASE
ELSE

  IF ( steplEintransport > STEP_0_E ) THEN
    bpDone := FALSE;
    blSchnittstelle_bAnforderungTransportVerbund := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    blEintransportDefaultLuftabfrage := FALSE;

    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION