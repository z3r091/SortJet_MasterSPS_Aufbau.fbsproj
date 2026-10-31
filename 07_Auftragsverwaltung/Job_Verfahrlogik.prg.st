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
VAR CONSTANT
	cUMRECHNUNG_METER_MINUTE_ZU_MILLIMETER_SEKUNDE : REAL := 16.6666666666667;
	cUMRECHNUNG_METER_ZU_MILLIMETER                : REAL := 1000;
END_VAR


(***************************************************************************************************)
(* AUFTRAG: VERFAHRLOGIK [QUERFAHRT] SHUTTLE *)
(***************************************************************************************************)
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

      (* WICHTIG:
         - Fuellen der Positionier-Auftragsstruktur 
           => Variablen werden erst alle gefüllt mit der Verfahrlogik HMI 2.0.0.0
      *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.wStationsNummer                    := tMmi2SpsInfo.wVorabStationsNr;                                                       (* Hinweis: Stationsnummer *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rSollPosition                      := tMmi2SpsInfo.rVorabPositionierung;                                                   (* Hinweis: Soll Position (Ziel) *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rBeschleunigungsrampe              := tMmi2SpsInfo.rVorabBeschleunigung * cUMRECHNUNG_METER_ZU_MILLIMETER;                 (* Hinweis: Beschleunigungsrampe in mm/s^2 *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rVerzoegerungsrampe                := tMmi2SpsInfo.rVorabVerzoegern * cUMRECHNUNG_METER_ZU_MILLIMETER;                     (* Hinweis: Verzögerungsrampe in mm/s^2 *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rSollGeschwindigkeit               := tMmi2SpsInfo.rVorabGeschwindigkeit *cUMRECHNUNG_METER_MINUTE_ZU_MILLIMETER_SEKUNDE ; (* Hinweis: Soll geschwindigkeit in mm/s^2 *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rNennstromBeschleunigungsphase     := tMmi2SpsInfo.rNennstromBeschleunigungsphase;                                         (* Hinweis: Nennstrom (A) in der Beschleunigungsphase *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rNennstromKonstantfahrt            := tMmi2SpsInfo.rNennstromKonstantfahrt;                                                (* Hinweis: Nennstrom (A) in derKonstantfahrt *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rZeitintervalBeschleunigungsphase  := tMmi2SpsInfo.rZeitintervalBeschleunigungsphase;                                      (* Hinweis: Zeit / Dauer der Beschleunigungsphase *)
      Job_Stationen.AuftragsSpeicherStation[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.wAuftragstyp                       := tMmi2SpsInfo.wVorabAuftragstyp;                                                      (* Hinweis: Zeit / Dauer der Beschleunigungsphase *)
                                                                         
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

      (* WICHTIG:
         - Fuellen der Positionier-Auftragsstruktur 
           => Variablen werden erst alle gefüllt mit der Verfahrlogik HMI 2.0.0.0
      *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.wStationsNummer                    := tMmi2SpsInfo.wVorabStationsNr;                                                       (* Hinweis: Stationsnummer *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rSollPosition                      := tMmi2SpsInfo.rVorabPositionierung;                                                   (* Hinweis: Soll Position (Ziel) *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rBeschleunigungsrampe              := tMmi2SpsInfo.rVorabBeschleunigung * cUMRECHNUNG_METER_ZU_MILLIMETER;                 (* Hinweis: Beschleunigungsrampe in mm/s^2 *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rVerzoegerungsrampe                := tMmi2SpsInfo.rVorabVerzoegern * cUMRECHNUNG_METER_ZU_MILLIMETER;                     (* Hinweis: Verzögerungsrampe in mm/s^2 *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rSollGeschwindigkeit               := tMmi2SpsInfo.rVorabGeschwindigkeit *cUMRECHNUNG_METER_MINUTE_ZU_MILLIMETER_SEKUNDE ; (* Hinweis: Soll geschwindigkeit in mm/s^2 *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rNennstromBeschleunigungsphase     := tMmi2SpsInfo.rNennstromBeschleunigungsphase;                                         (* Hinweis: Nennstrom (A) in der Beschleunigungsphase *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rNennstromKonstantfahrt            := tMmi2SpsInfo.rNennstromKonstantfahrt;                                                (* Hinweis: Nennstrom (A) in derKonstantfahrt *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rZeitintervalBeschleunigungsphase  := tMmi2SpsInfo.rZeitintervalBeschleunigungsphase;                                      (* Hinweis: Zeit / Dauer der Beschleunigungsphase *)
      Job_Shuttle.AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.wAuftragstyp                       := tMmi2SpsInfo.wVorabAuftragstyp;                                                      (* Hinweis: Zeit / Dauer der Beschleunigungsphase *)

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

      (* WICHTIG:
         - Fuellen der Positionier-Auftragsstruktur 
           => Variablen werden erst alle gefüllt mit der Verfahrlogik HMI 2.0.0.0
      *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.wStationsNummer                    := tMmi2SpsInfo.wVorabStationsNr;                                                       (* Hinweis: Stationsnummer *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rSollPosition                      := tMmi2SpsInfo.rVorabPositionierung;                                                   (* Hinweis: Soll Position (Ziel) *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rBeschleunigungsrampe              := tMmi2SpsInfo.rVorabBeschleunigung * cUMRECHNUNG_METER_ZU_MILLIMETER;                 (* Hinweis: Beschleunigungsrampe in mm/s^2 *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rVerzoegerungsrampe                := tMmi2SpsInfo.rVorabVerzoegern * cUMRECHNUNG_METER_ZU_MILLIMETER;                     (* Hinweis: Verzögerungsrampe in mm/s^2 *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rSollGeschwindigkeit               := tMmi2SpsInfo.rVorabGeschwindigkeit *cUMRECHNUNG_METER_MINUTE_ZU_MILLIMETER_SEKUNDE ; (* Hinweis: Soll geschwindigkeit in mm/s^2 *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rNennstromBeschleunigungsphase     := tMmi2SpsInfo.rNennstromBeschleunigungsphase;                                         (* Hinweis: Nennstrom (A) in der Beschleunigungsphase *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rNennstromKonstantfahrt            := tMmi2SpsInfo.rNennstromKonstantfahrt;                                                (* Hinweis: Nennstrom (A) in derKonstantfahrt *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.rZeitintervalBeschleunigungsphase  := tMmi2SpsInfo.rZeitintervalBeschleunigungsphase;                                      (* Hinweis: Zeit / Dauer der Beschleunigungsphase *)
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.pPositionierAuftrag.wAuftragstyp                       := tMmi2SpsInfo.wVorabAuftragstyp;                                                      (* Hinweis: Zeit / Dauer der Beschleunigungsphase *)

      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr].NeuerAuftrag.wAuftrag := eStation_Vorabpositionierung;
      Job_Shuttle.AuftragsSpeicherShuttle[tMmi2SpsInfo.wVorabStationsNr](bpNeuerAuftrag := TRUE);

    ELSE
      ;

  END_CASE

END_IF
END_PROGRAM