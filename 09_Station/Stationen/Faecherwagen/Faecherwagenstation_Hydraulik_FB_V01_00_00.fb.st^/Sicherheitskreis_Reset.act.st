(* METADATA
{
  "v3Meta": {
    "objectGuid": "5b2b3b3a-0378-4a76-86aa-19573502ed03"
  }
}
*)
ACTION Sicherheitskreis_Reset
//-------------------------------------------------------------------------------------------------
// SICHERHEITSKREIS-RESET
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Quittiert das Sicherheitsrelais der Station (kein Quittiertaster an der Station)
   - Anforderung blStarteSicherheitskreisReset: nach dem Programmstart automatisch und vom MMI
     (SB0_MMI_STATIONSTATUS, Statuswort 1 Bit 0)
   - Zuerst die Muting-Sensoren zuruecksetzen, danach zwei Reset-Impulse auf das Sicherheitsrelais
*)
IF ( blStarteSicherheitskreisReset ) THEN

  CASE steplSicherheitskreisReset OF

    // SICHERHEITSKREIS-RESET =================
    STEP_0_E:
      tonlResetImpuls( IN := FALSE );
      tonlResetWarten( IN := FALSE );
      out_bResetSicherheitsrelais := FALSE;

      blMutingResetAnforderung   := TRUE;
      steplSicherheitskreisReset := STEP_5_E;

    // SICHERHEITSKREIS-RESET =================
    STEP_5_E:
      (* Hinweis:
         - Auf den Reset der Muting-Sensoren warten; findet keiner statt (Bedingungen nicht erfuellt),
           nach Ablauf der Wartezeit trotzdem quittieren
      *)
      tonlResetWarten( IN := TRUE, PT := T#5S );

      IF ( blMutingSensorReset ) THEN
        tonlResetWarten( IN := FALSE );
        steplSicherheitskreisReset := STEP_10_E;
      ELSIF ( tonlResetWarten.Q ) THEN
        tonlResetWarten( IN := FALSE );
        steplSicherheitskreisReset := STEP_20_E;
      END_IF

    // SICHERHEITSKREIS-RESET =================
    STEP_10_E:
      (* Hinweis:
         - Ende des Muting-Resets abwarten (Impuls fester Laenge, Absicherung ueber die Wartezeit)
      *)
      tonlResetWarten( IN := TRUE, PT := T#5S );

      IF ( NOT blMutingSensorReset OR tonlResetWarten.Q ) THEN
        tonlResetWarten( IN := FALSE );
        steplSicherheitskreisReset := STEP_20_E;
      END_IF

    // SICHERHEITSKREIS-RESET =================
    STEP_20_E:
      out_bResetSicherheitsrelais := TRUE;
      steplSicherheitskreisReset  := STEP_30_E;

    // SICHERHEITSKREIS-RESET =================
    STEP_30_E:
      // Erster Reset-Impuls
      tonlResetImpuls( IN := TRUE, PT := T#1S );

      IF ( tonlResetImpuls.Q ) THEN
        tonlResetImpuls( IN := FALSE );
        out_bResetSicherheitsrelais := FALSE;
        steplSicherheitskreisReset  := STEP_40_E;
      END_IF

    // SICHERHEITSKREIS-RESET =================
    STEP_40_E:
      // Pause zwischen den Impulsen
      tonlResetWarten( IN := TRUE, PT := T#500MS );

      IF ( tonlResetWarten.Q ) THEN
        tonlResetWarten( IN := FALSE );
        out_bResetSicherheitsrelais := TRUE;
        steplSicherheitskreisReset  := STEP_50_E;
      END_IF

    // SICHERHEITSKREIS-RESET =================
    STEP_50_E:
      // Zweiter Reset-Impuls
      tonlResetImpuls( IN := TRUE, PT := T#500MS );

      IF ( tonlResetImpuls.Q ) THEN
        tonlResetImpuls( IN := FALSE );
        out_bResetSicherheitsrelais := FALSE;
        steplSicherheitskreisReset  := STEP_1000_E;
      END_IF

    // SICHERHEITSKREIS-RESET =================
    STEP_1000_E:
      blStarteSicherheitskreisReset := FALSE;

  // SICHERHEITSKREIS-RESET =================
  END_CASE

ELSE

  IF ( steplSicherheitskreisReset > STEP_0_E ) THEN
    out_bResetSicherheitsrelais := FALSE;
    tonlResetImpuls( IN := FALSE );
    tonlResetWarten( IN := FALSE );
    steplSicherheitskreisReset := STEP_0_E;
  END_IF

END_IF
END_ACTION