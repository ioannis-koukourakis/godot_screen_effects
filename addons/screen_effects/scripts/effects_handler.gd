class_name cEffectsHandler extends Node

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

const B_LINEAR_VELOCITY_MOTION_BLUR_ACTIVE: bool = false;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mCamera: Camera3D;
var mvFovFadeInst: Array[cFovFade];
var mlFovFadeID = -1;
var mvScreenShakeInst: Array[cScreenShake];
var mlScreenShakeID = -1;
var mvFovShakeInst: Array[cFovShake];
var mlFovShakeID: int = -1;
var mvRadialBlurInst: Array[cRadialBlur];
var mlRadialBlurID: int = -1;
var mvScreenBlurInst: Array[cScreenBlur];
var mlScreenBlurID: int = -1;
var mvScreenFadeInst: Array[cScreenFade];
var mlScreenFadeID: int = -1;
var mbMotionBlurActive: bool = true;
var mfLinearMotionBlurAmount: float = 0.05;
var mfAngularMotionBlurAmount: float = 0.1;
var mfMotionBlurFadeSpeed: float = 24.0;
var mvMotionBlurVelocity: Vector2 = Vector2(0.0, 0.0);
var mfDefaultFov: float = 55.0;
var msPostProcessEffectsScene: String;
var mPostProccessEffectsInstance: Control;
var mvLastCameraPosition: Vector3 = Vector3();
var mqLastCameraRotation: Quaternion = Quaternion();
var mvCameraLinearVelocity: Vector3 = Vector3(0.0, 0.0, 0.0);
var mvCameraAngularVelocity: Vector3 = Vector3(0.0, 0.0, 0.0);

#-------------------------------------------------------
# CORE FUNCTIONS
#-------------------------------------------------------

func _ready() -> void:
	mCamera = get_viewport().get_camera_3d();
	if (is_instance_valid(mCamera)==false):
		printerr("[EffectsHandler] No active camera found.");
		return;
	
	mfDefaultFov = mCamera.fov;
	
	#############################
	# Create the post processing effects viewport
	# Important: Must be created before any HUD elements if your game has any or the PP effects will affect the HUD! 
	if (is_instance_valid(mPostProccessEffectsInstance))==false:
		msPostProcessEffectsScene = "res://addons/screen_effects/scenes/post_process_fx_chain.tscn";
		var PostProcess: PackedScene = load(msPostProcessEffectsScene);
		mPostProccessEffectsInstance = PostProcess.instantiate();
		self.add_child(mPostProccessEffectsInstance);
		
		#################################
		# Sanity check
		if (is_instance_valid(mPostProccessEffectsInstance))==false:
			printerr("[ScreenEffects] Post processing effect Control instance is null");
			return;
	
	#########################
	# Reset all PP effects
	var pViewport: SubViewportContainer = GetPostProcessViewportContainer();
	if (is_instance_valid(pViewport)):
		pViewport.material.set_shader_parameter("motion_blur", 0.0);
		pViewport.material.set_shader_parameter("motion_blur_velocity", Vector2(0.0, 0.0));
		pViewport.material.set_shader_parameter("radial_blur_amount", 0.0);
		pViewport.material.set_shader_parameter("radial_blur_center_position", Vector2(0.5, 0.5));
		pViewport.material.set_shader_parameter("screen_blur_amount", 0.0);

#-------------------------------------------------------

