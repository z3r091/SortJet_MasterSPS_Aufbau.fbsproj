(* METADATA
{
  "v3Meta": {
    "objectGuid": "e6df45be-9420-4e9c-b3d7-0cda7a835d19"
  }
}
*)
FUNCTION_BLOCK Foerderer_FB_V01_00_00  EXTENDS Basic_Station_FB_V01_00_00

VAR
 
  // BOOLEAN 
  blGeblaeseAktiv                 : BOOL;
  blUpdateTimer                   : BOOL;
  blZielPositionErreicht          : BOOL; // Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm]

  // HARDWARE EINGAENGE
  in_bSensorNicht84Grad           : BOOL;
  in_bSensorNicht90Grad           : BOOL;
  in_bDurchgangBelegt             : BOOL;
    
  // TRIGGER 
  rtlAutomatikActiv               : R_TRIG;

  // TIMER 
  toflGeblaeseEnergiesparModus    : TOF;
  atonlUeberwachungEintransport   : TON; 
  tonlUpdateTimer                 : TON; // Verfahrlogik     

  // BAUSTEINE
  Glastransport                   : Foerderer_Glastransport_FB_V01_00_00;
  Geblaese                        : Geblaese_Schuetz_FB_V01_00_00;
  Kippen                          : Kippen_FB_V01_00_00;
  Hub                             : Hub_FB_V01_00_00;
  Roellchenleiste                 : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Wandverstellung                 : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Querfahrt                       : Querfahrt_FB_V01_00_00;

END_VAR

VAR CONSTANT

  // TIME
  ZEIT_UEBERWACHUNG_EINZELSCHRITT  : TIME := T#15s;

END_VAR


//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  HandfunktionenStatus();
  RETURN;
END_IF



//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
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


// Ohne Querfahrt ist die Zielposition immer erreicht
blZielPositionErreicht := (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt
                            OR  ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz ) 
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );
END_FUNCTION_BLOCK