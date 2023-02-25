HITMAN = {}
timer.Simple(0, function()
    HITMAN.config = {
        -- Работы, которые не смогут заказывать
        cantOrder = {
            [TEAM_MAYOR] = true,
        },
        -- Работы, которые смогут выполнять заказы
        hitmanJobs = {
            [TEAM_COOK] = true,
        },
        -- Минимальная и максимальная сумма
        price = {1000, 30000},
        -- Может ли киллер сам делать закзаы
        canHitmanOrder = true,
        -- Профессия, на которую сменится после смерти жертвы
        teamOnDeath = TEAM_CITIZEN,
        -- Цветовая схема
        colors = {
            btnColor = Color(16, 172, 132),
            primary = Color(30, 30, 30),
            secondary = Color(25, 25, 25),
            tertiary = Color(35, 35, 35),
            bg = Color(10, 10, 10, 230),
            title = Color(47, 54, 64, 230),
            text = Color(240, 240, 240),
        }
    }
end)

local path = "hitman/"
if SERVER then
    local _, folders = file.Find(path .. "*", "LUA")

    for _, folder in SortedPairs(folders, true) do
        print("Loading folder:", folder)

        for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
            print("	Loading file:", File)
            AddCSLuaFile(path .. folder .. "/" .. File)
            include(path .. folder .. "/" .. File)
        end

        for b, File in SortedPairs(file.Find(path .. folder .. "/sv_*.lua", "LUA"), true) do
            include(path .. folder .. "/" .. File)
        end

        for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
            print("	Loading file:", File)
            AddCSLuaFile(path .. folder .. "/" .. File)
        end
    end
end

if CLIENT then
    local _, folders = file.Find(path .. "*", "LUA")

    for _, folder in SortedPairs(folders, true) do
        print("Loading folder:", folder)

        for b, File in SortedPairs(file.Find(path .. folder .. "/sh_*.lua", "LUA"), true) do
            print("	Loading file:", File)
            include(path .. folder .. "/" .. File)
        end

        for b, File in SortedPairs(file.Find(path .. folder .. "/cl_*.lua", "LUA"), true) do
            print("	Loading file:", File)
            include(path .. folder .. "/" .. File)
        end
    end
end