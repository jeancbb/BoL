if myHero.charName:lower() ~= "xerath" then return end

--[[

		Script by: Totally Legit


			1.0
				Release
			1.01
				Fixed





--]]

function Say(text)
	print("<font color=\"#FF0000\"><b>Totally Xerath:</b></font> <font color=\"#FFFFFF\">" .. tostring(text) .. "</font>")
end

--[[		Auto Update		]]
local version = "1.01"
local author = "Totally Legit"
local SCRIPT_NAME = "Totally Xerath"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/Nickieboy/BoL/master/Totally Xerath.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/Nickieboy/BoL/master/version/Xerath.version")
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				Say("New version available "..ServerVersion)
				Say("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () Say("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				Say("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		Say("Error downloading version info")
	end
end



if not FileExist(LIB_PATH.."TotallyLib.lua") then return Say("Please download TotallyLib before running this script, thank you.") end


-- Download Libraries
local REQUIRED_LIBS = {
	["VPrediction"] = "https://raw.githubusercontent.com/Ralphlol/BoLGit/master/VPrediction.lua",
	["TotallyLib"] = "https://raw.githubusercontent.com/Nickieboy/BoL/master/lib/TotallyLib.lua"
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#6699FF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

local divinePredLoaded = false
local hPredLoaded = false

if VIP_USER and FileExist(LIB_PATH.."DivinePred.lua") then
	divinePredLoaded = true
	require "DivinePred"
end 

if FileExist(LIB_PATH.."HPrediction.lua") then
	hPredLoaded = true
	require "HPrediction"
end

-----------------------------------



function InitializeVariables()
	-- Spells
	Spells = {
				["AA"] = {range = 600, disabled = false},
				["Q"] = {name = "Arcanopulse", range = {min = 750, max = 1600}, speed = math.huge, radius = 100, Target = nil, ready = false, delay = 0.6, Charge = nil},
				["W"] = {name = "Eye of Destruction", range = 1150, radius = 200, delay = 0.65, speed = math.huge, ready = false},
				["E"] = {name = "Shocking Orb", range = 1000, speed = 1200, radius = 60, delay = 0, ready = false},
				["R"] = {name = "Rite of the Arcane", range = {3200, 4400, 5600}, speed = math.huge, radius = 180, delay = 0.5, ready = false, Target = {old = nil, new = nil}, isChanneled = false, x = 0, lastCast = os.clock()},
				["Helper"] = nil,
				["Target"] = nil
	}

	-- Minions
	EnemyMinions = minionManager(MINION_ENEMY, Spells.Q.range.max, myHero, MINION_SORT_HEALTH_ASC)

	-- Orbwalker settings
	SxOrbLoaded = false
	SACLoaded = false
	orbWalkLoaded = false

	-- movement
	movementDisabled = false

	-- Different target selector for Q and other spells
	ts = TargetSelector(TARGET_LOW_HP, 1200, DAMAGE_PHYSICAL, true)
	Qts = TargetSelector(TARGET_LOW_HP, Spells.Q.range.max, DAMAGE_PHYSICAL, true)
	Rts = TargetSelector(TARGET_LOW_HP, Spells.R.range[3], DAMAGE_PHYSICAL, true)

	-- Range
	oldRange = ((myHero:GetSpellData(_R).level >= 1 and Spells.R.range[myHero:GetSpellData(_R).level]) or Spells.R.range[1])

	-- DivinePrediction
 	if divinePredLoaded then
		DP = DivinePred()
	end

	if hPredLoaded then
		HPred = HPrediction()
	end

	--Vprediction
	VP = VPrediction()
end


function CheckOrbWalker() 
	if _G.Reborn_Initialised then
		SACLoaded = true 
		Menu.orbwalker:addParam("info", "Detected SAC", SCRIPT_PARAM_INFO, "")
		Say("SAC found.")
	elseif FileExist(LIB_PATH .. "SxOrbWalk.lua") then
		require("SxOrbWalk")
		SxOrbLoaded = true 
		_G.SxOrb:LoadToMenu(Menu.orbwalker)
		Say("SxOrbWalk found.")
	end

	if SACLoaded or SxOrbLoaded then
		orbWalkLoaded = true
	end

	if not orbWalkLoaded then 
		Say("You need either SAC or SxOrbWalk for this script. Please download one of them.") 
	else
		Say("Succesfully Loaded. Enjoy the script! Report bugs on the thread.")
	end
end

-- Load when game loads
function OnLoad()

	-- Load Variables
	InitializeVariables()

    -- Loading Menu 
    DrawMenu()

    Say("Please wait...")
    DelayAction(function() CheckOrbWalker() end, 10)

    if _G.PerformAutoUpdate then
		AutoUpdate()
	end

    -- Loading SpellHelper (From TotallyLib)
    Spells.Helper = SpellHelper(VP)

    Spells.Helper:AddSkillShot(_Q, Spells.Q.range.max, Spells.Q.delay, Spells.Q.radius, Spells.Q.speed, false, "line") 
    Spells.Helper:AddSkillShot(_W, Spells.W.range, Spells.W.delay, Spells.W.radius, Spells.W.speed, false, "circ")
    Spells.Helper:AddSkillShot(_E, Spells.E.range, Spells.E.delay, Spells.E.radius, Spells.E.speed, true, "line")
    Spells.Helper:AddSkillShot(_R, Spells.R.range[1], Spells.R.delay, Spells.R.radius, Spells.R.speed, false, "circ")
    Spells.Helper:SetCharged(_Q, "XerathArcanopulseChargeUp", Spells.Q.range.min, Spells.Q.range.max, 3, 1.5, "Xerath_Base_Q_cas_charge.troy")
    if divinePredLoaded then
    	Spells.Helper:AddDivinePrediction(DP, true)
    	--[[Spells.Helper:AddDP("Line", _Q)
    	Spells.Helper:AddDP("Circle", _W)
    	Spells.Helper:AddDP("Circle", _R)
    	Spells.Helper:AddDP("Line", _E)
    	--]]
    end

    if hPredLoaded then
    	Spells.Helper:AddHPred(HPred, true)
    end

    Spells.Helper:InitializePrediction(Menu)
   
end


function OnTick()
	Checks()
	if Menu.combo.useCombo then PerformCombo() end
	CastR()
	if Menu.harass.useHarassToggle or Menu.harass.useHarass then PerformHarass() end
	if Menu.laneclear.useLaneClear then PerformLaneClear() end
	--if Menu.killsteal.useKillSteal then PerformKillSteal() end
end

-- Checks same with FPS
function OnDraw()
	if myHero.dead then return end
	if Menu.drawings.draw then
		if Menu.drawings.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.Q.range.max, 0x111111)
		end

		if Menu.drawings.drawW then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.W.range, 0x111111)
		end

		if Menu.drawings.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.E.range, 0x111111)
		end

		if Menu.drawings.drawR and myHero:GetSpellData(_R).level >= 1 then
			DrawCircle(myHero.x, myHero.y, myHero.z, Spells.R.range[myHero:GetSpellData(_R).level], 0x111111)
		end
	end 
