------#################################################################################------  ------###########################   Ziggs in Wonderland!   ############################------ ------###########################         by Toy           ############################------ ------#################################################################################------

--> Version: BETA

--> Features:
--> Prodictions on every skills, they are also casted with packets.
--> Interrupt Channeled Spells with Satchel Charge!
--> Customizable combo and harrass options, that are also set on customizable hotkeys.
--> Hotkey to Jump to mouse position with Satchel Charge: use packets (Almost instant explosion for fast escapes).
--> Hotkey to use Mega Inferno Bomb with Prodictions.
--> KS with Mega Inferno Bomb.
--> KS with everything, calculates how much the full combo will deal, defines if the target is killable, and execute the KS, also KS with anything avaiable if the target is killable by it.
--> Drawing options to know how much damage each spell will deal, and how much the full combo will deal to your enemies.
--> Drawing options for every skill (Also for Q bounce range and Q normal range), also a option to draw the furthest spell avaiable.

if myHero.charName ~= "Ziggs" then return end

require "Prodiction"
require "Collision"
require "DrawDamageLib"
 
local qRange = 900
local bRange = 1400
local wRange = 1000
local eRange = 900
local rRange = 5300
local xRange = 1400

local qDmg, wDmg, eDmg, rDmg = nil, nil, nil, nil
 
local QAble, WAble, EAble, RAble = false, false, false, false
 
local Prodict = ProdictManager.GetInstance()
local ProdictB
local ProdictQ, ProdictQCol
local ProdictW
local ProdictE
local ProdictR

local explodingJump = 50

local ProdictQCol = Collision(bRange, 1500, 0.22, 180)

local enemyHeroes
local ToInterrupt = {}
local InterruptList = {
    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},
    { charName = "FiddleSticks", spellName = "Crowstorm"},
    { charName = "FiddleSticks", spellName = "DrainChannel"},
    { charName = "Galio", spellName = "GalioIdolOfDurand"},
    { charName = "Karthus", spellName = "FallenOne"},
    { charName = "Katarina", spellName = "KatarinaR"},
    { charName = "Lucian", spellName = "LucianR"}
    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},
    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", spellName = "AbsoluteZero"},
    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},
    { charName = "Shen", spellName = "ShenStandUnited"},
    { charName = "Urgot", spellName = "UrgotSwap2"},
    { charName = "Varus", spellName = "VarusQ"},
    { charName = "Warwick", spellName = "InfiniteDuress"}
}
 
function OnLoad()
        Menu()
        ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1400, DAMAGE_MAGIC, true)
        ts.name = "Ziggs"
        Config:addTS(ts)
        
        PrintChat("<font color='#C4296F'>>> Ziggs: Let's blow this place to ashes!</font>")
        
        enemyHeroes = GetEnemyHeroes()
        
        ProdictB = Prodict:AddProdictionObject(_Q, qRange, 1500, 0.22, 180)
        ProdictQ = Prodict:AddProdictionObject(_Q, qRange, 1734, 0.22, 180)
        ProdictW = Prodict:AddProdictionObject(_W, wRange, 1810, 0.25, 325)     
        ProdictE = Prodict:AddProdictionObject(_E, eRange, 2134, 0.30, 350)
        ProdictR = Prodict:AddProdictionObject(_R, rRange, 1956, 1, 550) 
        
        for _, enemy in pairs(enemyHeroes) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				table.insert(ToInterrupt, champ.spellName)
			end
		end
	end
end

function KS()
    for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if RReady and ValidTarget(Enemy, rRange, true) and Enemy.health < getDmg("R",Enemy,myHero) + 30 then
            MegaInfernoBomb()
        end
    end
end

function FullKS()
    for i = 1, heroManager.iCount do
        local Enemy = heroManager:getHero(i)
        if QAble then qDmg = getDmg("Q",Enemy,myHero) else qDmg = 0 end
        if WAble then wDmg = getDmg("W",Enemy,myHero) else wDmg = 0 end
        if EAble then eDmg = getDmg("E",Enemy,myHero) else eDmg = 0 end
        if RAble then rDmg = getDmg("R",Enemy,myHero) else rDmg = 0 end
        if ValidTarget(Enemy, qRange, true) and Enemy.health < qDmg + rDmg + eDmg + wDmg then
            CastFKS(Enemy)
        end
    end
