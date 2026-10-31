(* METADATA
{
  "v3Meta": {
    "objectGuid": "09c7eecd-c04d-4e36-bb54-bd65882750d8"
  }
}
*)
ACTION FahrrichtungErkennung
rlDistanzSeitLetzterPosition := rpIstPosition - rlLetzteIstPosition;
IF ABS(rlDistanzSeitLetzterPosition) > 0.1
THEN
  IF rlLetzteIstPosition < rpIstPosition THEN
    eBewegungsrichtung := TE_Move_Direction.MD_POSITIV_E;
  ELSIF rlLetzteIstPosition > rpIstPosition THEN
    eBewegungsrichtung := TE_Move_Direction.MD_NEGATIV_E;
  END_IF
  tonlAuswertungBewegungsrichtung(IN := FALSE);
ELSE
  tonlAuswertungBewegungsrichtung(IN := TRUE, PT := T#100MS);
  IF tonlAuswertungBewegungsrichtung.Q
  THEN
    eBewegungsrichtung := TE_Move_Direction.MD_STANDSTILL_E;
  END_IF
END_IF
rlLetzteIstPosition := rpIstPosition;
END_ACTION