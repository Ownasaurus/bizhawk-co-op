--author: Ownasaurus

--TODO: resync shared memory on file load
--      add sharing of other unlocks such as the wall and floor switches

local prevRAM = nil
local sotn_ram = {}

-- Writes value to RAM using little endian
client.reboot_core()
event.unregisterbyname("RelicText")
local prevDomain = ""
local messageLine1 = ""
local messageLine2 = ""
local messageLine3 = ""
local messageTimer = 0

function writeRAM(domain, address, size, value)
	-- update domain
	if (prevDomain ~= domain) then
		prevDomain = domain
		if not memory.usememorydomain(domain) then
			return
		end
	end

	-- default size short
	if (size == nil) then
		size = 2
	end

	if (value == nil) then
		return
	end

	if size == 1 then
		memory.writebyte(address, value)
	elseif size == 2 then
		memory.write_u16_le(address, value)
	elseif size == 4 then
		memory.write_u32_le(address, value)
	end
end

-- Reads a value from RAM using little endian
function readRAM(domain, address, size)
	-- update domain
	if (prevDomain ~= domain) then
		prevDomain = domain
		if not memory.usememorydomain(domain) then
			return
		end
	end

	-- default size is a byte
	if (size == nil) then
		size = 1
	end

	if size == 1 then
		return memory.readbyte(address)
	elseif size == 2 then
		return memory.read_u16_le(address)
	elseif size == 4 then
		return memory.read_u32_le(address)
	end
end


local function recieveRelic(newValue, prevValue, address)
    -- if you dont already have the relic
	if prevValue == 0 and newValue ~= 0 then
        -- give relic and turn it on
		return 3
	end
    
    return prevValue
end

local function recieveSummon(newValue, prevValue, address)
    -- if you dont already have the relic
	if prevValue == 0 and newValue ~= 0 then
        -- give relic but do NOT automatically turn it on
		return 1
	end
    
    return prevValue
end

-- NOTE: UNFINISHED 
--[[local function recieveXP(newValue, prevValue, address)
    -- normal xp gain
	if newValue > prevVaule then
		
    -- since you cannot lose xp, there must have been a carry
    elseif newValue < prevValue
    
	end
    
    return prevValue
end]]

local function recieveTeleporter(newValue, prevValue, address)
    -- i think we can simply go with the new value
    return newValue
end

