(* METADATA
{
	"v3Meta": {
		"objectGuid": "f398e717-0dce-40bc-90e9-88259e087e99"
	}
}
*)
FUNCTION VisuAv_Zahl : STRING(40)
VAR_INPUT
  rWert       : REAL;
  uiNachkomma : UINT := 1; // 0..3 Nachkommastellen
  sEinheit    : STRING(12);
END_VAR
VAR
  diFaktor : DINT;
  diWert   : DINT;
  diGanz   : DINT;
  diRest   : DINT;
  sRest    : STRING(10);
END_VAR
// Zahl gerundet mit fester Anzahl Nachkommastellen (Dezimalpunkt) und Einheit
CASE MIN( uiNachkomma, 3 ) OF
  0: diFaktor := 1;
  1: diFaktor := 10;
  2: diFaktor := 100;
  3: diFaktor := 1000;
END_CASE

diWert := REAL_TO_DINT( rWert * DINT_TO_REAL( diFaktor ) );
diGanz := ABS( diWert ) / diFaktor;
diRest := ABS( diWert ) MOD diFaktor;

VisuAv_Zahl := DINT_TO_STRING( diGanz );
IF ( diWert < 0 ) THEN
  VisuAv_Zahl := CONCAT( '-', VisuAv_Zahl );
END_IF

IF ( diFaktor > 1 ) THEN
  sRest := DINT_TO_STRING( diRest + diFaktor ); // fuehrende Nullen ueber die vorangestellte 1
  VisuAv_Zahl := CONCAT( CONCAT( VisuAv_Zahl, '.' ), DELETE( sRest, 1, 1 ) );
END_IF

VisuAv_Zahl := CONCAT( VisuAv_Zahl, sEinheit );
END_FUNCTION