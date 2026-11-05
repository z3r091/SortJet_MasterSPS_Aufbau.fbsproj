(* METADATA
{
  "v3Meta": {
    "objectGuid": "37a26a85-68d5-4775-b05c-ebd4ad8948b2"
  }
}
*)
ACTION MutingSensorReset
//-------------------------------------------------------------------------------------------------
// MUTING-SENSOREN ZURUECKSETZEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Steht nach dem Einschalten ein Faecherwagen in der Station, muessen die Muting-Sensoren einmal
     zurueckgesetzt werden, sonst loest beim naechsten Einschleusen (Rolltor auf) der Sicherheitskreis aus
   - Anforderung ueber blMutingResetAnforderung (Kette Sicherheitskreis-Reset), Impuls ZEIT_MUTING_SENSOR_RESET
   - Option AGV: ohne eingeschleusten Faecherwagen (blMutingAusschalten) den Reset im Automatikbetrieb dauerhaft
     ausgeben
*)
IF ( blMutingResetAnforderung ) THEN
  blMutingResetAnforderung := FALSE;

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAGV ) THEN
    // Rolltor zu: Muting weg kann keinen aktiven Sicherheitskreis unterbrechen
    // Rolltor auf: Reset nur, wenn der Sicherheitskreis nicht in Ordnung ist und beide Sensoren belegt sind
    IF     NOT blMutingAusschalten
       AND (    bpRolltorUnten
             OR ( blFaecherwagenErkannt AND NOT in_bSicherheitsrelaisOK ) )
    THEN
      blMutingResetImpuls := TRUE;
    END_IF
  ELSE
    IF bpRolltorUnten AND in_bMutingSensorLinks AND in_bSicherheitsrelaisOK THEN
      blMutingResetImpuls := TRUE;
    END_IF
  END_IF
END_IF

// Reset-Impuls fester Laenge
toflMutingSensorReset( IN := blMutingResetImpuls, PT := ZEIT_MUTING_SENSOR_RESET );
blMutingSensorReset := toflMutingSensorReset.Q;

rtlMutingSensorReset( CLK := toflMutingSensorReset.Q );
IF ( rtlMutingSensorReset.Q ) THEN
  blMutingResetImpuls := FALSE;
END_IF

// Ausgang
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAGV ) THEN
  out_bMutingSensorReset := blBetriebsartAutomatik AND ( blMutingAusschalten OR blMutingSensorReset );
ELSE
  out_bMutingSensorReset := blMutingSensorReset;
END_IF
END_ACTION