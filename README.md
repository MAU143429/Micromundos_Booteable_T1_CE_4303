# 🐢 Micromundos Bootable — CE4303

## 🧠 Task Overview

This repository contains the implementation of Micromundos Bootable, a low-level interactive application developed for the course CE4303 — Operating Systems Principles. The goal of the assignment is to understand the boot process and implement a simple interactive system that runs directly from the bootloader without any operating system or emulator.

The game allows a player to control a turtle that draws paths on the screen using a keyboard. It runs on x86 assembly architecture and it is meant to execute directly at boot time from a disk image.

---

## 🎮 Gameplay Summary

- Move the turtle in 8 directions using arrow keys and `Q`, `E`, `A`, `D`.
- Use the Spacebar to toggle drawing mode.
- Use the Z key to toggle erase mode.
- Draw a closed path (e.g., a rectangle) in under 1 minute to win.
- If time runs out, a game over animation is triggered.
- The game includes:
  - Live display of time remaining
  - On-screen help for controls
  - Color-coded movement (8 directions = 8 colors)
  - Keyboard confirmation to start
  - Restart and exit controls

---

## 🖥️ Technical Requirements

- Must be implemented in Assembly x86
- Must run on real hardware, not just in emulators
- Include a bootloader that welcomes the user and starts the game
- Provide a Makefile to compile and generate the bootable image
- Display must use BIOS interrupts and hardware I/O for rendering

---

## 📌 Note

This project is an academic exercise to strengthen knowledge in:
- Assembly programming
- Bootloader development
- Hardware-level I/O
- Time-sensitive logic and interaction

All execution is performed **directly on hardware**, making it a valuable low-level systems engineering experience.
