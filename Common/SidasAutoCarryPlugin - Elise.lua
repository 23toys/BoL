------#################################################################################------  ------##########################      Victorious Elise      ###########################------ ------##########################           by Toy           ###########################------ ------#################################################################################------

--> Version: 1.2b

--> Features:
--> Prodictions in every skillshoot, also taking their hitboxes in consideration.
--> Cast options for Q, W and E in both forms for autocarry, and Human form skills for mixed mode (Works separately).
--> KS with Neurotoxin and Venomous Bite, will use Q if the enemy is killable. (can be turned on/off).
--> Draw options for every skill, and also a option to draw the furthest skill avaiable.
--> Options to Last Hit with Venomous Bite in LastHit and LaneClear mode.
--> Options to change to Spider form or Human form when you have all your skills in that mode on cooldown and is holding the autocarry key.
--> Options to use W only when target is stunned in Autocarry or Mixed mode (or both).
--> Option to use rappel only when target is "x" distance away from you (set with a slider).
--> Hotkey to rappel into target (if you don't like it being used when you press autocarry, and wanna use your own judgment to use rappel, but like it to target rappel for you because it's faster/why not).

if myHero.charName ~= "Elise" then return end
 
require "Collision"
require "Prodiction"
 
local qRange = 625
local qRange2 = 475
local wRange = 950
local eRange = 1075

local Stunned = false
 
local QAble, WAble, Eable, RAble = false, false, false, false
 
local Prodict = ProdictManager.GetInstance()
local ProdictE, ProdictECol
local ProdictW, ProdictWCol

function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 1050
        Menu()
       
        ProdictE = Prodict:AddProdictionObject(_E, eRange, 1450, 0.250, 80)
        ProdictECol = Collision(eRange, 1450, 0.250, 80)
        ProdictW = Prodict:AddProdictionObject(_W, wRange, 800, 0.250, 90)
        ProdictWCol = Collision(eRange, 800, 0.250, 120)
end

function KS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local qDmg = getDmg("Q", enemy, myHero)
		if Target and not Target.dead and Target.health < qDmg then
			CastSpell(_Q, Target)
		end
	end
end
 
function PluginOnTick()
    Checks()
    CheckForms()
    if Target then
      if Target and (AutoCarry.MainMenu.AutoCarry) and HumanForm then
        Neurotoxin()
        Spiderling()
				SpiderlingS()
				Cacoon()
				SpiderFormC()
      end
			if Target and (AutoCarry.MainMenu.AutoCarry) and SpiderForm then
				Bite()
				Frenzy()
				Rappel()
				HumanFormC()
			end
      if Target and (AutoCarry.MainMenu.MixedMode) and HumanForm then
        Neurotoxin2()
  		  Spiderling2()
				Spiderling2S()
				Cacoon2()
      end
			if Target and (AutoCarry.MainMenu.MixedMode) and SpiderForm then
				Bite()
				Frenzy()
			end
			if AutoCarry.PluginMenu.KS and QAble then KS()
			end
			if AutoCarry.PluginMenu.useEkey then Rappel()
			end
    end

--Last Hit
	if QAble and AutoCarry.PluginMenu.qFarm and AutoCarry.MainMenu.LastHit then
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
--Lane Clear	
	if QAble and AutoCarry.PluginMenu.qFarm and AutoCarry.MainMenu.LaneClear then
		if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange and Minion.health < getDmg("Q", Minion, myHero) and SpiderForm then 
			CastSpell(_Q, Minion)
		else 
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero) and SpiderForm then 
					CastSpell(_Q, minion)
				end
			end
		end
	end
end
 
