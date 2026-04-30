local PI = math.pi
local PI2 = 2 * PI

-- Cache frequently used math functions for JIT compilation
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local acos = math.acos
local deg = math.deg
local log = math.log

function random_direction2()
  local angle = PI2 * math.random()
  return cos(angle), sin(angle)
end

-- generate random 3d unit vector
function random_direction3()
  local angle = PI2 * math.random()
  local z = -1 +  2 * math.random()
  local x = sqrt(1 - z*z) * cos(angle)
  local y = sqrt(1 - z*z) * sin(angle)

  return x, y, z
end

-- returns angle in degrees between 2 3d vectors
-- OPTIMIZED: Avoid redundant magnitude calculations
function vector3_deg_angle(ux, uy, uz, vx, vy, vz)
  local usq = ux*ux + uy*uy + uz*uz
  local vsq = vx*vx + vy*vy + vz*vz
  local dot = ux*vx + uy*vy + uz*vz
  local rad = acos(dot / sqrt(usq * vsq))
  
  return deg(rad)
end

-- returns angle in rads between 2 3d vectors
-- OPTIMIZED: Avoid redundant magnitude calculations
function vector3_rad_angle(ux, uy, uz, vx, vy, vz)
  local usq = ux*ux + uy*uy + uz*uz
  local vsq = vx*vx + vy*vy + vz*vz
  local dot = ux*vx + uy*vy + uz*vz
  local rad = acos(dot / sqrt(usq * vsq))
  
  return rad
end

-- dot product
function vector3_dot(ux, uy, uz, vx, vy, vz)
  return ux*vx + uy*vy + uz*vz
end

-- cross product
function vector3_cross(u1, u2, u3, v1, v2, v3)
  local x = u2*v3 - u3*v2
  local y = u3*v1 - u1*v3
  local z = u1*v2 - u2*v1
  
  return x, y, z
end

-- returns length of 3d vector
function vector3_magnitude(vx, vy, vz)
  return sqrt(vx*vx + vy*vy + vz*vz)
end

-- BUGFIX: Was 'vx - uz, vy - uy, vz - uz' - incorrect z component calculation
function vector3_distance(ux, uy, uz, vx, vy, vz)
  local dx, dy, dz = vx - ux, vy - uy, vz - uz
  return sqrt(dx*dx + dy*dy + dz*dz)
end

function rotate_point3(px, py, pz, ox, oy, oz, dirx, diry, dirz, th)
  local x, y, z = px, py, pz
  local a, b, c = ox, oy, oz
  local u, v, w = dirx, diry, dirz
  local costh = cos(th)
  local sinth = sin(th)
  local minus_costh = 1 - costh
  local term = -u*x-v*y-w*z
  
  local rx = (a*(v*v+w*w)-u*(b*v+c*w+term))*minus_costh+x*costh+(-c*v+b*w-w*y+v*z)*sinth
  local ry = (b*(u*u+w*w)-v*(a*u+c*w+term))*minus_costh+y*costh+( c*u-a*w+w*x-u*z)*sinth
  local rz = (c*(u*u+v*v)-w*(a*u+b*v+term))*minus_costh+z*costh+(-b*u+a*v-v*x+u*y)*sinth
  
  return rx, ry, rz
end

-- BUGFIX: Was 'z3 - y1' instead of 'z3 - z1' for vz component
function triangle_minimum_angle(x1, y1, z1, x2, y2, z2, x3, y3, z3)
  local ux, uy, uz = x2 - x1, y2 - y1, z2 - z1
  local vx, vy, vz = x3 - x1, y3 - y1, z3 - z1
  local angle = vector3_rad_angle(ux, uy, uz, vx, vy, vz)
  
  ux, uy, uz = x1 - x2, y1 - y2, z1 - z2
  vx, vy, vz =  x3 - x2, y3 - y2, z3 - z2
  local a = vector3_rad_angle(ux, uy, uz, vx, vy, vz)
  if a < angle then
    angle = a
  end
  
  ux, uy, uz = x2 - x3, y2 - y3, z2 - z3
  vx, vy, vz = x1 - x3, y1 - y3, z1 - z3
  local b = vector3_rad_angle(ux, uy, uz, vx, vy, vz)
  if b < angle then
    angle = b
  end
  
  return angle
