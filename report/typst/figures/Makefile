# Compile chaque diagramme TikZ standalone en PDF
# Usage : make           -> compile tous les .tex en .pdf
#         make clean     -> supprime fichiers auxiliaires
#         make distclean -> supprime aussi les PDF générés

LATEX     := pdflatex
LATEXOPTS := -interaction=nonstopmode -halt-on-error -file-line-error

# Tous les diagrammes (sauf le préambule partagé)
SRC := $(filter-out preambule.tex,$(wildcard *.tex))
PDF := $(SRC:.tex=.pdf)

.PHONY: all clean distclean
all: $(PDF)

%.pdf: %.tex preambule.tex
	@echo "==> Compilation $<"
	@$(LATEX) $(LATEXOPTS) $< > /dev/null || (echo "ERREUR sur $<"; tail -n 30 $*.log; exit 1)
	@$(LATEX) $(LATEXOPTS) $< > /dev/null

clean:
	@rm -f *.aux *.log *.out *.synctex.gz *.fls *.fdb_latexmk

distclean: clean
	@rm -f $(PDF)
