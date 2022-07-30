import "scripts/game/hitbox"

class('PlayerHitbox').extends(Hitbox)

function PlayerHitbox:init(player, xOffset, yOffset, w, h, delay, time, damage)
    self:setCollidesWithGroups(ENEMY_GROUP)
    PlayerHitbox.super.init(self, player, xOffset, yOffset, w, h, delay, time, damage)
end

function PlayerHitbox:signalDamage()
    SignalController:notify("enemy_damaged")
end