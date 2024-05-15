local circular_wall = {}

local circular_walls = {}
local entities = {}

local entity_types = {pewpew.EntityType.ASTEROID, pewpew.EntityType.BAF, pewpew.EntityType.INERTIAC, pewpew.EntityType.MOTHERSHIP, pewpew.EntityType.MOTHERSHIP_BULLET, pewpew.EntityType.ROLLING_CUBE, pewpew.EntityType.ROLLING_SPHERE, pewpew.EntityType.UFO, pewpew.EntityType.WARY, pewpew.EntityType.CROWDER, pewpew.EntityType.CUSTOMIZABLE_ENTITY, pewpew.EntityType.SHIP, pewpew.EntityType.BOMB, pewpew.EntityType.BAF_BLUE, pewpew.EntityType.BAF_RED, pewpew.EntityType.WARY_MISSILE, pewpew.EntityType.UFO_BULLET, pewpew.EntityType.PLAYER_BULLET, pewpew.EntityType.BOMB_EXPLOSION, pewpew.EntityType.PLAYER_EXPLOSION, pewpew.EntityType.BONUS, pewpew.EntityType.FLOATING_MESSAGE, pewpew.EntityType.POINTONIUM, pewpew.EntityType.BONUS_IMPLOSION}

local approximate_radii = require("/dynamic/Circular Wall/approx_radii.lua")
local approximate_speeds = require("/dynamic/Circular Wall/approx_speeds.lua")

local function circular_wall_update_callback(entity_id)
  local wall = circular_walls[entity_id]

  for entity, wall_id in pairs(wall.temp_walls) do
    if not pewpew.entity_get_is_alive(entity) then
      pewpew.remove_wall(wall_id)
      wall.temp_walls[entity] = nil
    end
  end

  if #entities > 0 then
    for i = 1, #entities do
      local entity = entities[i]

      if entity == entity_id then
        break
      end

      local entity_x, entity_y = pewpew.entity_get_position(entity)

      local dx = entity_x - wall.pos.x
      local dy = entity_y - wall.pos.y

      local sqr_distance = dx * dx + dy * dy
      local distance = fmath.sqrt(sqr_distance)

      local entity_radius = approximate_radii[pewpew.get_entity_type(entity)] + approximate_speeds[pewpew.get_entity_type(entity)]

      if distance < wall.radius + entity_radius then  -- Using 3fx/2fx as a safety measure
        local tangent_angle = fmath.atan2(dy, dx) + fmath.tau()/4fx

        local increment_y, increment_x = fmath.sincos(tangent_angle)

        dx = (dx / distance) * wall.radius
        dy = (dy / distance) * wall.radius

        if wall.temp_walls[entity] ~= nil then
          pewpew.remove_wall(wall.temp_walls[entity])
        end

        local default_wall_id = pewpew.add_wall(
          wall.pos.x + dx + increment_x * entity_radius / 2fx,
          wall.pos.y + dy + increment_y * entity_radius / 2fx,
          wall.pos.x + dx - increment_x * entity_radius / 2fx,
          wall.pos.y + dy - increment_y * entity_radius / 2fx
        )

        if default_wall_id ~= 65535 then
          wall.temp_walls[entity] = default_wall_id
        end
      else
        if wall.temp_walls[entity] ~= nil then
          pewpew.remove_wall(wall.temp_walls[entity])
        end
        wall.temp_walls[entity] = nil
      end
    end
  end
end

local is_ufos_collision_enabled = false
local is_rolling_cubes_collision_enabled = false
function circular_wall.init(configuration)
  for entity_type, value in pairs(configuration.max_speeds) do
    approximate_speeds[entity_type] = value
  end

  if configuration.is_ufos_collision_enabled == true then
    is_ufos_collision_enabled = true
  end

  if configuration.is_rolling_cubes_collision_enabled == true then
    is_rolling_cubes_collision_enabled = true
  end

  level_width = configuration.level_width
  level_height = configuration.level_height
end

-- Creates a circular wall entity and returns its ID.
-- @params x: FixedPoint the x position of the center of the circular wall
-- @params y: FixedPoint the y position of the center of the circular wall
-- @params radius: FixedPoint the radius of the circular wall
-- @params color: a 32 bit color; the color of the circular wall
function circular_wall.new(x, y, radius, color)
  local entity_id = pewpew.new_customizable_entity(x, y)

  -- Set the entity's properties
  pewpew.customizable_entity_set_mesh(entity_id, "/dynamic/Circular Wall/graphics.lua", 0)
  pewpew.customizable_entity_set_mesh_scale(entity_id, radius)  -- The mesh is a unit circle
  pewpew.customizable_entity_set_mesh_color(entity_id, color)  -- The mesh is white, any multiplication to it will make the entity that color.
  pewpew.customizable_entity_set_visibility_radius(entity_id, radius)

  circular_walls[entity_id] = {
    pos = {
      x = x,
      y = y
    },
    radius = radius,
    temp_walls = {}
  }

  pewpew.entity_set_update_callback(entity_id, circular_wall_update_callback)

  return entity_id
