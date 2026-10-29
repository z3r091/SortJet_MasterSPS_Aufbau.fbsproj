(* METADATA
{
	"v3Meta": {
		"objectGuid": "f09c33db-7a20-4b90-8ead-5fa591e68102"
	}
}
*)
ACTION LED_Steuerung
(***************************************************************************************************)
(* AKTION LED_Steuerung *)
(***************************************************************************************************)
(* 
Hinweise
 - Die ansteuerung der LEDS erfolgt hier und wird nur über die 3 BITs gesteuert
 - Die Ansteuerung der LEDs gestalltet sich wie folgt
 - MMI Button schlatet die einzelnen Stufen durch

 ilDimmstufe | Dimmstufe % | BIT 2 (Pin 5) | BIT 1 (Pin 4) | BIT 0 (Pin 2)
 ------------|-------------|---------------|---------------|--------------
  0          |0            | 0             | 1             | 0
  1          |40           | 0             | 1             | 1
  2          |50           | 1             | 1             | 1
  3          |60           | 1             | 1             | 0
  4          |70           | 0             | 0             | 1
  5          |80           | 1             | 0             | 1
  6          |90           | 1             | 0             | 0
  7          |100          | 0             | 0             | 0
*)

rtlTasterDimmstufe(CLK:= dwlHandfunktionen.25);// Mit MMI absprechen welches bis da im endeffekt gesetzt wird
// Kontrollieren evtl. Drehen
IF rtlTasterDimmstufe.Q AND (ilDimmstufe = 7) THEN
  ilDimmstufe := 0;
ELSE
  ilDimmstufe := ilDimmstufe + 1;
END_IF

CASE ilDimmstufe OF
  0:
    // 0%
    out_bLeuchtsignalBIT_0 := FALSE; 
    out_bLeuchtsignalBIT_1 := TRUE;
    out_bLeuchtsignalBIT_2 := FALSE;
  1:
    // 40%
    out_bLeuchtsignalBIT_0 := TRUE; 
    out_bLeuchtsignalBIT_1 := TRUE;
    out_bLeuchtsignalBIT_2 := FALSE;
  2:
    // 50%
    out_bLeuchtsignalBIT_0 := TRUE; 
    out_bLeuchtsignalBIT_1 := TRUE;
    out_bLeuchtsignalBIT_2 := TRUE;
  3:
    // 60%
    out_bLeuchtsignalBIT_0 := FALSE; 
    out_bLeuchtsignalBIT_1 := TRUE;
    out_bLeuchtsignalBIT_2 := TRUE;
  4:
    // 70%
    out_bLeuchtsignalBIT_0 := TRUE; 
    out_bLeuchtsignalBIT_1 := FALSE;
    out_bLeuchtsignalBIT_2 := FALSE;
  5:
    // 80%
    out_bLeuchtsignalBIT_0 := TRUE; 
    out_bLeuchtsignalBIT_1 := FALSE;
    out_bLeuchtsignalBIT_2 := TRUE;
  6:
    // 90%
    out_bLeuchtsignalBIT_0 := FALSE; 
    out_bLeuchtsignalBIT_1 := FALSE;
    out_bLeuchtsignalBIT_2 := TRUE;
  7:
    // 100%
    out_bLeuchtsignalBIT_0 := FALSE; 
    out_bLeuchtsignalBIT_1 := FALSE;
    out_bLeuchtsignalBIT_2 := FALSE;
  
  
END_CASE
END_ACTION