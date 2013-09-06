local math = math

local _, ns = ...
local Crabby = { }
ns.Crabby = Crabby

local DefaultSettings = {
	x = 0,
	y = 0,
}

function Crabby:CopySettings(src, dst)
	if type(src) ~= "table" then
		return { }
	end
	if type(dst) then
		dst = { }
	end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = Crabby:CopySettings(v, dst[k])
		elseif type(v) ~= type(dst[k]) then
			dst[k] = v
		end
	end
	return dst
end

CrabbyVars = Crabby:CopySettings(DefaultSettings,CrabbyVars)

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("ADDON_LOADED")
frame:SetFrameStrata("High")
frame:SetPoint("Center", CrabbyVars.x, CrabbyVars.y)
frame:SetWidth(600)
frame:SetHeight(600)
frame:SetAlpha(0.99)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(false)
frame:RegisterForDrag("LeftButton")

local model = CreateFrame("PlayerModel", nil, frame)
model:SetModel("Creature\\Deepseacrab\\deepseacrab_ghost.m2")
model:SetPosition(0, 0, -0.0001)
model:SetRotation(math.rad(0))
model:SetAlpha(0.99)
model:SetAllPoints(frame)
model:Show()

local texture = frame:CreateTexture("Texture", "High")
texture:SetTexture("Interface\\AddOns\\Crabby\\Textures\\Eyes")
texture:SetPoint("Top", frame, "Top", 0, -260)
texture:SetWidth(128)
texture:SetHeight(128)
texture:SetAlpha(0.99)
texture:SetBlendMode("Disable")
texture:SetDrawLayer("Background", 0)

local animframe = CreateFrame("Frame", nil, UIParent)

-- You can animate the model by changing this from 0-802
local modelanimation = -1
local animation = false

frame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		self:StartMoving()
	end
end)

frame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		self:StopMovingOrSizing()
		local L1, B1, W1, H1 = UIParent:GetRect()
		local L2, B2, W2, H2 = self:GetRect()
		CrabbyVars.x = L2 - L1 + (W2 - W1) / 2
		CrabbyVars.y = B2 - B1 + (H2 - H1) / 2
		self:ClearAllPoints()
		self:SetPoint("CENTER", L2 - L1 + (W2 - W1) / 2, B2 - B1 + (H2 - H1) / 2)
	elseif button == "RightButton" then
		if IsControlKeyDown() then
			animation = "Negative"
			modelanimation = 41
		elseif IsAltKeyDown() then
			animation = "Positive"
			modelanimation = 40
		else
			if modelanimation < 802 then
				modelanimation = modelanimation + 1
			else
				modelanimation = 0
			end
		end
	elseif button == "MiddleButton" then
		if IsControlKeyDown() then
			modelanimation = 1
		else
			modelanimation = -1
		end
	end
end)


local timer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
	if modelanimation > -1 and modelanimation < 802 then
		timer = timer + (elapsed * 1000)
		model:SetSequenceTime(modelanimation, timer)
	end
end)

local elapsed = 0
local timer = 0
local degree = 0
animframe:SetScript("OnUpdate", function(self, elapsed)
	timer = timer + elapsed
	if timer < 0.05 or not animation then
		return
	end
	if degree < 360 and degree > - 360 then
		if animation == "Positive" then
			degree = degree + 1
		elseif animation == "Negative" then
			degree = degree - 1
		end
		model:SetRotation(math.rad(degree))
	else
		degree = 0
		animation = false
		modelanimation = -1
	end
end)

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local Addon = ...
		if Addon == "Crabby" then
			frame:SetPoint("Center", CrabbyVars.x, CrabbyVars.y)
			frame:UnregisterEvent("ADDON_LOADED")
		end
	end
end)