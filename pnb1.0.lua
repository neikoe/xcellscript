function getUptime()
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local days = math.floor(elapsedTime / 86400)
    local hours = math.floor((elapsedTime % 86400) / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    return string.format("%dd %02dh %02dm", days, hours, minutes)
end

function callWebhook(blocks, seeds, pack, gems)
    local wh = Webhook.new(mainWebhookUrl)
    wh.username = "Xcell"
    wh.avatar_url = "https://media.discordapp.net/attachments/1200237439801905173/1201034718787944558/XcellLogos.png"
    wh.embed1.use = true
    wh.embed1.author.name = "Xcell Pnb V1.0"
    wh.embed1.author.url = "https://discord.gg/"
    wh.embed1.color = 65280
    local desc = ""
    for _, botz in pairs(getBots()) do
        if botz.selected == true then
            desc = desc .. ":farmer: "..botz.name:upper().." [**"..botz.level.."**] ".. getStatus(botz.status).."\n"
        end
    end
    
    wh.embed1.description = desc

    if blocks then
        totalBlock = blocks
    end

    if seeds then
        totalSeed = seeds
    end

    if pack then
        totalPack = pack
    end

    if gems then
        totalGems = gems
    end

    wh.embed1:addField("Details",blockIcon .. " Total Block: " .. totalBlock .. "\n".. seedIcon .. " Seed Dropped: ".. totalSeed.. "\n:package: Pack Dropped: ".. totalPack.. "\n:gem: Gems Break: ".. totalGems.. "\n\nUptime: ".. getUptime(), true)
    wh.embed1.footer.text = os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60)
    if editMessage == true then
        wh:edit(messageID)
    else
        wh:send()
    end
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

function callAlert(msg)
    local wh = Webhook.new(eventWebhookUrl)
    wh.username = "Xcell"
    wh.avatar_url = "https://media.discordapp.net/attachments/1200237439801905173/1201034718787944558/XcellLogos.png"
    wh.content = "@everyone"
    wh.embed1.use = true
    wh.embed1.color = 16711680
    wh.embed1.description = "<a:offlinegif:1179100927345561620> ".. msg
	wh:send()
end

function callEvent(msg)
    local wh = Webhook.new(eventWebhookUrl)
    wh.username = "Xcell"
    wh.avatar_url = "https://media.discordapp.net/attachments/1200237439801905173/1201034718787944558/XcellLogos.png"
    wh.embed1.use = true
    wh.embed1.color = 16776960 
    wh.embed1.description = "<a:alerts:1186548719324250132> ".. msg
    wh:send()
end

for _, botz in pairs(getBots()) do
    if botz.selected then
        table.insert(selectedBot, botz)
    end
end

for i, botz in pairs(selectedBot) do
    if botz.name:upper() == bot.name:upper() then
        botIndex = i
    end
end

for i = math.floor(breakTile/2),1,-1 do
    i = i * -1
    table.insert(tileBreak,i)
end

for i = 0, math.ceil(breakTile/2) - 1 do
    table.insert(tileBreak,i)
end

for i, botz in pairs(selectedBot) do
    if botz.name:upper() == bot.name:upper() then
        posX, posY = posX+posDistance*(i-1), posY
    end
end
print(bot.name:upper().." Position: X "..posX.." and Y "..posY)

function gscanFloat(id)
    return bot:getWorld().growscan:getObjects()[id] or 0
end

function gscanBlock(id)
    return bot:getWorld().growscan:getTiles()[id] or 0
end

function findItem(id)
    return bot:getInventory():findItem(id)
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
    while not bot:isInWorld(worldName:upper()) and not worldNuked do
        print("Warping to "..worldName)
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

        listenEvents(6)

        if warpAttempt == 5 then
            callAlert("Hard Warping to "..worldName.." "..bot.name:upper().." Resting.")
            print(worldName, " Hard Warp")
            sleep(2 * 60000)
            bot:disconnect()
            sleep(1000)
            while bot.status ~= BotStatus.online do
                sleep(1000)
            end
            warpAttempt = 0
        else
            warpAttempt = warpAttempt + 1
        end

    end

    if worldNuked then
        callAlert(worldName.." is Nuked!")
        print(worldName, "Nuked")
        -- bot:stopScript()
    end
    
    if doorID ~= "" and getTile(bot.x, bot.y).fg == 6 then
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(1000)
            while bot.status == BotStatus.account_banned do
                callAlert(bot.name:upper() .. " got Banned!")
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
            print("Cant go to Door ID at ".. worldName)
            callAlert("Cant go to Door ID at ".. worldName)
            sleep(100)
            worldNuked = true
        end
    end
    sleep(100)
    removeEvent(Event.variantlist)
