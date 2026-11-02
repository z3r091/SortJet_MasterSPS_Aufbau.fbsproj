(* METADATA
{
  "v3Meta": {
    "objectGuid": "4412b2e8-80e3-4d41-9c3d-84963f94e3c1"
  }
}
*)
FUNCTION_BLOCK AnlegeAbnahmeWand_FB_V01_00_00 EXTENDS Basic_Station_FB_V01_00_00

VAR_INPUT

  // BOOLEAN
  bpFreigabeBereichsScanner : BOOL := TRUE; 

END_VAR

VAR

  // BOOLEAN
  // REAL
  rlScheibenHoehe            : REAL;
  rlAbstandZurNulllinie      : REAL;
    
  // INT
  ilScheibenZaehler          : INT;

  
  // TRIGGER
  rtlTasterQuittierung                  : R_TRIG;
  rtlFussleisteStart                    : R_TRIG;
  rtlGeblaese                           : R_TRIG;
  rtlTasterGeblaese                     : R_TRIG;
  rtlDrosselklappeOeffnen               : R_TRIG;
  ftlGeblaese                           : F_TRIG;
  ftEnergiesparmodusGeblaese            : F_TRIG;
  ftlGlastransportCheckMitNachfolger    : F_TRIG;

  // TIMER
  toflGeblaeseEnergiesparModus          : TOF;
  tonlQuittierungGlasAbgenommen         : TON; 
  tonlFreigabeErhalten                  : TON; 
  tofGeblaeseWirdAusGeschaltet          : TOF; 
  tonlGeblaseLauft                      : TON; 
  
  // TIME
  tlZeitBereitAnzulegen                 : TIME;
                                       
  // ENUM 
  epTypeHoehenmessung : ModusHoehenvermessung_EN;

  // BAUSTEINE 
  Glastransport     : AnlegeAbnahmeWand_Glastransport_FB_V01_00_00;
  Messachse         : Messachse_FB_V01_00_00;
  Kippen            : Kippen_FB_V01_00_00;
  Dickenverstellung : ZylinderPneumatik_3Wege_FB_V01_00_00;

END_VAR


VAR
  
  // Taster
  in_bFussTaster                                  : BOOL; // Signal Fusstaster
  in_bTasterGlasAngelegt                   AT %I* : BOOL; // Signal Scheibe ist angelegt gelber Leuchtdrucktaster
  in_bTasterFehlmessungQuittiern           AT %I* : BOOL; // Gelber Leuchtdrucktaster
  in_bKnebelGlastransportZurueck           AT %I* : BOOL; // Knebelschalter: Glastransport zurück
  in_bKnebelGlastransportVor               AT %I* : BOOL; // Knebelschalter: Glastransport vor
  in_bTasterQuittierungGlasAbgenommen      AT %I* : BOOL;
  in_bTasterGeblaeseEin                    AT %I* : BOOL; 
  in_bTasterGlasbruch                      AT %I* : BOOL;
  in_bLichtschrankeQuittiert               AT %I* : BOOL;
  in_bLichtschrankeFehler                  AT %I* : BOOL;
  in_bMotorschutzGeblaese_Ok               AT %I* : BOOL; 

  // HARDWARE AUSGAENGE
  out_bDrosselklappeOeffnen                       : BOOL; // Drosselklappe oeffnen / schliessen
  out_bAmpelSignalRot                             : BOOL; // rote Ampel an der Station
  out_bAmpelSignalGruen                           : BOOL; (* grüne Ampel an der Station *)//evtl mit GruenScheibeAnlegen zusammen führen
  out_bSignalScheibeAufgegeben             AT %Q* : BOOL; // grüner Leuchdrucktaster
  out_bSignalScheibeAbnehmen               AT %Q* : BOOL; // grüner Leuchdrucktaster
  out_bSignalScheibeFehlmessung            AT %Q* : BOOL; // gelber Leuchdrucktaster
  out_bSignalScheibeGlasbruch              AT %Q* : BOOL; // gelber Leuchdrucktaster
  out_bGeblaeseEin                         AT %Q* : BOOL; // Geblaese starten (Schuetz)
  out_bLichtschrankeAusgeloest             AT %Q* : BOOL; // Signal im OP das die Lichtschranke ausgelöst hat und nicht quittiert ist
  
    
END_VAR
//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);

//-------------------------------------------------------------------------------------------------
// DEAKTIVIEREN
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.stMKs.bDeaktivieren ) THEN
  HandfunktionenStatus();
  RETURN;
END_IF

//-------------------------------------------------------------------------------------------------
// IO ZUWEISUNG
//-------------------------------------------------------------------------------------------------
in_bFussTaster := pgAntriebe[Glastransport.ppAntriebsInformationen.wAchsID].udipEingaengeUmrichter.cXG37_2_IO_2;

Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_IO_3  := out_bAmpelSignalRot;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_IO_4  := out_bAmpelSignalGruen;
Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_6   := out_bDrosselklappeOeffnen;

//-------------------------------------------------------------------------------------------------
// AKTIONEN
//-------------------------------------------------------------------------------------------------
// Die fehlenden Aktionen werden im Master aufgerufen
A_Aufrufe();
A_Timer();

Referenz();
Reset();
SystemCheck();
Eintransport();
Anlegen();
Abnehmen();
Glashoehenmessung();
Glaslaengenmessung();
Austransport();
Handfunktionen();
Geblaese();
END_FUNCTION_BLOCK