class_name cFovShake extends cEffect_Base

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

const F_SHAKE_FORCE_MUL = 8.0;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mfShake: float = 0.0;
var mfLastShake: float = 0.0;
var mfRate: float = 0.0;
var mNoise: FastNoiseLite;

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func InitShake(alID:int, afForce:float, afRate:float, afFadeIn:float, afDuration:float, afFadeOut:float)->void:
	mlID = alID;
	mfAmount = afForce;
	mfRate = afRate;
	mfFadeInTime = afFadeIn;
	mfDuration = afDuration;
	mfFadeOutTime = afFadeOut;
	mfTimeElapsed = 0.0;
	mlEffectState = eEffectState.eEffectState_FadeIn;
	
	mNoise = FastNoiseLite.new();
	mNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX;
	mNoise.frequency = mfRate;
	
#-------------------------------------------------------

func Process(afTimeStep : float)->void:
	super.Process(afTimeStep);
	ProcessShake(afTimeStep);

#-------------------------------------------------------

func ProcessShake(afTimeStep: float)->void:
	mfTimeElapsed += afTimeStep;
	var fShake = mNoise.get_noise_1d(mfTimeElapsed);
	var fT: float = clamp(mfRate * 0.1, 0.0, 1.0);
	mfShake = lerpf(mfLastShake, fShake * (mfAmount * mfMultiplier), fT);
	mfLastShake = mfShake;

#-------------------------------------------------------

func GetAmount()->float:
	return mfShake;
	
#-------------------------------------------------------

func SetForce(afX: float):
	mfAmount = afX;

#-------------------------------------------------------