ramItems = {
    -- relics
	[0x097964] = {type="num", name="Soul of Bat", receiveFunc=recieveRelic},
    [0x097965] = {type="num", name="Fire of Bat", receiveFunc=recieveRelic},
    [0x097966] = {type="num", name="Echo of Bat", receiveFunc=recieveRelic},
    [0x097967] = {type="num", name="Force of Echo", receiveFunc=recieveRelic},
    [0x097968] = {type="num", name="Soul of Wolf", receiveFunc=recieveRelic},
    [0x097969] = {type="num", name="Power of Wolf", receiveFunc=recieveRelic},
    [0x09796A] = {type="num", name="Skill of Wolf", receiveFunc=recieveRelic},
    [0x09796B] = {type="num", name="Form of Mist", receiveFunc=recieveRelic},
    [0x09796C] = {type="num", name="Power of Mist", receiveFunc=recieveRelic},
    [0x09796D] = {type="num", name="Gas Cloud", receiveFunc=recieveRelic},
    [0x09796E] = {type="num", name="Cube of Zoe", receiveFunc=recieveRelic},
    [0x09796F] = {type="num", name="Spirit Orb", receiveFunc=recieveRelic},
    [0x097970] = {type="num", name="Gravity Boots", receiveFunc=recieveRelic},
    [0x097971] = {type="num", name="Leap Stone", receiveFunc=recieveRelic},
    [0x097972] = {type="num", name="Holy Symbol", receiveFunc=recieveRelic},
    [0x097973] = {type="num", name="Faerie Scroll", receiveFunc=recieveRelic},
    [0x097974] = {type="num", name="Jewel of Open", receiveFunc=recieveRelic},
    [0x097975] = {type="num", name="Merman Statue", receiveFunc=recieveRelic},
    [0x097976] = {type="num", name="Bat Card", receiveFunc=recieveSummon},
    [0x097977] = {type="num", name="Ghost Card", receiveFunc=recieveSummon},
    [0x097978] = {type="num", name="Faerie Card", receiveFunc=recieveSummon},
    [0x097979] = {type="num", name="Demon Card", receiveFunc=recieveSummon},
    [0x09797A] = {type="num", name="Sword Card", receiveFunc=recieveSummon},
    [0x09797B] = {type="num", name="Fairy Card", receiveFunc=recieveSummon},
    [0x09797C] = {type="num", name="WeirdDemon Card", receiveFunc=recieveSummon},
    [0x09797D] = {type="num", name="Heart of Vlad", receiveFunc=recieveRelic},
    [0x09797E] = {type="num", name="Tooth of Vlad", receiveFunc=recieveRelic},
    [0x09797F] = {type="num", name="Rib of Vlad", receiveFunc=recieveRelic},
    [0x097980] = {type="num", name="Ring of Vlad", receiveFunc=recieveRelic},
    [0x097981] = {type="num", name="Eye of Vlad", receiveFunc=recieveRelic},
    -- xp
    --[0x097BEC] = {type="num", name="Experience", receiveFunc=recieveXP, size=2}, -- technically the size is slightly more than two bytes, but we only really need to read this part
    [0x03BEBC] = {type="bit", name="Teleporter", receiveFunc=recieveTeleporter}, -- 1st castle
    [0x03BEBD] = {type="bit", name="Teleporter", receiveFunc=recieveTeleporter}, -- 2nd castle
    -- switches and bridges
    [0x03BDED] = {type="num", name="Caverns Switch", receiveFunc=recieveSummon}, -- BUG: cannot be on same screen as pink areas or other person can freeze
    [0x03BEB3] = {type="bit", name="Waterfall Switch", receiveFunc=recieveTeleporter}, -- waterfall switch and wooden bridge at same memory address
    [0x03BE1C] = {type="num", name="Merman Switch", receiveFunc=recieveTeleporter},
    [0x03BE1D] = {type="num", name="Marble Shortcut Switch", receiveFunc=recieveTeleporter},
    [0x03BE1E] = {type="num", name="Warp Switch", receiveFunc=recieveTeleporter},
    [0x03BE2E] = {type="num", name="Light Switch", receiveFunc=recieveTeleporter},
    [0x03BDFC] = {type="num", name="Elevator Switch", receiveFunc=recieveTeleporter},
    [0x03BE4C] = {type="num", name="Chapel Statue", receiveFunc=recieveTeleporter},
    [0x03BE9D] = {type="num", name="Colosseum Gate", receiveFunc=recieveTeleporter},
    [0x03BE3C] = {type="num", name="First Demon Button", receiveFunc=recieveTeleporter},
    [0x03BE44] = {type="num", name="Second Demon Button", receiveFunc=recieveTeleporter},
    [0x03BE80] = {type="num", name="Castle Keep Secret", receiveFunc=recieveTeleporter},
    [0x03BE9E] = {type="num", name="Colosseum Elevator", receiveFunc=recieveTeleporter},
    [0x03BE6F] = {type="num", name="Marble Elevator", receiveFunc=recieveTeleporter},
    --TODO: add both clocktower puzzles
    --[[ 1st castle:
    1C1681 = 2
    1C1683 = 8
    1C1685 = 3
    1C1685 = 0xE or 14
    BUT does not update door state on the fly. can't quite get it to work!
    maybe it will work if the clocktower area is reloaded?
    --]]
}

