(* METADATA
{
  "v3Meta": {
    "objectGuid": "c640e471-237d-4bdc-a1be-7d3bf2dbdd78"
  }
}
*)
ACTION Ausgaenge
(***************************************************************************************************)
(* AKTION AUSGAENGE *)
(***************************************************************************************************)
(* Ausgaeng:
   - Aktuelle Geschwindigkeit des Antriebs
     -> Soll- Wertkopplung ( Soll-Geschwindigkeit des Antriebs)
     -> Ist- Wertkopplung ( Soll-Geschwindigkeit des Antriebs)
*)
IF  ((  bpEintransport AND bpOutBereitZumEintransport )
  OR ( bpCheck         AND bpOutBereitZumEintransport ))
THEN
  rpOutGeschwindigkeit := ABS(Antrieb.rpGeschwindigkeit);
ELSE
  rpOutGeschwindigkeit := ABS(Antrieb.rpIstGeschwindigkeit);
END_IF

(* Ausgaeng:
   - Verfahrfreigabe
*)
bpVerfahrFreigabe :=     NOT bpSensorEinlauf
                     AND NOT bpSensorAuslaufStopp
                     AND NOT bpAustransport
                     AND ( NOT bpEintransport OR bpFreigabeQuerfahrt );


bpAuftragAktiv :=    bpEintransport
                  OR bpRueckwaertsEintransportieren
                  OR bpAustransport
                  OR bpRueckwaertsAustransportieren
                  OR bpVortransport
                  OR bpVortransportRueck
                  OR bpCheck;
END_ACTION