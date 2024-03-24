bot = getBot()
bot.move_range = move_range
bot.move_interval = move_interval
bot.collect_interval = 100
bot.auto_collect = false
bot.auto_reconnect = true
bot.reconnect_interval = 30
bot.collect_range = 3
bot.legit_mode = show_animation

mode2Tile = {1,2}
mode3Tile = {0,1,2}
startTime = os.time()
worldNuked = false
warpAttempt = 0
trashList = {2, 3, 14, 15, 10, 11, 4, 5}
putPlat = false
emptyTile = 0
fillDirtWh = false

tileYList = {}
platYList = {}
selectedBot = {}
botTileY = {}
placeYList = {}
botPlaceY = {}

waktu = {}

sleep(bot.index*2500)

for i = 25, 53, 2 do
    table.insert(tileYList, i)
end

for i = 22, 2, -2 do
    table.insert(placeYList, i)
end

for i = 52, 2, -2 do
    table.insert(platYList, i)
end

for _, botz in pairs(getBots()) do
    if botz.selected then
        table.insert(selectedBot, botz)
    end
end

sleep(100)

for i, botz in pairs(selectedBot) do
    if botz.name:upper() == bot.name:upper() then
        indexBot = i
    end
end

botTileY[indexBot] = {}
botPlaceY[indexBot] = {}

if multi_bots then
    for i, botz in pairs(selectedBot) do
        if botz.name:upper() == bot.name:upper() then
            if i == 1 or i == 2 then
                putPlat = true
            end
    
            if i%2 == 0 then
                if use_platform then
                    botSideX = {0, 1}
                else
                    botSideX = {0}
                end
                botPlatX = 1
            else
                if use_platform then
                    botSideX = {98, 99}
                else
                    botSideX = {99}
                end
                botPlatX = 98
            end
        end

    end

    for i = indexBot, #tileYList, #selectedBot do
        table.insert(botTileY[indexBot], tileYList[i])
    end
    
    for i = indexBot, #placeYList, #selectedBot do
        table.insert(botPlaceY[indexBot], placeYList[i])
    end
    
else

    for _, ye in pairs(tileYList) do
        table.insert(botTileY[indexBot], ye)
    end
    
    for _, ye in pairs(placeYList) do
        table.insert(botPlaceY[indexBot], ye)
    end

    if use_platform then
        botSideX = {0, 1}
        botSideX2 = {98, 99}
    else
        botSideX = {0}
        botSideX2 = {99}
    end

    botPlatX = 1
    botPlatX2 = 98
    putPlat = true

end

-- print(bot.name:upper().." Tile Y:")
-- print(table.concat(botTileY[indexBot], ", "))

-- print(bot.name:upper().." Side X:")
-- print(table.concat(botSideX, ", "))

-- print(bot.name:upper().." Place Y:")
-- print(table.concat(botPlaceY[indexBot], ", "))

if use_platform then
    plat_storageWorld, plat_storageDoorID = plat_storage:upper():match("([^|]+)|([^|]+)")
    -- print(plat_storageWorld, plat_storageDoorID)
end
if save_seed then
    seed_storageWorld, seed_storageDoorID = seed_storage:upper():match("([^|]+)|([^|]+)")
    -- print(seed_storageWorld, seed_storageDoorID)
end
if take_pexe then
    pexe_storageWorld, pexe_storageDoorID = pexe_storage:upper():match("([^|]+)|([^|]+)")
    -- print(pexe_storageWorld, pexe_storageDoorID)
end

for _, list in pairs(world_dirtfarm) do
    print(list)
