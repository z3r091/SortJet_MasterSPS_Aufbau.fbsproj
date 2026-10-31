(* METADATA
{
  "v3Meta": {
    "objectGuid": "9344cd08-074d-4d9b-8f38-9deed52e1a06"
  }
}
*)
ACTION Stillstandsposition
// rpIstGeschwindigkeit [mm/s]
// rpIstPosition        [mm]
// rlVerzoegerung       [mm/s²]
// rpRuckzeit           [ms]

IF ABS(rpIstGeschwindigkeit) <= 0 OR rlVerzoegerung <= 0 THEN
  rpStillstandsPosition := rpIstPosition;
ELSE
  IF rpRuckzeit > 0 THEN
    IF ABS(rpIstGeschwindigkeit) >= rlVerzoegerung * (rpRuckzeit / 1000.0) THEN
      rpStillstandsPosition :=
      (ABS(rpIstGeschwindigkeit) * ABS(rpIstGeschwindigkeit)) / (2.0 * rlVerzoegerung)
      + (ABS(rpIstGeschwindigkeit) * (rpRuckzeit / 1000.0)) / 2.0;
    ELSE
      rpStillstandsPosition :=
      SQRT(
        ABS(rpIstGeschwindigkeit) * ABS(rpIstGeschwindigkeit) * ABS(rpIstGeschwindigkeit)
        * (rpRuckzeit / 1000.0)
        / rlVerzoegerung
      );
    END_IF;
  ELSE
    rpStillstandsPosition := (ABS(rpIstGeschwindigkeit) * ABS(rpIstGeschwindigkeit)) / (2.0 * rlVerzoegerung);
  END_IF;

  // Reaktionsweg durch Tasklaufzeit: 2 ms
  IF rpIstGeschwindigkeit > 0 THEN
    rpStillstandsPosition := rpStillstandsPosition + ABS(rpIstGeschwindigkeit) * 0.002;
  ELSE
    rpStillstandsPosition := rpStillstandsPosition + ABS(rpIstGeschwindigkeit) * 0.002;
  END_IF

  IF rpIstGeschwindigkeit > 0 THEN
    rpStillstandsPosition := rpIstPosition + rpStillstandsPosition;
  ELSE
    rpStillstandsPosition := rpIstPosition - rpStillstandsPosition;
  END_IF;
END_IF;
END_ACTION