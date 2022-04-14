local Math = {
    physicsignore = {workspace:FindFirstChild("Players"), workspace.CurrentCamera, workspace:FindFirstChild("Ignore")},
    raycast = workspace.FindPartOnRayWithIgnoreList,
    wraycast = workspace.FindPartOnRayWithWhitelist,
    tau = 2 * 3.141592653589793,
    ldt = 0.016666666666666666,
    dot = Vector3.new().Dot,
    pi = 3.141592653589793,
    e = 2.718281828459045,
    atan2 = math.atan2,
    asin = math.asin,
    cos = math.cos,
    sin = math.sin,
    err = 1.0E-10,
    v3 = Vector3.new()
}

local function solve(a, b, c, d, e)
    if not a then
        return
    elseif a > -Math.err and a < Math.err then
        return solve(b, c, d, e)
    end

    if e then
        local k = -b / (4 * a)
        local p = (8 * a * c - 3 * b * b) / (8 * a * a)
        local q = (b * b * b + 8 * a * a * d - 4 * a * b * c) / (8 * a * a * a)
        local r = (16 * a * a * b * b * c + 256 * a * a * a * a * e - 3 * a * b * b * b * b - 64 * a * a * a * b * d) / (256 * a * a * a * a * a)
        local h0, h1, h2 = solve(1, 2 * p, p * p - 4 * r, -q * q)
        local s = h2 or h0

        if s < Math.err then
            local f0, f1 = solve(1, p, r)

            if not f1 or f1 < 0 then
                return
            else
                local f = f1 ^ 0.5

                return k - f, k + f
            end
        else
            local h = s ^ 0.5
            local f = (h * h * h + h * p - q) / (2 * h)

            if f > -Math.err and f < Math.err then
                return k - h, k
            else
                local r0, r1 = solve(1, h, f)
                local r2, r3 = solve(1, -h, r / f)

                if r0 and r2 then
                    return k + r0, k + r1, k + r2, k + r3
                elseif r0 then
                    return k + r0, k + r1
                elseif r2 then
                    return k + r2, k + r3
                else
                    return
                end
            end
        end
    elseif d then
        local k = -b / (3 * a)
        local p = (3 * a * c - b * b) / (9 * a * a)
        local q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (54 * a * a * a)
        local r = p * p * p + q * q
        local s = r ^ 0.5 + q

        if s > -Math.err and s < Math.err then
            if q < 0 then
                return k + (-2 * q) ^ 0.3333333333333333
            else
                return k - (2 * q) ^ 0.3333333333333333
            end
        elseif r < 0 then
            local m = (-p) ^ 0.5
            local d = Math.atan2((-r) ^ 0.5, q) / 3
            local u = m * Math.cos(d)
            local v = m * Math.sin(d)

            return k - 2 * u, k + u - 1.7320508075688772 * v, k + u + 1.7320508075688772 * v
        elseif s < 0 then
            local m = -(-s) ^ 0.3333333333333333

            return k + p / m - m
        else
            local m = s ^ 0.3333333333333333

            return k + p / m - m
        end
    elseif c then
        local k = -b / (2 * a)
        local u2 = k * k - c / a

        if u2 < 0 then
            return
        else
            local u = u2 ^ 0.5

            return k - u, k + u
        end
    elseif b then
        return -b / a
    else
        return
    end
end -- returns travel time
Math.solve = solve

local function bulletcheck(o, t, p) -- origin, target, penetrationdepth
    if p <= 0.01 then
        return false
    end
    
    local ve = t - o
    local n = ve.Unit
    local h, po = Math.raycast(workspace, Ray.new(o, ve), Math.physicsignore)

    if h then
        if h.CanCollide and h.Transparency == 0 and h.Name ~= "Window" then
            local e = h.Size.Magnitude * n
            local nh, dp = Math.wraycast(workspace, Ray.new(po + e, -e), {h})
            local m = (dp - po).Magnitude

            if m >= p then
                return false
            else
                p = p - m
            end
        end

        return bulletcheck(po + n / 100, t, p)
    end

    return true
end -- returns if the bullet passed
Math.bulletcheck = bulletcheck

