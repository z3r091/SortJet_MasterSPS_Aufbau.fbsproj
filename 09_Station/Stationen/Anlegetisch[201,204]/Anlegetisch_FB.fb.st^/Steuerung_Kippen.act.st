(* METADATA
{
  "v3Meta": {
    "objectGuid": "c2ec1e80-268a-4855-9092-13890ee0dc70"
  }
}
*)
ACTION Steuerung_Kippen
(***************************************************************************************************)
(* AKTION: STEUERUNG KIPPEN [DURCHGANG] *)
(***************************************************************************************************)
blFreigabeTischKippen := ( NOT BasisStationsParameter.bAuftragAktiv
                          OR ( BasisStationsParameter.bAnlegen AND ( steplAnlegen <= STEP_100_E ) ) )
                          AND NOT Messachse.bpPositionierung
                          AND NOT Glastransport.bpSensorEinlauf
                          AND NOT Glastransport.bpSensorAuslauf
 //                         AND NOT Glastransport.Antrieb.bpReglerBereit    // Antrieb hat keine Freigabe mehr
 ;//                         AND NOT Messachse.Antrieb.bpReglerBereit; // Antrieb hat keine Freigabe mehr
	
// Ampel und Horn Warnsignal ausgeben	
out_bKipptischHornWarnsignal := out_bKipptischAmpelWarnsignal := ( in_bTasterAnforderungKippen OR in_bTasterAnforderungKippen_OP );			

IF ( ( in_bTasterAnforderungKippen OR in_bTasterAnforderungKippen_OP )
  AND blFreigabeTischKippen
  AND NOT out_bSchaltleisteAusgeloest )
THEN

  tonlStatusKippstatusUnten( IN := ( in_bSensorKipptischUnten AND NOT in_bSensorKipptischOben ),
                             PT :=  T#1s );

  tonlStatusKippenOben( IN := ( in_bSensorKipptischOben AND NOT in_bSensorKipptischUnten ),
                        PT := T#1s );


  out_bHydraulikpumpeEin := TRUE;

  IF ( ( in_bTasterKippenAuf
    OR in_bTasterKippenAb ) AND in_bTasterAnforderungKippen
    OR ( in_bTasterKippenAuf_OP
    OR in_bTasterKippenAb_OP  ) AND in_bTasterAnforderungKippen_OP)
  THEN
    out_bKippsicherungoeffnen := TRUE;
  ELSE
    out_bKippsicherungoeffnen := FALSE;
  END_IF

  IF  (  in_bSensorKippsicherungOffen
    AND NOT in_bSensorKippsicherungGeschlossen )
  THEN
    out_bKipptischAuf := NOT tonlStatusKippenOben.Q AND ( ( in_bTasterKippenAuf AND in_bTasterAnforderungKippen ) OR ( in_bTasterKippenAuf_OP AND in_bTasterAnforderungKippen_OP ) );
    out_bKipptischAb  := NOT tonlStatusKippstatusUnten.Q AND ( ( in_bTasterKippenAb AND in_bTasterAnforderungKippen ) OR ( in_bTasterKippenAb_OP AND in_bTasterAnforderungKippen_OP ) );
  ELSE               
    out_bKipptischAuf := FALSE;
    out_bKipptischAb  := FALSE;
  END_IF

ELSE

  out_bKippsicherungoeffnen := FALSE;
  out_bHydraulikpumpeEin    := FALSE;
  out_bKipptischAuf         := FALSE;
  out_bKipptischAb          := FALSE;

  tonlStatusKippstatusUnten( IN := FALSE);
  tonlStatusKippenOben( IN := FALSE);

END_IF
END_ACTION