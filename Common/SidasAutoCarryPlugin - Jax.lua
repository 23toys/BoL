------#################################################################################------  ------##########################        Jaximus Turn!       ###########################------ ------##########################           by Toy           ###########################------ ------#################################################################################------

--> Version: 1.1
--> Features:
--> Cast options for Q, E and R (Autocarry already handles W).
--> Option to use E if it will hit a "x" number of enemies with the stun.
--> Option to use ultimate when a "x" number of enemies is around (700 range).
--> KS option to use Q+W if target is killable, or only Q if W is on cooldown.
--> Option to auto-ignite if it will kill the enemy (not needed for revamped).
--> Drawing options for Q and E.
--> Options to farm with Q and W in last hit or lane clear mode (or both).

if myHero.charName ~= "Jax" then return end

require "AoE_Skillshot_Position"

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1050
	--> Main Load
	mainLoad()
	--> Main Menu
	mainMenu()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
    igniteslot = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
    igniteslot = SUMMONER_2
  end
end

function PluginOnTick()
	Checks()
	FlameOn()
	if Target and (AutoCarry.MainMenu.AutoCarry) then
		if QREADY and Menu.useQ and GetDistance(Target) < qRange then CastSpell(_Q, Target) end
		if EREADY and Menu.useE and GetDistance(Target) < eRange then CastSpell(_E) end
		if RREADY and Menu.useR then castR() end
	end
		if Target and (AutoCarry.MainMenu.MixedMode) then
		if QREADY and Menu.useQ2 and GetDistance(Target) < qRange then CastSpell(_Q, Target) end
		if EREADY and Menu.useE2 and GetDistance(Target) < eRange then CastSpell(_E) end
		if RREADY and Menu.useR2 then castR() end
	end
	if Menu.KS and QREADY then KS() end
	if EREADY and Menu.eMEC then castE() end
	
	--Last Hit
	if QREADY and AutoCarry.PluginMenu.qFarm and AutoCarry.MainMenu.LastHit then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange and Minion.health < getDmg("Q", Minion, myHero) then 
			CastSpell(_Q, Minion)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero) then 
					CastSpell(_Q, minion)
				end
			end
		end
	end
	if WREADY and AutoCarry.PluginMenu.wFarm and AutoCarry.MainMenu.LastHit then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= wRange and Minion.health < getDmg("W", Minion, myHero) then 
			CastSpell(_W, Minion.x, Minion.z)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= wRange and minion.health < getDmg("W", minion, myHero) then 
					CastSpell(_W, minion.x, minion.z)
				end
			end
		end
	end

--Lane Clear	
	if QREADY and AutoCarry.PluginMenu.qClear and AutoCarry.MainMenu.LaneClear then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange and Minion.health < getDmg("Q", Minion, myHero) then 
			CastSpell(_Q, Minion)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero) then 
					CastSpell(_Q, minion)
				end
			end
		end
	end
	if WREADY and AutoCarry.PluginMenu.wClear and AutoCarry.MainMenu.LaneClear then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= wRange and Minion.health < getDmg("W", Minion, myHero) then 
			CastSpell(_W, Minion.x, Minion.z)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= wRange and minion.health < getDmg("W", minion, myHero) then 
					CastSpell(_W, minion.x, minion.z)
				end
			end
		end
	end
end

function PluginOnDraw()
	--> Ranges
	if not Menu.drawMaster and not myHero.dead then
		if QREADY and Menu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
		end
		if EREADY and Menu.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFF0000)
		end
	end
end

--> KS
function KS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if WREADY then kDmg = getDmg("Q", enemy, myHero) + getDmg("W", enemy, myHero) else
		local kDmg = getDmg("Q", enemy, myHero)
		if enemy and not enemy.dead and enemy.health < kDmg then
			CastSpell(_Q, enemy)
			CastSpell(_W)
			end
		end
	end
end

--> Checks
function Checks()
	Target = AutoCarry.GetAttackTarget()
	Minion = AutoCarry.GetMinionTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
end

--> MEC
function CountEnemies(point, range)
        local ChampCount = 0
        for j = 1, heroManager.iCount, 1 do
                local enemyhero = heroManager:getHero(j)
                if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, eRange) then
                        if GetDistance(enemyhero, point) <= eRange then
                                ChampCount = ChampCount + 1
                        end
                end
        end            
        return ChampCount
end

function castE()
        if Menu.eMEC then
                local ePos = GetAoESpellPosition(185, myHero)
                if ePos and GetDistance(ePos) <= eRange     then
                        if CountEnemies(ePos, 185) >= Menu.eEnemies then
                                CastSpell(_E)
                        end
                end
        elseif GetDistance(target) <= eRange then
                CastSpell(_E)
        end
end

function castR()
        if Menu.rMEC then
                local rPos = GetAoESpellPosition(700, myHero)
                if rPos and GetDistance(rPos) <= rRange     then
                        if CountEnemies(rPos, 700) >= Menu.rEnemies then
                                CastSpell(_R)
                        end
                end
        elseif GetDistance(target) <= rRange then
                CastSpell(_R)
        end
end

--> Ignite
function FlameOn( )
    for _, igtarget in pairs(GetEnemyHeroes()) do
                if ValidTarget(igtarget, 600) and KSIgnite and igtarget.health <= 50 + (20 * player.level) then
                CastSpell(igniteslot, igtarget)
        end
    end
end

--> Main Load
function mainLoad()
	qRange, wRange, eRange, rRange = 700, 125, 185, 700
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	Cast = AutoCarry.CastSkillshot
	Menu = AutoCarry.PluginMenu
end

--> Main Menu
function mainMenu()
	Menu:addParam("sep", "-- KS Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("KS", "KS - Leap Strike + Empower", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("KSIgnite", "KS - Ignite", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "-- MEC Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("eMEC", "Counter Strike - Stun", SCRIPT_PARAM_ONOFF, true)
  Menu:addParam("eEnemies", "Counter Strike - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("rMEC", "Grandmaster's Might - Use", SCRIPT_PARAM_ONOFF, true)
  Menu:addParam("rEnemies", "Grandmaster's Might - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("sep1", "-- Autocarry Mode --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Leap Strike", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Counter Strike", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use - Grandmaster's Might", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Mixed Mode --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ2", "Use - Leap Strike", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE2", "Use - Counter Strike", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR2", "Use - Grandmaster's Might", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep3", "-- Last Hit Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("qFarm", "Farm - Leap Strike", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wFarm", "Farm - Empower", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep4", "-- Lane Clear Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("qClear", "Farm - Leap Strike", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wClear", "Farm - Empower", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep5", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawQ", "Draw - Leap Strike", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawE", "Draw - Counter Strike", SCRIPT_PARAM_ONOFF, false)
end

--UPDATEURL=
--HASH=2D06A7CB025DF83459BC3D5F820987B5
