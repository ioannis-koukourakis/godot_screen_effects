class_name cScreenFade

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mlID: int = -1;
var mbFadeInProgress: bool = false;
var mfFadeDuration: float = 0.0;
var mfFadeTimeElapsed: float = 0.0;
var mFadeStartColor: Color = Color(0.0, 0.0, 0.0, 1.0);
var mFadeTargetColor: Color = Color(0.0, 0.0, 0.0, 1.0);
var mFadeColorOut: Color = Color(0.0, 0.0, 0.0, 0.0);

#-------------------------------------------------------
# HELPERS
#-------------------------------------------------------

func LerpToColor(aCurrent: Color, aGoal : Color, afStep : float)->Color:
	var colorOut: Color = aCurrent;
	colorOut.r = lerpf(aCurrent.r, aGoal.r, afStep);
	colorOut.g = lerpf(aCurrent.g, aGoal.g, afStep);
	colorOut.b = lerpf(aCurrent.b, aGoal.b, afStep);
	colorOut.a = lerpf(aCurrent.a, aGoal.a, afStep);
	return colorOut;


#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func InitScreenFade(alID: int, afFadeDuration: float, aStartColor: Color=Color(0.0, 0.0, 0.0, 0.0), aTargetColor: Color=Color(0.0, 0.0, 0.0, 0.0))->void:
	mlID = alID;
	mbFadeInProgress = true;
	mfFadeDuration = afFadeDuration;
	mfFadeTimeElapsed = 0.0;
	mFadeStartColor = aStartColor;
	mFadeTargetColor = aTargetColor;
	mFadeColorOut = aStartColor;

#-------------------------------------------------------

func Process(afDeltaTime : float)->void:
	if (mbFadeInProgress):
		mfFadeTimeElapsed += afDeltaTime;
		
		var fT = mfFadeTimeElapsed / mfFadeDuration;
		fT = clamp(fT, 0.0, 1.0);
		mFadeColorOut = LerpToColor(mFadeStartColor, mFadeTargetColor, fT);
		
		if (mFadeColorOut == mFadeTargetColor):
			mbFadeInProgress = false;
			mFadeColorOut = mFadeTargetColor;

#-------------------------------------------------------

func GetColor()->Color:
	return mFadeColorOut;

#-------------------------------------------------------

func GetEnded()->bool:
	return mbFadeInProgress == false;
	
#-------------------------------------------------------
	
func Stop()->void:
	mbFadeInProgress = false;
	mFadeColorOut = Color(0.0, 0.0, 0.0, 0.0);
	
#-------------------------------------------------------