func _process(afDeltaTime : float)->void:	
	if (is_instance_valid(mCamera) == false): return;

	####################################################################################################
	# Fov Fade
	var fFovMul: float = 1.0;
	for i in range(mvFovFadeInst.size() - 1, -1, -1):
		var pFovFade: cFovFade = mvFovFadeInst[i];
		if (is_instance_valid(pFovFade) == false): continue;

		#########################
		# Process current FOV fade instance
		pFovFade.Process(afDeltaTime);

		#########################
		# Multiply FOV values from all instances
		fFovMul *= pFovFade.GetFovMultiplier();

		#########################
		# Remove instance if done
		if (pFovFade.GetEnded()):
			mvFovFadeInst.remove_at(i);
	
	#########################
	# Prevent negative values and apply the final FOV multiplier
	fFovMul = max(fFovMul, 0.0);
	
	
	####################################################################################################
	# Fov Shake
	var fFovShake: float = 0.0;
	
	for i in range(mvFovShakeInst.size()-1, -1, -1):
		var pCurrShake = mvFovShakeInst[i];
		if (is_instance_valid(pCurrShake)==false): continue;
		
		#########################
		# Process curr fov shake inst
		pCurrShake.Process(afDeltaTime);

		#########################
		# Sum up the amount of all instances
		fFovShake += pCurrShake.GetAmount();
		
		#########################
		# Remove fov shake inst if done
		if (pCurrShake.GetEnded()):
			mvFovShakeInst.remove_at(i);
	
	####################################################################################################
	# Apply fov fade, fov shake
	var fNewFov: float = (mfDefaultFov * fFovMul) + fFovShake;
	fNewFov = clamp(fNewFov, 1.0, 179.0);
	mCamera.set_fov(fNewFov);
	
	
	####################################################################################################
	# Screen Shake
	var vScreenShake: Vector2 = Vector2();

	for i in range(mvScreenShakeInst.size()-1, -1, -1):
		var pCurrShake = mvScreenShakeInst[i];
		if (is_instance_valid(pCurrShake)==false):
			continue;
		
		#########################
		# Process curr inst
		pCurrShake.Process(afDeltaTime);

		#########################
		# Sum up the amount of all instances
		vScreenShake += pCurrShake.GetAmount();
		
		#########################
		# Remove shake inst if done
		if (pCurrShake.GetEnded()):
			mvScreenShakeInst.remove_at(i);
	
	mCamera.h_offset = vScreenShake.y;
	mCamera.v_offset = vScreenShake.x;
	
	
	####################################################################################################
	# Post Process effects
	var pViewport: SubViewportContainer = GetPostProcessViewportContainer();
	if (is_instance_valid(pViewport)):
		
		####################################################################################################
		# Radial Blur
		var fRadialBlurAmount: float = 0.0;
		var vRadialBlurCenterPos: Vector2 = Vector2(0.5, 0.5);
		for i in range(mvRadialBlurInst.size()-1, -1, -1):
			var pRadialBlur: cRadialBlur = mvRadialBlurInst[i];
			if (is_instance_valid(pRadialBlur)==false): continue;
			
			#########################
			# Process curr radial blur inst
			pRadialBlur.Process(afDeltaTime);
			
			#########################
			# Sum up the amount of all instances
			fRadialBlurAmount += pRadialBlur.GetAmount();
			vRadialBlurCenterPos = pRadialBlur.mvFocusPosition; # only take into account the last entry for this
			
			#########################
			# Remove inst if done
			if (pRadialBlur.GetEnded()):
				mvRadialBlurInst.remove_at(i);
		
		fRadialBlurAmount = clamp(fRadialBlurAmount, 0.0, 5.0);
		pViewport.material.set_shader_parameter("radial_blur_amount", fRadialBlurAmount);
		pViewport.material.set_shader_parameter("radial_blur_center_position", vRadialBlurCenterPos);
		
		
		####################################################################################################
		# Screen Blur
		var fScreenBlurAmount : float = 0.0;
		for i in range(mvScreenBlurInst.size()-1, -1, -1):
			var pScreenBlur: cScreenBlur = mvScreenBlurInst[i];
			if (is_instance_valid(pScreenBlur)==false): continue;
			
			#########################
			# Process curr radial blur inst
			pScreenBlur.Process(afDeltaTime);
			
			#########################
			# Sum up the amount of all instances
			fScreenBlurAmount += pScreenBlur.GetAmount();
			
			#########################
			# Remove inst if done
			if (pScreenBlur.GetEnded()):
				mvScreenBlurInst.remove_at(i);
		
		fScreenBlurAmount = clamp(fScreenBlurAmount, 0.0, 1.0);
		pViewport.material.set_shader_parameter("screen_blur_amount", fScreenBlurAmount);
		
		
		####################################################################################################
		# Screen Fade
		var screenFadeColor: Color = Color(0,0,0,0);
		for i in range(mvScreenFadeInst.size() -1, -1, -1):
			var pScreenFade: cScreenFade = mvScreenFadeInst[i];
			if (is_instance_valid(pScreenFade)==false): continue;
			
			#########################
			# Process curr radial blur inst
			pScreenFade.Process(afDeltaTime);
			
			#########################
			# Sum up the amount of all instances
			screenFadeColor += pScreenFade.GetColor();
			
			#########################
			# Remove inst if done
			if (pScreenFade.GetEnded()):
				mvScreenFadeInst.remove_at(i);
		
		screenFadeColor = ClampColor(screenFadeColor, Color(0,0,0,0), Color(1,1,1,1));
		var pColorRect: ColorRect = GetPostProcessEffectsChainControl().get_node_or_null("FadeColorRect");
		if (is_instance_valid(pColorRect)):
			pColorRect.color = screenFadeColor;
		
		
		#############################################################################################################
		# Motion Blur
		if (mbMotionBlurActive):
			var vDesiredMotionBlur: Vector2 = Vector2.ZERO;
			
			#########################
			# Apply angular velocity
			var fMotionBlurVelMax = 1.0;
			vDesiredMotionBlur.x = clamp(-mvCameraAngularVelocity.y * mfAngularMotionBlurAmount, -fMotionBlurVelMax, fMotionBlurVelMax);
			vDesiredMotionBlur.y = clamp(mvCameraAngularVelocity.x * mfAngularMotionBlurAmount, -fMotionBlurVelMax, fMotionBlurVelMax);
			
			#########################
			# Add linear velocity;
			if (B_LINEAR_VELOCITY_MOTION_BLUR_ACTIVE):
				vDesiredMotionBlur.y += clamp( (mvCameraLinearVelocity.x + mvCameraLinearVelocity.z) * mfLinearMotionBlurAmount, -fMotionBlurVelMax, fMotionBlurVelMax);
				vDesiredMotionBlur.x += clamp(mvCameraLinearVelocity.y * mfLinearMotionBlurAmount, -fMotionBlurVelMax, fMotionBlurVelMax);
			
			#########################
			# Motion blur fade out 
			var fMotionBlurFade = mfMotionBlurFadeSpeed * afDeltaTime;
			mvMotionBlurVelocity.x = lerp(mvMotionBlurVelocity.x, vDesiredMotionBlur.x, fMotionBlurFade);
			mvMotionBlurVelocity.y = lerp(mvMotionBlurVelocity.y, vDesiredMotionBlur.y, fMotionBlurFade);
			
			#########################
			# Apply motion blur
			mvMotionBlurVelocity.x = lerp(mvMotionBlurVelocity.x, vDesiredMotionBlur.x, 16.0 * afDeltaTime);
			mvMotionBlurVelocity.y = lerp(mvMotionBlurVelocity.y, vDesiredMotionBlur.y, 16.0 * afDeltaTime);
			
			#########################
			# Apply blur velocity to the shader
			pViewport.material.set_shader_parameter("motion_blur_velocity", mvMotionBlurVelocity);
		else:
			pViewport.material.set_shader_parameter("motion_blur_velocity", Vector2(0.0, 0.0));

