
local trigger = compilestring(" (function()
{
	entity player = GetLocalClientPlayer();
	player.EndSignal( "OnDestroy" );
	while(true)
	{
		if(IsValid(player) && IsAlive(player) && player.GetBleedoutState() == BS_NOT_BLEEDING_OUT && GetCurrentPlaylistVarBool( "tb", false ) )
		{
			entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand );
			if( activeWeapon &&
			IsValid(activeWeapon) &&
			!activeWeapon.IsReloading() &&
			(((IsWeaponInSingleShotMode(activeWeapon) || IsWeaponInBurstMode(activeWeapon)) && activeWeapon.IsReadyToFire() == true) || IsWeaponInAutomaticMode(activeWeapon)))
			{
				bool bBocek = activeWeapon.GetWeaponClassName() == "mp_weapon_bow";
				if(!bBocek && (InputIsButtonDown( MOUSE_LEFT ) || InputIsButtonDown( BUTTON_A )))
				{
					WaitFrame();
					continue;
				};
 
				vector crosshairStart = player.EyePosition();
				vector crosshairEnd = crosshairStart + player.GetViewForward() * 250000;
				entity undercrosshair = player.GetTargetUnderCrosshair();
				entity crosshairEnt = null;
 
				if(undercrosshair == null)
				{
					TraceResults crosshairResults = TraceLine( crosshairStart, crosshairEnd, player, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE, player );
					crosshairEnt = crosshairResults.hitEnt;
 
					if ( IsValid( crosshairEnt ) && (crosshairEnt.GetScriptName() == "gibraltar_gun_shield" || crosshairEnt.GetScriptName() == "amped_wall"))
					{
						var deferredTrace = DeferredTraceLine( crosshairStart, crosshairEnd, crosshairEnt, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE);while ( IsDeferredTraceFinished( deferredTrace ) == false)
						{
							WaitFrame();
						};
 
						crosshairResults = GetDeferredTraceResult( deferredTrace );
						crosshairEnt = crosshairResults.hitEnt;
					};
				}
				else
				{
					crosshairEnt = undercrosshair;
				};
 
				if ( IsValid(player) &&
				IsAlive(player) &&
				IsValid( crosshairEnt ) &&
				(IsFiringRangeGameMode() ||
				IsSurvivalTraining() ||
				((GameRules_GetGameMode() == GAMEMODE_CONTROL && (crosshairEnt.GetTeam() % 2) != (player.GetTeam() % 2)) ||
				(GameRules_GetGameMode() != GAMEMODE_CONTROL && crosshairEnt.GetTeam() != player.GetTeam()))) &&
				(crosshairEnt.IsPlayer() || IsTrainingDummie(crosshairEnt) || IsProwler( crosshairEnt ) || IsSpider( crosshairEnt )) )
				{
					if(GetCurrentPlaylistVarBool( "trigger_ignore_down", false ) == false || crosshairEnt.GetBleedoutState() == BS_NOT_BLEEDING_OUT)
					{
						if(bBocek && activeWeapon.GetWeaponChargeFraction() == 1.0)
						{
							player.ClientCommand("-attack");
						};
 
						if(!bBocek)
						{
							player.ClientCommand("+attack");
							player.ClientCommand("-attack");
						};
					}
				}
			}
		};
 
		WaitFrame();
	}
})() ", "cl_shooting.nut")