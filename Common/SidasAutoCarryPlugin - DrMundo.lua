------#################################################################################------  ------###########################    Mundo like a BOSS!    ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Version: 1.1

--> Features:
--> Prodiction on every skillshoot, also taking their hitbox in consideration.
--> Cast options for Q, W, E with health manager (if below "x%" health, not use "x" skills, all set to 0 by default) in both, autocarry and mixed mode (Works separately).
-->> Supports collision and fast collision, customizable to pick betwen one or the other in the Range & Collision Settings menu.
-->> Options to use customizable ranges for Target selector's skill crosshair, Infected Cleaver(Q-Default 1000) and to turn off Burning Agony(W-Default 525).
--> Toggle key for automatic Harrass with Infected Cleaver.
--> Option to KS with Infected Cleaver.
--> Option to don't turn off W automatically, this ignores the range set in the Range & Collision settings to turn off the W, making the plugin not turn off W automatically (So the user have to turn it off when done).
--> Option for auto R with a Health Check slider.
--> Working customizable W usage.
--> Logic to use E will be use E WHEN attacking, activating this right before attacking, for maximum usage efficiency.
--> Farm with Q options for Mixed, LastHit and LaneClear, all optional and separated.
--> Drawing options for Infected Cleaver and Burning Agony.

--> Extra Credits:
--> BotHappy, for the Time to Mundo plugin, which I used as a base for this.

require "Prodiction"

if myHero.charName ~= "DrMundo" then return end

local qRange = 1000
local wRange = 325
local eRange = 225
local wUsed = false
	
local QReady, WReady, EReady, RReady = false, false, false, false
	
local Prodict = ProdictManager.GetInstance()
local ProdictQ = Prodict:AddProdictionObject(_Q, 1000, 1900, 0.250, 80)
local ProdictQCol = nil
local ProdictQFastCol = nil

local HKQ = string.byte("T")

local enemyHeroes = GetEnemyHeroes()

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1000
	Menu()
	RebornCheck()
end

function PluginOnTick()
	Checks()
	if ValidTarget(Target) then
		if (AutoCarry.MainMenu.AutoCarry) then
			InfectedCleaver()
			BurningAgony()
			Masochism()
		end
		if (AutoCarry.MainMenu.MixedMode) then
			InfectedCleaver2()
			BurningAgony2()
			Masochism2()
		end
		if QReady and AutoCarry.PluginMenu.Harrass then 
			ProdictQ:GetPredictionCallBack(Target, CastQ)
		end
	end
	if AutoCarry.PluginMenu.useR then CastREmergency() end
	if AutoCarry.PluginMenu.ksQ then KSQ() end
	if not AutoCarry.PluginMenu.extra.useRanger then
	AutoCarry.PluginMenu.extra.xRanger = 1000
	AutoCarry.PluginMenu.extra.qRanger = 1000
	AutoCarry.PluginMenu.extra.wRanger = 525
	end
--
	if QReady and (AutoCarry.PluginMenu.qFarm and AutoCarry.MainMenu.LastHit) or (AutoCarry.PluginMenu.qClear and AutoCarry.MainMenu.LaneClear) or (AutoCarry.PluginMenu.qMix and AutoCarry.MainMenu.MixedMode) then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange and Minion.health < getDmg("Q", Minion, myHero) then 
			CastSpell(_Q, Minion.x, Minion.z)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero) then 
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if QReady and AutoCarry.PluginMenu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, AutoCarry.PluginMenu.extra.qRanger, 0x6600CC)
		end
		if WReady and AutoCarry.PluginMenu.drawW then 
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x990000)
		end
	end
end

