(* METADATA
{
	"v3Meta": {
		"objectGuid": "e2245dfb-7a4f-4b2e-8ea2-abea4deaa4b5"
	}
}
*)
PROGRAM Job_Verfahrlogik
VAR
END_VAR


//-------------------------------------------------------------------------------------------------
// AUFTRAG: VERFAHRLOGIK [QUERFAHRT] SHUTTLE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Steuerung der Verfahrbewegungen durch die Oberflaeche
     => Verfahrlogik
*)
IF ( M_SB0_MMI_SHUTTLEVORABPOSITIONIERUNG ) THEN
  M_SB0_MMI_SHUTTLEVORABPOSITIONIERUNG := FALSE;


  CASE tMmi2SpsInfo.wVorabStationsNr OF

    cERSTE_STATION..cLETZTE_STATION:
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabPosition                    := tMmi2SpsInfo.rVorabPositionierung;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabUpdateZeit                  := tMmi2SpsInfo.rVorabUpdateZeit;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabBeschleunigung              := tMmi2SpsInfo.rVorabBeschleunigung;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabBremsrampe                  := tMmi2SpsInfo.rVorabVerzoegern;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabGeschwindigkeit             := tMmi2SpsInfo.rVorabGeschwindigkeit;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rNennstromBeschleunigungsphase    := tMmi2SpsInfo.rNennstromBeschleunigungsphase;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rNennstromKonstantfahrt           := tMmi2SpsInfo.rNennstromKonstantfahrt;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rZeitintervalBeschleunigungsphase := tMmi2SpsInfo.rZeitintervalBeschleunigungsphase;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wVorabAuftragstyp                 := tMmi2SpsInfo.wVorabAuftragstyp;

      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wAuftrag := eStation_Vorabpositionierung;
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr](bpNeuerAuftrag := TRUE);


    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabPosition                    := tMmi2SpsInfo.rVorabPositionierung;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabUpdateZeit                  := tMmi2SpsInfo.rVorabUpdateZeit;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabBeschleunigung              := tMmi2SpsInfo.rVorabBeschleunigung;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabBremsrampe                  := tMmi2SpsInfo.rVorabVerzoegern;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabGeschwindigkeit             := tMmi2SpsInfo.rVorabGeschwindigkeit;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rNennstromBeschleunigungsphase    := tMmi2SpsInfo.rNennstromBeschleunigungsphase;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rNennstromKonstantfahrt           := tMmi2SpsInfo.rNennstromKonstantfahrt;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rZeitintervalBeschleunigungsphase := tMmi2SpsInfo.rZeitintervalBeschleunigungsphase;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wVorabAuftragstyp                 := tMmi2SpsInfo.wVorabAuftragstyp;

      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wAuftrag := eStation_Vorabpositionierung;
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr](bpNeuerAuftrag := TRUE);

    cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabPosition                    := tMmi2SpsInfo.rVorabPositionierung;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabUpdateZeit                  := tMmi2SpsInfo.rVorabUpdateZeit;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabBeschleunigung              := tMmi2SpsInfo.rVorabBeschleunigung;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabBremsrampe                  := tMmi2SpsInfo.rVorabVerzoegern;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rVorabGeschwindigkeit             := tMmi2SpsInfo.rVorabGeschwindigkeit;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rNennstromBeschleunigungsphase    := tMmi2SpsInfo.rNennstromBeschleunigungsphase;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rNennstromKonstantfahrt           := tMmi2SpsInfo.rNennstromKonstantfahrt;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.rZeitintervalBeschleunigungsphase := tMmi2SpsInfo.rZeitintervalBeschleunigungsphase;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wVorabAuftragstyp                 := tMmi2SpsInfo.wVorabAuftragstyp;

      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wAuftrag := eStation_Vorabpositionierung;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr](bpNeuerAuftrag := TRUE);

    ELSE
      ;

  END_CASE

END_IF
END_PROGRAM