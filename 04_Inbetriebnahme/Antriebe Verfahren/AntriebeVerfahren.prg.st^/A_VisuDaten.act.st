(* METADATA
{
	"v3Meta": {
		"objectGuid": "10e8df39-1363-4584-9b71-7e84e662ac8e"
	}
}
*)
ACTION A_VisuDaten
//-------------------------------------------------------------------------------------------------
// DATENAUFBEREITUNG FUER DIE VISU "Antriebe_Verfahren"
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Alle Texte und Farben der Status- und Diagnosezeilen werden hier gebildet, die Visu zeigt nur an
   - Einheiten nach Achstyp (MK-Achsflag Bit 0 = rotativ): mm bzw. Grad
*)
stlAchse REF= pgAntriebe[wgAuswahlAchsID];

blRotativ      := stlAchse.l_ts_MKAxisConfig.dwAxisFlags.0;
sEinheitPos    := SEL( blRotativ, ' mm',    ' °' );
sEinheitGeschw := SEL( blRotativ, ' mm/s',  ' °/s' );
sEinheitBeschl := SEL( blRotativ, ' mm/s²', ' °/s²' );

sAchsKopf := CONCAT( CONCAT( 'ID ', WORD_TO_STRING( wgAuswahlAchsID ) ), '   ' );
IF ( stlAchse.slAchsname <> '' ) THEN
  sAchsKopf := CONCAT( CONCAT( sAchsKopf, stlAchse.slAchsname ), SEL( blRotativ, '   (linear)', '   (rotativ)' ) );
ELSE
  sAchsKopf := CONCAT( sAchsKopf, '(nicht vorhanden)' );
END_IF

// 1 Achszustand
CASE stlAchse.eAchsStatus OF
  AXIS_VALID:
    asWert[1] := 'gültig';              adwFarbe[1] := VISU_UEBERSICHT.cFARBE_GRUEN;
  AXIS_STOPPING:
    asWert[1] := 'stoppt';              adwFarbe[1] := VISU_UEBERSICHT.cFARBE_ORANGE;
  AXIS_ERROR_OR_DISABLED:
    IF ( stlAchse.l_mc_ReadStatus.Errorstop ) THEN
      asWert[1] := 'ERRORSTOP';         adwFarbe[1] := VISU_UEBERSICHT.cFARBE_ROT;
    ELSE
      asWert[1] := 'ohne Regelung';     adwFarbe[1] := VISU_UEBERSICHT.cFARBE_GRAU;
    END_IF
ELSE
    asWert[1] := 'unbekannt';           adwFarbe[1] := VISU_UEBERSICHT.cFARBE_ORANGE;
END_CASE

// 2 / 3 Betriebsart aktiv / angefordert
asWert[2] := VisuAv_Betriebsart( stlAchse.wlAktiveBetriebsart );
adwFarbe[2] := SEL( stlAchse.wlAktiveBetriebsart = KEINE_FUNKTION, VISU_UEBERSICHT.cFARBE_BLAU, VISU_UEBERSICHT.cFARBE_GRAU );
asWert[3] := VisuAv_Betriebsart( stlAchse.wpBetriebsart );
adwFarbe[3] := SEL( stlAchse.wpBetriebsart = KEINE_FUNKTION, VISU_UEBERSICHT.cFARBE_BLAU, VISU_UEBERSICHT.cFARBE_GRAU );

// 4 Freigabe
IF ( stlAchse.bpAntriebFreigegeben ) THEN
  asWert[4] := SEL( stlAchse.bpFreigabeErzwingen, 'erteilt', 'erteilt (erzwungen)' );
  adwFarbe[4] := SEL( stlAchse.bpFreigabeErzwingen, VISU_UEBERSICHT.cFARBE_GRUEN, VISU_UEBERSICHT.cFARBE_ORANGE );
ELSE
  asWert[4] := 'keine';                 adwFarbe[4] := VISU_UEBERSICHT.cFARBE_GRAU;
END_IF

// 5 Regler bereit
asWert[5] := SEL( stlAchse.bpReglerBereit, 'nein', 'ja' );
adwFarbe[5] := SEL( stlAchse.bpReglerBereit, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_GRUEN );

