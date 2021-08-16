# Ant Colony Optimisation Demonstration Software

Author: Emilie Tavernier

The Ant Colony Optimisation (ACO) demonstration software is an educational tool demonstrating ACO algorithms usage in a variety of problems (traveling salesman problem, job scheduling and edge detection).<br/>
This project was realised for a dissertation for the degree of MSc. Artificial Intelligence at Heriot Watt University (Scotland).<br/>

![image](https://user-images.githubusercontent.com/47278505/129526981-e2f26d0f-3e22-4fd9-bfb8-dd9ad98bd999.png)

## Getting Started

This software is accessible as a web app at this address: https://emilietavernier.github.io/MSc_ACO_Project/#/<br/>
The desktop version (windows only) is contained in the folder "aco_windows_release" (run the executable file .exe to launch the app). <br/>
For better performance, the <b>desktop version is advised</b>.<br/>

## Setting up the development environment

This is an open-source project. You are free to copy the code and expand on it. <br/>
Here is the set up I used for my development environment:
- Install IntelliJ IDE
- Install Flutter SDK
- In IntelliJ, install Dart and Flutter plugins
- Create a new flutter project (check web platform box)
- For desktop development, use in terminal:<br/>
    $ flutter config --enable-windows-desktop<br/>
    $ flutter config --enable-macos-desktop<br/>
    $ flutter config --enable-linux-desktop<br/>
- For web, Chrome or Edge are the default supported browser
- To run the code, use in terminal:<br/>
    $ flutter run
