class_name cRadialBlur extends cEffect_Base

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mvFocusPosition: Vector2 = Vector2(0.5, 0.5);

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func InitRadialBlur(alID : int, afAmount : float, afFadeIn : float, afDuration : float, afFadeOut : float, avFocusPosition : Vector2 = Vector2(0.5, 0.5))->void:
	mlID = alID;
	mfAmount = afAmount;
	mfFadeInTime = afFadeIn;
	mfDuration = afDuration;
	mfFadeOutTime = afFadeOut;
	mfTimeElapsed = 0.0;
	mvFocusPosition.x = clamp(avFocusPosition.x, 0.0, 1.0);
	mvFocusPosition.y = clamp(avFocusPosition.y, 0.0, 1.0);
	mlEffectState = eEffectState.eEffectState_FadeIn;

#-------------------------------------------------------

func Process(afTimeStep : float)->void:
	super.Process(afTimeStep);
	ProcessFocus(afTimeStep);

#-------------------------------------------------------

func ProcessFocus(afTimeStep: float)->void:
	if(mlEffectState == eEffectState.eEffectState_FadeOut):
		if (mfFadeOutTime > 0.0):
			var fFade = afTimeStep * (1.0 / mfFadeOutTime);
			mfMultiplier = FadeTo(mfMultiplier, 0.0, fFade);
			mfMultiplier = clamp(mfMultiplier, 0.0, 1.0);
		else:
			mfMultiplier = 0.0;
			mvFocusPosition = Vector2(0.5, 0.5);

#-------------------------------------------------------

func GetAmount()->float:
	return mfAmount * mfMultiplier;

#-------------------------------------------------------

func SetAmount(afAmount:float)->void:
	mfAmount = afAmount;

#-------------------------------------------------------

func SetCenterPosition(avPosition : Vector2)->void:
	mvFocusPosition.x = clamp(avPosition.x, 0.0, 1.0);
	mvFocusPosition.y = clamp(avPosition.y, 0.0, 1.0);

#-------------------------------------------------------
