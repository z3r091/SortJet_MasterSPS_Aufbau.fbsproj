(* METADATA
{
	"v3Meta": {
		"objectGuid": "5c116975-7ea8-4794-b20d-23cbba1de39f"
	}
}
*)
FUNCTION_BLOCK Schnittstelle_Auslauf_Schneidanlage EXTENDS Basic_Schnittstelle_FB_V01_00_00

VAR_INPUT
END_VAR

VAR_OUTPUT

  // Bool
  bpAnforderungSK : BOOL;
  bpGlasAbruf     : BOOL;

END_VAR

VAR

END_VAR

VAR_INPUT

  // HARDWARE EINGAENGE
  in_bGlasAbruf                 AT%I* : BOOL; // Signal von Schneidanlage
  in_bTransportRueckwaerts      AT%I* : BOOL; // Signal von Schneidanlage
  in_bRiemenVor                 AT%I* : BOOL; // Signal von Schneidanlage
  in_bRiemenZurueck             AT%I* : BOOL; // Signal von Schneidanlage
  in_bAnforderungSK             AT%I* : BOOL; // Signal von Schneidanlage

  out_bFreigabeSK               AT%Q* : BOOL; // Signal von Schneidanlage

END_VAR

//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: DEAKTIVIERUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Schnittstelle deaktiviert (MK bDeaktivieren): Ausgaenge abschalten, Baustein verlassen
*)
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  out_bFreigabeSK := FALSE;
  bpAnforderungSK := FALSE;
  bpGlasAbruf     := FALSE;
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------

Signalverarbeitung();
IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
  Signal_Logger();
END_IF

//-------------------------------------------------------------------------------------------------
// STEUERUNG: HARDWARESCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
blSenderGlasBereit := ( (*( BasisStationsParameter.bAutomatik )
                        AND*) NOT BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bFehler )
                      AND ( BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport
                            OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]
                            OR BasisStationsParameter.bCheckMitNachfolger[cWAND_1] );


bpAnforderungSK := in_bAnforderungSK OR bgVisu_Schnittstelle_Force_AnforderungSK[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
bpGlasAbruf     := in_bGlasAbruf OR bgVisu_Schnittstelle_Force_GlasAbruf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

bgVisu_Schnittstelle_GlasAbruf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]     := in_bGlasAbruf OR bgVisu_Schnittstelle_Force_GlasAbruf[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
bgVisu_Schnittstelle_AnforderungSK[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] := in_bAnforderungSK OR bgVisu_Schnittstelle_Force_AnforderungSK[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
bgVisu_Schnittstelle_FreigabeSK[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]    := out_bFreigabeSK;
END_FUNCTION_BLOCK