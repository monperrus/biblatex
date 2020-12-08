#!/usr/bin/env bash
set -x
usage () {
echo "Usage:

build.sh help
build.sh install <version> <tds_root>
build.sh uninstall <tds_root>
build.sh build <version>
build.sh builddist|builddocs|build <version>
build.sh testbibtex [file]|testbiber [file]|test [file]|testoutput 
build.sh upload <version> [ \"DEV\" ]

With the \"DEV\" argument, uploads to the SourceForge development
folder instead of the <version> numbered folder

Examples: 
obuild/build.sh install 3.8 ~/texmf/
obuild/build.sh uninstall ~/texmf/
obuild/build.sh build 3.8
obuild/build.sh upload 3.8 DEV

\"build test\" runs all of the example files (in a temp dir) and puts errors in a log:

obuild/example_errs_biber.txt
obuild/example_errs_bibtex.txt

You should run the \"build.sh install\" before test as it uses the installed biblatex and biber

\"build testoutput\" should be run after \"test\"/\"testbibtex\"/\"testbiber\" and will compare
at a low level the differences between the reference example PDFs and those generated by the test.

"
}

if [[ ! -e obuild/build.sh ]]
then
  echo "Please run in the root of the distribution tree" 1>&2
  exit 1
fi

if [[ "$1" == "help" ]]
then
  usage
  exit 1
fi

if [[ "$1" == "uninstall" && -z "$2" ]]
then
  usage
  exit 1
fi

if [[ "$1" == "install" && ( -z "$2" || -z "$3" ) ]]
then
  usage
  exit 1
fi

if [[ "$1" == "build" && -z "$2" ]]
then
  usage
  exit 1
fi

if [[ "$1" == "upload" && -z "$2" ]]
then
  usage
  exit 1
fi

declare VERSION=$2
declare VERSIONM=$(echo -n "$VERSION" | perl -nE 'say s/^(\d+\.\d+)[a-z]/$1/r')
declare DATE=$(date '+%Y/%m/%d')
declare ERRORS=0

if [[ "$1" == "uninstall" ]]
then
  \rm -f $2/biber/bltxml/biblatex/biblatex-examples.bltxml
  \rm -f $2/bibtex/bib/biblatex/biblatex-examples.bib
  \rm -f $2/bibtex/bst/biblatex/biblatex.bst
  \rm -f $2/doc/latex/biblatex/README
  \rm -f $2/doc/latex/biblatex/CHANGES.md
  \rm -f $2/doc/latex/biblatex/biblatex.pdf
  \rm -f $2/doc/latex/biblatex/biblatex.tex
  \rm -rf $2/doc/latex/biblatex/examples
  \rm -rf $2/tex/latex/biblatex
  exit 0
fi

if [[ "$1" == "upload" ]]
then
    if [[ -e obuild/biblatex-$VERSION.tds.tgz ]]
    then
      if [[ "$3" == "DEV" ]]
      then
        scp obuild/biblatex-"$VERSION".*tgz philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/development/
        scp doc/latex/biblatex/CHANGES.md philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/development/
      else
        scp obuild/biblatex-"$VERSION".*tgz philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/biblatex-"$VERSIONM"/
        scp doc/latex/biblatex/CHANGES.md philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/biblatex-"$VERSIONM"/
      fi
    exit 0
  fi
fi


if [[ "$1" == "builddist" || "$1" == "build" || "$1" == "install" ]]
then
  find . -name \*~ -print0 | xargs -0 rm >/dev/null 2>&1
  # tds
  [[ -e obuild/tds ]] || mkdir obuild/tds
  \rm -rf obuild/tds/*
  cp -r bibtex obuild/tds/
  cp -r biber obuild/tds/
  mkdir -p obuild/tds/doc/latex/biblatex
  cp doc/latex/biblatex/README obuild/tds/doc/latex/biblatex/
  cp doc/latex/biblatex/CHANGES.md obuild/tds/doc/latex/biblatex/
  cp doc/latex/biblatex/biblatex.pdf obuild/tds/doc/latex/biblatex/ 2>/dev/null
  cp doc/latex/biblatex/biblatex.tex obuild/tds/doc/latex/biblatex/
  cp -r doc/latex/biblatex/examples obuild/tds/doc/latex/biblatex/
  cp -r tex obuild/tds/
  cp obuild/tds/bibtex/bib/biblatex/biblatex-examples.bib obuild/tds/doc/latex/biblatex/examples/
  cp obuild/tds/biber/bltxml/biblatex/biblatex-examples.bltxml obuild/tds/doc/latex/biblatex/examples/
  
  # normal
  [[ -e obuild/flat ]] || mkdir obuild/flat
  \rm -rf obuild/flat/biblatex/*
  mkdir -p obuild/flat/biblatex/bibtex/{bib,bst}
  mkdir -p obuild/flat/biblatex/bibtex/bib/biblatex
  mkdir -p obuild/flat/biblatex/biber/bltxml
  mkdir -p obuild/flat/biblatex/doc/examples
  mkdir -p obuild/flat/biblatex/latex/{cbx,bbx,lbx}
  cp doc/latex/biblatex/README obuild/flat/biblatex/
  cp doc/latex/biblatex/CHANGES.md obuild/flat/biblatex/
  cp bibtex/bib/biblatex/biblatex-examples.bib obuild/flat/biblatex/bibtex/bib/biblatex/  
  cp bibtex/bib/biblatex/biblatex-examples.bib obuild/flat/biblatex/doc/examples/
  cp biber/bltxml/biblatex/biblatex-examples.bltxml obuild/flat/biblatex/biber/bltxml/
  cp biber/bltxml/biblatex/biblatex-examples.bltxml obuild/flat/biblatex/doc/examples/
  cp bibtex/bst/biblatex/biblatex.bst obuild/flat/biblatex/bibtex/bst/
  cp doc/latex/biblatex/biblatex.pdf obuild/flat/biblatex/doc/ 2>/dev/null
  cp doc/latex/biblatex/biblatex.tex obuild/flat/biblatex/doc/
  cp -r doc/latex/biblatex/examples obuild/flat/biblatex/doc/
  cp tex/latex/biblatex/*.def obuild/flat/biblatex/latex/
  cp tex/latex/biblatex/*.sty obuild/flat/biblatex/latex/
  cp tex/latex/biblatex/*.cfg obuild/flat/biblatex/latex/
  cp -r tex/latex/biblatex/cbx obuild/flat/biblatex/latex/
  cp -r tex/latex/biblatex/bbx obuild/flat/biblatex/latex/
  cp -r tex/latex/biblatex/lbx obuild/flat/biblatex/latex/

  perl -pi -e "s|\\\\abx\\@date\{[^\}]+\}|\\\\abx\\@date\{$DATE\}|;s|\\\\abx\\@version\{[^\}]+\}|\\\\abx\\@version\{$VERSION\}|;" obuild/tds/tex/latex/biblatex/biblatex.sty obuild/flat/biblatex/latex/biblatex.sty

  # Can't do in-place on windows (cygwin)
  find obuild/tds -name \*.bak -print0 | xargs -0 \rm -rf
  find obuild/tds -name auto -print0 | xargs -0 \rm -rf

  echo "Created build trees ..."
fi

if [[ "$1" == "install" ]]
then
  \cp -rf obuild/tds/* $3

  echo "Installed TDS build tree ..."
fi

if [[ "$1" == "builddocs" || "$1" == "build" ]]
then
  cd doc/latex/biblatex || exit

  perl -pi.bak -e 's|DATEMARKER|\\today|;' biblatex.tex

  lualatex --interaction=batchmode biblatex.tex
  lualatex --interaction=batchmode biblatex.tex
  lualatex --interaction=batchmode biblatex.tex

  \rm *.{aux,bbl,bcf,blg,log,run.xml,toc,out,lot} 2>/dev/null

  mv biblatex.tex.bak biblatex.tex

  cp biblatex.pdf ../../../obuild/tds/doc/
  cp biblatex.pdf ../../../obuild/flat/biblatex/doc/
  cd ../../.. || exit

  echo
  echo "Created main documentation ..."
fi

if [[ "$1" == "builddist" || "$1" == "build" ]]
then
  \rm -f obuild/biblatex-$VERSION.tds.tgz
  \rm -f obuild/biblatex-$VERSION.tgz
  tar zcf obuild/biblatex-$VERSION.tds.tgz -C obuild/tds bibtex biber doc tex
  tar zcf obuild/biblatex-$VERSION.tgz -C obuild/flat biblatex

  echo "Created packages (flat and TDS) ..."
fi

if [[ "$1" == "testbiber" || "$1" == "testbibtex" || "$1" == "test" ]]
then
  [[ -e obuild/test/examples ]] || mkdir -p obuild/test/examples
  \rm -rf obuild/test/examples/*
  cp -r doc/latex/biblatex/examples/*.tex obuild/test/examples/
  cp -r doc/latex/biblatex/examples/*.dbx obuild/test/examples/
  cp -r doc/latex/biblatex/examples/*.bib obuild/test/examples/
  \rm -f obuild/test/example_errs_biber.txt
  \rm -f obuild/test/example_errs_bibtex.txt
  cd obuild/test/examples || exit

  # Make the bibtex/biber backend test files
  for f in *.tex
  do
    if [[ "$f" < 9* ]] # 9+*.tex examples require biber
    then
      if [[ ! "$f" =~ -bibtex\.tex ]] # some files are already bibtex specific
      then
        mv $f ${f%.tex}-biber.tex
        if [[ ! -e ${f%.tex}-bibtex.tex ]] # don't overwrite already existing bibtex specific tests
        then
          sed -e 's/backend=biber/backend=bibtex/g' -e 's/\\usepackage\[utf8\]{inputenc}//g' ${f%.tex}-biber.tex > ${f%.tex}-bibtex.tex
        fi
      fi
    else
      mv $f ${f%.tex}-biber.tex
    fi
  done

  if [[ "$1" == "testbibtex" || "$1" == "test" ]]
  then
    for f in *-bibtex.tex
    do
      if [[ "$2" != "" && "$2" != "$f" ]]
      then
        continue
      fi
      bibtexflag=false
      echo -n "File (bibtex): $f ... "
      #exec 4>&1 7>&2 # save stdout/stderr
      #exec 1>/dev/null 2>&1 # redirect them from here
      # Twice due to two-pass @set handling in bibtex
      pdflatex --interaction=batchmode ${f%.tex}
      bibtex ${f%.tex}
      pdflatex --interaction=batchmode ${f%.tex}
      bibtex ${f%.tex}
      # Any refsections? If so, need extra bibtex runs
      for sec in ${f%.tex}*-blx.aux
      do
        bibtex $sec
      done
      pdflatex --interaction=batchmode ${f%.tex}
      # Need a second bibtex run to pick up set members
      if [[ $f == 20-indexing-* || $f == 21-indexing-* ]]
      then
        makeindex -o ${f%.tex}.ind ${f%.tex}.idx
        makeindex -o ${f%.tex}.nnd ${f%.tex}.ndx
        makeindex -o ${f%.tex}.tnd ${f%.tex}.tdx
      fi
      # This example uses sub-indexes
      if [[ $f == 22-indexing-* ]]
      then
          makeindex -o name-title.ind name-title.idx
          makeindex -o year-title.ind year-title.idx
      fi
      bibtex ${f%.tex}
      pdflatex --interaction=batchmode ${f%.tex}
      #exec 1>&4 4>&- # restore stdout
      #exec 7>&2 7>&- # restore stderr
      # Now look for latex/bibtex errors and report ...
      echo "==============================
Test file: $f

PDFLaTeX errors/warnings
------------------------"  >> ../example_errs_bibtex.txt
      # Use GNU grep to get PCREs as we want to ignore the legacy bibtex
      # warning in 3.4+
      grep -P '(?:[Ee]rror|[Ww]arning): (?!Using fall-back|prefixnumbers option|The option '\''labelprefix'\''|Empty biblist|Font shape|Command \\mark)' ${f%.tex}.log >> ../example_errs_bibtex.txt
      if [[ $? -eq 0 ]]; then bibtexflag=true; fi
      grep -E -A 3 '^!' ${f%.tex}.log >> ../example_errs_bibtex.txt
      if [[ $? -eq 0 ]]; then bibtexflag=true; fi
      echo >> ../example_errs_bibtex.txt
      echo "BibTeX errors/warnings" >> ../example_errs_bibtex.txt
      echo "---------------------" >> ../example_errs_bibtex.txt
      # Glob as we need to check all .blgs in case of refsections
      grep -i -e "(error|warning)[^\$]" ${f%.tex}*.blg >> ../example_errs_bibtex.txt
      if [[ $? -eq 0 ]]; then bibtexflag=true; fi
      echo "==============================" >> ../example_errs_bibtex.txt
      echo >> ../example_errs_bibtex.txt
      if $bibtexflag 
      then
          ERRORS=1
          echo -e "\033[0;31mERRORS\033[0m"
      else
        echo "OK"
      fi
    done
  fi

  if [[ "$1" == "testbiber" || "$1" == "test" ]]
  then
    for f in *-biber.tex
    do
      if [[ "$2" != "" && "$2" != "$f" ]]
      then
        continue
      fi

      biberflag=false      
      if [[ "$f" < 9* ]] # 9+*.tex examples require biber and we want UTF-8 support
      then
          declare TEXENGINE=pdflatex
          declare BIBEROPTS='--output_safechars --onlylog'
      else
          if [[ "$f" == "93-nameparts-biber.tex" ]] # Needs xelatex
          then
             declare TEXENGINE=xelatex
             declare BIBEROPTS='--onlylog'
          else
             declare TEXENGINE=lualatex
             declare BIBEROPTS='--onlylog'
          fi
      fi
      echo -n "File (biber): $f ... "
      #exec 4>&1 7>&2 # save stdout/stderr
      #exec 1>/dev/null 2>&1 # redirect them from here
      $TEXENGINE --interaction=batchmode ${f%.tex}
      # using output safechars as we are using fontenc and ascii in the test files
      # so that we can use the same test files with bibtex which only likes ascii
      # biber complains when outputting ascii from it's internal UTF-8
      biber $BIBEROPTS --onlylog ${f%.tex}
      $TEXENGINE --interaction=batchmode ${f%.tex}
      if [[ $f == 20-indexing-* || $f == 21-indexing-* ]]
      then
        makeindex -o ${f%.tex}.ind ${f%.tex}.idx
        makeindex -o ${f%.tex}.nnd ${f%.tex}.ndx
        makeindex -o ${f%.tex}.tnd ${f%.tex}.tdx
      fi
      # This example uses sub-indexes
      if [[ $f == 22-indexing-* ]]
      then
          makeindex -o name-title.ind name-title.idx
          makeindex -o year-title.ind year-title.idx
      fi
      $TEXENGINE --interaction=batchmode ${f%.tex}
      #exec 1>&4 4>&- # restore stdout
      #exec 7>&2 7>&- # restore stderr
  
      # Now look for latex/biber errors and report ...
      echo "==============================
Test file: $f

$TEXENGINE errors/warnings
------------------------"  >> ../example_errs_biber.txt
      grep -P '(?:[Ee]rror|[Ww]arning): (?!Using fall-back|prefixnumbers option|The option '\''labelprefix'\''|Empty biblist|Font shape|Command \\mark)' ${f%.tex}.log >> ../example_errs_biber.txt
      if [[ $? -eq 0 ]]; then biberflag=true; fi
      grep -E -A 3 '^!' ${f%.tex}.log >> ../example_errs_biber.txt
      if [[ $? -eq 0 ]]; then biberflag=true; fi
      echo >> ../example_errs_biber.txt
      echo "Biber errors/warnings" >> ../example_errs_biber.txt
      echo "---------------------" >> ../example_errs_biber.txt
      grep -i -e "(error|warn)" ${f%.tex}.blg >> ../example_errs_biber.txt
      if [[ $? -eq 0 ]]; then biberflag=true; fi
      echo "==============================" >> ../example_errs_biber.txt
      echo >> ../example_errs_biber.txt
      if $biberflag 
      then
          ERRORS=1
          echo -e "\033[0;31mERRORS\033[0m"
      else
        echo "OK"
      fi
    done
  fi
  cd ../../..
  exit $ERRORS
fi

if [[ "$1" == "testoutput" ]]
then
  for f in obuild/test/examples/*.pdf
  do
    echo -n "Checking `basename $f` ... "
    diff-pdf "doc/latex/biblatex/examples/`basename $f`" $f
    if [[ $? -eq 0 ]]
    then
      echo "PASS"
    else
        ERRORS=1
        echo -e "\033[0;31mFAIL\033[0m"
    fi
  done
  exit $ERRORS
fi
