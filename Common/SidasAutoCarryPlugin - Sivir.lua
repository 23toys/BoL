------#################################################################################------  ------###########################      Snowstorm Sivir     ############################------ ------###########################          by Toy          ############################------ ------#################################################################################------

--> Version: 1.0

--> Features:
--> Prodictions for Boomerang Blade (Q).
--> Auto-Attack W Reset usage made with a Reborn API, so it might be faster than the regular OnAttacked style of getting the AA reset out of her W.
--> Range Settings for Boomerang Blade (Q), default is 875, max range is 1075, keep in mind that if you lower the range, you're most likely to get the return damage of the Boomerang on the enemy, 875 is working just fine here, but you can choose to put it in a higher or lower range, I don't recommend using max Range (1075).
--> KS option with Boomerang blade, ignores the range settings and throw it for max range on a killable enemy if you can get him with Q.
--> Option to use the AA>W Reset while holding wave clear key, for orbwalking turrets, jungle mobs and  minions waves.
--> Optional drawing for Boomerang Blade (Q).

if myHero.charName ~= "Sivir" then return end

require "Prodiction"

-- Constants
local qRange = 1050

local QAble, WAble, RAble = false, false, false
 
local Prodict = ProdictManager.GetInstance()
local ProdictQ

-- PROdiction
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 1075
        Menu()
       
        ProdictQ = Prodict:AddProdictionObject(_Q, AutoCarry.PluginMenu.qRanger, 1350, 0.250, 85)
end
 
-- Drawings
function PluginOnDraw()
        if not myHero.dead then
                if QAble and AutoCarry.PluginMenu.drawQ then
                        DrawCircle(myHero.x, myHero.y, myHero.z, AutoCarry.PluginMenu.qRanger, 0x6600CC)
                end
        end
end
 
 -- KS
function KS()
    for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if QAble and ValidTarget(Enemy, qRange, true) and Enemy.health < getDmg("Q",Enemy,myHero) then
            CastQKS(Enemy)
        end
    end
end

function Menu()
AutoCarry.PluginMenu:addParam("sep", "-- Misc Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("KS", "KS - Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("qRanger", "Range - Boomerange Blade", SCRIPT_PARAM_SLICE, 875, 550, 1075, 0)
AutoCarry.PluginMenu:addParam("sep1", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "") 
AutoCarry.PluginMenu:addParam("useQ", "Use - Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("useW", "Use - Ricochet", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("useQ2", "Use - Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("useW2", "Use - Ricochet", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("sep3", "-- Lane Clear Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("useW3", "Use - Ricochet", SCRIPT_PARAM_ONOFF, false)
AutoCarry.PluginMenu:addParam("sep4", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("drawQ", "Draw - Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnTick()
        Checks()
		if Target then
            if Target and (AutoCarry.MainMenu.AutoCarry) then
				Boomerang()
				Ricochet()
            end
            if Target and (AutoCarry.MainMenu.MixedMode) then
				Boomerang2()
				Ricochet2()
            end
			if AutoCarry.PluginMenu.KS and QAble then KS()
			end

		end
		if (AutoCarry.MainMenu.LaneClear) then
			Ricochet3()
		end
end

function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = AutoCarry.GetAttackTarget()
end

function Boomerang()
        if QAble and AutoCarry.PluginMenu.useQ then ProdictQ:GetPredictionCallBack(Target, CastQ)
        end
end

function Ricochet()
        if WAble and AutoCarry.PluginMenu.useW and AutoCarry.Orbwalker:IsAfterAttack() then CastSpell(_W)
        end
end
 
function Boomerang2()
        if QAble and AutoCarry.PluginMenu.useQ2 then ProdictQ:GetPredictionCallBack(Target, CastQ)
        end
end

function Ricochet2()
        if WAble and AutoCarry.PluginMenu.useW2 and GetDistance(Target) < 500 and AutoCarry.Orbwalker:IsAfterAttack() then CastSpell(_W)
        end
end

function Ricochet3()
        if WAble and AutoCarry.PluginMenu.useW3 and AutoCarry.Orbwalker:IsAfterAttack() then CastSpell(_W)
        end
end
 
local function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)
end

function CastQ(unit, pos, spell)
        if GetDistance(pos) - getHitBoxRadius(unit)/2 < AutoCarry.PluginMenu.qRanger then
          CastSpell(_Q, pos.x, pos.z)
        end
end

function CastQKS(Unit)
        if GetDistance(Unit) - getHitBoxRadius(Unit)*0.5 < qRange and ValidTarget(Unit) then
          QPos = ProdictQ:GetPrediction(Unit)
          CastSpell(_Q, QPos.x, QPos.z)
        end
end