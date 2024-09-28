class_name cFovShake extends cEffect_Base

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

const F_SHAKE_FORCE_MUL = 8.0;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mfShake: float = 0.0;
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
	mfShake = mNoise.get_noise_2d(mfTimeElapsed, 0);
	mfShake += mNoise.get_noise_2d(0, mfTimeElapsed);
	mfShake *= F_SHAKE_FORCE_MUL * (mfAmount * mfMultiplier);

#-------------------------------------------------------

func GetAmount()->float:
	return mfShake;
	
#-------------------------------------------------------

func SetForce(afX: float):
	mfAmount = afX;

#-------------------------------------------------------
