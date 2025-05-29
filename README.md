# The Legend of the Princess (ARPG)

This project is an action-RPG inspired by classics of the genre, developed in Love2D and Lua.

## How to play

- **Objective:** Explore rooms, defeat enemies, and face the final boss to win.
- **Controls:**
- **Arrow keys:** Move your character.
- **Space:** Attack with your sword.
- **Enter:** Pick up and throw objects (if nearby).
- **Escape:** Quit the game.
- **Z:** Shoot arrows after obtaining the bow from the chest.

## Main Mechanics

- **Exploration:** Move through different rooms connected by doors.
- **Enemies:** Each room may contain enemies with different movement and attack patterns.
- **Boss:** Appears randomly in the final room. You must dodge its fireballs and attack it with your sword, but only after shooting it with an arrow to weaken it.
- **Objects:** You can find chests, switches, and other interactive objects.
- **Projectiles:** The boss shoots fireballs every so often. If they hit you, you will lose health. Attacking the boss without shooting it with an arrow first will have no effect.

## Code Structure

- `src/world/Room.lua`: Room logic, collisions, and objects.
- `src/states/entity/EntityWalkState.lua`: Boss and enemy movement and attack logic.
- `src/states/entity/EntityIdleState.lua`: Entity idle state.
- `src/definitions/entity.lua`: Entity definitions and animations.

## Requirements

- [Love2D](https://love2d.org/) 11.3 or higher.

## How to Run

1. Download or clone this repository.
2. Open a terminal in the project folder.
3. Run the game with:
```
love .
```

## Credits

- Colton Ogden (original author)
- Alejandro Mujica (educational modifications)
- Adapted and extended by Ana Veronica Jaimes, Eduardo Rodriguez, and Davod Rondon

---

Have fun playing and learning with The Legend of the Princess!