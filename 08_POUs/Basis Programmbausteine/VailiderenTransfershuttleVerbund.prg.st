(* METADATA
{
  "v3Meta": {
    "objectGuid": "53cd760f-4cde-42f5-90aa-7a00051f7bed"
  }
}
*)
PROGRAM VailiderenTransfershuttleVerbund
VAR
END_VAR

VAR_INPUT

  // WORD
  wTransferstation1 : WORD;
  wTransferstation2 : WORD;

END_VAR

VAR_OUTPUT

  // BOOL
  bpFehler : BOOL;

  // WORD
  wTransferstationMaster : WORD;
  wTransferstationSlave  : WORD;


END_VAR


//-------------------------------------------------------------------------------------------------
// BAUSTEIN: LOGIK
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Fehler ggf. zuruecksetzen
*)
bpFehler := FALSE;

(* Hinweis:
   - Validieren
*)
IF (  ( PruefungWertImIntervall(wTransferstation1, cERSTES_TRANSFERSHUTTLE , cLETZTES_TRANSFERSHUTTLE ) )
     AND ( PruefungWertImIntervall(wTransferstation2, cERSTES_TRANSFERSHUTTLE , cLETZTES_TRANSFERSHUTTLE ) ) )
THEN

  IF (      ( starrTransfershuttleBasisParameter[wTransferstation1].stMKs.stStationsOptionen.stTransfershuttle.bMasterStation = TRUE )
       AND NOT ( starrTransfershuttleBasisParameter[wTransferstation2].stMKs.stStationsOptionen.stTransfershuttle.bMasterStation = TRUE ) )
  THEN
    wTransferstationMaster := wTransferstation1;
    wTransferstationSlave  := wTransferstation2;

  ELSIF (   ( starrTransfershuttleBasisParameter[wTransferstation2].stMKs.stStationsOptionen.stTransfershuttle.bMasterStation = TRUE )
          AND NOT ( starrTransfershuttleBasisParameter[wTransferstation1].stMKs.stStationsOptionen.stTransfershuttle.bMasterStation = TRUE ) )
  THEN
    wTransferstationMaster := wTransferstation2;
    wTransferstationSlave  := wTransferstation1;

  ELSE
    bpFehler := TRUE;

    wTransferstationMaster := wTransferstation1;
    wTransferstationSlave  := wTransferstation2;

    wpgFehlerdaten[0] := wTransferstation1;
    wpgFehlerdaten[0] := wTransferstation2;
    SpsHinweis( eFehler_Station,
                cMELDUNG_TS_KONNTE_KEIN_MASTER_TS_ERMITTELT_WERDEN,
                wTransferstation1,
                AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wTransferstation1].stMKs.stStationsNummern.NummerSPS),
                wpgFehlerdaten );

  (* Anmerkung:
     - Hier muesste ein fehler geworfen werden
  *)

  END_IF


ELSE
  bpFehler := TRUE;

(* Anmerkung:
   - Hier muesste ein fehler geworfen werden
*)

END_IF
END_PROGRAM