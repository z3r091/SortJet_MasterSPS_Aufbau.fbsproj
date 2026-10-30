(* METADATA
{
	"v3Meta": {
		"objectGuid": "d572774f-9eb0-4642-b999-1d4bc3469776"
	}
}
*)
FUNCTION_BLOCK Kippen_FB
VAR_INPUT

  // BOOLEAN *)
  bpAktivieren              : BOOL;
  bpFreigabe                : BOOL;
  bpReset                   : BOOL;
  bpReferenz                : BOOL;
  bpPositionieren           : BOOL;
  bpHandfahrenPlus          : BOOL;
  bpHandfahrenMinus         : BOOL;
  bpAutomatikAktiv          : BOOL;
  bpSensorEinlauf           : BOOL;
  bpSensorAuslauf           : BOOL;
  bpSensorEinlaufNachfolger : BOOL;
  bpSensorAuslaufVorgaenger : BOOL;
  bpTeilnehmerErreichbar    : BOOL;

  bpSensorNicht90Grad       : BOOL;
  bpSensorNicht84Grad       : BOOL;

  // POINTER
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;
  ppParameterBaustein     : REFERENCE TO Parameter_Kippen;

  // ENUM
  epZielPosition          : Kippen_EN; (* Hinweis: Wird fuer die Absolut-Positionierung verwendet "bpStartAbsolutPositionierung" *)

  // STRUCT
  stStationsNummern       : Station_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                       : BOOL;
  bpFehler                     : BOOL;
  bpInReferenz                 : BOOL;
  bpPositionierenAbgeschlossen : BOOL;

  // WORD
  wpFehlerNr                   : Fehlerkonstanten_EN; // FEHLER-AUSWERTUNG: Fehlernummer[Const] *)

  // ENUM *)
  epKippStatus                 : Kippen_EN; // Status: Gibt die aktuelle Position des Antriebs aus

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus      : BOOL := TRUE;

  // REAL
  rlAntriebsZielPosition : REAL;

  // TIMER
  tonlFehlermeldungUnterdrueckenAntriebOK : TON;
  tonlMaxWarteZeit                        : TON;
  tonlMaxWarteAufResetErfolgreich         : TON;
  tonlEndschalterFreifahren               : TON;
  tonlWarteSchrittEndschalterFreifahren   : TON;
  tofHardwareEndschalterFrei              : TOF;
  toflReglerFreigabeErhalten              : TOF;
  toflHardwareEndschalterFrei             : TOF;
  toflReset                               : TOF;

  // STEPS
  steplReset          : Steps_TE;
  steplReferenz       : Steps_TE;
  steplPositionieren  : Steps_TE;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR

VAR
  // HARDWARE EINGÄNGE
  in_bMotorstarter_OK                 AT%I* : BOOL;
  in_bLS400V_OK                       AT%I* : BOOL;
  in_bLSBremse_OK                     AT%I* : BOOL;

  // HARDWARE AUSGÄNGE
  out_bKippen84Grad                   AT%Q* : BOOL;
  out_bKippen90Grad                   AT%Q* : BOOL;
  out_bBremseLoesen                   AT%Q* : BOOL;
  out_bReset                          AT%Q* : BOOL;

END_VAR

(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    blErsterZyklus := FALSE;

    Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;

    (* Hinweis:
       - Für die Zielpunktkontrolle muss im ersten Zyklus die Zielposition initialisiert werden
    *)
    Antrieb.rpZielPosition := Antrieb.rpIstPosition;

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

  ELSE
    RETURN;
  END_IF

END_IF

(***************************************************************************************************)
(* DEAKTIVIEREN *)
(***************************************************************************************************)
IF ( NOT bpAktivieren ) THEN

  bpDone                       := TRUE;
  bpInReferenz                 := TRUE;
  bpPositionierenAbgeschlossen := TRUE;

  epKippStatus := epZielPosition;

  bpFehler   := FALSE;
  wpFehlerNr := 0;

  RETURN;

END_IF

(***************************************************************************************************)
(* BAUSTEIN: AKTIONEN *)
(***************************************************************************************************)

(* Hinweis:
   - Kippbewegung
*)
IF (ppParameterBaustein.bKippenMitSchuetz ) THEN
  Kippen_Schuetz();
ELSE
  Positionieren();
END_IF


(* Hinweis:
   - Baisis- Aktionen
*)
Ausgaenge();
Meldungen();
Timer();
Reset();
Referenz();
Handbetrieb();

(***************************************************************************************************)
(* ZUWEISUNGEN UND BAUSTEINAUFRUFE *)
(***************************************************************************************************)
(* Antriebsfreigabe:
    - Antrieb
*)
toflReglerFreigabeErhalten( IN := (   bpPositionieren
                                    OR bpReferenz
                                    OR bpHandfahrenPlus
                                    OR bpHandfahrenMinus
                                    OR bpReset ),
                            PT := ppParameterBaustein.tZeitAntriebsfreigabeErhalten );


Antrieb.bpFreigabe        := ( bpFreigabe AND toflReglerFreigabeErhalten.Q );
Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
Antrieb.stStationsNummern := stStationsNummern;
END_FUNCTION_BLOCK