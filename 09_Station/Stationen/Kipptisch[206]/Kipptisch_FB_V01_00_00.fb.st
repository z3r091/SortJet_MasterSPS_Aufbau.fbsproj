(* METADATA
{
  "v3Meta": {
    "objectGuid": "c4c0d694-747f-463e-8b4c-1bee289d6be3"
  }
}
*)
FUNCTION_BLOCK Kipptisch_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00

VAR

  // BOOL  
  blStartePositionWaagerecht           : BOOL;
  blStartePositionSenkrecht            : BOOL; 
  blBewegungAbgeschlossen              : BOOL; 
  blUpdateTimer                        : BOOL; 
  blZielPositionErreicht               : BOOL; // Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm]

  blOption_Eintransport_Aufgekippt     : BOOL;
  blOption_Austransport_Aufgekippt     : BOOL;
  
  // TRIGGER 
  ftlGlastransportCheckMitNachfolger   : F_TRIG;
                                      
  // TIMER      
  tonlUpdateTimer                      : TON; // Verfahrlogik                       
                                      
  //  STEPS   
  steplKippenSenkrecht     : Steps_TE;
  steplKippenWaagerecht    : Steps_TE;
  
  // BAUSTEINE
  Glastransport  : Kipptisch_Glastransport_FB_V01_00_00;
  Rollenleiste   : Rollenleiste_FB_V01_00_00;
  Querfahrt      : Querfahrt_FB_V01_00_00;
  Kippen         : Kipptisch_Kippen_FB_V01_00_00;
  
END_VAR

//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);


//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// AUFRUFE
//-------------------------------------------------------------------------------------------------
Vortransport();
Eintransport();
Austransport();
Systemcheck();
Messkopplung();
Reset();
Referenz();
Handfunktionen();
A_Timer();
A_Aufrufe();
Kippen_PositionSenkrecht();
Positionieren();
Kippen_PositionWaagerecht();

//-------------------------------------------------------------------------------------------------
// KONFIG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bestimmen der Ein- Aus- Transport Position [KIPPEN]
*)
IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bGLasUebernahmeSenkrecht ) THEN
  blOption_Eintransport_Aufgekippt := TRUE;
  blOption_Austransport_Aufgekippt := FALSE;

ELSE
  blOption_Eintransport_Aufgekippt := FALSE;
  blOption_Austransport_Aufgekippt := TRUE;

END_IF

// Ohne Querfahrt ist die Zielposition immer erreicht
blZielPositionErreicht := (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt
                            OR  ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz ) 
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );
END_FUNCTION_BLOCK