(* METADATA
{
  "v3Meta": {
    "objectGuid": "8b6333e0-ac53-46a6-b75b-b633a8904a02"
  }
}
*)
ACTION Handfunktionen
(***************************************************************************************************)
(* HANDFUNKTIONEN  *)
(***************************************************************************************************)

IF ( bpBetriebsartHand
  AND NOT bpReferenz
  AND NOT bpReset
  AND NOT bpStarteDrehBewegung
  AND NOT bpStarteAbsolutPositionierung )
THEN

  IF bpInReferenz THEN

    CASE epDrehPositionsStatus OF

      eDrehPosition0Grad,
      eDrehPosition90Grad,
      eDrehPosition180Grad:
        Arretierung.bpStartAusfahren       := bpHandZentrierungAusfahren;
        Arretierung.bpStartEinfahren       := bpHandZentrierungEinfahren;

    ELSE

      Arretierung.bpStartAusfahren       := bpHandZentrierungAusfahren;
      Arretierung.bpStartEinfahren       := bpHandZentrierungEinfahren;
    END_CASE

  ELSE

    Arretierung.bpStartAusfahren       := bpHandZentrierungAusfahren;
    Arretierung.bpStartEinfahren       := bpHandZentrierungEinfahren;

  END_IF

END_IF
END_ACTION