end
math.randomseed(os.time())
-- ==============
function callWebhook()
    local mainWebhook = Webhook.new(link_webhook)
	mainWebhook.username = "Cema Bot"

    mainWebhook.avatar_url = "https://cdn.discordapp.com/attachments/1219232194493550692/1219235041704415242/WhatsApp_Image_2024-03-15_at_06.13.30_90fe0da4.jpg?ex=660a901e&is=65f81b1e&hm=7ee2b41fa07847748bea77ffe01988bec28ceab26d4f32e83afc0fdad33ba83f&"
    mainWebhook.embed1.use = true

    mainWebhook.embed1.title = "**CEMA STORE | AUTO DIRT FARM V1.0**"
    mainWebhook.embed1.color = math.random(1,9999)
    mainWebhook.embed1.description = "Updated <t:".. os.time() ..":R>"
    mainWebhook.embed1:addField("<:botlucu:1213053390570004490> total_bot [".. #selectedBot .."]"
    ,getBotList()
    ,false)
    mainWebhook.embed1:addField("<:GLOBE:1196789499930361936>total_world [".. #world_dirtfarm .."]",getWorldList(),false)
    mainWebhook.embed1:addField("",":clock12: **up_time**: ".. getUptime(),false)
    mainWebhook.embed1.footer.text = os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60)
    if link_webhook_message_id ~= "" then
        mainWebhook:edit(link_webhook_message_id)
    else
        mainWebhook:send()
    end
end


function callAlert(msg)
    local mainEvent = Webhook.new(link_webhook)
    mainEvent.content = "@everyone **".. bot.name:upper().."** "
    mainEvent.embed1.use = true
    mainEvent.embed1.color = 16711680
    mainEvent.embed1.description = msg
    mainEvent:send()
end

function getStatus(stat)
    local online = "<a:onlinegif:1179100715747131474>"
    local offline = "<a:offlinegif:1179100927345561620>"
    if stat == BotStatus.online then
        return online
    else
        return offline
    end
end

function getBotList()
    local desc = ""
    for _, botz in pairs(selectedBot) do
        desc = desc .. botz.name:upper() .. " [".. botz.level .."] " .. getStatus(botz.status) .. "\n"
    end
    return desc
end

function getWorldList()
    local desc = ""
    for _, worldz in pairs(world_dirtfarm) do
        wlist, wdoor = worldz:upper():match("([^|]+)|([^|]+)")
        if wlist == dfWorld:upper() then
            desc = desc .."<a:PANAH2:1209836286282571817> **".. wlist:upper() .. waktu[wlist] .. "**\n"
        elseif waktu[wlist] then
            desc = desc .."- ".. wlist:upper() .. waktu[wlist] .. "\n"
        else
            desc = desc .."- ".. wlist:upper() .. "\n"
        end
    end
    return desc
end


function getUptime()
    local elapsedTime = os.time() - startTime
    return string.format("%dd %02dh %02dm", math.floor(elapsedTime / 86400), math.floor((elapsedTime % 86400) / 3600), math.floor((elapsedTime % 3600) / 60))
end

function findItem(id)
    return bot:getInventory():findItem(id)
end

function gscanFloat(id)
    return bot:getWorld().growscan:getObjects()[id] or 0
end

function gscanBlock(id)
    return bot:getWorld().growscan:getTiles()[id] or 0
end

function round(n)
    return n % 1 > 0.5 and math.ceil(n) or math.floor(n)
end

function tileDrop(x,y,num)
    local count = 0
    local stack = 0
    for _,obj in pairs(bot:getWorld():getObjects()) do
        if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    if stack < 20 and count <= (4000 - num) then
        return true
    end
    return false
end

