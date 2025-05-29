# The Legend of the Princess (ARPG)

Este proyecto es un juego de acción y rol inspirado en clásicos del género, desarrollado en Love2D y Lua.

## ¿Cómo jugar?

- **Objetivo:** Explora las habitaciones, derrota enemigos y enfréntate al jefe final para ganar.
- **Controles:**
  - **Flechas del teclado:** Mover al personaje.
  - **Espacio:** Atacar con la espada.
  - **Enter:** Levantar y lanzar objetos (si están cerca).
  - **Escape:** Salir del juego.
  - **Z:** Disparar flechas tras obtener el arco del cofre.

## Mecánicas principales

- **Exploración:** Muévete por diferentes habitaciones conectadas por puertas.
- **Enemigos:** Cada habitación puede contener enemigos con diferentes patrones de movimiento y ataque.
- **Jefe:** Aparece aleatoriamente en la sala final. Debes esquivar sus bolas de fuego y atacarlo con la espada, pero solo después de haberle disparado una flecha para debilitarlo.
- **Objetos:** Puedes encontrar cofres, interruptores y otros objetos interactivos.
- **Proyectiles:** El jefe dispara bolas de fuego cada cierto tiempo. Si te golpean, perderás vida. Atacar al jefe sin haberle disparado la flecha primero no tendrá efecto.

## Estructura del código

- `src/world/Room.lua`: Lógica de las habitaciones, colisiones y objetos.
- `src/states/entity/EntityWalkState.lua`: Lógica de movimiento y ataques del jefe y enemigos.
- `src/states/entity/EntityIdleState.lua`: Estado de reposo de las entidades.
- `src/definitions/entity.lua`: Definición de entidades y animaciones.

## Requisitos

- [Love2D](https://love2d.org/) 11.3 o superior.

## Cómo ejecutar

1. Descarga o clona este repositorio.
2. Abre una terminal en la carpeta del proyecto.
3. Ejecuta el juego con:
   ```
   love .
   ```

## Créditos

- Colton Ogden (autor original)
- Alejandro Mujica (modificaciones educativas)
- Adaptado y extendido por Ana Veronica Jaimes, Eduardo Rodriguez y Davod Rondon 

---

¡Diviértete jugando y aprendiendo con The Legend of the Princess!
