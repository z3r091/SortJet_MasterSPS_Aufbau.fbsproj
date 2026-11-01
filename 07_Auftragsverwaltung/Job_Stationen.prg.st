(* METADATA
{
  "v3Meta": {
    "objectGuid": "9b3e7ff2-3a2c-4bce-8ea4-25f3e47febe0"
  }
}
*)
PROGRAM Job_Stationen
VAR_INPUT

  (* BOOLEAN *)
  abpReset                              : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
  abpAbbruchAnlegeauftrag               : ARRAY [cERSTE_STATION..cLETZTE_STATION] OF BOOL; (* Hinweis: Wird ein Anlegeauftrag abgebrochen (M_SB0_MMI_SORTIERUNGCANCELQUEUEDATA) so darf die *)
  abpStarteParalleleBausteinAnsteuerung : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF BOOL;
  abpResetTransportkopplung             : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF BOOL;

  (* AUJFTRAGSSPEICHER *)
  AuftragsSpeicherStation     : ARRAY [cERSTE_STATION..cLETZTE_STATION]                          OF AuftragsSpeicherStationen;
  AuftragsSpeicherWand        : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF AuftragsSpeicherStationen;

  // AUFTRAGS-STRUKTUREN
  AuftragsdatenStation        : ARRAY [cERSTE_STATION..cLETZTE_STATION] OF Auftragsdaten_ST;
  AuftragsdatenWand           : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Auftragsdaten_ST;
  VisuAuftragsdaten           : ARRAY [cERSTE_STATION..cLETZTE_STATION] OF Visu_Auftraege_ST;

END_VAR
VAR_OUTPUT

  // BOOL
  abpFehler          : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

END_VAR
VAR

  (* BOOLEAN *)
  blErsterZyklus   : BOOL := TRUE;
  ablFreigabeZurParalleleBausteinAnsteuerung : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF BOOL;
  ablMerkerLetzteScheibeStation              : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF BOOL;
  ablFehler                                  : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF BOOL;

  (* WORD *)
  wlIndex,
  wlIndexWand,
  wlIndexReset,
  wlIndexAutoStart,
  wlLetzteScheibe,
  wlErsteScheibe : WORD;

  // INT 
  ailScheibenZuQuittierenEintransport        : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF INT; (* Scheibenzaehlung fuer die Quittierung *)
  ailScheibenZuQuittierenAustransport        : ARRAY [cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF INT; (* Scheibenzaehlung fuer die Quittierung *)

  (* TRIGGER *)
  rtlFehler          : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF R_TRIG;
  rtlStartAutomatik  : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF R_TRIG;

  // BAUSTEINE 
  Anlegen            : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Anlegen;
  Abnehmen           : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Abnehmen;
  Glashoehenmessung  : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Glashoehenmessung;
  Glaslaengenmessung : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Glaslaengenmessung;
  Eintransport       : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Eintransport;
  Austransport       : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Austransport;
  Durchtransport     : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Durchtransport;
  Transportkopplung  : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Transportkopplung;
  Messkopplung       : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Messkopplung;
  Vortransport       : ARRAY[cERSTE_STATION..cLETZTE_STATION, cWAND_1..cANZAHL_WAENDE] OF Station_Vortransport;
  Querfahrt          : ARRAY[cERSTE_STATION..cLETZTE_STATION] OF Station_Querfahrt;

  // STRUCT
  stLokaleKopplungZielStation : REFERENCE TO StationBasisParameter_ST;
  stLokaleKopplungsStation    : REFERENCE TO StationBasisParameter_ST;

END_VAR
VAR CONSTANT

  (* Stationen die nicht in den dynamischen Methoden aufgerufen werden dürfen *)  
  awcAusgeschlosseneStationen : ARRAY[1..10] OF WORD := [ 218, 9(cSTATION_DEFAULT) ];

END_VAR
(***************************************************************************************************)
(* BAUSTEIN: INITIALISIERUNG *)
(***************************************************************************************************)
IF blErsterZyklus THEN
  blErsterZyklus := FALSE;

END_IF

(***************************************************************************************************)
(* Transportkopplungen zurücksetzen, wenn vom Master gefordert  *)
(***************************************************************************************************)

FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
    IF abpResetTransportkopplung[wlIndex, wlIndexWand] THEN
      abpResetTransportkopplung[wlIndex, wlIndexWand] := FALSE;
      Transportkopplung[wlIndex, wlIndexWand]( bpReset := TRUE );
      Messkopplung[wlIndex, wlIndexWand]( bpReset := TRUE );
      AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag := eStation_Kein_Auftrag;
    END_IF  
  END_FOR
END_FOR


(***************************************************************************************************)
(* BAUSTEIN: AKTIONEN  *)
(***************************************************************************************************)

Status_Automatikkreis_Start();

Auftraege();

Auftragsverwaltung();

Schnittstelle_Stationen();

FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
    rtlFehler[wlIndex, wlIndexWand]( CLK := ablFehler[wlIndex, wlIndexWand] );
    IF NOT findInWORDArray(awcAusgeschlosseneStationen, wlIndex) THEN
      Station(wlIndex, wlIndexWand);
    END_IF
  END_FOR
END_FOR

Reset();

Verfahrfreigabe();

Visu();
END_PROGRAM