function checkNuked(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        if variant:get(1):getString():find("That world is inaccessible") then
            worldNuked = true
        end
    end
end

function warps(worldName, doorID)
    worldNuked = false
    warpAttempt = 0
    addEvent(Event.variantlist, checkNuked)
    while bot:getWorld().name:upper() ~= worldName:upper() and not worldNuked do
        print(bot.name:upper().." | Warping to "..worldName)
        if bot.status == BotStatus.online and bot:getPing() == 0 then
            bot:disconnect()
            sleep(2000)
        end

        while bot.status ~= BotStatus.online do
            sleep(1000)
            while bot.status == BotStatus.account_banned do
                sleep(8000)
            end
        end

        if doorID ~= "" then
            bot:warp(worldName, doorID)
        else
            bot:warp(worldName)
        end

        listenEvents(math.floor(6000/1000))

        if warpAttempt == 5 then
            warpAttempt = 0
            callAlert("hard_warp trigger")
            sleep(1 * 60000)
            if bot:getWorld().name:upper() ~= worldName:upper() then
                bot:disconnect()
                sleep(1000)
                while bot.status ~= BotStatus.online do
                    sleep(1000)
                end
            end
        else
            warpAttempt = warpAttempt + 1
        end
    end

    if worldNuked then
        callAlert(worldName.." nuked")
    end
    
    if doorID ~= "" and getTile(bot.x, bot.y).fg == 6 then
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(1000)
            while bot.status == BotStatus.account_banned do
                callAlert(bot.name.." banned")
                bot.auto_reconnect = false
                bot:stopScript()
            end
        end
        for i = 1,3 do
            if getTile(bot.x,bot.y).fg == 6 then
                bot:warp(worldName, doorID)
                sleep(2000)
            end
        end
        if getTile(bot.x,bot.y).fg == 6 then
            callAlert("world : "..worldName.." wrong_door_id : "..doorID)
            sleep(100)
            worldNuked = true
        end
    end
    sleep(100)
    removeEvent(Event.variantlist)
end

function reconnect(worldName, doorID, posX, posY)
    if bot.status ~= BotStatus.online then
        callAlert("reconnect")
        callWebhook()
        sleep(100)
        while bot.status ~= BotStatus.online do
            sleep(1000)
            if bot.status == BotStatus.account_banned then
                callAlert(bot.name .. " banned")
                bot.auto_reconnect = false
                bot:stopScript()
            end
        end

        while findItem(9640) > 0 do
            sleep(1000)
        end
        
        warpingBackAttempt = 0
        while not bot:isInWorld(worldName:upper()) do
            bot:warp(worldName)
            sleep(6000)
            if warpingBackAttempt == 5 then
                warpingBackAttempt = 0
                sleep(1 * 60000)
            else
                warpingBackAttempt = warpingBackAttempt + 1
            end
        end
        if doorID ~= "" and getTile(bot.x, bot.y).fg == 6 then
            bot:warp(worldName, doorID)
            sleep(3000)
        end
        if posX and posY and not bot:isInTile(posX, posY) then
            sleep(300)
            bot:findPath(posX, posY)
            sleep(200)
        end
    end

end

function takePickaxe()
    bot.auto_collect = false
    bot.collect_interval = 100
    warps(pexe_storageWorld, pexe_storageDoorID)
    if not worldNuked and bot:isInWorld(pexe_storageWorld:upper()) then
        for _, obj in pairs(getObjects()) do
            if obj.id == 98 then
                bot:findPath(math.floor(obj.x/32), math.floor(obj.y/32))
                bot:collectObject(obj.oid, 4)
                sleep(300)
                reconnect(pexe_storageWorld, pexe_storageDoorID)
            end
            if findItem(98) > 0 then
                break
            end
        end

        while findItem(98) > 1 do
            bot:moveRight()
            sleep(100)
            bot:setDirection(true)
            sleep(100)
            bot:fastDrop(98, findItem(98)-1)
            sleep(500)
            reconnect(pexe_storageWorld, pexe_storageDoorID)
        end

        if findItem(98) == 1 then
            if not bot:getInventory():getItem(98).isActive then
                bot:wear(98)
                sleep(400)
            end
        else
            callAlert("pick_empty")
        end
        
    end
end

function dropTrash()
    bot.auto_collect = false
    bot.collect_interval = 60000
    warps(seed_storageWorld, seed_storageDoorID)
    if not worldNuked and bot:isInWorld(seed_storageWorld:upper()) then
        ye = bot.y
        for _, tile in pairs(getTiles()) do
            if tile.y == ye and tile.x > bot.x and tileDrop(tile.x, tile.y, 200) then
                bot:findPath(tile.x-1, tile.y)
                sleep(100)
                bot:setDirection(false)
                sleep(100)
                if bot:isInTile(tile.x-1, tile.y) then
                    for _, trash in pairs(trashList) do
                        if findItem(trash) > 0 then
                            bot:fastDrop(trash, findItem(trash))
                            sleep(400)
                            reconnect(seed_storageWorld, seed_storageDoorID, tile.x-1, tile.y)
                            while findItem(trash) > 0 and #bot:getPath(bot.x+1, bot.y) > 0 do
                                bot:moveRight()
                                sleep(100)
                                bot:fastDrop(trash, findItem(trash))
                                sleep(400)
                                reconnect(seed_storageWorld, seed_storageDoorID, tile.x-1, tile.y)
                            end
                        end
                    end
                end
                break
            end
        end
    end
    bot.collect_interval = 100
end

function takeItem(itemID, amount, worldName, doorID)
    bot.auto_collect = false
    bot.collect_interval = 100
    warps(worldName, doorID)
    if not worldNuked and bot:isInWorld(worldName:upper()) then
        for _, obj in pairs(getObjects()) do
            reconnect(worldName, doorID)
            if obj.id == itemID then
                if #bot:getPath(math.floor(obj.x / 32),math.floor(obj.y / 32)) > 0 then
                    bot:findPath(math.floor(obj.x / 32),math.floor(obj.y / 32))
                    sleep(100)
                end
                bot:collectObject(obj.oid, 4)
                sleep(500)
                reconnect(worldName, doorID)
            end
            if findItem(itemID) >= amount then
                break
            end
        end
    
        while findItem(itemID) > amount and getTile(bot.x+1, bot.y).fg == 0 do
            bot:setDirection(false)
            bot:drop(itemID, findItem(itemID)-amount)
            sleep(500)
            if findItem(itemID) > amount and getTile(bot.x+1, bot.y).fg == 0 then
                bot:moveRight()
                sleep(100)
            end
            reconnect(worldName, doorID)
        end

        if not fillDirtWh then
            if findItem(itemID) < amount then
                callAlert("need : "..getInfo(itemID).name)
            end
        end
        
    end
end

function checkTrash()
    for _, trash in pairs(trashList) do
        if findItem(trash) > 150 then
            return true
        end
    end
    return false
end

function trashJunk()
    if checkTrash() then
        if save_seed then
            dropTrash()
        else
            for _, trash in pairs(trashList) do
                bot:fastTrash(trash, findItem(trash))
                sleep(350)
            end
        end
    end
end

function clearSide()
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        bot.auto_collect = true
        bot.collect_interval = 100
        for ye = 24, 53 do
            reconnect(dfWorld, dfDoorID)
            for _, ex in pairs(botSideX) do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye).fg ~= id_platform then
                    if getTile(ex, ye).fg ~= 0 or getTile(ex, ye).bg ~= 0 and hasAccess(ex, ye) and #bot:getPath(ex, ye-1) > 0 then
                        if #bot:getPath(ex, ye-1) > 5 then
                            bot:findPath(ex, ye-1)
                        else
                            bot:moveTile(ex, ye-1)
                        end
    
                        if bot:isInTile(ex, ye-1) then
                            for _, i in pairs(mode2Tile) do
                                if getTile(bot.x, bot.y+i).fg ~= 8 then
                                    while getTile(bot.x, bot.y+i).fg ~= 0 or getTile(bot.x, bot.y+i).bg ~= 0 and hasAccess(bot.x, bot.y+i) > 0 and bot:isInTile(ex, ye-1) do
                                        bot:hit(bot.x, bot.y+i)
                                        sleep(delay_break)
                                        reconnect(dfWorld, dfDoorID, ex, ye-1)
                                    end
                                end
                            end
                        end

                        trashJunk()
                        if bot:getWorld().name ~= dfWorld:upper() then
                            warps(dfWorld, dfDoorID)
                            bot.auto_collect = true
                            bot.collect_interval = 100
                        end

                    end
                end
            end
        end

        if not multi_bots then
            for ye = 24, 53 do
                reconnect(dfWorld, dfDoorID)
                for _, ex in pairs(botSideX2) do
                    reconnect(dfWorld, dfDoorID)
                    if getTile(ex, ye).fg ~= id_platform then
                        if getTile(ex, ye).fg ~= 0 or getTile(ex, ye).bg ~= 0 and hasAccess(ex, ye) and #bot:getPath(ex, ye-1) > 0 then
                            if #bot:getPath(ex, ye-1) > 5 then
                                bot:findPath(ex, ye-1)
                            else
                                bot:moveTile(ex, ye-1)
                            end
        
                            if bot:isInTile(ex, ye-1) then
                                for _, i in pairs(mode2Tile) do
                                    if getTile(bot.x, bot.y+i).fg ~= 8 then
                                        while getTile(bot.x, bot.y+i).fg ~= 0 or getTile(bot.x, bot.y+i).bg ~= 0 and hasAccess(bot.x, bot.y+i) > 0 and bot:isInTile(ex, ye-1) do
                                            bot:hit(bot.x, bot.y+i)
                                            sleep(delay_break)
                                            reconnect(dfWorld, dfDoorID, ex, ye-1)
                                        end
                                    end
                                end
                            end
                            
                        end
                    end
                end
            end
        end

    end
