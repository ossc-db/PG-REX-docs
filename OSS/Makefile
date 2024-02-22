#

PANDOC = pandoc
PANDOC_OPT =
HEADER_OPT = -f markdown+pandoc_title_block+yaml_metadata_block
PANDOC_DOCX_OPT = --data-dir=. --reference-doc=$(STYLEDOC) -p
PANDOC_HTML_OPT = 
PANDOC_PDF_OPT = 
TASK_OPT = --standalone --data-dir=. --template=task_template

STYLEDOC = reference.docx
SOURCES = pg-rex_man01.md pg-rex_man02.md pg-rex_man03_1_2.md pg-rex_man03_3.md pg-rex_man03_4.md pg-rex_man03_5.md pg-rex_man03_6.md pg-rex_man03_7.md pg-rex_man04.md pg-rex_man05.md pg-rex_man06_01-03.md pg-rex_man06_04-07.md pg-rex_man06_08-11.md pg-rex_man06_13-14.md pg-rex_man07_1.md pg-rex_man07_2.md pg-rex_man07_3.md pg-rex_man08.md pg-rex_man09.md
SOURCE2 = pg-rex_man_header.md
SOURCE3 = manual_task.rst

MANUAL = $(MAN_DOCX) $(MAN_DOCX_HEADER)
MAN_DOCX = pg-rex_man.docx
MAN_DOCX_HEADER = $(SOURCE2:.md=.docx)
TASK = $(SOURCE3:.rst=.html)

all: $(MAN_DOCX) $(MAN_DOCX_HEADER)

task: $(TASK)

$(TASK) : $(SOURCE3)
	$(PANDOC) $(TASK_OPT) -t html $< -o $@

$(MAN_DOCX) : $(SOURCES)
	$(PANDOC) $(PANDOC_DOCX_OPT) --toc -t docx $(SOURCES) -o $@

$(MAN_DOCX_HEADER) : $(SOURCE2)
	$(PANDOC) $(PANDOC_DOCX_OPT) $(HEADER_OPT) -t docx $< -o $@

%.docx: %.md
	$(PANDOC) $(PANDOC_DOCX_OPT) -t docx $< -o $@

clean:
	- $(RM) $(MAN_DOCX) $(MAN_DOCX_HEADER) $(MAN_HTML) $(MAN_PDF) $(TASK) pg-rex_man??*.docx