end

function reconnect(worldName, doorID, posX, posY)
    if autoRest and bot:isResting() then
        while bot:isResting() do
            if exitOnRest and bot:isInWorld() then
                bot:leaveWorld()
            end
            if disconnectOnRest and bot.status == BotStatus.online then
                print(bot.name:upper() .. " Disconnect while Resting")
                callEvent(bot.name:upper() .. " Disconnect while Resting")
                bot.auto_reconnect = false
                bot:disconnect()
            end
            sleep(1000)
        end
        
        callEvent(bot.name:upper() .. " Resuming after Rest")
        bot.auto_reconnect = true
        
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(1000)
            if bot.status == BotStatus.account_banned then
                callAlert(bot.name:upper() .. " got Banned!")
                bot.auto_reconnect = false
                bot:stopScript()
            end
        end
    
        while not bot:isInWorld(worldName:upper()) do
            bot:warp(worldName)
            sleep(delayWarp)
        end
        
        if doorID ~= "" and getTile(bot.x,bot.y).fg == 6 then
            sleep(1000)
            bot:warp(worldName, doorID)
            sleep(2000)
        end
    
        if posX and posY and not bot:isInTile(posX, posY) then
            sleep(200)
            bot:findPath(posX, posY)
            sleep(200)
        end
        callWebhook(nil, nil, nil, nil)
    end
    if bot.status ~= BotStatus.online or bot:getPing() == 0 then
        callWebhook(nil, nil, nil, nil)

        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(1000)
            if bot.status == BotStatus.account_banned then
                callAlert(bot.name:upper() .. " got Banned!")
                bot.auto_reconnect = false
                bot:stopScript()
            end
        end
        
        while not bot:isInWorld(worldName:upper()) do
            bot:warp(worldName)
            sleep(delayWarp)
        end
        
        if doorID ~= "" and getTile(bot.x,bot.y).fg == 6 then
            sleep(1000)
            bot:warp(worldName, doorID)
            sleep(2000)
        end
        
        if posX and posY and not bot:isInTile(posX, posY) then
            sleep(200)
            bot:findPath(posX, posY)
            sleep(200)
        end
        callWebhook(nil, nil, nil, nil)
    end
end

function round(n)
    return n % 1 > 0.5 and math.ceil(n) or math.floor(n)
end

function autoWear(itemID)
    bot.auto_collect = false
    bot.object_collect_delay = 100
    warps(pickaxeWorld, pickaxeDoorID)
    if bot:isInWorld() then
        for _, obj in pairs(getObjects()) do
            reconnect(pickaxeWorld, pickaxeDoorID)
            if obj.id == itemID then
                if #bot:getPath(math.floor(obj.x / 32)-1,math.floor(obj.y / 32)) > 0 then
                    bot:findPath(math.floor(obj.x / 32)-1,math.floor(obj.y / 32))
                    sleep(100)
                end
                bot:collectObject(obj.oid, 3)
                sleep(500)
            end
            if findItem(itemID) > 0 then
                break
            end
        end
        
        if findItem(itemID) > 1 then
            print("Item Count > 1, Bot Dropping")
            bot:setDirection(false)
            sleep(100)
            bot:drop(itemID, findItem(itemID)-1)
            sleep(500)
            while findItem(itemID) > 1 do
                bot:moveRight()
                sleep(100)
                bot:drop(itemID, findItem(itemID)-1)
                sleep(500)
                reconnect(pickaxeWorld, pickaxeDoorID)
            end
        end

        if findItem(itemID) == 1 then
            if not getBot():getInventory():getItem(itemID).isActive then
                bot:wear(itemID)
                sleep(300)
            end
        else
            print("No Item["..itemID.."] Found in Backpack!, Calling Auto Wear Again")
            sleep(3000)
            autoWear(itemID)
        end

    end
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