#-------------------------------------------------------

func _physics_process(afTimeStep: float) -> void:
	if (is_instance_valid(mCamera)==false): return;
	if (mbMotionBlurActive==false): return;
	
	#########################
	# Linear velocity
	if (B_LINEAR_VELOCITY_MOTION_BLUR_ACTIVE):
		#TODO: Fix me! This is currently a bit unstable.
		mvCameraLinearVelocity = mCamera.global_position - mvLastCameraPosition;
	
	#########################
	# Angular velocity
	var qCamRot : Quaternion = Quaternion(mCamera.global_transform.basis);
	var qCameraRotationDifference = qCamRot.inverse() * mqLastCameraRotation; # subtract quat
	mvCameraAngularVelocity = qCameraRotationDifference.get_euler();
	
	#########################
	# Store current frame values to use during the next frame.
	mvLastCameraPosition = mCamera.global_position;
	mqLastCameraRotation = Quaternion(mCamera.global_transform.basis);

#-------------------------------------------------------
# HELPERS
#-------------------------------------------------------

func ClampColor(aColor: Color, aColorMin: Color, aColorMax: Color)->Color:
	var aColorOut: Color = Color(0,0,0,0);
	aColorOut.r = clamp(aColor.r, aColorMin.r, aColorMax.r);
	aColorOut.g = clamp(aColor.g, aColorMin.g, aColorMax.g);
	aColorOut.b = clamp(aColor.b, aColorMin.b, aColorMax.b);
	aColorOut.a = clamp(aColor.a, aColorMin.a, aColorMax.a);
	return aColorOut;

