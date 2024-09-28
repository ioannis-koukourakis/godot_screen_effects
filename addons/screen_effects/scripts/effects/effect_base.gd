class_name cEffect_Base

#-------------------------------------------------------

enum eEffectState{
	eEffectState_FadeIn,
	eEffectState_Full,
	eEffectState_FadeOut,
	eEffectState_LastEnum
}

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mlID: int = -1;
var mfDuration: float = 0.0;
var mfAmount: float = 0.0;
var mfFadeInTime: float = 0.0;
var mfFadeOutTime: float = 0.0;
var mlEffectState: int = 0;
var mfTimeElapsed = 0.0;
var mfMultiplier: float = 0.0;

# ------------------------------------------------
# HELPERS
# ------------------------------------------------

func FadeTo(afCurrent : float, afGoal : float, afStep : float)->float:
	if (afCurrent > afGoal):
		return max(afCurrent - afStep, afGoal);
	elif (afCurrent < afGoal):
		return min(afCurrent + afStep, afGoal);
	else:
		return afCurrent;

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func Process(afTimeStep: float) -> void:
	mfTimeElapsed += afTimeStep;
	
	#########################
	# Fade in
	if (mlEffectState == eEffectState.eEffectState_FadeIn):
		if (mfMultiplier < 1.0):
			var fFade = afTimeStep * (1.0 / mfFadeInTime);
			mfMultiplier = FadeTo(mfMultiplier, 1.0, fFade);
			mfMultiplier = clamp(mfMultiplier, 0.0, 1.0);
		else:
			mfMultiplier = 1.0;
			mlEffectState = eEffectState.eEffectState_Full;
	
	#########################
	# Full effect duration
	elif (mlEffectState == eEffectState.eEffectState_Full):
		#########################
		# If mfDuration is < 0, stay in Full state indefinitely
		if (mfDuration >= 0.0):
			if (mfTimeElapsed >= mfFadeInTime + mfDuration):
				mlEffectState = eEffectState.eEffectState_FadeOut;
	
	#########################
	# Fade Out
	elif (mlEffectState == eEffectState.eEffectState_FadeOut):
		if (mfMultiplier > 0.0):
			var fFade = afTimeStep * (1.0 / mfFadeOutTime);
			mfMultiplier = FadeTo(mfMultiplier, 0.0, fFade);
			mfMultiplier = clamp(mfMultiplier, 0.0, 1.0);
		else:
			mfMultiplier = 0.0;
			mlEffectState = eEffectState.eEffectState_LastEnum;

#-------------------------------------------------------

func Stop(afFadeOut: float = -1.0)->void:
	if (afFadeOut > 0.0): mfFadeOutTime = afFadeOut; # this is so that if < 0.0 we use the value defined in the constructor
	mlEffectState = eEffectState.eEffectState_FadeOut;

#-------------------------------------------------------

func GetEnded()->bool:
	return mlEffectState == eEffectState.eEffectState_LastEnum;

#-------------------------------------------------------

func GetEffectState()-> int:
	return mlEffectState;

#-------------------------------------------------------

func SetEffectState(alX)-> void:
	mlEffectState = alX;

#-------------------------------------------------------
