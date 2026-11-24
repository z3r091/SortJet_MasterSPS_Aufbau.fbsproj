(* METADATA
{
	"v3Meta": {
		"objectGuid": "fdc13e48-e8ff-456a-879e-40351fd7e090"
	}
}
*)
PROGRAM Job_Shuttle
VAR_INPUT

  // BOOLEAN
  abpReset                              : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS]    OF BOOL;
  abpStarteParalleleBausteinAnsteuerung : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;
  abpSpeicherfachValidierung            : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;
  abpResetTransportkopplung             : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;

  // BAUSTEINE
  AuftragsSpeicherTransfershuttle  : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE]          OF AuftragsSpeicher;
  AuftragsSpeicherShuttle          : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE]                          OF AuftragsSpeicher;
  AuftragsSpeicherWand             : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF AuftragsSpeicher;

  // STRUCT
  AuftragsdatenStation                       : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE]                                  OF Auftragsdaten_ST;
  AuftragsdatenWand                          : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE]         OF Auftragsdaten_ST;
  VorAbAuftragsDaten                         : ARRAY [cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE, cWAND_1..cANZAHL_WAENDE] OF VorAbAuftragsdaten_ST; // Ermoeglicht ein paralleles abarbeiten von bestimmten Auftraegen
  VisuAuftragsdaten                          : ARRAY [cERSTES_SHUTTLE..cLETZTES_TRANSFERSHUTTLE]                          OF Visu_Auftraege_ST;
  AuftragsdatenTransfershuttle               : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE]                  OF Auftragsdaten_ST;
  starrAuftragsdatenSpeicherfachValidierung  : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE]                  OF Auftragsdaten_ST;

  LocalAuftragsSpeicher             : REFERENCE TO AuftragsSpeicher;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  abpFehler : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus         : BOOL := TRUE;
  blFehler               : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF BOOL;
  blFehlerTS             : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;

  // WORD
  wlIndex,
  wlIndexWand,
  wlIndexQuelle,
  wlIndexReset,
  wlLetzteScheibe,
  wlErsteScheibe                  : WORD;
  awlGlasSender                   : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF WORD;
  awlVerbundTransfershuttle       : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF WORD;
  awlStatusSpeichervalidierung    : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF WORD;

  // TRIGGER
  rtlFehler   : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  rtlFehlerTS : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF R_TRIG;

  // STEPS
  asteplSpeicherfachValidierung   : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF Steps_TE;
  asteplFaecherwagenSuche         : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF Steps_TE;

  // TON
  atonlWarteAufMasterAuftrag      : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TON;

  // SH - BAUSTEINE
  Querfahrt                       : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF Shuttle_Querfahrt;
  Racksuche                       : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF Shuttle_RackSuche;
  Eintransport                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF Shuttle_Eintransport;
  Austransport                    : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF Shuttle_Austransport;
  Durchtransport                  : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF Shuttle_Durchtransport;
  VorabkomponentenAnsteuerung     : ARRAY[cERSTES_SHUTTLE..cLETZTES_SHUTTLE, cWAND_1..cANZAHL_WAENDE] OF Shuttle_Vorabkomponenten;

  // TS - BAUSTEINE
  TS_Querfahrt                    : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TS_Querfahrt;
  TS_Eintransport                 : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TS_Eintransport;
  TS_Austransport                 : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TS_Austransport;
  TS_Transportkopplung            : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TS_Transportkopplung;
  TS_Vortransport                 : ARRAY[cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF TS_Vortransport;

  wlAutomatikkreis2               : WORD := 2; // Variable mit dem Index zum Zugriff auf den 2. Automatikkreis Index. Benötigt zum Austricksen des Compilers

  Basis                           : REFERENCE TO StationBasisParameter_ST;

END_VAR


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;

  FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    Querfahrt[wlIndex].wStation := wlIndex;
    Racksuche[wlIndex].wStation := wlIndex;
    FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
      Eintransport[wlIndex, wlIndexWand].wStation                := wlIndex;
      Eintransport[wlIndex, wlIndexWand].wWand                   := wlIndexWand;
      Austransport[wlIndex, wlIndexWand].wStation                := wlIndex;
      Austransport[wlIndex, wlIndexWand].wWand                   := wlIndexWand;
      VorabkomponentenAnsteuerung[wlIndex, wlIndexWand].wStation := wlIndex;
      VorabkomponentenAnsteuerung[wlIndex, wlIndexWand].wWand    := wlIndexWand;
    END_FOR
  END_FOR

END_IF

(* Hinweis [TRANSFERSHUTTLE]:
   - Transportkopplungen zurücksetzen, wenn vom Master-TS gefordert
*)
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  IF NOT starrTransfershuttleBasisParameter[wlIndex].stMKs.stStationsOptionen.stTransfershuttle.bMasterStation THEN
    IF abpResetTransportkopplung[wlIndex] THEN
      abpResetTransportkopplung[wlIndex] := FALSE;
      TS_Transportkopplung[wlIndex]( bpReset := TRUE );
      AuftragsdatenTransfershuttle[wlIndex].wAuftrag := eStation_Kein_Auftrag;
    END_IF
  END_IF
END_FOR

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AKTIONEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Aufruf der Baustein-Aktionen
*)
Auftraege();

FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
    rtlFehler[wlIndex,wlIndexWand]( CLK := blFehler[wlIndex,wlIndexWand] );
    ShuttleWandAuftraege(wlIndex, wlIndexWand);
  END_FOR

  ShuttleQuerfahrt(wlIndex);

END_FOR

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  rtlFehlerTS[wlIndex]( CLK := blFehlerTS[wlIndex] );
  IF starrTransfershuttleBasisParameter[wlIndex].stMKs.stStationsOptionen.stTransfershuttle.bMasterStation THEN
    Master_Transfershuttle(wlIndex);
  ELSE
    Slave_Transfershuttle(wlIndex);
  END_IF
END_FOR

Reset();
Meldungen();
Verfahrfreigabe();

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUFTRAGSVERWALTUNG
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Die Auftraege mussen vor dem Aufruf der Steuerung abgehandelt werden [Grund: z.B: Vermeidung von Fehlern nach dem SystemCheck]
*)

// Auftragsdaten für das Shuttle, z.B. Querfahrt
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  AuftragsSpeicherShuttle[wlIndex]();

  IF ( AuftragsSpeicherShuttle[wlIndex].bpAuftragverfuegbar
       AND ( ( AuftragsdatenStation[wlIndex].wAuftrag = eStation_Kein_Auftrag )
             OR ( AuftragsdatenStation[wlIndex].wAuftrag = eStation_Belegt ) ) )
  THEN
    AuftragsSpeicherShuttle[wlIndex].bpNaechsterAuftrag := TRUE;
    AuftragsSpeicherShuttle[wlIndex]();
    AuftragsdatenStation[wlIndex] := AuftragsSpeicherShuttle[wlIndex].AktAuftrag;
  END_IF

END_FOR

// Auftragsdaten für die Shuttlewand, z.B. Eintransport
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO

  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO

    AuftragsSpeicherWand[wlIndex, wlIndexWand]();

    IF    AuftragsSpeicherWand[wlIndex, wlIndexWand].bpAuftragverfuegbar
          AND AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag = eStation_Kein_Auftrag
    THEN
      AuftragsSpeicherWand[wlIndex, wlIndexWand].bpNaechsterAuftrag := TRUE;
      AuftragsSpeicherWand[wlIndex, wlIndexWand]();
      AuftragsdatenWand[wlIndex, wlIndexWand] := AuftragsSpeicherWand[wlIndex, wlIndexWand].AktAuftrag ;
    END_IF

  END_FOR

END_FOR

// Auftragsdaten für das Transfershuttle
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO

  AuftragsSpeicherTransfershuttle[wlIndex]();

  IF ( AuftragsSpeicherTransfershuttle[wlIndex].bpAuftragverfuegbar
       AND AuftragsdatenTransfershuttle[wlIndex].wAuftrag = eStation_Kein_Auftrag )
  THEN
    AuftragsSpeicherTransfershuttle[wlIndex].bpNaechsterAuftrag := TRUE;
    AuftragsSpeicherTransfershuttle[wlIndex]();
    AuftragsdatenTransfershuttle[wlIndex] := AuftragsSpeicherTransfershuttle[wlIndex].AktAuftrag;
  END_IF

END_FOR
END_PROGRAM