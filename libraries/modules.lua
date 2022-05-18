local client = {}; do
    coroutine.wrap(function()
        for i,v in pairs(getloadedmodules()) do
            if (v.Name == "camera") then
                client.camera = require(v);
            elseif (v.Name == "network") then
                client.network = require(v);
            elseif (v.Name == "particle") then
                client.particle = require(v);
            elseif (v.Name == "sound") then
                client.sound = require(v);
            elseif (v.Name == "input") then
                client.input = require(v);
            elseif (v.Name == "uiscaler") then
                client.uiscaler = require(v);
            elseif (v.Name == "effects") then
                client.effects = require(v);
            elseif (v.Name == "ScreenCull") then
                client.screencull = require(v);
            elseif (v.Name == "Raycast") then
                client.raycast = require(v);
            elseif (v.Name == "BulletCheck") then
                client.bulletcheck = require(v);
            elseif (v.Name == "ReplicationSmoother") then
                client.replicationsmoother = require(v);
            elseif (v.Name == "animation") then
                client.animation = require(v);
            elseif (v.Name == "spring") then
                client.spring = require(v);
            end
        end

        client.replication = debug.getupvalue(client.camera.setspectate, 1);
        client.char = debug.getupvalue(client.camera.step, 7);
        client.hud = debug.getupvalue(client.camera.step, 20);
        client.gamelogic = debug.getupvalue(client.hud.updateammo, 4);
        client.roundsystem = debug.getupvalue(client.hud.spot, 6);
        client.menu = debug.getupvalue(client.hud.radarstep, 1);
        client.loadplayer = debug.getupvalue(client.replication.getupdater, 2);
        client.remoteevent = client.network and debug.getupvalue(client.network.send, 1);
        client.networkfunctions = client.remoteevent and debug.getupvalue(getconnections(client.remoteevent.OnClientEvent)[1].Function, 1);

        setreadonly(client.particle, false);

        for i,v in pairs(client.networkfunctions) do
            local constants = debug.getconstants(v);

            if (table.find(constants, "KNIFE") and table.find(constants, "GRENADE")) then
                client.loadgun = debug.getupvalue(v, 6);
                client.loadknife = debug.getupvalue(v, 7);
            elseif (table.find(constants, "killfeed")) then
                client.killfeed = i;
            end
        end
    end)();
end
return client;
