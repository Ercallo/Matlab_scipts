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
XMIN	3442.300000
XWID	20.000000
*
*	Documentational Text:
*
TITL	'018_calibration_NaC60_288K'
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
DATE    06/25/21
TIME    16:53:42
CMNT    
SAMP    
SFOR    
STAG    C
EXPT    CW
OXS1    IADC
AXS1    B0VL
AXS2    NONE
AXS3    
A1CT    0.34494
A1SW    0.002
MWFQ    9.666654e+09
MWPW    1.479e-05
AVGS    1
RESO    MD5_Jun20
SPTP    0.02048
RCAG    60
RCHM    1
B0MA    4e-06
B0MF    100000
RCPH    0.0
RCOF    0.0
A1RS    1024
RCTC    0.01024
*
************************************************************
*
#DSL	1.0 * DEVICE SPECIFIC LAYER
*

.DVC     acqStart, 1.0


.DVC     fieldCtrl, 1.0

AllegroMode        False
CenterField        3449.40 G
Delay              0.0 s
FieldFlyback       On
FieldWait          Wait LED off
GFactor            2.000000
SetToSampleG       False
StaticFieldMon     3480.000 G
SweepDirection     Up
SweepWidth         20.0 G

.DVC     fieldSweep, 1.0


.DVC     freqCounter, 1.0

FrequencyMon       9.666654 GHz
QMonitBridge       On

.DVC     mwBridge, 1.0

AcqFineTuning      Never
AcqScanFTuning     Off
AcqSliceFTuning    Off
BridgeCalib        100.0
Power              0.01479 mW
PowerAtten         40 dB

.DVC     recorder, 1.0

BaselineCorr       Off
NbScansAcc         1
NbScansDone        1
NbScansToDo        1
ReplaceMode        Off
SmoothMode         Auto
SmoothPoints       1

.DVC     scanEnd, 1.0


.DVC     signalChannel, 1.0

AFCTrap            True
AllegroMode        False
AllowShortCt       False
Calibrated         True
ConvTime           20.48 ms
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
ModAmp             0.040 G
ModFreq            100.00 kHz
ModInput           Internal
ModOutput          Internal
ModPhase           0.0
Offset             0.0 %
QuadMode           False
QuadPhase          90.0
Resolution         1024
Resonator          1
SctNorm            True
SctRevision        SCT
SignalInput        Internal
SpuExtension       False
SweepTime          20.97 s
TimeConst          10.24 ms
TimeExp            False
TuneCaps           34

*
************************************************************