#-------------------------------------------------------

func GetUniqueIntID()-> int:
	var UUID: PackedByteArray = PackedByteArray();
	for i in range(16):
		UUID.append(randi() % 256);
	
	###########################
	# Set the version to 4 (randomly generated UUID)
	UUID[6] = (UUID[6] & 0x0F) | 0x40;
	
	###########################
	# Set the variant to DCE 1.1, ITU-T X.667
	UUID[8] = (UUID[8] & 0x3F) | 0x80;
	
	###########################
	# Convert to a single integer
	var lUUID: int = 0
	for i in range(16):
		lUUID = (lUUID << 8) | UUID[i];
	
	###########################
	# Ensure the integer is positive.
	lUUID = lUUID & 0x7FFFFFFFFFFFFFFF;
	
	return lUUID;

#-------------------------------------------------------
# INTERFACE
#-------------------------------------------------------

func GetPostProcessEffectsChainControl()-> Control:
	return mPostProccessEffectsInstance;

#-------------------------------------------------------

func GetPostProcessViewportContainer()-> SubViewportContainer:
	return mPostProccessEffectsInstance.get_node_or_null("SubViewportContainer");
	
#-------------------------------------------------------

func GetPostProcessViewport()->SubViewport:
	var pViewport: SubViewportContainer = GetPostProcessViewportContainer();
	if (is_instance_valid(pViewport)==false): return null;
	return pViewport.get_node_or_null("SubViewport");

#-------------------------------------------------------

func AddFovFade(afFovMultiplier : float = 1.0, afFadeIn : float = 0.1, afDuration : float =0.1, afFadeOut : float = 0.8)->int:
	var pNewFovFadeInst: cFovFade = cFovFade.new();
	if (is_instance_valid(pNewFovFadeInst)==false): return -1;
	
	mlFovFadeID = GetUniqueIntID();
	pNewFovFadeInst.InitFovFade(mlFovFadeID, afFovMultiplier, afFadeIn, afDuration, afFadeOut);
	mvFovFadeInst.push_back(pNewFovFadeInst);
	
	return pNewFovFadeInst.mlID;

#-------------------------------------------------------

func GetFovFadeInstanceById(alID: int) -> cFovFade:
	for i in range(mvFovFadeInst.size()):
		var pInst: cFovFade = mvFovFadeInst[i];
		if (is_instance_valid(pInst)==false): continue;
		if (pInst.mlID==alID): return pInst;
	return null;

#-------------------------------------------------------

func StopFovFade(alID : int)->void:
	var pInst: cFovFade = GetFovFadeInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.Stop();

