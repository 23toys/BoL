------#################################################################################------  ------###########################     Officer Caitlyn      ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Version: 1.0

--> Features:
--> VPrediction on every skillshot.
--> Cast options for W, to cast W when the enemy is inmmobille (ChainCC) or when he is dashing.
--> Combo E + Q into the enemy when key is pressed (Default T).
--> Dash to mouse position with E when key is pressed (Default G).
--> Checks if you're in the middle of an auto-attack animation, so it doesn't cancel your auto-attack to use a spell (it completes the auto-attack before using the spell).
--> Cast options for Piltover Peacemaker (Q) on autocarry and mixed mode.
--> Draw when you have an enemy that is killable by Ace in the Hole(R) in range (Killshot), and allow you to Killshot by a keypress (Default is R), also KS with Piltover Peacemaker (Q).
--> Drawing option for Q and R(Escaling range for R, checks for the skill level to increase the circle range when it's leveled up).
--> Optional customizable skill ranges, set the skills to whatever range you like (default is max range), also you can change the skill cross-hair range (target selector range, if you set it to a value below 1300, Q and W will be limited by this range, recomended is betwen 1300 and 1400), disable the option to reset the ranges to the default, the ranges are configured with a slider.
--> Set-able hitchance for VPrediction on skillshots, with an explanation about each hitchance that can be readed ingame, W usage and E>Q combo are not affected by this change, as it is already using a custom hitchance for those functions.

--> Extra Credits:
--> JBman, as I had some ideas from his script: Killshot with R, and dash to mouse position with E.

if myHero.charName ~= "Caitlyn" then return end

require "VPrediction"

-- Constants
local qRange = 1300
local wRange = 800
local eRange = 1000
local rRange = nil
local xRange = 1300

local QAble, WAble, RAble = false, false, false

local qDmg, eDmg, rDmg, DmgRange

local VP = nil

-- PROdiction
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = xRange
        Menu()
        RebornCheck()
        VP = VPrediction()
end
 
-- Drawings
function PluginOnDraw()
        if not myHero.dead then
                if QAble and AutoCarry.PluginMenu.drawQ then
                        DrawCircle(myHero.x, myHero.y, myHero.z, AutoCarry.PluginMenu.extra.qRanger, 0x6600CC)
                end
                if RAble and AutoCarry.PluginMenu.drawR then
                        DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x990000)
                end
        end
end
 
 -- KS
function KS()
    for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if QAble and AutoCarry.PluginMenu.KSQ then qDmg = getDmg("Q",Enemy,myHero) else qDmg = 0 end
        if EAble and AutoCarry.PluginMenu.KSE then eDmg = getDmg("E",Enemy,myHero) else eDmg = 0 end
        if RAble then rDmg = getDmg("R",Enemy,myHero) else rDmg = 0 end
        if ValidTarget(Enemy, 1300, true) and Enemy.health < qDmg then
            --Net()
            PeacemakerKS()
        end
        if ValidTarget(Enemy, rRange, true) and Enemy.health < rDmg then
        PrintFloatText(myHero, 0, "Press R For Killshot") end
        if ValidTarget(Enemy, rRange, true) and AutoCarry.PluginMenu.Killshot and Enemy.health < rDmg then
        CastSpell(_R, Enemy) end
    end
end
 
