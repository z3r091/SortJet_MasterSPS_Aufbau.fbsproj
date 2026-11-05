(* METADATA
{
  "v3Meta": {
    "objectGuid": "55863f74-01aa-4af3-a904-fb5ee81aa524"
  }
}
*)
ACTION SlaveBetriebGreifer
//-------------------------------------------------------------------------------------------------
// AKTION SLAVEBETRIEB GREIFER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ein- / Austransport mit dem Shuttle-Greifer: die Greiferachse ist Master, der Glastransport folgt synchron
   - Die Kopplung bleibt bestehen, solange der Greifer sie anfordert
*)
IF (     bpStarteSlaveKopplungGreifer
     AND NOT bpReset
     AND NOT bpFahreReferenz )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    bpGreiferSlaveAktiv   := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplSlaveGreifer := STEP_900_E;
  END_IF

  CASE steplSlaveGreifer OF
    // SLAVEBETRIEB GREIFER ==============================
    STEP_0_E:
      (* Hinweis:
         - Antrieb bereit
      *)
      bpGreiferSlaveAktiv := FALSE;

      tonlUeberwachungSlaveGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF (     Antrieb.bpReglerBereit
           AND blAntriebsKopplungAktiv )
      THEN
        tonlUeberwachungSlaveGreifer( IN := FALSE );
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplSlaveGreifer := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungSlaveGreifer.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplSlaveGreifer := STEP_900_E;
      END_IF

    // SLAVEBETRIEB GREIFER ==============================
    STEP_10_E:
      (* Hinweis:
         - Auf die Greiferachse synchronisieren
      *)
      Antrieb.wpMaster      := wpAchsIDGreifer;
      Antrieb.wpBetriebsart := SYNC_AUF_MASTER;

      tonlUeberwachungSlaveGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( Antrieb.bpDone ) THEN
        tonlUeberwachungSlaveGreifer( IN := FALSE );
        bpGreiferSlaveAktiv := TRUE;
        steplSlaveGreifer := STEP_20_E;
      END_IF

      IF ( tonlUeberwachungSlaveGreifer.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_SLAVE_NICHT_AKTIV;
        steplSlaveGreifer := STEP_900_E;
      END_IF

    // SLAVEBETRIEB GREIFER ==============================
    STEP_20_E:
      (* Hinweis:
         - Kopplung aktiv bis zur Ruecknahme der Anforderung; Antriebsfehler fuehren in den Fehlerschritt
      *)
      bpGreiferSlaveAktiv := TRUE;

    // SLAVEBETRIEB GREIFER ==============================
    STEP_900_E:
      bpGreiferSlaveAktiv := FALSE;
      bpFehler := TRUE;

  // SLAVEBETRIEB GREIFER ==============================
  END_CASE

ELSE

  IF ( steplSlaveGreifer > STEP_0_E ) THEN
    bpGreiferSlaveAktiv   := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlUeberwachungSlaveGreifer( IN := FALSE );
    steplSlaveGreifer := STEP_0_E;
  END_IF

END_IF
END_ACTION