// 6 Referenz
asWert[6] := SEL( stlAchse.bpIstReferenziert, 'nicht referenziert', 'referenziert' );
adwFarbe[6] := SEL( stlAchse.bpIstReferenziert, VISU_UEBERSICHT.cFARBE_ORANGE, VISU_UEBERSICHT.cFARBE_GRUEN );

// 7 Fehler
IF ( stlAchse.bpFehler ) THEN
  asWert[7] := CONCAT( CONCAT( 'Baustein ', DWORD_TO_STRING( stlAchse.Antriebsfehler.wlBausteinFehlerNr ) ),
                       CONCAT( ' / Antrieb ', DWORD_TO_STRING( stlAchse.Antriebsfehler.wlAntriebsFehler ) ) );
  adwFarbe[7] := VISU_UEBERSICHT.cFARBE_ROT;
ELSE
  asWert[7] := 'kein Fehler';           adwFarbe[7] := VISU_UEBERSICHT.cFARBE_GRUEN;
END_IF

// 8 Bewegung
IF ( stlAchse.bpAntrieblaeuft ) THEN
  asWert[8] := SEL( stlAchse.bpBewegungsrichtungNegativ, 'läuft +', 'läuft -' );
  adwFarbe[8] := VISU_UEBERSICHT.cFARBE_BLAU;
ELSIF ( stlAchse.bpMotionAktiv ) THEN
  asWert[8] := 'Bewegung aktiv';        adwFarbe[8] := VISU_UEBERSICHT.cFARBE_BLAU;
ELSE
  asWert[8] := 'Stillstand';            adwFarbe[8] := VISU_UEBERSICHT.cFARBE_GRAU;
END_IF

// 9 / 10 Ist-Position / Ist-Geschwindigkeit
asWert[9]  := VisuAv_Zahl( rWert := stlAchse.rpIstPosition,        uiNachkomma := 2, sEinheit := sEinheitPos );
asWert[10] := VisuAv_Zahl( rWert := stlAchse.rpIstGeschwindigkeit, uiNachkomma := 1, sEinheit := sEinheitGeschw );
adwFarbe[9]  := VISU_UEBERSICHT.cFARBE_TEXT;
adwFarbe[10] := VISU_UEBERSICHT.cFARBE_TEXT;

// 11 Endschalter
IF ( stlAchse.bpMinSchalterBelegt AND stlAchse.bpMaxSchalterBelegt ) THEN
  asWert[11] := 'MIN und MAX belegt';   adwFarbe[11] := VISU_UEBERSICHT.cFARBE_ROT;
ELSIF ( stlAchse.bpMinSchalterBelegt ) THEN
  asWert[11] := 'MIN belegt';           adwFarbe[11] := VISU_UEBERSICHT.cFARBE_ROT;
ELSIF ( stlAchse.bpMaxSchalterBelegt ) THEN
  asWert[11] := 'MAX belegt';           adwFarbe[11] := VISU_UEBERSICHT.cFARBE_ROT;
ELSE
  asWert[11] := 'frei';                 adwFarbe[11] := VISU_UEBERSICHT.cFARBE_GRUEN;
END_IF

// 12 Bremse
asWert[12] := SEL( stlAchse.bpBremseGeloest, 'geschlossen', 'gelöst' );
adwFarbe[12] := SEL( stlAchse.bpBremseGeloest, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_ORANGE );

// 13 Versorgung
IF ( stlAchse.bpHaupschalter400VEin AND stlAchse.bpLS_150F02_230V ) THEN
  asWert[13] := '400 V und 230 V ok';   adwFarbe[13] := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSIF ( NOT stlAchse.bpHaupschalter400VEin AND NOT stlAchse.bpLS_150F02_230V ) THEN
  asWert[13] := '400 V und 230 V aus';  adwFarbe[13] := VISU_UEBERSICHT.cFARBE_ROT;
ELSIF ( NOT stlAchse.bpHaupschalter400VEin ) THEN
  asWert[13] := '400 V aus';            adwFarbe[13] := VISU_UEBERSICHT.cFARBE_ROT;
ELSE
  asWert[13] := 'LS 230 V aus';         adwFarbe[13] := VISU_UEBERSICHT.cFARBE_ROT;
END_IF

// 14 Langsamfahrt
asWert[14] := SEL( stlAchse.bpLangsamfahrenAktiv, 'aus', 'aktiv' );
adwFarbe[14] := SEL( stlAchse.bpLangsamfahrenAktiv, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_ORANGE );

