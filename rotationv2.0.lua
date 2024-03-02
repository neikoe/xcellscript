function botEvents(info)
    te = os.time() - t
    local dhika_wh = Webhook.new(webhook_link)
    dhika_wh.embed1.use = true 
    dhika_wh.embed1.title = "**SCRIPT AUTO ROTATION V2.0**"
    dhika_wh.embed1.description = info .. "\nBot Refresh : <t:" .. os.time() .. ":R>"
    dhika_wh.embed1.footer.text = "Script By Xcell - ".. os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60)
    dhika_wh.embed1.color = 
    dhika_wh.embed1:addField(
        "**[BOT INFORMATION]**",
        "<:Excellent:964672053624078407> | Bot Id: ||" .. bot.name .. "||\n" .. 
        "<:gtExclamation:691380522651353140> | Bot Status: " .. GetBot(getBot().name) .. "<:greendot:1084209325121216522>\n" .. 
        "<:GT_Bot:1190695123336560781> | Bot Number: " .. indexBot .. "\n" .. 
        "<:Status:1190695183440945182> | Bot Ping: " .. bot:getPing() .. "\n" .. 
        "<:DumbBuilder:1094476784860397589> | Bot Level: " .. bot.level .. "\n" .. 
        "<:Gems:1156643126316904508> | Bot Gems: " .. bot.gem_count .. "\n" .. 
        "<:Uptime:1156642727811874838> | Bot Uptime: " .. secondON(te) .. "\n" .. 
        "** **\n" .. 
        "**[FARM INFORMATION]**\n" .. 
        "<:Laser_Grid_Tree:1190695145188884661> |  Tree: " .. getInfo(number_block).name .. "\n" .. 
        "<:Laser_Grid_Tree:1190695145188884661> |  Tree Amount: " .. totalTree .. "\n" .. 
        "<:Laser_Grid_Tree:1190695145188884661> |  Ready Amount: " .. readyTree .. "\n" .. 
        "<:Fossil_Rock:1190695032001413191> | Fossil Rock Amount: " .. fossil .. "\n" .. 
        "<:Scroll:1083965766187110460> | Current World: ||" .. world .. "||\n" .. 
        "** **\n" .. 
        "**[STORAGE INFORMATION]**\n" .. 
        "<:WorldList:1156644357135409262> | Pack World: ||" .. storagePack .. "||\n" .. 
        "<:SeedProfit:1156653454899556434> | Pack Dropped: " .. profit .. "\n" .. 
        "<:WorldList:1156644357135409262> | Seed World: ||" .. storageSeed .. "||\n" .. 
        "<:laser_grid_seed:1190645092378226718> | Seed Dropped: " .. profitSeed,

        false
    )
    if webhook_id == '' then dhika_wh:send() else dhika_wh:edit(webhook_id) end
end

function auto_cloth_ces()
    currentClothes = {}
    for _,inventory in pairs(bot:getInventory():getItems()) do
        if getInfo(inventory.id).clothing_type ~= 0 then
            table.insert(currentClothes,inventory.id)
        end
    end
    sleep(100)
    jumlahClothes = #currentClothes
    if jumlahClothes < 5 then
        bot:sendPacket(2,"action|buy\nitem|rare_clothes")
        sleep(100)
        for _,num in pairs(bot:getInventory():getItems()) do
            if getInfo(num.id).clothing_type ~= 0 then
                if num.id ~= 3934 and num.id ~= 3932 then
                    bot:wear(num.id)
                    sleep(1000)
                end
            end
        end
    end
end

