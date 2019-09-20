AIR = {}

AIR.name 			= "AwesomeResearch"
AIR.Initialized 	= false
AIR.character 		= GetUnitName("player")
AIR.main       		= "Avashriel"

-- define saved vars
AIR.saved = {}
AIR.defaults = {}


AIR.smithingTypes = {
	blacksmithing = CRAFTING_TYPE_BLACKSMITHING,
	clothier = CRAFTING_TYPE_CLOTHIER,
	woodworking = CRAFTING_TYPE_WOODWORKING,
	jewelcrafting = CRAFTING_TYPE_JEWELRYCRAFTING,
}

AIR.weaponTypes = {
															-- [0] (none)
    [WEAPONTYPE_AXE] 				= "Axe", 				-- [1]
    [WEAPONTYPE_HAMMER] 			= "Mace", 				-- [2]
    [WEAPONTYPE_SWORD] 				= "Sword", 				-- [3]
    [WEAPONTYPE_TWO_HANDED_SWORD] 	= "Greatsword",			-- [4]
    [WEAPONTYPE_TWO_HANDED_AXE] 	= "Battle Axe", 		-- [5]
    [WEAPONTYPE_TWO_HANDED_HAMMER] 	= "Maul", 				-- [6]
															-- [7] (prop)
    [WEAPONTYPE_BOW] 				= "Bow",				-- [8]
    [WEAPONTYPE_HEALING_STAFF] 		= "Restoration Staff",	-- [9]
															-- [10] (rune)
    [WEAPONTYPE_DAGGER] 			= "Dagger",				-- [11]
    [WEAPONTYPE_FIRE_STAFF] 		= "Inferno Staff",		-- [12]
    [WEAPONTYPE_FROST_STAFF] 		= "Ice Staff",			-- [13]
    [WEAPONTYPE_SHIELD] 			= "Shield",				-- [14]
    [WEAPONTYPE_LIGHTNING_STAFF] 	= "Lightning Staff",	-- [15]
}

AIR.armorTypes = {
															-- [0] (none)
	[ARMORTYPE_LIGHT] = {									-- [1]
		[EQUIP_TYPE_HEAD]        = "Hat",			--[1]
		[EQUIP_TYPE_NECK]        = "Necklace",		--[2]
		[EQUIP_TYPE_CHEST]       = "Robe & Jerkin",	--[3]
		[EQUIP_TYPE_SHOULDERS]   = "Epaulets",		--[4]
													--[5] (one hand)
													--[6] (two hand)
													--[7] (off hand)
		[EQUIP_TYPE_WAIST]       = "Sash",			--[8]
		[EQUIP_TYPE_LEGS]        = "Breeches",		--[9]
		[EQUIP_TYPE_FEET]        = "Shoes",			--[10]
													--[11] (costume)
		[EQUIP_TYPE_RING]        = "Ring",			--[12]
		[EQUIP_TYPE_HAND]        = "Gloves",		--[13]
													--[14] (main hand)
													--[15] (poison)
	},
	[ARMORTYPE_MEDIUM] = {									-- [2]
		[EQUIP_TYPE_HEAD]        = "Helmet",		--[1]
		[EQUIP_TYPE_NECK]        = "Necklace",		--[2]
		[EQUIP_TYPE_CHEST]       = "Jack",			--[3]
		[EQUIP_TYPE_SHOULDERS]   = "Arm Cops",		--[4]
													--[5] (one hand)
													--[6] (two hand)
													--[7] (off hand)		
		[EQUIP_TYPE_WAIST]       = "Belt",			--[8]
		[EQUIP_TYPE_LEGS]        = "Guards",		--[9]
		[EQUIP_TYPE_FEET]        = "Boots",			--[10]
													--[11] (costume)		
		[EQUIP_TYPE_RING]        = "Ring",			--[12]
		[EQUIP_TYPE_HAND]        = "Bracers",		--[13]
													--[14] (main hand)
													--[15] (poison)
	},
	[ARMORTYPE_HEAVY] = {									-- [3]
		[EQUIP_TYPE_HEAD]        = "Helm",			--[1]
		[EQUIP_TYPE_NECK]        = "Necklace",		--[2]
		[EQUIP_TYPE_CHEST]       = "Cuirass",		--[3]
		[EQUIP_TYPE_SHOULDERS]   = "Pauldron",		--[4]
													--[5] (one hand)
													--[6] (two hand)
													--[7] (off hand)
		[EQUIP_TYPE_WAIST]       = "Girdle",		--[8]
		[EQUIP_TYPE_LEGS]        = "Greaves",		--[9]
		[EQUIP_TYPE_FEET]        = "Sabatons",		--[10]
													--[11] (costume)
		[EQUIP_TYPE_RING]        = "Ring",			--[12]
		[EQUIP_TYPE_HAND]        = "Gauntlets",		--[13]
													--[14] (main hand)
													--[15] (poison)
	}
}