end

function clearRow()
    local webhuk = false
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        bot.auto_collect = true
        bot.collect_interval = 100
        for _, ye in pairs(botTileY[indexBot]) do
            reconnect(dfWorld, dfDoorID)
            for ex = 1, 99 do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye).fg %2 == 0 then
                    if getTile(ex, ye).fg ~= 0 or getTile(ex, ye).bg ~= 0 and #bot:getPath(ex, ye) > 0 and hasAccess(ex, ye) > 0 then
                        webhuk = true
                        while getTile(ex-1, ye).fg ~= 0 do
                            sleep(1000)
                        end
                        if #bot:getPath(ex-1, ye) > 5 then
                            bot:findPath(ex-1, ye)
                        else
                            bot:moveTile(ex-1, ye)
                        end
    
                        if bot:isInTile(ex-1, ye) then
                            for _, i in pairs(mode2Tile) do
                                if bot:getWorld():isValidPosition((bot.x+i)*32, bot.y*32) then
                                    while getTile(bot.x+i, bot.y).fg ~= 0 or getTile(bot.x+i, bot.y).bg ~= 0 and bot:isInTile(ex-1, ye) and hasAccess(bot.x+i, bot.y) do
                                        bot:hit(bot.x+i, bot.y)
                                        sleep(delay_break)
                                        reconnect(dfWorld, dfDoorID, ex-1, ye)
                                    end
                                end
                            end
    
                            if rock_clear then
                                for _, i in pairs(mode2Tile) do
                                    if getTile(bot.x+i, bot.y-1).fg == 10 then
                                        while getTile(bot.x+i, bot.y-1).fg ~= 0 and bot:isInTile(ex-1, ye) and hasAccess(bot.x+i, bot.y) do
                                            bot:hit(bot.x+i, bot.y-1)
                                            sleep(delay_break)
                                            reconnect(dfWorld, dfDoorID, ex-1, ye)
                                        end
                                    end
                                end
                            end
                            
                            if lava_clear then
                                for _, i in pairs(mode2Tile) do
                                    if getTile(bot.x+i, bot.y-1).fg == 4 then
                                        while getTile(bot.x+i, bot.y-1).fg ~= 0 and bot:isInTile(ex-1, ye) and hasAccess(bot.x+i, bot.y) do
                                            bot:hit(bot.x+i, bot.y-1)
                                            sleep(delay_break)
                                            reconnect(dfWorld, dfDoorID, ex-1, ye)
                                        end
                                    end
                                end
                            end
                            
                        end
                        sleep(200)
                    end
                end
            end
            trashJunk()
            if bot:getWorld().name ~= dfWorld:upper() then
                warps(dfWorld, dfDoorID)
                bot.auto_collect = true
                bot.collect_interval = 100
            end
            if webhuk then
                callWebhook()
            end
        end
    end
