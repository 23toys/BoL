if myHero.charName ~= "Sona" then return end

require "AoE_Skillshot_Position"

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1050
	--> Main Load
	mainLoad()
	--> Main Menu
	mainMenu()
end

function PluginOnTick()
	Checks()
	if Target and (AutoCarry.MainMenu.MixedMode) then
		if QREADY and Menu.useQ2 and GetDistance(Target) <= qRange then CastSpell(_Q) end
		if RREADY and Menu.useR2 then castR(Target) end
	end
		if Target and (AutoCarry.MainMenu.AutoCarry) then
		if QREADY and Menu.useQ and GetDistance(Target) <= qRange then CastSpell(_Q) end
		if RREADY and Menu.useR then castR(Target) end
	end
end

function PluginOnDraw()
	--> Ranges
	if not Menu.drawMaster and not myHero.dead then
		if QREADY and Menu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FFFF)
		end
		if RREADY and Menu.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x00FF00)
		end
	end
end


--> Checks
function Checks()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
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
                if ultPos and GetDistance(ultPos) <= rRange-350     then
                        if CountEnemies(ultPos, 350) >= Menu.rEnemies then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        elseif GetDistance(target) <= rRange then
                Cast(SkillR, Target)
        end
end

--> Main Load
function mainLoad()
	qRange, rRange = 700, 1000
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	SkillR = {spellKey = _R, range = rRange, speed = 2.0, delay = 250}
	Cast = AutoCarry.CastSkillshot
	Menu = AutoCarry.PluginMenu
end

--> Main Menu
function mainMenu()
	Menu:addParam("sep0", "-- Ultimate Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("rMEC", "Crescendo - Use MEC", SCRIPT_PARAM_ONOFF, true)
  Menu:addParam("rEnemies", "Crescendo - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("sep1", "-- Autocarry Mode --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Hymn of Valor", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use - Crescendo", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Mixed Mode --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ2", "Use - Hymn of Valor", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR2", "Use - Crescendo", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawQ", "Draw - Hymn of Valor", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawR", "Draw - Crescendo", SCRIPT_PARAM_ONOFF, false)
end

--UPDATEURL=
--HASH=9A6942A86DEC56BA05A9B499C58EAE76
