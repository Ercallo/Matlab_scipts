#DESC	1.2 * DESCRIPTOR INFORMATION ***********************
*
*	Dataset Type and Format:
*
DSRC	EXP
BSEQ	BIG
IKKF	REAL
XTYP	IDX
YTYP	NODATA
ZTYP	NODATA
*
*	Item Formats:
*
IRFMT	D
*
*	Data Ranges and Resolutions:
*
XPTS	1024
XMIN	3386.900000
XWID	180.100000
*
*	Documentational Text:
*
TITL	'001_1p0V_10KHz_3G_30K_10Scan_90Deg_Light'
IRNAM	'Intensity'
XNAM	'Field'
IRUNI	''
XUNI	'G'
*
************************************************************
*
#SPL	1.2 * STANDARD PARAMETER LAYER
*
OPER    fehr
DATE    06/15/21
TIME    11:31:38
CMNT    
SAMP    
SFOR    
STAG    C
EXPT    CW
OXS1    IADC
AXS1    B0VL
AXS2    NONE
AXS3    
A1CT    0.3476
A1SW    0.018
MWFQ    9.740585e+09
MWPW    0.03717
AVGS    10
RESO    MD5_Jun20
SPTP    0.04096
RCAG    60
RCHM    1
B0MA    0.0003
B0MF    10000
RCPH    90.0
RCOF    -12.0
A1RS    1024
RCTC    0.02048
*
************************************************************
*
#DSL	1.0 * DEVICE SPECIFIC LAYER
*

.DVC     acqStart, 1.0


.DVC     fieldCtrl, 1.0

AllegroMode        False
CenterField        3476.00 G
Delay              0.0 s
FieldFlyback       On
FieldWait          Wait LED off
GFactor            2.000000
SetToSampleG       False
StaticFieldMon     3476.000 G
SweepDirection     Up
SweepWidth         180.0 G

.DVC     fieldSweep, 1.0


.DVC     freqCounter, 1.0

FrequencyMon       9.740585 GHz
QMonitBridge       On

.DVC     mwBridge, 1.0

AcqFineTuning      Never
AcqScanFTuning     Off
AcqSliceFTuning    Off
BridgeCalib        100.0
Power              37.17 mW
PowerAtten         6 dB
QValue             4100

.DVC     recorder, 1.0

BaselineCorr       Off
NbScansAcc         10
NbScansDone        10
NbScansToDo        10
ReplaceMode        Off
SmoothMode         Auto
SmoothPoints       1

.DVC     scanEnd, 1.0


.DVC     signalChannel, 1.0

AFCTrap            True
AllegroMode        False
AllowShortCt       False
Calibrated         True
ConvTime           40.96 ms
DModAFCTrap        True
DModAmp            1.00 G
DModCalibrated     True
DModDetectSCT      First
DModEliDelay       1.0 us
DModExtLockIn      False
DModExtTrigger     False
DModFieldMod       First
DModGain           60 dB
DModHighPass       True
DModIntegrator     True
DModModOutput      Internal
DModSignalInput    Internal
DModTimeConst      1.28 ms
DoubleModFreq      5.00 kHz
DoubleModPhase     0.0
DoubleMode         False
EliDelay           1.0 us
EnableImag         Disable
ExtLockIn          False
ExtTrigger         False
Gain               60 dB
Harmonic           1
HighPass           True
Integrator         True
IsCalibExp         False
ModAmp             3.000 G
ModFreq            10.00 kHz
ModInput           Internal
ModOutput          Internal
ModPhase           90.0
Offset             -12.0 %
QuadMode           False
QuadPhase          90.0
Resolution         1024
Resonator          1
SctNorm            True
SctRevision        SCT
SignalInput        External
SpuExtension       False
SweepTime          41.94 s
TimeConst          20.48 ms
TimeExp            False
TuneCaps           0

*
************************************************************