function dropItem(itemID)
    print(bot.name:upper().." Dropping Item["..itemID.."]")
    bot.auto_collect = false
    bot.object_collect_delay = 60000
    if seedWorld:upper() == blockWorld:upper() then
        bot:warp(seedWorld, seedDoorID)
        sleep(2000)
    else
        warps(seedWorld, seedDoorID)
    end
    if bot:isInWorld(seedWorld:upper()) then
        ye = bot.y
        for _, tile in pairs(getTiles()) do
            reconnect(seedWorld, seedDoorID)
            if tile.y == ye and tile.x > bot.x and tile.x <= 99 then
                if tileDrop(tile.x, tile.y, findItem(itemID)) then
                    bot:findPath(tile.x-1, tile.y)
                    bot:setDirection(false)
                    sleep(100)
                    bot:drop(itemID, findItem(itemID))
                    sleep(500)
                    while findItem(itemID) > 0 and getTile(bot.x+1, bot.y).fg == 0 do
                        bot:moveRight()
                        sleep(100)
                        bot:drop(itemID, findItem(itemID))
                        sleep(500)
                        reconnect(seedWorld, seedDoorID)
                    end
                end
            end
            if findItem(itemID) == 0 then
                break
            end
        end
        callWebhook(nil, gscanFloat(seedID), nil, nil)
    end
end

function dropGoodItem(itemID)
    print(bot.name:upper().." Dropping Item["..itemID.."]")
    bot.auto_collect = false
    warps(saveItemWorld:upper(), saveItemDoorID)
    if bot:isInWorld(saveItemWorld:upper()) then
        ye = bot.y
        for _, tile in pairs(getTiles()) do
            reconnect(saveItemWorld, saveItemDoorID)
            if tile.y == ye and tile.x > bot.x and tile.x <= 99 then
                if tileDrop(tile.x, tile.y, findItem(itemID)) then
                    bot:findPath(tile.x-1, tile.y)
                    bot:setDirection(false)
                    sleep(100)
                    bot:drop(itemID, findItem(itemID))
                    sleep(500)
                    while findItem(itemID) > 0 and getTile(bot.x+1, bot.y).fg == 0 do
                        bot:moveRight()
                        sleep(100)
                        bot:drop(itemID, findItem(itemID))
                        sleep(500)
                        reconnect(saveItemWorld, saveItemDoorID)
                    end
                end
            end
            if findItem(itemID) == 0 then
                break
            end
        end
    end
end