-- Display a message of the ram event
function getGUImessage(address, prevVal, newVal, user)
    -- No need to display messages to ourselves
    if user == config.user then
        return
    end
	-- Only display the message if there is a name for the address
    -- and if the name is not your name
	local name = ramItems[address].name
	if name and prevVal ~= newVal then
		-- If boolean, show 'Removed' for false
		if ramItems[address].type == "bool" then				
			gui.addmessage(user .. ": " .. name .. (newVal == 0 and 'Removed' or ''))
		-- If numeric, show the indexed name or name with value
		elseif ramItems[address].type == "num" then
			if (type(name) == 'string') then
                if (0x09797D <= address and address <= 0x097981) then
                    -- handle vlady daddys specially
                    -- count how many we have by going through the vlady daddy addys
                    local count = 0
                    local memval = 0
                    for addy=0x09797D,0x097981 do
                        memval = readRAM("MainRAM", addy, 1)
                        if memval > 0 then 
                            count = count + 1
                        end
                    end
                    
                    -- account for the fact that the clients will be off by one
                    if user ~= config.user then
                        count = count + 1
                    end
                    
                    messageLine1 = user
                    if count == 5 then
                        messageLine2 = "found the FINAL VladyDaddy"
                        messageLine3 = "Go mode engaged!"
                    else
                        messageLine2 = "found a VladyDaddy"
                        messageLine3 = "Current count = " .. count .. "/5"
                    end
                else
                    messageLine1 = user
                    messageLine2 = "unlocked the"
                    messageLine3 = name .. "!"
                end
                -- capture the time of the acquisition
                messageTimer = emu.framecount()
			elseif (name[newVal]) then
				gui.addmessage(user .. ": " .. name[newVal])
			end
		-- If bitflag, show each bit: the indexed name or bit index as a boolean
		elseif ramItems[address].type == "bit" then
            if address == 0x03BEB3 then -- special case for waterfall switch and wooden bridge
                local newBit = bit.check(newVal, 0)
				local prevBit = bit.check(prevVal, 0)
                
                if (newBit ~= prevBit) then
                    if (type(name) == 'string') then
                        messageLine1 = user
                        messageLine2 = "unlocked the"
                        messageLine3 = "Waterfall Switch!"
                        messageTimer = emu.framecount()
                    end
                end
                
                newBit = bit.check(newVal, 1)
				prevBit = bit.check(prevVal, 1)
                
                if (newBit ~= prevBit) then
                    if (type(name) == 'string') then
                        messageLine1 = user
                        messageLine2 = "unlocked the"
                        messageLine3 = "Wooden Bridge!"
                        messageTimer = emu.framecount()
                    end
                end
            else
                -- teleporter unlocks
                -- lowest bit is Entrance
                -- next lowest bit is Catacombs
                -- next lowest bit is Outer Wall
                -- next lowest bit is Keep
                -- next lowest bit is Olrox
                for b=0,7 do
                    local newBit = bit.check(newVal, b)
                    local prevBit = bit.check(prevVal, b)

                    if (newBit ~= prevBit) then
                        if (type(name) == 'string') then
                            messageLine1 = user
                            messageLine2 = "unlocked the"
                            if (b == 0) then
                                messageLine3 = "Entrance Teleporter!"
                            elseif (b == 1) then
                                messageLine3 = "Abandoned Mine Teleporter!"
                            elseif (b == 2) then
                                messageLine3 = "Outer Wall Teleporter!"
                            elseif (b == 3) then
                                messageLine3 = "Castle Keep Teleporter!"
                            elseif (b == 4) then
                                messageLine3 = "Olrox Quarters Teleporter!"
                            else
                                messageLine3 = "?!?!?!"
                            end
                            
                            if (address == 0x03BEBD) then -- special case for inverted teleporters
                                messageLine3 = "Inverted " .. messageLine3
                            end
                            -- capture the time of the acquisition
                            messageTimer = emu.framecount()
                        elseif (name[b]) then
                            gui.addmessage(user .. ": " .. name[b] .. (newBit and '' or ' Removed'))
                        end
                    end
                end
            end
		-- if delta, show the indexed name, or the differential
		elseif ramItems[address].type == "delta" then
			local delta = newVal - prevVal
			if (delta > 0) then
				if (type(name) == 'string') then
					gui.addmessage(user .. ": " .. name .. (delta > 0 and " +" or " ") .. delta)
				elseif (name[newVal]) then
					gui.addmessage(user .. ": " .. name[newVal])
				end
			end
		else 
			gui.addmessage("Unknown item ram type")
		end
	end
end


-- Get the list of ram values
function getRAM() 
	newRAM = {}
	for address, item in pairs(ramItems) do
        -- Default byte length to 1
        if (not item.size) then
            item.size = 1
        end

        local ramval = readRAM("MainRAM", address, item.size)

        -- Apply bit mask if it exist
        if (item.mask) then
            ramval = bit.band(ramval, item.mask)
        end

        newRAM[address] = ramval
	end

	return newRAM
end


-- Get a list of changed ram events
function eventRAMchanges(prevRAM, newRAM)
	local ramevents = {}
	local changes = false

	for address, val in pairs(newRAM) do
		-- If change found
		if (prevRAM[address] ~= val) then
			getGUImessage(address, prevRAM[address], val, config.user)

			-- If boolean, get T/F
			if ramItems[address].type == "bool" then
				ramevents[address] = (val ~= 0)
				changes = true
			-- If numeric, get value
			elseif ramItems[address].type == "num" then
				ramevents[address] = val				
				changes = true
			-- If bitflag, get the changed bits
			elseif ramItems[address].type == "bit" then
				local changedBits = {}
				for b=0,7 do
					local newBit = bit.check(val, b)
					local prevBit = bit.check(prevRAM[address], b)

					if (newBit ~= prevBit) then
						changedBits[b] = newBit
					end
				end
				ramevents[address] = changedBits
				changes = true
			-- If delta, get the change from prevRAM frame
			elseif ramItems[address].type == "delta" then
				ramevents[address] = val - prevRAM[address]
				changes = true
			else 
				printOutput("Unknown item ram type")
			end
		end
	end

	if (changes) then
		return ramevents
	else
		return false
	end
end


