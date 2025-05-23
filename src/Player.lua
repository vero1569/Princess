--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the class Player.
]]
Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:render()
     --dibuja el sprite del jugador desde este render 
    local anim = self.currentAnimation
    love.graphics.draw(
        TEXTURES[anim.texture],
        FRAMES[anim.texture][anim:getCurrentFrame()],
        math.floor(self.x - self.offsetX),
        math.floor(self.y - self.offsetY)
    )

    --dibuja el mas arriba del jugador
    if self.hasBow and self.bowFrame then
        love.graphics.draw(
            TEXTURES['bow'],
            FRAMES['bow'][self.bowFrame],
            math.floor(self.x - self.offsetX),
            math.floor(self.y - self.offsetY - 15)
        )
    end
    
    -- love.graphics.setColor(love.math.colorFromBytes(255, 0, 255, 255))
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 255))
end
