(* METADATA
{
  "v3Meta": {
    "objectGuid": "8ef5bc36-5f76-46e1-a5ac-606d922f719c"
  }
}
*)
ACTION A_Schnittstelle
(***************************************************************************************************)
(* AKTION SCHNITTSTELLE *)
(***************************************************************************************************)

BasisStationsParameter.OutGlasTransport[cWAND_1].stStationsNummern          := BasisStationsParameter.stMKs.stStationsNummern;
BasisStationsParameter.OutGlasTransport[cWAND_1].wStationsTyp               := BasisStationsParameter.stMKs.eStationsTyp;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor             REF= bEmpfaengerSensorEinlauf;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor             REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport     REF= blBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport     REF= blBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit           REF= rpGeschwindigkeit;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFehler                    REF= BasisStationsParameter.bFehler;
BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe              REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFreigabe                  REF= BasisStationsParameter.bFreigabe;
BasisStationsParameter.OutGlasTransport[cWAND_1].bTransportAbgeschlossen    REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAutomatikBetriebAktiv     REF= blAutomatikBetriebAktiv;


//   - Status der Sortierung [Hardware- Ausgaenge]
//     => Automatik ativ
//     => Kein Fehler aktiv
out_bSenderBereit := blSenderBereit :=         BasisStationsParameter.bAutomatik
                                       AND NOT BasisStationsParameter.bFehler
                                       AND NOT BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bFehler;
																								
out_bSenderGlasBereit := blSenderGlasBereit (*OR bgVisu_Schnittstelle_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]*);

// Eingangssignale können über den Drive oder IO's kommen
bEmpfaengerSensorEinlauf := bpEmpfaengerSensorEinlauf OR in_bEmpfaengerSensorEinlauf;


(***************************************************************************************************)
(* VISU *)
(***************************************************************************************************)
bgVisu_Schnittstelle_GlasBereit[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS]    := out_bSenderGlasBereit;
END_ACTION