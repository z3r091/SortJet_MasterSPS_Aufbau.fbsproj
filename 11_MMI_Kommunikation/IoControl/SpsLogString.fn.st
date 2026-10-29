(* METADATA
{
	"v3Meta": {
		"objectGuid": "3382b282-4d75-484e-8f31-3dfec2faf444"
	}
}
*)
FUNCTION SpsLogString : BOOL
VAR_INPUT
 spLogString : STRING(59);
END_VAR
VAR
 smlMessage     : SpsMessage;
 i,j            : WORD;
END_VAR

smlMessage.wAuftrag := SB0_SPS_LOGSTRING;

i:=SIZEOF(spLogString);
j:=SIZEOF(smlMessage.awDaten);

SysMemCpy( ADR( smlMessage.awDaten ), ADR( spLogString ), SIZEOF(spLogString) );

TCPMain.l_fb_SortjetHMI.PutMsg( smpSpsMessage := smlMessage, bpTrig := FALSE );
END_FUNCTION