(* METADATA
{
  "v3Meta": {
    "objectGuid": "4b006156-55f0-4052-a03b-8c052b439175"
  }
}
*)
ACTION A_Schnittstelle
(***************************************************************************************************)
(* SCHNITTSTELLE *)
(***************************************************************************************************)

(* --------------------------------------------------------------------------------------- *)

(* Hinweis:
   - Schnittstelle zwischen den Stationen [Transportkopplung]
*)
BasisStationsParameter.OutGlasTransport[cWAND_1].stStationsNummern      := BasisStationsParameter.stMKs.stStationsNummern;
BasisStationsParameter.OutGlasTransport[cWAND_1].bEinlaufsensor         REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bAuslaufsensor         REF= bgFALSE;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumAustransport REF= bpOutBereitZumAustransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].bBereitZumEintransport REF= bpOutBereitZumEintransport;
BasisStationsParameter.OutGlasTransport[cWAND_1].rGeschwindigkeit       REF= rgNULL;
BasisStationsParameter.OutGlasTransport[cWAND_1].bFehler                REF= bpFehler;

dwpHandfunktionen := BasisStationsParameter.dwHandfunktionen;
END_ACTION