end


function CheckRRange()
	local level = ((myHero:GetSpellData(_R).level and myHero:GetSpellData(_R).level >= 1 and myHero:GetSpellData(_R).level) or 1)
	local range = Spells.R.range[level]
	if oldRange ~= range then
		Spells.Helper:ChangeRange(_R, range)
		oldRange = range 
	end
end

function PerformCombo()
	if Menu.combo.comboQ.comboQ and Spells.Q.Target and ValidTarget(Spells.Q.Target) and Spells.Q.ready then
		if Spells.Helper:IsCharging() then
			if Spells.Helper:GetChargedRange() <= Spells.Q.range.max and GetDistanceSqr(Spells.Q.Target) < math.pow(Spells.Helper:GetChargedRange() - 200, 2) then
				Spells.Helper:CastCharged(_Q, Spells.Q.Target)
			end
		else
			Spells.Helper:CastCharged(_Q)
		end
	end

	if not Spells.Helper:IsCharging() then
		if Spells.Target and ValidTarget(Spells.Target) then
			if Menu.combo.comboW.comboW then
				Spells.Helper:Cast(_W, Spells.Target)
			end
			if Menu.combo.comboE.comboE then
				Spells.Helper:Cast(_E, Spells.Target)
			end
		end
	end

end

function PerformHarass()
	if Spells.Q.Target and ValidTarget(Spells.Q.Target) and Spells.Q.ready then
		if Spells.Helper:IsCharging() then
			if Spells.Helper:GetChargedRange() <= Spells.Q.range.max and GetDistanceSqr(Spells.Q.Target) < math.pow(Spells.Helper:GetChargedRange() - 100, 2) then
				Spells.Helper:CastCharged(_Q, Spells.Q.Target)
			end
		elseif ManaManager("Harass") then
			Spells.Helper:CastCharged(_Q)
		end
	end
