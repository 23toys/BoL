------#################################################################################------  ------###########################  Anivia bring the storm! ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Version: 1.5b
--> Features:
--> Prodictions in every skill, also taking their hitboxes in consideration.
--> Cast options for Q, W, E and R in both, autocarry and mixed mode (Works separately).
--> Option to Auto-Explode Q if it will stun an enemy.
--> It will only cast E if target is chilled (double damage), there is an option to disable it however.
--> Put the Wall behind the target, so he can't run, the wall actually uses Prodiction (Also the ultimate too).
--> KS option to kill with E even if target is not chilled, if the target will die from it.
--> Draw options for every skill, and also a option to draw the furthest skill avaiable.
--> Option to disable auto-attack in autocarry mode.
--> Hotkey to create a defensive wall, that will block your target from reaching you.
--> Pick the distance to use the wall from the target with a slider (if you feel like it is misplaced), you can pick between 0 and 300 (if you pick 0... dude...) default is 100 (Originally was 100 since the first version, works fine for me, but if you feel like it is misplaced you can increase the distance, or if you feel like you could pull your target with the wall, put less than 100), it will also affect the defensive wall, but in the oposite way (tl;dr in autocarry higher value = will put the wall further, in defensive hotkey = will put the wall closer).
--> Smart Combo (Turn on/off), if smart combo option is enabled it will hold Flash Frost and Crystallize, and only use it after using Glacial Storm, this way your chances of hitting Flash Frost are increased a lot, and the wall will keep your enemies in place for a longer duration, therefore dealing more DPS with Glacial Storm (If you enable Smart Combo it will auto-disable use Q and use W in the autocarry menu, since it will use Q and W under specific conditions, however you can still use it without those conditions in mixed mode).
--> Lag-Free Drawings option into the drawings menu, if you are having FPS issues with this plugin, you can enable it instead of disabling the drawings (If you want to disable it you have to uncheck the option and reload the plugin with F9).
--> KS ignite option.

if myHero.charName ~= "Anivia" then return end

require "Prodiction"

local qRange = 1100
local qRange2 = 185
local wRange = 1000
local eRange = 700
local rRange = 615

local QAble, WAble, eAble, RAble = false, false, false, false

local Prodict = ProdictManager.GetInstance()
local ProdictQ
local ProdictW
local ProdictR
local ProdictW2

local anir = false
local throwq = false

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1100
	Menu()
	
	ProdictQ = Prodict:AddProdictionObject(_Q, qRange, 860.05, 0.250, 110)
	ProdictW = Prodict:AddProdictionObject(_W, wRange, math.huge, 0.100, 350)
	ProdictR = Prodict:AddProdictionObject(_R, rRange, math.huge, 0.100, 350)
	ProdictW2 = Prodict:AddProdictionObject(_W, wRange, math.huge, 0.100, 350)
			
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
    igniteslot = SUMMONER_1
  elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
    igniteslot = SUMMONER_2
 end
end

function PluginOnTick()
	Checks()
	FlameOn()
	if Target then
		if Target and (AutoCarry.MainMenu.AutoCarry) then
			Flash()
			FlashSmart()
			Wall()
			WallSmart()
			Frostbite()
			Frostiebite2()
			Glacial()
		end
		if Target and (AutoCarry.MainMenu.MixedMode) then
		  Flash2()
			Wall2()
			Frostbite2()
			Frostiebite2()
			Glacial2()
		end
		if AutoCarry.PluginMenu.explodeQ then explodeQ() end
		if Target and AutoCarry.PluginMenu.KS then KS() end
		if AutoCarry.PluginMenu.noAttack and AutoCarry.MainMenu.AutoCarry then AutoCarry.CanAttack = false else AutoCarry.CanAttack = true end
		if AutoCarry.PluginMenu.useWkey then WallD() end
		if AutoCarry.PluginMenu.useSmart then 
		AutoCarry.PluginMenu.useQ = false
		AutoCarry.PluginMenu.useW = false 
		end
	end
end

function PluginOnDraw()
    if not myHero.dead then
			if AutoCarry.PluginMenu.EnableLagFree then _G.DrawCircle = DrawCircle2 end
		  if QAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
      else
      if WAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0xFFFFFF)
			else
			if EAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFFFFFF)
			else
			if RAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0xFFFFFF)
			else
      end
      end
      if QAble and AutoCarry.PluginMenu.drawQ then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
		  end
		  if WAble and AutoCarry.PluginMenu.drawW then
      DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0xFF0000)
		  end
      if EAble and AutoCarry.PluginMenu.drawE then
      DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x9933FF)
		  end
      if RAble and AutoCarry.PluginMenu.drawR then
      DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x9933FF)
	    end
		end
   end
	end
end

