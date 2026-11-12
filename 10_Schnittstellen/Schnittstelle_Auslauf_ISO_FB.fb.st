(* METADATA
{
	"v3Meta": {
		"objectGuid": "159241df-4e26-44a3-b242-7f4886765264"
	}
}
*)
FUNCTION_BLOCK Schnittstelle_Auslauf_ISO_FB EXTENDS Basic_Schnittstelle_FB_V01_00_00

VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR

  // STEPS
  steplStartIsolinie       : Steps_TE;

  // TRIGGER
  rtlAutomatik             : R_TRIG;
  rtlGlasAbruf             : R_TRIG;
  ftlGlasAbruf             : F_TRIG;

END_VAR

VAR_INPUT

  // HARDWARE EINGAENGE
  in_bGlasAbruf                 AT%I* : BOOL; // Signal von ISO-Linie
  in_bTransportRueckwaerts      AT%I* : BOOL; // Signal von ISO-Linie

  // ANALOGWERT
  in_wAnalogwertISOLinie        AT%I* : WORD; // Geschwindigkeit von der ISO-Linie

END_VAR

//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Schnittstelle deaktiviert (MK bDeaktivieren): Baustein verlassen (Ausgaenge schaltet der Basis-Baustein ab)
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
CASE BasisStationsParameter.stMKs.stFremdanlage.eTypSchnittstelle OF

  //eGlaston:
  //  Glaston_Schnittstelle();

  eLISEC:
    Lisec_Schnittstelle();

  eFOREL:
    Forel_Schnittstelle();

  eHEGLA_SJ:
    Hegla_SJ_Schnittstelle();

END_CASE

// Meldung: Glas bereit, aber kein Abruf durch die Fremdanlage
Meldungen();

// Glaettung der Geschwindigkeit zur Sortierung
M_GeschwindigkeitGlaetten( rpMindestGeschwindigkeitsAenderung   := BasisStationsParameter.stMKs.stFremdanlage.rMindestGeschwindigkeitsAenderung,
                           tpMindestZeitZwischenGeschwAenderung := BasisStationsParameter.stMKs.stFremdanlage.tMindestZeitZwischenGeschwAenderung );

IF BasisStationsParameter.stMKs.stFremdanlage.bStationStatusZuGlasAbruf THEN
  Status_ISO_Linie();
END_IF

IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
  Signal_Logger();
END_IF
END_FUNCTION_BLOCK