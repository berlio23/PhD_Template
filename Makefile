ifndef V
	TO_LOG = >> ${LOG} 2<&1
else
	TO_LOG = 
endif

ifndef TARGET
	TARGET := main.tex
endif

ifndef BIBLIO
	BIBLIO := biblio.bib
endif

ifndef CLASS
	CLASS := phdclass
endif

OS := $(shell uname)

COLOR_BASE := \033[0m
COLOR_RED := \033[1;31m
COLOR_GREEN := \033[1;32m
COLOR_ORANGE := \033[0;33m
COLOR_BLUE := \033[1;34m

CHAP_TEMPLATE := .chapter_template
CHAP_PREFIX := chap_
CHAPS = $(wildcard ${CHAP_PREFIX}*)
CHAP_MAIN = main
CHAP_TEX = chap.tex
SRC = $(wildcard ${CHAP_PREFIX}*/main.tex)

MAIN_STY := macros

PDF_PATH := pdf
LOG_PATH := logs
LOG := ${LOG_PATH}/compile.log

#TODO: replace command execution to check wether the configuration is valid or not. Or the compiler does not exists
LATEXMK := \
	if ! [ -f .latexmkrc ]; then \
	echo "${COLOR_RED}No latexmk configuration file found${COLOR_BASE}"; \
	echo "${COLOR_ORANGE}Run make configure to create latexmk configuration file${COLOR_BASE}"; \
	exit 1; \
	fi; \
	latexmk

COMPILE_CHAP = cd ${CHAP_PREFIX}$$${CHAP_TO_COMPILE}; \
	echo 'Compiling chapter '$$${CHAP_TO_COMPILE}; \
	echo 'Creating ${CHAP_MAIN}.tex'; \
	touch ${CHAP_MAIN}.tex; \
	echo '\\documentclass[draft]{../${CLASS}}' > '${CHAP_MAIN}.tex'; \
	echo '\\usepackage{../${MAIN_STY}}' >> ${CHAP_MAIN}.tex; \
	echo '\\begin{document}' >> '${CHAP_MAIN}.tex'; \
	echo '\\input{${CHAP_TEX}}' >> ${CHAP_MAIN}.tex; \
	echo '\\bibliographystyle{alpha}' >> ${CHAP_MAIN}.tex; \
	echo '\\bibliography{../${BIBLIO}}' >> ${CHAP_MAIN}.tex; \
	echo '\\end{document}' >> '${CHAP_MAIN}.tex'; \
	echo ${CONFIG_LATEXMKRC} >> .latexmkrc; \
	mkdir ${PDF_PATH}; \
	mkdir ${LOG_PATH}; \
	rm -f ${LOG}; \
	echo 'Compiling '$$${CHAP_TO_COMPILE}'/main.tex'; \
	${LATEXMK} -pdf ${CHAP_MAIN}.tex ${TO_LOG}; \
	echo 'Copying logs and pdf...'; \
	cp ${LOG_PATH}/main.log ../${LOG_PATH}/$$${CHAP_TO_COMPILE}.log; \
	cp ${PDF_PATH}/main.pdf ../${PDF_PATH}/$$${CHAP_TO_COMPILE}.pdf; \
	rm -f ${CHAP_MAIN}.*; \
	rm -r ${LOG_PATH} ${PDF_PATH}; \
	rm .latexmkrc; \
	cd ..; \
	echo 'Done.'

CHAP_TO_COMPILE := chapname

ifeq (${OS}, Linux)
	VIEWER := evince
else ifeq (${OS}, Darwin)
	VIEWER := apercu
endif

CONFIG_LATEXMKRC = "\$$silent = 1;\
	\n\$$fdb_ext = 'fdb';\
	\n\
	\n@default_files = ('main.tex');\
	\n\
	\n\#\$$aux_dir = 'aux';\
	\n\#\$$ENV{PDF_PATH} = \$$out_dir;\
	\n\
	\n\$$pdf_mode = 1;\
	\n\#\$$pdflatex = 'pdflatex %O -halt-on-error -shell-escape %S; cp %B.pdf locked.%B.pdf';\
	\n\$$pdflatex = 'pdflatex %O -synctex=1 -interaction=nonstopmode %S; cp %B.pdf ${PDF_PATH}/%B.pdf; cp %B.log ${LOG_PATH}/%B.log';\
	\n\$$pdf_previewer = 'start ${VIEWER} %O %S';\
	\n\
	\n\$$clean_ext .= 'bbl nav out auxlock';"

include .env

.PHONY: all view continuous clean cleanlog cleanall force rebuild .env

all:
	@echo 'Compiling ${TARGET}...'
	@${LATEXMK} ${TARGET} ${TO_LOG}

	@rm -f .env
	@echo 'Done.'

view:
	@echo 'Compiling and preview ${TARGET}...'
	@${LATEXMK} -pv ${TARGET} ${TO_LOG}
	@echo 'Done.'

continuous:
	@echo 'Continuous compilation of ${TARGET}...'
	@echo 'Ctrl+C to stop.'
	${LATEXMK} -pvc ${TARGET} ${TO_LOG}
	@echo 'Ended.'

newchap:
	@echo 'Creating new chapter...'
	@while true; do \
	echo '${COLOR_BLUE}Enter chapter name:${COLOR_BASE} (Ctrl+C to cancel)'; \
	read ${CHAP_TO_COMPILE}; \
	if [ -d ${CHAP_PREFIX}$$${CHAP_TO_COMPILE} ]; then \
	echo '${COLOR_RED}Chapter already exists!${COLOR_BASE}'; \
	else echo '${COLOR_GREEN}Creating ${CHAP_PREFIX}'$$${CHAP_TO_COMPILE}'...${COLOR_BASE}'; \
	mkdir ${CHAP_PREFIX}$$${CHAP_TO_COMPILE}; \
	touch ${CHAP_PREFIX}$$${CHAP_TO_COMPILE}/${CHAP_TEX}; \
	break; \
	fi;\
	done
	@echo 'Done.'

chap:
	@while true; do \
	echo '${COLOR_BLUE}Select chapter to compile:${COLOR_BASE} (Ctrl+C to cancel)'; \
	echo 'Available: ${COLOR_GREEN}${CHAPS}${COLOR_BASE}' | sed 's/${CHAP_PREFIX}//g'; \
	read ${CHAP_TO_COMPILE}; \
	if [ -d ${CHAP_PREFIX}$$${CHAP_TO_COMPILE} ]; then \
	echo '${COLOR_GREEN}Chapter '$$${CHAP_TO_COMPILE}' found${COLOR_BASE}'; \
	break; \
	else echo '${COLOR_RED}Chapter '$$${CHAP_TO_COMPILE}' does not exists${COLOR_BASE}'; \
	fi; \
	done; \
	${COMPILE_CHAP}

allchap:
	@for chap in ${CHAPS}; do \
	${CHAP_TO_COMPILE}=$$(echo $$chap | sed 's/.*_//'); \
	${COMPILE_CHAP}; \
	done

#TODO: Remove debug only dangerous command
delchapall:
	@echo 'Deleting all chapters...'
	@rm -r ${CHAPS}
	@echo 'Done.'

test:
	@for name in ${CHAPS}; do \
	echo $$name | sed 's/.*_//'; \
	done

.env: cleanlog
	@if ! [ -d ${LOG_PATH} ]; then \
	echo 'Directory ${LOG_PATH} does not exists, creating...'; \
	mkdir ${LOG_PATH}; \
	fi
	@if ! [ -d ${PDF_PATH} ]; then \
	echo 'Directory ${PDF_PATH} does not exists, creating...'; \
	mkdir ${PDF_PATH}; \
	fi

cleanlog:
	@rm -f ${LOG}

clean:
	@echo 'Cleaning aux files...'
	@${LATEXMK} -c ${TARGET} ${TO_LOG}
	@rm -f *.log
	@rm -f *.aux
	@rm -f *.gz
	@rm -f *.out
	@rm -f *.fls
	@rm -f *.fdb
	@rm -f *.bbl
	@rm -f *.blg
	@rm -f *.pdf
	@rm -f .env
	@echo 'Done.'

cleanall: clean
	@echo 'Cleaning compiled files...'
	@${LATEXMK} -C ${TARGET} ${TO_LOG}
	@rm -rf ${PDF_PATH}
	@rm -rf ${LOG_PATH}
	@echo 'Done.'

rebuild: cleanall view 

configure:
ifeq (${OS}, Linux)
	@echo "${COLOR_ORANGE}Linux Operating System detected${COLOR_BASE}"
else ifeq (${OS}, Darwin)
	@echo "${COLOR_ORANGE}Mac Operating System detected${COLOR_BASE}"
	@echo "To synchronize editor with Apercu go to option TODO: je sais plus le nom"
else
	@echo "${COLOR_RED}Error: Operating System not detected"
	@exit 1
endif
	@echo "Creating .latexmkrc config file..."
	@echo ${CONFIG_LATEXMKRC} > .latexmkrc
	@echo "Done."

dep:
ifeq (${OS}, Linux)
	@echo "${COLOR_ORANGE}Installing Texlive full distribution...${COLOR_BASE}"
	sudo apt install texlive-full
	@echo "${COLOR_ORANGE}Installing Latexmk...${COLOR_BASE}"
	sudo apt install latexmk
	@echo "${COLOR_ORANGE}Installing Evince...${COLOR_BASE}"
	sudo apt install evince
else ifeq (${OS}, Darwin)
	@echo "${COLOR_ORANGE}Installing Homebrew package manager...{COLOR_BASE}"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo "${COLOR_ORANGE}Installing Texlive full distribution...${COLOR_BASE}"
	brew install texlive
	@echo "${COLOR_ORANGE}Installing Latexmk...${COLOR_BASE}"
	brew install latexmk
else
	@echo "${COLOR_RED}Operating System not detected${COLOR_BASE}"
	@exit 1
endif

usage:
	@echo "${COLOR_ORANGE}README means Read me!${COLOR_BASE}"