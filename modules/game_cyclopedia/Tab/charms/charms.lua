﻿local UI = nil
function showCharms()
    UI = g_ui.loadUI("charms", contentContainer)
    UI:show()
    g_game.requestBestiary()
end

charmsControllerCyclopedia = Controller:new()

function charmsControllerCyclopedia:onInit()

    charmsControllerCyclopedia:registerEvents(g_game, {
        onUpdateBestiaryCharmsData = Cyclopedia.loadCharms
    })

end

function charmsControllerCyclopedia:onGameStart()

end

function charmsControllerCyclopedia:onGameEnd()

end

function charmsControllerCyclopedia:onTerminate()

end

Cyclopedia.Charms = {}

local CHARMS = {{
    ID = 9,
    IMAGE = "/game_cyclopedia/images/charms/9",
    TYPE = 1
}, {
    ID = 11,
    IMAGE = "/game_cyclopedia/images/charms/11",
    TYPE = 1
}, {
    ID = 10,
    IMAGE = "/game_cyclopedia/images/charms/10",
    TYPE = 1
}, {
    ID = 6,
    IMAGE = "/game_cyclopedia/images/charms/6",
    TYPE = 2
}, {
    ID = 8,
    IMAGE = "/game_cyclopedia/images/charms/8",
    TYPE = 3
}, {
    ID = 7,
    IMAGE = "/game_cyclopedia/images/charms/7",
    TYPE = 3
}, {
    ID = 5,
    IMAGE = "/game_cyclopedia/images/charms/5",
    TYPE = 4
}, {
    ID = 1,
    IMAGE = "/game_cyclopedia/images/charms/1",
    TYPE = 4
}, {
    ID = 3,
    IMAGE = "/game_cyclopedia/images/charms/3",
    TYPE = 4
}, {
    ID = 2,
    IMAGE = "/game_cyclopedia/images/charms/2",
    TYPE = 4
}, {
    ID = 0,
    IMAGE = "/game_cyclopedia/images/charms/0",
    TYPE = 4
}, {
    ID = 4,
    IMAGE = "/game_cyclopedia/images/charms/4",
    TYPE = 4
}, {
    ID = 16,
    IMAGE = "/game_cyclopedia/images/charms/16",
    TYPE = 5
}, {
    ID = 15,
    IMAGE = "/game_cyclopedia/images/charms/15",
    TYPE = 6
}, {
    ID = 17,
    IMAGE = "/game_cyclopedia/images/charms/17",
    TYPE = 6
}, {
    ID = 18,
    IMAGE = "/game_cyclopedia/images/charms/18",
    TYPE = 6
}, {
    ID = 19,
    IMAGE = "/game_cyclopedia/images/charms/18",
    TYPE = 6
}, {
    ID = 20,
    IMAGE = "/game_cyclopedia/images/charms/18",
    TYPE = 6
}, {
    ID = 21,
    IMAGE = "/game_cyclopedia/images/charms/18",
    TYPE = 6
}, {
    ID = 0,
    IMAGE = "/game_cyclopedia/images/charms/18",
    TYPE = 6
}}

function Cyclopedia.UpdateCharmsBalance(Value)
    for i, child in pairs(UI.Bottombase:getChildren()) do
        if child.CharmsBase then
            child.CharmsBase.Value:setText(Value)
        end
    end
end

