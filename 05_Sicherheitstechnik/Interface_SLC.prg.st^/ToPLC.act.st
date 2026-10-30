(* METADATA
{
	"v3Meta": {
		"objectGuid": "2230cbd9-0764-4dd0-8a6d-fa77d75d3bc5"
	}
}
*)
ACTION ToPLC
(***************************************************************************************************)
(* AKTION ToPLC *)
(***************************************************************************************************)
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
END_ACTION