(* METADATA
{
	"v3Meta": {
		"objectGuid": "bd924e48-93d5-4f05-bff1-59051efc4e7c"
	}
}
*)
FUNCTION GlasGewichtErmitteln : REAL
VAR_INPUT

  // REAL
  rpGlaslaenge  : REAL := REAL#0; // [mm] -> Wert in mm
  rpGlasbreite  : REAL := REAL#0; // [mm] -> Wert in mm
  rpGlasstaerke : REAL := REAL#0; // [mm] -> Wert in mm

END_VAR
VAR

  // REAL
  rlErgebnis : REAL := REAL#0;
  rlLaenge   : REAL := REAL#0; // [mm] -> Wert in dm [UMRECHNUNG]
  rlBreite   : REAL := REAL#0; // [mm] -> Wert in dm [UMRECHNUNG]
  rlStaerke  : REAL := REAL#0; // [mm] -> Wert in dm [UMRECHNUNG]

END_VAR

VAR CONSTANT

  // WORD
  cUMRECHNUNG_MM_IN_DM      : REAL := 100.0;

  // REAL
  cSPEZIFISCHES_GLASGEWICHT : REAL := REAL#2.5; //IN kg/dm³

END_VAR

 
rlErgebnis := REAL#0;

rlLaenge  := rpGlaslaenge / cUMRECHNUNG_MM_IN_DM;
rlBreite  := rpGlasbreite / cUMRECHNUNG_MM_IN_DM;
rlStaerke := rpGlasstaerke/ cUMRECHNUNG_MM_IN_DM;


GlasGewichtErmitteln := ( ( rlLaenge * rlBreite * rlStaerke ) ) * cSPEZIFISCHES_GLASGEWICHT;
END_FUNCTION