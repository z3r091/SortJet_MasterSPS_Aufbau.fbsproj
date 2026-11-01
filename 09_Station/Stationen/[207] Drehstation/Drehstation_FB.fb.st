(* METADATA
{
  "v3Meta": {
    "objectGuid": "9d767b72-d5d2-41dd-bf85-6fed179b78ea"
  }
}
*)
FUNCTION_BLOCK Drehstation_FB EXTENDS Basic_Station_FB

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
 
  // TRIGGER
  rtlAutomatikActiv                  : R_TRIG;
  ftlGlastransportCheckMitNachfolger : F_TRIG;

  // TIMER
  toflGeblaeseEnergiesparModus       : TOF; 
  toflGeblaeseHandfahren             : TOF;
  tonlUpdateTimer                    : TON;

  // STEPS  
  steplVorabDrehen                   : Steps_TE; // Drehen
  steplPositionierungQuerfahrt       : Steps_TE; // Querfahrt

  // BAUSTEINE 
  Glastransport                      : Drehstation_Glastransport_FB;
  Drehen                             : Drehstation_Drehen_FB;
  Kippen                             : Kippen_FB;
  Querfahrt                          : Querfahrt_FB;
  Geblaese                           : Geblaese_Schuetz_FB;
  Dickenverstellung                  : ZylinderPneumatik_3Wege_FB;
  Querachse                          : ZylinderPneumatik_3Wege_FB;

END_VAR
VAR

  // HARDWARE EINGAENGE
  in_bMotorstarter_Geblaese_OK : BOOL;



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
Eintransport();
Austransport();
VorabDrehen();
Vortransport();
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