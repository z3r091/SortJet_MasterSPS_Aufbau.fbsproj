(* METADATA
{
	"v3Meta": {
		"objectGuid": "0713858d-73c1-43e2-8e34-fbe80fbf8cab"
	}
}
*)
PROGRAM SteuerungSicherheitskreise
VAR_INPUT
  in_bTasterSKFaecherwagenQuittieren        AT %I* : BOOL; // Taster an OP fuer FW SK quittieren
  out_bLeuchtmelderSKFaecherwagenQuittieren AT %Q* : BOOL; 
  
  bpFreigabePuffer101Ausfahren                     : BOOL;
  
END_VAR
VAR_OUTPUT
END_VAR
VAR

  // BOOLEAN 
  ablSicherheitskreisFreigabeStation : ARRAY [cERSTE_STATION..cLETZTE_STATION] OF BOOL;
  ablSicherheitskreisFreigabeShuttle : ARRAY [cERSTES_SHUTTLE..cLETZTES_SHUTTLE] OF BOOL;
  ablSicherheitskreisFreigabeTransferShuttle : ARRAY [cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE] OF BOOL;
  ablSicherheitskreisAnfordernExtern : ARRAY [cERSTER_SICHERHEITSKREIS..cLETZTER_SICHERHEITSKREIS] OF BOOL;
  
  bpPuffer101ObenAusfahren           : BOOL;  
  bpPuffer103ObenAusfahren           : BOOL;
  bpPuffer102UntenAusfahren          : BOOL;
  bpPuffer104UntenAusfahren          : BOOL;
  bpPuffer101ObenEinfahren           : BOOL;  
  bpPuffer103ObenEinfahren           : BOOL;
  bpPuffer102UntenEinfahren          : BOOL;
  bpPuffer104UntenEinfahren          : BOOL;
  
  
  // STEPS
  steplPuffer101ObenAusfahren        : STEPS_TE;
  steplPuffer101ObenEinfahren        : STEPS_TE;
  steplPuffer102UntenAusfahren       : STEPS_TE;
  steplPuffer102UntenEinfahren       : STEPS_TE;
  steplPuffer103ObenAusfahren        : STEPS_TE;
  steplPuffer103ObenEinfahren        : STEPS_TE;
  steplPuffer104UntenAusfahren       : STEPS_TE;
  steplPuffer104UntenEinfahren       : STEPS_TE;
  
  // TIMER
  tonlPuffer101ObenAusfahren         : TON;
  tonlPuffer101ObenEinfahren         : TON;
  tonlPuffer102UntenAusfahren        : TON;
  tonlPuffer102UntenEinfahren        : TON;
  tonlPuffer103ObenAusfahren         : TON;
  tonlPuffer103ObenEinfahren         : TON;
  tonlPuffer104UntenAusfahren        : TON;
  tonlPuffer104UntenEinfahren        : TON;

  
  // WORD
  wlIndex                            : WORD;
  wlIndexSK                          : WORD;
  wlIndexTuer                        : WORD;
  wlIndexDurchgang                   : WORD;  
  wlMeldungsnummer                   : WORD;
  
  wlStatusPuffer101Oben_OLD          : WORD;
  wlStatusPuffer102Unten_OLD         : WORD;
  wlStatusPuffer103Oben_OLD          : WORD;
  wlStatusPuffer104Unten_OLD         : WORD;
  wlStatusTorOben_OLD                : WORD;
  wlStatusTorUnten_OLD               : WORD;
  
  
  out_bPuffer_101_Ausfahren   AT %Q* : BOOL;
  out_bPuffer_101_Einfahren   AT %Q* : BOOL;
  out_bPuffer_102_Ausfahren   AT %Q* : BOOL;
  out_bPuffer_102_Einfahren   AT %Q* : BOOL;
  out_bPuffer_103_Ausfahren   AT %Q* : BOOL;
  out_bPuffer_103_Einfahren   AT %Q* : BOOL;
  out_bPuffer_104_Ausfahren   AT %Q* : BOOL;
  out_bPuffer_104_Einfahren   AT %Q* : BOOL;
  
END_VAR
//-------------------------------------------------------------------------------------------------
// Aufrufe
//-------------------------------------------------------------------------------------------------
Freigabe_Stationen();
Meldungen();
Tueren();
Zuweisung_Freigabe();

// Aufruf Türen
FOR wlIndex := cERSTE_TUER TO cLETZTE_TUER DO
  aTuer[wlIndex](wMeldungsnummer := (ioccNotausAnTuer1Betaetigt - 1) + wlIndex  );
END_FOR

// Aufruf Durchgang
FOR wlIndex := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
  aDurchgang[wlIndex](ppParameterBaustein := (apgMKDurchgang[wlIndex]));
END_FOR

// Aufruf Sicherheitskreise
FOR wlIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  Sicherheitskreis[wlIndex]();  
END_FOR
END_PROGRAM