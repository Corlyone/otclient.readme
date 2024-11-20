ItemsDatabase = {}

ItemsDatabase.rarityColors = {
    ["yellow"] = TextColors.yellow,
    ["purple"] = TextColors.purple,
    ["blue"] = TextColors.blue,
    ["green"] = TextColors.green,
    ["grey"] = TextColors.grey,
}

local function getColorForValue(value)
    if value >= 1000000 then
        return "yellow"
    elseif value >= 100000 then
        return "purple"
    elseif value >= 10000 then
        return "blue"
    elseif value >= 1000 then
        return "green"
    elseif value >= 50 then
        return "grey"
    else
        return "white"
    end
end

local getSlotPanelBySlot = {
    [InventorySlotHead] = function(ui) return ui.helmet, ui.helmet.helmet end,
    [InventorySlotNeck] = function(ui) return ui.amulet, ui.amulet.amulet end,
    [InventorySlotBack] = function(ui) return ui.backpack, ui.backpack.backpack end,
    [InventorySlotBody] = function(ui) return ui.armor, ui.armor.armor end,
    [InventorySlotRight] = function(ui) return ui.shield, ui.shield.shield end,
    [InventorySlotLeft] = function(ui) return ui.sword, ui.sword.sword end,
    [InventorySlotLeg] = function(ui) return ui.legs, ui.legs.legs end,
    [InventorySlotFeet] = function(ui) return ui.boots, ui.boots.boots end,
    [InventorySlotFinger] = function(ui) return ui.ring, ui.ring.ring end,
    [InventorySlotAmmo] = function(ui) return ui.tools, ui.tools.tools end
}

function ItemsDatabase.setRarityItem(widget, item, style, slot)
    if not g_game.getFeature(GameColorizedLootValue) or not widget then
        return
    end
	
	if not widget then
        return
    end
	
	local getSlotInfo = getSlotPanelBySlot[slot]

    if not item and getSlotInfo then
		local imageBitsPath = "/images/game/slots/slots_bits/"
        widget:setImageSource(imageBitsPath .. slot)
        return
    end

    local price = type(item) == "number" and item or (item and item:getMeanPrice()) or 0
    local itemRarity = getColorForValue(price)
    local imagePath = "/images/ui/item"
    if itemRarity and itemRarity ~= "white" then -- necessary in setColorLootMessage
        imagePath = "/images/ui/rarity_" .. itemRarity
    end

    widget:setImageSource(imagePath)

    if style then
        widget:setStyle(style)
    end
end

function ItemsDatabase.getColorForRarity(rarity)
    return ItemsDatabase.rarityColors[rarity] or TextColors.white
end

function ItemsDatabase.setColorLootMessage(text)
    local function coloringLootName(match)
        local id, itemName = match:match("(%d+)|(.+)")
        local itemInfo = g_things.getThingType(tonumber(id), ThingCategoryItem):getMeanPrice()
        if itemInfo then
            local color = ItemsDatabase.getColorForRarity(getColorForValue(itemInfo))
            return "{" .. itemName .. ", " .. color .. "}"
        else
            return itemName
        end
    end
    return text:gsub("{(.-)}", coloringLootName)
end

function ItemsDatabase.setTier(widget, item)
    if not g_game.getFeature(GameThingUpgradeClassification) or not widget then
        return
    end
    local tier = type(item) == "number" and item or (item and item:getTier()) or 0
    if tier and tier > 0 then
        local xOffset = (math.min(math.max(tier, 1), 10) - 1) * 9
        widget.tier:setImageClip({
            x = xOffset,
            y = 0,
            width = 10,
            height = 9
        })
        widget.tier:setVisible(true)
    else
        widget.tier:setVisible(false)
    end
end
