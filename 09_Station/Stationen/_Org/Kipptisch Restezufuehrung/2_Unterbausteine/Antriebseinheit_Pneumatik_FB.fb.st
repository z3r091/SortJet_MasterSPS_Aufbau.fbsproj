(* METADATA
{
	"v3Meta": {
		"objectGuid": "aa71ee51-5acc-4802-93b0-7eb9a9ed8991"
	}
}
*)
FUNCTION_BLOCK Antriebseinheit_Pneumatik_FB
VAR_INPUT

  // BOOLEAN
  bpReset          : BOOL;
  bpAktivieren     : BOOL;
  bpHeben          : BOOL; 
  bpSenken         : BOOL;


  in_bAntriebseinheitOben        : BOOL; 
  in_bAntriebseinheitUnten       : BOOL; 
  in_bAntriebseinheitVerriegelt  : BOOL; 
	in_bAntriebseinheitEntriegelt  : BOOL;


END_VAR
VAR_OUTPUT

  // BOOLEAN 
  bpFehler         : BOOL;
  bpDone           : BOOL;
  bpFreigabeKippen : BOOL;

  // WORD 
  wpFehlerNr       : WORD;

END_VAR
VAR

  // STEPS
  stepHeben        : Steps_TE;
  stepSenken       : Steps_TE;

  // TIMER 
  tonTimeoutSenken      : TON; 
  tonTimeoutHeben       : TON;
  tonTimeoutVerriegeln  : TON;
  tonTimeoutEntriegeln  : TON;
  tonWartenVerriegeln   : TON;
  tonWartenEntriegeln   : TON;

END_VAR
VAR

  // IO's
  out_bAntriebseinheitHeben        AT %Q* : BOOL; 
  out_bAntriebseinheitSenken       AT %Q* : BOOL;
  out_bAntriebseinheitVerriegeln   AT %Q* : BOOL;
  out_bAntriebseinheitEntriegeln   AT %Q* : BOOL;
  

END_VAR
VAR CONSTANT

  // TIME
  cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER : TIME := T#15s;

END_VAR
(***************************************************************************************************)
(* BNAUSTEIN: STEUERUNG *)
(***************************************************************************************************)
IF ( bpReset ) THEN

  bpFehler := FALSE;
  bpDone   := FALSE;
  bpHeben  := FALSE;
  bpSenken := FALSE;
  
  out_bAntriebseinheitHeben      := FALSE;
  out_bAntriebseinheitSenken     := FALSE;
  out_bAntriebseinheitVerriegeln := FALSE;
  out_bAntriebseinheitEntriegeln := FALSE;

  tonTimeoutVerriegeln(IN:=FALSE);
  tonTimeoutEntriegeln(IN:=FALSE);
  tonTimeoutHeben( IN := FALSE );
  tonTimeoutSenken( IN := FALSE );

  stepHeben := STEP_0_E;
  stepSenken := STEP_0_E;

  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

ELSE

  IF ( bpAktivieren ) THEN

    (* Hinweis:
       - Baustein- Aktionen
    *)
    Heben();
    Senken();

    // Der Kipptisch darf nur kippen, wenn die Antriebseinheit oben und verriegekt ist
    bpFreigabeKippen := in_bAntriebseinheitOben and in_bAntriebseinheitVerriegelt;
    
    
    
  ELSE
    bpDone   := TRUE;
    bpFehler := FALSE;

  END_IF

END_IF
END_FUNCTION_BLOCK