local HKR = string.byte("R")
local HKE = string.byte("G")
local HKC = string.byte("T")
function Menu()
AutoCarry.PluginMenu:addSubMenu("-- [Range & Prediction Settings] --", "extra")
AutoCarry.PluginMenu.extra:addParam("useRanger", "Use - Custom Ranges", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu.extra:addParam("xRanger", "Range - Skill Crosshair", SCRIPT_PARAM_SLICE, 1300, 650, 2000, 0)
AutoCarry.PluginMenu.extra:addParam("qRanger", "Range - Piltover Peacemaker", SCRIPT_PARAM_SLICE, 1300, 650, 1350, 0)
AutoCarry.PluginMenu.extra:addParam("HitChance", "Q - Hitchance", SCRIPT_PARAM_SLICE, 2, 0, 5, 0)
AutoCarry.PluginMenu.extra:addParam("HitChanceInfo", "Info - Hitchance", SCRIPT_PARAM_ONOFF, false)
AutoCarry.PluginMenu:addParam("sep", "-- Misc Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("useW", "Use - Yordle Snap Trap", SCRIPT_PARAM_ONOFF, false)
AutoCarry.PluginMenu:addParam("TrapInfo", "Info - Yordle Snap Trap", SCRIPT_PARAM_ONOFF, false)
AutoCarry.PluginMenu:addParam("Dash", "Dash - 90 Caliber Net", SCRIPT_PARAM_ONKEYDOWN, false, HKE)
AutoCarry.PluginMenu:addParam("Combo", "Combo - Net Peacemaker", SCRIPT_PARAM_ONKEYDOWN, false, HKC)
AutoCarry.PluginMenu:addParam("sep1", "-- KS Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("KS", "Enable - Killsteal", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("Killshot", "Killshot - Ace in the Hole", SCRIPT_PARAM_ONKEYDOWN, false, HKR)
AutoCarry.PluginMenu:addParam("KSQ", "Use - Piltover Peacemaker", SCRIPT_PARAM_ONOFF, true)
--AutoCarry.PluginMenu:addParam("KSE", "Use - 90 Caliber Net", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("sep2", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "") 
AutoCarry.PluginMenu:addParam("useQ", "Use - Piltover Peacemaker", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("sep3", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("useQ2", "Use - Piltover Peacemaker", SCRIPT_PARAM_ONOFF, false)
AutoCarry.PluginMenu:addParam("sep4", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("drawQ", "Draw - Piltover Peacemaker", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("drawR", "Draw - Ace in the Hole", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnTick()
        Checks()
        CheckRLevel()
			if Target then
            	if Target and (AutoCarry.MainMenu.AutoCarry) then
				Peacemaker()
            	end
            	if Target and (AutoCarry.MainMenu.MixedMode) then
				Peacemaker2()
            	end
            	if AutoCarry.PluginMenu.useW then Trap() end
            	if AutoCarry.PluginMenu.Combo then Net() PeacemakerCombo() end
			end
			if AutoCarry.PluginMenu.KS then KS() end
			if AutoCarry.PluginMenu.Dash then Dash() end
		--
	if not AutoCarry.PluginMenu.extra.useRanger then
	AutoCarry.PluginMenu.extra.xRanger = 1300
	AutoCarry.PluginMenu.extra.qRanger = 1300
	end
	
-- Infos
	if AutoCarry.PluginMenu.extra.HitChanceInfo then
		PrintChat ("<font color='#FFFFFF'>Hitchance 0: No waypoints found for the target, returning target current position</font>")
		PrintChat ("<font color='#FFFFFF'>Hitchance 1: Low hitchance to hit the target</font>")
		PrintChat ("<font color='#FFFFFF'>Hitchance 2: High hitchance to hit the target</font>")
		PrintChat ("<font color='#FFFFFF'>Hitchance 3: Target too slowed or/and too close(~100% hit chance)</font>")
		PrintChat ("<font color='#FFFFFF'>Hitchance 4: Target inmmobile(~100% hit chace)</font>")
		PrintChat ("<font color='#FFFFFF'>Hitchance 5: Target dashing(~100% hit chance)</font>")
		AutoCarry.PluginMenu.ranges.HitChanceInfo = false
	end
	if AutoCarry.PluginMenu.extra.TrapInfo then
		PrintChat ("<font color='#FFFFFF'>Automatically uses Yordle Snap Trap on inmmobile or dashing targets.</font>")
		AutoCarry.PluginMenu.ranges.TrapInfo = false
	end
end

function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = AutoCarry.GetAttackTarget()
end

function CheckRLevel()
        if myHero:GetSpellData(_R).level == 1 then rRange = 2000
        elseif myHero:GetSpellData(_R).level == 2 then rRange = 2500
        elseif myHero:GetSpellData(_R).level == 3 then rRange = 3000
        end
end

function Peacemaker()
        for i, target in pairs(GetEnemyHeroes()) do
        CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.632, 90, qRange, 2225, myHero)
        if IsSACReborn and QAble and AutoCarry.PluginMenu.useQ and not AutoCarry.Orbwalker:IsShooting() and HitChance >= AutoCarry.PluginMenu.extra.HitChance and GetDistance(CastPosition) < AutoCarry.PluginMenu.extra.qRanger then CastSpell(_Q, CastPosition.x, CastPosition.z)
        elseif QAble and AutoCarry.PluginMenu.useQ and HitChance >= AutoCarry.PluginMenu.extra.HitChance and GetDistance(CastPosition) < AutoCarry.PluginMenu.extra.qRanger then CastSpell(_Q, CastPosition.x, CastPosition.z) end
        end
end

function Peacemaker2()
        for i, target in pairs(GetEnemyHeroes()) do
        CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.632, 90, qRange, 2225, myHero)
        if IsSACReborn and QAble and AutoCarry.PluginMenu.useQ2 and not AutoCarry.Orbwalker:IsShooting() and HitChance >= AutoCarry.PluginMenu.extra.HitChance and GetDistance(CastPosition) < AutoCarry.PluginMenu.extra.qRanger then CastSpell(_Q, CastPosition.x, CastPosition.z)
        elseif QAble and AutoCarry.PluginMenu.useQ2 and HitChance >= AutoCarry.PluginMenu.extra.HitChance and GetDistance(CastPosition) < AutoCarry.PluginMenu.extra.qRanger then CastSpell(_Q, CastPosition.x, CastPosition.z) end
        end
end

function PeacemakerKS()
        for i, target in pairs(GetEnemyHeroes()) do
        CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.632, 90, qRange, 2225, myHero)
        if QAble and HitChance >= 2 and GetDistance(CastPosition) < AutoCarry.PluginMenu.extra.qRanger then CastSpell(_Q, CastPosition.x, CastPosition.z) end
        end
end

function PeacemakerCombo()
        for i, target in pairs(GetEnemyHeroes()) do
        CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.632, 90, qRange, 2225, myHero)
        if QAble and not EAble and HitChance >= 2 and GetDistance(CastPosition) < AutoCarry.PluginMenu.extra.qRanger then CastSpell(_Q, CastPosition.x, CastPosition.z) end
        end
end

function Net()
        for i, target in pairs(GetEnemyHeroes()) do
        CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.1, 80, eRange, 1960, myHero)
        if EAble and HitChance >= AutoCarry.PluginMenu.extra.HitChance and GetDistance(CastPosition) < eRange then CastSpell(_E, CastPosition.x, CastPosition.z) end
        end
end

function Trap()
        for i, target in pairs(GetEnemyHeroes()) do
        CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 1.5, 100, wRange, math.huge, myHero)
        if WAble and HitChance >= 4 and GetDistance(CastPosition) <= 800 then CastSpell(_W, CastPosition.x, CastPosition.z) end
        end
end

function Dash()
         if EAble and AutoCarry.PluginMenu.Dash then
         MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
         HeroPos = Vector(myHero.x, myHero.y, myHero.z)
         DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
          myHero:MoveTo(mousePos.x,mousePos.z)
          CastSpell(_E,DashPos.x,DashPos.z)
         end
end

function RebornCheck()
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
	PrintChat("<font color='#FFFFFF'>>> Officer Caitlyn: I'm on the case.</font>")
end