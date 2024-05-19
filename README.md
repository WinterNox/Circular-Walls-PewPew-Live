# Circular Walls (PewPew Live)

**Circular Walls** is a module that allows level creators to create almost perfect circular wall collisions in PewPew Live without using a lot of resources or needing more than the limit of 200 walls. It can be used extremely easily even by the people who have just stepped into level creation in PewPew Live.

**Note: The module only provides the functionality of the walls, without any graphical elements are included. The mesh for the walls are to be created manually by the level creator.**

## Installation

To install this module, follow the steps below:

1. Download the source code as a ZIP file.
2. Extract the file into a desired location.
3. Move the folder `Circular-Walls-PewPew-Live/Circular Wall` to your level folder.
4. In `level.lua` or any other file that may use the module's features, add the following line of code. Note that you can move the above folder to any desired location. In that case, you will use the complete path to `Circular Wall/code.lua` inside that folder and during the configuration of the module, set `path` to the parent folder of `Circular Wall`.
```lua
local circular_wall = require("/dynamic/Circular Wall/code.lua")
```

You are now ready to use the module!

## Usage

The module is extremely simple to use. To use the module in your level without any problems, follow the steps below:

1. Configure the module.
The module needs to be initialized through a certain function to fit the level's needs properly. If not initialized, the module will break. It is used to gather the following information in order to properly perform with minimal resources:
    * `path`: The path to the parent folder of `Circular Wall`; Example: `/dynamic/modules/`. It should end with a forward slash. You can ignore setting this if `Circular Wall` is present in the same folder as `level.lua`.
    * `max_speeds`: The **maximum speeds** at which entities of specific types move
        * This should only be used to set the maximum speeds of the player ship, customizable entities, and entities whose speed can be controlled. This includes BAFs, Inertiacs, Rolling Spheres, etc. 
        * Setting the maximum speed for entity types that have a fixed speed throughout the game is discouraged. 
        * Setting the maximum speed for entity types that do not collide with walls will have no effect. 
        * You should set the maximum speed for customizable entities to the **maximum** speed of the **fastest** customizable entity that will be used in the level.
    * `maximum_radius_customizable_entity`: The radius of the **largest** customizable entity that will be used in the level
    * `is_ufos_collision_enabled, is_rolling_cubes_collision_enabled`: Whether or not UFOs and Rolling Cubes have collision enabled
    * `level_width, level_height`: The level's width and height

```lua
circular_wall.init(
  configuration: table {
    path: String
    max_speeds: table {
      [pewpew.EntityType.BAF]: FixedPoint,
      [pewpew.EntityType.ROLLING_SPHERE]: FixedPoint,
      [pewpew.EntityType.SHIP]: FixedPoint,
      -- ...
    },
    maximum_radius_customizable_entity: FixedPoint,
    is_ufos_collision_enabled: bool,
    is_rolling_cubes_collision_enabled: bool,
    level_width: FixedPoint,
    level_height: FixedPoint
  }
)
```

**Example:**
```lua
circular_wall.init(
  {
    path = "/dynamic/helpers/"
    max_speeds = {
      [pewpew.EntityType.SHIP] = 24fx
    }
    maximum_radius_customizable_entity = 8fx,
    is_ufos_collision_enabled = true,
    is_rolling_cubes_collision_enabled = true,
    level_width = 7200fx,
    level_height = 480fx,
  }
)
```

## Functions

Along with the function to create circular walls, the module has some functions to ease the process of development in a level that uses it. Here is the documentation for each of them:

### `circular_wall.new()`
```lua
circular_Wall.new(
  x: FixedPoint,
  y: FixedPoint,
  radius: FixedPoint,
  mesh: table {
    file_path: String,
    index: int,
    visibility_radius: FixedPoint
  }
): EntityID
```

Creates a circular wall entity with its center at location `x`, `y`, radius equal to `radius` and returns its entityID. If `radius` is negative, the wall will be pass-through. Avoid using negative radii. `mesh` is an optional parameter that specifies a mesh to use with an optinal `visibility_radius` which will be used to set the entity's visibility radius for optimized rendering. It is better to not set the visibility radius if your wall's mesh is extended significantly in the negative Z axis.

### `circular_wall.get_wall_count()`
```lua
circular_wall.get_wall_count(): int
```
Returns the number of walls that are being used by the module to perform circular wall collisions. The limit to how many walls can be present at a given time is 200. This information can be used to make changes to your level to ensure that it does not pass the limit.

### `circular_wall.is_inside_wall()`
```lua
circular_wall.is_inside_wall(
  x: FixedPoint,
  y: FixedPoint
): bool
```
Returns whether or not the point located at `x`, `y` is inside a circular wall.

### `circular_wall.random_position`
```lua
circular_Wall.random_position(
  entity_type: int
): FixedPoint, FixedPoint
```
Returns a random location for spawning an entity of type `entity_type` such that it will not be inside any of the circular walls present in the level at that time. Returns the origin location if it fails to find a proper location in under 10,000 checks.

**Example:**
```lua
local x, y = circular_wall.random_position(pewpew.EntityType.ASTEROID)
pewpew.new_asteroid(x, y)
```

### `circular_wall.random_position_custom_radius`
```lua
circular_wall.random_position_custom_radius(
  radius: FixedPoint
): FixedPoint, FixedPoint
```
Returns a location for spawning an entity of type `pewpew.EntityType.CUSTOMIZABLE_ENTITY` with collsion radius `radius` such that it will not be inside any of the circular walls present in the level at that time. Returns the origin location if it fails to find a proper location in under 10,000 checks.

**Example:**
```lua
local x, y = circular_wall.random_position_custom_radius(128fx)
large_entity.new(x, y)
```
Here, the function `large.new(x: FixedPoint, y: FixedPoint)` creates an entity at location `x`, `y`. The collision radius of the entity is `128fx`.

## Recommendations
You should take into consideration the following recommendations:
- Add code for manual garbage collection every tick. Since the module makes the use of temporary walls to simulate collisions, it will take up a significant amount of memory. Usually, PewPew Live collects garbage incrementally. To ensure that the temporary walls are deleted from the memory as soon as they are not being used, you can call `collectgarbage("collect")` every tick in your update callback. This will ensure that the module does not limit your usage of memory unnecessarilly.
- Do not move the circular wall entities. This will not cause any changes to their functionality but will instead shift the mesh of the entity, if any, to the location specified while the actual collisions take place according to the original position of the entity.
- Deletion of circular wall entities can be done using the `pewpew.entity_destroy(entity_id: int)` function with the ID of the circular wall entity.
- If only few circular walls are required, it is better to just lay down an approximate polygonal wall instead of using this module.