function Cyclopedia.CreateCharmItem(data)
    local widget = g_ui.createWidget("CharmItem", UI.CharmList)
    local value = widget.PriceBase.Value

    widget:setId(data.id)

    -- Verificar que data.id no sea nil y que CHARMS[data.id] exista
    if data.id ~= nil and CHARMS[data.id + 1] then
        widget.charmBase.image:setImageSource(CHARMS[data.id + 1].IMAGE)
    else
        print("Error: CHARMS[" .. tostring(data.id) .. "] is nil")
        return
    end

    widget:setText(data.name)
    widget.data = data

    if data.hasCurrentCreature then
        -- Verificar que data.raceId no sea nil y que RACE[data.raceId] exista
        if data.raceId and RACE[data.raceId] then
            widget.InfoBase.Sprite:setOutfit(RACE[data.raceId].outfit)
            widget.InfoBase.Sprite:setAnimate(true)
        else
            print("Error: RACE[" .. tostring(data.raceId) .. "] es nil")
        end
    end

    if data.unlocked then
        widget.PriceBase.Charm:setVisible(false)
        widget.PriceBase.Gold:setVisible(true)
        widget.charmBase.lockedMask:setVisible(false)
        widget.icon = 1
        if data.hasCurrentCreature then
            widget.PriceBase.Value:setText(comma_value(data.removeRuneCost))
        else
            widget.PriceBase.Value:setText(0)
        end
    else
        widget.PriceBase.Charm:setVisible(true)
        widget.PriceBase.Gold:setVisible(false)
        widget.charmBase.lockedMask:setVisible(true)
        widget.PriceBase.Value:setText(comma_value(data.unlockPrice))
        widget.icon = 0
    end

    if widget.icon == 1 and UI.Balance then
        if data.removeRuneCost > UI.Balance then
            value:setColor("#D33C3C")
        else
            value:setColor("#C0C0C0")
        end
    end

    if widget.icon == 0 then
        if data.unlockPrice > UI.CharmsPoints then
            value:setColor("#D33C3C")
        else
            value:setColor("#C0C0C0")
        end
    end
end

-- function Cyclopedia.loadCharms(points, data, monsters)
function Cyclopedia.loadCharms(data2)
    if UI == nil or UI.CharmList == nil then -- I know, don't change it
        return
    end
    local points = data2.points
    local monsters = data2.finishedMonsters
    local data = data2.charms
    UI.CharmsPoints = points

    -- UI.CharmsBase.Value:setText(comma_value(points))
    -- UI.Bottombase.Cat3.CharmsBase.Value:setText(comma_value(points))
    -- UI.Bottombase.Cat6.CharmsBase.Value:setText(comma_value(points))

    local raceIdNamePairs = {}

    for _, raceId in ipairs(monsters) do
        table.insert(raceIdNamePairs, {
            raceId = raceId,
            name = RACE and RACE.name or "buscar_" .. raceId
        })
    end

    local function compareByName(a, b)
        return a.name:lower() < b.name:lower()
    end

    table.sort(raceIdNamePairs, compareByName)

    Cyclopedia.Charms.Monsters = {}

    for _, pair in ipairs(raceIdNamePairs) do
        table.insert(Cyclopedia.Charms.Monsters, pair.raceId)
    end

    UI.CharmList:destroyChildren()

    local formatedData = {}

    local function verify(id)
        for index, charm in ipairs(CHARMS) do
            if id == charm.ID then
                return index
            end
        end

        return nil
    end

    for _, charmData in pairs(data) do
        local internalId = verify(charmData.raceId)

        if internalId then
            charmData.internalId = internalId
            charmData.typePriority = CHARMS[internalId + 1].TYPE

            table.insert(formatedData, charmData)
        end
    end

    table.sort(formatedData, function(a, b)
        if a.unlocked == b.unlocked then
            if a.typePriority == b.typePriority then
                return a.name < b.name
            else
                return a.typePriority < b.typePriority
            end
        else
            return a.unlocked and not b.unlocked
        end
    end)

    for _, value in ipairs(formatedData) do
        Cyclopedia.CreateCharmItem(value)
    end

    if Cyclopedia.Charms.redirect then
        Cyclopedia.selectCharm(UI.CharmList:getChildById(Cyclopedia.Charms.redirect),
            UI.CharmList:getChildById(Cyclopedia.Charms.redirect):isChecked())

        Cyclopedia.Charms.redirect = nil
    else
        Cyclopedia.selectCharm(UI.CharmList:getChildByIndex(1), UI.CharmList:getChildByIndex(1):isChecked())
    end
end