end

function isPlantable(x,y)
    local tempTile = getTile(x,y + 1)
    if not tempTile.fg then return false end
    local collision = getInfo(tempTile.fg).collision_type
    return tempTile and ( collision == 1 or collision == 2 or collision == 4)
end

function readyTreeScan()
    local totalTree = 0
    for _, ye in pairs(botTileY[indexBot]) do
        for ex = 2, 22 do
            if getTile(ex, ye).fg == 3 and getTile(ex, ye):canHarvest() and hasAccess(ex, ye) > 0 then
                totalTree = totalTree + 1
            end
        end
    end
    return totalTree
end

function emptyTileScan()
    local totalEmpty = 0
    for _, ye in pairs(botTileY[indexBot]) do
        for ex = 2, 22 do
            if getTile(ex, ye).fg == 0 and isPlantable(ex, ye) and hasAccess(ex, ye) > 0 then
                totalEmpty = totalEmpty + 1
            end
        end
    end
    return totalEmpty
end

function harvestDirt()
    if bot:isInWorld(dfWorld:upper()) then
        print(bot.name:upper().." | Harvesting Dirt")
        bot.auto_collect = true
        bot.collect_interval = 100
        for _, ye in pairs(botTileY[indexBot]) do
            reconnect(dfWorld, dfDoorID)
            for ex = 2, 22 do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye):canHarvest() and getTile(ex, ye).fg == 3 and hasAccess(ex, ye) > 0 and findItem(2) < 190 then
                    if #bot:getPath(ex, ye) > 5 then
                        bot:findPath(ex, ye)
                    else
                        bot:moveTile(ex, ye)
                    end
                    if bot:isInTile(ex, ye) then
                        for _, m in pairs(mode3Tile) do
                            while getTile(bot.x+m, bot.y).fg == 3 and getTile(bot.x+m, bot.y):canHarvest() and hasAccess(bot.x+m, bot.y) > 0 do
                                bot:hit(bot.x+m, bot.y)
                                sleep(120)
                                reconnect(dfWorld, dfDoorID, ex, ye)
                            end
                        end
                    end
                end
            end
        end
    end
