(* METADATA
{
	"v3Meta": {
		"objectGuid": "4a671982-396e-400b-83b3-877cfdb4acd7"
	}
}
*)
FUNCTION_BLOCK Kipptisch_Kippen_Restezufuehrung_FB EXTENDS Kipptisch_Kippen_FB
VAR_INPUT
   // BAUSTEINE
  Antriebseinheit : Antriebseinheit_Pneumatik_FB;
END_VAR
VAR_OUTPUT
END_VAR
VAR
  
END_VAR

(***************************************************************************************************)
(* MASTER AUFRUFEN *)
(***************************************************************************************************)
SUPER^();

// Pneumatik Antriebseinheit
Antriebseinheit( bpAktivieren := TRUE );

(***************************************************************************************************)
(* IO ZUWEISUNG *)
(***************************************************************************************************)
Antriebseinheit.in_bAntriebseinheitUnten      := Antrieb.udipEingaengeUmrichter.cXG37_3_I_5;
Antriebseinheit.in_bAntriebseinheitOben       := Antrieb.udipEingaengeUmrichter.cXG37_4_I_6;
Antriebseinheit.in_bAntriebseinheitVerriegelt := Antrieb.udipEingaengeUmrichter.cXG37_5_I_7;
Antriebseinheit.in_bAntriebseinheitEntriegelt := Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;


(***************************************************************************************************)
(* FREIGABEN UND BAUSTEINAUFRUFE *)
(***************************************************************************************************)
// AufrufAntrieb
Antrieb.bpFreigabe        :=    ( bpFreigabe 
                              AND bpVerfahrFreigabe
                              AND Antriebseinheit.bpFreigabeKippen
                              AND toflReglerFreigabeErhalten.Q );
END_FUNCTION_BLOCK