function nukeWorldInfo(webhook_link,status)
    local text = [[
        $webHookUrl = "]]..webhook_link..[["
        $payload = @{
            content = "]]..status..[["
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    ]]
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
end

function OnVariantList(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        if variant:get(1):getString():lower():find("inaccessible") then
            nuked = true
        end
    end
end

function warp(world,id)
    cok = 0
    nuked = false
    addEvent(Event.variantlist, OnVariantList)
    while not bot:isInWorld(world:upper()) and not nuked do
        if bot.status == BotStatus.online and bot:getPing() == 0 then
            bot:disconnect()
            sleep(1000)
        end
        while bot.status ~= BotStatus.online do
            sleep(1000)
            while bot.status == BotStatus.account_banned do
                sleep(8000)
            end
        end
        if id ~= "" then
            bot:sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
        else
            bot:sendPacket(3,"action|join_request\nname|"..world:upper().."\ninvitedWorld|0")
        end
        listenEvents(5)
        sleep(set_warp)
        if cok == 5 then
            botInfo(webhook_link,bot.name.." ("..indexBot..")".." can't entering world ||"..world:upper().."|| , disconnect 3 minutes while server sucks @everyone")
            sleep(100)
            while bot.status == BotStatus.online do
                bot:disconnect()
                bot.auto_reconnect = false
                sleep(1000)
            end
            sleep(6 * 60000)
            cok = 0
            bot.auto_reconnect = true
        else
            cok = cok + 1
        end
    end
    if nuked then
        nukeWorldInfo(webhook_link,world.." is nuked. @everyone")
    end
    if id ~= "" and getTile(bot.x,bot.y).fg == 6 and not nuked then
        if bot.status == BotStatus.online and bot:getPing() == 0 then
            bot:disconnect()
            sleep(1000)
        end
        while bot.status ~= BotStatus.online do
            sleep(1000)
            while bot.status == BotStatus.account_banned do
                sleep(8000)
            end
        end
        for i = 1,3 do
            if getTile(bot.x,bot.y).fg == 6 then
                bot:sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
                sleep(1000)
            end
        end
        if getTile(bot.x,bot.y).fg == 6 then
            nukeWorldInfo(webhook_link,bot.name:upper() .. " world "..world.." cannot join door. @everyone")
            sleep(100)
            nuked = true
        end
    end
    sleep(100)
    removeEvent(Event.variantlist)
end

function detect()
    local store = {}
    local count = 0
    for _,tile in pairs(getTiles()) do
        if tile:hasFlag(0) and tile.fg ~= 0 then
            if store[tile.fg] then
                store[tile.fg].count = store[tile.fg].count + 1
            else
                store[tile.fg] = {fg = tile.fg, count = 1}
            end
        end
    end
    for _,tile in pairs(store) do
        if tile.count > count and tile.fg % 2 ~= 0 then
            count = tile.count
            number_seed = tile.fg
            number_block = number_seed - 1
            print(bot.name.." Detected Farmable : "..getInfo(number_block).name)
        end
    end
end

function packInfo(link,id,desc)
    local text = [[
        $webHookUrl = "]]..link..[[/messages/]]..id..[["
        $footerObject = @{
            text = "]]..(os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60))..[["
        }
        $fieldArray = @(
            @{
                name = "<:globe:1011929997679796254> World"
                value = "]]..bot:getWorld().name..[["
                inline = "false"
            }
            @{
                name = "<:cid:1133695201156800582> Last Visit"
                value = "]]..bot.name.." (No."..indexBot..")"..[["
                inline = "false"
            }
            @{
                name = "<:questjt:1179825331562106881> Dropped Items"
                value = "]]..desc..[["
                inline = "false"
            }
        )
        $embedObject = @{
            title = "**SCRIPT AUTO ROTATION V2.0**"
            color = "16777215"
            footer = $footerObject
            fields = $fieldArray
        }
        $embedArray = @($embedObject)
        $payload = @{
            embeds = $embedArray
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
    ]]
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
end

function reconnect(world,id,x,y)
    if bot.level >= max_lvl then
        bot:stopScript()
    end
    if bot_rest then
        currentRest = false
        local timeNow = os.date("*t")
        for _,i in pairs(botrest_time) do
            if i == timeNow.hour and timeNow.min == 0 then
                currentRest = true
            end
        end
        if currentRest then
            
            sleep(100)
            if botrest_disconnect then
                bot.auto_reconnect = false
                bot:disconnect()
                sleep(60000 * botrest_duration)
                bot.auto_reconnect = true
            else
                goExit()
                sleep(60000 * botrest_duration)
                if bot.status == BotStatus.online then
                    bot:disconnect()
                    sleep(1000)
                end
            end
        end
    end
    if bot.status ~= BotStatus.online or bot:getPing() == 0 then
        
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(1000)
            if bot.status == BotStatus.account_banned then
                
                stopScript()
            end
        end
        if take_pexe and bot:getInventory():findItem(98) == 0 and bot.status == BotStatus.online then
            take_pexeaxe()
            sleep(100)
        end
        while bot:getWorld().name ~= world:upper() do
            bot:sendPacket(3,"action|join_request\nname|"..world:upper().."\ninvitedWorld|0")
            sleep(set_warp)
        end
        if id ~= "" and getTile(bot.x,bot.y).fg == 6 then
            bot:sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
            sleep(2000)
        end
        if x and y and (bot.x ~= x or bot.y ~= y) then
            bot:findPath(x,y)
            sleep(100)
        end
        
    end
end

function reconnectHarvest(world,id)
    if bot.status ~= BotStatus.online or bot:getPing() == 0 then
        
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(1000)
            if bot.status == BotStatus.account_banned then
                
                stopScript()
            end
        end
        if take_pexe and bot:getInventory():findItem(98) == 0 and bot.status == BotStatus.online then
            take_pexeaxe()
            sleep(100)
        end
        while not bot:isInWorld(world:upper()) do
            bot:sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
            sleep(set_warp)
        end
        if id ~= "" and getTile(bot.x,bot.y).fg == 6 then
            bot:sendPacket(3,"action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0")
            sleep(1000)
        end
        
    end
end

function infoPack()
    local str = ""
    growscan = getBot():getWorld().growscan
    for id, count in pairs(growscan:getObjects()) do
        str = str.."\n"..getInfo(id).name..": x"..count
    end
    return str
end

function storeSeed(world)
    bot.auto_collect = false
    bot.collect_interval = 9999999
    sleep(100)
    warp(storageSeed,door_seed)
    sleep(100)
    ba = bot:getInventory():findItem(number_seed)
    for _,tile in pairs(bot:getWorld():getTiles()) do
        if tile.fg == tile_seed or tile.bg == tile_seed then
            if tileDrop(tile.x,tile.y,100) then
                bot:findPath(tile.x - 1,tile.y)
                bot:setDirection(false)
                sleep(100)
                if bot:getInventory():findItem(number_seed) > 100 then
                    bot:sendPacket(2,"action|drop\n|itemID|"..number_seed)
                    sleep(500)
                    bot:sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..number_seed.."|\ncount|100")
                    sleep(500)
                    reconnect(storageSeed,door_seed,tile.x - 1,tile.y)
                end
                if bot:getInventory():findItem(number_seed) <= 100 then
                    break
                end
            end
        end
    end
    sleep(100)
    ba = ba - bot:getInventory():findItem(number_seed)
    profitSeed = profitSeed + ba
    sleep(100)
    packInfo(webhook_link,webhook_id,infoPack())
    sleep(100)
    if refresh_history_world then
        join()
    end
    warp(world,doorFarm)
    sleep(100)
    bot.auto_collect = true
    bot.collect_interval = 100
end

function clear()
    for _,item in pairs(auto_trash) do
        if bot:getInventory():findItem(item) > 0 then
            bot:sendPacket(2,"action|trash\n|itemID|"..item)
            bot:sendPacket(2,"action|dialog_return\ndialog_name|trash_item\nitemID|"..item.."|\ncount|"..bot:getInventory():findItem(item)) 
            sleep(500)
        end
    end
end

function goExit()
    while bot:getWorld().name ~= "EXIT" do
        bot:sendPacket(3,"action|join_request\nname|EXIT\ninvitedWorld|0")
        sleep(2000)
    end
end

function checkTutorial()
    goExit()
    sleep(100)
    worldPNB = ""
    sleep(100)
    addEvent(Event.variantlist, onVarSearchTutorial)
    while worldPNB == "" and bot:getWorld().name == "EXIT" do
        bot:sendPacket(3,"action|world_button\nname|_16")
        listenEvents(5)
        sleep(2000)
    end
    sleep(100)
    removeEvent(Event.variantlist)
    sleep(100)
end

function pnbTutorial()
    warp(worldPNB,"")
    sleep(100)
    bot.ignore_gems = false
    if bot:getWorld().name == worldPNB and bot:getWorld():hasAccess(bot.x-1,bot.y) > 0 then
        if bot:getInventory():findItem(number_block) >= break_row and bot:getWorld().name == worldPNB:upper() and bot:getWorld():hasAccess(bot.x-1,bot.y) > 0 then
            ex = bot.x
            ye = bot.y
            bot.auto_collect = true
            while bot:getInventory():findItem(number_block) > break_row and bot:getInventory():findItem(number_seed) <= 190 and bot:getWorld().name == worldPNB:upper() do
                while bot.x ~= ex and bot.y ~= ye do
                    findPath(ex,ye)
                end
                for i,player in pairs(bot:getWorld():getPlayers()) do
                    if player.netid ~= getLocal().netid and player.name:upper() ~= ownerwl:upper() then
                        bot:say("/ban " .. player.name)
                        sleep(1000)
                    end
                end
                while tilePlace(ex,ye) and bot:getWorld().name == worldPNB do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg == 0 and getTile(ex - 1,ye + i).bg == 0 then
                            place(number_block,-1,i)
                            sleep(set_place)
                            reconnect(worldPNB,"",ex,ye)
                        end
                    end
                end
                while tilePunch(ex,ye) and bot:getWorld().name == worldPNB do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg ~= 0 or getTile(ex - 1,ye + i).bg ~= 0 then
                            punch(-1,i)
                            if set_var_on then
                                sleep(math.random(set_punch - set_b_var,set_punch + set_b_var))
                            else
                                sleep(set_punch)
                            end
                            reconnect(worldPNB,"",ex,ye)
                        end
                    end
                end
            end
        end
    elseif bot:isInWorld() and bot:getWorld():hasAccess(bot.x-1,bot.y) == 0 then
        checkTutorial()
    end
end

function pnbOtherWorld()
    worldBreak,doorBreak = read(world_pnb)
    sleep(100)
    warp(worldBreak,doorBreak)
    sleep(100)
    bot.ignore_gems = false
    if not nuked and bot:isInWorld(worldBreak:upper()) then
        if bot:getInventory():findItem(number_block) >= break_row and bot:getWorld().name == worldBreak:upper() then
            ex = bot.x
            ye = bot.y
            bot.auto_collect = true
            while bot:getInventory():findItem(number_block) > break_row and bot:getInventory():findItem(number_seed) <= 190 and bot.x == ex and bot.y == ye and bot:getWorld().name == worldBreak:upper() do
                while tilePlace(ex,ye) do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg == 0 and getTile(ex - 1,ye + i).bg == 0 then
                            place(number_block,-1,i)
                            sleep(set_place)
                            reconnect(worldBreak,doorBreak,ex,ye)
                        end
                    end
                end
                while tilePunch(ex,ye) do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg ~= 0 or getTile(ex - 1,ye + i).bg ~= 0 then
                            punch(-1,i)
                            if set_var_on then
                                sleep(math.random(set_punch - set_b_var,set_punch + set_b_var))
                            else
                                sleep(set_punch)
                            end
                            reconnect(worldBreak,doorBreak,ex,ye)
                        end
                    end
                end
            end
        end
    end
end

function pnb(world)
    if bot:isInWorld() then
        if auto_chat_on then
            chatBot = auto_chat_list[math.random(1,#auto_chat_list)]
            bot:say(chatBot)
            sleep(1000)
            chatBot = emoteChat[math.random(1,#emoteChat)]
            bot:say(chatBot)
            sleep(1000)
        end
        if bot:getInventory():findItem(98) > 0 then
            bot:wear(98)
            sleep(100)
        end
        if auto_skin_c then
            bot:setSkin(math.random(1,8))
            sleep(100)
        end
    end
    if pnb_home then
        pnbTutorial()
    elseif pnb_world then
        pnbOtherWorld()
    else
        if bot:getInventory():findItem(number_block) >= break_row and bot:getWorld().name == world:upper() then
            if not customTile then
                ex = 1
                ye = bot.y
                if ye > 40 then
                    ye = ye - 10
                elseif ye < 11 then
                    ye = ye + 10
                end
                if getTile(ex,ye).fg ~= 0 and getTile(ex,ye).fg ~= number_seed then
                    ye = ye - 1
                end
            else
                ex = customX
                ye = customY
            end
            sleep(100)
            bot:findPath(ex,ye)
            sleep(100)
            bot.ignore_gems = false
            bot.auto_collect = true
            while bot:getInventory():findItem(number_block) > break_row and bot:getInventory():findItem(number_seed) <= 190 and bot.x == ex and bot.y == ye do
                while tilePlace(ex,ye) do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg == 0 and getTile(ex - 1,ye + i).bg == 0 then
                            place(number_block,-1,i)
                            sleep(set_place)
                            reconnect(world,doorFarm,ex,ye)
                        end
                    end
                end
                while tilePunch(ex,ye) do
                    for _,i in pairs(tileBreak) do
                        if getTile(ex - 1,ye + i).fg ~= 0 or getTile(ex - 1,ye + i).bg ~= 0 then
                            punch(-1,i)
                            if set_var_on then
                                sleep(math.random(set_punch - set_b_var,set_punch + set_b_var))
                            else
                                sleep(set_punch)
                            end
                            reconnect(world,doorFarm,ex,ye)
                        end
                    end
                end
            end
        end
    end
    sleep(100)
    clear()
    sleep(100)
    if gems_ht then
        bot.ignore_gems = true
    end
    sleep(100)
    if auto_cloth_c and bot.gem_count >= 1500 then
        while bot:getInventory().slotcount < 36 do
            bot:buy("upgrade_backpack")
            sleep(200)
        end
        auto_cloth_ces()
    end
    if bot.gem_count > buy_item_gems_set then
        buyPack(world)
        sleep(100)
    end
    warp(world,doorFarm)
    sleep(100)
    if not plant_off then
        plant(world)
    end
    sleep(100)
end

function buyPack(world)
    bot.auto_collect = false
    bot.collect_interval = 9999999
    sleep(100)
    while bot:getInventory().slotcount < 36 do
        bot:buy("upgrade_backpack")
        sleep(200)
    end
    while bot.gem_count > buy_item_price do
        if bot.gem_count > buy_item_price and bot:getInventory():findItem(buy_item_num[1]) < 200 then
            bot:buy(buy_item_name)
            profit = profit + 1
            sleep(1000)
            if bot:getInventory():findItem(buy_item_num[1]) == 0 then
                bot:buy("upgrade_backpack")
                sleep(200)
            end
        else
            break
        end
        if bot:getInventory():findItem(buy_item_num[1]) == 200 then
            break
        end
    end
    sleep(100)
    if editNoteProfile then
        netid = getLocal().netid
        bot:sendPacket(2,"action|wrench\n|netid|"..netid)
        sleep(1000)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nbuttonClicked|notebook_edit")
        sleep(1000)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|paginated_personal_notebook_view\npageNum|0|\nbuttonClicked|editPnPage")
        sleep(1000)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|paginated_personal_notebook_edit\npageNum|0|\nbuttonClicked|save\n\npersonal_note|Total Profit Pack : "..profit)
        sleep(1000)
    end
    sleep(100)
    warp(storagePack,door_strg)
    sleep(100)
    if bot:getWorld().name == storagePack:upper() then
        for _,pack in pairs(buy_item_num) do
            for _,tile in pairs(bot:getWorld():getTiles()) do
                if tile.fg == tile_strg or tile.bg == tile_strg then
                    if tileDrop(tile.x,tile.y,bot:getInventory():findItem(pack)) then
                        bot:findPath(tile.x - 1,tile.y)
                        sleep(100)
                        bot:setDirection(false)
                        sleep(100)
                        reconnect(storagePack,door_strg,tile.x - 1,tile.y)
                        if bot:getInventory():findItem(pack) > 0 and tileDrop(tile.x,tile.y,bot:getInventory():findItem(pack)) then
                            bot:sendPacket(2,"action|drop\n|itemID|"..pack)
                            sleep(500)
                            bot:sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..pack.."|\ncount|"..bot:getInventory():findItem(pack))
                            sleep(500)
                            reconnect(storagePack,door_strg,tile.x - 1,tile.y)
                        end
                    end
                end
                if bot:getInventory():findItem(pack) == 0 then
                    break
                end
            end
        end
    end
    sleep(100)
    packInfo(webhook_link,webhook_id,infoPack())
    sleep(100)
    if refresh_history_world then
        join()
    end
    warp(world,doorFarm)
    sleep(100)
    bot.auto_collect = true
    bot.collect_interval = 100
    sleep(100)
end

function isPlantable(tile)
    local tempTile = getTile(tile.x, tile.y + 1)
    if not tempTile.fg then 
        return false 
    end
    local collision = getInfo(tempTile.fg).collision_type
    return tempTile and ( collision == 1 or collision == 2 )
end

function plant(world)
    for _,tile in pairs(bot:getWorld():getTiles()) do
        if getTile(tile.x,tile.y).fg == 0 and isPlantable(getTile(tile.x,tile.y)) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 and bot:getInventory():findItem(number_seed) > 0 and bot:getWorld().name == world:upper() then
            bot:findPath(tile.x,tile.y)
            for _, i in pairs(mode3Tile) do
                while getTile(tile.x + i,tile.y).fg == 0 and isPlantable(getTile(tile.x + i,tile.y)) and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot:getInventory():findItem(number_seed) > 0 and bot.x == tile.x and bot.y == tile.y and bot:getWorld().name == world:upper() do
                    place(number_seed,i,0)
                    sleep(set_plant)
                    reconnect(world,doorFarm,tile.x,tile.y - 1)
                end
            end
        end
    end
end

function take_pexeaxe()
    bot.auto_collect = false
    sleep(100)
    warp(worldPickaxe,door_pexe)
    sleep(100)
    while bot:getInventory():findItem(98) == 0 do
        for _,obj in pairs(bot:getWorld():getObjects()) do
            if obj.id == 98 then
                bot:findPath(math.floor(obj.x / 32),math.floor(obj.y / 32))
                sleep(100)
                bot:collect(3)
                sleep(100)
            end
            if bot:getInventory():findItem(98) > 0 then
                break
            end
        end
        sleep(500)
    end
    bot:moveTo(-1,0)
    sleep(100)
    bot:setDirection(false)
    sleep(100)
    while bot:getInventory():findItem(98) > 1 do
        bot:sendPacket(2,"action|drop\n|itemID|98")
        sleep(500)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|98|\ncount|"..(bot:getInventory():findItem(98) - 1))
        sleep(500)
    end
    bot:wear(98)
    sleep(100)
    goExit()
    sleep(100)
    bot.auto_collect = true
end

function takeFirehose()
    bot.auto_collect = false
    sleep(100)
    warp(storageFirehose,doorFirehose)
    sleep(100)
    while bot:getInventory():findItem(3066) == 0 do
        for _,obj in pairs(bot:getWorld():getObjects()) do
            if obj.id == 3066 then
                bot:findPath(math.floor(obj.x / 32),math.floor(obj.y / 32))
                sleep(100)
                bot:collect(3)
                sleep(100)
            end
            if bot:getInventory():findItem(3066) > 0 then
                break
            end
        end
        sleep(500)
    end
    bot:moveTo(-1,0)
    sleep(100)
    bot:setDirection(false)
    sleep(100)
    while bot:getInventory():findItem(3066) > 1 do
        bot:sendPacket(2,"action|drop\n|itemID|3066")
        sleep(500)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|3066|\ncount|"..(bot:getInventory():findItem(3066) - 1))
        sleep(500)
    end
    goExit()
    sleep(100)
    bot.auto_collect = true
end

function take(world)
    warp(storageSeed,door_seed)
    sleep(100)
    while bot:getInventory():findItem(number_seed) == 0 do
        for _,obj in pairs(bot:getWorld():getObjects()) do
            if obj.id == number_seed then
                bot:findPath(round(obj.x / 32),math.floor(obj.y / 32))
                sleep(100)
                bot:collect(3)
                sleep(100)
                if bot:getInventory():findItem(number_seed) > 0 then
                    break
                end
            end
        end
        packInfo(webhook_link,webhook_id,infoPack())
        sleep(100)
    end
    warp(world,doorFarm)
    sleep(100)
end

function harvest(world)
    tiley = 0
    tree[world] = 0
    if gems_ht then
        bot.ignore_gems = true
    end
    if bot.level < htonly_lvl and ht_only then
        for _,tile in pairs(bot:getWorld():getTiles()) do
            reconnectHarvest(world,doorFarm)
            if tile:canHarvest() and bot:isInWorld(world:upper()) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 and bot.level < htonly_lvl and getBot().status == BotStatus.online then
                bot:findPath(tile.x,tile.y)
                if tiley ~= tile.y and indexBot <= max_bot_events then
                    tiley = tile.y
                    sleep(100)
                    botEvents("<:megaphone:1030769901230641152> | On Progress "..math.ceil(tiley/2).."/27 Row")
                end
                for _, i in pairs(mode3Tile) do
                    if getTile(tile.x + i,tile.y).fg == number_seed and getTile(tile.x + i,tile.y):canHarvest() and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 then
                        tree[world] = tree[world] + 1
                        while getTile(tile.x + i,tile.y).fg == number_seed and getTile(tile.x + i,tile.y):canHarvest() and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot.x == tile.x and bot.y == tile.y do
                            punch(i,0)
                            sleep(set_harvest)
                            reconnect(world,doorFarm,tile.x,tile.y)
                        end
                    end
                end
                if root_farm then
                    for _, i in pairs(mode3Tile) do
                        while getTile(tile.x + i, tile.y + 1).fg == (number_block + 4) and bot.x == tile.x and bot.y == tile.y do
                            punch(i, 1)
                            sleep(set_harvest)
                            reconnect(world,doorFarm,tile.x,tile.y)
                        end
                    end
                end
                bot:collect(3)
            end
            if bot.level >= htonly_lvl then
                break
            end
        end
    end
    if bot.level >= htonly_lvl or not ht_only then
        if plant_off then
            for _,tile in pairs(bot:getWorld():getTiles()) do
                reconnectHarvest(world,doorFarm)
                if tile:canHarvest() and bot:isInWorld(world:upper()) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 then
                    bot:findPath(tile.x,tile.y)
                    if tiley ~= tile.y and indexBot <= max_bot_events then
                        tiley = tile.y
                        sleep(100)
                        botEvents("<:megaphone:1030769901230641152> | On Progress "..math.ceil(tiley/2).."/27 Row")
                    end
                    for _, i in pairs(mode3Tile) do
                        if getTile(tile.x + i,tile.y).fg == number_seed and getTile(tile.x + i,tile.y):canHarvest() and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot:getWorld().name == world:upper() then
                            tree[world] = tree[world] + 1
                            while getTile(tile.x + i,tile.y).fg == number_seed and getTile(tile.x + i,tile.y):canHarvest() and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot.x == tile.x and bot.y == tile.y and bot:getWorld().name == world:upper() do
                                punch(i,0)
                                sleep(set_harvest)
                                reconnect(world,doorFarm,tile.x,tile.y)
                            end
                        end
                    end
                    if root_farm then
                        for _, i in pairs(mode3Tile) do
                            while getTile(tile.x + i, tile.y + 1).fg == (number_block + 4) and bot.x == tile.x and bot.y == tile.y do
                                punch(i, 1)
                                sleep(set_harvest)
                                reconnect(world,doorFarm,tile.x,tile.y)
                            end
                        end
                    end
                    bot:collect(3)
                end
                if findItem(number_block) >= 190 and bot:getWorld().name == world:upper() then
                    pnb(world)
                    sleep(100)
                    if findItem(number_seed) > 190 then
                        storeSeed(world)
                        sleep(100)
                    end
                end
            end
        else
            for _,tile in pairs(bot:getWorld():getTiles()) do
                reconnectHarvest(world,doorFarm)
                if tile:canHarvest() and bot:isInWorld(world:upper()) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 then
                    bot:findPath(tile.x,tile.y)
                    if tiley ~= tile.y and indexBot <= max_bot_events then
                        tiley = tile.y
                        sleep(100)
                        botEvents("<:megaphone:1030769901230641152> | On Progress "..math.ceil(tiley/2).."/27 Row")
                    end
                    for _, i in pairs(mode3Tile) do
                        if getTile(tile.x + i,tile.y).fg == number_seed and getTile(tile.x + i,tile.y):canHarvest() and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot:getWorld().name == world:upper() then
                            tree[world] = tree[world] + 1
                            while getTile(tile.x + i,tile.y).fg == number_seed and getTile(tile.x + i,tile.y):canHarvest() and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot.x == tile.x and bot.y == tile.y and bot:getWorld().name == world:upper() do
                                punch(i,0)
                                sleep(set_harvest)
                                reconnect(world,doorFarm,tile.x,tile.y)
                            end
                        end
                    end
                    if root_farm then
                        for _, i in pairs(mode3Tile) do
                            while getTile(tile.x + i, tile.y + 1).fg == (number_block + 4) and bot.x == tile.x and bot.y == tile.y do
                                punch(i, 1)
                                sleep(set_harvest)
                                reconnect(world,doorFarm,tile.x,tile.y)
                            end
                        end
                    end
                    for _, i in pairs(mode3Tile) do
                        while getTile(tile.x + i,tile.y).fg == 0 and isPlantable(getTile(tile.x + i,tile.y)) and findItem(number_seed) > 0 and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot.x == tile.x and bot.y == tile.y and bot:getWorld().name == world:upper() do
                            place(number_seed,i,0)
                            sleep(set_plant)
                            reconnect(world,doorFarm,tile.x,tile.y)
                        end
                    end
                    bot:collect(3)
                end
                if bot:getInventory():findItem(number_block) >= 190 then
                    pnb(world)
                    sleep(100)
                    if bot:getInventory():findItem(number_seed) > 150 then
                        storeSeed(world)
                        sleep(100)
                    end
                end
            end
        end
        if floating_block then
            for _,obj in pairs(bot:getWorld():getObjects()) do
                if obj.id == number_block then
                    bot:findPath(round(obj.x / 32),math.floor(obj.y / 32))
                    sleep(100)
                    bot:collect(3)
                    sleep(100)
                end
                if bot:getInventory():findItem(number_block) >= 190 then
                    pnb(world)
                    sleep(100)
                    if bot:getInventory():findItem(number_seed) > 150 then
                        storeSeed(world)
                        sleep(100)
                    end
                end
            end
        end
    end
    if fill_tile_plant then
        for _,tile in pairs(bot:getWorld():getTiles()) do
            if bot:getInventory():findItem(number_seed) == 0 then
                take(world)
                sleep(100)
            end
            if (tile.fg == 0 and tile.y ~= 0 and isPlantable(tile)) and bot:isInWorld(world:upper()) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 then
                for _, i in pairs(mode3Tile) do
                    while getTile(tile.x + i,tile.y).fg == 0 and isPlantable(getTile(tile.x + i,tile.y)) and bot:getWorld():hasAccess(tile.x + i,tile.y) > 0 and bot:getInventory():findItem(number_seed) > 0 and bot.x == tile.x and bot.y == tile.y and bot:getWorld().name == world:upper() do
                        place(number_seed,i,0)
                        sleep(set_plant)
                        reconnect(world,doorFarm,tile.x,tile.y)
                    end
                end
            end
        end
    end
end

function clearBlocks()
    for _,tile in pairs(bot:getWorld():getTiles()) do
        if getTile(tile.x,tile.y).fg == number_block and bot.level >= htonly_lvl then
            bot:findPath(tile.x,tile.y)
            while getTile(tile.x,tile.y).fg == number_block and bot.x == tile.x and bot.y == tile.y do
                punch(0,0)
                sleep(set_harvest)
                reconnect(world,doorFarm,tile.x,tile.y)
            end
        end
    end
end

function join()
    for _,wurld in pairs(refresh_world_list) do
        while bot:getWorld().name:upper() ~= wurld:upper() do
            if bot.status == BotStatus.online and bot:getPing() == 0 then
                bot:disconnect()
                sleep(1000)
            end
            while bot.status ~= BotStatus.online do
                sleep(1000)
                while bot.status == BotStatus.account_banned do
                    sleep(8000)
                end
            end
            bot:sendPacket(3,"action|join_request\nname|"..wurld:upper().."\ninvitedWorld|0")
            sleep(set_warp)
        end
    end
end

function checkFire(world)
    totalTree = 0
    readyTree = 0
    fossil = 0
    toxicwst = false
    for _,tile in pairs(bot:getWorld():getTiles()) do
        if tile:hasFlag(4096) then
            fired = true
        end
        if tile.fg == number_seed then
            totalTree = totalTree + 1
            if tile:canHarvest() then
                readyTree = readyTree + 1
            end
        end
        if tile.fg == 3918 then
            fossil = fossil + 1
        end
        if tile.fg == 778 then
            toxicwst = true
        end
    end
    fossilz[world] = fossil
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

local jsonString = request("POST","http://game2.jagoanvps.cloud:5051/gt/loginlua?username="..username.."&password="..password.."&mac="..getMachineGUID())

local responsePattern = '"response":"(.-)"'
local messagePattern = '"message":"(.-)"'

local response = jsonString:match(responsePattern)
local message = jsonString:match(messagePattern)

if response and message then
    -- Print values
    print("Status: " .. response)
    print("Message: " .. message)

    if response == "success" then
            while bot.status ~= BotStatus.online do
                sleep(1000)
                while bot.status == BotStatus.account_banned do
                     bot:stopScript()
                end
            end

            for i = indexBot, 1, -1 do
                    sleep(set_exec)
            end

            while bot.status ~= BotStatus.online do
                sleep(1000)
                while bot.status == BotStatus.account_banned do
                    bot:stopScript()
                end
            end
--// END LISENCE

            if take_pexe and bot:getInventory():findItem(98) == 0 then
                take_pexeaxe()
                sleep(100)
            end

            if pnb_home then
                checkTutorial()
                sleep(100)
            end

            while true do
                nuked = false
                fired = false
                toxicwst = false
                world,doorFarm = read(world_farm)
                if #world_farmBot == 10 then
                    world_farmBot = {}
                    waktu = {}
                    tree = {}
                end
                table.insert(world_farmBot,world)
                warp(world,doorFarm)
                sleep(100)
                totalFarm = totalFarm + 1
                if not nuked then
                    checkFire(world)
                    if not fired or autoCleanFire then
                        tt = os.time()
                        sleep(100)
                        if toxicwst then
                            nukeWorldInfo(webhook_link,bot.name .. " world "..world.." got toxic waste. cleaning toxic waste @everyone")
                            bot.anti_toxic = true
                            while true do 
                                cntToxic = 0
                                for _,tile in pairs(bot:getWorld():getTiles()) do
                                    if tile.fg == 778 then
                                        cntToxic = cntToxic + 1
                                        sleep(1000)
                                    end
                                end
                                if cntToxic == 0 then
                                    bot.anti_toxic = false
                                    break
                                end
                            end
                        end
                        if fired then
                            if bot:getInventory():findItem(3066) == 0 then
                                takeFirehose()
                                sleep(100)
                            end
                            nukeWorldInfo(webhook_link,bot.name .. " world "..world.." is fired. cleaning fire @everyone")
                            sleep(100)
                            bot.anti_fire = true
                            sleep(100)
                            while bot:getInventory():getItem(3066).isActive and bot:getInventory():findItem(3066) >= 1 do
                                sleep(1000)
                            end
                        end
                        sleep(100)
                        if bot_detect then
                            detect()
                        end
                        sleep(100)
                        clearBlocks()
                        sleep(100)
                        harvest(world)
                        sleep(100)
                        tt = os.time() - tt
                        sleep(100)
                        waktu[world] = math.floor(tt/3600).." Hours "..math.floor(tt%3600/60).." Minutes"
                        sleep(100)
                        botEvents("Farm finished.")
                        sleep(100)
                        if refresh_history_world and tt > 60 then
                            join()
                        end
                    else
                        waktu[world] = "FIRED"
                        tree[world] = "FIRED"
                        nukeWorldInfo(webhook_link,bot.name .. " world "..world.." is fired. @everyone")
                        fired = false
                    end
                else
                    waktu[world] = "NUKED"
                    tree[world] = "NUKED"
                    sleep(100)
                    nuked = false
                    fired = false
                    sleep(5000)
                    if refresh_history_world then
                        join()
                    end
                end
                if stop_bot ~= 0 then
                    if totalFarm >= stop_bot then
                        removeBot()
                        bot:stopScript()
                    end
                end
            end
    else
        print("ERROR REGISTER")
    end
end
