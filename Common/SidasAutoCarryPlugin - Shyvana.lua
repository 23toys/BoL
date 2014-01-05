------#################################################################################------  ------###########################    Shyvana Unleashed     ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Version: 1.0

--> Features:
--> Prodictions in every skillshot, also taking their hitboxes in consideration.
--> Cast options for Q(Reset auto-attack animation), W and E in both, autocarry and mixed mode (works separately).
--> Customizable Hotkey to use Dragons Descent (R) with prodictions when the key is pressed (Default is "A").
--> KS with Flame Breath.
--> Options to Last Hit with Q(Takes Q + AD damage into consideration, also uses a method to force you to attack the minion so it won't derp-ignore the last-hit and leave with Q activated tl;dr +accurate) with Last Hit and Mixed Mode, and with E in Last Hit mode.
--> Option to clear the lane with skills in Lane Clear Mode (Q and E only to last hit, W activated if it can hit a minion).
--> Option to clear the jungle with skills in Lane Clear Mode (Keep using Q, W and E to clear the jungle camps).
--> Drawing options for W, E and R.

if myHero.charName ~= "Shyvana" then return end
 
require "Prodiction"
 
local qRange = 135
local wRange = 325
local eRange = 925
local rRange = 1000
 
local QAble, WAble, Eable, RAble = false, false, false, false
 
local Prodict = ProdictManager.GetInstance()
local ProdictW
local ProdictR
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 900
        Menu()
        
        ProdictE = Prodict:AddProdictionObject(_E, eRange, 1500, 0.125, 80)               
        ProdictR = Prodict:AddProdictionObject(_R, rRange, 1000, 0.125, 100)                       
end

function KS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
	local eDmg = getDmg("E", enemy, myHero)
		if Target and not Target.dead and Target.health < eDmg and GetDistance(Target) < rRange then
			ProdictE:GetPredictionCallBack(Target, CastE)
		end
	end
end
 
function PluginOnTick()
    Checks()
    JungleClear()
    if Target then
      if Target and (AutoCarry.MainMenu.AutoCarry) then
        Burnout()
        FlameBreath()
      end
      if Target and (AutoCarry.MainMenu.MixedMode) then
        Burnout2()
        FlameBreath2()
      end
      if Target and AutoCarry.PluginMenu.useR then
        DragonDescent()
      end
      if AutoCarry.PluginMenu.KS and EAble then KS()
      end
    end
-- Last Hit
 	if QAble and AutoCarry.PluginMenu.qFarm and AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.MixedMode then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange and Minion.health < getDmg("Q", minion, myHero)+getDmg("AD", minion, myHero) then 
			CastSpell(_Q, Minion.x, Minion.z)
			myHero:Attack(minion)
			AutoCarry.shotFired = true
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero)+getDmg("AD", minion, myHero) then 
					CastSpell(_Q, minion.x, minion.z)
					myHero:Attack(minion)
					AutoCarry.shotFired = true
				end
			end
		end
	end
	if EAble and AutoCarry.PluginMenu.eFarm and AutoCarry.MainMenu.LastHit then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= eRange and Minion.health < getDmg("E", Minion, myHero) then 
			CastSpell(_E, Minion.x, Minion.z)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= eRange and minion.health < getDmg("E", minion, myHero) then 
					CastSpell(_E, minion.x, minion.z)
				end
			end
		end
	end
-- Lane Clear
	if QAble and AutoCarry.PluginMenu.WaveClear and AutoCarry.MainMenu.LaneClear then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange and Minion.health < getDmg("Q", minion, myHero)+getDmg("AD", minion, myHero) then 
			CastSpell(_Q, Minion.x, Minion.z)
			myHero:Attack(minion)
			AutoCarry.shotFired = true
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero)+getDmg("AD", minion, myHero) then 
					CastSpell(_Q, minion.x, minion.z)
					myHero:Attack(minion)
					AutoCarry.shotFired = true
				end
			end
		end
	end
	if WAble and AutoCarry.PluginMenu.WaveClear and AutoCarry.MainMenu.LaneClear then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= wRange then 
			CastSpell(_W)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= wRange then 
					CastSpell(_W)
				end
			end
		end
	end
	if EAble and AutoCarry.PluginMenu.WaveClear and AutoCarry.MainMenu.LaneClear then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= eRange and Minion.health < getDmg("E", Minion, myHero) then 
			CastSpell(_E, Minion.x, Minion.z)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= eRange and minion.health < getDmg("E", minion, myHero) then 
					CastSpell(_E, minion.x, minion.z)
				end
			end
		end
	end
