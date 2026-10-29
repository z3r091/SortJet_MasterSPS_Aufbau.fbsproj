(* METADATA
{
	"v3Meta": {
		"objectGuid": "e6df45be-9420-4e9c-b3d7-0cda7a835d19"
	}
}
*)
FUNCTION_BLOCK Foerderer_FB  EXTENDS Basic_Station_FB

VAR
 
  // BOOLEAN 
  blGeblaeseAktiv                 : BOOL;
  bDurchgangBelegt                : BOOL;
  blUpdateTimer                   : BOOL; 
  blZielPositionErreicht          : BOOL; // Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm]
    
  // TRIGGER 
  rtlAutomatikActiv               : R_TRIG;

  // TIMER 
  toflGeblaeseEnergiesparModus    : TOF;
  atonlUeberwachungEintransport   : TON; 
  tonlUpdateTimer                 : TON; // Verfahrlogik     

  // BAUSTEINE
  Glastransport                   : Foerderer_Glastransport_FB;
  Geblaese                        : Geblaese_Schuetz_FB;
  Kippen                          : Kippen_FB;
  Hub                             : Hub_FB;
  Roellchenleiste                 : ZylinderPneumatik_3Wege_FB;
  Wandverstellung                 : ZylinderPneumatik_3Wege_FB;
  Querfahrt                       : Querfahrt_FB;

END_VAR

VAR CONSTANT

  (* TIME *)
  ZEIT_UEBERWACHUNG_EINZELSCHRITT  : TIME := T#15s;

END_VAR


(***************************************************************************************************)
(* MASTER AUFRUFEN *)
(***************************************************************************************************)
SUPER^(BasisStationsParameter := BasisStationsParameter);

(***************************************************************************************************)
(* DEAKTIVIEREN *)
(***************************************************************************************************)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  RETURN;
END_IF



(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
A_Aufrufe();
A_Geblaese();

IO_Zuweisung();

SystemCheck();
Eintransport();
Vortransport();
Austransport();
Durchtransport();
Messkopplung();
Reset();
Handfunktionen();
Positionieren();


blZielPositionErreicht := (     ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz ) 
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );
END_FUNCTION_BLOCK