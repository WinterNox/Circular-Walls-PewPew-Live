# Circular Walls (PewPew Live)

Circular walls is a module that allows level creators to create almost perfect circular wall collisions in PewPew Live without using a lot of resources or needing more than limit of 200 walls. It can be used extremely easily even by the people who have just stepped into level creation in PewPew Live.

## Installation

To install this module, follow the steps below:

1. Download the source code as a ZIP file.
2. Move the folder `Circular Walls > Circular Wall` to your level folder.
3. In `level.lua` or any other file that may use the module's features, add the following line of code:
```lua
local circular_wall = require("/dynamic/Circular Wall/code.lua")
```

You are now ready to use the module!

## Usage

The module is extremely simple to use. To use the module in your level without any problems, follow the steps below:

1. Configure the module.
The module needs to be initialized through a certain function to fit the level's needs properly. If not initialized, the module will break. It is used to gather the following information in order to properly perform with minimal resources:
    * The **maximum speeds** at which entities of specific types move
        * This should only be used to set the maximum speeds of the player ship, customizable entities, and entities whose speed can be controlled. This includes BAFs, Inertiacs, Rolling Spheres, etc. 
        * Setting the maximum speed for entity types that have a fixed speed throughout the game is discouraged. 
        * Setting the maximum speed for entity types that do not collide with walls will have no effect. 
        * You should set the maximum speed for customizable entities to the **maximum** speed of the **fastest** customizable entity that will be used in the level.
    * The radius of the **largest** customizable entity that will be used in the level
    * Whether or not UFOs and Rolling Cubes have collision enabled
    * The level's width and height
```lua
circular_wall.init(
  configuration: table {
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

## Functions

The module has some functions to create circular walls and also some functions to ease the process of development in a level that uses it. Here is the documentation for each of them:

### `circular_wall.new()`
```lua
circular_Wall.new(
  x: FixedPoint,
  y: FixedPoint,
  radius: FixedPoint,
  color: int
): EntityID
```

Creates a circular wall entity with its center at location `x`, `y`, radius equal to `radius` and color set to `color` and returns its entityID.

### `circular_wall.get_wall_count()`
```lua
circular_wall.get_wall_count(): int
```
Returns the number of walls that are being used by the module to perform circular wall collisions. The limit to how many walls can be present at a given time is 200. This information can be used to make changes to your level or to the parameters in `circular_wall.init()` if required.

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
Returns a location for spawning an entity of type `pewpew.EntityType.CUSTOMIZABLE_ENTITY` such that it will not be inside any of the circular walls present in the level at that time. Returns the origin location if it fails to find a proper location in under 10,000 checks.

**Example**
```lua
local x, y = circular_wall.random_position_custom_radius(128fx)
large_entity.new(x, y)
```
Here, the function `large.new(x: FixedPoint, y: FixedPoint)` creates an entity at location `x`, `y`. The collision or visual radius of the entity is `128fx`.