#-------------------------------------------------------

func SetFovFadeMultiplier(alID: int, afX: float):
	var pInst: cFovFade = GetFovFadeInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.SetFovMultiplier(afX);

#-------------------------------------------------------

func AddScreenShake(afForce:float=0.1, afRate:float=50.0, afFadeIn:float=0.1, afDuration:float=0.1, afFadeOut:float=0.8)->int:
	var pNewScreenShakeInst: cScreenShake = cScreenShake.new();
	if (is_instance_valid(pNewScreenShakeInst)==false):
		return -1;
	
	mlScreenShakeID = GetUniqueIntID();
	pNewScreenShakeInst.InitShake(mlScreenShakeID, afForce, afRate, afFadeIn, afDuration, afFadeOut);
	mvScreenShakeInst.push_back(pNewScreenShakeInst);
	return pNewScreenShakeInst.mlID;

#-------------------------------------------------------

func GetScreenShakeInstanceById(alID: int) -> cScreenShake:
	for i in range(mvScreenShakeInst.size()):
		var pInst: cScreenShake = mvScreenShakeInst[i];
		if (is_instance_valid(pInst)==false): continue;
		if (pInst.mlID==alID): return pInst;
	return null;

#-------------------------------------------------------

func StopScreenShake(alID : int)->void:
	var pInst: cScreenShake = GetScreenShakeInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.Stop();

#-------------------------------------------------------

func SetScreenShakeForce(alID: int, afX: float):
	var pInst: cScreenShake = GetScreenShakeInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.SetForce(afX);

#-------------------------------------------------------

func AddFovShake(afForce : float = 0.1, afRate : float = 50, afFadeIn : float = 0.1, afDuration : float =0.1, afFadeOut : float = 0.8)->int:
	var pNewShakeInst: cFovShake = cFovShake.new();
	if (is_instance_valid(pNewShakeInst)==false): return -1;
	
	mlFovShakeID = GetUniqueIntID();
	pNewShakeInst.InitShake(mlFovShakeID, afForce, afRate, afFadeIn, afDuration, afFadeOut);
	mvFovShakeInst.push_back(pNewShakeInst);
	
	return pNewShakeInst.mlID;

#-------------------------------------------------------

func GetFovShakeInstanceById(alID: int) -> cFovShake:
	for i in range(mvFovShakeInst.size()):
		var pInst: cFovShake = mvFovShakeInst[i];
		if (is_instance_valid(pInst)==false): continue;
		if (pInst.mlID==alID): return pInst;
	return null;

#-------------------------------------------------------

func StopFovShake(alID : int)->void:
	var pInst: cFovShake = GetFovShakeInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.Stop();

#-------------------------------------------------------

func SetFovShakeForce(alID: int, afX: float):
	var pInst: cFovShake = GetFovShakeInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.SetForce(afX);

#-------------------------------------------------------

func AddRadialBlur(afAmount : float = 1.0, afFadeIn : float = 0.1, afDuration : float = 0.1, afFadeOut : float = 0.8, avFocusPosition: Vector2 = Vector2(0.5, 0.5))->int:
	var pNewRadialBlurInst : cRadialBlur = cRadialBlur.new();
	if (is_instance_valid(pNewRadialBlurInst)==false): return -1;
	
	mlRadialBlurID = GetUniqueIntID();
	pNewRadialBlurInst.InitRadialBlur(mlRadialBlurID, afAmount, afFadeIn, afDuration, afFadeOut, avFocusPosition);
	mvRadialBlurInst.push_back(pNewRadialBlurInst);
	
	return pNewRadialBlurInst.mlID;

#-------------------------------------------------------

func GetRadialBlurInstanceById(alID: int) -> cRadialBlur:
	for i in range(mvRadialBlurInst.size()):
		var pInst: cRadialBlur = mvRadialBlurInst[i];
		if (is_instance_valid(pInst)==false): continue;
		if (pInst.mlID==alID): return pInst;
	return null;