end

function PerformLaneClear()
	if Menu.laneclear.laneclearQ then
		if Spells.Q.ready then
			local position, hit = GetBestLineFarmPosition(Spells.Q.range.max, Spells.Q.radius, EnemyMinions.objects)
			if position and hit >= Menu.laneclear.laneclearQamount and GetDistanceSqr(position) <= Spells.Q.range.max * Spells.Q.range.max then
				if Spells.Helper:IsCharging() then
					if Spells.Helper:GetChargedRange() <= Spells.Q.range.max and GetDistanceSqr(position) < math.pow(Spells.Helper:GetChargedRange() - 100, 2) then
						Spells.Helper:CastCharged(_Q, position)
					end
				elseif ManaManager("LaneClear") then
					Spells.Helper:CastCharged(_Q)
				end
			end
		end
	end

	if Menu.laneclear.laneclearW then
		if Spells.W.ready then
			local position, hit = GetBestAOEPosition(EnemyMinions.objects, Spells.W.range, Spells.W.radius, myHero)
			if position and hit >= Menu.laneclear.laneclearWamount and GetDistanceSqr(position) <= Spells.W.range * Spells.W.range then
				Spells.Helper:Cast(_W, position.x, position.z)
			end
		end
	end

end

function CastR()
	if Menu.combo.comboR.comboR and Spells.R.isChanneled and myHero:GetSpellData(_R).level >= 1 and Spells.R.Target.new and ValidTarget(Spells.R.Target.new, Spells.R.range[myHero:GetSpellData(_R).level]) then
		if Spells.R.Target.old == nil then Spells.R.Target.old = Spells.R.Target.new end

		if Spells.R.x == 1 then
			local delay = (Menu.combo.comboR.useDelay and Menu.combo.comboR.delay1/1000) or 0
			if Spells.R.lastCast + delay <= os.clock() then
				Spells.Helper:Cast(_R, Spells.R.Target.new)
			end

		elseif Spells.R.x == 2 then
			local delay = (Menu.combo.comboR.useDelay and Menu.combo.comboR.delay2/1000) or 0
			if Spells.R.Target.old ~= Spells.R.Target.new then
				delay = delay * Menu.combo.comboR.delayTarget
				Spells.R.Target.old = Spells.R.Target.new
			end
			if Spells.R.lastCast + delay <= os.clock() then
				Spells.Helper:Cast(_R, Spells.R.Target.new)
			end

		elseif Spells.R.x == 3 then
			local delay = (Menu.combo.comboR.useDelay and Menu.combo.comboR.delay3/1000) or 0
			if Spells.R.Target.old ~= Spells.R.Target.new then
				delay = delay * Menu.combo.comboR.delayTarget
				Spells.R.Target.old = Spells.R.Target.new
			end
			if Spells.R.lastCast + delay <= os.clock() then
				Spells.Helper:Cast(_R, Spells.R.Target.new)
			end
		end
	end

end

function OnProcessSpell(unit, spell)
	if unit and unit.isMe and spell and spell.name and spell.name == "xerathlocuspulse" then
		Spells.R.lastCast = os.clock()
		Spells.R.x = Spells.R.x + 1
	end
	if unit and unit.isMe and spell and spell.name and spell.name:lower():find("xerathlocusofpower2") then
		Spells.R.isChanneled = true
		Spells.R.x = 1
		Spells.R.lastCast = os.clock()
	end

	if unit and unit.isMe and spell and spell.name:lower():find("xeratharcanopulse2") and Spells.Helper:IsCharging() then
		Spells.Helper:ForceCharge(false)
	end
end

function OnApplyBuff(source, unit, buff)
	if source and source.isMe and buff and (buff.name == "XerathLocusOfPower2" or buff.name == "xerathrshots") then
		Spells.R.isChanneled = true
	end
