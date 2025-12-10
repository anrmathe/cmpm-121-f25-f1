CMPM-121-F25-F1

# Devlog Entry 3 - 12/05/2025

## How we satisfied the software requirements

**[continuous inventory] The game must involve one inventory item for which the
continuous quantity matters in an interesting way (e.g. a bucket holds some
continuously variable number of liters of water, but the bucket can't put out
the fire unless it has enough water).**

- TBD

**[save system] Support multiple save points as well as an auto-save feature so
that the player cannot lose progress by accidentally closing the game app.**

- The game has an auto save function that can be toggled on or off depending on the user's preference. There is also a manual save option that players can click and a new game button if they would like to delete their most recent saved puzzle. As long as the user clicks the same difficulty when opening the game again, their old saved puzzle will open up just as it was left.

**[visual themes] Support light and dark modes visual styles that respond to the
user's preferences set in the host environment (e.g. operating system or
browser, not in-game settings), and these visual styles are integrated deeply
into the game's display (e.g. day/night lighting of the fictional rooms, not
just changing the border color of the game window)**

- We supported light and dark mode as well as color palettes by integrating them
  throughout the menu, and each individual game mode: 2d and 3d. Buttons,
  background colors, border and grid lines, all UI elements across difficulty
  levels, 2d and 3d, win screens, and cell colors are determined by these modes.

**[touchscreen] Support touchscreen-only gameplay (no requirement of mouse and
keyboard).**

- The game has buttons for numbers on the sudoku world where they can press to interact and fill in numbers without having to use keyboard. They can also use the mouse the rotate the cube in order to access the other sides of the cubes. In the 3d world, there are jump buttons and a joystick that the player can use to move their player around, as well has the ability to click on the screen to control their camera, mimicing the usage of mouse and keyboard.

**[i18n + l10n] Support three different natural languages including English, a
language with a logographic script (e.g. 中文), and a language with a
right-to-left script (e.g. العربية).**

- We supported three different natural languages: English, Chinese, and Arabic. We built a lightweight localization system (locale.lua) that stores all in-game text for each language and handles runtime switching between them. We also added full language-aware font sets in main.lua so logographic fonts (中文) and right-to-left Arabic script display correctly. All the text in the game menus, instructions, error messages, and win screens automatically update when a new language is chosen.

**[unlimited undo] Support unlimited levels of undo of the major play actions
(such as moving to a scene or interacting with a specific object, but don't
worry about undo within a physics interaction)**

- TBD

**[external DSL] Use an external DSL to define some of the most important design
details in the game (possibly reusing an existing syntax like XML, JSON, or
s-expressions), and create some kind of tool support for that DSL (e.g.
in-editor syntax highlighting).**

- I added a game_config.json which stores data's for each game setting, amount of objects and space of the players inventory in it. This is called into the game in the config.lua where it creates seperate functions for calling data for each mode, as well as calling data for the world generation. I have also included settings.json in the .vscode directory which allows highlighing of the all the variables in game_config.json and what they are allowed to contain.

## Reflection

**Looking back on how you achieved the F3 requirements, how has your team’s plan
changed since your F3 devlog? There’s learning value in you documenting how your
team’s thinking has changed over time.**

- We spread the work for this assignment a lot more evenly than the other two. We stayed fairly close to what our original plan was and didn't have to make any changes regarding how we should approach the assignment specs. If anything, we mainly tested our commits more often due to the game crashing on one person's device but not on other's. We helped each other out and made sure everyone was able to run and see the same game across all screens. 

# Devlog Entry 2 - 12/01/2025

## How we satisfied the software requirements

**The game uses the same 3D rendering and physics simulation identified by the
team for F1 or suitable replacements that still satisfy the F1 requirements.**

- We are currently using [g3d](https://github.com/groverburger/g3d) for the 3D
  physics as we had mentioned in our F1.

**The game must allow the player to move between scenes (e.g. rooms)**

- The player is able to move between the puzzle and the menu by clicking the ESC
  key and then clicking the respective button for which type of game they would
  like to play. The two mode available as of now are the 2D and 3D (cube) mode.
  Everytime they click ESC and return to the menu, their progress is lost and
  they return to a different mode. A different scene that was implemented is
  when the player wins, they are then taken to a win screen. You can access the
  menu again from this scene by clicking the ESC key. We are currently working
  on keeping a memory of wins and potentially times as well.

**The game must allow the player to select specific objects in a scene for
interaction (e.g. tapping an item to pick it up or examine it)**

- Players are able to click each individual cell (minus the ones that are given
  for the puzzle) and add in a number or change a number previously added.
  Players can interact with the cube sudoku puzzle the same way and can click
  and drag, or use the arrow keys, to rotate and move around the cube.

**The game maintains an inventory system allowing the player to carry objects so
that what happens in one scene has an impact on what is possible in another
scene.**

- Still currently working on this.

**The game contains at least one physics-based puzzle that is relevant to the
player's progress in the game.**

- The physics based puzzle is the cube sudoku.

**The player can succeed or fail at the physics-based puzzle on the basis of
their skill and/or reasoning (rather than luck)**

- The sudoku puzzles can only be won through deduction and critical thinking.
  The only way luck can be on the player's side is if they continuously keep
  guessing, that would take a really long time, though. Once the sudoku puzzle
  is finished, the player is taken to a win screen with the time it took for
  them to complete the puzzle displayed on the screen.

**Via play, the game can reach at least one conclusive ending.**

- As of now, once the player completes the 2d mode of sudoku, they are taken to
  a win screen with the amount of time spent displayed as well.

## Reflection

**Looking back on how you achieved the F2 requirements, how has your team’s plan
changed since your F1 devlog? There’s learning value in you documenting how your
team’s thinking has changed over time.**

- We wanted to achieve many things during F1, specifically our three different
  types of sudoku modes. We weren't able to implement the 3D sudoku (3 boards of
  3x3 grids), but we were able to fully implement the 2D and cube mode. We
  realized that going for three different modes was pretty difficult, especially
  with the bugs that came with the cube version already, and decided to polish
  the two modes we had working already instead of aiming for a third version
  that would've costed us more time to implement/debug that wouldn't have been
  worth it in the end (considering our schedules + other classes). We were also
  thinking of implementing items that could lead to solving the puzzle more
  easily so that it isn't just plain sudoku (this is still in talks, though).
  Additionally, we began incorporating the 3D world and inventory, but we still
  plan to tie the two with the sudoku implementation itself.