function Cyclopedia.selectCharm(widget, isChecked)
    UI.InformationBase.CreaturesBase.CreatureList:destroyChildren()

    local parent = widget:getParent()
    local button = UI.InformationBase.UnlockButton
    local value = UI.InformationBase.PriceBase.Value

    UI.InformationBase.data = widget.data

    local function format(text)
        local capitalizedText = text:gsub("(%l)(%w*)", function(first, rest)
            return first:upper() .. rest
        end)

        if #capitalizedText > 19 then
            return capitalizedText:sub(1, 16) .. "..."
        else
            return capitalizedText
        end
    end

    for i = 1, parent:getChildCount() do
        local internalWidget = parent:getChildByIndex(i)

        if internalWidget:isChecked() and widget:getId() ~= internalWidget:getId() then
            internalWidget:setChecked(false)
        end
    end

    if not isChecked then
        widget:setChecked(true)
    end

    UI.InformationBase.TextBase:setText(widget.data.description)
    UI.InformationBase.ItemBase.image:setImageSource(widget.charmBase.image:getImageSource())

    if widget.data.hasCurrentCreature then
        UI.InformationBase.InfoBase.sprite:setVisible(true)
        UI.InformationBase.InfoBase.sprite:setOutfit(RACE[widget.data.raceId].outfit)
        UI.InformationBase.InfoBase.sprite:setAnimate(true)
        UI.InformationBase.InfoBase.sprite:setOpacity(1)
    else
        UI.InformationBase.InfoBase.sprite:setVisible(false)
    end

    if widget.icon == 1 then
        UI.InformationBase.PriceBase.Gold:setVisible(true)
        UI.InformationBase.PriceBase.Charm:setVisible(false)
    else
        UI.InformationBase.PriceBase.Gold:setVisible(false)
        UI.InformationBase.PriceBase.Charm:setVisible(true)
    end

    if widget.icon == 1 and UI.Balance then
        if widget.data.removeRuneCost > UI.Balance then
            value:setColor("#D33C3C")
            button:setEnabled(false)
        else
            value:setColor("#C0C0C0")
            button:setEnabled(true)
        end

        if widget.data.unlocked and not widget.data.hasCurrentCreature then
            value:setText(0)
        else
            value:setText(comma_value(widget.data.removeRuneCost))
        end
    end

    if widget.icon == 0 then
        if widget.data.unlockPrice > UI.CharmsPoints then
            value:setColor("#D33C3C")
            button:setEnabled(false)
        else
            value:setColor("#C0C0C0")
            button:setEnabled(true)
        end

        value:setText(widget.data.unlockPrice)
    end

    if widget.data.unlocked and not widget.data.hasCurrentCreature then
        button:setText("Select")

        local color = "#484848"

        for index, raceId in ipairs(Cyclopedia.Charms.Monsters) do
            local internalWidget = g_ui.createWidget("CharmCreatureName", UI.InformationBase.CreaturesBase.CreatureList)

            internalWidget:setId(index)
            internalWidget:setText(format(RACE[raceId].name))

            internalWidget.raceId = raceId

            internalWidget:setBackgroundColor(color)

            internalWidget.color = color
            color = color == "#484848" and "#414141" or "#484848"
        end

        button:setEnabled(false)
        UI.InformationBase.SearchEdit:setEnabled(true)
        UI.InformationBase.SearchLabel:setEnabled(true)
        UI.InformationBase.CreaturesLabel:setEnabled(true)
    end

    if widget.data.hasCurrentCreature then
        button:setText("Remove")

        local internalWidget = g_ui.createWidget("CharmCreatureName", UI.InformationBase.CreaturesBase.CreatureList)

        internalWidget:setText(format(RACE[widget.data.raceId].name))
        internalWidget:setEnabled(false)
        internalWidget:setColor("#707070")
        UI.InformationBase.SearchEdit:setEnabled(false)
        UI.InformationBase.SearchLabel:setEnabled(false)
        UI.InformationBase.CreaturesLabel:setEnabled(false)
    end

    if not widget.data.unlocked then
        button:setText("Unlock")
        UI.InformationBase.SearchEdit:setEnabled(false)
        UI.InformationBase.SearchLabel:setEnabled(false)
        UI.InformationBase.CreaturesLabel:setEnabled(false)
    end
end

function Cyclopedia.selectCreatureCharm(widget, isChecked)
    local parent = widget:getParent()

    for i = 1, parent:getChildCount() do
        local internalWidget = parent:getChildByIndex(i)

        if internalWidget:isChecked() and widget:getId() ~= internalWidget:getId() then
            internalWidget:setChecked(false)
            internalWidget:setBackgroundColor(internalWidget.color)
        end
    end

    if not isChecked then
        widget:setChecked(true)
    end

    UI.InformationBase.InfoBase.sprite:setVisible(true)
    UI.InformationBase.InfoBase.sprite:setOutfit(RACE[widget.raceId].outfit)
    UI.InformationBase.InfoBase.sprite:setAnimate(true)
    UI.InformationBase.InfoBase.sprite:setOpacity(0.5)
    UI.InformationBase.UnlockButton:setEnabled(true)

    Cyclopedia.Charms.SelectedCreature = widget.raceId
