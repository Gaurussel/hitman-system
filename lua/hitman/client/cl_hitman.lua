HITMAN = HITMAN or {}
HITMAN.config = HITMAN.config or {}
HITMAN.activeOrders = HITMAN.activeOrders or {}
local countOrders = 0
local localplayer = LocalPlayer()
local canHitman = false

local function loadFonts()
    surface.CreateFont("HitmanOrder", {
        font = "Roboto",
        antialias = true,
        shadow = false,
        size = ScreenScale(7),
        extended = true
    })

    surface.CreateFont("htRoboto30", {
        font = "Roboto",
        antialias = true,
        shadow = false,
        size = 30,
        extended = true
    })

    surface.CreateFont("htRoboto25", {
        font = "Roboto",
        antialias = true,
        shadow = false,
        size = 25,
        extended = true
    })

    surface.CreateFont("htRoboto20", {
        font = "Roboto",
        antialias = true,
        shadow = false,
        size = 20,
        extended = true
    })

    surface.CreateFont("htRoboto70", {
        font = "Roboto",
        antialias = true,
        shadow = false,
        size = 70,
        extended = true
    })
end

loadFonts()

function RemoveOrder(victimID)
    HITMAN.activeOrders[victimID] = nil
end

hook.Add("Tick", "hitman.tick", function()
    if not IsValid(localplayer) then
        localplayer = LocalPlayer()

        return
    end

    if HITMAN.config.hitmanJobs[localplayer:Team()] then
        canHitman = true
    else
        canHitman = false
    end

    countOrders = table.Count(HITMAN.activeOrders) or 1
end)

local scrw, scrh = ScrW(), ScrH()

hook.Add("HUDPaint", "hitman.HUDPaint", function()
    if not canHitman then
        return
    end

    local wide, _ = scrw * .15, scrh * 0.1
    local x, y = scrw * 1 - wide, scrh * 0.03

    surface.SetFont("HitmanOrder")
    local _, tY = surface.GetTextSize("Активные заказы")
    surface.SetDrawColor(HITMAN.config.colors.title)
    surface.DrawRect(x, 0, wide, scrh * 0.03)
    surface.SetTextColor(HITMAN.config.colors.text)
    surface.SetTextPos(x + 5, (y - tY) / 2)

    surface.DrawText("Активные заказы")
    surface.SetDrawColor(HITMAN.config.colors.bg)
    surface.DrawRect(x, y, wide, (y * 0.7) * countOrders)
    local oY = y

    for _, data in SortedPairsByMemberValue(HITMAN.activeOrders, "price", true) do
        surface.SetTextColor(HITMAN.config.colors.text)
        surface.SetTextPos(x + 5, oY)
        surface.DrawText(data.name)

        local price = DarkRP.formatMoney(data.price)
        local tW, _ = surface.GetTextSize(price)

        surface.SetTextColor(HITMAN.config.colors.text)
        surface.SetTextPos(scrw - tW - 5, oY)
        surface.DrawText(price)

        oY = oY + tY + 2
    end
end)

net.Receive("hitman.AddOrder", function()
    local victim = net.ReadEntity()
    local price = net.ReadUInt(24)

    if victim then
        table.insert(HITMAN.activeOrders, {
            price = price,
            name = victim:Name()
        })
    end
end)

net.Receive("hitman.RemoveOrder", function()
    local victim = net.ReadEntity()
    local name = victim:Name()

    for k, v in ipairs(HITMAN.activeOrders) do
        if v.name != name then
            continue
        end

        HITMAN.activeOrders[k] = nil
        break
    end
end)

function HITMAN.GetTeamPlayers()
    local count = 0

    for job, _ in pairs(HITMAN.config.hitmanJobs) do
        count = count + team.NumPlayers(job)
    end

    return count
end

-- concommand.Add("getordersh", function()
--     PrintTable(HITMAN.activeOrders)
-- end)

-- concommand.Add("resetorders", function()
--     HITMAN.activeOrders = {}
-- end)