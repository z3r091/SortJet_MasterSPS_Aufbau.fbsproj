(* METADATA
{
  "v3Meta": {
    "objectGuid": "62302654-e6b2-4422-aa92-378ed6b39485"
  }
}
*)
ACTION Slave_Antrieb
//-------------------------------------------------------------------------------------------------
// AKTION: SLAVE_ANTRIEB
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Starten der Slave-Kopplung
*)
blStarteSlaveKopplung := ( (    bpEintransport
                             OR bpRueckwaertsEintransportieren
                             OR bpAustransport
                             OR bpRueckwaertsAustransportieren
                             OR bpVortransport
                             OR bpVortransportRueck
                             OR bpDurchtransport
                             OR bpStarteSensorFreiFahren
                             OR bpStarteVorabPositionierung
                             OR bpHandfahrenPlus
                             OR bpHandfahrenMinus
                             OR bpCheck )
                           AND NOT bpFehler );

IF (  blStarteSlaveKopplung
     AND NOT bpReset
     AND NOT bpFahreReferenz )
THEN

  // Fehlerauswertung:
  //   - Antrieb
  //   - Sicherstellen das der Slavekopplung aktiv ist
  IF ( Antrieb_Slave.bpFehler ) THEN
    blAntriebsKopplungAktiv := FALSE;
    Antrieb_Slave.wpBetriebsart:= KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplSlave := STEP_900_E;
  END_IF


  CASE steplSlave OF
    // SLAVE BETRIEB ====================
    STEP_0_E:

      blAntriebsKopplungAktiv := FALSE;

      IF ( Antrieb.bpReglerBereit AND Antrieb_Slave.bpReglerBereit ) THEN

        IF ( ( ABS(Antrieb.rpIstPosition) > rgSchwellwertReferenzieren ) 
             OR NOT Antrieb.bpIstReferenziert 
             OR ( ABS(Antrieb_Slave.rpIstPosition) > rgSchwellwertReferenzieren )
             OR NOT Antrieb_Slave.bpIstReferenziert )
        THEN
          Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          Antrieb_Slave.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          steplSlave := STEP_20_E;
        ELSE
          steplSlave := STEP_30_E;
        END_IF
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlSlaveAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit AND Antrieb_Slave.bpReglerBereit ),
                                        PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlSlaveAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplSlave := STEP_900_E;
      END_IF

    // SLAVE BETRIEB ====================
    STEP_20_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone
           AND Antrieb_Slave.bpDone ) 
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        steplSlave := STEP_30_E;
      END_IF

    // SLAVE BETRIEB ====================
    STEP_30_E:
      tonlUberwachungSlaveAktiv( IN := FALSE);

      Antrieb_Slave.wpMaster := ppAntriebsInformationen.wAchsID;
      Antrieb_Slave.wpBetriebsart := SYNC_AUF_MASTER;

      IF ( Antrieb_Slave.bpDone ) THEN
        blAntriebsKopplungAktiv := TRUE;
        steplSlave := STEP_40_E;
      END_IF

    // SLAVE BETRIEB ====================
    STEP_40_E:
      (* Anmerkung:
         - Überwachung ob die Achsen synchron laufen
      *)
      tonlUberwachungSlaveAktiv( IN := NOT blAntriebsKopplungAktiv,
                                 PT := cUEBERWACHUNG_SLAVE_AKTIV );


      IF ( tonlUberwachungSlaveAktiv.Q ) THEN
        blAntriebsKopplungAktiv := FALSE;
        Antrieb_Slave.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_SLAVE_NICHT_AKTIV;
        steplSlave := STEP_900_E;
      END_IF

    // SLAVE BETRIEB ====================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      Antrieb_Slave.wpBetriebsart:= KEINE_FUNKTION;
      blAntriebsKopplungAktiv := FALSE;
      bpFehler := TRUE;

    // SLAVE BETRIEB ====================
    STEP_1000_E:
      blAntriebsKopplungAktiv := FALSE;

  // SLAVE BETRIEB ====================
  END_CASE
ELSE

  IF (steplSlave > STEP_0_E) THEN
    tonlUberwachungSlaveAktiv( IN := FALSE );
    blAntriebsKopplungAktiv := FALSE;
    Antrieb_Slave.wpBetriebsart:= KEINE_FUNKTION;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlSlaveAntriebNichtFreigegeben( IN := FALSE );
    steplSlave := STEP_0_E;
  END_IF

END_IF
END_ACTION