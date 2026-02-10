# CircuitQuest

Welcome to CircuitQuest, an educational software with gamification elements, all about logic gates and circuits.

## Background

This app is based on a semester project by a group of exchange students at the University of Agder, Norway.
The original Python project can be found [here](https://github.com/Vlogenz/ICT-Project).
The idea for this project arised because some of us had a lecture in Computer Architecture before and we wanted to create a software that would help future students to learn the subject more easily.
This lecture was held at the home university of four of us in Münster, Germany by Prof. Paula Herber, which in turn was largely based on the book [Computer Organization and Design by David Patterson and John Hennessy](https://nsec.sjtu.edu.cn/data/MK.Computer.Organization.and.Design.4th.Edition.Oct.2011.pdf).
We based the contents of the levels, etc. mainly on this lecture.

After we finished the project at UiA, two of us decided to continue it. To make the app available cross-platform, we ported it to the Flutter framework. This version is what you see here.

## Installation

Perspectively, we want to release this app on the PlayStore and on the AppStore and also make it available as an executable for PC/Mac. Currently, you still have to clone the project and start it using `flutter run` (Flutter installation required).

## Features

### Sandbox Mode

In this mode, you can freely use all available components and build your own circuits without restrictions. You can:

- Evaluate circuits with different speeds and watch the animation
- Save circuits to continue working on them later
- Save circuits as custom components

### Level Mode

In this mode, you learn about computer architecture step-by-step. 
Starting with basic components like AND, OR, etc. you work your way up to an entire processor.

### The app directory

Circuits, custom components as well as your level progress are saved as JSON files in a CircuitQuest app directory. On Linux, Windows and Mac, this can be found inside your user's Documents folder.
