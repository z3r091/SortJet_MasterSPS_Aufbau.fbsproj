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
  blAktionImFehler                     : BOOL; // Eine der wandweisen Aktionen steht im Fehler

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
  Rollenleiste   : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Querfahrt      : Querfahrt_FB_V01_00_00;
  Kippen         : Kippen_FB_V01_00_00;

  (* Hinweis:
     - Der Kipptisch hat keinen Hub, keine Wandverstellung und kein Geblaese, der Eintransport erwartet
       die Bausteine aber. Die Instanzen bleiben deaktiviert (bpAktivieren wird nie gesetzt)
  *)
  HubUnbenutzt             : Hub_FB_V01_00_00;
  WandverstellungUnbenutzt : ZylinderPneumatik_3Wege_FB_V01_00_00;
  GeblaeseUnbenutzt        : Geblaese_Schuetz_FB_V01_00_00;

  // AKTIONEN (WANDWEISE)
  Vortransport   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Vortransport_FB_V01_00_00;
  Eintransport   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Eintransport_FB_V01_00_00;
  Austransport   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Austransport_FB_V01_00_00;
  Durchtransport : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Durchtransport_FB_V01_00_00;
  Messkopplung   : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Messkopplung_FB_V01_00_00;

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
// AUFRUFE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Automatik-Aktionen je Wand
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Vortransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport );

  Eintransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := TRUE,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport,
                         Kippen                 := Kippen,
                         Hub                    := HubUnbenutzt,
                         Roellchenleiste        := Rollenleiste,
                         Wandverstellung        := WandverstellungUnbenutzt,
                         Geblaese               := GeblaeseUnbenutzt );

  Austransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := TRUE,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport,
                         Kippen                 := Kippen,
                         Hub                    := HubUnbenutzt,
                         Geblaese               := GeblaeseUnbenutzt );

  Durchtransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                           wWand                  := wlIndex,
                           bpAutomatikAktiv       := blBetriebsartAutomatik,
                           bpGeblaeseAktiv        := TRUE,
                           bpZielPositionErreicht := blZielPositionErreicht,
                           Glastransport          := Glastransport,
                           Hub                    := HubUnbenutzt );
END_FOR

Systemcheck();

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Messkopplung[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := TRUE,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport,
                         Kippen                 := Kippen,
                         Hub                    := HubUnbenutzt,
                         Roellchenleiste        := Rollenleiste,
                         Wandverstellung        := WandverstellungUnbenutzt );
END_FOR

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