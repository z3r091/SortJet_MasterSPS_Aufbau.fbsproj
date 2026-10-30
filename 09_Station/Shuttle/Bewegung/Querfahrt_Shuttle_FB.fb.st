(* METADATA
{
	"v3Meta": {
		"objectGuid": "72dffa9c-0dea-4fd7-9820-5307a69ebe3d"
	}
}
*)
FUNCTION_BLOCK Querfahrt_Shuttle_FB
VAR_INPUT

  (* BOOLEAN *)
  bpAktivieren                           : BOOL; (* Hinweis: Baustein aktivieren *)
  bpReset                                : BOOL; (* BETRIEBSART: Fehler zuruecksetzen *)
  bpStartReferenz                        : BOOL;
  bpHandplus                             : BOOL;
  bpHandminus                            : BOOL;
  bpFreigabe                             : BOOL; (* Sicherheitsfreigabe Regler darf Freigeben *)
  bpAutomatikAktiv                       : BOOL; (* BETRIEBSART: Umschaltung der Geschwindigkeit*)
  bpVerfahreShuttle                      : BOOL; (* Befehl zum Positionieren *)
  bpVerfahrfreigabe                      : BOOL; (* Das entsprechende Shutte setzt die Verfahrfreigabe und überträgt es an die Verfahrkontrolle *)
  bpSofortStop                           : BOOL;
  bpQuittungAuftragsstatusZurueckgesetzt : BOOL; (* Auftrag wurde zurueckgesetzt *)
  bpTeilnehmerErreichbar                 : BOOL;
  bpShuttleFaecherwagenSuche             : BOOL;
  bpLangsamfahrtNockenAktivieren         : BOOL;

  (* WORD *)
  wpAuftragsTyp                          : WORD; // Bit 1 = Positionierauftrag mit Messgeschwindigkeit (RackSuche); Anbindung folgt mit P2.1

  (* REAL *)
  rpDestinationPosition                  : REAL; (* ZielPosition *)  
  rpMinPosSwEsEingrenzung                : REAL;
  rpMaxPosSwEsEingrenzung                : REAL;

  (* POINTER *)
  ppAntriebsInformationen  : REFERENCE TO AntriebsInformationen; (* Hinweis: Beinhaltet die Geschwindigkeiten / Rampen der einzelnen Shuttle *)

  // STRUKTUR
  stStationsNummern     : Station_ST;
	
END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpDone                         : BOOL;
  bpFehler                       : BOOL;
  bpPositionierungAktiv          : BOOL;
  bpAntriebLaeuft                : BOOL;
  bpInReference                  : BOOL;
  bpAuftragsstatusZuruecksetzen  : BOOL := FALSE;
  bpAbbruchPositionierung        : BOOL := FALSE;

  (* WORD *)
  wpFehlerNr     : WORD; (* Exception- Handle: Fehlernummer *)

  (* REAL *)
  rpAktPosition : REAL;
  rpAktSpeed    : REAL;

  (* HARDWARE EINGAENGE *)
  in_bLeistungsschutzFremdluefter : BOOL;

END_VAR
VAR

  (* BOOLEAN *)
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

  (* BOOLEAN *)
  blErsterZyklus                : BOOL := TRUE;
  blFreigabeGesetzt             : BOOL;
  blAlterStatus_Bewegung        : BOOL;

  (* REAL *)
  rlAlterStatus_Position        : REAL;

  (* STEPS *)
  STEP_Mov_Shuttle_W    : Steps_TE;
  schrittlReset         : STEPS_TE;
  steplReferenz         : STEPS_TE;

  (* TIMER *)
  tonlWarteAufStop                      : TON; (* EINSCHALTVERZOEGERUNG: *)
  tonlWarteAufReset                     : TON; (* EINSCHALTVERZOEGERUNG: *)
  tofAntriebFreigabe                    : TOF; (* AUSSCHALTVERZÖGERUNG  *)
  tonlEndschalterFreifahren             : TON;
  tonlWarteSchrittEndschalterFreifahren : TON;
  toflHardwareEndschalterFrei           : TOF;
  tonlSafetyTimeout                     : TON;
  tonlFreigabe                          : TON;
  tonlAntriebNichtBetriebsbereit        : TON;
  tonlStatusMelden                      : TON;

  (* TRIGGER *)
  rtlAutoAktiv : R_TRIG;

END_VAR

(***************************************************************************************************)
(* S T A R T - Initialisierung *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  IF __ISVALIDREF(ppAntriebsInformationen) THEN
    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];
  ELSE
    RETURN;
  END_IF

  blErsterZyklus := FALSE;

  (* Hinweis:
     - Für die Zielpunktkontrolle muss im ersten Zyklus (und nach jeder Referenzierung) die Zielposition initialisiert werden
  *)
  Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;
  Antrieb.rpZielPosition := Antrieb.rpIstPosition;
  Antrieb.stStationsNummern := stStationsNummern;

  (* Erste Initialisierung *)
  Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
  Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
  Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
  Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;

