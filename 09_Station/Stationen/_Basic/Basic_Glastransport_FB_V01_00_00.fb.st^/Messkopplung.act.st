(* METADATA
{
	"v3Meta": {
		"objectGuid": "447f5584-a183-4598-9766-d0da4d40ae14"
	}
}
*)
ACTION Messkopplung
//-------------------------------------------------------------------------------------------------
// AKTION: MESSKOPPLUNG
//-------------------------------------------------------------------------------------------------

IF (  bpMesskopplung
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_MASTER;
    steplMesskopplung := STEP_900_E;
  END_IF

  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplMesskopplung := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplMesskopplung := STEP_900_E;
  END_IF


  // Ausnahmesituation:
  //   - Slave-Kopplung waehrend der Kette verloren
  IF ( NOT blAntriebsKopplungAktiv AND ( steplMesskopplung > STEP_0_E ) AND ( steplMesskopplung < STEP_900_E ) ) THEN
    wpFehlerNr := cMELDUNG_MESSUNG_SLAVE_KOPPLUNG_VERLOREN;
    steplMesskopplung := STEP_900_E;
  END_IF

  CASE steplMesskopplung OF

    // MESSKOPPLUNG ================================================
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      bpDone := FALSE;
      bpOutBereitZumEintransport := FALSE;

      // Zeit für Statistik
      tlWarteZeitAufnahme := TIME();

      // Sicherstellen das die Slavekopplung aktiv ist
      IF ( blAntriebsKopplungAktiv ) THEN
        steplMesskopplung := STEP_100_E;
      END_IF

    // MESSKOPPLUNG ================================================
    STEP_100_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation bereit ist zum Eintransport
      *)
      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        steplMesskopplung := STEP_110_E;
      END_IF

    // MESSKOPPLUNG ================================================
    STEP_110_E:
      (* Hinweis:
         - Antrieb in den Master- Slave- Modus setzen
      *)
      Antrieb.wpMaster := InGlasTransportVorgaenger.wAchsID;
      Antrieb.wpBetriebsart := SYNC_AUF_MASTER;

      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumEintransport := TRUE;
        steplMesskopplung := STEP_120_E;
      END_IF

    // MESSKOPPLUNG ================================================
    STEP_120_E:
      (* Wichtig:
         - Kopplung wird solange aktiv gehalten bis diese von dem uebergeordneten Baustein geloest wird
      *)
      bpDone := TRUE;

    // MESSKOPPLUNG ================================================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      bpFehler := TRUE;

    // MESSKOPPLUNG ================================================
    STEP_1000_E:
      bprtScheibe := FALSE;
      bpDone := TRUE;

  // MESSKOPPLUNG ================================================
  END_CASE
END_IF

IF ( NOT bpMesskopplung ) THEN

  IF (steplMesskopplung > STEP_0_E ) THEN
    bpDone := FALSE;

    bpOutBereitZumEintransport := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    steplMesskopplung := STEP_0_E;
  END_IF

END_IF
END_ACTION