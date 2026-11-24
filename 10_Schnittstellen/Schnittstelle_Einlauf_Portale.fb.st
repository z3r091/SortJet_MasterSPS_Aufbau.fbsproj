(* METADATA
{
	"v3Meta": {
		"objectGuid": "1983d120-77fe-4da5-a5d1-bf513123edf7"
	}
}
*)
FUNCTION_BLOCK Schnittstelle_Einlauf_Portale EXTENDS Basic_Schnittstelle_FB_V01_00_00
VAR_INPUT

  // HARDWARE EINGAENGE
  in_bGlasAufgestellt                     AT %I* : BOOL;

END_VAR

VAR_OUTPUT

  // HARDWARE AUSGAENGE
  out_bBereitZumAufstellen               AT %Q* : BOOL;

END_VAR

// Schnittstelle zu den Portalen (Glas aufstellen)
// - "out_bBereitZumAufstellen": die Folgestation ist bereit zum Eintransport, das Portal darf Glas aufstellen
// - "in_bGlasAufgestellt": das Portal hat Glas aufgestellt, die Folgestation startet den Eintransport

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

IF BasisStationsParameter.stMKs.stFremdanlage.bSignaleLoggen THEN
  Signal_Logger();
END_IF

//-------------------------------------------------------------------------------------------------
// SCHNITTSTELLE
//-------------------------------------------------------------------------------------------------
// Signale vom Portal
blBereitZumAustransport := in_bGlasAufgestellt OR bgVisu_Schnittstelle_Einlauf_Force_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS];

//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
// Portal hat Glas aufgestellt, die Station ist aber 30 s nicht bereit zum Eintransport [wMeldungsNummer + 2]
WatchIoControl( T#30S,
                BasisStationsParameter.stMKs.wMeldungsNummer + 2,
                blBereitZumAustransport AND NOT BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bBereitZumEintransport );

//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Signale zum Portal
out_bBereitZumAufstellen := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bBereitZumEintransport;

//-------------------------------------------------------------------------------------------------
// VISU
//-------------------------------------------------------------------------------------------------
bgVisu_Schnittstelle_Einlauf_Status_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]   := BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport;
bgVisu_Schnittstelle_Status_BereitZumEintrasport[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] := out_bBereitZumAufstellen;
END_FUNCTION_BLOCK