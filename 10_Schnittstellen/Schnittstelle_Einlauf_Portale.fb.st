(* METADATA
{
	"v3Meta": {
		"objectGuid": "1983d120-77fe-4da5-a5d1-bf513123edf7"
	}
}
*)
FUNCTION_BLOCK Schnittstelle_Einlauf_Portale EXTENDS Basic_Schnittstelle_FB_V01_00_00
VAR_INPUT

END_VAR

VAR_INPUT

  // HARDWARE EINGAENGE
  in_bGlasAufgestellt                     AT %I* : BOOL;

END_VAR

VAR_OUTPUT

  // HARDWARE AUSGAENGE
  out_bBereitZumAufstellen               AT %Q* : BOOL;

END_VAR

// Schnittstelle zwischen LTR und VSG Anlage
// Sobald wir einen Anlageauftrag bekommen und das Signal "in_bAutomatikBetrieb" ansteht, gehen wir in Eintrasport.
// Dort setzen wir "out_bBereitZumEintrasport" und warten bis das Signal "in_bGlasBereit" ansteht. Dieses wird von
// der VSG gesetzt wenn Glas bereit liegt und die Riemen in SlaveMode sind. Wir starten dann denn Eintransport.
// Der SlaveMode bleibt so lange aktiv, bis wir das Signal "out_bBereitZumEintrasport" wegnehmen.

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
  out_bBereitZumAufstellen := FALSE;
  RETURN;
END_IF

//IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
Signal_Logger();
//END_IF

//-------------------------------------------------------------------------------------------------
// SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
// Signale von der VSG
blBereitZumAustransport := in_bGlasAufgestellt OR bgVisu_Schnittstelle_Einlauf_Force_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Signale zur VSG
out_bBereitZumAufstellen := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bBereitZumEintransport;

//-------------------------------------------------------------------------------------------------
// VISU
//-------------------------------------------------------------------------------------------------
bgVisu_Schnittstelle_Einlauf_Status_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]   := BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport;
bgVisu_Schnittstelle_Status_BereitZumEintrasport[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] := out_bBereitZumAufstellen;
END_FUNCTION_BLOCK