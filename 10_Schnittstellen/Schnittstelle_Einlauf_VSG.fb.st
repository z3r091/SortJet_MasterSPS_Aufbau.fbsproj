(* METADATA
{
	"v3Meta": {
		"objectGuid": "fbbba330-556c-41e3-bb2c-ea5fa1aaa6e1"
	}
}
*)
FUNCTION_BLOCK Schnittstelle_Einlauf_VSG EXTENDS Basic_Schnittstelle_FB_V01_00_00
VAR_INPUT

END_VAR
VAR_OUTPUT

  // STRUCT
  OutGlasTransport   : Interface_LTR_VSG; // Signale zum LTR

END_VAR

VAR_INPUT

  // HARDWARE EINGAENGE
  in_bGlasBereit                          AT %I* : BOOL;
  in_bAutomatikBetrieb                    AT %I* : BOOL; // Scheiben werden automatisch eintransportiert

END_VAR

VAR_OUTPUT
  // HARDWARE AUSGAENGE
  out_bEinlaufsensor                      AT %Q* : BOOL;
  out_bBereitZumEintrasport               AT %Q* : BOOL;

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
  out_bEinlaufsensor        := FALSE;
  out_bBereitZumEintrasport := FALSE;
  RETURN;
END_IF

IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
  Signal_Logger();
END_IF

//-------------------------------------------------------------------------------------------------
// SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
// Signale von der VSG
blBereitZumAustransport := in_bGlasBereit OR bgVisu_Schnittstelle_Einlauf_Force_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];
blAutomatikBetriebAktiv := in_bAutomatikBetrieb OR bgVisu_Schnittstelle_Force_AutomatikBetrieb[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];;

//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Signale zur VSG
out_bEinlaufsensor        := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bEinlaufsensor;
out_bBereitZumEintrasport := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bBereitZumEintransport;

//-------------------------------------------------------------------------------------------------
// VISU
//-------------------------------------------------------------------------------------------------
bgVisu_Schnittstelle_Einlauf_Status_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]   := BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport;
bgVisu_Schnittstelle_Status_AutomatikBetrieb[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]     := BasisStationsParameter.OutGlasTransport[cWAND_1].bAutomatikBetriebAktiv;
bgVisu_Schnittstelle_Status_Einlaufsensor[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]        := out_bEinlaufsensor;
bgVisu_Schnittstelle_Status_BereitZumEintrasport[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] := out_bBereitZumEintrasport;
END_FUNCTION_BLOCK