function Menu()
	AutoCarry.PluginMenu:addSubMenu("-- [Range & Collision Settings] --", "extra")
	AutoCarry.PluginMenu.extra:addParam("useRanger", "Use - Custom Ranges", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.extra:addParam("xRanger", "Range - Skill Crosshair", SCRIPT_PARAM_SLICE, 1000, 325, 1500, 0)
	AutoCarry.PluginMenu.extra:addParam("qRanger", "Range - Infected Cleaver", SCRIPT_PARAM_SLICE, 1000, 325, 1050, 0)
	AutoCarry.PluginMenu.extra:addParam("wRanger", "Range - Burning Agony (To turn off)", SCRIPT_PARAM_SLICE, 525, 325, 1500, 0)
	AutoCarry.PluginMenu.extra:addParam("ColSwap", "Use - Fast Collision (Reload)", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep1", "-- Misc Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("Harrass", "Toggle Q Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, HKQ)
	AutoCarry.PluginMenu:permaShow("Harrass")
	AutoCarry.PluginMenu:addParam("ksQ", "KS - Infected Cleaver", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("manageW", "Don't Auto Turn off W", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep1", "-- Ultimate Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("useR", "Auto - Sadism", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("AutoRHP", "R if below X% health", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	AutoCarry.PluginMenu:addParam("sep2", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addSubMenu("-- [Health Manager] --", "extra2")
	AutoCarry.PluginMenu.extra2:addParam("notQ", "Not Q if below X% health", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.extra2:addParam("notW", "Not W if below X% health", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.extra2:addParam("notE", "Not E if below X% health", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu:addParam("useQ", "Use - Infected Cleaver", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useW", "Use - Burning Agony", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useE", "Use - Masochism", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep3", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("useQ2", "Use - Infected Cleaver", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useW2", "Use - Burning Agony", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useE2", "Use - Masochism", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("qMix", "Farm - Infected Cleaver", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep4", "-- Last Hit Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("qFarm", "Farm - Infected Cleaver", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep5", "-- Lane Clear Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("qClear", "Farm - Infected Cleaver", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep6", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("drawQ", "Draw - Infected Cleaver", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("drawW", "Draw - Burning Agony", SCRIPT_PARAM_ONOFF, true)
	
end

function Checks()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	Target = AutoCarry.GetAttackTarget()
	Minion = AutoCarry.GetMinionTarget()
	if myHero.dead then wUsed = false end
end
 
function KSQ()
    for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if QReady and ValidTarget(Enemy, qRange, true) and Enemy.health < getDmg("Q",Enemy,myHero) + 30 then
            CastQKS(Enemy)
        end
    end
end

function InfectedCleaver() 
	if QReady and AutoCarry.PluginMenu.useQ and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notQ*0.01)) then 
		ProdictQ:GetPredictionCallBack(Target, CastQ)
	end
end

function BurningAgony()
	if WReady and AutoCarry.PluginMenu.useW and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notW*0.01)) then 
		if not wUsed and CountEnemyHeroInRange(wRange) >= 1 then
			CastSpell(_W)
		elseif wUsed and CountEnemyHeroInRange(AutoCarry.PluginMenu.extra.wRanger) == 0 and not AutoCarry.PluginMenu.manageW then
			CastSpell(_W)
		end
	end
end

function Masochism() 
	if IsSACReborn and EReady and AutoCarry.PluginMenu.useE and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notE*0.01)) and AutoCarry.Orbwalker:IsShooting() then
			CastSpell(_E)
	elseif not IsSACReborn and EReady and AutoCarry.PluginMenu.useE and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notE*0.01)) and AutoCarry.CurrentlyShooting then
			CastSpell(_E)
	end
end

function InfectedCleaver2() 
	if QReady and AutoCarry.PluginMenu.useQ2 and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notQ*0.01)) then 
		ProdictQ:GetPredictionCallBack(Target, CastQ)
	end
end

function BurningAgony2()
	if WReady and AutoCarry.PluginMenu.useW2 and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notW*0.01)) then 
		if not wUsed and CountEnemyHeroInRange(wRange) >= 1 then
			CastSpell(_W)
		elseif CountEnemyHeroInRange(AutoCarry.PluginMenu.extra.wRanger) == 0 and wUsed and not AutoCarry.PluginMenu.manageW then
			CastSpell(_W)
		end
	end
end

function Masochism2() 
	if IsSACReborn and EReady and AutoCarry.PluginMenu.useE2 and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notE*0.01)) and AutoCarry.Orbwalker:IsShooting() and GetDistance(Target) <= 225 then
			CastSpell(_E)
	elseif not IsSACReborn and EReady and AutoCarry.PluginMenu.useE2 and myHero.health > (myHero.maxHealth*(AutoCarry.PluginMenu.extra2.notE*0.01)) and AutoCarry.CurrentlyShooting and GetDistance(Target) <= 225 then
			CastSpell(_E)
	end
end

function GetHitBoxRadius(target)
	return GetDistance(target, target.minBBox)
end

function CastQ(unit, pos, spell)
        if GetDistance(pos) - getHitBoxRadius(unit)/2 < AutoCarry.PluginMenu.extra.qRanger then
                if AutoCarry.PluginMenu.extra.ColSwap then
                local willCollide = ProdictQFastCol:GetMinionCollision(pos, myHero)
                if not willCollide then CastSpell(_Q, pos.x, pos.z) end
                else
                local willCollide = ProdictQCol:GetMinionCollision(pos, myHero)
                if not willCollide then CastSpell(_Q, pos.x, pos.z) end
                end
        end
end

function CastQKS(Unit)
    if GetDistance(Unit) - GetHitBoxRadius(Unit)*0.5 < qRange and ValidTarget(Unit) and AutoCarry.PluginMenu.extra.ColSwap then
        QPos = ProdictQ:GetPrediction(Unit)
        local WillCollide = ProdictQFastCol:GetMinionCollision(QPos, myHero)
        if not WillCollide then CastSpell(_Q, QPos.x, QPos.z) end
    elseif GetDistance(Unit) - GetHitBoxRadius(Unit)*0.5 < qRange and ValidTarget(Unit) then
        QPos = ProdictQ:GetPrediction(Unit)
        local WillCollide = ProdictQCol:GetMinionCollision(QPos, myHero)
        if not WillCollide then CastSpell(_Q, QPos.x, QPos.z) end
    end
end

function CastREmergency()
    if myHero.health < (myHero.maxHealth*(AutoCarry.PluginMenu.AutoRHP*0.01)) then
		if RReady then
			CastSpell(_R)
        end
    end
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name == myHero:GetSpellData(_W).name then
	if not wUsed then wUsed = true else wUsed = false end
	end
end

function RebornCheck()
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
	if AutoCarry.PluginMenu.extra.ColSwap then
		require "FastCollision"
		ProdictQFastCol = FastCol(ProdictQ)
		PrintChat("<font color='#FFFFFF'>>> Mundo Corp.: Fast Collision Loaded!</font>")
	else
		require "Collision"
		ProdictQCol = Collision(qRange, 1900, 0.250, 80)
		PrintChat("<font color='#FFFFFF'>>> Mundo Corp.: Normal Collision Loaded!</font>") end
end