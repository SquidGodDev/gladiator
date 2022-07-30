import "scripts/game/hitbox"

class('PlayerHitbox').extends(Hitbox)

function PlayerHitbox:init(player, xOffset, yOffset, w, h, delay, time, damage)
    self:setCollidesWithGroups(ENEMY_GROUP)
    PlayerHitbox.super.init(self, player, xOffset, yOffset, w, h, delay, time, damage)
    self.rechargesSpin = false
end

function PlayerHitbox:setRechargesSpin(flag)
    self.rechargesSpin = flag
end

function PlayerHitbox:signalDamage()
    if self.rechargesSpin then
        SignalController:notify("enemy_damaged")
    end
end