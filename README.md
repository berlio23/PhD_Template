# Ph.D Template

## Getting Started

This template uses ```latexmk``` to compile ```.tex``` files into ```.pdf```
Make sure to check dependencies to see necessary packages depending on your distribution.
Alternatively, use ```make dep``` to install it.
Use ```make configure``` to configure make to your environnement.
Currently supported :
- [X] Ubuntu
- [?] MacOS
- [X] Windows 11 (Use WSL please.)

## Usage
At any time use ```make usage``` to print available commands.

- ```make (all)```: to compile the whole manuscript, i.e the ```main.tex``` file. Compiled ```.pdf``` can be found under ```pdf/thesis.pdf```.

- ```make view```: to recompile the manuscript and open it in viewer.

- ```make continuous```: to compile dynamically the manuscript when saving ```.tex``` files.

- ```make newchap```: to create a new chapter. Awaits for the user to input the chapter name. Create a directory ```chap_${INPUT}``` with ```chap.tex``` inside.

- ```make allchap```: to compile all chapters individually. Output ```.pdf``` are stored under ```pdf/${CHAPNAME}.pdf```.

- ```make chap```: to compile specific chapter. Awaits for the user to input the chapter name.

- ```make clean```: to clean ```latexmk``` auxilliary files.

- ```make cleanlog```: to remove ```logs/``` directory under which the ```latexmk``` logs files are stored.

- ```make cleanall```: to clean all compiled files, including logs, auxilliary files and pdfs.

- ```make configure```: Configure ```.latexmkrc``` files depending on the OS

- ```make dep```: Install dependencies depending of the OS

## Requirements

- Linux: The latex compiler ```latexmk```; A valid tex distribution  ```textlive(-full)```; A pdf viewer as ```evince```
- MacOS: The package manager ```Homebrew```; The latex compiler ```latexmk```; A valide tex distribution ```texlive```

Dependencies can be installed using ```make dep```.

## Upcoming

- [ ] continuous compilation of a specific chapter
- [ ] view show a specific chapter
- [ ] delete a specific chapter with confirmation and archive
- [ ] empty dustbin
- [ ] configure to use on specific plateform
- [ ] Specify IDE and open tex files in that IDE
- [ ] make usage 
- [ ] make init OR make example
- [ ] make default to echo usage
- [ ] OS specific configuration
- [X] A nice README
- [ ] Synchronisation synctex !