local function farthestpoint(o, ve, p) -- origin, velocity, penetrationdepth
    if p <= 0.01 then
        return o
    end
    
    local n = ve.Unit
    local h, po = Math.raycast(workspace, Ray.new(o, ve), Math.physicsignore)

    if h then
        if h.CanCollide and h.Transparency == 0 and h.Name ~= "Window" then
            local e = h.Size.Magnitude * n
            local nh, dp = Math.wraycast(workspace, Ray.new(po + e, -e), {h})
            local m = (dp - po).Magnitude

            if m >= p then
                return po
            else
                p = p - m
            end
        end

        return farthestpoint(po + n / 100, ve, p)
    end

    return o + ve
end -- returns the farthest point the bullet will go
Math.farthestpoint = farthestpoint

local function scanplayer(s, d, r, e) -- origin, target, radius, penetrationdepth
    local c = CFrame.new(s, d)

    for p = 1, 2 do
        p = (p - 1) * 45
        local cf = c * CFrame.Angles(0, math.rad(p), 0)

        for i = 1, 2 do
            i = i * 45
            
            for k, o in pairs({
                cf,
                cf * CFrame.Angles(math.rad(i), 0, 0),
                cf * CFrame.Angles(-math.rad(i), 0, 0)
            }) do
                local v = (o * CFrame.new(0, 0, -r)).Position

                if bulletcheck(v, d, e) then
                    return v
                end
            end
            
            for k, o in pairs({
                cf,
                cf * CFrame.Angles(0, 0, -math.rad(i)),
                cf * CFrame.Angles(0, 0, math.rad(i))
            }) do
                local v = (o * CFrame.new(r, 0, 0)).Position

                if bulletcheck(v, d, e) then
                    return v
                end
                if p == 0 then
                    local q = (o * CFrame.new(-r, 0, 0)).Position

                    if bulletcheck(q, d, e) then
                    	return q
		            end
                end
            end
        end
    end
    
    return false
end -- returns a firepos
Math.scanplayer = scanplayer

local function scanplayerwithtpr(s, d, r, e, j) -- origin, target, scan radius, penetrationdepth, max tp radius
    local c = CFrame.new(s, d)

    for p = 1, 2 do
        p = (p - 1) * 45
        local cf = c * CFrame.Angles(0, math.rad(p), 0)

        for i = 1, 2 do
            i = i * 45
            
            for k, o in pairs({
                cf,
                cf * CFrame.Angles(math.rad(i), 0, 0),
                cf * CFrame.Angles(-math.rad(i), 0, 0)
            }) do
                local m = (o * CFrame.new(0, 0, -j)).Position
                local v = (o * CFrame.new(0, 0, -r - ((s - m).Magnitude))).Position

                if Math.vischeck(s, m) and bulletcheck(v, d, e) then
                    return v, m
                end
            end
            
            for k, o in pairs({
                cf,
                cf * CFrame.Angles(0, 0, -math.rad(i)),
                cf * CFrame.Angles(0, 0, math.rad(i))
            }) do
                local m = (o * CFrame.new(j, 0, 0)).Position
                local v = (o * CFrame.new(r + ((s - m).Magnitude), 0, 0)).Position

                if Math.vischeck(s, m) and bulletcheck(v, d, e) then
                    return v, m
                end

                if p == 0 then
                    local mm = (o * CFrame.new(-j, 0, 0)).Position
		            local q = (o * CFrame.new(-r - ((s - mm).Magnitude), 0, 0)).Position

		            if Math.vischeck(s, mm) and bulletcheck(q, d, e) then
                    	return q, mm
		            end
                end
            end
        end
    end
    
    return false
end -- returns a firepos and a visible pos in the radius
Math.scanplayerwithtpr = scanplayerwithtpr

function Math.minpos(t) -- list
    for i, v in pairs(t) do
        if v and v >= 0 then
            return v
        end
    end
end -- returns the smallest number

function Math.vischeck(o, t) -- origin, target
    local cf = CFrame.new(o, t)
    local d = (o - t).Magnitude
    local os = {
        cf * CFrame.new(Vector3.new(0.3, 0.3, -0.3)),
        cf * CFrame.new(Vector3.new(-0.3, 0.3, -0.3)),
        cf * CFrame.new(Vector3.new(0.3, -0.3, -0.3)),
        cf * CFrame.new(Vector3.new(-0.3, -0.3, -0.3))
    }

    for i, v in pairs(os) do
        local o0 = v.Position
        local t0 = (v * CFrame.new(0, 0, -d)).Position

        if workspace:FindPartOnRayWithIgnoreList(Ray.new(o0, t0 - o0), Math.physicsignore) ~= nil then
            return false
        end
    end

    return true
end -- returns if anything is between the positions