end

function triangle_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3)
  local ux, uy, uz = x2 - x1, y2 - y1, z2 - z1
  local vx, vy, vz = x3 - x1, y3 - y1, z3 - z1
  
  local nx, ny, nz = vector3_cross(ux, uy, uz, vx, vy, vz)
  local imag = 1 / sqrt(nx*nx + ny*ny + nz * nz)
  
  return nx * imag, ny * imag, nz * imag
end

function triangle_centroid(x1, y1, z1, x2, y2, z2, x3, y3, z3)
  local midx, midy, midz = x2 + 0.5 * (x3 - x2), 
                           y2 + 0.5 * (y3 - y2),
                           z2 + 0.5 * (z3 - z2)
  local cx, cy, cz = midx + (1/3) * (x1 - midx), 
                     midy + (1/3) * (y1 - midy),
                     midz + (1/3) * (z1 - midz)
  return cx, cy, cz
end

function triangle_area(x1, y1, z1, x2, y2, z2, x3, y3, z3)
  local ux, uy, uz = x2 - x1, y2 - y1, z2 - z1
  local vx, vy, vz = x3 - x1, y3 - y1, z3 - z1
  local umag = vector3_magnitude(ux, uy, uz)
  local vmag = vector3_magnitude(vx, vy, vz)
  local rads = vector3_rad_angle(ux, uy, uz, vx, vy, vz)
  
  return 0.5 * umag * vmag * sin(rads)
end

-- (xi, yi) - start of line segment
-- (xf, yf) - end of line segment
-- (rx, ry) - top left corner of rectangle
-- w, h - width and height of rectangle
function line_rectangle_intersection(xi, yi, xf, yf, rx, ry, w, h)
  
  if xi == xf and yi == yf then
    return false
  end
  
  -- equation of line
  local eps = 0.0000001
  local dx, dy
  local Ax, Bx
  if xi < xf then
    dx, dy = xf - xi, yf - yi
    Ax, Bx = xi, xf
  else
    dx, dy = xi - xf, yi - yf
    Ax, Bx = xf, xi
  end
  if dx == 0 then dx = eps end
  if dy == 0 then dy = eps end
  local m = dy / dx
  local m_inv = 1 / m
  local b = yi - m * xi
  
  -- check intersection with rectangle sides
  local ix, iy, nx, ny, dsq
  
  -- top
  local y = ry
  local x = m_inv * (y - b)
  if x > Ax and x < Bx and x > rx and x < rx + w then
    ix, iy = x, y
    nx, ny = 0, -1
    local dx, dy = ix - xi, iy - yi
    dsq = dx*dx + dy*dy
  end
  
  -- bottom
  local y = ry + h
  local x = m_inv * (y - b)
  if x > Ax and x < Bx and x > rx and x < rx + w then
    local this_dsq
    local dx, dy = x - xi, y - yi
    local this_dsq = dx*dx + dy*dy
    if ix then
      if this_dsq < dsq then
        ix, iy = x, y
        nx, ny = 0, 1
        dsq = this_dsq
      end
    else
      ix, iy = x, y
      nx, ny = 0, 1
      dsq = this_dsq
    end
  end
  
  -- right
  local x = rx + w
  local y = m * x + b
  if x > Ax and x < Bx and y > ry and y < ry + h then
    local dx, dy = x - xi, y - yi
    local this_dsq = dx*dx + dy*dy
    if ix then
      if this_dsq < dsq then
        ix, iy = x, y
        nx, ny = 1, 0
        dsq = this_dsq
      end
    else
      ix, iy = x, y
      nx, ny = 1, 0
      dsq = this_dsq
    end
  end
  
  -- left
  local x = rx
  local y = m * x + b
  if x > Ax and x < Bx and y > ry and y < ry + h then
    local dx, dy = x - xi, y - yi
    local this_dsq = dx*dx + dy*dy
    if ix then
      if this_dsq < dsq then
        ix, iy = x, y
        nx, ny = -1, 0
        dsq = this_dsq
      end
    else
      ix, iy = x, y
      nx, ny = -1, 0
      dsq = this_dsq
    end
  end
  
  if ix then
    return ix, iy, nx, ny
  else
    return false
  end

  return x, y, nx, ny