end
 
function PluginOnDraw()
    if not myHero.dead then
	  if WAble and AutoCarry.PluginMenu.drawW then
      DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x9933FF)
		  end
      if EAble and AutoCarry.PluginMenu.drawE then
      DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFF0000)
		  end
      if RAble and AutoCarry.PluginMenu.drawR then
      DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x9933FF)
	    end
   end
end

 function Menu()
  local HKR = string.byte("T")
  AutoCarry.PluginMenu:addParam("sep", "-- Misc Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useR", "Hotkey - Dragon's Descent", SCRIPT_PARAM_ONKEYDOWN, false, HKR)
  AutoCarry.PluginMenu:addParam("KS", "KS - Flame Breath", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep1", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useQ", "Use - Twin Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW", "Use - Burnout", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useE", "Use - Flame Breath", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useQ2", "Use - Twin Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW2", "Use - Burnout", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useE2", "Use - Flame Breath", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep3", "-- Last Hit Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("qFarm", "Farm - Twin Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("eFarm", "Farm - Flame Breath", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep4", "-- Lane Clear Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("WaveClear", "Clear - Lane", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("JungleClear", "Clear - Jungle", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep6", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("drawW", "Draw - Burnout", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawE", "Draw - Flame Breath", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawR", "Draw - Dragon Descent", SCRIPT_PARAM_ONOFF, true)
end
 
function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = AutoCarry.GetAttackTarget()
        Minion = AutoCarry.GetMinionTarget()
end
 
function OnAttacked()
        if QAble and (AutoCarry.MainMenu.AutoCarry) and AutoCarry.PluginMenu.useQ then CastSpell(_Q) end
        if QAble and (AutoCarry.MainMenu.MixedMode) and Target and GetDistance(Target) <= qRange and AutoCarry.PluginMenu.useQ2 then CastSpell(_Q) end
end

function Burnout()
        if WAble and AutoCarry.PluginMenu.useW and GetDistance(Target) <= wRange then CastSpell(_W) end
end    
 
function FlameBreath()
        if EAble and AutoCarry.PluginMenu.useE then ProdictE:GetPredictionCallBack(Target, CastE) end
end  

function Burnout2()
        if WAble and AutoCarry.PluginMenu.useW2 and GetDistance(Target) <= wRange then CastSpell(_W) end
end       
 
function FlameBreath2()
        if EAble and AutoCarry.PluginMenu.useE2 then ProdictE:GetPredictionCallBack(Target, CastE) end
end    

function DragonDescent()
        if RAble then ProdictR:GetPredictionCallBack(Target, CastR) end
end    
 
local function getHitBoxRadius(target)
       return GetDistance(target, target.minBBox)
end

function CastE(unit, pos, spell)
        if GetDistance(pos) - getHitBoxRadius(unit)/2 < eRange then
          CastSpell(_E, pos.x, pos.z)
        end
end

function CastR(unit, pos, spell)
        if GetDistance(pos) - getHitBoxRadius(unit)/2 < rRange then
          CastSpell(_R, pos.x, pos.z)
        end
end

function JungleClear()
	if AutoCarry.MainMenu.LaneClear and AutoCarry.PluginMenu.JungleClear then
	local Priority = nil
	local Target = nil
	for _, mob in pairs(AutoCarry.GetJungleMobs()) do
		if ValidTarget(mob) then
 			if mob.name == "TT_Spiderboss7.1.1"
			or mob.name == "Worm12.1.1"
			or mob.name == "Dragon6.1.1"
			or mob.name == "AncientGolem1.1.1"
			or mob.name == "AncientGolem7.1.1"
			or mob.name == "LizardElder4.1.1"
			or mob.name == "LizardElder10.1.1"
			or mob.name == "GiantWolf2.1.3"
			or mob.name == "GiantWolf8.1.3"
			or mob.name == "Wraith3.1.3"
			or mob.name == "Wraith9.1.3"
			or mob.name == "Golem5.1.2"
			or mob.name == "Golem11.1.2"
			then
				Priority = mob
			else
				Target = mob
			end
		end
	end

	if Priority then
		Target = Priority
	end

	if ValidTarget(Target) then
		if myHero:GetDistance(Target) <= qRange then CastSpell(_Q) end
		if myHero:GetDistance(Target) <= wRange then CastSpell(_W) end
		if myHero:GetDistance(Target) <= eRange then CastSpell(_E, Target.x, Target.z) end
	end
  end
end