function Math.closestvisiblepos(o, t) -- origin, target
    local cf = CFrame.new(o, t)
    local d = (o - t).Magnitude
    local f = math.huge
    local os = {
        cf,
        cf * CFrame.new(Vector3.new(0.25, 0.25, 0)),
        cf * CFrame.new(Vector3.new(-0.25, 0.25, 0)),
        cf * CFrame.new(Vector3.new(0.25, -0.25, 0)),
        cf * CFrame.new(Vector3.new(-0.25, -0.25, 0))
    }

    for i, v in pairs(os) do
        local o0 = v.Position
        local t0 = (v * CFrame.new(0, 0, -d)).Position
        local _, t1 = workspace:FindPartOnRayWithIgnoreList(Ray.new(o0, t0 - o0), Math.physicsignore)
        local d0 = (o0 - t1).Magnitude

        if d - d0 > 0.1 and d0 < f then
            t = (cf * CFrame.new(0, 0, 2 - d0)).Position
            f = d0
        end
    end

    return t
end -- returns the closest visible position between the arguments

function Math.timehit(o, ve, a, t) -- origin, velocity, acceleration, target
	local d = o - t
	local st = 0
	local n = (1 / 0)

    for i, v in pairs({solve(Math.dot(a, a), 3 * Math.dot(a, ve), 2 * (Math.dot(a, d) + Math.dot(ve, ve)), 2 * Math.dot(d, ve))}) do
		local m = (d + v * ve + v * v / 2 * a).Magnitude

		if st < v and m < n then
			st = v
			n = m
		end
	end

	return st, n
end -- returns the time for the bullet to hit and the distance

function Math.trajectory(o, a, t, s, e) -- origin, acceleration, target, speed, offset 
    local f = -a
    local ld = t - o
    local a = Math.dot(f, f)
    local b = 4 * Math.dot(ld, ld)
    local k = (4 * (Math.dot(f, ld) + s * s)) / (2 * a)
    local v = (k * k - b / a) ^ 0.5
    local t, t0 = k - v, k + v

    if not (t > 0) then
        t = t0
    end

    t = t ^ 0.5
    return f * t / 2 + (e or Math.v3) + ld / t, t
end -- returns the trajectory velocity

function Math.old_trajectory(pp, pv, pa, tp, tv, ta, s) -- origin, addition offset, acceleration, target, addition, accel offset, speed
    local rp = tp - pp
    local rv = tv - pv
    local ra = ta - pa

    for i, v in pairs({solve(Math.dot(ra, ra) / 4, Math.dot(ra, rv), Math.dot(ra, rp) + Math.dot(rv, rv) - s * s, 2 * Math.dot(rp, rv), Math.dot(rp, rp))}) do
        if v and v > 0 then
            return ra * v / 2 + tv + rp / v, v
        end
    end
end -- returns the trajectory velocity

function Math.simple_trajectory(s, a, r) -- speed, acceleration, direction
    local a0 = 4 * Math.dot(r, r)
    local a1 = -4 * (Math.dot(a, r) + s * s)
    local a2 = Math.dot(a, a)
    local u = Math.minpos({solve(a2, a1, a0)})

    if u then
        local t = u ^ 0.5
        return r / t - t / 2 * a
    end
end -- returns the trajectory velocity

function Math.wtvp(p) -- vector
    p = workspace.CurrentCamera:WorldToViewportPoint(p)
    return Vector2.new(p.X, p.Y), p.Z
end -- returns 2d screen position

function Math.getpartends(cf, s) -- cframe, size
    return Math.wtvp((cf * CFrame.new(Vector3.new(0, s.Y / 2, 0))).Position), Math.wtvp((cf * CFrame.new(Vector3.new(0, -s.Y / 2, 0))).Position)
end -- returns the top and bottom positions of a part ( made for skeleton esp )

function Math.getpartinfo3(cf, s) -- cframe, size
    local Positions = {}
    local Top = s.Y / 2
    local Bottom = -s.Y / 2
    local Front = -s.Z / 2
    local Back = s.Z / 2
    local Left = -s.X / 2
    local Right = s.X / 2

    return {
        LeftTopFront = (cf * CFrame.new(Vector3.new(Left, Top, Front))).Position,
        RightTopFront = (cf * CFrame.new(Vector3.new(Right, Top, Front))).Position,
        LeftBottomFront = (cf * CFrame.new(Vector3.new(Left, Bottom, Front))).Position,
        RightBottomFront = (cf * CFrame.new(Vector3.new(Right, Bottom, Front))).Position,
        LeftTopBack = (cf * CFrame.new(Vector3.new(Left, Top, Back))).Position,
        RightTopBack = (cf * CFrame.new(Vector3.new(Right, Top, Back))).Position,
        LeftBottomBack = (cf * CFrame.new(Vector3.new(Left, Bottom, Back))).Position,
        RightBottomBack = (cf * CFrame.new(Vector3.new(Right, Bottom, Back))).Position
    }