end

function plantDirt()
    if findItem(3) < 50 and save_seed then
        takeItem(3, 75, seed_storageWorld, seed_storageDoorID)
        warps(dfWorld, dfDoorID)
        if worldNuked then
            bot:stopScript()
        end
    end
    if bot:isInWorld(dfWorld:upper()) then
        for _, ye in pairs(botTileY[indexBot]) do
            reconnect(dfWorld, dfDoorID)
            for ex = 2, 22 do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye).fg == 0 and isPlantable(ex, ye) and hasAccess(ex, ye) > 0 and findItem(3) > 0 then
                    if #bot:getPath(ex, ye) > 5 then
                        bot:findPath(ex, ye)
                    else
                        bot:moveTile(ex, ye)
                    end
                    if bot:isInTile(ex, ye) then
                        for _, m in pairs(mode3Tile) do
                            while getTile(bot.x+m, bot.y).fg == 0 and isPlantable(ex, ye) and hasAccess(bot.x+m, bot.y) > 0 and findItem(3) > 0 and getTile(bot.x+m, bot.y).x < 22 do
                                bot:place(bot.x+m, bot.y, 3)
                                sleep(140)
                                reconnect(dfWorld, dfDoorID, ex, ye)
                            end
                        end
                    end
                end
            end
        end
    end
end

function farmDirt()
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        callWebhook()
        bot.auto_collect = true
        bot.collect_interval = 100
        
        if readyTreeScan() > 0 then
            harvestDirt()
        else
            plantDirt()
            while readyTreeScan() == 0 do
                sleep(15000)
            end
            harvestDirt()
        end
        
    end
end

function fillDirt()
    if use_platform then
        fillDirtX1, fillDirtX2 = 2, 97
    else
        fillDirtX1, fillDirtX2 = 1, 98
    end

    if findItem(2) < 200 and save_seed then
        fillDirtWh = true
        takeItem(2, 200, seed_storageWorld, seed_storageDoorID)
        fillDirtWh = false
    end

    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        bot.auto_collect = true
        bot.collect_interval = 100
        for _, ye in pairs(botTileY[indexBot]) do
            reconnect(dfWorld, dfDoorID)
            for ex = fillDirtX1, fillDirtX2 do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye-1).fg == 0 and hasAccess(ex, ye-1) then
                    if findItem(2) < 1 then
                        farmDirt()
                    end

                    if #bot:getPath(ex, ye) > 5 then
                        bot:findPath(ex, ye)
                    else
                        bot:moveTile(ex, ye)
                    end

                    if bot:isInTile(ex, ye) then
                        while getTile(bot.x, bot.y-1).fg == 0 and findItem(2) > 0 and hasAccess(bot.x, bot.y-1) do
                            bot:place(bot.x, bot.y-1, 2)
                            sleep(delay_place)
                            reconnect(dfWorld, dfDoorID, ex, ye)
                        end
                    end
                    
                end
            end
        end
    end
