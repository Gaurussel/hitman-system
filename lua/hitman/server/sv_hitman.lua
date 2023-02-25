util.AddNetworkString("hitman.AddOrder")
util.AddNetworkString("hitman.RemoveOrder")
util.AddNetworkString("hitman.OpenMenu")
HITMAN.activeOrders = HITMAN.activeOrders or {}

function AddOrder(victim, client, price)
    if HITMAN.config.cantOrder[client:Team()] then
        DarkRP.notify(client, 1, 4, "У вас нет доступа!")

        return
    end

    if HITMAN.activeOrders[victim:AccountID()] then
        DarkRP.notify(client, 1, 4, "На этого человека уже сделан заказ!")

        return
    end

    if price < HITMAN.config.price[1] or price > HITMAN.config.price[2] then
        DarkRP.notify(client, 1, 4, "Неверная сумма заказа! От " .. DarkRP.formatMoney(HITMAN.config.price[1]) .. " до " .. DarkRP.formatMoney(HITMAN.config.price[2]))

        return
    end

    if not client:canAfford(price) then
        DarkRP.notify(client, 1, 4, "У вас недостаточно денег для этого!")

        return
    end

    HITMAN.activeOrders[victim:AccountID()] = {
        customer = client:AccountID(),
        price = price,
        name = victim:Name()
    }

    client:addMoney(-price)
    DarkRP.notify(client, 0, 4, "Вы разместили заказ на убийство на " .. victim:Name() .. ".")

    for k, v in pairs(player.GetAll()) do
        if not HITMAN.config.hitmanJobs[v:Team()] then continue end
        net.Start("hitman.AddOrder")
        net.WriteEntity(victim)
        net.WriteUInt(price, 24)
        net.Send(v)
    end
end

function RemoveOrder(victim)
    if not HITMAN.activeOrders[victim:AccountID()] then return end
    HITMAN.activeOrders[victim:AccountID()] = nil

    for id, ply in pairs(player.GetAll()) do
        if not HITMAN.config.hitmanJobs[ply:Team()] then continue end
        net.Start("hitman.RemoveOrder")
        net.WriteEntity(victim)
        net.Send(ply)
    end
end

function GetOrder(victim)
    return HITMAN.activeOrders[victim:AccountID()]
end

hook.Add("PlayerDeath", "hitman.PlayerDeath", function(victim, _, attacker)
    local victimID = victim:AccountID()
    local order = GetOrder(victim)
    if not order then return end

    if not attacker:IsPlayer() then
        local customer = player.GetByAccountID(HITMAN.activeOrders[victimID].customer)

        if IsValid(customer) then
            DarkRP.notify(customer, 2, 4, "Наёмник выполнил ваш заказ на убийство!")
        end

        for k, v in pairs(player.GetAll()) do
            if not HITMAN.config.hitmanJobs[v:Team()] then continue end
            net.Start("hitman.RemoveOrder")
            net.WriteEntity(victim)
            net.Send(v)
        end

        RemoveOrder(victim)

        return
    end

    attacker:addMoney(order.price)

    if HITMAN.config.needChangeTeam then
        victim:changeTeam(HITMAN.config.teamOnDeath, true)
    end

    DarkRP.notify(victim, 2, 4, "Вы были убиты по заказу наёмным убийцей!")
    DarkRP.notify(attacker, 2, 4, "Вы выполнили заказ и получили " .. DarkRP.formatMoney(order.price))
    local customer = player.GetByAccountID(HITMAN.activeOrders[victimID].customer)

    if IsValid(customer) then
        DarkRP.notify(customer, 2, 4, "Наёмник выполнил ваш заказ на убийство!")
    end

    for k, v in pairs(player.GetAll()) do
        if not HITMAN.config.hitmanJobs[v:Team()] then continue end
        net.Start("hitman.RemoveOrder")
        net.WriteEntity(victim)
        net.Send(v)
    end

    RemoveOrder(victim)
end)

hook.Add("PlayerChangedTeam", "hitman.PlayerChangedTeam", function(ply, _, newTeam)
    if not HITMAN.config.hitmanJobs[newTeam] then return end

    for k, v in pairs(HITMAN.activeOrders) do
        net.Start("hitman.AddOrder")
        net.WriteEntity(victim)
        net.WriteUInt(v.price, 24)
        net.Send(ply)
    end
end)

hook.Add("PlayerDisconnected", "hitman.PlayerDisconnected", function(ply)
    if GetOrder(ply) then
        for k, v in pairs(player.GetAll()) do
            if not HITMAN.config.hitmanJobs[v:Team()] then continue end
            net.Start("hitman.RemoveOrder")
            net.WriteEntity(ply)
            net.Send(v)
        end

        RemoveOrder(ply)
    end
end)

net.Receive("hitman.AddOrder", function(_, ply)
    if HITMAN.config.canHitmanOrder and HITMAN.config.hitmanJobs[ply:Team()] then
        DarkRP.notify(ply, 1, 4, "Киллеры не могут сами делать заказы")
        return
    end

    if HITMAN.GetTeamPlayers() < 1 then
        DarkRP.notify(ply, 1, 4, "На данный момент нет киллеров онлайн!")
        return
    end

    local victim = net.ReadEntity()
    local price = net.ReadUInt(24)
    AddOrder(victim, ply, price)
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