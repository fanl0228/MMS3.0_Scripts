-- Command Enum
TEST_CMD_PD_BUFFER_CAL              				=   1
TEST_CMD_P2G_CAL	                				=	2
TEST_CMD_RX_PLT_ENTER	            				=	3
TEST_CMD_RX_PLT_CAL	                				=	4
TEST_CMD_RX_PLT_EXIT	            				=	5
TEST_CMD_RX_PLT_GET	                				=	6
TEST_CMD_FCC	                    				=	7
TEST_CMD_TELEC	                    				=	8
TEST_CMD_STOP_TX	                				=	9
TEST_CMD_PLT_TEMPLATE	            				=	10
TEST_CMD_PLT_GAIN_ADJUST	        				=	11
TEST_CMD_PLT_GAIN_GET	            				=	12
TEST_CMD_CHANNEL_TUNE	            				=	13
TEST_CMD_PLT_RX_PER_START	        				=	14
TEST_CMD_PLT_RX_PER_STOP	        				=	15
TEST_CMD_PLT_RX_PER_CLEAR	        				=	16
TEST_CMD_PLT_RX_PER_GET	            				=	17
TEST_CMD_RX_STAT_STOP 	            				=	18
TEST_CMD_RX_STAT_START	            				=	19
TEST_CMD_RX_STAT_RESET	            				=	20
TEST_CMD_RX_STAT_GET	            				=	21
TEST_CMD_LOOPBACK_START	            				=	22
TEST_CMD_LOOPBACK_STOP	            				=	23
TEST_CMD_GET_FW_VERSIONS	        				=	24
TEST_CMD_INI_FILE_RADIO_PARAM	    				=	25
TEST_CMD_RUN_CALIBRATION_TYPE	    				=	26
TEST_CMD_TX_GAIN_ADJUST	            				=	27
TEST_CMD_UPDATE_PD_BUFFER_ERRORS					=	28
TEST_CMD_UPDATE_PD_REFERENCE_POINT					=	29
TEST_CMD_INI_FILE_GENERAL_PARAM	    				=	30
TEST_CMD_SET_EFUSE	                				=	31
TEST_CMD_GET_EFUSE 	                				=	32
TEST_CMD_TEST_TONE	                				=	33
TEST_CMD_POWER_MODE	                				=	34

-- Calibration Enum
CM_space1_e	                                        =	0
CM_RX_IQ_MM_calibration_e	                        =	1
CM_RX_IQ_MM_correction_upon_channel_change_e	    =	2
CM_RX_IQ_MM_correction_upon_temperature_change_e	=	3
CM_RX_IQ_MM_duplicate_VGA_e	                        =	4
CM_space2_e	                                        =	5
CM_RX_analog_DC_Correction_calibration_e	        =	6
CM_RX_DC_AUX_cal_mode_e	                            =	7
CM_RX_DC_AUX_normal_mode_e	                        =	8
CM_space3_e	                                        =	9
CM_RX_BIP_enter_mode_e	                            =	10
CM_RX_BIP_perform_e	                                =	11
CM_RX_BIP_exit_mode_e	                            =	12
CM_space4_e	                                        =	13
CM_TX_power_detector_calibration_e	                =	14
CM_TX_power_detector_buffer_calibration_e	        =	15
CM_space5_e	                                        =	16
CM_TX_LO_Leakage_calibration_e	                    =	17
CM_TX_PPA_Steps_calibration_e	                    =	18
CM_TX_CLPC_calibration_e	                        =	19
CM_TX_IQ_MM_calibration_e	                        =	20
CM_TX_BIP_calibration_e	                            =	21
CM_RX_TANK_TUNE_calibration_e						=	22
--CM_PD_BUFF_TUNE_calibration_e						=	23
CM_RX_DAC_TUNE_calibration_e						=	23
CM_RX_IQMM_TUNE_calibration_e						=	24
CM_RX_LPF_TUNE_calibration_e						=	25
CM_TX_LPF_TUNE_calibration_e						=	26
CM_TA_TUNE_calibration_e							=	27
CM_TX_MIXERFREQ_calibration_e						=	28
CM_RX_IF2GAIN_calibration_e							=	39
CM_RTRIM_calibration_e								=	30
CM_RX_LNAGAIN_calibration_e							=	31
CM_SMART_REFLEX_calibration_e						=	32
CM_CHANNEL_RESPONSE_calibration_e					=	33


--Preamble Mode
LONG_PREAMBLE_MODE              					= 	0 -- For rates 1,2,5.5,11 MBPS
SHORT_PREAMBLE_MODE             					= 	1 -- For rates 2 MBPS,5.5 MBPS,11 MBPS
OFDM_PREAMBLE_MODE              					= 	4 -- For rates 6,9,12,18,24,36,48,54 MBPS
N_MIXED_MODE_PREAMBLE_MODE      					= 	6 -- For rates MCS0,1,2,3,4,5,6,7
GREENFIELD_PREAMBLE_MODE        					= 	7

-- Packet Type
packetType_Data        								= 	0
packetType_Ack         								= 	1
packetType_ProbReq     								= 	2
packetType_RadData     								= 	3
packetType_UserData    								= 	4

-- Packet Mode
Single                                              =   0
multiple                                            =   1
InfiniteLength                                      =   2 --(unsupported)
Continuous                                          =   3
FCC                                                 =   4

-- Rate Enum
rate_1MBPS   										= 	0x00000001
rate_2MBPS   										= 	0x00000002
rate_5p5MBPS 										= 	0x00000004
rate_6MBPS   										= 	0x00000008
rate_9MBPS   										= 	0x00000010
rate_11MBPS  										= 	0x00000020
rate_12MBPS  										= 	0x00000040
rate_18MBPS  										= 	0x00000080
rate_24MBPS  										= 	0x00000200
rate_36MBPS  										= 	0x00000400
rate_48MBPS  										= 	0x00000800
rate_54MBPS  										= 	0x00001000
rate_MCS_0   										= 	0x00002000
rate_MCS_1   										= 	0x00004000
rate_MCS_2   										= 	0x00008000
rate_MCS_3   										= 	0x00010000
rate_MCS_4   										= 	0x00020000
rate_MCS_5   										= 	0x00040000
rate_MCS_6   										= 	0x00080000
rate_MCS_7   										= 	0x00100000



-- Tx Params
txParams =  {
            iDelay      = 500,
            iRate       = rate_54MBPS,
            iSize       = 1024,
            iAmount     = 0,
            iPower      = 10000,
            iSeed       = 10000,
            iPacketMode = Continuous,
            iDcfOnOff   = 1,
            iGI         = 0,
            iPreamble   = OFDM_PREAMBLE_MODE,
            iType       = packetType_Data,
            iScrambler  = 1,
            iEnableCLPC = 1,
            iSeqNumMode = 1,
            iSrcMacAddr = 0xdeadbeef,
            iDstMacAddr = 0xdeadbeef
            }
			
			
			
			
coarseDigitalGain = { -12 , -6 , 0 , 6 , 12 , -18 , -24 }

VSA_OFDM_Modulation = 
{
	QAM16 = 0,
	QAM64 = 2,
	QAM256 = 3, -- for OFDM11n only
	QPSK = 4,
	BPSK = 8
}

VSA_Average_Style = 
{
	Off = 0,
	Rms = 1,
	RmsExp = 2,
	Time = 3,
	TimeExp = 4,
	PeakHold = 5,
	MinPeakHold = 6
}

VSA_OFDM11n_Standart =
{
	Sta80211n20 = 0,
	Sta80211n40 = 1
} 
