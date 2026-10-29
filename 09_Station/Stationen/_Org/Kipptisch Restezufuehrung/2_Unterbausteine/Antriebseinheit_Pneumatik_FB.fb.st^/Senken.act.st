(* METADATA
{
	"v3Meta": {
		"objectGuid": "db809b55-b6bf-4fc2-a1a0-ed73bea6f7ca"
	}
}
*)
ACTION Senken
(***************************************************************************************************)
(* AKTION: SENKEN *)
(***************************************************************************************************)
IF ( bpSenken 
  AND NOT bpHeben ) 
THEN
  
  CASE stepSenken OF  
(* SENKEN =====================*)
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
      *)
      bpDone := FALSE;

      tonWartenEntriegeln( IN := FALSE );
      
      IF ( NOT in_bAntriebseinheitUnten ) THEN
        tonTimeoutSenken(IN := FALSE);
        stepSenken := STEP_10_E;
      ELSE
        stepSenken := STEP_1000_E;
      END_IF
      
(* SENKEN =====================*)
    STEP_10_E:
      (* Hinweis:
         - Verriegelung einfahren
      *)
      out_bAntriebseinheitEntriegeln := TRUE;
        
      tonWartenEntriegeln( IN := in_bAntriebseinheitEntriegelt, PT := T#500MS);
      IF ( tonWartenEntriegeln.q ) THEN
        out_bAntriebseinheitEntriegeln := FALSE;
        stepSenken := STEP_20_E;
      END_IF
     
      // Fehlerbehandlung:
      tonTimeoutEntriegeln( IN := NOT in_bAntriebseinheitEntriegelt,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      
      IF ( tonTimeoutEntriegeln.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        stepSenken := STEP_900_E;
      END_IF

(* SENKEN =====================*)
    STEP_20_E:
      (* Hinweis:
         - Antriebseinheit senken
      *)
      out_bAntriebseinheitSenken := TRUE;

      IF ( in_bAntriebseinheitUnten ) THEN
        out_bAntriebseinheitSenken := FALSE;
        stepSenken := STEP_1000_E;
      END_IF

      // Fehlerbehandlung:
      tonTimeoutSenken( IN := NOT in_bAntriebseinheitUnten,
                               PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );

      IF ( tonTimeoutSenken.Q ) THEN
        out_bAntriebseinheitSenken := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        stepSenken := STEP_900_E;
      END_IF

(* SENKEN =====================*)
    STEP_900_E:
      bpFehler := TRUE;

(* SENKEN =====================*)
    STEP_1000_E:
      bpDone := TRUE;

(* SENKEN =====================*)
  END_CASE
END_IF

IF ( NOT bpSenken ) THEN

  IF (stepSenken > STEP_0_E) THEN
    bpDone := FALSE;
    out_bAntriebseinheitSenken     := FALSE;    
    out_bAntriebseinheitEntriegeln := FALSE;
    
    tonTimeoutSenken( IN := FALSE );
    tonTimeoutEntriegeln( IN := FALSE );
    tonTimeoutVerriegeln( IN := FALSE );
    
    stepSenken := STEP_0_E;
  END_IF

END_IF
END_ACTION