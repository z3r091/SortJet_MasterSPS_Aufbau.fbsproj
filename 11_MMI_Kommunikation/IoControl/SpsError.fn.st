(* METADATA
{
	"v3Meta": {
		"objectGuid": "8b5c3fca-ed53-4ab3-83d7-c24b940f4322"
	}
}
*)
FUNCTION SpsError : BOOL
VAR_INPUT
  wpFehlerGruppe    : WORD;
  wpErrorNr         : WORD;
  wpStationsnummmer : WORD;
  wpAutomatikkreis  : WORD;
  awpDaten          : ARRAY [0..25] OF WORD;
END_VAR
VAR
  smlMessage : SpsMessage;
END_VAR


smlMessage.wAuftrag := SB0_SPS_ERROR;

smlMessage.awDaten[0] := HMI_GetWORD(ADR(wpFehlerGruppe));
smlMessage.awDaten[1] := HMI_GetWORD(ADR(wpErrorNr));
smlMessage.awDaten[2] := HMI_GetWORD(ADR(wpStationsnummmer));
smlMessage.awDaten[3] := HMI_GetWORD(ADR(wpAutomatikkreis));

HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 8  , wVal := awpDaten[0] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 10 , wVal := awpDaten[1] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 12 , wVal := awpDaten[2] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 14 , wVal := awpDaten[3] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 16 , wVal := awpDaten[4] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 18 , wVal := awpDaten[5] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 20 , wVal := awpDaten[6] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 22 , wVal := awpDaten[7] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 24 , wVal := awpDaten[8] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 26 , wVal := awpDaten[9] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 28 , wVal := awpDaten[10] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 30 , wVal := awpDaten[11] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 32 , wVal := awpDaten[12] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 34 , wVal := awpDaten[13] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 36 , wVal := awpDaten[14] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 38 , wVal := awpDaten[15] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 40 , wVal := awpDaten[16] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 42 , wVal := awpDaten[17] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 44 , wVal := awpDaten[18] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 46 , wVal := awpDaten[19] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 48 , wVal := awpDaten[20] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 50 , wVal := awpDaten[21] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 52 , wVal := awpDaten[22] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 54 , wVal := awpDaten[23] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 56 , wVal := awpDaten[24] );
HMI_PutWORD( pbyAddr := ADR( smlMessage.awDaten ) + 58 , wVal := awpDaten[25] );

TCPMain.l_fb_SortjetHMI.PutMsg( smpSpsMessage := smlMessage, bpTrig := FALSE );
END_FUNCTION