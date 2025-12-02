CMPM-121-F25-F1

# Devlog Entry 3 - 12/05/2025

## How we satisfied the software requirements

**[continuous inventory] The game must involve one inventory item for which the continuous quantity matters in an interesting way (e.g. a bucket holds some continuously variable number of liters of water, but the bucket can't put out the fire unless it has enough water).**
- TBD

**[offline mobile] Support offline play on some smartphone-class mobile device (i.e. some way of installing the app so that it can be played by players who don't have live internet access).**
- TBD

**[save system] Support multiple save points as well as an auto-save feature so that the player cannot lose progress by accidentally closing the game app.**
- TBD

**[visual themes] Support light and dark modes visual styles that respond to the user's preferences set in the host environment (e.g. operating system or browser, not in-game settings), and these visual styles are integrated deeply into the game's display (e.g. day/night lighting of the fictional rooms, not just changing the border color of the game window)**
- TBD

**[touchscreen] Support touchscreen-only gameplay (no requirement of mouse and keyboard).**
- TBD

**[i18n + l10n] Support three different natural languages including English, a language with a logographic script (e.g. 中文), and a language with a right-to-left script (e.g. العربية).**
- TBD

**[unlimited undo] Support unlimited levels of undo of the major play actions (such as moving to a scene or interacting with a specific object, but don't worry about undo within a physics interaction)**
- TBD

**[external DSL] Use an external DSL to define some of the most important design details in the game (possibly reusing an existing syntax like XML, JSON, or s-expressions), and create some kind of tool support for that DSL (e.g. in-editor syntax highlighting).**
- TBD

## Reflection
**Looking back on how you achieved the F3 requirements, how has your team’s plan changed since your F3 devlog? There’s learning value in you documenting how your team’s thinking has changed over time.**
- Reflection here



# Devlog Entry 2 - 12/01/2025

## How we satisfied the software requirements

**The game uses the same 3D rendering and physics simulation identified by the team for F1 or suitable replacements that still satisfy the F1 requirements.**
  - We are currently using [g3d](https://github.com/groverburger/g3d) for the 3D physics as we had mentioned in our F1. 

**The game must allow the player to move between scenes (e.g. rooms)**
  - The player is able to move between the puzzle and the menu by clicking the ESC key and then clicking the respective button for which type of game they would like to play

**The game must allow the player to select specific objects in a scene for interaction (e.g. tapping an item to pick it up or examine it)**
  - Players are able to click each individual cell (minus the ones that are given for the puzzle) and add in a number or change a number previously added.

**The game maintains an inventory system allowing the player to carry objects so that what happens in one scene has an impact on what is possible in another scene.**
  - Still currently working on this.

**The game contains at least one physics-based puzzle that is relevant to the player's progress in the game.**
  - Still currently working on this.

**The player can succeed or fail at the physics-based puzzle on the basis of their skill and/or reasoning (rather than luck)**
  - The sudoku puzzles can only be won through deduction and critical thinking. The only way luck can be on the player's side is if they continuously keep guessing, that would take a really long time, though. 

**Via play, the game can reach at least one conclusive ending.**
  - Still working on this.

## Reflection 

**Looking back on how you achieved the F2 requirements, how has your team’s plan changed since your F1 devlog? There’s learning value in you documenting how your team’s thinking has changed over time.**
  - Reflection here



# Devlog Entry 1 - 11/21/2025

## Introducing the team
Tools Lead (Hannah): This person will research alternative tools, identify good ones, and help every other team member set them up on their own machine in the best configuration for your project. This person might also establish your team’s coding style guidelines and help peers setup auto-formatting systems. This person should provide support for systems like source control and automated deployment (if appropriate to your team’s approach).

Engine Lead (Annette): This person will research alternative engines, get buy-in from teammates on the choice, and teach peers how to use it if it is new to them. This might involve making small code examples outside of the main game project to teach others. The Engine Lead should also establish standards for which kinds of code should be organized into which folders of the project. They should try to propose software designs that insulate the rest of the team from many details of the underlying engine.

Design Lead (Ria): This person will be responsible for setting the creative direction of the project, and establishing the look and feel of the game. They might make small art or code samples for others to help them contribute and maintain game content. Where the project might involve a domain-specific language, the Design Lead (who is still an engineer in this class) will lead the discussion as to what primitive elements the language needs to provide.

Testing Lead (Fiona):  This person will be responsible for both any automated testing that happens within the codebase as well as organizing and reporting on human playtests beyond the team.

Technical Assistant (Kaushik): This person will support the team across all areas of software engineering that fall outside any single specialty. They will help teammates debug issues in their code, investigate errors, and propose fixes or improvements. The Technical Assistant should be comfortable tracing problems across different parts of the codebase, from tooling to runtime behavior. They may also help set up development environments, troubleshoot GPU or build issues, and ensure that everyone’s workflow runs smoothly. When team members hit technical roadblocks, the Technical Assistant is the point of contact. Their role is to unblock others quickly, document solutions, and keep the entire engineering process running efficiently.

## Tools and materials
With about one paragraph each (ideally including clickable hyperlinksLinks to an external site.)...

**Engine:** We are using the [**LÖVE2D**](https://love2d.org/) engine with these following libraries:
- For 3D: [g3d](https://github.com/groverburger/g3d)
    - Feels simple enough to implement 3D flat puzzles

- Typescript -> LÖVE: [LÖVE TypeScript Definitions](https://github.com/hazzard993/love-typescript-definitions)
    - Might use this due to familiarity of the typescript language
    
- For UI: [SUIT](https://github.com/vrld/SUIT)
    - It seems very easy to use to create menus and pause screens.

Overall, the LÖVE2D engine with these libraries seems to allow us to get closer to our goal of 3D orientated sudoku puzzles.

**Language:** TypeScript and Javascript. 

**Tools:** We are using Visual Studio Code for writing code as it has strong TS and JS support, built-in Git integration, and access to the live share extension. We will use the G3D library for implementing 3D flat puzzles as it seems simple to learn and use. 

**Generative AI:** We plan to use generative AI for several aspects, which include: debugging and how to refactor and improve the efficiency of the code. 

## Outlook
Give us a short section on your outlook on the project. You might cover one or more of these topics:

- tentative idea for project: sudoku game with 3 different ways of playing sudoku - regular sudoku (1 board of 3 by 3), 3d sudoku (3 boards of 3 by 3), and cube sudoku (6 boards pieced together to make a cube)

**What is your team hoping to accomplish that other teams might not attempt?**
- make a relatively straight forwards puzzle game (regular sudoku) more complicated lol

**What do you anticipate being the hardest or riskiest part of the project?**
- probably trying to figure out how to code the individual blocks in the board, and figuring out the math behind sudoku
- figuring out how to code cube sudoku, and remembering to code effectively and cleanly while navigating the actual implementation challenge

**What are you hoping to learn by approaching the project with the tools and materials you selected above?**
- learn how to code with a different language/application
