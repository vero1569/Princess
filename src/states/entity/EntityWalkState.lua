--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the class EntityWalkState.
]]
EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity, room)
    self.entity = entity
    self.entity:changeAnimation('walk-down')

    --self.dungeon = dungeon
    self.room = room
    
    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

    -- keeps track of whether we just hit a wall
    self.bumped = false

    
    --tiempo entre disparos para el jefe
    self.shootTimer = 0
    self.shootInterval = 2  --dispara cada 2 segundos

   
      self.healthBarBlinkTimer = 0
      self.healthBarBlinkInterval = 0.2  -- parpadea cada 0.2 segundos
      self.healthBarVisible = true
end

function EntityWalkState:update(dt)
    
    -- assume we didn't hit a wall
    self.bumped = false

    if self.entity.direction == 'left' then
        self.entity.x = self.entity.x - self.entity.walkSpeed * dt
        
        if self.entity.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then 
            self.entity.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
    elseif self.entity.direction == 'right' then
        self.entity.x = self.entity.x + self.entity.walkSpeed * dt

        if self.entity.x + self.entity.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.entity.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.entity.width
            self.bumped = true
        end
    elseif self.entity.direction == 'up' then
        self.entity.y = self.entity.y - self.entity.walkSpeed * dt

        if self.entity.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2 then 
            self.entity.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.entity.height / 2
            self.bumped = true
        end
    elseif self.entity.direction == 'down' then
        self.entity.y = self.entity.y + self.entity.walkSpeed * dt

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.entity.y + self.entity.height >= bottomEdge then
            self.entity.y = bottomEdge - self.entity.height
            self.bumped = true
        end
    end
    -- si es el jefe manejar el disparo
    if self.entity.isBoss then
        -- sctualizar el temporizador de disparo
        self.shootTimer = self.shootTimer + dt
        
        --si es hora de disparar
        if self.shootTimer >= self.shootInterval then
            self.shootTimer = 0

            local dx = self.room.player.x - self.entity.x
            local dy = self.room.player.y - self.entity.y
            
            local direction
            if math.abs(dx) > math.abs(dy) then
               
                direction = dx > 0 and 'right' or 'left'
            else
             
                direction = dy > 0 and 'down' or 'up'
            end
            --crea una bola de fuego
            local fireball = GameObject(
                GAME_OBJECT_DEFS['fire'],
                self.entity.x,
                self.entity.y
            )
            
       
            local projectile = Projectile(fireball, direction)
            table.insert(self.room.projectiles, projectile)
            
            
            SOUNDS['sword']:play()
        end
    end

      --actualizar el parpadeo de la barra de vida
    if self.entity.isBoss and not self.entity.swordImmune then
        self.healthBarBlinkTimer = self.healthBarBlinkTimer + dt
        if self.healthBarBlinkTimer >= self.healthBarBlinkInterval then
            self.healthBarBlinkTimer = 0
            self.healthBarVisible = not self.healthBarVisible
        end
    else
        self.healthBarVisible = true
    end



end

function EntityWalkState:processAI(params, dt)
    local room = params.room
    local directions = {'left', 'right', 'up', 'down'}

    if self.moveDuration == 0 or self.bumped then
        
        -- set an initial move duration and direction
        self.moveDuration = math.random(5)
        self.entity.direction = directions[math.random(#directions)]
        self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0

        -- chance to go idle
        if math.random(3) == 1 then
            self.entity:changeState('idle')
        else
            self.moveDuration = math.random(5)
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
        end
    end

    self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(TEXTURES[anim.texture], FRAMES[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x - self.entity.offsetX), math.floor(self.entity.y - self.entity.offsetY))
    
    -- love.graphics.setColor(love.math.colorFromBytes(255, 0, 255, 255))
    -- love.graphics.rectangle('line', self.entity.x, self.entity.y, self.entity.width, self.entity.height)
    -- love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 255))



    
    if self.entity.isBoss then
        
        if self.healthBarVisible or self.entity.swordImmune then
         
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle('fill', 
                self.entity.x, 
                self.entity.y - 10, 
                self.entity.width, 
                4)
            
            -- barra de vida actual (verde)
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.rectangle('fill', 
                self.entity.x, 
                self.entity.y - 10, 
                (self.entity.health / 20) * self.entity.width,
                4)
        end
        
      
        love.graphics.setColor(1, 1, 1, 1)
    end
end