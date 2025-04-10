local task_wait = function(x)
    return wait(x)
end
local esp_objects = {}
local a = {}
a.cache = {}
a.load = function(b)
    if not a.cache[b] then
        a.cache[b] = { c = a[b]() }
    end
    return a.cache[b].c
end

do
    function a.generator()
        return setmetatable({
            is_game_active = function()
                local map = workspace:FindFirstChild('Map')
                return map and map:FindFirstChild('Ingame') and map.Ingame:FindFirstChild('Map')
            end,

            get_active_generators = function()
                local active = {}
                local map = workspace:FindFirstChild('Map')
                if map and map:FindFirstChild('Ingame') and map.Ingame:FindFirstChild('Map') then
                    for _, gen in ipairs(map.Ingame.Map:GetChildren()) do
                        if gen.Name == 'Generator' and gen:IsA('Model') and gen:FindFirstChild('Progress') then
                            table.insert(active, gen)
                        end
                    end
                end
                return active
            end,

            validate_generator = function(gen)
                if not gen then return false end
                local map = workspace:FindFirstChild('Map')
                if not map then return false end
                return map:FindFirstChild(tostring(gen))
            end,

            get_progress_value = function(gen)
                return gen.Progress.Value
            end
        }, {})
    end
end

local generator_module = a.load('generator')


while true do
    task_wait(0.235)
    for id, circle in pairs(esp_objects) do
        if not generator_module.validate_generator(id) then
            circle:Remove()
            esp_objects[id] = nil
        end
    end
    if generator_module.is_game_active() then
        local generators = generator_module.get_active_generators()
        for _, gen in pairs(generators) do
            local id = tostring(gen)
            local should_break = false
            repeat
                if not gen then
                    if esp_objects[id] then
                        esp_objects[id]:Remove()
                        esp_objects[id] = nil
                    end
                    should_break = true
                    break
                end
                local main = gen:FindFirstChild('Main')
                if not main then
                    if esp_objects[id] then
                        esp_objects[id]:Remove()
                        esp_objects[id] = nil
                    end
                    should_break = true
                    break
                end
                if generator_module.get_progress_value(gen) >= 100 then
                    if esp_objects[id] then
                        esp_objects[id]:Remove()
                        esp_objects[id] = nil
                    end
                    should_break = true
                    break
                end
                local x, y = WorldToScreen(main.Position)
                local existing = esp_objects[id]
                if existing then
                    if not y then
                        existing:Remove()
                        esp_objects[id] = nil
                        should_break = true
                        break
                    end
                    existing.Position = x
                    should_break = true
                    break
                end
                if not y then
                    should_break = true
                    break
                end
                local circle = Drawing.new('Circle')
                circle.Position = Vector2(-5000, 0) 
                circle.Color = Color3(1, 1, 1)
                circle.NumSides = 6
                circle.Radius = 7
                circle.Visible = true
                circle.Filled = false
                esp_objects[id] = circle
                circle.Position = x
                should_break = true
            until true

            if not should_break then break end
        end
    else
        for id, circle in pairs(esp_objects) do
            circle:Remove()
            esp_objects[id] = nil
        end
    end
end
