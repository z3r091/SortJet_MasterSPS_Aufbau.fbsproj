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
   - Faecherwagen vorhanden: Variante Einfach (bpFaecherwagenVorhanden), Variante Lineareinheit
     nutzt stattdessen bpLichtschranke_OK und bpUntergestellErkannt
   - Bei Wechsel der Variante einer Instanz die Zuweisungen hier anpassen
*)
aFaecherwagenstation[301].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station301_Geschlossen;
aFaecherwagenstation[302].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station302_Geschlossen;
aFaecherwagenstation[303].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station303_Geschlossen;
aFaecherwagenstation[304].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station304_Geschlossen;
aFaecherwagenstation[305].bpRolltorUnten        := EV_ToPLC_HarpRack.EV_ToPLC_bRolltor_Station305_Geschlossen;

aFaecherwagenstation[301].bpFaecherwagenVorhanden := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station301_Vorhanden;
aFaecherwagenstation[302].bpFaecherwagenVorhanden := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station302_Vorhanden;
aFaecherwagenstation[303].bpFaecherwagenVorhanden := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station303_Vorhanden;
aFaecherwagenstation[304].bpFaecherwagenVorhanden := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station304_Vorhanden;
aFaecherwagenstation[305].bpFaecherwagenVorhanden := EV_ToPLC_HarpRack.EV_ToPLC_bUnterwagen_Station305_Vorhanden;

// Durchgang 203: Klapprahmen geschlossen (Sicherheitssensor, SK3)
aDurchgang[1].bpDurchgangGeschlossen := EV_ToPLC_b203_geschlossen;
END_ACTION