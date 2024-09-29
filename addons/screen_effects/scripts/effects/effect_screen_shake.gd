class_name cScreenShake extends cEffect_Base

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mvShake: Vector2;
var mvLastShake: Vector2;
var mfRate: float;
var mNoise: FastNoiseLite;

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func InitShake(alID : int, afForce : float, afRate : float, afFadeIn : float, afDuration : float, afFadeOut:float)->void:
	if (afFadeIn<=0): afFadeIn = 999999999;
	if (afFadeOut<=0): afFadeOut = 999999999;
	
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

func Process(afTimeStep: float)->void:
	super.Process(afTimeStep);
	ProcessShake(afTimeStep);

#-------------------------------------------------------

func ProcessShake(afTimeStep: float)->void:
	mfTimeElapsed += afTimeStep;
	var vShake: Vector2 = Vector2.ZERO;
	vShake.x = mNoise.get_noise_2d(mfTimeElapsed, 0) * (mfAmount * mfMultiplier);
	vShake.y = mNoise.get_noise_2d(0, mfTimeElapsed) * (mfAmount * mfMultiplier);
	var fT: float = clamp(mfRate * 0.1, 0.0, 1.0);
	mvShake.x = lerpf(mvLastShake.x, vShake.x, fT);
	mvShake.y = lerpf(mvLastShake.y, vShake.y, fT);
	mvLastShake = mvShake;

#-------------------------------------------------------

func GetAmount()->Vector2:
	return mvShake;

#-------------------------------------------------------

func SetForce(afX: float):
	mfAmount = afX;

#-------------------------------------------------------
