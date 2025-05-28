--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the class Room.
]]
Room = Class{}

function Room:init(player,isBossRoom, entranceDirection)
    -- reference to player for collisions, etc.
    self.player = player
    self.isBossRoom = isBossRoom or false 
    self. entranceDirection =  entranceDirection


    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    self.tiles = {}
    self:generateWallsAndFloors()

    -- entities in the room
    self.entities = {}
    self:generateEntities()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    self:generateDoorways()

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0

    -- projectiles
    self.projectiles = {}
end

function Room:update(dt)
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- remove entity from the table if health is <= 0
        if entity.health <= 0 then
            entity.dead = true

            if entity.isBoss then
                stateMachine:change('winner')
                return
            end
            -- chance to drop a heart
            if not entity.dropped and math.random(10) == 1 then
                table.insert(self.objects, GameObject(GAME_OBJECT_DEFS['heart'], entity.x, entity.y))
            end
            -- whether the entity dropped or not, it is assumed that it dropped
            entity.dropped = true
        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end


         for k, object in pairs(self.objects) do
        object:update(dt)

        --cofre cerrado y jugador enfrente abrir cofre
        if object.type == 'chest' and object.state == 'closed' then
            local player = self.player
            local px, py, pw, ph = player.x, player.y, player.width, player.height
            local ox, oy, ow, oh = object.x, object.y, object.width, object.height

            --calcula la posicion central del jugador y el cofre
            local playerCenterX = px + pw / 2
            local playerCenterY = py + ph / 2
            local objectCenterX = ox + ow / 2
            local objectCenterY = oy + oh / 2

            --calcula las celdas
            local playerCol = math.floor(playerCenterX / TILE_SIZE)
            local playerRow = math.floor(playerCenterY / TILE_SIZE)
            local objCol = math.floor(objectCenterX / TILE_SIZE)
            local objRow = math.floor(objectCenterY / TILE_SIZE)

          
            if (player.direction == 'right' and playerRow == objRow and objCol == playerCol + 1) or
            (player.direction == 'left' and playerRow == objRow and objCol == playerCol - 1) or
            (player.direction == 'up' and playerCol == objCol and objRow == playerRow - 1) or
            (player.direction == 'down' and playerCol == objCol and objRow == playerRow + 1) then
                object.state = 'open'
                object.frame = object.states['open'].frame

          
                local bowExists = false
                for _, obj in pairs(self.objects) do
                    if obj.type == 'bow' then
                        bowExists = true
                        break
                    end
                end
                if not bowExists then
                    local bowFrame = 1
                    local bow = GameObject(
                        GAME_OBJECT_DEFS['bow'],
                        object.x + object.width / 2 - 8,
                        object.y - 20
                    )
                    bow.state = 'default'
                    bow.frame = bowFrame
                    table.insert(self.objects, bow)
                end
            end

          
            if object.type == 'bow' and not self.player.hasBow and self.player:collides(object) then
                if object.onConsume then
                    object.onConsume(self.player, object)
                end
                object.taken = true
            end

        end


        for i = #self.objects, 1, -1 do
            if self.objects[i].taken then
                table.remove(self.objects, i)
            end
        end
        
            
   
    end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            if entity.isBoss then
                SOUNDS['hit-player']:play()
                self.player:damage(2)
                self.player:goInvulnerable(1.5)

                if self.player.health == 0 then
                stateMachine:change('game-over')
                end

            else
                SOUNDS['hit-player']:play()
                self.player:damage(1)
                self.player:goInvulnerable(1.5)

                if self.player.health == 0 then
                stateMachine:change('game-over')
                end
            end

        end
    end

    for k, object in pairs(self.objects) do
        object:update(dt)

        -- trigger collision callback on object
        if self.player:collides(object) then
            object:onCollide()

            if object.solid and not object.taken then
                local playerY = self.player.y + self.player.height / 2
                local playerHeight = self.player.height - self.player.height / 2
                local playerRight = self.player.x + self.player.width
                local playerBottom = playerY + playerHeight
                
                if self.player.direction == 'left' and not (playerY >= (object.y + object.height)) and not (playerBottom <= object.y) then
                    self.player.x = object.x + object.width
                elseif self.player.direction == 'right' and not (playerY >= (object.y + object.height)) and not (playerBottom <= object.y) then 
                    self.player.x = object.x - self.player.width
                elseif self.player.direction == 'down' and not (self.player.x >= (object.x + object.width)) and not (playerRight <= object.x) then
                    self.player.y = object.y - self.player.height
                elseif self.player.direction == 'up' and not (self.player.x >= (object.x + object.width)) and not (playerRight <= object.x) then
                    self.player.y = object.y + object.height - self.player.height/2
                end
            end

            if object.consumable then
                object.onConsume(self.player, object)
                table.remove(self.objects, k)
            end
        end
    end

    for k, projectile in pairs(self.projectiles) do
        projectile:update(dt)
    
        -- Si el proyectil es una bola de fuego del jefe
        if projectile.obj.type == 'fire' then
            -- Solo colisiona con el jugador
            if not projectile.dead and projectile:collides(self.player) then
                self.player:damage(6)
                SOUNDS['hit-player']:play()
                projectile.dead = true

                stateMachine:change('game-over')
            end
        else
           -- Para otros proyectiles (flechas), colisionan con entidades
            for e, entity in pairs(self.entities) do
                if projectile.dead then
                    break
                end

                if not entity.dead and projectile:collides(entity) then
                    if entity.isBoss then
                        -- Si es el jefe, hacerlo vulnerable a la espada
                        entity.swordImmune = false
                        entity.swordVulnerableTimer = 0
                    end
                    entity:damage(1)
                    SOUNDS['hit-enemy']:play()
                    projectile.dead = true
                end
            end
        end
    
        if projectile.dead then
            table.remove(self.projectiles, k)
        end
    end
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}
    if self.isBossRoom then
         -- Generar el jefe en el centro de la sala
         table.insert(self.entities, Entity {
            animations = ENTITY_DEFS['boss'].animations,
            walkSpeed = ENTITY_DEFS['boss'].walkSpeed,
            x = VIRTUAL_WIDTH / 2 - 16,  -- Centrado horizontalmente
            y = VIRTUAL_HEIGHT / 2 - 16,  -- Centrado verticalmente
            width = 32,  -- Jefe más grande
            height = 32,
            health = 20, -- Más vida que enemigos normales
            isBoss = true
        })

        self.entities[1].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[1],self) end,
            ['idle'] = function() return EntityIdleState(self.entities[1]) end
        }

        self.entities[1]:changeState('walk')
        return
    end


    for i = 1, 10 do
        local type = types[math.random(#types)]

        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
            y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16),
            
            width = 16,
            height = 16,

            health = 1
        })

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i]) end,
            ['idle'] = function() return EntityIdleState(self.entities[i]) end
        }

        self.entities[i]:changeState('walk')
    end
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()

    if self.isBossRoom then
        return
    end

    table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['switch'],
        math.random(MAP_RENDER_OFFSET_X + TILE_SIZE,
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16),
        math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE,
                    VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    ))
    

    -- get a reference to the switch
    local switch = self.objects[1]
   
    

    --define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            SOUNDS['door']:play()
        end
    end


    
     --agrega un cofre aleatoriamnete
    local chestX = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 32)
    local minChestY = MAP_RENDER_OFFSET_Y + TILE_SIZE * 2  -- deja 2 tiles de margen superior
    local maxChestY = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 32
    local chestY = math.random(minChestY, maxChestY)table.insert(self.objects, GameObject(
        GAME_OBJECT_DEFS['chest'],
        chestX,
        chestY
    ))

    for y = 2, self.height -1 do
        for x = 2, self.width - 1 do
            -- change to spawn a pot
            if math.random(20) == 1 then
                local potX = x * 16
                local potY = y * 16
                -- Verifica que no se superponga con el cofre
                local overlap = false
                for _, obj in pairs(self.objects) do
                    if obj.type == 'chest' then
                        if potX + 16 > obj.x and potX < obj.x + obj.width and
                           potY + 16 > obj.y and potY < obj.y + obj.height then
                            overlap = true
                            break
                        end
                    end
                end
                if not overlap then
                    table.insert(self.objects, GameObject(
                        GAME_OBJECT_DEFS['pot'], potX, potY
                    ))
                end
            end
        end
    end
end

function Room:generateDoorways()
    if self.isBossRoom then
        -- Si es sala de jefe, solo generamos una puerta (la de entrada)
        local oppositeDirection = {
            ['left'] = 'right',
            ['right'] = 'left',
            ['top'] = 'down',
            ['down'] = 'top'
        }
        local exitDirection = oppositeDirection[self.entranceDirection]
        table.insert(self.doorways, Doorway(exitDirection, false, self))
    else
        -- Si es sala normal, generamos las cuatro puertas
        table.insert(self.doorways, Doorway('top', false, self))
        table.insert(self.doorways, Doorway('bottom', false, self))
        table.insert(self.doorways, Doorway('left', false, self))
        table.insert(self.doorways, Doorway('right', false, self))
    end
end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(TEXTURES['tiles'], FRAMES['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE * 2,
            TILE_SIZE * 2 + 6, TILE_SIZE * 3)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - 6,
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE * 2, TILE_SIZE * 2 + 6, TILE_SIZE * 3)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)

    if self.player then
        self.player:render()
    end

    for k, projectile in pairs(self.projectiles) do
        projectile:render()
    end

    love.graphics.setStencilTest()
end
