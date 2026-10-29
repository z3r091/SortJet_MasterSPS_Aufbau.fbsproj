(* METADATA
{
	"v3Meta": {
		"objectGuid": "635376ef-0b43-45f8-aefb-954fe07363f7"
	}
}
*)
ACTION Heben
(***************************************************************************************************)
(* AKTION: HEBEN *)
(***************************************************************************************************)
IF ( bpHeben 
  AND NOT bpSenken )
THEN
  
  CASE stepHeben OF
(* HEBEN =====================*)
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
      *)
      bpDone := FALSE;
      
      tonWartenVerriegeln( In := FALSE );
      tonWartenEntriegeln( IN := FALSE );

      IF ( NOT in_bAntriebseinheitOben 
        OR NOT in_bAntriebseinheitVerriegelt )
      THEN
        tonTimeoutHeben(IN := FALSE);
        stepHeben := STEP_10_E;
      ELSE
        stepHeben := STEP_1000_E;
      END_IF
      
(* HEBEN =====================*)
    STEP_10_E:
      (* Hinweis:
         - Verriegelung einfahren
      *)
      out_bAntriebseinheitEntriegeln := TRUE;
        
      tonWartenEntriegeln( IN := in_bAntriebseinheitEntriegelt, PT := T#500MS);
      IF ( tonWartenEntriegeln.q ) THEN
        out_bAntriebseinheitEntriegeln := FALSE;
        stepHeben := STEP_20_E;
      END_IF
     
      // Fehlerbehandlung:
      tonTimeoutEntriegeln( IN := NOT in_bAntriebseinheitEntriegelt,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      
      IF ( tonTimeoutEntriegeln.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        stepHeben := STEP_900_E;
      END_IF
            
(* HEBEN =====================*)
    STEP_20_E:
      (* Hinweis:
         - Antriebseinheit heben
      *)
      out_bAntriebseinheitHeben := TRUE;
     
      tonWartenVerriegeln( In := in_bAntriebseinheitOben, PT := T#500MS);
      IF ( tonWartenVerriegeln.Q ) THEN
        out_bAntriebseinheitHeben := FALSE;
        stepHeben := STEP_30_E;
      END_IF

      // Fehlerbehandlung:
      tonTimeoutHeben( IN := NOT in_bAntriebseinheitOben,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );

      IF ( tonTimeoutHeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        stepHeben := STEP_900_E;
      END_IF
      
(* HEBEN =====================*)
    STEP_30_E:
      (* Hinweis:
         - Verriegelung ausfahren
      *)
      out_bAntriebseinheitVerriegeln := TRUE;
        
      IF ( in_bAntriebseinheitVerriegelt ) THEN
        out_bAntriebseinheitVerriegeln := FALSE;
        stepHeben := STEP_1000_E;
      END_IF
     
      // Fehlerbehandlung:
      tonTimeoutVerriegeln( IN := NOT in_bAntriebseinheitVerriegelt,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      
      IF ( tonTimeoutVerriegeln.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        stepHeben := STEP_900_E;
      END_IF
      
(* HEBEN =====================*)
    STEP_900_E:
      out_bAntriebseinheitHeben      := FALSE;
      out_bAntriebseinheitEntriegeln := FALSE;
      out_bAntriebseinheitVerriegeln := FALSE;
      
      bpFehler := TRUE;

(* HEBEN =====================*)
    STEP_1000_E:
      bpDone := TRUE;

(* HEBEN =====================*)
  END_CASE
END_IF

IF ( NOT bpHeben ) THEN

  IF ( stepHeben > STEP_0_E) THEN
    bpDone := FALSE;
    
    out_bAntriebseinheitHeben      := FALSE;
    out_bAntriebseinheitEntriegeln := FALSE;
    out_bAntriebseinheitVerriegeln := FALSE;
    
    tonTimeoutHeben( IN := FALSE );
    tonTimeoutEntriegeln( IN := FALSE );
    tonTimeoutVerriegeln( IN := FALSE );

    stepHeben := STEP_0_E;
  END_IF

END_IF
END_ACTION