// 15 Master/Slave
IF ( stlAchse.bpAchseSychron ) THEN
  asWert[15] := CONCAT( 'synchron zu ', WORD_TO_STRING( stlAchse.wpMaster ) );
  adwFarbe[15] := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSE
  asWert[15] := 'nicht gekoppelt';      adwFarbe[15] := VISU_UEBERSICHT.cFARBE_GRAU;
END_IF

// 16 Referenzbit: S-0-0277 Bit 11 (Firmware 0612), Pruefung einmalig nach dem Hochlauf
IF ( stlAchse.blS277PruefungNotwendig ) THEN
  asWert[16] := SEL( stlAchse.blCoeS277ReadGestartet, 'Prüfung ausstehend', 'wird gelesen' );
  adwFarbe[16] := SEL( stlAchse.blCoeS277ReadGestartet, VISU_UEBERSICHT.cFARBE_ORANGE, VISU_UEBERSICHT.cFARBE_BLAU );
ELSIF ( stlAchse.udiEncoderProperties.11 ) THEN
  asWert[16] := 'Bit 11 gesetzt';       adwFarbe[16] := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSE
  asWert[16] := 'Bit 11 FEHLT';         adwFarbe[16] := VISU_UEBERSICHT.cFARBE_ROT;
END_IF

// 17 Messtaster-Funktion (CoE 0x60B8)
IF ( stlAchse.uiTouchProbeStatus.0 ) THEN
  asWert[17] := 'aktiv';                adwFarbe[17] := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSIF ( stlAchse.blTouchprobeScheibenAktiv ) THEN
  asWert[17] := 'wird aktiviert';       adwFarbe[17] := VISU_UEBERSICHT.cFARBE_BLAU;
ELSE
  asWert[17] := 'nicht aktiv';          adwFarbe[17] := VISU_UEBERSICHT.cFARBE_ORANGE;
END_IF

// 18 / 19 Messtaster-Positionen
asWert[18] := CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.rpPositionMesstaster1Positiv, uiNachkomma := 2, sEinheit := '' ), '  /  ' ),
                      VisuAv_Zahl( rWert := stlAchse.rpPositionMesstaster1Negativ, uiNachkomma := 2, sEinheit := sEinheitPos ) );
asWert[19] := CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.rpPositionMesstaster2Positiv, uiNachkomma := 2, sEinheit := '' ), '  /  ' ),
                      VisuAv_Zahl( rWert := stlAchse.rpPositionMesstaster2Negativ, uiNachkomma := 2, sEinheit := sEinheitPos ) );
adwFarbe[18] := VISU_UEBERSICHT.cFARBE_TEXT;
adwFarbe[19] := VISU_UEBERSICHT.cFARBE_TEXT;

// 20 Scheibenmessung
IF ( stlAchse.bpMessungOk ) THEN
  asWert[20] := CONCAT( 'OK  ', VisuAv_Zahl( rWert := stlAchse.rpMessErgebnis, uiNachkomma := 2, sEinheit := sEinheitPos ) );
  adwFarbe[20] := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSIF ( stlAchse.bpMessungFehlerhaft ) THEN
  asWert[20] := 'fehlerhaft';           adwFarbe[20] := VISU_UEBERSICHT.cFARBE_ROT;
ELSE
  asWert[20] := VisuAv_Zahl( rWert := stlAchse.rpMessErgebnis, uiNachkomma := 2, sEinheit := sEinheitPos );
  adwFarbe[20] := VISU_UEBERSICHT.cFARBE_GRAU;
END_IF

// 21 Restweg
asWert[21] := SEL( stlAchse.bpRestwegMaterialGefunden, 'kein Material erkannt', 'Material gefunden' );
adwFarbe[21] := SEL( stlAchse.bpRestwegMaterialGefunden, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_GRUEN );

// 22 Absolut setzen
IF ( stlAchse.bpAbsolutSetzenDone ) THEN
  asWert[22] := 'fertig';               adwFarbe[22] := VISU_UEBERSICHT.cFARBE_GRUEN;
ELSIF ( stlAchse.bpAbsolutSetzen ) THEN
  asWert[22] := 'läuft';                adwFarbe[22] := VISU_UEBERSICHT.cFARBE_BLAU;
