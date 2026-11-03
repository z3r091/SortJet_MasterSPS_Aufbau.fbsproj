(* METADATA
{
  "v3Meta": {
    "objectGuid": "b30aafc3-3789-47a8-aab6-b8b866a10c4d"
  }
}
*)
ACTION SlaveAntrieb
//-------------------------------------------------------------------------------------------------
// AKTION: SLAVE ANTRIEB
//-------------------------------------------------------------------------------------------------
// Starten der Slave-Kopplung
blStarteSlaveKopplung := ( (    bpEintransport
                             OR bpEintransportRueckwaertig
                             OR bpAustransport
                             OR bpAustransportRueckwaertig
                             OR bpVortransport
                             OR bpVortransportRueckwaertig
                             OR bpMesskopplung
                             OR bpDurchtransport
                             OR bpHandfahrenPlus
                             OR bpHandfahrenMinus
                             OR bpGlaslaengenmessung
                             OR bpCheck )
                           AND NOT bpFehler );

IF (  blStarteSlaveKopplung
     AND NOT bpReset
     AND NOT bpReferenz )
THEN

  // Fehlerauswertung:
  //   - Antrieb
  //   - Sicherstellen das der Slavekopplung aktiv ist
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplSlave := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    Antrieb_Slave.wpBetriebsart:= KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplSlave := STEP_900_E;
  END_IF

  // Ueberwachung:
  //   - Kopplung muss in endlicher Zeit hergestellt sein, sonst warten die Ketten in STEP_0 ewig
  tonlSlaveKopplungHerstellen( IN := ( steplSlave < STEP_200_E ),
                               PT := cMAX_ZEIT_SLAVE_KOPPLUNG_HERSTELLEN );

  IF ( tonlSlaveKopplungHerstellen.Q ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_SLAVE_NICHT_AKTIV;
    steplSlave := STEP_900_E;
  END_IF

  CASE steplSlave OF
    // SLAVE ANTRIEB ====================
    STEP_0_E:
      IF ( Antrieb.bpReglerBereit AND Antrieb_Slave.bpReglerBereit ) THEN
        
        IF ( ( ABS(Antrieb.rpIstPosition) > rgSchwellwertReferenzieren ) 
             OR NOT Antrieb.bpIstReferenziert 
             OR ( ABS(Antrieb_Slave.rpIstPosition) > rgSchwellwertReferenzieren )
             OR NOT Antrieb_Slave.bpIstReferenziert )
        THEN
          Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          Antrieb_Slave.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          steplSlave := STEP_60_E;
        ELSE
          steplSlave := STEP_100_E;
        END_IF
      
      END_IF

    // SLAVE ANTRIEB ====================
    STEP_60_E:
      (* Hinweis:
         - Antrieb ist referenziert
      *)
      IF ( Antrieb.bpDone
           AND Antrieb_Slave.bpDone ) 
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        steplSlave := STEP_100_E;
      END_IF

    // SLAVE ANTRIEB ====================
    STEP_100_E:
      tonlUberwachungSlaveAktiv( IN := FALSE);

      Antrieb_Slave.wpMaster := ppAntriebsInformationen.wAchsID;
      Antrieb_Slave.wpBetriebsart        := SYNC_AUF_MASTER;

      IF ( Antrieb_Slave.bpDone ) THEN
        steplSlave := STEP_200_E;
      END_IF

    // SLAVE ANTRIEB ====================
    STEP_200_E:
      (* Anmerkung:
         - Überwachung ob die Achsen synchron laufen
      *)
      tonlUberwachungSlaveAktiv( IN := NOT blAntriebsKopplungAktiv,
                                 PT := cUEBERWACHUNG_SLAVE_AKTIV );


      IF ( tonlUberwachungSlaveAktiv.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_SLAVE_NICHT_AKTIV;
        steplSlave := STEP_900_E;
      END_IF

    // SLAVE ANTRIEB ====================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      Antrieb_Slave.wpBetriebsart:= KEINE_FUNKTION;
      bpFehler := TRUE;

    // SLAVE ANTRIEB ====================
    STEP_1000_E:
      ;

  // SLAVE ANTRIEB ====================
  END_CASE
ELSE

  tonlSlaveKopplungHerstellen( IN := FALSE );

  IF (steplSlave > STEP_0_E) THEN
    tonlUberwachungSlaveAktiv( IN := FALSE );
    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

    steplSlave := STEP_0_E;
  END_IF

END_IF
END_ACTION