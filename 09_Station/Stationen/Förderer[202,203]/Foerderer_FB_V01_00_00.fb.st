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
  blAktionImFehler                : BOOL; // Eine der wandweisen Aktionen steht im Fehler
  blZielPositionErreicht          : BOOL; // Ueberpruefung ob die Zielposition aus dem Auftrag mit der aktuellen Position uebereinstimmt [Abweichung + - 1mm]

  // HARDWARE EINGAENGE
  in_bSensorNicht84Grad           : BOOL;
  in_bSensorNicht90Grad           : BOOL;
  in_bDurchgangBelegt             : BOOL;
    
  // TRIGGER 
  rtlAutomatikActiv               : R_TRIG;

  // TIMER 
  tonlUpdateTimer                 : TON; // Verfahrlogik

  // BAUSTEINE
  Glastransport                   : Foerderer_Glastransport_FB_V01_00_00;
  Geblaese                        : Geblaese_Schuetz_FB_V01_00_00;
  Kippen                          : Kippen_FB_V01_00_00;
  Hub                             : Hub_FB_V01_00_00;
  Roellchenleiste                 : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Wandverstellung                 : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Querfahrt                       : Querfahrt_FB_V01_00_00;

  // AKTIONEN (WANDWEISE)
  Eintransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Eintransport_FB_V01_00_00;
  Austransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Austransport_FB_V01_00_00;
  Durchtransport                  : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Durchtransport_FB_V01_00_00;
  Vortransport                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Vortransport_FB_V01_00_00;
  Messkopplung                    : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Basic_Station_Messkopplung_FB_V01_00_00;

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

(* Hinweis:
   - Automatik-Aktionen je Wand
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Eintransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport,
                         Kippen                 := Kippen,
                         Hub                    := Hub,
                         Roellchenleiste        := Roellchenleiste,
                         Wandverstellung        := Wandverstellung,
                         Geblaese               := Geblaese );

  Vortransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport );

  Austransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport,
                         Kippen                 := Kippen,
                         Hub                    := Hub,
                         Geblaese               := Geblaese );

  Durchtransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                           wWand                  := wlIndex,
                           bpAutomatikAktiv       := blBetriebsartAutomatik,
                           bpGeblaeseAktiv        := blGeblaeseAktiv,
                           bpZielPositionErreicht := blZielPositionErreicht,
                           Glastransport          := Glastransport,
                           Hub                    := Hub );

  Messkopplung[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         bpZielPositionErreicht := blZielPositionErreicht,
                         Glastransport          := Glastransport,
                         Kippen                 := Kippen,
                         Hub                    := Hub,
                         Roellchenleiste        := Roellchenleiste,
                         Wandverstellung        := Wandverstellung );
END_FOR

Reset();
Handfunktionen();
Positionieren();


// Ohne Querfahrt ist die Zielposition immer erreicht
blZielPositionErreicht := (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt
                            OR  ( ABS( BasisStationsParameter.rAktuellePositionQuerfahrt - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz )
                            OR  ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition - argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] ) <= rgMKZielPositionToleranz ) 
                            OR  ( ABS(ABS(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition) - ABS(BasisStationsParameter.rAktuellePositionQuerfahrt) ) <= rgMKZielPositionToleranz ) );
END_FUNCTION_BLOCK