end -- returns all the 3d corners of a part

function Math.getpartinfo2(cf, s) -- cframe, size
    local Positions = {}
    local Top = s.Y / 2
    local Bottom = -s.Y / 2
    local Front = -s.Z / 2
    local Back = s.Z / 2
    local Left = -s.X / 2
    local Right = s.X / 2

    return {
        LeftTopFront = Math.wtvp((cf * CFrame.new(Vector3.new(Left, Top, Front))).Position),
        RightTopFront = Math.wtvp((cf * CFrame.new(Vector3.new(Right, Top, Front))).Position),
        LeftBottomFront = Math.wtvp((cf * CFrame.new(Vector3.new(Left, Bottom, Front))).Position),
        RightBottomFront = Math.wtvp((cf * CFrame.new(Vector3.new(Right, Bottom, Front))).Position),
        LeftTopBack = Math.wtvp((cf * CFrame.new(Vector3.new(Left, Top, Back))).Position),
        RightTopBack = Math.wtvp((cf * CFrame.new(Vector3.new(Right, Top, Back))).Position),
        LeftBottomBack = Math.wtvp((cf * CFrame.new(Vector3.new(Left, Bottom, Back))).Position),
        RightBottomBack = Math.wtvp((cf * CFrame.new(Vector3.new(Right, Bottom, Back))).Position)
    }
end -- returns all the 2d corners of a part

function Math.getposlist3(l) -- list of 3d vectors
    local Positions = {}
    local Top = -math.huge
    local Bottom = math.huge
    local Front = math.huge
    local Back = -math.huge
    local Left = math.huge
    local Right = -math.huge

    for i, v in pairs(l) do
        Top = (v.Y > Top) and v.Y or Top
        Bottom = (v.Y < Bottom) and v.Y or Bottom
        Front = (v.Z < Front) and v.Z or Front
        Back = (v.Z > Back) and v.Z or Back
        Left = (v.X < Left) and v.X or Left
        Right = (v.X > Right) and v.X or Right
    end

    return {
        LeftTopFront = Math.wtvp(Vector3.new(Left, Top, Front)),
        RightTopFront = Math.wtvp(Vector3.new(Right, Top, Front)),
        LeftBottomFront = Math.wtvp(Vector3.new(Left, Bottom, Front)),
        RightBottomFront = Math.wtvp(Vector3.new(Right, Bottom, Front)),
        LeftTopBack = Math.wtvp(Vector3.new(Left, Top, Back)),
        RightTopBack = Math.wtvp(Vector3.new(Right, Top, Back)),
        LeftBottomBack = Math.wtvp(Vector3.new(Left, Bottom, Back)),
        RightBottomBack = Math.wtvp(Vector3.new(Right, Bottom, Back))
    }
end -- returns the 3d corners of everything in the list

function Math.getposlist2(l) -- list of 2d vectors
    local TopY = math.huge
    local BottomY = -math.huge
    local RightX = -math.huge
    local LeftX = math.huge

    for i, v in pairs(l) do
        TopY = (v.Y < TopY) and v.Y or TopY
        BottomY = (v.Y > BottomY) and v.Y or BottomY
        LeftX = (v.X < LeftX) and v.X or LeftX
        RightX = (v.X > RightX) and v.X or RightX
    end

    return {
        Positions = {
            TopLeft = Vector2.new(LeftX, TopY), 
            TopRight = Vector2.new(RightX, TopY), 
            BottomLeft = Vector2.new(LeftX, BottomY), 
            Middle = Vector2.new((RightX - LeftX) / 2 + LeftX, (BottomY - TopY) / 2 + TopY), 
            BottomRight = Vector2.new(RightX, BottomY)
        }, 
        Quad = {
            PointB = Vector2.new(LeftX, TopY), 
            PointA = Vector2.new(RightX, TopY), 
            PointC = Vector2.new(LeftX, BottomY), 
            PointD = Vector2.new(RightX, BottomY)
        }
    }
end -- returns the 2d corners of everything in the list

return Math
