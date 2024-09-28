class_name cScreenBlur extends cEffect_Base

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func InitScreenBlur(alID: int, afAmount: float, afFadeIn: float, afDuration: float, afFadeOut: float)->void:
	mlID = alID;
	mfAmount = afAmount;
	mfFadeInTime = afFadeIn;
	mfDuration = afDuration;
	mfFadeOutTime = afFadeOut;
	mfTimeElapsed = 0.0;
	mlEffectState = eEffectState.eEffectState_FadeIn;

#-------------------------------------------------------

func Process(afTimeStep : float)->void:
	super.Process(afTimeStep);

#-------------------------------------------------------

func GetAmount()->float:
	return mfAmount * mfMultiplier;

#-------------------------------------------------------

func SetAmount(afAmount:float)->void:
	mfAmount = afAmount;

#-------------------------------------------------------