end

function Cyclopedia.searchCharmMonster(text)
    UI.InformationBase.CreaturesBase.CreatureList:destroyChildren()

    local function format(string)
        local capitalizedText = string:gsub("(%l)(%w*)", function(first, rest)
            return first:upper() .. rest
        end)

        if #capitalizedText > 19 then
            return capitalizedText:sub(1, 16) .. "..."
        else
            return capitalizedText
        end
    end

    local function getColor(currentColor)
        return currentColor == "#484848" and "#414141" or "#484848"
    end

    local searchedMonsters = {}

    if text ~= "" then
        for _, raceId in ipairs(Cyclopedia.Charms.Monsters) do
            local name = RACE[raceId].name

            if string.find(name:lower(), text:lower()) then
                table.insert(searchedMonsters, raceId)
            end
        end
    else
        searchedMonsters = Cyclopedia.Charms.Monsters
    end

    local color = "#484848"

    for _, raceId in ipairs(searchedMonsters) do
        local internalWidget = g_ui.createWidget("CharmCreatureName", UI.InformationBase.CreaturesBase.CreatureList)

        internalWidget:setId(raceId)
        internalWidget:setText(format(RACE[raceId].name))

        internalWidget.raceId = raceId

        internalWidget:setBackgroundColor(color)

        internalWidget.color = color
        color = getColor(color)
    end
end

function Cyclopedia.actionCharmButton(widget)
    local confirmWindow
    local type = widget:getText()
    local data = widget:getParent().data

    if type == "Unlock" then
        local function yesCallback()
            g_game.requestUnlockCharm(data.id)

            if confirmWindow then
                confirmWindow:destroy()

                confirmWindow = nil

                Cyclopedia.Toggle(true, false, 3)
            end

            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()

                confirmWindow = nil

                Cyclopedia.Toggle(true, false, 3)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("Confirm Unlocking of Charm"), tr(
                "Do you want to unlock the Charm %s? This will cost you %d Charm Points?", data.name, data.unlockPrice),
                {
                    {
                        text = tr("Yes"),
                        callback = yesCallback
                    },
                    {
                        text = tr("No"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    if type == "Select" then
        local function yesCallback()
            g_game.requestSelectCharm(data.id, Cyclopedia.Charms.SelectedCreature)

            if confirmWindow then
                confirmWindow:destroy()

                confirmWindow = nil

                Cyclopedia.Toggle(true, false, 3)
            end

            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()

                confirmWindow = nil

                Cyclopedia.Toggle(true, false, 3)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("Confirm Selected Charm"),
                tr("Do you want to use the Charm %s for this creature?", data.name), {
                    {
                        text = tr("Yes"),
                        callback = yesCallback
                    },
                    {
                        text = tr("No"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end

    if type == "Remove" then
        local function yesCallback()
            g_game.requestRemoveCharm(data.id)

            if confirmWindow then
                confirmWindow:destroy()

                confirmWindow = nil

                Cyclopedia.Toggle(true, false, 3)
            end

            Cyclopedia.Charms.redirect = data.id
        end

        local function noCallback()
            if confirmWindow then
                confirmWindow:destroy()

                confirmWindow = nil

                Cyclopedia.Toggle(true, false, 3)
            end
        end

        if not confirmWindow then
            confirmWindow = displayGeneralBox(tr("Confirm Charm Removal"),
                tr("Do you want to remove the Charm %s from this creature? This will cost you %s gold pieces.",
                    data.name, comma_value(data.removeRuneCost)), {
                    {
                        text = tr("Yes"),
                        callback = yesCallback
                    },
                    {
                        text = tr("No"),
                        callback = noCallback
                    },
                    anchor = AnchorHorizontalCenter
                }, yesCallback, noCallback)

            Cyclopedia.Toggle(true, false)
        end
    end
end