#-------------------------------------------------------

func SetRadialBlurAmount(alID: int, afAmount: float)->void:
	var pInst: cRadialBlur = GetRadialBlurInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.SetAmount(afAmount);

#-------------------------------------------------------

func SetRadialBlurFocusPosition(alID : int, avPosition:Vector2)->void:
	var pInst: cRadialBlur = GetRadialBlurInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.mvFocusPosition = avPosition; # TODO: Add setter in the class.

#-------------------------------------------------------

func StopRadialBlur(alID : int)->void:
	var pInst: cRadialBlur = GetRadialBlurInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.Stop();

#-------------------------------------------------------

func AddScreenBlur(afAmount : float = 1.0, afFadeIn : float = 0.1, afDuration : float = 0.1, afFadeOut : float = 0.8)->int:
	var pScreenBlurInst : cScreenBlur = cScreenBlur.new();
	if (is_instance_valid(pScreenBlurInst)==false):
		return -1;
	
	mlScreenBlurID = GetUniqueIntID();
	pScreenBlurInst.InitScreenBlur(mlScreenBlurID, afAmount, afFadeIn, afDuration, afFadeOut);
	mvScreenBlurInst.push_back(pScreenBlurInst);
	
	return pScreenBlurInst.mlID;

#-------------------------------------------------------

func GetScreenBlurInstanceById(alID: int) -> cScreenBlur:
	for i in range(mvScreenBlurInst.size()):
		var pInst: cScreenBlur = mvScreenBlurInst[i];
		if (is_instance_valid(pInst)==false): continue;
		if (pInst.mlID==alID): return pInst;
	return null;

#-------------------------------------------------------

func SetScreenBlurAmount(alID : int, afAmount:float)->void:
	var pInst: cScreenBlur = GetScreenBlurInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.SetAmount(afAmount);

#-------------------------------------------------------

func StopScreenBlur(alID: int)->void:
	var pInst: cScreenBlur = GetScreenBlurInstanceById(alID);
	if (is_instance_valid(pInst)==false): return;
	pInst.Stop();

#-------------------------------------------------------

func SetMotionBlurActive(abX: bool)->void:
	mbMotionBlurActive = abX;

#-------------------------------------------------------

func GetMotionBlurActive()->bool:
	return mbMotionBlurActive;

#-------------------------------------------------------

func AddScreenFade(afFadeDuration: float = 1.0, aStartColor: Color = Color(0,0,0,1), aEndColor: Color = Color(0,0,0,0))->int:
	var pScreenFadeInst: cScreenFade = cScreenFade.new();
	if (is_instance_valid(pScreenFadeInst)==false):
		return -1;
	
	mlScreenFadeID = GetUniqueIntID();
	pScreenFadeInst.InitScreenFade(mlScreenFadeID, afFadeDuration, aStartColor, aEndColor);
	mvScreenFadeInst.push_back(pScreenFadeInst);
	
	return pScreenFadeInst.mlID;

#-------------------------------------------------------

func GetScreenFadeInstanceById(alID: int) -> cScreenFade:
	for i in range(mvScreenFadeInst.size()):
		var pInst: cScreenFade = mvScreenFadeInst[i];
		if (is_instance_valid(pInst)==false): continue;
		if (pInst.mlID==alID): return pInst;
	return null;

#-------------------------------------------------------

func StopEffectInstances(avInstances: Array) -> void:
	for i in range(avInstances.size()):
		var pInst = avInstances[i];
		if (is_instance_valid(pInst)):
			if (avInstances == mvScreenFadeInst):
				pInst.Stop();
			else:
				pInst.Stop(0.0);
	
	avInstances.clear();

#-------------------------------------------------------

func SetCamera(aCamera: Camera3D)->void:
	mCamera = aCamera;

#-------------------------------------------------------