ELSE
  asWert[22] := '-';                    adwFarbe[22] := VISU_UEBERSICHT.cFARBE_GRAU;
END_IF

// 23 Verfahrbereich aktiv (Software-Endschalter inkl. externer Eingrenzung)
asWert[23] := CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.rpMinPosition, uiNachkomma := 1, sEinheit := '' ), '  ...  ' ),
                      VisuAv_Zahl( rWert := stlAchse.rpMaxPosition, uiNachkomma := 1, sEinheit := sEinheitPos ) );

// 24 Software-Endschalter aus der MK-Achskonfiguration (0 / 0 = nicht aktiv)
asWert[24] := CONCAT( CONCAT( VisuAv_Zahl( rWert := LREAL_TO_REAL( stlAchse.l_ts_MKAxisConfig.lrSoftwareLimitNegative ), uiNachkomma := 1, sEinheit := '' ), '  ...  ' ),
                      VisuAv_Zahl( rWert := LREAL_TO_REAL( stlAchse.l_ts_MKAxisConfig.lrSoftwareLimitPositive ), uiNachkomma := 1, sEinheit := sEinheitPos ) );

// 25 .. 27 Grenzwerte aus der SPS-MK (AntriebsInformationen): rotativ zusaetzlich in U/min, linear in m/min
IF ( __ISVALIDREF( stlAchse.ppAntriebsInformationen ) ) THEN
  IF ( blRotativ ) THEN
    asWert[25] := CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxGeschwindigkeit, uiNachkomma := 0, sEinheit := sEinheitGeschw ), '  =  ' ),
                          VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxGeschwindigkeit * 60.0 / 360.0, uiNachkomma := 1, sEinheit := ' U/min' ) );
  ELSE
    asWert[25] := CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxGeschwindigkeit, uiNachkomma := 0, sEinheit := sEinheitGeschw ), '  =  ' ),
                          VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxGeschwindigkeit * 60.0 / 1000.0, uiNachkomma := 1, sEinheit := ' m/min' ) );
  END_IF
  asWert[26] := CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxBeschleunigung, uiNachkomma := 0, sEinheit := '' ), '  /  ' ),
                        VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxVerzoegerung, uiNachkomma := 0, sEinheit := sEinheitBeschl ) );
  asWert[27] := VisuAv_Zahl( rWert := stlAchse.ppAntriebsInformationen.rpMaxRuckzeit, uiNachkomma := 0, sEinheit := ' ms' );
ELSE
  asWert[25] := '-';
  asWert[26] := '-';
  asWert[27] := '-';
END_IF

// 28 / 29 Grenzwerte aus der MK-Achskonfiguration (E°ConSet), begrenzen die Fahrwerte im Baustein
asWert[28] := CONCAT( CONCAT( CONCAT( VisuAv_Zahl( rWert := stlAchse.l_ts_MKAxisConfig.rVelocity, uiNachkomma := 0, sEinheit := '' ), '  /  ' ),
                              CONCAT( VisuAv_Zahl( rWert := stlAchse.l_ts_MKAxisConfig.rAcceleration, uiNachkomma := 0, sEinheit := '' ), '  /  ' ) ),
                      VisuAv_Zahl( rWert := stlAchse.l_ts_MKAxisConfig.rDeceleration, uiNachkomma := 0, sEinheit := '' ) );
asWert[29] := VisuAv_Zahl( rWert := stlAchse.l_ts_MKAxisConfig.rRampTime, uiNachkomma := 3, sEinheit := ' s' );

FOR wlNcZeile := 23 TO 29 DO
  adwFarbe[wlNcZeile] := VISU_UEBERSICHT.cFARBE_TEXT;
END_FOR