end

function placePlat()
    if multi_bots then
        while findItem(id_platform) < 26 and putPlat do
            takeItem(id_platform, 26, plat_storageWorld, plat_storageDoorID)
        end
    else
        while findItem(id_platform) < 52 and putPlat do
            takeItem(id_platform, 52, plat_storageWorld, plat_storageDoorID)
        end
    end
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        if findItem(id_platform) > 0 then
            for _, ye in pairs(platYList) do
                reconnect(dfWorld, dfDoorID)
                if getTile(botPlatX, ye).fg == 0 and hasAccess(botPlatX, ye) > 0 and findItem(id_platform) > 0 then
                    if #bot:getPath(botPlatX, ye-1) > 5 then
                        bot:findPath(botPlatX, ye-1)
                    else
                        bot:moveTile(botPlatX, ye-1)
                    end
                    if bot:isInTile(botPlatX, ye-1) then
                        while getTile(bot.x, bot.y+1).fg == 0 and hasAccess(bot.x, bot.y+1) > 0 and findItem(id_platform) > 0 do
                            bot:place(bot.x, bot.y+1, id_platform)
                            sleep(delay_place)
                            reconnect(dfWorld, dfDoorID, botPlatX, ye-1)
                        end
                    end
                end
            end

            if not multi_bots then
                for _, ye in pairs(platYList) do
                    reconnect(dfWorld, dfDoorID)
                    if getTile(botPlatX2, ye).fg == 0 and hasAccess(botPlatX2, ye) > 0 and findItem(id_platform) > 0 then
                        if #bot:getPath(botPlatX2, ye-1) > 5 then
                            bot:findPath(botPlatX2, ye-1)
                        else
                            bot:moveTile(botPlatX2, ye-1)
                        end
                        if bot:isInTile(botPlatX2, ye-1) then
                            while getTile(bot.x, bot.y+1).fg == 0 and hasAccess(bot.x, bot.y+1) > 0 and findItem(id_platform) > 0 do
                                bot:place(bot.x, bot.y+1, id_platform)
                                sleep(delay_place)
                                reconnect(dfWorld, dfDoorID, botPlatX2, ye-1)
                            end
                        end
                    end
                end
            end

        end
    end
end

function placeDirt()
    local webhuk = false
    if use_platform then
        placeDirtX1, placeDirtX2 = 2, 97
    else
        placeDirtX1, placeDirtX2 = 1, 98
    end
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        for _, ye in pairs(botPlaceY[indexBot]) do
            reconnect(dfWorld, dfDoorID)
            for ex = placeDirtX1, placeDirtX2 do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye).fg == 0 and hasAccess(ex, ye) > 0 then
                    if findItem(2) < 1 then
                        farmDirt()
                    end

                    if #bot:getPath(ex, ye-1) > 5 then
                        bot:findPath(ex, ye-1)
                    else
                        bot:moveTile(ex, ye-1)
                    end
                    webhuk = true
                    if bot:isInTile(ex, ye-1) then
                        for _, m in pairs(mode3Tile) do
                            while getTile(bot.x+m, bot.y+1).fg == 0 and hasAccess(bot.x+m, bot.y+1) > 0 and findItem(2) > 0 and getTile(bot.x+m, bot.y+1).x <= placeDirtX2 do
                                bot:place(bot.x+m, bot.y+1, 2)
                                sleep(delay_place)
                                reconnect(dfWorld, dfDoorID, ex, ye-1)
                            end
                        end
                    end
                    
                end
            end
            if webhuk then
                callWebhook()
            end
        end
    end
end

