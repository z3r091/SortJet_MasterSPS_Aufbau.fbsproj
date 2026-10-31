(* METADATA
{
  "v3Meta": {
    "objectGuid": "530c17d7-3762-455b-8431-d2a354444d9d"
  }
}
*)
FUNCTION_BLOCK ZylinderPneumatik_3Wege_FB
VAR_INPUT

  (* BOOLEAN *)
  blErsterZyklus              : BOOL;
  bpAktivieren                : BOOL;
  bpStartPneumatik            : BOOL; (* Starten der Zylinder *)
  bpReset                     : BOOL; (* BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt *)
  bpZylinderAbfragenVorhanden : BOOL := TRUE; (* Hinweis: Manche Zylinder haben keine Abfragen *)
  bpEinAusFahrenLogikDrehen   : BOOL := FALSE; (* Hinweis: Manche Zylinder haben keine Abfragen *)

  (* ENUM *)
  epOeffnungsStellung  : PneumatikZylinderStatus_EN;

END_VAR

VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler                       : BOOL;
  bpDone                         : BOOL;

  (* WORD *)
  wpFehlerNr                     : WORD;

  (* ENUM *)
  wpStatusZylinder               : PneumatikZylinderStatus_EN;

END_VAR
VAR

  (* HARDWARE EINGAENGE *)
  in_bStatusZylinder1Ausgefahren   AT %I* : BOOL; (* STATUS: Sensor meldet ausgfahren   *)
  in_bStatusZylinder1Eingefahren   AT %I* : BOOL; (* STATUS: Sensor meldet eingefahren  *)
  in_bStatusZylinder2Ausgefahren   AT %I* : BOOL; (* STATUS: Sensor meldet ausgfahren   *)
  in_bStatusZylinder2Eingefahren   AT %I* : BOOL; (* STATUS: Sensor meldet eingefahren  *)

  (* HARDWARE AUSGAENGE *)
  out_bZylinder1Ausfahren   AT %Q* : BOOL; (* AKTION: Zylinder 1 ausfahren *)
  out_bZylinder1Einfahren   AT %Q* : BOOL; (* AKTION: Zylinder 1 einfahren *)
  out_bZylinder2Ausfahren   AT %Q* : BOOL; (* AKTION: Zylinder 2 ausfahren *)
  out_bZylinder2Einfahren   AT %Q* : BOOL; (* AKTION: Zylinder 2 einfahren *)

  (* STEPS *)
  steplAusfahren   : Steps_TE;
  steplReset       : Steps_TE;

  (* TIMER *)
  tonlZylinder1Eingefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlZylinder1Ausgefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlZylinder2Eingefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlZylinder2Ausgefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlWarteZeitAufVentile   : TON; (* EINSCHALTVERZOEGERUNG: wenn keine Abfragen verbaut sind, pauschal die Schaltung der Ventile zurücksetzen *)

END_VAR
(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus  ) THEN
  blErsterZyklus := FALSE;
  epOeffnungsStellung := eZylinderStellung16mm;
END_IF


IF bpReset THEN
  
  Reset();

ELSE

 IF ( bpAktivieren ) THEN
    (***************************************************************************************************)
    (* AKTIONEN *)
    (***************************************************************************************************)
    AusEinFahren();
    
    (***************************************************************************************************)
    (* AUSGAENGE *)
    (***************************************************************************************************)
    
    (* Ausgang:
       - Status der Zylinders
         => Ausgefahren
         => Eingefahren
         => Undefiniert
    *)
    wpStatusZylinder := eZylinderUndefiniert;
    
    
    IF NOT bpZylinderAbfragenVorhanden THEN
     (* dies mit auch als DEMO Mode benutzen, wenn keine Abfargen verbaut sind, dann den Öffnungsstatus zurück spiegeln ..*)
     wpStatusZylinder := epOeffnungsStellung;
    
    ELSIF NOT bpEinAusFahrenLogikDrehen THEN  (* mit Zylinderabfragen *)
    
     IF ( in_bStatusZylinder1Ausgefahren ) THEN
      IF (in_bStatusZylinder2Ausgefahren) THEN
       wpStatusZylinder := eZylinderStellung29mm;
      ELSE
       wpStatusZylinder := eZylinderStellung23mm;
      END_IF
    
     ELSE
      IF (in_bStatusZylinder2Ausgefahren) THEN
       wpStatusZylinder := eZylinderStellung23mm;
      ELSE
       wpStatusZylinder := eZylinderStellung16mm;
      END_IF
     END_IF
    
    ELSE
    
     IF in_bStatusZylinder1Eingefahren THEN
    
      IF (in_bStatusZylinder2Eingefahren) THEN
       wpStatusZylinder := eZylinderStellung29mm;
      ELSE
       wpStatusZylinder := eZylinderStellung23mm;
      END_IF
    
     ELSE
    
      IF (in_bStatusZylinder2Eingefahren) THEN
       wpStatusZylinder := eZylinderStellung23mm;
      ELSE
       wpStatusZylinder := eZylinderStellung16mm;
      END_IF
    
     END_IF
    
    END_IF
  
  ELSE
    bpDone   := TRUE;
    bpFehler := FALSE;
  END_IF

END_IF
END_FUNCTION_BLOCK