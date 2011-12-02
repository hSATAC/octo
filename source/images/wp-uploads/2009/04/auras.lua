local aUF = LibStub("AceAddon-3.0"):GetAddon("ag_UnitFrames")
local plugin = aUF:NewModule("Auras")
local newFrame, delFrame = aUF.newFrame, aUF.delFrame

local playerClass

-- Upvalues
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff

-- QueueSet: A FIFO Queue which guarantees all elements to be unique
local QueueSet = {};

--
--add GetAuraScale
function plugin.GetAuraScale(self, frame)
--error('test getaura scale')
	local position, rows, columns, scale
	
	if frame and frame == self.debuffFrame then
		position = plugin.db.profile.units[self.type].DebuffPos
		rows = plugin.db.profile.units[self.type].DebuffRows
		columns = plugin.db.profile.units[self.type].DebuffColumns	
	else
		position = plugin.db.profile.units[self.type].AuraPos
		rows = plugin.db.profile.units[self.type].AuraRows
		columns = plugin.db.profile.units[self.type].AuraColumns
	end
	local count = rows * columns
	if frame.growAs then
		position = frame.growAs
	end

	if position == "Below" or position == "Above" then
		if frame.autoScale then
			local offset = type(frame.autoScale) == "number" and frame.autoScale or 0
			scale = (self.frame:GetWidth() + offset)/(16*columns+(columns-1)*2)
		end
	elseif position == "Left" or position == "Right" then
		if frame.autoScale then
			local offset = type(frame.autoScale) == "number" and frame.autoScale or 0
			scale = (self.frame:GetHeight() + offset)/(16*rows+(rows-1)*2)
		end
	end
	--if frame.auraScale then
		--scale = frame.auraScale
	--end
	if not scale or scale <= 0 then
		scale = 1
	end
	return scale
end
--end here
--

function QueueSet:new()
	return {
		offer = self.offer,
		poll = self.poll,
		peek = self.peek,
		elements = {},
		map = {},
	};
end

