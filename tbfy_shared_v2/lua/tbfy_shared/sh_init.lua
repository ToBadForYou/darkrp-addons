
TBFY_SH.Version = "2.0.5"

local ModulesFolder = "tbfy_shared/modules"
local files, directories = file.Find(ModulesFolder .. "/*", "LUA")
for k,v in pairs(directories) do
    local SHFiles = file.Find(ModulesFolder .. "/" .. v .. "/sh_*.lua", "LUA")
    for i,fn in pairs(SHFiles) do
        if SERVER then
            AddCSLuaFile(ModulesFolder .. "/" .. v .. "/" .. fn)
        end
        include(ModulesFolder .. "/" .. v .. "/" .. fn)
    end

    if SERVER then
        local SVFiles = file.Find(ModulesFolder .. "/" .. v .. "/sv_*.lua", "LUA")
        for i,fn in pairs(SVFiles) do
            include(ModulesFolder .. "/" .. v .. "/" .. fn)
        end
    end

    local CLFiles = file.Find(ModulesFolder .. "/" .. v .. "/cl_*.lua", "LUA")
    for i,fn in pairs(CLFiles) do
        if SERVER then
            AddCSLuaFile(ModulesFolder .. "/" .. v .. "/" .. fn)
        else
            include(ModulesFolder .. "/" .. v .. "/" .. fn)
        end
    end
end

if SERVER then
    resource.AddWorkshop("1900873878")

    local function VersionToNumbers(version)
        version = tostring(version or "0.0.0")

        local major, minor, patch = string.match(version, "(%d+)%.(%d+)%.(%d+)")

        return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
    end

    local function CompareVersions(a, b)
        local aMajor, aMinor, aPatch = VersionToNumbers(a)
        local bMajor, bMinor, bPatch = VersionToNumbers(b)

        if aMajor != bMajor then
            return aMajor > bMajor and 1 or -1
        end

        if aMinor != bMinor then
            return aMinor > bMinor and 1 or -1
        end

        if aPatch != bPatch then
            return aPatch > bPatch and 1 or -1
        end

        return 0
    end
    
    // Just checks lastest version
    hook.Add("PlayerConnect", "tbfy_check_version", function()
        local gitlink = "https://raw.githubusercontent.com/ToBadForYou/tbfy_shared/master/version.txt"


        http.Fetch(gitlink, function(contents, size)
            local LatestVersion = string.match(contents, "tbfy_shared%s=%s*(%d+%.%d+%.%d+)")

            if not LatestVersion then
                print("[TBFY_SHARED] Latest version could not be detected")
                return
            end

            local versionComparison = CompareVersions(TBFY_SH.Version, LatestVersion)

            if versionComparison >= 0 then
                print("[TBFY_SHARED] Up to date: v" .. TBFY_SH.Version)

                if versionComparison > 0 then
                    print("[TBFY_SHARED] Current version is newer than the public latest version: v" .. LatestVersion)
                end
            else
                print("[TBFY_SHARED] Outdated: v" .. LatestVersion .. " available, current version in use: v" .. TBFY_SH.Version)
                TBFY_SH.Outdated = true
            end
        end,
        function(message)
            print("[TBFY_SHARED] Failed to check for new update: " .. message)
        end)

        hook.Remove("PlayerConnect", "tbfy_check_version")
    end)
end