function PluginOnDraw()
    if not myHero.dead then
		  if QAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
      else
      if WAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0xFFFFFF)
			else
			if EAble and AutoCarry.PluginMenu.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFFFFFF)
			else
      end
      end
      if QAble and AutoCarry.PluginMenu.drawQ and HumanForm then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
			end
			if QAble and AutoCarry.PluginMenu.drawQ and SpiderForm then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange2, 0xFFFFFF)
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
end

 function Menu()
  local HKE = string.byte("E")
  AutoCarry.PluginMenu:addParam("sep", "-- Form Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useR", "Change to Spider Form", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useRs", "Change to Human Form", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("sepm", "-- KS Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("KS", "KS - Neurotoxin/Venomous Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep1", "-- Autocarry Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("stunC", "Only W stunned targets", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("sepH", "[Human Form]", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useQ", "Use - Neurotoxin", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW", "Use - Volatile Spiderling", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useE", "Use - Cacoon", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sepS", "[Spider Form]", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useQs", "Use - Venomous Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useWs", "Use - Skittering Frenzy", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useEs", "Use - Rappel", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("minRange", " Min. Distance - Rappel", SCRIPT_PARAM_SLICE, 500, 100, 1075, 0)
  AutoCarry.PluginMenu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("stunC2", "Only W stunned targets", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useQ2", "Use - Neurotoxin", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW2", "Use - Volatile Spiderling", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useE2", "Use - Cacoon", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep3", "-- Last Hit Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("qFarm", "Farm - Venomous Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep4", "-- Lane Clear Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("qClear", "Farm - Venomous Bite", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("sep5", "-- Hotkey Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("useEkey", "Use - Rappel", SCRIPT_PARAM_ONKEYDOWN, false, HKE)
  AutoCarry.PluginMenu:addParam("sep6", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
  AutoCarry.PluginMenu:addParam("drawF", "Draw - Furthest Spell Available", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawQ", "Draw - Neurotoxin/Venomous Bite", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("drawW", "Draw - Volatile Spiderling", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("drawE", "Draw - Cocoon/Rappel", SCRIPT_PARAM_ONOFF, false)
end
 
function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = AutoCarry.GetAttackTarget()
        Minion = AutoCarry.GetMinionTarget()
end
 
 function Neurotoxin()
        if QAble and AutoCarry.PluginMenu.useQ and GetDistance(Target) < qRange then CastSpell(_Q, Target) end
end   
 
function SpiderlingS()
      if WAble and AutoCarry.PluginMenu.useW and AutoCarry.PluginMenu.stunC and Stunned then
			ProdictW:GetPredictionCallBack(Target, CastW) end 
end  

function Spiderling()
      if WAble and AutoCarry.PluginMenu.useW and not AutoCarry.PluginMenu.stunC then
			ProdictW:GetPredictionCallBack(Target, CastW) end 
end  

function Cacoon()
        if EAble and AutoCarry.PluginMenu.useE and HumanForm then ProdictE:GetPredictionCallBack(Target, CastE) end
end    

 function Neurotoxin2()
        if QAble and AutoCarry.PluginMenu.useQ and GetDistance(Target) < qRange then CastSpell(_Q, Target) end
end     
 
function Spiderling2S()
      if WAble and AutoCarry.PluginMenu.useW2 and AutoCarry.PluginMenu.stunC2 and Stunned then
			ProdictW:GetPredictionCallBack(Target, CastW) end 
end   

function Spiderling2()
      if WAble and AutoCarry.PluginMenu.useW2 and not AutoCarry.PluginMenu.stunC2 then
			ProdictW:GetPredictionCallBack(Target, CastW) end 
end 
	
function Cacoon2()
        if EAble and AutoCarry.PluginMenu.useE and HumanForm then ProdictE:GetPredictionCallBack(Target, CastE) end
end   
	
function SpiderFormC()
        if RAble and AutoCarry.PluginMenu.useR and HumanForm and not QAble and not EAble and not WAble then CastSpell(_R) end
end    

function Bite()
				if QAble and AutoCarry.PluginMenu.useQs and GetDistance(Target) <= qRange2 then 
				CastSpell(_Q, Target) end
end

function Frenzy()
				if WAble and AutoCarry.PluginMenu.useWs and GetDistance(Target) <= 150 then
				CastSpell(_W) end
end

function Rappel()
				if EAble and AutoCarry.PluginMenu.useEs and GetDistance(Target) <= eRange and (GetDistance(Target) > AutoCarry.PluginMenu.minRange) then
				CastSpell(_E, Target) end
end

function HumanFormC()
        if RAble and AutoCarry.PluginMenu.useRs and SpiderForm and not QAble and not EAble and not WAble then CastSpell(_R) end
end    
 
local function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)
end
 
function CastE(unit, pos, spell)
        if GetDistance(pos) - getHitBoxRadius(unit)/2 < eRange then
                local willCollide = ProdictECol:GetMinionCollision(pos, myHero)
                if not willCollide then CastSpell(_E, pos.x, pos.z) end
        end
end

function CastW(unit, pos, spell)
        if GetDistance(pos) - getHitBoxRadius(unit)/2 < wRange then
				local willCollide = ProdictECol:GetMinionCollision(pos, myHero)
        if not willCollide then CastSpell(_W, pos.x, pos.z) end
        end
end

function CheckForms()
	if myHero:GetSpellData(_E).name == "EliseHumanE" then
		HumanForm = true
		SpiderForm = false
	end
	if myHero:GetSpellData(_E).name == "EliseSpiderEInitial" then
		HumanForm = false
		SpiderForm = true
	end
end

function PluginOnCreateObj(obj)
 if obj and GetDistance(obj, Target) <= 50 and obj.name == "LOC_Stun.troy" then
  Stunned = true
 end
end

function PluginOnDeleteObj(obj)
 if obj and GetDistance(obj, Target) <= 50 and obj.name == "LOC_Stun.troy" then
  Stunned = false
 end
end