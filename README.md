# Gladiator
Source code for my unfinished side-scrolling roguelike Playdate game, "Gladiator".

https://github.com/user-attachments/assets/1f8669fb-5139-4fab-8425-9e51bddc7885

## Project Structure
- `scripts/`
    - `game/`
        - `gameScene.lua` 
            - `enemies/`
                - `basicEnemies/`
                    - `basicEnemy.lua` - A generic enemy with AI that wanders around, and runs and attacks the player when near - I extend this to create all the different enemy types
                - `enemy.lua` - A very simple enemy parent class that just handles setting the correct group and taking damage
                - `enemyHitbox.lua` - Extends the hitbox class and creates an enemy hitbox with the correct collision groups
            - `level/`
                - `spawnEffect.lua` - Handles drawing the pillar animation that appears when an enemy spawns
                - `waveController.lua` - Handles the wave spawning system that spawns in enemies
            - `player/`
                - `healthbar.lua` - Handles drawing the healthbar
                - `player.lua` - Handles the entire player movement, attacking, and state machine
                - `playerHitbox.lua` - Extends the hitbox class and creates a player hitbox with the correct collision groups
                - `spinAttackMeter.lua` - Handles drawing and keeping track of the spin attack meter
                - `swapPopup.lua` - Handles drawing and keeping track of the swap abilities
            - `results/`
                - `resultsScene.lua` - A temporary scene that shows how well you did with the infinite waves I added one of the weeks
                - `roomEndDisplay.lua` - A popup that shows you how much gold you've earned
            - `gameScene.lua` - The main scene that handles the main game/combat
            - `hitbox.lua` - A helper class that generates a hitbox
    - `libraries/`
        - `AnimatedSprite.lua` - A library from Whitebrim that allows you to create animated state machines
        - `Signal.lua` - A library from Dustin Mierau that allows you to subscribe to and send signals around the project, so you don't need a direct reference to something (it's like having signals from Godot)
    - `map/`
        - `shop/`
            - `shopScene.lua` - Handles the shop
        - `mapScene.lua` - Handles the level map 
    - `title/`
        - This is empty

## License
All code is licensed under the terms of the MIT license, with the exception of Signal.lua by Dustin Mierau.
