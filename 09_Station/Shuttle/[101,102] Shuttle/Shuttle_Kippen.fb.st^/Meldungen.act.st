(* METADATA
{
  "v3Meta": {
    "objectGuid": "8920fbd4-d47f-4dcd-867d-ed40f40a1858"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION MELDUNGEN *)
(***************************************************************************************************)

IF ( bpKippenSchuetz ) THEN
  
  IF (bpStartAbkippen OR bpStartAufkippen) THEN
  
    IF ( NOT bpFreigabe ) THEN
      wpFehlerNr := cMELDUNG_KIPPEN_KEINE_FREIGABE;
      bpFehler := TRUE;
      bpStartAufkippen := FALSE;
      bpStartAbkippen  := FALSE;
    END_IF
    
    IF bpStartAbkippen AND bpStartAufkippen THEN
      wpFehlerNr := cMELDUNG_KIPPEN_AUF_UND_ABKIPPEN_ZEITGLEICH_AKTIV;
      bpFehler := TRUE;
      bpStartAufkippen := FALSE;
      bpStartAbkippen  := FALSE;
    END_IF
  
  END_IF

  IF ( NOT in_bSensorNicht90Grad AND NOT in_bSensorNicht84Grad ) AND tonlTeilnehmerErreichbar.Q AND bpKippenSchuetz THEN
    wpFehlerNr := cMELDUNG_KIPPEN_BEIDE_KIPPSENSOREN_BELEGT;
    bpFehler         := TRUE;
    bpStartAufkippen := FALSE;
    bpStartAbkippen  := FALSE;
  END_IF

  toflMotorSicherungOK( IN := in_bMotorschutzschalter_OK , PT := T#5S );
  IF ( NOT toflMotorSicherungOK.Q ) AND tonlTeilnehmerErreichbar.Q THEN
    wpFehlerNr := cMELDUNG_KIPPEN_SICHERUNG_NICHT_OK;
    bpFehler         := TRUE;
    bpStartAufkippen := FALSE;
    bpStartAbkippen  := FALSE;
  END_IF
  
  toflMotorstarterOK( IN := in_bMotorstarter_OK , PT := T#5S );
  IF ( NOT toflMotorstarterOK.Q ) AND tonlTeilnehmerErreichbar.Q THEN
    wpFehlerNr := cMELDUNG_KIPPEN_MOTORSTARTER_NICHT_OK;
    bpFehler         := TRUE;
    bpStartAufkippen := FALSE;
    bpStartAbkippen  := FALSE;
  END_IF

 

ELSE
  IF( NOT bpFehler
      AND Antrieb.bpFehler )
  THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    bpFehler := TRUE;
  END_IF

END_IF
END_ACTION