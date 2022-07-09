import "scripts/game/hitbox"

class('EnemyHitbox').extends(Hitbox)

function EnemyHitbox:init(enemy, xOffset, yOffset, w, h, delay, time, damage)
    self:setCollidesWithGroups(PLAYER_GROUP)
    EnemyHitbox.super.init(self, enemy, xOffset, yOffset, w, h, delay, time, damage)
end