-- set a list of ram events
function setRAMchanges(prevRAM, their_user, newEvents)
	for address, val in pairs(newEvents) do
		local newval

		-- If boolean type value
		if ramItems[address].type == "bool" then
			newval = (val and 1 or 0)
		-- If numeric type value
		elseif ramItems[address].type == "num" then
			newval = val
		-- If bitflag update each bit
		elseif ramItems[address].type == "bit" then
			newval = prevRAM[address]
			for b, bitval in pairs(val) do
				if bitval then
					newval = bit.set(newval, b)
				else
					newval = bit.clear(newval, b)
				end
			end
		-- If delta, add to the previous value
		elseif ramItems[address].type == "delta" then
			newval = prevRAM[address] + val
		else 
			printOutput("Unknown item ram type")
			newval = prevRAM[address]
		end

		-- Run the address's reveive function if it exists
		if (ramItems[address].receiveFunc) then
			newval = ramItems[address].receiveFunc(newval, prevRAM[address], address, ramItems[address], their_user)
		end

		-- Apply the address's bit mask
		if (ramItems[address].mask) then
			local xMask = bit.bxor(ramItems[address].mask, 0xFF)
			local prevval = readRAM("MainRAM", address, ramItems[address].size)

			prevval = bit.band(prevval, xMask)
			newval = bit.band(newval, ramItems[address].mask)
			newval = bit.bor(prevval, newval)
		end

		-- Write the new value
		getGUImessage(address, prevRAM[address], newval, their_user)
		prevRAM[address] = newval
        
		writeRAM("MainRAM", address, ramItems[address].size, newval)
	end	
	return prevRAM
end

prevDomain = ""

local messageQueue = {first = 0, last = -1}
function messageQueue.isEmpty()
	return messageQueue.first > messageQueue.last
end
function messageQueue.pushLeft (value)
  local first = messageQueue.first - 1
  messageQueue.first = first
  messageQueue[first] = value
end
function messageQueue.pushRight (value)
  local last = messageQueue.last + 1
  messageQueue.last = last
  messageQueue[last] = value
end
function messageQueue.popLeft ()
  local first = messageQueue.first
  if messageQueue.isEmpty() then error("list is empty") end
  local value = messageQueue[first]
  messageQueue[first] = nil        -- to allow garbage collection
  messageQueue.first = first + 1
  return value
end
function messageQueue.popRight ()
  local last = messageQueue.last
  if messageQueue.isEmpty() then error("list is empty") end
  local value = messageQueue[last]
  messageQueue[last] = nil         -- to allow garbage collection
  messageQueue.last = last - 1
  return value
end

-- Gets a message to send to the other player of new changes
-- Returns the message as a dictionary object
-- Returns false if no message is to be send
function sotn_ram.getMessage()
--[[
	-- Game was just loaded, restore to previous known RAM state
	if (gameLoaded and not gameLoadedModes[prevGameMode]) then
		 -- get changes to prevRAM and apply them to game RAM
		local newRAM = getRAM()
		local message = eventRAMchanges(newRAM, prevRAM)
		prevRAM = newRAM
		if (message) then
			sotn_ram.processMessage("Save Restore", message)
		end
	end
--]]

    -- Initilize previous RAM frame if missing
	if prevRAM == nil then
		prevRAM = getRAM()
	end

	-- Load all queued changes
	while not messageQueue.isEmpty() do
		local nextmessage = messageQueue.popLeft()
		sotn_ram.processMessage(nextmessage.their_user, nextmessage.message)
	end
    
	-- Get current RAM events
	local newRAM = getRAM()
	local message = eventRAMchanges(prevRAM, newRAM)

	-- Update the RAM frame pointer
	prevRAM = newRAM

	return message
end

local splitItems = {}

-- Process a message from another player and update RAM
function sotn_ram.processMessage(their_user, message)
    
    -- special initial item messages
    if message["i"] then
		splitItems = message["i"]
		message["i"] = nil
    end
        
    --messageQueue.pushRight({["their_user"]=their_user, ["message"]=message})
    prevRAM = setRAMchanges(prevRAM, their_user, message)


	--[[if gameLoadedModes[gameMode] then
		prevRAM = setRAMchanges(prevRAM, their_user, message)
	else
		messageQueue.pushRight({["their_user"]=their_user, ["message"]=message})
	end--]]
end

sotn_ram.itemcount = 30

local verticalOffset = 70
local lineOffset = 16
local fontSize = 12
local maxMessageTime = 180
local textColor = 0x7FFFFFFF
local bgColor = 0x7F0000FF

function RelicText()
    local curFrameCount = emu.framecount()
    
    if (curFrameCount - messageTimer < maxMessageTime) then
        gui.drawText(client.bufferwidth()/2, client.bufferheight()/2 + verticalOffset, messageLine1, textColor, bgColor, fontSize, "Calibri", "bold", "center", "middle")
        gui.drawText(client.bufferwidth()/2, client.bufferheight()/2 + verticalOffset + lineOffset, messageLine2, textColor, bgColor, fontSize, "Calibri", "bold", "center", "middle")
        gui.drawText(client.bufferwidth()/2, client.bufferheight()/2 + verticalOffset + lineOffset + lineOffset, messageLine3, textColor, bgColor, fontSize, "Calibri", "bold", "center", "middle")
    end
end

event.onframeend(RelicText, "RelicText")

return sotn_ram