end
 
function OnTick()
    Checks()
    ts:update()
    if Target then
      if Config.Combo then
        BouncingBomb()
        Bomb()
        Charge()
        Minefield()
      end
      if Config.Harrass then
        BouncingBomb2()
        Bomb2()
        Charge2()
        Minefield2()
      end
    end
    if Config.drawDmg then damageDrawing() end
    if Config.Jump and WAble then ActivateJump() end
    if Config.KS and RAble then KS() end
    if Config.FullKS and (QAble or WAble or EAble or RAble) then FullKS() end
    if Config.useR then
       MegaInfernoBomb()
    end
end
 
function OnDraw()
    if not myHero.dead then
      if Config.drawDmg then drawDamage() end
      if QAble and Config.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, bRange, 0x6600CC)
      elseif WAble and Config.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x6600CC)
      elseif EAble and Config.drawF then
      DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x6600CC)
      end
      if QAble and Config.drawB then
      DrawCircle(myHero.x, myHero.y, myHero.z, bRange, 0x6600CC)
      end
      if QAble and Config.drawQ then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFFFF)
      end
      if WAble and Config.drawW then
      DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x9933FF)
      end
      if EAble and Config.drawE then
      DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFF0000)
      end
      if RAble and Config.drawR then
      DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x9933FF)
      end
   end
