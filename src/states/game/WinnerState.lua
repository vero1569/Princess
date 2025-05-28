--[[
    ISPPV1 2024
    Study Case: The Legend of the Princess (ARPG)

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Modified by Alejandro Mujica (alejandro.j.mujic4@gmail.com) for teaching purpose.

    This file contains the class WinnerState for the game.
]]
WinnerState = Class{__includes = BaseState}

function WinnerState:init()
    SOUNDS['start-music']:setLooping(true)
    SOUNDS['start-music']:play()
end

function WinnerState:exit()
    SOUNDS['start-music']:stop()
end

function WinnerState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        stateMachine:change('start')
    end
end

function WinnerState:render()
    love.graphics.draw(TEXTURES['background'], 0, 0, 0, 
        VIRTUAL_WIDTH / TEXTURES['background']:getWidth(),
        VIRTUAL_HEIGHT / TEXTURES['background']:getHeight())
    
    love.graphics.setFont(FONTS['princess'])
    
    love.graphics.setColor(love.math.colorFromBytes(34, 34, 34, 255))
    love.graphics.printf('WINNER', 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(love.math.colorFromBytes(175, 53, 42, 255))
    love.graphics.printf('WINNER', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255, 255))
    love.graphics.setFont(FONTS['princess-small'])
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')
end