function QueueSet:offer(e)
	if (self.map[e]) then return end
	self.map[e] = true
	self.elements[#self.elements + 1] = e
end

function QueueSet:poll() 
	local e = table.remove(self.elements, 1)
	if (e ~= nil) then
		if (not self.map[e]) then error("invalid state in QueueSet") end
		self.map[e] = nil
	end
	return e
end

function QueueSet:peek()
	return self.elements[1]
end

local auraUpdatePool = QueueSet:new()

local CanDispel = {
	PRIEST = {
		Magic = true,
		Disease = true,
	},
	SHAMAN = {
		Poison = true,
		Disease = true,
	},
	PALADIN = {
		Magic = true,
		Poison = true,
		Disease = true,
	},
	MAGE = {
		Curse = true,
	},
	DRUID = {
		Curse = true,
		Poison = true,
	}
}
	
function plugin:OnRegister()
	self:RegisterDefaults({
		units = {
			["**"] = {
				AuraStyle = "TwoLines",
				AuraPos = "Below",
				AuraFilter = 0,
				AuraDebuffC = false,
				AuraRows = 2,
				AuraColumns = 10,
				AuraPreferBuff = true,
				cooldown = true,
				DebuffRows = 2,
				DebuffColumns = 10,
				DebuffPos = "Below",
				Gloss = true,
			},
			["raid"] = {
				AuraPos = "Hidden",
				DebuffPos = "Hidden",
				AuraRows = 1,
				AuraFilter = 1,
				AuraDebuffC = true,
			},
			["player"] = {
				AuraFilter = 1,
				AuraDebuffC = true,
			},
			["pet"] = {
				AuraRows = 1,
				AuraFilter = 1,
				AuraDebuffC = true,
			},			
			["party"] = {
				AuraRows = 1,
				AuraFilter = 1,
				AuraDebuffC = true,
			},	
			["partypet"] = {
				AuraRows = 1,
				AuraColumns = 8,
				AuraFilter = 1,
				AuraDebuffC = true,
				DebuffRows = 1,
				DebuffColumns = 8,
			},
			["targettarget"] = {
				AuraRows = 1,
				AuraColumns = 8,
				DebuffRows = 1,
				DebuffColumns = 8,
			},
			["partytarget"] = {
				AuraPos = "Hidden",
				DebuffPos = "Hidden",
			},
		}
	})
	
	if (not self.cache) then 
		self.cache = {}
	end
	self.cache.buffs = setmetatable({}, {__index = function(t, k) t[k] = {}; return t[k] end})
	self.cache.debuffs = setmetatable({}, {__index = function(t, k) t[k] = {}; return t[k] end})
	playerClass = select(2, UnitClass("player"))
end

function plugin:OnEnable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectEnable(object)
		object:ApplyLayout()
		self.AuraPositions(object)
		self.AuraDimentions(object)
		self.UpdateAuras(object)
		self:OnRegisterEvents(object)
	end
	self.OnUpdateEvent = self:StartTimer("UpdatePool", 0.05)
end

function plugin:OnDisable()
	for _,object in aUF:IterateUnitObjects() do
		self:OnObjectDisable(object)
	end
	self:CancelTimer(self.OnUpdateEvent)
end

function plugin:OnObjectDisable(object)
	self:OnRegisterEvents(object)
	if object.buffFrame then
		object.buffFrame:Hide()
	end
	if object.debuffFrame then
		object.debuffFrame:Hide()
	end
end

function plugin:OnRegisterEvents(object)
	local bPos = plugin.db.profile.units[object.type].AuraPos
	local dbPos = plugin.db.profile.units[object.type].DebuffPos
	local auraDebuffC = plugin.db.profile.units[object.type].AuraDebuffC
	local hide = bPos == "Hidden" and dbPos == "Hidden"
	if ((not (hide)) or auraDebuffC) then
		object:RegisterUnitEvent("UNIT_AURA", self.UpdateAuras)
	else
		object:UnregisterUnitEvent("UNIT_AURA", self.UpdateAuras)
	end
end

function plugin:OnMetroUpdate(object)
	self.UpdateAuras(object)
end

function plugin:OnUpdateAll(object)
	self.UpdateAuras(object)
end

local setupMode
function plugin:OnUpdateSetupMode(object, flag)
	setupMode = flag
	if flag then
		self.ShowAuraPositions(object)
	else
		self.UpdateAuras(object)
	end
end

function plugin:UpdatePool()
	for i = 1,5 do
		local object = auraUpdatePool:poll()
		if object then
			self.UpdateAuras(object,nil,nil,true)
		else
			break
		end
	end
end

function plugin:OnLayoutApplied(object)
	plugin.AuraPositions(object)
	plugin.AuraDimentions(object)
end

function plugin:OnObjectEnable(object)
	local bPos = plugin.db.profile.units[object.type].AuraPos
	local dbPos = plugin.db.profile.units[object.type].DebuffPos
	local auraDebuffC = plugin.db.profile.units[object.type].AuraDebuffC
	local hide = bPos == "Hidden" and dbPos == "Hidden"

	if not object.DebuffHighlight and auraDebuffC then
		local highlight = newFrame("Texture",object.top, "OVERLAY")
		highlight:SetAlpha(0.5)
		highlight:SetTexture("Interface\\AddOns\\ag_UnitFrames\\Images\\DebuffHighlight")
		highlight:SetBlendMode("ADD")
		highlight:SetPoint("TOPLEFT",object.frame, "TOPLEFT", 5, -5)
		highlight:SetPoint("BOTTOMRIGHT",object.frame, "BOTTOMRIGHT", -5, 5)
		highlight:Hide()
		object.DebuffHighlight = highlight
	end
	if hide then
		return
	end
	
	if not object.buffFrame then
		self:CreateBuffFrame(object)
	else
		object.buffFrame.position = plugin.db.profile.units[object.type].AuraPos
	end
	object.buffFrame.position = plugin.db.profile.units[object.type].AuraPos
	if not object.debuffFrame and not (dbPos == "Hidden") and not (dbPos == bPos) then
		self:CreateBuffFrame(object, true)
	elseif object.debuffFrame then
		object.debuffFrame.position = plugin.db.profile.units[object.type].DebuffPos
	end
end

function plugin:CreateBuffFrame(object, flag)
	local frame = CreateFrame("Frame", nil, object.frame)
	frame:Hide()
	if flag then
		frame.position = plugin.db.profile.units[object.type].DebuffPos
		object.debuffFrame = frame
	else
		frame.position = plugin.db.profile.units[object.type].AuraPos
		object.buffFrame = frame
	end
end

-- ----------- --
-- Positioning --
-- ----------- --

function plugin.AuraPositions(object)
	local dbPos = plugin.db.profile.units[object.type].DebuffPos
	local bPos = plugin.db.profile.units[object.type].AuraPos

	if object.buffFrame then
		object.buffFrame.position = bPos
		plugin.AuraPosition(object, object.buffFrame)
	end
	if object.debuffFrame then
		object.debuffFrame.position = dbPos
		plugin.AuraPosition(object, object.debuffFrame)
	elseif not object.debuffFrame and not (dbPos == "Hidden") and not (dbPos == bPos) then
		plugin.AuraPosition(object, object.debuffFrame)
	end
	if setupMode then
		plugin.ShowAuraPositions(object)
	end
end

function plugin.AuraPosition(self, frame)
	local position, rows, columns
	
	local bPos = plugin.db.profile.units[self.type].AuraPos
	local dbPos = plugin.db.profile.units[self.type].DebuffPos
	
	if frame and frame == self.debuffFrame then
		position = dbPos
		rows = plugin.db.profile.units[self.type].DebuffRows
		columns = plugin.db.profile.units[self.type].DebuffColumns	
	else
		position = bPos
		rows = plugin.db.profile.units[self.type].AuraRows
		columns = plugin.db.profile.units[self.type].AuraColumns
	end

	local combined = bPos == dbPos
	local allHidden = dbPos == "Hidden" and bPos == "Hidden"
	
	if allHidden or (frame == self.debuffFrame and (position == "Hidden" or combined)) or (frame == self.buffFrame and position == "Hidden" and not (combined)) then
		frame:Hide()
		return
	end
	
	local count = rows * columns
	if frame.growAs then
		position = frame.growAs
	end
	
	plugin.SetAuraCount(self, frame, count)
	plugin.SetAuraFrameGloss(self, frame)
	
	-- Aura's were not even created yet, so we have nothing to position.
	if not frame.Aura1 then
		return
	end
	
		frame.Aura1:ClearAllPoints()
	if position == "Below" or position == "Right" then	
		frame.Aura1:SetPoint("TOPLEFT", frame,"TOPLEFT", 0, 0)
	elseif position == "Above" then
		frame.Aura1:SetPoint("BOTTOMLEFT", frame,"BOTTOMLEFT", 0, 0)
	elseif position == "Left" then
		frame.Aura1:SetPoint("TOPRIGHT", frame,"TOPRIGHT", 0, 0)
	end
		
	if position == "Above" or position == "Below" then
		for i=2,count do
			frame["Aura"..i]:ClearAllPoints()
			if (i % columns == 1) then
				if position == "Above" then
					frame["Aura"..i]:SetPoint("BOTTOM",frame["Aura"..i-columns],"TOP",0,2)
				else
					frame["Aura"..i]:SetPoint("TOP",frame["Aura"..i-columns],"BOTTOM",0,-2)
				end
			else
				frame["Aura"..i]:SetPoint("LEFT",frame["Aura"..i-1],"RIGHT",2,0)
			end
		end
		local j = count + 1
		while frame["Aura"..j] do
			frame["Aura"..j]:Hide()
			j = j + 1
		end		
	elseif position == "Left" or position == "Right" then
		for i=2,count do
			frame["Aura"..i]:ClearAllPoints()
			if (i % rows == 1) or rows == 1 then
				if position == "Left" then
					frame["Aura"..i]:SetPoint("RIGHT",frame["Aura"..i-rows],"LEFT",-2,0)
				else
					frame["Aura"..i]:SetPoint("LEFT",frame["Aura"..i-rows],"RIGHT",2,0)
				end
			else
				frame["Aura"..i]:SetPoint("TOP",frame["Aura"..i-1],"BOTTOM",0,-2)
			end
		end
		local j = count + 1
		while frame["Aura"..j] do
			frame["Aura"..j]:Hide()
			j = j + 1
		end
	end
	frame.setup = true
end

function plugin.AuraDimentions(object)
	if object.buffFrame and object.buffFrame.setup then
		plugin.AuraDimention(object, object.buffFrame)
	end
	if object.debuffFrame and object.debuffFrame.setup then
		plugin.AuraDimention(object, object.debuffFrame)
	end	
end

function plugin.AuraDimention(self, frame)
	local position, rows, columns, scale
	
	if frame and frame == self.debuffFrame then
		position = plugin.db.profile.units[self.type].DebuffPos
		rows = plugin.db.profile.units[self.type].DebuffRows
		columns = plugin.db.profile.units[self.type].DebuffColumns	
	else
		position = plugin.db.profile.units[self.type].AuraPos
		rows = plugin.db.profile.units[self.type].AuraRows
		columns = plugin.db.profile.units[self.type].AuraColumns
	end
	local count = rows * columns
	if frame.growAs then
		position = frame.growAs
	end

	if position == "Below" or position == "Above" then
		if frame.autoScale then
			local offset = type(frame.autoScale) == "number" and frame.autoScale or 0
			scale = (self.frame:GetWidth() + offset)/(16*columns+(columns-1)*2)
		end
	elseif position == "Left" or position == "Right" then
		if frame.autoScale then
			local offset = type(frame.autoScale) == "number" and frame.autoScale or 0
			scale = (self.frame:GetHeight() + offset)/(16*rows+(rows-1)*2)
		end
	end
	if frame.auraScale then
		scale = frame.auraScale
	end
	if not scale or scale <= 0 then
		scale = 1
	end
	if not frame.autoScale then
		if frame.autoWidth then
			frame:SetWidth((columns*16 + (columns-1)*2)*scale)
		end
		if frame.autoHeight then
			frame:SetHeight((rows*16 + (rows-1)*2)*scale)
		end
	end
	for i=1,count do
		if frame["Aura"..i] then
			frame["Aura"..i]:SetScale(scale)
		end
	end
end

local function hideTT()
	GameTooltip:Hide()
end

local function onAuraEnter(self)
	if (not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	if ( self.buffFilter == "HELPFUL") then
		local filter = plugin.db.profile.units[self.unit.type].BuffFilter and "RAID" or nil
		GameTooltip:SetUnitBuff(self.unit.unit, self.id, filter)
	elseif ( self.buffFilter == "HARMFUL") then
		GameTooltip:SetUnitDebuff(self.unit.unit, self.id, nil)
	end
end

function plugin.SetAuraGloss(object)
	if object.buffFrame and object.buffFrame.setup then
		plugin.SetAuraFrameGloss(object, object.buffFrame)
	end
	if object.debuffFrame and object.debuffFrame.setup then
		plugin.SetAuraFrameGloss(object, object.debuffFrame)
	end	
end

function plugin.SetAuraFrameGloss(object, frame)
	local i = 1
	if plugin.db.profile.units[object.type].Gloss then
		while frame["Aura" .. i] and i < 49 do
			local aura = "Aura" .. i
			if frame[aura] then
				frame[aura].ButtonGloss:Show()
			end
			i = i + 1
		end
	else
		while frame["Aura" .. i] and i < 49 do
			local aura = "Aura" .. i
			if frame[aura] then
				frame[aura].ButtonGloss:Hide()
			end
			i = i + 1
		end	
	end
end

function plugin.SetAuraCount(self, frame, count)
	for i = 1,math.max(count) do
		if count == 49 then 
			break
		end
		local aura = "Aura" .. i
		if (not frame[aura]) then
			local name = self.name .. "_" .. aura
			local auraFrame
			auraFrame = newFrame("Button", self.middle)
			auraFrame:SetParent(frame)
			auraFrame:Hide()			
			auraFrame:SetWidth(16)
			auraFrame:SetHeight(16)
			
			auraFrame.Icon = newFrame("Texture", auraFrame, "BACKGROUND")
			auraFrame.Icon:SetAllPoints(auraFrame)
			auraFrame.Icon:SetTexCoord(.07, .93, .07, .93)
	
			local Overlay = auraFrame:CreateTexture(nil, 'OVERLAY')
			Overlay = newFrame("Texture", auraFrame, "ARTWORK")
			Overlay:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			Overlay:SetTexCoord(.296875, .5703125, 0, .515625)
			Overlay:SetPoint("CENTER", auraFrame)
			Overlay:SetWidth(17)
			Overlay:SetHeight(17)
			auraFrame.Overlay = Overlay

			local ButtonGloss = auraFrame:CreateTexture(nil, 'ARTWORK')
			ButtonGloss:SetTexture('Interface\\AddOns\\ag_UnitFrames\\images\\AuraGloss')
			ButtonGloss:SetParent(auraFrame)
			ButtonGloss:SetPoint('TOPLEFT', -2.5, 2.5)
			ButtonGloss:SetPoint('BOTTOMRIGHT', 2.5, -2.5)
			ButtonGloss:SetVertexColor(.84,.75,.65)
			ButtonGloss:SetBlendMode('ADD')
			ButtonGloss:SetAlpha(0.3)
			auraFrame.ButtonGloss = ButtonGloss
			
			local Count = newFrame("FontString", auraFrame, "OVERLAY")
			Count:SetFont("Interface\\AddOns\\ag_UnitFrames\\fonts\\barframes.ttf", 10, "OUTLINE")
			Count:SetShadowColor(0, 0, 0, 1)
			Count:SetShadowOffset(0.8, -0.8)
			Count:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", 1, 0)
			Count:SetWidth(18)
			Count:SetHeight(10)
			Count:SetJustifyH("RIGHT")
			auraFrame.Count = Count
			
			local cooldown = newFrame("cooldown", auraFrame)
			cooldown:Hide()			
			cooldown:SetAllPoints(auraFrame)
			cooldown:SetReverse(true)
			cooldown:SetFrameLevel(auraFrame:GetFrameLevel())
			cooldown:SetAlpha(1)
			auraFrame.cooldown = cooldown
			
			auraFrame:SetScript("OnEnter", onAuraEnter)
			auraFrame:SetScript("OnLeave", hideTT)
			auraFrame.unit = self
			frame[aura] = auraFrame
		end
	end
	local i = count+1
	while (true) do
		local f = frame["Aura"..i]
		if (not f) then
			break
		end
		f:Hide()
		i = i+1
	end
end

-- --------------- --
-- Texture updates --
-- --------------- --

function plugin.UpdateAuras(object, _, _, exec)
	if setupMode then return end
	if not exec then
		auraUpdatePool:offer(object)
		return
	end

	local bcount, dbcount, highlighttype
	if object.unit then
		local debuffC = plugin.db.profile.units[object.type].AuraDebuffC
		bcount, dbcount, highlighttype = plugin.ScanAuras(object)
		if object.DebuffHighlight and highlighttype and DebuffTypeColor[highlighttype] and debuffC == true then
			local h = DebuffTypeColor[highlighttype]
			object.DebuffHighlight:Show()
			object.DebuffHighlight:SetVertexColor(h.r, h.g, h.b)
		elseif object.DebuffHighlight then
			object.DebuffHighlight:Hide()
		end
	else
		return
	end
	local bPos, dbPos = plugin.db.profile.units[object.type].AuraPos, plugin.db.profile.units[object.type].DebuffPos
	local combined = bPos == dbPos
	local allHidden = bPos == "Hidden" and dbPos == "Hidden"
	
	if object.buffFrame and ((not (allHidden)) and ((not (bPos == "Hidden")) or (combined and not dbPos == "Hidden"))) then
		plugin.UpdateAuraFrame(object, object.buffFrame, bcount or 0, (combined and dbcount) or 0, exec)
	end
	if object.debuffFrame and not (bPos == dbPos) and not (dbPos == "Hidden") then
		plugin.UpdateAuraFrame(object, object.debuffFrame, 0, dbcount or 0, exec)
	end
end

function plugin.UpdateAuraFrame(self, frame, bcount, dbcount)
	if bcount + dbcount == 0 then
		frame:Hide()
		return
	end
	frame:Show()
	
	local position, rows, cols
	local buttons, dFound
	if frame and frame == self.debuffFrame then
		position = plugin.db.profile.units[self.type].DebuffPos
		rows = plugin.db.profile.units[self.type].DebuffRows
		cols = plugin.db.profile.units[self.type].DebuffColumns
	else
		position = plugin.db.profile.units[self.type].AuraPos
		rows = plugin.db.profile.units[self.type].AuraRows
		cols = plugin.db.profile.units[self.type].AuraColumns
	end	
	if position == "Hidden" then
		return
	end
	if frame.growAs then
		position = frame.growAs
	end
	
	local auracount = rows * cols
	if not frame["Aura"..1] then
		return
	end
		
	if (not frame.hidden) then
		for i=1,auracount do
			frame["Aura"..i]:Hide()
		end
	end
	if (auracount < bcount + dbcount) then
		if (plugin.db.profile.units[self.type].AuraPreferBuff) then
			dbcount = auracount - bcount
			if (dbcount < 0) then
				bcount = auracount
				dbcount = 0
			end
		else
			bcount = auracount - dbcount
			if (bcount < 0) then
				dbcount = auracount
				bcount = 0
			end
		end
	end
	
	local cooldown = plugin.db.profile.units[self.type].cooldown
	if bcount > 0 then
		local c, id, icon, count, duration, expirationTime

		for i=1,bcount do
			c = plugin.cache.buffs[i]
			id, icon, count, duration, expirationTime = c.id, c.icon, c.count, c.duration, (cooldown and c.expirationTime or 0)
			--plugin.SetAura(self, frame["Aura" .. i], false, id, icon, count, nil, expirationTime, duration)
			local scale = plugin.GetAuraScale(self, frame)
			plugin.SetAura(self, frame["Aura" .. i], false, id, icon, count, nil, expirationTime, duration, scale)
		end
	end
	
	if position == "Above" or position == "Below" then
		rows = math.ceil((bcount+dbcount) / cols)
	elseif (position == "Left" or position == "Right" or position == "Inside") then
		cols = math.ceil((bcount+dbcount) / rows)
	end
	
	if dbcount > 0 then
		local c, id, icon, count, debuffType, duration, expirationTime
		for i=1,dbcount do
			c = plugin.cache.debuffs[i];
			id, icon, count, debuffType, duration, expirationTime = c.id, c.icon, c.count, c.debuffType, c.duration, (cooldown and c.expirationTime or 0)
			local index = rows * cols - i + 1
			--plugin.SetAura(self, frame["Aura" .. index], true, id, icon, count, debuffType, expirationTime, duration)
			local aura_name, aura_rank, aura_icon, aura_count, aura_debuffType,aura_duration, aura_expirationTime, aura_isMine, aura_isStealable =UnitAura(self.type, i,"HARMFUL")
			local scale = plugin.GetAuraScale(self, frame)
			if self.type == "target" and aura_isMine=="player" then
				scale = scale * 2;
			end
			plugin.SetAura(self, frame["Aura" .. index], true, id, icon, count, debuffType, expirationTime, duration, scale)
		end
	end
end

function plugin.SetAura(self, buffFrame, isDebuff, id, buff, count, class, expirationTime, duration, scale)

	--start 就放大兩倍
	if scale then
		buffFrame:SetScale(scale)
	end
	--end 
	
	buffFrame.Icon:SetTexture(buff)
	buffFrame:Show()
	buffFrame.id = id
	
	if duration and duration > 0 and expirationTime and expirationTime > 0 then
		local startCooldownTime = expirationTime - duration
		buffFrame.cooldown:SetCooldown(startCooldownTime, duration)
		buffFrame.cooldown:Show()
	else
		buffFrame.cooldown:Hide()
	end
	
	if (not (buffFrame.hideCount)) and count and count > 1 then
		buffFrame.Count:SetText(count)
	else
		buffFrame.Count:SetText("")
	end

	if (isDebuff) then
		buffFrame.buffFilter = "HARMFUL"
		local borderColor
		if class then
			borderColor = DebuffTypeColor[class]
		else
			borderColor = DebuffTypeColor["none"]
		end
		if borderColor then
			buffFrame.Overlay:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
		end
	else
		buffFrame.Overlay:SetVertexColor(0.6, 0.6, 0.6)
		buffFrame.buffFilter = "HELPFUL"
	end
end

function plugin.ScanAuras(self)
	local unit = self.unit
	local filter, logdb
	local dbcount, bcount
	
	local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable
	local id, buffid = 1, 1
	local c
	
	-- Scan Buffs
	filter = plugin.db.profile.units[self.type].BuffFilter and "RAID" or nil
	name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff(unit, buffid, filter)
	while name do
		c = plugin.cache.buffs[buffid]
		c.id, c.name, c.rank, c.icon, c.count, c.debuffType, c.duration, c.expirationTime, c.caster, c.isStealable = 
		  buffid, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable

		buffid = buffid + 1
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff(unit, buffid, filter)
	end
	bcount = buffid - 1

	-- Scan Debuffs
	filter = plugin.db.profile.units[self.type].DebuffFilter
	id, buffid = 1, 1
	
	name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuff(unit, buffid)
	while (name) do
		local logdb = false
		if not filter then
			logdb = true
		elseif (CanDispel[playerClass] and CanDispel[playerClass][debuffType]) then
			logdb = true
		elseif (playerClass == "PRIEST" and icon == "Interface\\Icons\\Spell_Holy_AshesToAshes") then
			logdb = true
		end

		if (logdb) then
			c = plugin.cache.debuffs[id]
			c.id, c.name, c.rank, c.icon, c.count, c.debuffType, c.duration, c.expirationTime, c.caster, c.isStealable = 
			  buffid, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable
			id = id + 1
		end

		buffid = buffid + 1
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuff(unit, buffid)
	end
	dbcount = id - 1

	if (dbcount > 0) then
		return bcount, dbcount, plugin.cache.debuffs[1].type
	else
		return bcount, dbcount
	end
end

-- ---------- --
-- Setup mode --
-- ---------- --

function plugin.ShowAuraPositions(object)
	if object.buffFrame then
		plugin.ShowAuraPosition(object, object.buffFrame)
	end
	if object.debuffFrame then
		plugin.ShowAuraPosition(object, object.debuffFrame)
	end	
end

function plugin.ShowAuraPosition(self, frame)
	local debuffPos = plugin.db.profile.units[self.type].DebuffPos
	local auraPos = plugin.db.profile.units[self.type].AuraPos
	local rows, columns, pos
	if frame and frame == self.debuffFrame then
		rows = plugin.db.profile.units[self.type].DebuffRows
		columns = plugin.db.profile.units[self.type].DebuffColumns
		pos = debuffPos
	else
		rows = plugin.db.profile.units[self.type].AuraRows
		columns = plugin.db.profile.units[self.type].AuraColumns
		pos = auraPos
	end

	local combined = auraPos == debuffPos
	local allHidden = debuffPos == "Hidden" and auraPos == "Hidden"
	
	if allHidden or (frame == self.debuffFrame and (debuffPos == "Hidden" or combined)) or (frame == self.buffFrame and auraPos == "Hidden" and not (combined)) then
		frame:Hide()
		return
	end
	frame:Show()	
	local count = rows * columns
	
	local i = 1
	if (plugin.db.profile.units[self.type].AuraPreferBuff) then
		for i = 1, count do
			local b = frame["Aura"..i]
			if b then
				if frame == self.buffFrame and ((i <= 16) or (not combined)) then
					b.Icon:SetTexture("Interface\\Icons\\Spell_ChargePositive")
					b.Overlay:SetVertexColor(0.6, 0.6, 0.6)
				else
					b.Icon:SetTexture("Interface\\Icons\\Spell_ChargeNegative")
					b.Overlay:SetVertexColor(1, 0, 0)
				end
				b:Show()
				
				b.cooldown:Hide()
			end
		end
	else
		for i = 1, count do
			local b = frame["Aura"..i]
			if b then
				if ((i > count-16) and combined) or frame == self.debuffFrame then
					b.Icon:SetTexture("Interface\\Icons\\Spell_ChargeNegative")
					b.Overlay:SetVertexColor(1, 0, 0)
				else
					b.Icon:SetTexture("Interface\\Icons\\Spell_ChargePositive")
					b.Overlay:SetVertexColor(0.6, 0.6, 0.6)
				end
				b:Show()
				b.cooldown:Hide()
			end
		end
	end
end
