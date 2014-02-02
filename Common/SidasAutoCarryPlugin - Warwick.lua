------#################################################################################------  ------###########################      Weedwick: 420       ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Version: 1.0

--> Features:
--> Cast Options for Q and W in both, Autocarry and Mixed Mode (Works separately).
--> KS with R and Q, takes into consideration if you can kill a target with the full "combo" + an auto-attack it will ult the target.
--> Hotkey to use R.
--> Default Crosshair range is 400, and increase to 700 when using the ultimate is possible, this way avoiding it targetting someone out of your range, and not using Q into someone that is on your range.
--> Uses W while attacking, so it will most likely not waste W just because you're near an enemy, but can't really hit him.
--> Toggle to enable Farm with Q in last hit mode, and Last hit with Q in Lane clear mode (Works separately).
--> Drawing options for Q, W, E(with increasing range by level of the ability) and R.

if myHero.charName ~= "Warwick" then return end
 
local qRange = 400
local wRange = 1250
local eRange = nil
local rRange = 700
 
local QAble, WAble, Eable, RAble = false, false, false, false

local qDmg, rDmg, ksDmg
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 400
        RebornCheck()
        Menu()
end

function KS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
	if QAble then qDmg = getDmg("Q", enemy, myHero) + 30 else qDmg = 0 end
	if RAble then rDmg = getDmg("R", enemy, myHero) + 50 else rDmg = 0 end
	ksDmg = getDmg("AD", enemy, myHero) + qDmg + rDmg + 30
		if Target and not Target.dead and Target.health < ksDmg and GetDistance(Target) < rRange then
			CastSpell(_R, enemy)
			CastSpell(_Q, enemy)
		end
	end
end
 
function PluginOnTick()
    Checks()
    CheckELevel()
    if Target then
      if Target and (AutoCarry.MainMenu.AutoCarry) then
        HungeringStrike()
        HuntersCall()
      end
      if Target and (AutoCarry.MainMenu.MixedMode) then
        HungeringStrike2()
        HuntersCall2()
      end
      if AutoCarry.PluginMenu.KS and RAble then KS()
      end
    end
    if AutoCarry.PluginMenu.useR then
       InfiniteDuress()
       AutoCarry.SkillsCrosshair.range = 700 else AutoCarry.SkillsCrosshair.range = 400
    end
--LastHitting
	if QAble and AutoCarry.PluginMenu.qFarm and AutoCarry.MainMenu.LastHit then
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
--LaneClear
	if QAble and AutoCarry.PluginMenu.qClear and AutoCarry.MainMenu.LaneClear then
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
--
end
 
function PluginOnDraw()
    if not myHero.dead then
	  if QAble and AutoCarry.PluginMenu.drawQ then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
		  end
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
  AutoCarry.PluginMenu:addParam("KS", "Killsteal - R+Q/AD", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useR", "Use - Inifinite Duress", SCRIPT_PARAM_ONKEYDOWN, false, HKR)
  AutoCarry.PluginMenu:addParam("sep1", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useQ", "Use - Hungering Strike", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW", "Use - Hunters Call", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useQ2", "Use - Hungering Strike", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW2", "Use - Hunters Call", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("sep3", "-- Last Hit Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("qFarm", "Farm - Hungering Strike", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep4", "-- Lane Clear Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("qClear", "Farm - Hungering Strike", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("sep5", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("drawQ", "Draw - Hungering Strike", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawW", "Draw - Hunters Call", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawE", "Draw - Blood Scent", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawR", "Draw - Infinite Duress", SCRIPT_PARAM_ONOFF, true)
end
 
function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = AutoCarry.GetAttackTarget()
end

function CheckELevel()
        if myHero:GetSpellData(_E).level == 1 then eRange = 1500
        elseif myHero:GetSpellData(_E).level == 2 then eRange = 2300
        elseif myHero:GetSpellData(_E).level == 3 then eRange = 3100
        elseif myHero:GetSpellData(_E).level == 4 then eRange = 3900
        elseif myHero:GetSpellData(_E).level == 5 then eRange = 4700
        end
        if AutoCarry.PluginMenu.KS and RAble then AutoCarry.SkillsCrosshair.range = 700 else AutoCarry.SkillsCrosshair.range = 400 end
end

function HungeringStrike()
        if QAble and AutoCarry.PluginMenu.useQ and GetDistance(Target) < qRange then CastSpell(_Q, Target) end
end
 
function HuntersCall()
      if IsSACReborn then
        if WAble and AutoCarry.PluginMenu.useW and GetDistance(Target) <= 300 and AutoCarry.Orbwalker:IsShooting() then CastSpell(_W) end
      else
        if WAble and AutoCarry.PluginMenu.useW and GetDistance(Target) <= 300 and AutoCarry.CurrentlyShooting then CastSpell(_W) end
      end
end

function HungeringStrike2()
        if QAble and AutoCarry.PluginMenu.useQ2 and GetDistance(Target) < qRange then CastSpell(_Q, Target) end
end
 
function HuntersCall2()
      if IsSACReborn then
        if WAble and AutoCarry.PluginMenu.useW2 and GetDistance(Target) <= 250 and AutoCarry.Orbwalker:IsShooting() then CastSpell(_W) end
      else
        if WAble and AutoCarry.PluginMenu.useW2 and GetDistance(Target) <= 250 and AutoCarry.CurrentlyShooting then CastSpell(_W) end
      end
end

function InfiniteDuress()
        if RAble and AutoCarry.PluginMenu.useR and not AutoCarry.PluginMenu.useRre and GetDistance(Target) < AutoCarry.PluginMenu.rRanger then CastSpell(_R) end
end

function RebornCheck()
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
	PrintChat("<font color='#7ABA71'>>> Weedwick: 420 Loaded!</font>")
end