----------------------------------------------------
-- addon: Initialize
----------------------------------------------------
function AIR.Initialize(eventCode, addOnName)
	-- Only initialize our own addon
	if (AIR.name ~= addOnName) then return end

    -- Load the saved variables. 
    AIR.saved = ZO_SavedVars:NewAccountWide("AIR_SavedVariables", 1, nil, AIR.defaults)	
		
	-- register events
	AIR.RegisterEvents()	
	
	-- done here
    AIR.Initialized = true
end

----------------------------------------------------
-- addon: register events
----------------------------------------------------
function AIR.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent("AIR", EVENT_PLAYER_ACTIVATED, AIR.ScanMain)
end

----------------------------------------------------
-- addon: scan main character traits
----------------------------------------------------
function AIR.ScanMain()
	-- smithingType = {blacksmithing,woodworking, etc}
	-- researchLine = { ice staff, lightning staff, etc}
	if (AIR.character == AIR.main) then
        for smithingType, smithingIndex in pairs(AIR.smithingTypes) do	
			for lineIndex = 1, GetNumSmithingResearchLines(smithingIndex) do
				local researchLine, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(smithingIndex, lineIndex)
				if (not AIR.saved[researchLine]) then AIR.saved[researchLine] = {} end
				for traitIndex = 1, numTraits do
					local duration, remaining = GetSmithingResearchLineTraitTimes(smithingIndex, lineIndex, traitIndex)
					local traitID, description, known = GetSmithingResearchLineTraitInfo(smithingIndex, lineIndex, traitIndex)
					local traitName = GetString("SI_ITEMTRAITTYPE", traitID)
					AIR.saved[researchLine][traitName] = false
					if known then
						AIR.saved[researchLine][traitName] = true
					end
				end
			end
		end
	end
end

----------------------------------------------------
-- addon: compare inventory items with saved scan
----------------------------------------------------
function AIR.CanResearch(slotData)
	local category, canResearch = "", false
	local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)
	
	-- get the trait
	local itemTrait = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(itemLink))

	-- no trait to research
	if (itemTrait == 'No Trait') then return false end
	
	-- get the weapon type and map it to known types
	if slotData.itemType == ITEMTYPE_WEAPON then
		category = AIR.weaponTypes[GetItemLinkWeaponType(itemLink)]
	end
	
	-- get the armor type and map it to known types
	if slotData.itemType == ITEMTYPE_ARMOR then
		if AIR.armorTypes[GetItemLinkArmorType(itemLink)] then
			category = AIR.armorTypes[GetItemLinkArmorType(itemLink)][slotData.equipType]	

		-- ring and neck
		else
			category = AIR.armorTypes[1][slotData.equipType]	
		end
	end
	
	-- is it researchable by main?
	return not AIR.saved[category][itemTrait]
end

----------------------------------------------------
-- addon: determine which texture to use
----------------------------------------------------
function AIR.GetIconTexture(slotData)
	local texture = nil
	-- only if weapon or armor
	if slotData.itemType == ITEMTYPE_ARMOR or slotData.itemType == ITEMTYPE_WEAPON then
		-- researchable by main (green)
		if AIR.CanResearch(slotData) then
			texture = "AwesomeResearch/inventory_trait_not_researched_icon_green.dds"
		-- researchable by self (white)
		else    
			if slotData.traitInformation ~= ITEM_TRAIT_INFORMATION_NONE then
				-- normally slotData.traitInformation is ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED
				texture = GetPlatformTraitInformationIcon(slotData.traitInformation)
			end
		end
	end
	return texture
end

----------------------------------------------------
-- addon: skip ornate and intricate
----------------------------------------------------
function AIR.IsSpecial(slotData)
	local special = false
	local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)
	local itemTrait = GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(itemLink))
	if itemTrait == 'Ornate' or itemTrait == 'Intricate' then
		special = true
	end
	return special
end

----------------------------------------------------
-- override trait research icon on alts
----------------------------------------------------
local oldZO_UpdateTraitInformationControlIcon = ZO_UpdateTraitInformationControlIcon
function ZO_UpdateTraitInformationControlIcon(inventorySlot, slotData)
	-- go to original function if on main
	if (AIR.character == AIR.main or AIR.IsSpecial(slotData)) then
		--d("is main")
		oldZO_UpdateTraitInformationControlIcon(inventorySlot, slotData)
		return
	-- alts use the alternate lol
	else
		local traitInfoControl = GetControl(inventorySlot, "TraitInfo")
		traitInfoControl:ClearIcons()		
		local texture = AIR.GetIconTexture(slotData)
		if (texture) then
			traitInfoControl:AddIcon(texture)
			traitInfoControl:Show()
		end
	end
end

----------------------------------------------------
-- Initialize has been defined so register the event
----------------------------------------------------
EVENT_MANAGER:RegisterForEvent("AIR", EVENT_ADD_ON_LOADED, AIR.Initialize)

