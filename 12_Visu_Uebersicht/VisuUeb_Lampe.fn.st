(* METADATA
{
	"v3Meta": {
		"objectGuid": "b7aa09e8-5cde-43cf-b09b-dc0ab15a15f2"
	}
}
*)
FUNCTION VisuUeb_Lampe : BOOL
VAR_IN_OUT
  stLampe   : VisuUeb_Lampe_ST;
END_VAR
VAR_INPUT
  sText     : STRING(40);
  bOK       : BOOL;   // TRUE = gruen
  bWarnung  : BOOL := FALSE; // bei NOT bOK: TRUE = orange, FALSE = rot
  bNeutral  : BOOL := FALSE; // TRUE = grau (inaktiv, keine Bewertung)
END_VAR
stLampe.sText := sText;
IF bNeutral THEN
  stLampe.dwFarbe := VISU_UEBERSICHT.cFARBE_GRAU;
ELSIF bOK THEN
  stLampe.dwFarbe := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSIF bWarnung THEN
  stLampe.dwFarbe := VISU_UEBERSICHT.cFARBE_ORANGE;
ELSE
  stLampe.dwFarbe := VISU_UEBERSICHT.cFARBE_ROT;
END_IF
VisuUeb_Lampe := bOK;
END_FUNCTION