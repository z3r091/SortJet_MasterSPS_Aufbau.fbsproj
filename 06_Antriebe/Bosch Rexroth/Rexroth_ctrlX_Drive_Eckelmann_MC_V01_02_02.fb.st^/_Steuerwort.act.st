(* METADATA
{
	"v3Meta": {
		"objectGuid": "2cb5236d-2c9d-4e67-a004-d0a59f43b200"
	}
}
*)
ACTION _Steuerwort
// Alle Steuerwort-Bits werden ausschliesslich in dieser Aktion beschrieben.

// Externe Endschalter nur bei Quelle SPS weitergeben, sonst Frei-Pegel (Oeffner: TRUE = frei)
blEndschalterAusSPS := FALSE;
IF __ISVALIDREF(ppAntriebsInformationen) THEN
  blEndschalterAusSPS := ppAntriebsInformationen.stOptionen.eEndschalterQuelle = Endschalterquelle_EN.SPS;
END_IF

SignalSteuerWort.0  := blReferenzLoeschen;
SignalSteuerWort.1  := wlAusgaengeUmrichter.3;
SignalSteuerWort.2  := wlAusgaengeUmrichter.4;
SignalSteuerWort.3  := wlAusgaengeUmrichter.5;
SignalSteuerWort.4  := wlAusgaengeUmrichter.6;
SignalSteuerWort.5  := wlAusgaengeUmrichter.7;
SignalSteuerWort.6  := wlAusgaengeUmrichter.8;
SignalSteuerWort.7  := wlAusgaengeUmrichter.9;
SignalSteuerWort.8  := wlAusgaengeUmrichter.10;
SignalSteuerWort.9  := NOT blEndschalterAusSPS OR bpEndschalterMaxExtern;
SignalSteuerWort.10 := NOT blEndschalterAusSPS OR bpEndschalterMinExtern;
SignalSteuerWort.11 := FALSE;
SignalSteuerWort.12 := FALSE;
SignalSteuerWort.13 := FALSE;
SignalSteuerWort.14 := blReferenzSetzen;
SignalSteuerWort.15 := blBremseLoesen;
END_ACTION