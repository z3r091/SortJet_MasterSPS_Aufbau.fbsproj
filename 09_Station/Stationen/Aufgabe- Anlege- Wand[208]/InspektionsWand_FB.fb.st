(* METADATA
{
	"v3Meta": {
		"objectGuid": "7650e038-244c-432f-8d1f-f46eb566ccbc"
	}
}
*)
FUNCTION_BLOCK InspektionsWand_FB EXTENDS AnlegeAbnahmeWand_FB

VAR_INPUT
  

END_VAR

VAR
  // BOOL
  blGlasBruchMeldungSperren :BOOL;  


  //Int
	ilDimmstufe       : INT := 0;// TODO gucken welche Dimmstufe aus ist
  
  // Trigger
                  
  rtlTasterDimmstufe                    : R_TRIG;
  rtlTasterGlasbruch                    : R_TRIG;
  rtlGlasBruchSperren                   : R_TRIG;
  rtlTasterGlasInspiziert               : R_TRIG;
  
  // Timer
  tonlTasterGlasbruch                   : TON;
  tonlTasterGlasInspiziert              : TON;
  toflZeitlicheSperrungGlasbruch        : TOF;
  
  //Input
  
    in_b24VNetzteilLEDs_OK          AT %I* :BOOL;
    in_b24VSammelsicherungLEDs_OK   AT %I* :BOOL;
  
END_VAR

VAR CONSTANT


  // TIME
  ZEIT_GEBLASE_FREIGABE_AUSSCHALTEN             : TIME := T#4000MS;  (* Zeit ab wann das Geblaese ueber den Taster ausgeschaltet werden kann, nach dem der Ausgang <<Geblaese ein>> gesetzt wurde *)
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASBRUCH       : TIME := T#200ms;
  ZEITLICHE_VERZOEGERUNG_TASTER_GLASABGENOMMEN  : TIME := T#200ms;
  ZEITLICHE_SPERRUNG_TASTER_GLASBRUCH           : TIME := T#2s;

END_VAR
(***************************************************************************************************)
(* MASTER AUFRUFEN *)
(***************************************************************************************************)
SUPER^(BasisStationsParameter := BasisStationsParameter);

Abnehmen();
LED_Steuerung();
Taster();
Meldungen();
END_FUNCTION_BLOCK