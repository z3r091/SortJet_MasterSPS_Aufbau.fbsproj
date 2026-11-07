(* METADATA
{
	"v3Meta": {
		"objectGuid": "ed8f1b73-31c7-4f7a-ada4-9c4fd3f36895"
	}
}
*)
ACTION HeglaBrechanlage_Schnittstelle
//-------------------------------------------------------------------------------------------------
// HARDWARESIGNALE: AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Ausgaenge:
//   - Transport-Signale
out_bGlasAbruf     := InGlasTransportNachfolger.bBereitZumEintransport;

// Sensor:
//   - Einlaufsensor
out_bSensorEinlauf := InGlasTransportNachfolger.bEinlaufsensor;


// Anforderung:
//   - Sicherheitskreis
out_bAnforderungSK := bpAnforderungSK;

// Geschwindigkeit übergeben
out_wSpeed := 32767 / 1166 * REAL_TO_WORD(InGlasTransportNachfolger.rGeschwindigkeit);
END_ACTION