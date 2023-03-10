all: fr en
	echo "Fini"

pdf-all: pdf-fr pdf-en
	echo "Fini"

pdf-%:
	env TEXINPUTS=lib/fonts: pandoc --pdf-engine=lualatex *_$@.md -o Conference_$@.pdf

%:
	env TEXINPUTS=lib/fonts: pandoc \
		-i *_$@.md 98_Bibliographie.md 99_Conclusio.md -o Conference_$@.html \
		-t revealjs --standalone -c reveal.js/dist/theme/white.css -V revealjs-url=./reveal.js \
		--slide-level=2 \
		-L lib/gabc.lua
