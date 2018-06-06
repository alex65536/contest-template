# Contest template

This is my template to create contest. It is useful for auto-generations tests, statements. Also it can deploy contests to a modified version of [Contest Management System](https://github.com/alex65536/cms). For all these purposes, a set of Makefiles and shell script is used.

This template is not big, so the contests can be made on this template and distributed along with it.

See `help/` subdirectory for some extra information.

## Dependencies

Dependencies required to build the contest:
    * Bash
    * GNU Make
    * GNU C
    * GNU C++
    * Free Pascal Compiler
    * GNU M4
    * latexmk
    * jq
    * SSH (to use `make deploy` with a patched CMS)

See also `help/dependencies.txt`.
