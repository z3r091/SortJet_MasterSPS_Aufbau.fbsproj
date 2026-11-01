(* METADATA
{
  "v3Meta": {
    "objectGuid": "ac7cd821-755f-477f-9445-f7486c53354c"
  }
}
*)
PROGRAM Job_Fremdanlage
VAR_INPUT

  // BOOL
  abpReset                    : ARRAY[cAUTOMATIKKREIS_1..cLETZTER_AUTOMATIKKREIS] OF BOOL;

  (* AUJFTRAGSSPEICHER *)
  AuftragsSpeicherFremdanlage : ARRAY [cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_EINLAUF] OF AuftragsSpeicherStationen;

  // AUFTRAGS-STRUKTUREN
  AuftragsdatenFremdanlage    : ARRAY [cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_EINLAUF]  OF Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOL
  abpFehler          : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

END_VAR
VAR

  // BOOL
  blErsterZyklus               : BOOL := TRUE;
  blUeberwachungFolgeNachricht : BOOL := FALSE;
  ablNachrichtEmpfangen        : ARRAY [1..2] OF BOOL;

  // WORD
  wlIndex          : WORD := 0;
  wlIndexReset     : WORD := 0;

  // STRUCT
  stAuftragScheibenIDs   : Schnittstelle_ScheibenIDs;

  // STEPS
  astplEintransportFremdanlage  : ARRAY [cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_EINLAUF] OF Steps_TE;

END_VAR
VAR CONSTANT

  // BYTE
  cNACHRICHTEN_INDEX_1 : BYTE := 1;
  cNACHRICHTEN_INDEX_2 : BYTE := 2;

END_VAR
(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  ablNachrichtEmpfangen[1]     := FALSE;
  ablNachrichtEmpfangen[2]     := FALSE;
  blUeberwachungFolgeNachricht := FALSE;

END_IF

(***************************************************************************************************)
(* BAUSTEIN: AUFTRAGSVERWALTUNG *)
(***************************************************************************************************)
FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO

  AuftragsSpeicherFremdanlage[wlIndex]();

  IF AuftragsSpeicherFremdanlage[wlIndex].bpAuftragverfuegbar
     AND ( AuftragsdatenFremdanlage[wlIndex].wAuftrag = eStation_Kein_Auftrag
           OR AuftragsdatenFremdanlage[wlIndex].wAuftrag = eStation_Belegt
           OR AuftragsdatenFremdanlage[wlIndex].wAuftrag = eStation_Warte_Auf_Eintransport )
  THEN
    AuftragsSpeicherFremdanlage[wlIndex].bpNaechsterAuftrag := TRUE;
    AuftragsSpeicherFremdanlage[wlIndex]();
    AuftragsdatenFremdanlage[wlIndex] := AuftragsSpeicherFremdanlage[wlIndex].AktAuftrag;
  END_IF

END_FOR

(***************************************************************************************************)
(* AKTIONEN  *)
(***************************************************************************************************)
Reset();
Auftraege();

// Hinweis:
// - Auslauf- Fremdanlagen: Vorgaenger und Automatikkreis aus den MKs der Schnittstelle
FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO

  IF __ISVALIDREF( starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs ) THEN
    Fremdanlage( wFremdanlage                  := wlIndex,
                 wVorgaenger                   := starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs.stSchnittstellendaten.wVorgaengerStation,
                 wAutomatikkreis               := TO_WORD( AutomatikkreisBestimmen( wlIndex ) ),
                 bDurchtransportierendeStation := FALSE );
  END_IF

END_FOR
END_PROGRAM