local client = {}; do
    coroutine.wrap(function()
        local Modules = {scripts = {}}

        for i,v in pairs(getscripts()) do
            if (v:IsA("ModuleScript") and v.Parent == nil) then
                Modules[v.Name] = require(v)
                Modules.scripts[v.Name] = v
            end
        end

        client.camera = Modules.camera
        client.network = Modules.network
        client.particle = Modules.particle
        client.sound = Modules.sound
        client.input = Modules.input
        client.uiscaler = Modules.uiscaler
        client.effects = Modules.effects
        client.publicsettings = {
            bulletLifeTime = 1.5
        }
        client.screencull = Modules.ScreenCull
        client.raycast = Modules.Raycast
        client.bulletcheck = Modules.BulletCheck
        client.replicationsmoother = Modules.ReplicationSmoother
        client.trajectory = require(Modules.scripts.physics:Clone()).trajectory
        client.replication = debug.getupvalue(client.camera.setspectate, 1)
        client.char = debug.getupvalue(client.camera.step, 7)
        client.hud = debug.getupvalue(client.camera.step, 20)
        client.gamelogic = debug.getupvalue(client.hud.updateammo, 4)
        client.roundsystem = debug.getupvalue(client.hud.spot, 6)
        client.menu = debug.getupvalue(client.hud.radarstep, 1)
        client.loadplayer = debug.getupvalue(client.replication.getupdater, 2)
        client.remoteevent = client.network and debug.getupvalue(client.network.send, 1)
        client.networkfunctions = client.remoteevent and debug.getupvalue(getconnections(client.remoteevent.OnClientEvent)[1].Function, 1)

        setreadonly(client.particle, false)

        for i,v in pairs(client.networkfunctions) do
            local Constants = debug.getconstants(v)

            if (table.find(Constants, "KNIFE") and table.find(Constants, "GRENADE")) then
                client.loadgun = debug.getupvalue(v, 6)
                client.loadknife = debug.getupvalue(v, 7)
            end
        end
    end)()
end
return client
