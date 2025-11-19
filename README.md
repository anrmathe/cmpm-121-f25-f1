cmpm-121-f25-f1

# Devlog Entry - 11/14/25

## Introducing the team
Tools Lead (Hannah): This person will research alternative tools, identify good ones, and help every other team member set them up on their own machine in the best configuration for your project. This person might also establish your team’s coding style guidelines and help peers setup auto-formatting systems. This person should provide support for systems like source control and automated deployment (if appropriate to your team’s approach).

Engine Lead (Annette): This person will research alternative engines, get buy-in from teammates on the choice, and teach peers how to use it if it is new to them. This might involve making small code examples outside of the main game project to teach others. The Engine Lead should also establish standards for which kinds of code should be organized into which folders of the project. They should try to propose software designs that insulate the rest of the team from many details of the underlying engine.

Design Lead (Ria): This person will be responsible for setting the creative direction of the project, and establishing the look and feel of the game. They might make small art or code samples for others to help them contribute and maintain game content. Where the project might involve a domain-specific language, the Design Lead (who is still an engineer in this class) will lead the discussion as to what primitive elements the language needs to provide.
Testing Lead (Fiona):  This person will be responsible for both any automated testing that happens within the codebase as well as organizing and reporting on human playtests beyond the team.

Technical Assistant (Kaushik): This person will support the team across all areas of software engineering that fall outside any single specialty. They will help teammates debug issues in their code, investigate errors, and propose fixes or improvements. The Technical Assistant should be comfortable tracing problems across different parts of the codebase, from tooling to runtime behavior. They may also help set up development environments, troubleshoot GPU or build issues, and ensure that everyone’s workflow runs smoothly. When team members hit technical roadblocks, the Technical Assistant is the point of contact. Their role is to unblock others quickly, document solutions, and keep the entire engineering process running efficiently.

## Tools and materials
With about one paragraph each (ideally including clickable hyperlinksLinks to an external site.)...

**Engine:** Tell us about what engines, libraries, frameworks, and or platforms you intend to use, and give us a tiny bit of detail about why your team chose those. You are not committing to use this engine to finish the project, just sharing your initial thinking on engine choice. IMPORTANT: In order to satisfy the F1 Requirements, you'll need to choose something that doesn't already support high-level 3D rendering and physics (it must be something that requires you to bring those features in for yourself). If you don't know what to use, "the baselineLinks to an external site. web browser platform" is a good default choice.

**Language:** Tell us programming languages (e.g. TypeScript) and data languages (e.g. JSON) you team expects to use and why you chose them. Presumably you’ll just be using the languages expected by your previously chosen engine/platform.

**Tools:** Tell us about which tools you expect to use in the process of authoring your project. You might name the IDE for writing code, the image editor for creating visual assets, or the 3D editor you will use for building your scene. Again, briefly tell us why you made these choices. Maybe one of your teammates feels especially skilled in that tool or it represents something you all want to learn about.

**Generative AI:** Tell us about your team's plan for using (or not using) tools based on generative AI, whether they are agentic or not. For example, will you be requiring team members to use or not use specific features of specific tools? Perhaps you plan use the autocomplete features in Github Copilot but not the agent mode. Maybe you will only use the agent mode under specific instructions for it to not make any direct modifications to your code, only giving the developer advice on how to proceed.

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
