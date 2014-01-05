------#################################################################################------  ------###########################    Gragas Happy Hour!    ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Vip Version: 1.3

--> Features:
--> Prodictions in every skill, also taking their hitboxes in consideration.
--> Cast options for Q, E and R in both, autocarry and mixed mode (Works separately).
--> KS with Explosive Cask and Barrel Roll, will use then if the enemy is killable. (can be turned on/off).
--> Options to use MEC on Explosive Cask (Only use ulti if it will hit "x" number of enemies), keep in mind that for now, it either uses MEC or Prodictions for the Ultimate (Can't use both at the same time, if you disable MEC you enable Prodictions, even with MEC enabled other skills still use Prodictions).
--> Draw options for every skill.
--> Option to auto-explode Barrel if it will hit an enemy, also will not explode the barrel if it will not hit while holding the Autocarry/Mixed mode Keys, you can still explode it with Q manually.

if myHero.charName ~= "Gragas" then return end

require "AoE_Skillshot_Position"
require "Collision"
require "Prodiction"

local Prodict = ProdictManager.GetInstance()
local ProdictQ
local ProdictE, ProdictECol
local ProdictR

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1100
	--> Main Load
	mainLoad()
	--> Main Menu
	mainMenu()
	--> Check Barrel
end

function PluginOnTick()
	Checks()
	if Menu.explodeQ and QREADY then explodeQ() end
	if Menu.ultKS and RREADY then ultKS() end
	if Menu.barrelKS and QREADY then barrelKS() end
	if Target and (AutoCarry.MainMenu.MixedMode) then
		if QREADY and Menu.useQ2 and GetDistance(Target) < qRange and barrel == nil then ProdictQ:EnableTarget(Target, true) end
		if EREADY and Menu.useE2 and GetDistance(Target) < eRange then ProdictE:EnableTarget(Target, true) end
		if RREADY and Menu.useR2 then castR(Target) end
	end
	if Target and (AutoCarry.MainMenu.AutoCarry) then
		if QREADY and Menu.useQ and GetDistance(Target) < qRange and barrel == nil then ProdictQ:EnableTarget(Target, true) end
		if EREADY and Menu.useE and GetDistance(Target) < eRange then ProdictE:EnableTarget(Target, true) end
		if RREADY and Menu.useR then castR(Target) end
	end
end

function PluginOnDraw()
	--> Ranges
	if not Menu.drawMaster and not myHero.dead then
		if QREADY and Menu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FFFF)
		end
		if EREADY and Menu.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFF0000)
		end
		if RREADY and Menu.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x9933FF)
		end
	end
end

--> Check Barrel
function OnCreateObj(obj)
	if obj ~= nil and string.find(obj.name, "barrelfoam") then
			barrel = obj
	end
end

function OnDeleteObj(obj)
	if obj ~= nil and string.find(obj.name, "barrelfoam") then
		barrel = nil
	end
end

--> Auto Explode
function explodeQ()	
	if barrel ~= nil then
		for i=1, heroManager.iCount do
			enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and not enemy.dead and enemy.visible then
				if GetDistance(enemy, barrel) < q2Range then
					CastSpell(_Q)
					barrel = nil
				end
			end
		end
	end
end

--> Ult KS
function ultKS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local rDmg = getDmg("R", enemy, myHero)
		if Target and not Target.dead and Target.health < rDmg then
			ProdictR:EnableTarget(Target, true)
		end
	end
end

--> barrel KS
function barrelKS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local qDmg = getDmg("Q", enemy, myHero)
		if Target and not Target.dead and Target.health < qDmg then
			ProdictQ:EnableTarget(Target, true)
		end
	end
end

--> Checks
function Checks()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
end

--> MEC
function CountEnemies(point, range)
        local ChampCount = 0
        for j = 1, heroManager.iCount, 1 do
                local enemyhero = heroManager:getHero(j)
                if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, rRange+150) then
                        if GetDistance(enemyhero, point) <= range then
                                ChampCount = ChampCount + 1
                        end
                end
        end            
        return ChampCount
end

function castR(target)
        if Menu.rMEC then
                local ultPos = GetAoESpellPosition(350, target)
                if ultPos and GetDistance(ultPos) <= rRange     then
                        if CountEnemies(ultPos, 350) >= Menu.rEnemies then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        elseif GetDistance(target) <= rRange then
                ProdictR:EnableTarget(Target, true)
        end
end

--> Main Load
function mainLoad()
	Cast = AutoCarry.CastSkillshot	
	Menu = AutoCarry.PluginMenu
	Target = AutoCarry.GetAttackTarget()
	qRange, eRange, rRange, q2Range = 1100, 600, 1050, 330
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	ProdictQ = Prodict:AddProdictionObject(_Q, qRange, 1000, 0.250, 125, myHero, CastQ)
	for I = 1, heroManager.iCount do
		local hero = heroManager:GetHero(I)
		if hero.team ~= myHero.team then
			ProdictQ:CanNotMissMode(true, hero)
		end
	end
	ProdictE = Prodict:AddProdictionObject(_E, eRange, 900, 0.1, 125, myHero, CastE)
	ProdictECol = Collision(eRange, 1000, 0.250, 150)
	for I = 1, heroManager.iCount do
		local hero = heroManager:GetHero(I)
		if hero.team ~= myHero.team then
			ProdictE:CanNotMissMode(true, hero)
		end
	end
	ProdictR = Prodict:AddProdictionObject(_R, rRange, 2000, 0.250, 0, myHero, CastR)
	for I = 1, heroManager.iCount do
		local hero = heroManager:GetHero(I)
		if hero.team ~= myHero.team then
			ProdictR:CanNotMissMode(true, hero)
		end
	end
end

local function getHitBoxRadius(target)
  return GetDistance(target, target.minBBox)
end

function CastE(unit, pos, spell)
  if GetDistance(pos) - getHitBoxRadius(unit)/2 < qRange then
    local willCollide = ProdictECol:GetMinionCollision(pos, myHero)
    if not willCollide then CastSpell(_E, pos.x, pos.z) end
  end
end

function CastQ(unit, pos, spell)
  if GetDistance(pos) - getHitBoxRadius(unit)/2 < qRange then
    CastSpell(_Q, pos.x, pos.z)
  end
end

function CastR(unit, pos, spell)
  if GetDistance(pos) - getHitBoxRadius(unit)/2 < rRange then
   CastSpell(_R, pos.x, pos.z)
  end
end

--> Main Menu
function mainMenu()
	Menu:addParam("sep", "-- KS Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("ultKS", "Kill with Explosive Cask", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("barrelKS", "Kill with Barrel Roll", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep", "-- Ultimate Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("rMEC", "Explosive Cask - Use MEC", SCRIPT_PARAM_ONOFF, true)
  Menu:addParam("rEnemies", "Explosive Cask - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("sep1", "-- Autocarry Mode --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Barrel Roll", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Body Slam", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use - Explosive Cask", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Mixed Mode --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ2", "Use - Barrel Roll", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE2", "Use - Body Slam", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR2", "Use - Explosive Cask", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep3", "-- Misc Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("explodeQ", "Auto Explode - Barrel", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep4", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawQ", "Draw - Barrel Roll", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawE", "Draw - Body Slam", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawR", "Draw - Explosive Cask", SCRIPT_PARAM_ONOFF, false)
end

--UPDATEURL=
--HASH=CA5FC16FF6041A71E1B02BA74E069502