//-------------------------------------------------------------------------------------------------
// AUSWAHLFENSTER DER ACHSEN (nur Achsen mit Namen, in ID-Reihenfolge)
//-------------------------------------------------------------------------------------------------
IF ( blAuswahlOffen ) THEN
  wlAuswahlAnzahl := 0;
  FOR wlNcIndex := 0 TO 65 DO
    IF ( pgAntriebe[wlNcIndex].slAchsname <> '' ) THEN
      awlAuswahlId[wlAuswahlAnzahl] := wlNcIndex;
      asAuswahl[wlAuswahlAnzahl]    := CONCAT( CONCAT( WORD_TO_STRING( wlNcIndex ), '   ' ), pgAntriebe[wlNcIndex].slAchsname );
      IF ( wlNcIndex = wgAuswahlAchsID ) THEN
        adwAuswahl[wlAuswahlAnzahl] := VISU_UEBERSICHT.cFARBE_BLAU;
      ELSIF ( pgAntriebe[wlNcIndex].bpFehler ) THEN
        adwAuswahl[wlAuswahlAnzahl] := VISU_UEBERSICHT.cFARBE_ROT;
      ELSIF ( NOT pgAntriebe[wlNcIndex].bpIstReferenziert ) THEN
        adwAuswahl[wlAuswahlAnzahl] := VISU_UEBERSICHT.cFARBE_ORANGE;
      ELSE
        adwAuswahl[wlAuswahlAnzahl] := VISU_UEBERSICHT.cFARBE_GRAU;
      END_IF
      wlAuswahlAnzahl := wlAuswahlAnzahl + 1;
    END_IF
  END_FOR
  FOR wlNcIndex := 0 TO 65 DO
    abAuswahlFrei[wlNcIndex] := ( wlNcIndex >= wlAuswahlAnzahl );
  END_FOR
END_IF

//-------------------------------------------------------------------------------------------------
// OVERRIDE-LEISTE
//-------------------------------------------------------------------------------------------------
sOverride := VisuAv_Zahl( rWert := rpOverrideVisu, uiNachkomma := 0, sEinheit := ' %' );
IF ( NOT bpOverrideWirksam ) THEN
  sOverride := CONCAT( sOverride, '  (nicht aktiv)' );
END_IF

FOR wlNcZeile := 1 TO 10 DO
  IF ( rpOverrideVisu >= WORD_TO_REAL( wlNcZeile * 10 ) - 0.1 ) THEN
    adwOverrideStufe[wlNcZeile] := SEL( bpOverrideWirksam, VISU_UEBERSICHT.cFARBE_GRAU, VISU_UEBERSICHT.cFARBE_BLAU );
  ELSE
    adwOverrideStufe[wlNcZeile] := VISU_UEBERSICHT.cFARBE_GRAU_HELL;
  END_IF
END_FOR

//-------------------------------------------------------------------------------------------------
// NC-FEHLERLISTE (PRG_NcErrors, Ringpuffer mit 16 Eintraegen, neuester oben)
//-------------------------------------------------------------------------------------------------
sNcKopf := CONCAT( 'Einträge gesamt: ', UDINT_TO_STRING( PRG_NcErrors.udiErrorsLogged ) );
IF ( PRG_NcErrors.xOverrun ) THEN
  sNcKopf := CONCAT( sNcKopf, '   (NC-Puffer übergelaufen)' );
END_IF

FOR wlNcZeile := 0 TO 15 DO
  IF ( WORD_TO_UDINT( wlNcZeile ) < PRG_NcErrors.udiErrorsLogged ) THEN
    wlNcIndex := ( UINT_TO_WORD( PRG_NcErrors.uiLogIdx ) + 15 - wlNcZeile ) MOD 16;
    wlNcAchse := UINT_TO_WORD( PRG_NcErrors.aInstance[wlNcIndex] );

    asNc[wlNcZeile] := CONCAT( 'Achse ', WORD_TO_STRING( wlNcAchse ) );
    IF ( wlNcAchse <= 65 ) THEN
      IF ( pgAntriebe[wlNcAchse].slAchsname <> '' ) THEN
        asNc[wlNcZeile] := CONCAT( CONCAT( asNc[wlNcZeile], ' (' ), CONCAT( pgAntriebe[wlNcAchse].slAchsname, ')' ) );
      END_IF
    END_IF
    asNc[wlNcZeile] := CONCAT( CONCAT( asNc[wlNcZeile], '   Kl. ' ), BYTE_TO_STRING( PRG_NcErrors.aCategory[wlNcIndex] ) );
    asNc[wlNcZeile] := CONCAT( CONCAT( asNc[wlNcZeile], '   Code ' ), DINT_TO_STRING( PRG_NcErrors.aCode[wlNcIndex] ) );
    asNc[wlNcZeile] := CONCAT( CONCAT( asNc[wlNcZeile], '   ' ), PRG_NcErrors.aMessage[wlNcIndex] );
  ELSE
    asNc[wlNcZeile] := '';
  END_IF
END_FOR
END_ACTION