# Devlog Entry 1 - 11/21/2025

## Introducing the team

Tools Lead (Hannah): This person will research alternative tools, identify good
ones, and help every other team member set them up on their own machine in the
best configuration for your project. This person might also establish your
team’s coding style guidelines and help peers setup auto-formatting systems.
This person should provide support for systems like source control and automated
deployment (if appropriate to your team’s approach).

Engine Lead (Annette): This person will research alternative engines, get buy-in
from teammates on the choice, and teach peers how to use it if it is new to
them. This might involve making small code examples outside of the main game
project to teach others. The Engine Lead should also establish standards for
which kinds of code should be organized into which folders of the project. They
should try to propose software designs that insulate the rest of the team from
many details of the underlying engine.

Design Lead (Ria): This person will be responsible for setting the creative
direction of the project, and establishing the look and feel of the game. They
might make small art or code samples for others to help them contribute and
maintain game content. Where the project might involve a domain-specific
language, the Design Lead (who is still an engineer in this class) will lead the
discussion as to what primitive elements the language needs to provide.

Testing Lead (Fiona): This person will be responsible for both any automated
testing that happens within the codebase as well as organizing and reporting on
human playtests beyond the team.

Technical Assistant (Kaushik): This person will support the team across all
areas of software engineering that fall outside any single specialty. They will
help teammates debug issues in their code, investigate errors, and propose fixes
or improvements. The Technical Assistant should be comfortable tracing problems
across different parts of the codebase, from tooling to runtime behavior. They
may also help set up development environments, troubleshoot GPU or build issues,
and ensure that everyone’s workflow runs smoothly. When team members hit
technical roadblocks, the Technical Assistant is the point of contact. Their
role is to unblock others quickly, document solutions, and keep the entire
engineering process running efficiently.

## Tools and materials

With about one paragraph each (ideally including clickable hyperlinksLinks to an
external site.)...

**Engine:** We are using the [**LÖVE2D**](https://love2d.org/) engine with these
following libraries:

- For 3D: [g3d](https://github.com/groverburger/g3d)
  - Feels simple enough to implement 3D flat puzzles

- Typescript -> LÖVE:
  [LÖVE TypeScript Definitions](https://github.com/hazzard993/love-typescript-definitions)
  - Might use this due to familiarity of the typescript language

- For UI: [SUIT](https://github.com/vrld/SUIT)
  - It seems very easy to use to create menus and pause screens.

Overall, the LÖVE2D engine with these libraries seems to allow us to get closer
to our goal of 3D orientated sudoku puzzles.

**Language:** TypeScript and Javascript.

**Tools:** We are using Visual Studio Code for writing code as it has strong TS
and JS support, built-in Git integration, and access to the live share
extension. We will use the G3D library for implementing 3D flat puzzles as it
seems simple to learn and use.

**Generative AI:** We plan to use generative AI for several aspects, which
include: debugging and how to refactor and improve the efficiency of the code.

## Outlook

Give us a short section on your outlook on the project. You might cover one or
more of these topics:

- tentative idea for project: sudoku game with 3 different ways of playing
  sudoku - regular sudoku (1 board of 3 by 3), 3d sudoku (3 boards of 3 by 3),
  and cube sudoku (6 boards pieced together to make a cube)

**What is your team hoping to accomplish that other teams might not attempt?**

- make a relatively straight forwards puzzle game (regular sudoku) more
  complicated lol

**What do you anticipate being the hardest or riskiest part of the project?**

- probably trying to figure out how to code the individual blocks in the board,
  and figuring out the math behind sudoku
- figuring out how to code cube sudoku, and remembering to code effectively and
  cleanly while navigating the actual implementation challenge

**What are you hoping to learn by approaching the project with the tools and
materials you selected above?**

- learn how to code with a different language/application
