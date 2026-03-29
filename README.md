# snake-verilog
A hardware implementation of the classic Snake game written entirely in Verilog HDL.

## Features
- 8×8 grid implemented using 2D arrays
- Snake movement with dynamic body shifting
- Pseudo-random food generation using LFSR
- Collision detection (boundary + self-collision)
- Optional AI mode for autonomous movement

## Design Overview
The snake is represented using coordinate arrays for each body segment. Movement is achieved by shifting body positions on every clock cycle. Food positions are generated using a Linear Feedback Shift Register (LFSR) to simulate randomness.

The design is fully synchronous and driven by a clock, highlighting the differences between hardware and software implementations of game logic.

## Notes
- Simulation uses a testbench with predefined inputs (non-interactive)