end


-- (Ax, Ay, Aw, Ah) - Moving rectangle - must be moving
-- (Bx, By, Bw, Bh) - static rectangle
-- vx, vy - velocity or direction vector
-- returns translation (tx, ty) components to move rectangle A to collision point
--         and normal (nx, ny) of collision
-- BUGFIX: Was 'by == 0' instead of 'vy == 0' - undefined variable
function rectangle_rectangle_collision(Ax, Ay, Aw, Ah, Bx, By, Bw, Bh, vx, vy)
  if vx == 0 and vy == 0 then
    return
  end
  
  local case
  if vx == 0 then
    if vy > 0 then case = 5 else case = 1 end
  elseif vy == 0 then
    if vx > 0 then case = 3 else case = 7 end
  else
    if vx > 0 then
      if vy > 0 then case = 4 else case = 2 end
    else
      if vy > 0 then case = 6 else case = 8 end
    end
  end
  
  local ix, iy, nx, ny
  if case % 2 == 1 then  -- up right down left cases
    if     case == 1 then  -- up
      ix, iy = Ax, By + Bh
      nx, ny = 0, 1
    elseif case == 3 then  -- right
      ix, iy = Bx - Aw, Ay
      nx, ny = -1, 0
    elseif case == 5 then  -- down
      ix, iy = Ax, By - Ah
      nx, ny = 0, -1
    elseif case == 7 then  -- left
      ix, iy = Bx + Bw, Ay
      nx, ny = 1, 0
    end
  else -- diagonal cases
    local m = vy / vx
    local m_inv = 1 / m
    local b = Ay - m * Ax
    
    if     case == 2 then  -- upright
      x_line, y_line = Bx - Ah, By + Bh
      ix = x_line
      iy = m * x_line + b
      nx, ny = -1, 0
      if iy > y_line then
        iy = y_line
        ix = m_inv * (y_line - b)
        nx, ny = 0, 1
      end
    elseif case == 4 then  -- downright
      x_line, y_line = Bx - Aw, By - Ah
      ix = x_line
      iy = m * x_line + b
      nx, ny = -1, 0
      if iy <= y_line then
        iy = y_line
        ix = m_inv * (y_line - b)
        nx, ny = 0, -1
      end
    elseif case == 6 then  -- downleft
      x_line, y_line = Bx + Bw, By - Ah
      ix = x_line
      iy = m * x_line + b
      nx, ny = 1, 0
      if iy < y_line then
        iy = y_line
        ix = m_inv * (y_line - b)
        nx, ny = 0, -1
      end
    elseif case == 8 then  -- upleft
      x_line, y_line = Bx + Bw, By + Bh
      ix = x_line
      iy = m * x_line + b
      nx, ny = 1, 0
      if iy >= y_line then
        iy = y_line
        ix = m_inv * (y_line - b)
        nx, ny = 0, 1
      end
    end
  end
  
  local tx, ty = ix - Ax, iy - Ay
  
  return tx, ty, nx, ny
end


--------------------------------------------------------------------------------
-- returns a random time interval in seconds based on the
-- poisson process
function poisson_interval(rate)
  return (-log(1-math.random())/rate)
end


--------------------------------------------------------------------------------
-- returns linear interpolation x from xi to xf
-- t = [0, 1]
function lerp(xi, xf, t)
  if t <= 0 then
    return xi
  end
  
  if t >= 1 then
    return xf
  end
  
  return xi + t * (xf - xi)
end

function get_bounce_velocity_components(velx, vely, nx, ny, friction, restitution)  
  local vdotn = velx * nx + vely * ny
  local ux, uy = vdotn * nx, vdotn * ny
  local wx, wy = velx - ux, vely - uy
  local vx = friction * wx - restitution * ux
  local vy = friction * wy - restitution * uy

  return vx, vy
end