end

 function Menu()
  local HKR = string.byte("T")
  local HKJ = string.byte("G")
  local HKA = string.byte("A")
  local HKC = string.byte("C")
  Config = scriptConfig("Ziggs in Wonderland! BETA", "ziggs")
  Config:addParam("sep", "-- Hotkey Options --", SCRIPT_PARAM_INFO, "")
  Config:addParam("Combo", "Use - Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
  Config:addParam("Harrass", "Use - Harrass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
  Config:addParam("sep", "-- Other Options --", SCRIPT_PARAM_INFO, "")
  Config:addParam("Jump", "Jump - Satchel Charge", SCRIPT_PARAM_ONKEYDOWN, false, HKJ)
  Config:addParam("useR", "Use - Mega Inferno Bomb", SCRIPT_PARAM_ONKEYDOWN, false, HKR)
  Config:addParam("interrupt", "Interrupt Spells", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("KS", "KS - Mega Inferno Bomb", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("FullKS", "KS - Everything", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("sep", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
  Config:addParam("useB", "Use - Bouncing Bomb", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("useQ", "Use - Bomb", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("useW", "Use - Satchel Charge", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("useE", "Use - Hexplosive Minefield", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("sep", "-- Harrass Options --", SCRIPT_PARAM_INFO, "")
  Config:addParam("useB2", "Use - Bouncing Bomb", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("useQ2", "Use - Bomb", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("useW2", "Use - Satchel Charge", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("useE2", "Use - Hexplosive Minefield", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("sep", "-- Drawing Options --", SCRIPT_PARAM_INFO, "")
  Config:addParam("drawDmg", "Draw - Damage Marks", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("drawF", "Draw - Furthest Spell Available", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("drawB", "Draw - Bouncing Bomb", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("drawQ", "Draw - Bomb", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("drawW", "Draw - Satchel Charge", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("drawE", "Draw - Hexplosive Minefield", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("drawR", "Draw - Mega Inferno Bomb", SCRIPT_PARAM_ONOFF, false)
end
 
function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = ts.target
end
 
function BouncingBomb()
        if QAble and Config.useB then ProdictB:GetPredictionCallBack(ts.target, CastB) end
end  

function Bomb()
        if QAble and Config.useQ then ProdictQ:GetPredictionCallBack(ts.target, CastQ) end
end  
 
function Charge()
        if WAble and Config.useW then ProdictW:GetPredictionCallBack(ts.target, CastW) end
end  

function Minefield()
        if EAble and Config.useE then ProdictE:GetPredictionCallBack(ts.target, CastE) end
end

function BouncingBomb2()
        if QAble and Config.useB2 then ProdictB:GetPredictionCallBack(ts.target, CastB) end
end  

function Bomb2()
        if QAble and Config.useQ2 then ProdictQ:GetPredictionCallBack(ts.target, CastQ) end
end 

function Charge2()
        if WAble and Config.useW2 then ProdictW:GetPredictionCallBack(ts.target, CastW) end
end

function Minefield2()
        if EAble and Config.useE2 then ProdictE:GetPredictionCallBack(ts.target, CastE) end
end

function MegaInfernoBomb()
        if Target and RAble then ProdictR:GetPredictionCallBack(ts.target, CastR) end
end    

function CastB(unit, pos, spell)
        if GetDistance(pos) < bRange and GetDistance(pos) > qRange then
          local willCollide = ProdictQCol:GetMinionCollision(pos, myHero)
          if not willCollide then Packet('S_CAST', { spellId = _Q, fromX = pos.x, fromY = pos.z}):send() end
        end
end
 
function CastQ(unit, pos, spell)
        if GetDistance(pos) < qRange then
          Packet('S_CAST', { spellId = _Q, fromX = pos.x, fromY = pos.z}):send()
        end
end

function CastW(unit, pos, spell)
        if GetDistance(pos) < wRange then
          Packet('S_CAST', { spellId = _W, fromX = pos.x+50, fromY = pos.z+50}):send()
        end
end

function CastE(unit, pos, spell)
        if GetDistance(pos) < eRange then
          Packet('S_CAST', { spellId = _E, fromX = pos.x, fromY = pos.z}):send()
        end
end

function CastR(unit, pos, spell)
        if GetDistance(pos) < rRange then
          Packet('S_CAST', { spellId = _R, fromX = pos.x, fromY = pos.z}):send()
        end
end

function CastRKS(Unit)
    if GetDistance(Unit) < rRange and ValidTarget(Unit) then
        RPos = ProdictR:GetPrediction(Unit)
        Packet('S_CAST', { spellId = _R, fromX = RPos.x, fromY = RPos.z}):send()
    end
end

function CastFKS(Unit)
    if QAble and GetDistance(Unit) < qRange and ValidTarget(Unit) then
        QPos = ProdictR:GetPrediction(Unit)
        Packet('S_CAST', { spellId = _Q, fromX = QPos.x, fromY = QPos.z}):send()
    end
    if WAble and GetDistance(Unit) < wRange and ValidTarget(Unit) then
        WPos = ProdictR:GetPrediction(Unit)
        Packet('S_CAST', { spellId = _W, fromX = WPos.x+50, fromY = WPos.z+50}):send()
    end
    if EAble and GetDistance(Unit) < eRange and ValidTarget(Unit) then
        EPos = ProdictR:GetPrediction(Unit)
        Packet('S_CAST', { spellId = _E, fromX = EPos.x+50, fromY = EPos.z+50}):send()
    end
    if RAble and GetDistance(Unit) < rRange and ValidTarget(Unit) then
        RPos = ProdictR:GetPrediction(Unit)
        Packet('S_CAST', { spellId = _R, fromX = RPos.x, fromY = RPos.z}):send()
    end
end

function ActivateJump()
    local x,y,z = (Vector(myHero) - Vector(mousePos)):normalized():unpack()
    
    if canJump then
      Packet('S_CAST', { spellId = _W }):send()
    else
      Packet('S_CAST', { spellId = _W, fromX = myHero.x + (x * explodingJump), fromY = myHero.z + (z * explodingJump)}):send()
  end
end

function OnCreateObj(obj)
  if obj.name == "ZiggsW_mis_ground.troy" then
    JumpAble = true
    ActivateJump()
  end
end

function OnDeleteObj(obj)
  if obj.name == "ZiggsW_mis_ground.troy" then
   JumpAble = false
  end
end

function OnProcessSpell(unit, spell)
	if #ToInterrupt > 0 and Config.interrupt and WAble then
		for _, ability in pairs(ToInterrupt) do
			if spell.name == ability and unit.team ~= myHero.team then
				if wRange >= GetDistance(unit) then
					ProdictW:GetPredictionCallBack(ts.target, CastW)
				end
			end
		end
	end
end

function damageDrawing()
	setOrder(_Q, 4)
	setOrder(_W, 3)
	setOrder(_E, 2)
	setOrder(_R, 1)
	setFlipped(above)
end