end

function OnRemoveBuff(unit, buff)
	if unit and unit.isMe and buff and (buff.name == "XerathLocusOfPower2" or buff.name == "xerathrshots") then
		Spells.R.isChanneled = false
		Spells.R.x = 0
		Menu.combo.comboR.comboR = false 
	end
	if source and source.isMe and buff and buff.name == "XerathArcanopulseChargeUp"  then
		Spells.Helper:ForceCharge(false)
	end
	if unit and unit.isMe and buff and buff.name == "xerathqlaunchsound" then
		Spells.Helper:ForceCharge(false)
	end
end

function ManaManager(string)
	local mana = myHero.mana
	local maxMana = myHero.maxMana
	if string == "Harass" then
	 	if (mana / myHero.maxMana <= Menu.manamanagers.manaManagerHarass) then
			return false
		end
		return true
	elseif string == "LaneClear" then
		if (mana / myHero.maxMana <= Menu.manamanagers.manaManagerLaneClear) then
			return false
		end
		return true
	else	
		return true
 	end
 end

 function UltActive()
 	return Spells.R.lastCast + 10 > os.clock() and myHero:GetSpellData(_R).currentCd < 10
 end


-- Draw Menu
function DrawMenu()
	Menu = scriptConfig("Totally Xerath - Totally Legit", "TotallyLegit")

	local tempName = "Totally Xerath - "
	 -- Combo
	Menu:addSubMenu(tempName .. "Combo", "combo")

	Menu.combo:addParam("useCombo", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
 	
 		-- Use Q in combo
 	Menu.combo:addSubMenu(Spells.Q.name .. " (Q)", "comboQ")
 	Menu.combo.comboQ:addParam("comboQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)

 		-- Use E in combo
 	Menu.combo:addSubMenu(Spells.W.name .. " (W)", "comboW")
 	Menu.combo.comboW:addParam("comboW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	

 		-- Use E in combo
 	Menu.combo:addSubMenu(Spells.E.name .. " (E)", "comboE")
 	Menu.combo.comboE:addParam("comboE", "Use " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	
 		-- Use R in combo
 	Menu.combo:addSubMenu(Spells.R.name .. " (R)", "comboR")
 	Menu.combo.comboR:addParam("comboR", "Use " .. Spells.R.name .. " (M)", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("K"))
 	Menu.combo.comboR:addParam("useDelay", "Use Delay on R", SCRIPT_PARAM_ONOFF, true)
 	Menu.combo.comboR:addParam("delay1", "Delay on First R", SCRIPT_PARAM_SLICE, 150, 0, 1000, 0)
 	Menu.combo.comboR:addParam("delay2", "Delay on Second R", SCRIPT_PARAM_SLICE, 200, 0, 1000, 0)
 	Menu.combo.comboR:addParam("delay3", "Delay on Third R", SCRIPT_PARAM_SLICE, 75, 0, 1000, 0)
 	Menu.combo.comboR:addParam("delayTarget", "Multitude new target", SCRIPT_PARAM_SLICE, 1, 1, 5, 2)

 	 -- Harass
	Menu:addSubMenu(tempName .. "Harass", "harass")
 	Menu.harass:addParam("useHarass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
 	Menu.harass:addParam("useHarassToggle", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Y"))
 	Menu.harass:addParam("harassQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)

 	-- LaneClear
 	Menu:addSubMenu(tempName .. "LaneClear", "laneclear")
 	Menu.laneclear:addParam("useLaneClear", "Laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("U"))
 	Menu.laneclear:addParam("laneclearQ", "Use " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear:addParam("laneclearQamount", "Min minions to hit", SCRIPT_PARAM_SLICE, 5, 0, 20, 0)
 	Menu.laneclear:addParam("laneclearW", "Use " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.laneclear:addParam("laneclearWamount", "Min minions to hit", SCRIPT_PARAM_SLICE, 5, 0, 20, 0)

 	--Manamangers
 	Menu:addSubMenu(tempName .. "ManaMangers", "manamanagers")
 	Menu.manamanagers:addParam("manaManagerHarass", "Min Mana % to Harass", SCRIPT_PARAM_SLICE, 0.7, 0, 1, 2)
 	Menu.manamanagers:addParam("manaManagerLaneClear", "Min Mana % to LaneClear", SCRIPT_PARAM_SLICE, 0.7, 0, 1, 2)

 	--Drawings
 	Menu:addSubMenu(tempName .. "Drawings", "drawings")
 	Menu.drawings:addParam("draw", "Use Drawings", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawQ", "Draw " .. Spells.Q.name .. " (Q)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawW", "Draw " .. Spells.W.name .. " (W)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawE", "Draw " .. Spells.E.name .. " (E)", SCRIPT_PARAM_ONOFF, true)
 	Menu.drawings:addParam("drawR", "Draw " .. Spells.R.name .. " (R)", SCRIPT_PARAM_ONOFF, true)

 	--Misc
 	Menu:addSubMenu(tempName .. "Misc", "misc")
 	Menu.misc:addSubMenu("Gapcloser", "gc")
	AntiGapcloser(Menu.misc.gc, AntiGapCloseFunc)
	Menu.misc:addSubMenu("Interrupter", "ai")
	Interrupter(Menu.misc.ai, InterruptFunc)

 	MenuMisc(Menu.misc, true)

 	-- OrbWalker
	Menu:addSubMenu(tempName .. "OrbWalker", "orbwalker")

	-- Add TS
	Menu:addTS(ts)

	-- debug
	Menu:addSubMenu(tempName .. "Debug", "debug")
  	Menu.debug:addParam("debug", "Use Debug", SCRIPT_PARAM_ONOFF, false)

	-- Permashow
	Menu.combo:permaShow("useCombo")
  	Menu.harass:permaShow("useHarass")
  	Menu.harass:permaShow("useHarassToggle")
  	Menu.laneclear:permaShow("useLaneClear")
  	Menu.drawings:permaShow("draw")

end

function AntiGapCloseFunc(unit, spell)
	if unit and unit.team ~= myHero.team and ValidTarget(unit) then
		Spells.Helper:Cast(_E, unit)
	end
end

function InterruptFunc(unit, spell) 
	if unit and unit.team ~= myHero.team and ValidTarget(unit) then
		Spells.Helper:Cast(_E, unit)
	end 	
end 

function Checks()
	Spells.Q.ready = (myHero:CanUseSpell(_Q) == READY)
	Spells.W.ready = (myHero:CanUseSpell(_W) == READY)
	Spells.E.ready = (myHero:CanUseSpell(_E) == READY)
	Spells.R.ready = (myHero:CanUseSpell(_R) == READY)

	-- Targetselector
	Qts:update()
	Rts:update()
	ts:update()
	EnemyMinions:update()

	-- Assigning target
	Spells.Target = ts.target
	Spells.Q.Target = Qts.target
	Spells.R.Target.new = Rts.target

	TargetChecks()
	
	CheckRRange()
end 

function TargetChecks()
	if Spells.Target and Spells.Q.Target and Spells.Q.Target ~= Spells.Target then
		if ValidTarget(Spells.Target, 1600) then
			Spells.Q.Target = Spells.Target
		end 
	end 

	if Spells.R.Target.new and Spells.Target and Spells.R.Target.new ~= Spells.Target then
		if ValidTarget(Spells.Target, Spells.R.range[myHero:GetSpellData(_R).level]) then
			Spells.R.Target.new = Spells.Target
		end
	end

	if Spells.R.Target.new and myHero:GetSpellData(_R).level >= 1 and GetDistance(Spells.R.Target.new) >= Spells.R.range[myHero:GetSpellData(_R).level] then
		Spells.R.Target.new = nil 
	end

	if Spells.R.Target.old and not Spells.R.isChanneled then
		Spells.R.Target.old = nil 
	end

	if Spells.Q.Target and GetDistanceSqr(Spells.Q.Target) >= Spells.Q.range.max * Spells.Q.range.max then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if enemy and GetDistanceSqr(enemy) <= Spells.Q.range.max * Spells.Q.range.max and ValidTarget(enemy) then
				Spells.Q.Target = enemy 
				break
			end
		end
	end

	if Spells.R.Target.new and myHero:GetSpellData(_R).level >= 1 and GetDistanceSqr(Spells.R.Target.new) >= Spells.R.range[myHero:GetSpellData(_R).level]  * Spells.R.range[myHero:GetSpellData(_R).level] then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if enemy and GetDistanceSqr(Spells.R.Target.new) <= Spells.R.range[myHero:GetSpellData(_R).level] * Spells.R.range[myHero:GetSpellData(_R).level] and ValidTarget(enemy) then
				Spells.R.Target.new = enemy 
				break
			end
		end
	end
end




















class "SxScriptUpdate"
function SxScriptUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript'..(UseHttps and '5' or '6')..'.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.CallbackError = CallbackError
    AddDrawCallback(function() self:OnDraw() end)
    self:CreateSocket(self.VersionPath)
    self.DownloadStatus = 'Connect to Server for VersionInfo'
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function SxScriptUpdate:print(str)
    print('<font color="#FFFFFF">'..os.clock()..': '..str)
end

function SxScriptUpdate:OnDraw()
    if self.DownloadStatus ~= 'Downloading Script (100%)' and self.DownloadStatus ~= 'Downloading VersionInfo (100%)'then
        DrawText('Download Status: '..(self.DownloadStatus or 'Unknown'),50,10,50,ARGB(0xFF,0xFF,0xFF,0xFF))
    end
end

function SxScriptUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function SxScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function SxScriptUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.0\r\nHost: sx-bol.eu\r\nUser-Agent: hDownload\r\n\r\n")
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') or self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if not self.OnlineVersion then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                if self.OnlineVersion > self.LocalVersion then
                    if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                        self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                    end
                    self:CreateSocket(self.ScriptPath)
                    self.DownloadStatus = 'Connect to Server for ScriptDownload'
                    AddTickCallback(function() self:DownloadUpdate() end)
                else
                    if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                        self.CallbackNoUpdate(self.LocalVersion)
                    end
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function SxScriptUpdate:DownloadUpdate()
    if self.GotSxScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') or self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('<sc'..'ript>')
        local ContentEnd, _ = self.File:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.File:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                self.GotSxScriptUpdate = true
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotSxScriptUpdate = true
    end
end







--[[

'||'            .                                               .                   
 ||  .. ...   .||.    ....  ... ..  ... ..  ... ...  ... ...  .||.    ....  ... ..  
 ||   ||  ||   ||   .|...||  ||' ''  ||' ''  ||  ||   ||'  ||  ||   .|...||  ||' '' 
 ||   ||  ||   ||   ||       ||      ||      ||  ||   ||    |  ||   ||       ||     
.||. .||. ||.  '|.'  '|...' .||.    .||.     '|..'|.  ||...'   '|.'  '|...' .||.    
                                                      ||                            
                                                     ''''                           

    Interrupter - They will never cast!

    Like alwasy undocumented by honda...
]]
class 'Interrupter'

local _INTERRUPTIBLE_SPELLS = {
    ["KatarinaR"]                          = { charName = "Katarina",     DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["Meditate"]                           = { charName = "MasterYi",     DangerLevel = 1, MaxDuration = 2.5, CanMove = false },
    ["Drain"]                              = { charName = "FiddleSticks", DangerLevel = 3, MaxDuration = 2.5, CanMove = false },
    ["Crowstorm"]                          = { charName = "FiddleSticks", DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["GalioIdolOfDurand"]                  = { charName = "Galio",        DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["MissFortuneBulletTime"]              = { charName = "MissFortune",  DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["VelkozR"]                            = { charName = "Velkoz",       DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["InfiniteDuress"]                     = { charName = "Warwick",      DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["AbsoluteZero"]                       = { charName = "Nunu",         DangerLevel = 4, MaxDuration = 2.5, CanMove = false },
    ["ShenStandUnited"]                    = { charName = "Shen",         DangerLevel = 3, MaxDuration = 2.5, CanMove = false },
    ["FallenOne"]                          = { charName = "Karthus",      DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["AlZaharNetherGrasp"]                 = { charName = "Malzahar",     DangerLevel = 5, MaxDuration = 2.5, CanMove = false },
    ["Pantheon_GrandSkyfall_Jump"]         = { charName = "Pantheon",     DangerLevel = 5, MaxDuration = 2.5, CanMove = false },

}

function Interrupter:__init(menu, cb)

    self.callbacks = {}
    self.activespells = {}
    AddTickCallback(function() self:OnTick() end)
    AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end)
    if menu then
        self:AddToMenu(menu)
    end
    if cb then
        self:AddCallback(cb)
    end

end

function Interrupter:AddToMenu(menu)

    assert(menu, "Interrupter: menu can't be nil!")
    local SpellAdded = false
    local EnemyChampioncharNames = {}
    for i, enemy in ipairs(GetEnemyHeroes()) do
        table.insert(EnemyChampioncharNames, enemy.charName)
    end
    menu:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
    for spellName, data in pairs(_INTERRUPTIBLE_SPELLS) do
        if table.contains(EnemyChampioncharNames, data.charName) then
            menu:addParam(string.gsub(spellName, "_", ""), data.charName.." - "..spellName, SCRIPT_PARAM_ONOFF, true)
            SpellAdded = true
        end
    end
    if not SpellAdded then
        menu:addParam("Info", "Info", SCRIPT_PARAM_INFO, "No spell available to interrupt")
    end
    self.Menu = menu

end

function Interrupter:AddCallback(cb)

    assert(cb and type(cb) == "function", "Interrupter: callback is invalid!")
    table.insert(self.callbacks, cb)

end

function Interrupter:TriggerCallbacks(unit, spell)

    for i, callback in ipairs(self.callbacks) do
        callback(unit, spell)
    end

end

function Interrupter:OnProcessSpell(unit, spell)

    if not self.Menu.Enabled then return end
    if unit.team ~= myHero.team then
        if _INTERRUPTIBLE_SPELLS[spell.name] then
            local SpellToInterrupt = _INTERRUPTIBLE_SPELLS[spell.name]
            if (self.Menu and self.Menu[string.gsub(spell.name, "_", "")]) or not self.Menu then
                local data = {unit = unit, DangerLevel = SpellToInterrupt.DangerLevel, endT = os.clock() + SpellToInterrupt.MaxDuration, CanMove = SpellToInterrupt.CanMove}
                table.insert(self.activespells, data)
                self:TriggerCallbacks(data.unit, data)
            end
        end
    end

end

function Interrupter:OnTick()

    for i = #self.activespells, 1, -1 do
        if self.activespells[i].endT - os.clock() > 0 then
            self:TriggerCallbacks(self.activespells[i].unit, self.activespells[i])
        else
            table.remove(self.activespells, i)
        end
    end

end


--[[

    |                .    ||   ..|'''.|                           '||                                 
   |||    .. ...   .||.  ...  .|'     '   ....   ... ...    ....   ||    ...    ....    ....  ... ..  
  |  ||    ||  ||   ||    ||  ||    .... '' .||   ||'  || .|   ''  ||  .|  '|. ||. '  .|...||  ||' '' 
 .''''|.   ||  ||   ||    ||  '|.    ||  .|' ||   ||    | ||       ||  ||   || . '|.. ||       ||     
.|.  .||. .||. ||.  '|.' .||.  ''|...'|  '|..'|'  ||...'   '|...' .||.  '|..|' |'..|'  '|...' .||.    
                                                  ||                                                  
                                                 ''''                                                 

    AntiGapcloser - Stay away please, thanks.

    And again undocumented by honda -.-
]]
class 'AntiGapcloser'

local _GAPCLOSER_TARGETED, _GAPCLOSER_SKILLSHOT = 1, 2
--Add only very fast skillshots/targeted spells since vPrediction will handle the slow dashes that will trigger OnDash
local _GAPCLOSER_SPELLS = {
    ["AatroxQ"]              = "Aatrox",
    ["AkaliShadowDance"]     = "Akali",
    ["Headbutt"]             = "Alistar",
    ["FioraQ"]               = "Fiora",
    ["DianaTeleport"]        = "Diana",
    ["EliseSpiderQCast"]     = "Elise",
    ["FizzPiercingStrike"]   = "Fizz",
    ["GragasE"]              = "Gragas",
    ["HecarimUlt"]           = "Hecarim",
    ["JarvanIVDragonStrike"] = "JarvanIV",
    ["IreliaGatotsu"]        = "Irelia",
    ["JaxLeapStrike"]        = "Jax",
    ["KhazixE"]              = "Khazix",
    ["khazixelong"]          = "Khazix",
    ["LeblancSlide"]         = "LeBlanc",
    ["LeblancSlideM"]        = "LeBlanc",
    ["BlindMonkQTwo"]        = "LeeSin",
    ["LeonaZenithBlade"]     = "Leona",
    ["UFSlash"]              = "Malphite",
    ["Pantheon_LeapBash"]    = "Pantheon",
    ["PoppyHeroicCharge"]    = "Poppy",
    ["RenektonSliceAndDice"] = "Renekton",
    ["RivenTriCleave"]       = "Riven",
    ["SejuaniArcticAssault"] = "Sejuani",
    ["slashCast"]            = "Tryndamere",
    ["ViQ"]                  = "Vi",
    ["MonkeyKingNimbus"]     = "MonkeyKing",
    ["XenZhaoSweep"]         = "XinZhao",
    ["YasuoDashWrapper"]     = "Yasuo"
}

function AntiGapcloser:__init(menu, cb)

    self.callbacks = {}
    self.activespells = {}
    AddTickCallback(function() self:OnTick() end)
    AddProcessSpellCallback(function(unit, spell) self:OnProcessSpell(unit, spell) end)
    if menu then
        self:AddToMenu(menu)
    end
    if cb then
        self:AddCallback(cb)
    end

end

function AntiGapcloser:AddToMenu(menu)

    assert(menu, "AntiGapcloser: menu can't be nil!")
    local SpellAdded = false
    local EnemyChampioncharNames = {}
    for i, enemy in ipairs(GetEnemyHeroes()) do
        table.insert(EnemyChampioncharNames, enemy.charName)
    end
    menu:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
    for spellName, charName in pairs(_GAPCLOSER_SPELLS) do
        if table.contains(EnemyChampioncharNames, charName) then
            menu:addParam(string.gsub(spellName, "_", ""), charName.." - "..spellName, SCRIPT_PARAM_ONOFF, true)
            SpellAdded = true
        end
    end
    if not SpellAdded then
        menu:addParam("Info", "Info", SCRIPT_PARAM_INFO, "No spell available to interrupt")
    end
    self.Menu = menu

end

function AntiGapcloser:AddCallback(cb)

    assert(cb and type(cb) == "function", "AntiGapcloser: callback is invalid!")
    table.insert(self.callbacks, cb)

end

function AntiGapcloser:TriggerCallbacks(unit, spell)

    for i, callback in ipairs(self.callbacks) do
        callback(unit, spell)
    end

end

function AntiGapcloser:OnProcessSpell(unit, spell)

    if not self.Menu.Enabled then return end
    if unit.team ~= myHero.team then
        if _GAPCLOSER_SPELLS[spell.name] then
            local Gapcloser = _GAPCLOSER_SPELLS[spell.name]
            if (self.Menu and self.Menu[string.gsub(spell.name, "_", "")]) or not self.Menu then
                local add = false
                if spell.target and spell.target.isMe then
                    add = true
                    startPos = Vector(unit)
                    endPos = myHero
                elseif not spell.target then
                    local endPos1 = Vector(unit) + 300 * (Vector(spell.endPos) - Vector(unit)):normalized()
                    local endPos2 = Vector(unit) + 100 * (Vector(spell.endPos) - Vector(unit)):normalized()
                    --TODO check angles etc
                    if (GetDistanceSqr(myHero, unit) > GetDistanceSqr(myHero, endPos1) or GetDistanceSqr(myHero, unit) > GetDistanceSqr(myHero, endPos2))  then
                        add = true
                    end
                end

                if add then
                    local data = {unit = unit, spell = spell.name, startT = os.clock(), endT = os.clock() + 1, startPos = startPos, endPos = endPos}
                    table.insert(self.activespells, data)
                    self:TriggerCallbacks(data.unit, data)
                end
            end
        end
    end

end

function AntiGapcloser:OnTick()

    for i = #self.activespells, 1, -1 do
        if self.activespells[i].endT - os.clock() > 0 then
            self:TriggerCallbacks(self.activespells[i].unit, self.activespells[i])
        else
            table.remove(self.activespells, i)
        end
    end

end

assert(load(Base64Decode("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"), nil, "bt", _ENV))() ScriptStatus("QDGFDHGKCLH") 
