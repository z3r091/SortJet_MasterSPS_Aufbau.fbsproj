(* METADATA
{
  "v3Meta": {
    "objectGuid": "57ebb36f-f22e-4632-9b59-8f205a70f04c"
  }
}
*)
FUNCTION_BLOCK Wandverstellung_MultiZylinder_FB
VAR_INPUT 

  (* BOOLEAN *)
  bpReset                     : BOOL;
  bpAktivieren                : BOOL;
  bpStartZylinderBewegung     : BOOL; (* BETRIEBTYP: Zylinder wird ausgefahren *)
  bpZylinderAbfragenVorhanden : BOOL := FALSE; (* Hinweis: Manche Zylinder haben keine Abfragen *)

  (* ENUM *)
  epSollZylinderStellung  : PneumatikZylinderStatus_EN;

END_VAR

VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler                       : BOOL;
  bpDone                         : BOOL;

  (* WORD *)
  wpFehlerNr       : WORD;

  (* ENUM *)
  epStatusZylinderStellung : PneumatikZylinderStatus_EN;

END_VAR

VAR

  (* STEPS *)
  steplZylinderStellung   : Steps_TE;

  (* TIMER *)
  tonlStellung13mm               : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlStellung23mm               : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlStellung29mm               : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlWartezeitZylinderStellung  : TON; (* EINSCHALTVERZOEGERUNG: wenn keine Abfragen verbaut sind, pauschal die Schaltung der Ventile zurücksetzen *)


END_VAR

VAR

  (* HARDWAREEINGAENGE *)
  in_bStatusZylinder_1_Ausgefahren     AT %I* : BOOL; // STATUS: Zylinderabfrage [Ausgefahren] 
  in_bStatusZylinder_2_Ausgefahren     AT %I* : BOOL; // STATUS: Zylinderabfrage [Ausgefahren] 
  in_bStatusZylinder_Alle_Eingefahren  AT %I* : BOOL; // STATUS: Zylinderabfrage [Eingefahren] 



  (* HARDWAREAUSGAENGE *)
  out_bZylinder_1_Einfahren    AT %Q* : BOOL; (* Impuls Zylinder: x mm Hub *)
  out_bZylinder_2_Einfahren    AT %Q* : BOOL; (* Impuls Zylinder: X mm Hub *)
  out_bZylinder_1_Ausfahren    AT %Q* : BOOL; (* Impuls Zylinder: x mm Hub *)
  out_bZylinder_2_Ausfahren    AT %Q* : BOOL; (* Impuls Zylinder: x mm Hub *)

END_VAR
(***************************************************************************************************)
(* BNAUSTEIN: STEUERUNG *)
(***************************************************************************************************)
IF ( bpReset ) THEN

  bpFehler := FALSE;
  bpDone   := FALSE;

  bpStartZylinderBewegung := FALSE;

  out_bZylinder_1_Einfahren := FALSE;
  out_bZylinder_2_Einfahren := FALSE;
  out_bZylinder_1_Ausfahren := FALSE;
  out_bZylinder_2_Ausfahren := FALSE;

  tonlStellung13mm( IN := FALSE ); 
  tonlStellung23mm( IN := FALSE ); 
  tonlStellung29mm( IN := FALSE ); 
  tonlWartezeitZylinderStellung( IN := FALSE );

  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

ELSE

  IF ( bpAktivieren ) THEN

    // Baustein- Aktionen
    ZylinderBewegung();

    //Status der Zylinder
    epStatusZylinderStellung := eZylinderUndefiniert;

    IF ( NOT bpZylinderAbfragenVorhanden ) THEN
      epStatusZylinderStellung := epSollZylinderStellung;

    ELSE
      // Stellung 29mm
      IF (  in_bStatusZylinder_1_Ausgefahren
        AND NOT in_bStatusZylinder_2_Ausgefahren  ) 
      THEN
        epStatusZylinderStellung := eZylinderStellung29mm;
      
      // Stellung 23mm
      ELSIF ( in_bStatusZylinder_1_Ausgefahren
          AND NOT in_bStatusZylinder_2_Ausgefahren ) 
      THEN
        epStatusZylinderStellung := eZylinderStellung23mm;
		
      // Stellung 13mm
      ELSIF ( in_bStatusZylinder_Alle_Eingefahren
          AND NOT in_bStatusZylinder_1_Ausgefahren
          AND NOT in_bStatusZylinder_2_Ausgefahren ) 
      THEN
        epStatusZylinderStellung := eZylinderStellung16mm;

      END_IF

    END_IF

  ELSE
    bpDone   := TRUE;
    bpFehler := FALSE;

    epStatusZylinderStellung := epSollZylinderStellung;

  END_IF

END_IF
END_FUNCTION_BLOCK