end

-- Returns the number of walls being used by the module.
function circular_wall.get_wall_count()
  local wall_num = 0
  for cw_entity_id, wall_information in pairs(circular_walls) do
    for entity_id, wall_id in pairs(wall_information.temp_walls) do
      wall_num = wall_num + 1
    end
  end

  return wall_num
end

-- Returns whether a given coordinate is inside a circular wall.
-- @params x: FixedPoint the x component of the coordinate
-- @params y: FixedPoint the y component of the coordinate
function circular_wall.is_inside_wall(x, y)
  for entity_id, wall_information in pairs(circular_walls) do
    local dx = x - wall_information.pos.x
    local dy = y - wall_information.pos.y

    local sqr_distance = dx * dx + dy * dy

    if sqr_distance < wall_information.radius * wall_information.radius then
      return true
    end
  end

  return false
end

-- Returns a random safe coordinate for spawning an entity of a specific type.
-- @params entity_type: EntityType the entity type of the entity that will be using the coordinates
function circular_wall.random_position(entity_type)
  local x
  local y
  local entity_radius = approximate_radii[entity_type] + approximate_speeds[entity_type]

  local num_outside_walls = 0
  local circular_walls_num = 0

  for entity_id, wall_information in pairs(circular_walls) do
    circular_walls_num = circular_walls_num + 1
  end

  local count = 0
  while (num_outside_walls < circular_walls_num) do
    num_outside_walls = 0
    x = fmath.random_fixedpoint(0fx, level_width)
    y = fmath.random_fixedpoint(0fx, level_height)

    for entity_id, wall_information in pairs(circular_walls) do
      local dx = x - wall_information.pos.x
      local dy = y - wall_information.pos.y
  
      local sqr_distance = dx * dx + dy * dy

      local sqr_min_distance = (wall_information.radius + entity_radius) * (wall_information.radius + entity_radius)
  
      if sqr_distance > sqr_min_distance then
        num_outside_walls = num_outside_walls + 1

      end
    end

    count = count + 1

    if count > 10000 then
      return 0fx, 0fx
    end
  end

  return x, y
end

-- Returns a random safe coordinate for spawning an entity of a specific type.
-- @params entity_type: EntityType the entity type of the entity that will be using the coordinates
function circular_wall.random_position_custom_radius(entity_radius)
  local x
  local y

  local num_outside_walls = 0
  local circular_walls_num = 0

  for entity_id, wall_information in pairs(circular_walls) do
    circular_walls_num = circular_walls_num + 1
  end

  local count = 0
  while (num_outside_walls < circular_walls_num) do
    num_outside_walls = 0
    x = fmath.random_fixedpoint(0fx, level_width)
    y = fmath.random_fixedpoint(0fx, level_height)

    for entity_id, wall_information in pairs(circular_walls) do
      local dx = x - wall_information.pos.x
      local dy = y - wall_information.pos.y
  
      local sqr_distance = dx * dx + dy * dy

      local sqr_min_distance = (wall_information.radius + entity_radius) * (wall_information.radius + entity_radius)
  
      if sqr_distance > sqr_min_distance then
        num_outside_walls = num_outside_walls + 1

      end
    end

    count = count + 1

    if count > 10000 then
      return 0fx, 0fx
    end
  end

  return x, y
end


local function update_entity_list()
  local entities_temp = pewpew.get_all_entities()

  for i = #entities_temp, 1, -1 do
    for cw_entity_id, wall_information in pairs(circular_walls) do
      if entities_temp[i] == cw_entity_id then
        table.remove(entities_temp, i)
      end
    end
  end

  entities = entities_temp
end

local function clear_dead_walls()
  for entity_id, wall_information in pairs(circular_walls) do
    if not pewpew.entity_get_is_alive(entity_id) then
      -- Remove the walls used
      for entity, wall_id in pairs(wall_information.temp_walls) do
        pewpew.remove_wall(wall_id)
      end

      circular_walls[entity_id] = nil
    end
  end
end

pewpew.add_update_callback(update_entity_list)
pewpew.add_update_callback(clear_dead_walls)

return circular_wall