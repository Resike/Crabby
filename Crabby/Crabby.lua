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
frame:SetPoint("CENTER", 0, 0)
frame:SetWidth(512)
frame:SetHeight(512)
frame:SetAlpha(0.99)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(false)
frame:RegisterForDrag("LeftButton")
frame:RegisterForDrag("RightButton")
frame:RegisterForDrag("MiddleButton")

local model = CreateFrame("PlayerModel", nil, frame)
model:SetModel("Creature\\Deepseacrab\\deepseacrab_ghost.m2")
model:SetPosition(0, 0, 0)
model:SetRotation(math.rad(0))
model:SetAlpha(0.99)
model:SetAllPoints(frame)
model:Show()

-- You can animate the model by changing this from 0-802
local modelanimation = -1

frame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		self:StartMoving()
	elseif button == "RightButton" then
		modelanimation = modelanimation + 1
		--print(modelanimation)
	elseif button == "MiddleButton" then
		modelanimation = -1
		--print(modelanimation)
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
	end
end)


local elapsed = 0
frame:SetScript("OnUpdate", function(self, elaps)
	if modelanimation > -1 and modelanimation < 802 then
		elapsed = elapsed + (elaps * 1000)
		model:SetSequenceTime(modelanimation, elapsed)
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