function Menu()
	local HKW = string.byte("A")
	local HKS = string.byte("S")
	AutoCarry.PluginMenu:addParam("sep", "-- Misc Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("explodeQ", "Explode - Flash Frost", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("KS", "KS - Frost Bite", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("KSIgnite", "KS - Ignite", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("wallRange", "Distance - Wall from Target", SCRIPT_PARAM_SLICE, 100, 0, 300, 0)
	AutoCarry.PluginMenu:addParam("useWkey", "Defensive - Crystallize", SCRIPT_PARAM_ONKEYDOWN, false, HKW)
	AutoCarry.PluginMenu:addParam("sep2", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("wasteE", "Frostbite Non-Chilled", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("noAttack", "Disable Auto-Attack", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("useSmart", "Smart Combo", SCRIPT_PARAM_ONKEYTOGGLE, false, HKS)
	AutoCarry.PluginMenu:addParam("sep3", "[Cast]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("useQ", "Use - Flash Frost", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useW", "Use - Crystallize", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useE", "Use - Frostbite", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useR", "Use - Glacial Storm", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep4", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("wasteE2", "Frostbite Non-Chilled", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep5", "[Cast]", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("useQ2", "Use - Flash Frost", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useW2", "Use - Crystallize", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useE2", "Use - Frostbite", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("useR2", "Use - Glacial Storm", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep6", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("EnableLagFree","Enable Lag-Free Drawings", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("drawF", "Draw - Furthest Spell Avaiable", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("drawQ", "Draw - Flash Frost", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("drawW", "Draw - Crystallize", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("drawE", "Draw - Frostbite", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("drawR", "Draw - Glacial Storm", SCRIPT_PARAM_ONOFF, false)
end

function Checks()
  QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)
  EAble = (myHero:CanUseSpell(_E) == READY)
  RAble = (myHero:CanUseSpell(_R) == READY)
  Target = AutoCarry.GetAttackTarget()
end

function Flash() 
	if QAble and AutoCarry.PluginMenu.useQ and not throwq then ProdictQ:GetPredictionCallBack(Target, CastQ) end
end	

function FlashSmart() 
	if QAble and AutoCarry.PluginMenu.useSmart and not throwq and anir then ProdictQ:GetPredictionCallBack(Target, CastQ) end
end	

function Wall(target)
  if WAble and AutoCarry.PluginMenu.useW then ProdictW:GetPredictionCallBack(Target, CastW) end
end

function WallSmart(target)
  if WAble and AutoCarry.PluginMenu.useSmart and anir then ProdictW:GetPredictionCallBack(Target, CastW) end
end

function Frostbite() 
	if TargetHaveBuff("chilled", Target) and EAble and AutoCarry.PluginMenu.useE and GetDistance(Target) <= eRange then
	CastSpell(_E, Target) end
end	

function Frostiebite() 
	if AutoCarry.PluginMenu.wasteE and EAble and AutoCarry.PluginMenu.useE and GetDistance(Target) <= eRange then
	CastSpell(_E, Target) end
end	

function Glacial() 
	if RAble and AutoCarry.PluginMenu.useR and not anir then ProdictR:GetPredictionCallBack(Target, CastR) end
end	

function Flash2() 
	if QAble and AutoCarry.PluginMenu.useQ2 and not throwq then ProdictQ:GetPredictionCallBack(Target, CastQ) end
end	

function Wall2()
  if WAble and AutoCarry.PluginMenu.useW2 then ProdictW:GetPredictionCallBack(Target, CastW) end
end

function WallD()
  if WAble then ProdictW2:GetPredictionCallBack(Target, CastW2) end
end


function Frostbite2() 
	if TargetHaveBuff("chilled", Target) and EAble and AutoCarry.PluginMenu.useE2 and GetDistance(Target) <= eRange then
	CastSpell(_E, Target) end
end	

function Frostiebite2() 
	if AutoCarry.PluginMenu.wasteE and EAble and AutoCarry.PluginMenu.useE and GetDistance(Target) <= eRange then
	CastSpell(_E, Target) end
end	

function Glacial2() 
	if RAble and AutoCarry.PluginMenu.useR2 and not anir then ProdictR:GetPredictionCallBack(Target, CastR) end
end	

local function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)
end

function CastQ(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(unit)/2 < qRange then
		CastSpell(_Q, pos.x, pos.z) end
	end
	
function CastW(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(unit)/2 < wRange then
		CastSpell(_W, pos.x + AutoCarry.PluginMenu.wallRange, pos.z + AutoCarry.PluginMenu.wallRange) end
	end
	
function CastW2(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(unit)/2 < wRange then
		CastSpell(_W, pos.x - AutoCarry.PluginMenu.wallRange, pos.z - AutoCarry.PluginMenu.wallRange) end
	end

function CastR(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(unit)/2 < rRange then
		CastSpell(_R, pos.x, pos.z) end
end


function PluginOnCreateObj(obj)
        if obj.name:find("FlashFrost_mis") then
                        aniq = obj
												throwq = true
        end
        if obj.name:find("cryo_storm") then
                        anir = true
        end
end
 
function PluginOnDeleteObj(obj)
        if obj.name:find("FlashFrost_mis") then
                aniq = nil
								throwq = false
        end
        if obj.name:find("cryo_storm") then
                anir = false
        end
end

function explodeQ()	
	if aniq ~= nil then
		for i=1, heroManager.iCount do
			enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and not enemy.dead and enemy.visible then
				if GetDistance(enemy, aniq) < qRange2 then
					CastSpell(_Q)
					aniq = nil
					throwq = false
				end
			end
		end
	end
end

function KS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local eDmg = getDmg("E", enemy, myHero)
		if Target and not Target.dead and Target.health < eDmg and GetDistance(Target) < eRange then
			CastSpell(_E, Target)
		end
	end
end

function FlameOn( )
    for _, igtarget in pairs(GetEnemyHeroes()) do
                if ValidTarget(igtarget, 600) and KSIgnite and igtarget.health <= 50 + (20 * player.level) then
                CastSpell(igniteslot, igtarget)
        end
    end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75) 
    end
end

--UPDATEURL=
--HASH=3A2C4D06C69425FC5EC1C9E6FABC4A9C
