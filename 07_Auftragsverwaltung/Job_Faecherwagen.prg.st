(* METADATA
{
	"v3Meta": {
		"objectGuid": "77979386-6e9b-45aa-8f8e-3d53a4bcfd74"
	}
}
*)
PROGRAM Job_Faecherwagen
VAR_INPUT

  // BOOL
  abpReset  : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
  
END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  abpFehler : ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;

END_VAR
VAR

  // BOOL
  blErsterZyklus          : BOOL := TRUE;
  blMerkerAuftragsabbruch : BOOL;
  awMerkerStatusFaecherwagenstationen : ARRAY[0..29] OF WORD;

  // WORD
  wlIndex                    : WORD;
  wlIndexReset               : WORD;
  wlIndexFaecherwagenStation : WORD;

  // INT
  ilBitPosition              : INT;
  ilIndexWordArray           : INT;

  // DWORD
  dwDifference : DWORD;

  // TRIGGER
  rtlErwzungenesAuschleusen  : ARRAY [cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR] OF R_TRIG;
  rtlErwzungenesEinschleusen : ARRAY [cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR] OF R_TRIG;
  rtlAutomatikKreis          : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF R_TRIG;
  rtlSystemCheckKreis        : ARRAY [cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF R_TRIG;

  // ARRAY
  tonlUeberwachungFaecherwagenPosition  : ARRAY[cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR] OF TON;
  rtlUeberwachungFaecherwagenPosition   : ARRAY[cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR] OF R_TRIG;
  rtlUeberwachungFaecherwagenPosition2  : ARRAY[cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR] OF R_TRIG;

END_VAR

VAR CONSTANT

  // WORD
  cBIT_ANZAHL_WORD : WORD := 16;
  
END_VAR

(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  blErsterZyklus := FALSE;
END_IF

(***************************************************************************************************)
(* BELADUNGS STATUS *)
(***************************************************************************************************)
(* Hinweis:
   - Abfrage des Status der Faecherwagenstation
     => 0 = frei
     => 1 = belegt
   - Das MMI fragt an welche Beladestationen belegt sind. Steht in dem ersten Wort z.B. die 301 als SPS Nummer
     Steht im ersten Wort der Antwort der Status dieser Station (siehe nächste Nachricht)
*)
IF ( M_SB0_MMI_REQUESTSTATUSLOADINGSTATIONS OR SlowTask.rtrigECatOK.Q OR Job.rtlMmiOk.Q ) AND bgEtherCatOK THEN

  M_SB0_MMI_REQUESTSTATUSLOADINGSTATIONS := FALSE;

  (* Hinweis:
     - Werte zuruecksetzen
  *)
  wlIndex       := WORD#0;
  ilBitPosition := INT#0;

  (* Hinweis:
     - Der Index ist [MMI_Var] fix auf 0-29 angelegt
  *)
  FOR ilIndexWordArray := 0 TO 29 DO
    awSps2MmiStatusFaecherwagenstationen[ilIndexWordArray] := WORD#0;
  END_FOR

  (* Hinweis:
     - Status der Stationen wird Bit-Codiert uebergeben 
       => z.B.: Bit 0 = 301 | Bit 15 = 316
  *) 
  FOR wlIndexFaecherwagenStation := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

    (* Hinweis:
       - Ein Bit kann gesetzt als auch zurueck gesetzt werden 
    *)
    IF ( aFaecherwagenStation[wlIndexFaecherwagenStation].bpStatusStationInBeladePosition ) THEN
      awSps2MmiStatusFaecherwagenstationen[wlIndex] := BitToggleWord( IN := awSps2MmiStatusFaecherwagenstationen[wlIndex], POS := ilBitPosition );
    END_IF

    IF ( ilBitPosition >= ( WORD_TO_INT(cBIT_ANZAHL_WORD) - 1) ) THEN
      wlIndex := INT_TO_WORD(INCI( WORD_TO_INT(wlIndex), 30 ));
    END_IF

    ilBitPosition := INCI( ilBitPosition, WORD_TO_INT(cBIT_ANZAHL_WORD) );

  END_FOR


  MsgToMmi(auftragsnr_w := SB0_SPS_SETSTATUSLOADINGSTATIONS );

END_IF

(* Hinweis:
   - Status der Stationen erstellen
*) 
wlIndex       := WORD#0;
ilBitPosition := INT#0;

FOR ilIndexWordArray := 0 TO 29 DO
  awMerkerStatusFaecherwagenstationen[ilIndexWordArray] := WORD#0;
END_FOR
FOR wlIndexFaecherwagenStation := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

  IF ( aFaecherwagenStation[wlIndexFaecherwagenStation].bpStatusStationInBeladePosition ) THEN
    awMerkerStatusFaecherwagenstationen[wlIndex] := BitToggleWord( IN := awMerkerStatusFaecherwagenstationen[wlIndex], POS := ilBitPosition );
  END_IF

  IF ( ilBitPosition >= ( WORD_TO_INT(cBIT_ANZAHL_WORD) - 1) ) THEN
    wlIndex := INT_TO_WORD( INCI( WORD_TO_INT(wlIndex), 30 ));
  END_IF

  ilBitPosition := INCI( ilBitPosition, WORD_TO_INT(cBIT_ANZAHL_WORD) );

END_FOR

dwDifference := DINT_TO_DWORD(SysMemCmp( ADR ( awSps2MmiStatusFaecherwagenstationen ), ADR( awMerkerStatusFaecherwagenstationen ), SIZEOF( awMerkerStatusFaecherwagenstationen )));
IF( dwDifference <> 0 AND bgEtherCatOK ) THEN
  awSps2MmiStatusFaecherwagenstationen := awMerkerStatusFaecherwagenstationen;
  MsgToMmi(auftragsnr_w := SB0_SPS_SETSTATUSLOADINGSTATIONS );
END_IF

(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
FWAuftraege();
Reset();
END_PROGRAM