(* METADATA
{
	"v3Meta": {
		"objectGuid": "bc9224e8-3686-436c-a267-c47d59964304"
	}
}
*)
FUNCTION_BLOCK Kipptisch_Restezufuehrung_FB EXTENDS Basic_Station_FB

VAR
	
  // BOOL  
  blStartePositionWaagerecht           : BOOL;
  blStartePositionSenkrecht            : BOOL; 
  blBewegungAbgeschlossen              : BOOL; 
  blUpdateTimer                        : BOOL; 
  blZielPositionErreicht               : BOOL; // Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm]
  blGlasBruchMeldungSperren            : BOOL := FALSE;
  
  blOption_Eintransport_Aufgekippt     : BOOL;
  blOption_Austransport_Aufgekippt     : BOOL;
  
  // TRIGGER 
  ftlGlastransportCheckMitNachfolger   : F_TRIG;
  rtlTasterGlasbruch                   : R_TRIG;
  rtlTasterGlasAngelegt                : R_TRIG;
  rtlGlasBruchSperren                  : R_TRIG;
  rtlTasterQuittierung                 : R_TRIG;
                                      
  // TIMER      
  tonlUpdateTimer                      : TON; // Verfahrlogik    
  tonlTasterGlasbruch                  : TON;   
  toflZeitlicheSperrungGlasbruch       : TOF;
  tonlFreigabeErhalten                 : TON; 
  tlZeitBereitAnzulegen                : TIME;                   
                                      
  //  STEPS   
  steplKippenSenkrecht     : Steps_TE;
  steplKippenWaagerecht    : Steps_TE;
  
  // BAUSTEINE
  Glastransport  : Kipptisch_Restezufuehrung_Glastransport_FB;
  Rollenleiste   : Rollenleiste_FB;
  Querfahrt      : Querfahrt_FB;

  // IO's
  in_bTasterGlasAngelegt                   AT %I* : BOOL; 
  in_bTasterGlasbruch                      AT %I* : BOOL;
  in_bKnebelGlastransportZurueck                  : BOOL;
  in_bKnebelGlastransportVor                      : BOOL;
  in_bTasterFehlmessungQuittiern                  : BOOL; // Gelber Leuchtdrucktaster
  out_bSignalTasterScheibeAnlegen          AT %Q* : BOOL; // Weißer Leuchdrucktaster | Scheibe anlegen
  out_bSignalScheibeFehlmessung                   : BOOL;
  out_bAmpelSignalGruen                           : BOOL;
  
  
  
  Kippen         : Kipptisch_Kippen_Restezufuehrung_FB;
  
END_VAR

VAR CONSTANT

// TIME
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH       : TIME := T#200MS;  
  ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH           : TIME := T#2S;
  
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
(* AUFRUFE *)
(***************************************************************************************************)
Vortransport();
Eintransport();
Austransport();
Systemcheck();
Messkopplung();
Glaslaengenmessung();
Reset();
Referenz();
Handfunktionen();
A_Timer();
A_Aufrufe();
Kippen_PositionSenkrecht();
Positionieren();
Kippen_PositionWaagerecht();
Anlegen();
Glasbruch();

(***************************************************************************************************)
(* KONFIG *)
(***************************************************************************************************)
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

blZielPositionErreicht := (     ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz ) 
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );


tonlFreigabeErhalten(IN:= BasisStationsParameter.bFreigabe ,PT:= T#2S);
END_FUNCTION_BLOCK