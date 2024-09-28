class_name cFovFade extends cEffect_Base

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mfFovMultiplier: float = 1.0;

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func InitFovFade(alID: int, afFovMultiplier: float, afFadeIn: float, afDuration: float, afFadeOut: float) -> void:
	mlID = alID;
	mfAmount = afFovMultiplier;
	mfFadeInTime = afFadeIn;
	mfDuration = afDuration;
	mfFadeOutTime = afFadeOut;
	mfTimeElapsed = 0.0;
	mlEffectState = eEffectState.eEffectState_FadeIn;

#-------------------------------------------------------

func Process(afTimeStep: float) -> void:
	super.Process(afTimeStep);
	mfFovMultiplier = lerp(1.0, mfAmount, mfMultiplier);

#-------------------------------------------------------

func GetFovMultiplier() -> float:
	return mfFovMultiplier;

#-------------------------------------------------------

func SetFovMultiplier(afX:float) -> void:
	mfAmount = afX;

#-------------------------------------------------------
