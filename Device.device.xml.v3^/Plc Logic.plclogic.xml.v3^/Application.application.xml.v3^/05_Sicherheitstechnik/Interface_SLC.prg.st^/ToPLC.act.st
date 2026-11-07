(* METADATA
{
	"v3Meta": {
		"objectGuid": "2230cbd9-0764-4dd0-8a6d-fa77d75d3bc5"
	}
}
*)
ACTION ToPLC
//-------------------------------------------------------------------------------------------------
// AKTION ToPLC
//-------------------------------------------------------------------------------------------------
// Türen quittiert von SLC OK
FOR wIndex := cERSTE_TUER TO cLETZTE_TUER DO
  aTuer[wIndex].bpTuerRelaisQuittiert           := GetBitFromWord(EV_ToPLC_Tueren_Verriegelt, (wIndex-1));
  aTuer[wIndex].bpTuerGeschlossen               := GetBitFromWord(EV_ToPLC_Tueren_Verriegelt, (wIndex+8-1));
  aTuer[wIndex].in_bTasterNothaltNichtBetaetigt := ( GetBitFromWord(EV_ToPLC_Tueren_Nothalt_aktiv, (wIndex-1)) ) OR bpOperatorAcknowledgeRequested;
END_FOR

// Sicherheitskreis geschlossen von SLC OK
FOR wIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  Sicherheitskreis[wIndex].bpSicherheitskreisGeschlossenSafety := GetBitFromWord(EV_ToPLC_SK_OK, (wIndex-1)) OR bgSicherheitstechnikBruecken;
  
  // Wenn SK geschlossen wird EDM Fehler Reset ausführen
  rtlSKQuittiert[wIndex]( CLK := Sicherheitskreis[wIndex].bpSicherheitskreisGeschlossen );
  toflSKQuittiert[wIndex]( IN := rtlSKQuittiert[wIndex].Q, PT := T#100MS );
  
END_FOR

// Not-Halt von SLC OK
NotHalt.bpEingangNotHaltOK     := EV_ToPLC_bNothalt_OK;

// Faecherwagenstationen von SLC
(* Hinweis:
   - Rolltor unten: alle Varianten mit Rolltor
   - Lichtschranke und Unterwagen: nur Variante Lineareinheit (Eingaenge bpLichtschranke_OK, bpUntergestellErkannt)
   - Bei Wechsel der Variante einer Instanz die Zuweisungen hier anpassen
   - Fuer 304 und 305 gibt es noch keine Signale in EV_ToPLC_HarpRack
*)
aFaecherwagenstation[301].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station301_Geschlossen;
aFaecherwagenstation[302].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station302_Geschlossen;
aFaecherwagenstation[303].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station303_Geschlossen;

aFaecherwagenstation[301].bpLichtschranke_OK    := EV_ToPLC_HarpRack.EV_ToPLC_bLichtschranke_Station301_OK;
aFaecherwagenstation[302].bpLichtschranke_OK    := EV_ToPLC_HarpRack.EV_ToPLC_bLichtschranke_Station302_OK;
aFaecherwagenstation[303].bpLichtschranke_OK    := EV_ToPLC_HarpRack.EV_ToPLC_bLichtschranke_Station303_OK;

aFaecherwagenstation[301].bpUntergestellErkannt := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station301_Vorhanden;
aFaecherwagenstation[302].bpUntergestellErkannt := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station302_Vorhanden;
aFaecherwagenstation[303].bpUntergestellErkannt := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station303_Vorhanden;
END_ACTION