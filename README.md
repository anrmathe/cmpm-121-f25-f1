cmpm-121-f25-f1

# Devlog Entry - 11/27/25

One of the TAs suggested that we scale down the scope of the game we're making, so instead of the original goal (regular sudoku, 3d sudoku, cube sudoku) we're just going to do the regular sudoku and 3d sudoku.

# Devlog Entry - 11/14/25

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

- sudoku game with 3 modes (classic, 3d, cube) and 3 difficulties (easy, medium, hard)

**What is your team hoping to accomplish that other teams might not attempt?**

- make a relatively straight forwards puzzle game (regular sudoku) more complicated lol

**What do you anticipate being the hardest or riskiest part of the project?**

- probably trying to figure out how to code the individual blocks in the board, and figuring out the math behind sudoku
- figuring out how to code cube sudoku, and remembering to code effectively and cleanly while navigating the actual implementation challenge

**What are you hoping to learn by approaching the project with the tools and materials you selected above?**

- learn how to code with a different language/application
