local function Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Notification",
        Text = text or "",
        Duration = duration or 3,
        Button1 = "OK"
    })
end

spawn(function()
    local getgc = getgc or debug.getgc
    local hookfunction = hookfunction
    local getrenv = getrenv
    local debugInfo = (getrenv and getrenv().debug and getrenv().debug.info) or debug.info
    local newcclosure = newcclosure or function(f) return f end

    if not (getgc and hookfunction and getrenv and debugInfo) then
        Notify("Adonis Bypasser", "Required exploit functions not available. Skipping Adonis bypass.", 3)
        return
    end

    local IsDebug = false
    local DetectedMeth, KillMeth
    local AdonisFound = false
    local hooks = {}

    for _, value in getgc(true) do
        if typeof(value) == "table" then
            local hasDetected = typeof(rawget(value, "Detected")) == "function"
            local hasKill = typeof(rawget(value, "Kill")) == "function"
            local hasVars = rawget(value, "Variables") ~= nil
            local hasProcess = rawget(value, "Process") ~= nil

            if hasDetected or (hasKill and hasVars and hasProcess) then
                AdonisFound = true
                break
            end
        end
    end

    if not AdonisFound then
        --Notify("Adonis Bypasser", "Adonis not found. Bypass skipped.", 3)
        return
    end

    for _, value in getgc(true) do
        if typeof(value) == "table" then
            local detected = rawget(value, "Detected")
            local kill = rawget(value, "Kill")

            if typeof(detected) == "function" and not DetectedMeth then
                DetectedMeth = detected
                local hook
                hook = hookfunction(DetectedMeth, function(methodName, methodFunc)
                    if methodName ~= "_" and IsDebug then
                        Notify("Adonis Detected", "Method: "..methodName, 3)
                    end
                    return true
                end)
                table.insert(hooks, DetectedMeth)
                Notify("Adonis Bypasser", "Hooked Adonis 'Detected' method.", 3)
            end

            if rawget(value, "Variables") and rawget(value, "Process") and typeof(kill) == "function" and not KillMeth then
                KillMeth = kill
                local hook
                hook = hookfunction(KillMeth, function(killFunc)
                    if IsDebug then
                        Notify("Adonis tried to kill function", tostring(killFunc), 3)
                    end
                end)
                table.insert(hooks, KillMeth)
                Notify("Adonis Bypasser", "Hooked Adonis 'Kill' method.", 3)
            end
        end
    end

    if DetectedMeth and debugInfo then
        local hook
        hook = hookfunction(debugInfo, newcclosure(function(...)
            local functionName = ...
            if functionName == DetectedMeth then
                -- Bypass detection by yielding coroutine
                return coroutine.yield(coroutine.running())
            end
            return hook(...)
        end))
    end
end)