function clearDirt()
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        bot.auto_collect = true
        bot.collect_interval = 100
        for _, ye in pairs(botTileY[indexBot]) do
            reconnect(dfWorld, dfDoorID)
            for ex = 2, 22 do
                reconnect(dfWorld, dfDoorID)
                if getTile(ex, ye):canHarvest() and getTile(ex, ye).fg == 3 and hasAccess(ex, ye) > 0 then
                    if findItem(2) > 150 then
                        bot:fastTrash(2, findItem(2))
                        sleep(350)
                    end

                    if findItem(3) > 150 then
                        bot:fastTrash(3, findItem(3))
                        sleep(350)
                    end
                    
                    if #bot:getPath(ex, ye) > 5 then
                        bot:findPath(ex, ye)
                    else
                        bot:moveTile(ex, ye)
                    end
                    if bot:isInTile(ex, ye) then
                        for _, m in pairs(mode3Tile) do
                            while getTile(bot.x+m, bot.y).fg == 3 and getTile(bot.x+m, bot.y):canHarvest() and hasAccess(bot.x+m, bot.y) > 0 do
                                bot:hit(bot.x+m, bot.y)
                                sleep(140)
                                reconnect(dfWorld, dfDoorID, ex, ye)
                            end
                        end
                    end
                end
            end
        end
        
    end
end

function clearFloating()
    warps(dfWorld, dfDoorID)
    if not worldNuked and bot:isInWorld(dfWorld:upper()) then
        bot.auto_collect = false
        bot.collect_interval = 100
        for _, obj in pairs(getObjects()) do
            if #bot:getPath(math.floor(obj.x/32), math.floor(obj.y/32)) > 0 then
                bot:findPath(math.floor(obj.x/32), math.floor(obj.y/32))
                bot:collect(3)
                sleep(350)
                if findItem(obj.id) > 150 then
                    bot:fastTrash(obj.id, findItem(obj.id))
                    sleep(350)
                end
                reconnect(dfWorld, dfDoorID)
            end
        end
        
    end
end

function main()
    for _, list in pairs(world_dirtfarm) do
        dfWorld, dfDoorID = list:upper():match("([^|]+)|([^|]+)")
        startDf = os.time()
        waktu[dfWorld] = " [?]"
        callWebhook()
        while findItem(98) ~= 1 and take_pexe do
            takePickaxe()
            sleep(2500)
        end
        clearSide()
        sleep(100)
        if putPlat and use_platform then
            placePlat()
        end
        clearRow()
        sleep(100)
        fillDirt()
        sleep(100)
        placeDirt()
        sleep(100)
        clearDirt()
        clearFloating()
        sleep(100)
        
        elapsedTime = os.time() - startDf
        waktu[dfWorld] = " [done "..math.floor(elapsedTime / 3600) .. "hour ".. math.floor((elapsedTime % 3600) / 60) .."minute]"
        sleep(1000)
        callWebhook()
    end
    bot.auto_reconnect = false
    sleep(100)
    bot:disconnect()
    sleep(100)
    bot:stopScript()
end

--// LISENCE CONF
function getMachineGUID()
    local cmd = io.popen(
        'powershell -command "$MachineGUID = (Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\Microsoft\\Cryptography\").MachineGuid; $MachineGUID"')
    local machineGUID = cmd:read("*l")
    cmd:close()
    return machineGUID
end


function getMachineGUID()
    local cmd = io.popen('powershell -command "$MachineGUID = (Get-ItemProperty -Path \"HKLM:\\SOFTWARE\\Microsoft\\Cryptography\").MachineGuid; $MachineGUID"')
    local machineGUID = cmd:read("*l")
    cmd:close()
    return machineGUID
end

function request(method, URL)
    local client = HttpClient.new()
    if method:upper() == "POST" then
        client.method = Method.post
    elseif method:upper() == "GET" then
        client.method = Method.get
    elseif method:upper() == "DELETE" then
        client.method = Method.delete
    elseif method:upper() == "PATCH" then
        client.method = Method.patch
    else
        return "Unknown method used"
    end

    client.url = URL
    response = client:request()
    return response.body
end

local jsonString = request("POST","http://game2.jagoanvps.cloud:5028/gt/loginlua?username="..username.."&password="..password.."&mac="..getMachineGUID())

local responsePattern = '"response":"(.-)"'
local messagePattern = '"message":"(.-)"'

local response = jsonString:match(responsePattern)
local message = jsonString:match(messagePattern)

if response and message then
    -- Print values
    print("Status: " .. response)
    print("Message: " .. message)

    if response == "success" then
        delay(1000)
        main()
    else
    print("ERROR REGISTER")
    end
end
