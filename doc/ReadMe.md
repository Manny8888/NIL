## Read Me ##

This folder contains a text version of the I-Machine Architecture Specification.
The original is a OCR-ed pdf file sourced from bitsavers.org.

The text is formatted in asciidoc markdown.


Two ways to work with asciidoc documents:
- Easy: install the Firefox addon / Chrome extension asciidoctor.js, which
  monitors the adoc file and converts to html on the fly. Firefox seems quicker
  for some reason...

- Install asciidoctor-pdf and asciidoctor-diagram, then run `asciidoctor-pdf
  --verbose -r asciidoctor-diagram [filename.adoc]`.

Note that:
- The file is edited as and when particular sections are read, starting with the
  Memory Layout chapter.

- The pdf contains a few duplicate pages showing the differences between,
  presumably, Revision 1 and Revision 2 of the document. This is progressively
  cleaned up to only retain Revision 2.

- Figures will be deleted until a way is found to recreate them. New figures
  will (might) be recreated with Graphviz.

- No list of tables or figures yet.

- No index.

