(* METADATA
{
	"v3Meta": {
		"objectGuid": "d815e3f2-dcd5-4a25-9c13-c3ee247e2cce"
	}
}
*)
FUNCTION_BLOCK Dickenverstellung_FB_V01_00_00
VAR_INPUT

  // BOOLEAN
  bpAktivieren                                   : BOOL; // Hinweis: Baustein aktivieren
  bpReset                                        : BOOL;
  bpStartePositionierung                         : BOOL;
  bpReferenz                                     : BOOL;
  bpFreigabe                                     : BOOL;
  bpOptionMotorischAktivieren                    : BOOL;
  bpOptionPneumatikAktivieren                    : BOOL;
  bpOption3WegeLogikDrehen                       : BOOL;
  bpOptionRollenleisteSchuetzSchaltungAktivieren : BOOL;
  bpOptionGegenhalterSchuetzSchaltungAktivieren  : BOOL;

  // ENUM
  epSollStellung : PneumatikZylinderStatus_EN;

  // STRUCT
  stStationsNummern  : Station_ST;

  // POINTER
  ppAntriebsInformationen : REFERENCE TO AntriebsInformationen;
  ppParameterBaustein     : REFERENCE TO Parameter_Dickenverstellung;  // Zeiger auf Parameterfeld

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpFehler                  : BOOL;
  bpDone                    : BOOL;
  bpResourceAktiv           : BOOL;
  bpInReferenz              : BOOL; // Status: Baustein/Antrieb ist referenziert

  // WORD
  wpFehlerNr : Fehlerkonstanten_EN;

  // ENUM
  eStatusStellung : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // BOOLEAN
  blErsterZyklus   : BOOL := TRUE;

  // REAL
  rlZielPosition   : REAL;

  // TIMER
  tonlEndschalterFreifahren              : TON; // EINSCHALTVERZOEGERUNG:
  tonlWarteSchrittEndschalterFreifahren  : TON; // EINSCHALTVERZOEGERUNG:
  tonlMaxWarteAufResetErfolgreich        : TON; // EINSCHALTVERZOEGERUNG:
  tofHardwareEndschalterFrei             : TOF; // AUSSCHALTVERZOEGERUNG:
  toflAutoAbschaltung                    : TOF; // AUSSCHALTVERZOEGERUNG:

  // STEPS
  steplPositionieren    : Steps_TE;
  steplReferenz         : Steps_TE;
  steplReset            : Steps_TE;

  // Antrieb
  Antrieb : REFERENCE TO Rexroth_ctrlX_Drive_Eckelmann_MC_V01_02_02;

END_VAR
VAR_INPUT

  // HARDWARE EINGAENGE
  in_bEndschalterMax : BOOL; // Oeffner (TRUE = frei), gemappt; zum Umrichter ueber Signal-Steuerwort Bit 9, wirkt nur bei Endschalterquelle SPS

END_VAR
//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
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

// Endschalter zyklisch an den Antrieb geben, auch bei deaktivierter Bewegung
Antrieb.bpEndschalterMaxExtern := in_bEndschalterMax;

//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSFUEHRUNG
//-------------------------------------------------------------------------------------------------
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

    wpFehlerNr := cMELDUNG_NULL;

  END_IF // => bpAktiv

END_IF// => bpReset
END_FUNCTION_BLOCK