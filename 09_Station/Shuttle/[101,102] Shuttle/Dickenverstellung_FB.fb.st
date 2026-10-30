(* METADATA
{
	"v3Meta": {
		"objectGuid": "d815e3f2-dcd5-4a25-9c13-c3ee247e2cce"
	}
}
*)
FUNCTION_BLOCK Dickenverstellung_FB
VAR_INPUT

  (* BOOLEAN *)
  bpAktivieren                                   : BOOL; (* Hinweis: Baustein aktivieren *)
  bpReset                                        : BOOL;
  bpStartePositionierung                         : BOOL;
  bpReferenz                                     : BOOL;
  bpFreigabe                                     : BOOL;
  bpOptionMotorischAktivieren                    : BOOL;
  bpOptionPneumatikAktivieren                    : BOOL;
  bpOption3WegeLogikDrehen                       : BOOL;
  bpOptionRollenleisteSchuetzSchaltungAktivieren : BOOL;
  bpOptionGegenhalterSchuetzSchaltungAktivieren  : BOOL;
  
  (* ENUM *)
  epSollStellung : PneumatikZylinderStatus_EN;

  (* STRUCT *)
  stStationsNummern  : Station_ST;

  (* POINTER *)
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;
  ppParameterBaustein     : REFERENCE TO Parameter_Dickenverstellung;  (* Zeiger auf Parameterfeld *)
  
END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler                  : BOOL;
  bpDone                    : BOOL;
  bpResourceAktiv           : BOOL;
  bpInReferenz              : BOOL; (* Status: Baustein/Antrieb ist referenziert *)

  (* WORD *)
  wpFehlerNr : WORD;

  (* ENUM *)
  eStatusStellung : PneumatikZylinderStatus_EN;

END_VAR
VAR

  (* BOOLEAN *)
  blErsterZyklus   : BOOL := TRUE;

  (* REAL *)
  rlZielPosition   : REAL;

  (* TIMER *)
  tonlEndschalterFreifahren              : TON; (* EINSCHALTVERZOEGERUNG: *)
  tonlWarteSchrittEndschalterFreifahren  : TON; (* EINSCHALTVERZOEGERUNG: *)
  tonlMaxWarteAufResetErfolgreich        : TON; (* EINSCHALTVERZOEGERUNG: *)
  tofHardwareEndschalterFrei             : TOF; (* AUSSCHALTVERZOEGERUNG: *)
  toflAutoAbschaltung                    : TOF; (* AUSSCHALTVERZOEGERUNG: *)

  (* STEPS *)
  steplPositionieren    : Steps_TE;
  steplReferenz         : Steps_TE;
  steplReset            : Steps_TE;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR
(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN

  blErsterZyklus            := FALSE;
  
  Antrieb REF= pgAntriebe[ppAntriebsInformationen.wAchsID];

  (* Hinweis:
     - Für die Zielpunktkontrolle muss im ersten Zyklus die Zielposition initialisiert werden 
  *)
  Antrieb.rpZielPosition := Antrieb.rpIstPosition;

  IF ( __ISVALIDREF(ppAntriebsInformationen) ) THEN

    (* Hinweis:
       - Initialisierung Antriebsinformationen
    *)
    Antrieb.ppAntriebsInformationen REF= ppAntriebsInformationen;

    (* Hinweis:
       - Antriebswerte vorinitialisieren
    *)
    Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
    Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
    Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
    Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;

  END_IF

END_IF

(***************************************************************************************************)
(* BAUSTEIN: AUSFUEHRUNG *)
(***************************************************************************************************)
(* Hinweis:
   - Aktionen
*)
IF ( bpReset AND bpAktivieren ) THEN

  Reset();

ELSE

  IF ( bpAktivieren ) THEN
    Positionieren();
    Referenz();
    Ausgaenge();

    (* Hinweis:
       - Abschaltung
    *)
    toflAutoAbschaltung( IN :=     bpStartePositionierung
                               OR bpReferenz,
                             PT:= tgZeitAutoabschaltungEnergiesparModus );

    Antrieb.bpFreigabe := toflAutoAbschaltung.Q
                          AND bpAktivieren
                          AND bpFreigabe;

    Antrieb.rpRuckzeit := ppAntriebsInformationen.rpMaxRuckzeit;

    Antrieb.stStationsNummern := stStationsNummern;

  ELSE
    bpDone   := TRUE;
    bpFehler := FALSE;
    bpInReferenz := TRUE;

    eStatusStellung := epSollStellung;

    wpFehlerNr := 0;

  END_IF (* => bpAktiv *)

END_IF(* => bpReset *)
END_FUNCTION_BLOCK