END_IF

(***************************************************************************************************)
(* E N D E - Initialisierung *)
(***************************************************************************************************)

(***************************************************************************************************)
(* DEAKTIVIEREN *)
(***************************************************************************************************)
IF ( NOT bpAktivieren ) THEN

  bpDone                        := TRUE;
  bpAuftragsstatusZuruecksetzen := FALSE;
  bpAbbruchPositionierung       := FALSE;

  bpFehler   := FALSE;
  wpFehlerNr := WORD#0;

  Antrieb.bpFreigabe := FALSE;

  RETURN;

END_IF

(***************************************************************************************************)
(* S T A R T - Timer *)
(***************************************************************************************************)

rtlAutoAktiv(CLK := bpAutomatikAktiv);

IF ( rtlAutoAktiv.Q ) THEN
 Antrieb.rpZielPosition := Antrieb.rpIstPosition;
END_IF

(* Hinweis:
   - Aktuell wird diese Einschaltverzoegerung nur bei Motoren mit Bremse benoetigt [Lenze]
     => Eingebunden bei den Handfunktionen
*)
tofAntriebFreigabe( IN := blFreigabeGesetzt AND Antrieb.bpReglerBereit  , PT := T#10S );

(***************************************************************************************************)

(***************************************************************************************************)
(* S T A R T - Verfahrschrittketten zurücksetzen *)
(***************************************************************************************************)

(***************************************************************************************************)

IF (   bpVerfahrfreigabe
   AND bpAbbruchPositionierung
   AND bpQuittungAuftragsstatusZurueckgesetzt )
THEN
  bpAbbruchPositionierung := FALSE;
  bpAuftragsstatusZuruecksetzen := FALSE;
  bpQuittungAuftragsstatusZurueckgesetzt := FALSE;

  wSps2MmiStationsNummer     := stStationsNummern.NummerSPS;
  rSps2MmiShuttlePosition[0] := Antrieb.rpIstPosition;
  MsgToMmi(SB0_SPS_SHUTTLEVORABPOSITIONIERUNGREADY);

END_IF

(***************************************************************************************************)
(* S T A R T - BAUSTEINE AUFRUFEN *)
(***************************************************************************************************)

(***************************************************************************************************)
(* S T A R T - BAUSTEINE AUFRUFEN *)
(***************************************************************************************************)
Verfahren();
Handfunktionen();
Referenz();
Reset();
Meldungen();

(***************************************************************************************************)
(* E N D E - BAUSTEINE AUFRUFEN *)
(***************************************************************************************************)
IF ( bpSofortStop OR NOT abgVerfahrfreigabeShuttle[stStationsNummern.NummerSPS] ) OR NOT bpFreigabe THEN
  Antrieb.bpFreigabe := FALSE;
END_IF 

Antrieb.stStationsNummern            := stStationsNummern;

Antrieb.bpAktiviereLangsamfahrtNocke := bpLangsamfahrtNockenAktivieren;
Antrieb.rpMinSwEsEingrenzung         := rpMinPosSwEsEingrenzung;
Antrieb.rpMaxSwEsEingrenzung         := rpMaxPosSwEsEingrenzung;

(* übergabe der aktuellen Position *)
rpAktPosition   := Antrieb.rpIstPosition;
rpAktSpeed      := Antrieb.rpIstGeschwindigkeit; (* mm/s, mit Vorzeichen *)
bpInReference   := Antrieb.bpIstReferenziert;
bpAntriebLaeuft := Antrieb.bpAntrieblaeuft;

// STATUS AN MMI MELDEN
tonlStatusMelden(
  IN := NOT tonlStatusMelden.Q,
  PT := T#500MS
);

IF tonlStatusMelden.Q
AND (  ( ABS( Antrieb.rpIstPosition - rlAlterStatus_Position ) > 1.0 )
    OR ( Antrieb.bpAntrieblaeuft <> blAlterStatus_Bewegung ) OR Job.rtlMmiOk.Q ) THEN
  stStationUpdate.wStationsNummer       := stStationsNummern.NummerSPS;
  stStationUpdate.eUpdateTyp            := StationUpdateTyp_EN.POSITIONSAENDERUNG;
  stStationUpdate.wAnzahlWerte          := 2;
  stStationUpdate.astWerte[1].eDatenTyp := UpdateDatenTyp_EN.TYP_REAL;
  stStationUpdate.astWerte[1].rWert     := Antrieb.rpIstPosition;
  stStationUpdate.astWerte[2].eDatenTyp := UpdateDatenTyp_EN.TYP_BOOL;
  stStationUpdate.astWerte[2].bWert     := Antrieb.bpAntrieblaeuft;
  MsgToMmi( auftragsnr_w := SB0_SPS_STATION_UPDATE );

  rlAlterStatus_Position := Antrieb.rpIstPosition;
  blAlterStatus_Bewegung := Antrieb.bpAntrieblaeuft;
END_IF
END_FUNCTION_BLOCK