function takeBlockMain()
    print(bot.name:upper() .. " Taking Block")
    bot.auto_collect = false
    bot.object_collect_delay = 100
    for _, bWorld in pairs(blockWorlds) do
        blockWorld = bWorld:upper()
        if not emptyWorld[blockWorld] then
            warps(blockWorld, blockDoorID)
            if not worldNuked then
                if bot:isInWorld(blockWorld:upper()) then
                    if gscanFloat(blockID) > 0 then
                        takeItem(blockID, 200)
                        sleep(100)
                        callWebhook(gscanFloat(blockID), nil, nil, nil)
                    else
                        print(blockWorld.." Empty")
                        callEvent(blockWorld.." Empty")
                        emptyWorld[blockWorld] = true
                        if blockWorld == string.upper(blockWorlds[#blockWorlds]) and findItem(blockID) == 0 then
                            print(blockWorld.." is the Last World in the List!, "..bot.name:upper().." Finish!")
                            callEvent(blockWorld.." is the Last World in the List!, "..bot.name:upper().." Finish!")
                            if findItem(seedID) > 0 then
                                dropItem(seedID)
                                sleep(200)
                            end
                            if terminateOption == 1 then
                                bot:stopScript()
                            elseif terminateOption == 2 then
                                bot.auto_reconnect = false
                                bot:disconnect()
                                bot:stopScript()
                            else
                                removeBot(bot.name)
                            end
                        end
                    end
                    if findItem(blockID) > 0 then
                        break
                    end
                end
            end
        end
    end
end

function takeItem(itemID, amount)
    bot.auto_collect = false
    bot.object_collect_delay = 100
    warps(blockWorld, blockDoorID)
    for _, obj in pairs(getObjects()) do
        reconnect(blockWorld, blockDoorID)
        if obj.id == itemID then
            if #bot:getPath(math.floor(obj.x / 32),math.floor(obj.y / 32)) > 0 then
                bot:findPath(math.floor(obj.x / 32),math.floor(obj.y / 32))
                sleep(100)
            end
            bot:collectObject(obj.oid, 3)
            sleep(500)
            reconnect(blockWorld, blockDoorID)
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
        reconnect(blockWorld, blockDoorID)
    end
end

function trashJunk()
    for _, trash in pairs(trashList) do
        if findItem(trash) > 100 then
            bot:trash(trash, findItem(trash))
            sleep(1000)
        end
    end
end

function PNB()
    warps(pnbWorld, pnbDoorID)
    if bot:isInWorld(pnbWorld:upper()) then

        print(bot.name:upper().." PNB in World: "..bot:getWorld().name:upper())
        sleep(100)
        callEvent(bot.name:upper().." PNB in World: ||"..bot:getWorld().name:upper().."||")
        sleep(100)
        callWebhook(nil, nil, nil, gscanFloat(112))
        sleep(100)

        if not bot:isInTile(posX, posY) and #bot:getPath(posX, posY) > 0 then
            bot:findPath(posX, posY)
            sleep(200)
        end

        if randomSkinColor then
            bot:setSkin(math.random(1,6))
            sleep(200)
        end
    
        if randomChat then
            bot:say(randomChatList[math.random(1, #randomChatList)])
            sleep(1000)
            bot:say(randomChatList[math.random(1, #randomChatList)])
            sleep(1000)
        end
        
        bot.auto_collect = autoCollect
        bot.object_collect_delay = 150
        bot.ignore_gems = not collectGems

        if pnbMode:upper() == "UP" then
            while findItem(blockID) > 0 and findItem(seedID) < 196 and bot:isInWorld(pnbWorld:upper()) and getTile(bot.x, bot.y).fg ~= 6 do
                
                for _,i in pairs(tileBreak) do
                    if getTile(posX + i, posY - 2).fg == 0 and getTile(posX + i, posY - 2).bg == 0 then
                        bot:place(bot.x + i, bot.y - 2, blockID)
                        sleep(delayPlace)
                        reconnect(pnbWorld, pnbDoorID, posX, posY)
                    end
                end
                
                for _,i in pairs(tileBreak) do
                    while getTile(posX + i, posY - 2).fg ~= 0 or getTile(posX + i, posY - 2).bg ~= 0 do
                        bot:hit(bot.x + i, bot.y - 2)
                        if variationDelay then
                            sleep(math.random(delayHit - 10,delayHit + 10))
                        else
                            sleep(delayHit)
                        end
                        reconnect(pnbWorld, pnbDoorID, posX, posY)
                    end
                end
        
            end
        else
            while findItem(blockID) > 0 and findItem(seedID) < 196 and bot:isInWorld(pnbWorld:upper()) and getTile(bot.x, bot.y).fg ~= 6 do
                
                for _,i in pairs(tileBreak) do
                    if getTile(posX + i, posY + 2).fg == 0 and getTile(posX + i, posY + 2).bg == 0 then
                        bot:place(bot.x + i, bot.y + 2, blockID)
                        sleep(delayPlace)
                        reconnect(pnbWorld, pnbDoorID, posX, posY)
                    end
                end
                
                for _,i in pairs(tileBreak) do
                    while getTile(posX + i, posY + 2).fg ~= 0 or getTile(posX + i, posY + 2).bg ~= 0 do
                        bot:hit(bot.x + i, bot.y + 2)
                        if variationDelay then
                            sleep(math.random(delayHit - 10,delayHit + 10))
                        else
                            sleep(delayHit)
                        end
                        reconnect(pnbWorld, pnbDoorID, posX, posY)
                    end
                end
        
            end
        end
    end

end

function checkWrench(varlist, netid)
    if varlist:get(0):getString() == "OnDialogRequest" and varlist:get(1):getString():find("my_worlds") then
        wrenchP = true
        unlistenEvents()
    end
end

function checkMyWorld(varlist, netid)
    if varlist:get(0):getString() == "OnDialogRequest" and varlist:get(1):getString():find("add_button") then
        teks = varlist:get(1):getString()
        worldTutor = string.match(teks, "add_button|([^|]+)|")
        print(bot.name:upper().." Tutorial World: "..worldTutor)
        callEvent(bot.name:upper().." Tutorial World: "..worldTutor)
        unlistenEvents()
    end
end

function checkTutorial()
    worldTutor = ""
    while not bot:isInWorld() do
        bot:warp(randomWorld[math.random(1, #randomWorld)])
        sleep(delayWarp)
    end
    if bot:isInWorld() then
        netidd = getLocal().netid
        addEvent(Event.variantlist, checkWrench)
        bot:wrenchPlayer(netidd)
        listenEvents(5)
        if wrenchP then
            addEvent(Event.variantlist, checkMyWorld)
            bot:sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|".. netidd .."|\nbuttonClicked|my_worlds")
            listenEvents(5)
        end
        removeEvent(Event.variantlist)
    end
end

function PNBTutorial()
    warps(worldTutor, "")
    if not worldNuked then
        posX, posY = 50, 23
        if bot:isInWorld(worldTutor:upper()) and hasAccess(bot.x-1, bot.y) > 0 then
            print(bot.name:upper().." PNB in World: "..bot:getWorld().name:upper())
            callEvent(bot.name:upper().." PNB in World: ||"..bot:getWorld().name:upper().."||")
            if not bot:isInTile(posX, posY) and #bot:getPath(posX, posY) > 0 then
                bot:findPath(posX, posY)
                sleep(200)
            end

            if randomSkinColor then
                bot:setSkin(math.random(1,6))
                sleep(200)
            end
        
            if randomChat then
                bot:say(randomChatList[math.random(1, #randomChatList)])
                sleep(1000)
                bot:say(randomChatList[math.random(1, #randomChatList)])
                sleep(1000)
            end
            
            bot.auto_collect = autoCollect
            bot.object_collect_delay = 150
            bot.ignore_gems = not collectGems
            
            while findItem(blockID) > 0 and findItem(seedID) < 196 and bot:isInWorld(worldTutor:upper()) and getTile(bot.x, bot.y).fg ~= 6 do
                
                for i,player in pairs(getPlayers()) do
                    if player.netid ~= getLocal().netid and player.name:upper() ~= whiteListOwner:upper() then
                        bot:say("/ban " .. player.name)
                        sleep(1000)
                    end
                end
                
                for _,i in pairs(tileBreak) do
                    if getTile(posX + i, posY - 2).fg == 0 and getTile(posX + i, posY - 2).bg == 0 then
                        bot:place(bot.x + i, bot.y - 2, blockID)
                        sleep(delayPlace)
                        reconnect(worldTutor, "", posX, posY)
                    end
                end
                
                for _,i in pairs(tileBreak) do
                    while getTile(posX + i, posY - 2).fg ~= 0 or getTile(posX + i, posY - 2).bg ~= 0 do
                        bot:hit(bot.x + i, bot.y - 2)
                        if variationDelay then
                            sleep(math.random(delayHit - 10,delayHit + 10))
                        else
                            sleep(delayHit)
                        end
                        reconnect(worldTutor, "", posX, posY)
                    end
                end

            end
        end
    end
    if worldNuked then
        print(bot.name:upper().." World Tutorial Nuked!")
        callAlert(bot.name:upper().." World Tutorial Nuked!")
        PNBMain()
    end
end

function buyPacks()
    print(bot.name:upper().." Buy Packs!")
    bot.auto_collect = false
    warps(packWorld, packDoorID)
    if bot:isInWorld() then
        availSlot = getBot():getInventory().slotcount - getBot():getInventory().itemcount
        while bot.gem_count >= packPrice and availSlot > 0 do
            bot:buy(packName:lower())
            sleep(2000)
            reconnect(packWorld, packDoorID)
            for _, itemz in pairs(packItemID) do
                if findItem(itemz) > 190 then
                    dropPack()
                    reconnect(packWorld, packDoorID)
                end
            end
        end
        dropPack()
    end
end

function dropPack()
    bot.auto_collect = false
    warps(packWorld, packDoorID)
    for _, pack in pairs(packItemID) do
        if findItem(pack) > 0 then
            bot:drop(pack, findItem(pack))
            sleep(500)
            reconnect(packWorld, packDoorID)
            while findItem(pack) > 0 do
                bot:moveRight()
                sleep(100)
                bot:drop(pack, findItem(pack))
                sleep(500)
                reconnect(packWorld, packDoorID)
            end
        end
    end
    callWebhook(nil, nil, scanPack(), nil)
end

function scanPack()
    local totalPack = 0
    for _, obj in pairs(getObjects()) do
        for _, pid in ipairs(packItemID) do
            if obj.id == pid then
                totalPack = totalPack + obj.count
            end
        end
    end
    return totalPack
end

function scanSeedGaia()
    return getTile(gaiaX, gaiaY):getExtra().item_count
end

function autoRemove()
    if bot.level >= removeOnLevel then
        print(bot.name:upper().." has reached maximum level, Removing...")
        callAlert(bot.name:upper().." has reached maximum level, Removing...")
        if findItem(blockID) > 0 then
            dropItem(blockID)
            sleep(200)
        end
        if findItem(seedID) > 0 then
            dropItem(seedID)
            sleep(200)
        end
        if autoBuyPack and bot.gem_count >= packPrice then
            buyPacks()
            sleep(200)
        end
        removeBot(bot.name)
    end
end

function scanGaut()
    for _, tile in pairs(getTiles()) do
        if tile.fg == gaiaID and hasAccess(tile.x, tile.y) > 0 then
            gaiaX, gaiaY = tile.x, tile.y
        end
        if tile.fg == utID and hasAccess(tile.x, tile.y) > 0 then
            utX, utY = tile.x, tile.y
        end
    end
end

function itemInGaia(varlist, netid)
    if varlist:get(0):getString() == "OnDialogRequest" and varlist:get(1):getString():find("The machine contains") then
        teks = varlist:get(1):getString()
        totalItemInGaia = tonumber(string.match(teks, "contains (%d+)"))
        gaiaReady = true
        unlistenEvents()
    end
end

function itemInUT(varlist, netid)
    if varlist:get(0):getString() == "OnDialogRequest" and varlist:get(1):getString():find("The machine contains") then
        teks = varlist:get(1):getString()
        totalitemInUT = tonumber(string.match(teks, "contains (%d+)"))
        utReady = true
        unlistenEvents()
    end
end

function retGaia()
    gaiaReady = false
    warps(pnbWorld, pnbDoorID)
    if bot:isInWorld(pnbWorld:upper()) then
        if not bot:findPath(gaiaX, gaiaY-1) then
            bot:findPath(gaiaX, gaiaY+1)
        end
        sleep(100)
    
        if bot:isInTile(gaiaX, gaiaY-1) or bot:isInTile(gaiaX, gaiaY+1) and getTile(gaiaX, gaiaY).fg == gaiaID then
            addEvent(Event.variantlist, itemInGaia)
            bot:wrench(gaiaX, gaiaY)
            listenEvents(2)
            if gaiaReady then
                bot:sendPacket(2, "action|dialog_return\ndialog_name|itemsucker_seed\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")
                sleep(1000)
                if totalItemInGaia > 200 then
                    bot:sendPacket(2, "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nitemtoremove|200")
                    sleep(500)
                elseif totalItemInGaia > 0 then
                    bot:sendPacket(2, "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nitemtoremove|"..totalItemInGaia)
                    sleep(500)
                end
            end
            removeEvent(Event.variantlist)
        end

    end
end

function retUt()
    utReady = false
    warps(pnbWorld, pnbDoorID)
    if bot:isInWorld(pnbWorld:upper()) then
        if not bot:findPath(utX, utY-1) then
            bot:findPath(utX, utY+1)
        end
        sleep(100)
    
        if bot:isInTile(utX, utY-1) or bot:isInTile(utX, utY+1) and getTile(utX, utY).fg == utID then
            addEvent(Event.variantlist, itemInUT)
            bot:wrench(utX, utY)
            listenEvents(2)
            if utReady then
                bot:sendPacket(2, "action|dialog_return\ndialog_name|itemsucker_block\ntilex|"..utX.."|\ntiley|"..utY.."|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")
                sleep(1000)
                if totalitemInUT > 200 then
                    bot:sendPacket(2, "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..utX.."|\ntiley|"..utY.."|\nitemtoremove|200")
                    sleep(500)
                elseif totalitemInUT > 0 then
                    bot:sendPacket(2, "action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..utX.."|\ntiley|"..utY.."|\nitemtoremove|"..totalitemInUT)
                    sleep(500)
                end
            end
            removeEvent(Event.variantlist)
        end

    end
end

function dropGoods()
    for _, itemz in pairs(goodItemList) do
        if findItem(itemz) > minItem then
            dropGoodItem(itemz)
            sleep(200)
        end
    end
end

function PNBMain()
    for _, pnbW in pairs(pnbWorlds) do
        pnbWorld = pnbW:upper()
        if not maxGemsWorld[pnbWorld] then
            warps(pnbWorld, pnbDoorID)
            if not worldNuked then
                if bot:isInWorld(pnbWorld) then
                    if gscanFloat(112) <= maxGems then
                        while gscanFloat(112) <= maxGems do
                            trashJunk()
                            sleep(100)
                            scanGaut()
                            sleep(100)

                            if autoRemoveBot and bot.level >= removeOnLevel then
                                autoRemove()
                                sleep(100)
                            end

                            if autoTakePickaxe and findItem(98) == 0 then
                                autoWear(98)
                                sleep(100)
                            end
                    
                            if autoBuyPack and bot.gem_count >= minGems then
                                buyPacks()
                                sleep(100)
                            end
                            
                            if findItem(blockID) < 196 then
                                takeBlockMain()
                                sleep(100)
                                dropGoods()
                            end
                            
                            if findItem(seedID) >= maxSeedInBP then
                                dropItem(seedID)
                                sleep(200)
                            end
                            
                            PNB()
                            sleep(100)

                            callWebhook(nil, nil, nil, gscanFloat(112))
                            sleep(100)
                            
                            if autoRetrieve and getTile(gaiaX, gaiaY):getExtra().item_count >= minSeedToRetrieve then
                                retGaia()
                                sleep(100)
                                retUt()
                                sleep(100)

                                if findItem(blockID) < 196 then
                                    takeBlockMain()
                                    dropGoods()
                                    sleep(100)
                                end
                                
                                if findItem(seedID) > 0 then
                                    dropItem(seedID)
                                    sleep(200)
                                end

                                if autoTakePickaxe and findItem(98) == 0 then
                                    autoWear(98)
                                    sleep(100)
                                end
                        
                                if autoBuyPack and bot.gem_count >= minGems then
                                    buyPacks()
                                    sleep(100)
                                end
                            end

                            warps(pnbWorld, pnbDoorID)
                        end
                    else
                        maxGemsWorld[pnbWorld] = true
                        if pnbWorld:upper() == string.upper(pnbWorlds[#pnbWorlds]) then
                            print(pnbWorld.." is the Last World in the List!, "..bot.name:upper().." Finish!")
                            callAlert(pnbWorld.." is the Last World in the List!, "..bot.name:upper().." Finish!")
                            if findItem(blockID) > 0 then
                                dropItem(blockID)
                            end
                            if findItem(seedID) > 0 then
                                dropItem(seedID)
                            end
                            if terminateOption == 1 then
                                bot:stopScript()
                            elseif terminateOption == 2 then
                                bot.auto_reconnect = false
                                bot:disconnect()
                                bot:stopScript()
                            else
                                removeBot(bot.name)
                            end
                        end
                    end
                end
            end
        end
    end
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
        sleep(delayOnExecute*botIndex-1)
    
        if pnbInTutorial then
            for i = 1,3 do
                if worldTutor == "" then
                    checkTutorial()
                    sleep(100)
                end
            end

            if worldTutor == "" then
                print(bot.name:upper().." Dont Have Tutorial World!")
                sleep(100)
                callEvent(bot.name:upper().." Dont Have Tutorial World!")
                sleep(100)
                noTutorWorld = true
            end

            if not noTutorWorld then
                while true do
                    trashJunk()
                    sleep(100)

                    if autoRemoveBot and bot.level >= removeOnLevel then
                        autoRemove()
                        sleep(100)
                    end
        
                    if nei_take_pickaxe and findItem(98) == 0 then
                        autoWear(98)
                        sleep(100)
                    end
        
                    if autoBuyPack and bot.gem_count >= minGems then
                        buyPacks()
                        sleep(100)
                    end
                
                    if findItem(nei_itemid_block) < 196 then
                        takeBlockMain()
                        sleep(100)
                        dropGoods()
                    end

                    if findItem(seedID) >= maxSeedInBP then
                        dropItem(seedID)
                        sleep(200)
                    end
        
                    PNBTutorial()
                    sleep(100)

                    callWebhook(nil, nil, nil, gscanFloat(112))
                    sleep(100)
                end
            end
        end

        if not pnbInTutorial or noTutorWorld then
            PNBMain()
        end

    else
        print("ERROR REGISTER")
    end
end
