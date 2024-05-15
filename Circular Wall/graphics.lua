meshes = {}

local tau = math.pi * 2

local subdivisions = 64

local computed_vertexes, computed_segments = {}, {}
local i = 0

local segment = {}
for angle = 0, tau, tau / subdivisions do
  local y, x = math.sincos(angle)

  table.insert(computed_vertexes, {x, y})
  table.insert(segment, i)

  i = i + 1
end

table.remove(computed_vertexes, #computed_vertexes)
table.remove(segment, #segment)  -- In the above code, a vertex is added that coincides with the first point. This only happens at certain values of the variable "subdivisions".
table.insert(segment, 0)
table.insert(computed_segments, segment)

table.insert(meshes, {
  vertexes = computed_vertexes,
  segments = computed_segments
})
