(* METADATA
{
	"v3Meta": {
		"objectGuid": "9d767b72-d5d2-41dd-bf85-6fed179b78ea"
	}
}
*)
FUNCTION_BLOCK Drehstation_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00

VAR_INPUT

END_VAR

VAR_OUTPUT

  // BOOLEAN
  bpVorabDrehenAktiv                 : BOOL;

END_VAR
VAR

  // BOOLEAN
  blGeblaeseAktiv                    : BOOL;
  blUpdateTimer                      : BOOL;
  blAktionImFehler                   : BOOL; // Eine der wandweisen Aktionen steht im Fehler

  // TRIGGER
  rtlAutomatikActiv                  : R_TRIG;
  ftlGlastransportCheckMitNachfolger : F_TRIG;

  // TIMER
  toflGeblaeseHandfahren             : TOF;
  tonlUpdateTimer                    : TON;

  // STEPS
  steplVorabDrehen                   : Steps_TE; // Drehen
  steplPositionierungQuerfahrt       : Steps_TE; // Querfahrt

  // BAUSTEINE
  Glastransport                      : Drehstation_Glastransport_FB_V01_00_00;
  Drehen                             : Drehstation_Drehen_FB_V01_00_00;
  Kippen                             : Kippen_FB_V01_00_00;
  Querfahrt                          : Querfahrt_FB_V01_00_00;
  Geblaese                           : Geblaese_Schuetz_FB_V01_00_00;
  Dickenverstellung                  : ZylinderPneumatik_3Wege_FB_V01_00_00;
  Querachse                          : ZylinderPneumatik_3Wege_FB_V01_00_00;

  // AKTIONEN (WANDWEISE)
  Eintransport                       : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Drehstation_Eintransport_FB_V01_00_00;
  Austransport                       : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Drehstation_Austransport_FB_V01_00_00;
  Vortransport                       : ARRAY[cWAND_1..cANZAHL_WAENDE] OF Drehstation_Vortransport_FB_V01_00_00;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bMotorstarter_Geblaese_OK : BOOL;
  in_bSensorNicht84Grad        : BOOL;
  in_bSensorNicht90Grad        : BOOL;



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

(* Hinweis:
   - Pruefen und ggf. bereinigen der Station
*)
SystemCheck();
IO_Zuweisung();

(* Hinweis:
   - -Automatik- Aktionen
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Eintransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         bpVorabDrehenAktiv     := bpVorabDrehenAktiv,
                         Glastransport          := Glastransport,
                         Drehen                 := Drehen,
                         Kippen                 := Kippen,
                         Querfahrt              := Querfahrt,
                         Geblaese               := Geblaese,
                         Dickenverstellung      := Dickenverstellung,
                         Querachse              := Querachse );

  Austransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         bpVorabDrehenAktiv     := bpVorabDrehenAktiv,
                         Glastransport          := Glastransport,
                         Drehen                 := Drehen,
                         Kippen                 := Kippen,
                         Querfahrt              := Querfahrt,
                         Geblaese               := Geblaese,
                         Dickenverstellung      := Dickenverstellung,
                         Querachse              := Querachse );
END_FOR

VorabDrehen();

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Vortransport[wlIndex]( BasisStationsParameter := BasisStationsParameter,
                         wWand                  := wlIndex,
                         bpAutomatikAktiv       := blBetriebsartAutomatik,
                         bpGeblaeseAktiv        := blGeblaeseAktiv,
                         Glastransport          := Glastransport,
                         Drehen                 := Drehen );
END_FOR

QuerfahrtPositionieren();

(* Hinweis:
   - Basis- Aktion
*)
A_Aufrufe();
A_Geblaese();
A_Timer();
Reset();
Referenz();
Handfunktionen();
END_FUNCTION_BLOCK