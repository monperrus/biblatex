#!/usr/bin/env bash

usage () {
echo "Usage:

build.sh help
build.sh install <version> <tds_root>
build.sh build|buildall <version>
build.sh testbibtex|testbiber|test
build.sh upload <version> [ \"DEV\" ]

With the \"DEV\" argument, uploads to the SourceForge development
folder instead of the <version> numbered folder

Examples: 
obuild/build.sh install 2.2 ~/texmf/
obuild/build.sh build 2.2
obuild/build.sh upload 2.2 DEV

\"build test\" runs all of the example files (in a temp dir) and puts errors in a log:

obuild/example_errs_biber.txt
obuild/example_errs_bibtex.txt

You should run the \"build.sh install\" before test as it uses the installed biblatex and biber

"
}

if [[ ! -e obuild/build.sh ]]
then
  echo "Please run in the root of the distribution tree" 1>&2
  exit 1
fi

if [[ "$1" = "help" ]]
then
  usage
  exit 1
fi

if [[ "$1" = "install" && ( -z "$2" || -z "$3" ) ]]
then
  usage
  exit 1
fi

if [[ "$1" = "build" && -z "$2" ]]
then
  usage
  exit 1
fi

if [[ "$1" = "upload" && -z "$2" ]]
then
  usage
  exit 1
fi



declare VERSION=$2
declare VERSIONM=`echo -n "$VERSION" | perl -nE 'say s/^(\d+\.\d+)[a-z]/$1/r'`
declare DATE=`date '+%Y/%m/%d'`

if [[ "$1" = "upload" ]]
then
    if [[ -e obuild/biblatex-$VERSION.tds.tgz ]]
    then
      if [[ "$3" = "DEV" ]]
      then
        scp obuild/biblatex-$VERSION.*tgz philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/development/
        scp doc/latex/biblatex/CHANGES philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/development/
      else
        scp obuild/biblatex-$VERSION.*tgz philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/biblatex-$VERSIONM/
        scp doc/latex/biblatex/CHANGES philkime,biblatex@frs.sourceforge.net:/home/frs/project/biblatex/biblatex-$VERSIONM/
      fi
    exit 0
  fi
fi


if [[ "$1" = "build" || "$1" = "buildall" || "$1" = "install" ]]
then
  find . -name \*~ -print | xargs rm >/dev/null 2>&1
  # tds
  [[ -e obuild/tds ]] || mkdir obuild/tds
  \rm -rf obuild/tds/*
  cp -r bibtex obuild/tds/
  mkdir -p obuild/tds/doc/latex/biblatex
  cp doc/latex/biblatex/README obuild/tds/doc/latex/biblatex/
  cp doc/latex/biblatex/CHANGES obuild/tds/doc/latex/biblatex/
  cp doc/latex/biblatex/biblatex.pdf obuild/tds/doc/latex/biblatex/ 2>/dev/null
  cp doc/latex/biblatex/biblatex.tex obuild/tds/doc/latex/biblatex/
  cp -r doc/latex/biblatex/examples obuild/tds/doc/latex/biblatex/
  cp -r tex obuild/tds/
  cp obuild/tds/bibtex/bib/biblatex/biblatex-examples.bib obuild/tds/doc/latex/biblatex/examples/
  cp obuild/tds/bibtex/bltxml/biblatex/biblatex-examples.bltxml obuild/tds/doc/latex/biblatex/examples/
  
  # normal
  [[ -e obuild/flat ]] || mkdir obuild/flat
  \rm -rf obuild/flat/*
  mkdir -p obuild/flat/bibtex/{bib,bst,csf}
  mkdir -p obuild/flat/bibtex/bib/biblatex
  mkdir -p obuild/flat/doc/examples
  mkdir -p obuild/flat/latex/{cbx,bbx,lbx}
  cp doc/latex/biblatex/README obuild/flat/
  cp doc/latex/biblatex/CHANGES obuild/flat/
  cp bibtex/bib/biblatex/biblatex-examples.bib obuild/flat/bibtex/bib/biblatex/  
  cp bibtex/bib/biblatex/biblatex-examples.bib obuild/flat/doc/examples/
  cp bibtex/bltxml/biblatex/biblatex-examples.bltxml obuild/flat/bibtex/bib/biblatex/  
  cp bibtex/bltxml/biblatex/biblatex-examples.bltxml obuild/flat/doc/examples/
  cp bibtex/bst/biblatex/biblatex.bst obuild/flat/bibtex/bst/
  cp bibtex/csf/biblatex/*.csf obuild/flat/bibtex/csf/
  cp doc/latex/biblatex/biblatex.pdf obuild/flat/doc/ 2>/dev/null
  cp doc/latex/biblatex/biblatex.tex obuild/flat/doc/
  cp -r doc/latex/biblatex/examples obuild/flat/doc/
  cp tex/latex/biblatex/*.def obuild/flat/latex/
  cp tex/latex/biblatex/*.sty obuild/flat/latex/
  cp tex/latex/biblatex/*.cfg obuild/flat/latex/
  cp -r tex/latex/biblatex/cbx obuild/flat/latex/
  cp -r tex/latex/biblatex/bbx obuild/flat/latex/
  cp -r tex/latex/biblatex/lbx obuild/flat/latex/

  perl -pi -e "s|\\\\abx\\@date\{[^\}]+\}|\\\\abx\\@date\{$DATE\}|;s|\\\\abx\\@version\{[^\}]+\}|\\\\abx\\@version\{$VERSION\}|;" obuild/tds/tex/latex/biblatex/biblatex.sty obuild/flat/latex/biblatex.sty

  # Can't do in-place on windows (cygwin)
  find obuild/tds -name \*.bak | xargs \rm -rf
  find obuild/tds -name auto | xargs \rm -rf

  echo "Created build trees ..."
fi

if [[ "$1" = "install" ]]
then
  cp -r obuild/tds/* $3

  echo "Installed TDS build tree ..."
fi


if [[ "$1" = "build" || "$1" = "buildall" ]]
then
  if [[ "$1" = "build" ]]
  then    
    echo "NOT BUILDING DOCS"
  fi    

  if [[ "$1" = "buildall" ]]
  then
    cd doc/latex/biblatex

    perl -pi.bak -e 's|DATEMARKER|\\today|;' biblatex.tex

    lualatex -interaction=batchmode biblatex.tex
    lualatex -interaction=batchmode biblatex.tex
    lualatex -interaction=batchmode biblatex.tex

    \rm *.{aux,bbl,bcf,blg,log,run.xml,toc,out,lot} 2>/dev/null

    mv biblatex.tex.bak biblatex.tex

    cp biblatex.pdf ../../../obuild/tds/doc/
    cp biblatex.pdf ../../../obuild/flat/doc/
    cd ../../..

    echo "Created main documentation ..."
  fi

  \rm -f obuild/biblatex-$VERSION.tds.tgz
  \rm -f obuild/biblatex-$VERSION.tgz
  tar zcf obuild/biblatex-$VERSION.tds.tgz -C obuild/tds bibtex doc tex
  tar zcf obuild/biblatex-$VERSION.tgz -C obuild/flat README CHANGES bibtex doc latex

  echo "Created packages (flat and TDS) ..."

fi


if [[ "$1" = "testbiber" || "$1" = "testbibtex" || "$1" = "test" ]]
then
  [[ -e obuild/test/examples ]] || mkdir -p obuild/test/examples
  \rm -f obuild/test/example_errs_biber.txt
  \rm -f obuild/test/example_errs_bibtex.txt
  \rm -rf obuild/test/examples/*
  cp -r doc/latex/biblatex/examples/*.tex obuild/test/examples/
  cp -r doc/latex/biblatex/examples/*.dbx obuild/test/examples/
  cd obuild/test/examples

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

  if [[ "$1" = "testbibtex" || "$1" = "test" ]]
  then
    for f in *-bibtex.tex
    do
      bibtexflag=false
      echo -n "File (bibtex): $f ... "
      exec 4>&1 7>&2 # save stdout/stderr
      exec 1>/dev/null 2>&1 # redirect them from here
      pdflatex -interaction=batchmode ${f%.tex}
      bibtex ${f%.tex}
      # Any refsections? If so, need extra bibtex runs
      for sec in ${f%.tex}*-blx.aux
      do
        bibtex $sec
      done
      pdflatex -interaction=batchmode ${f%.tex}
      # Need a second bibtex run to pick up set members
      if [[ $f = *-indexing-* ]]
      then
        makeindex -o ${f%.tex}.ind ${f%.tex}.idx
        makeindex -o ${f%.tex}.nnd ${f%.tex}.ndx
        makeindex -o ${f%.tex}.tnd ${f%.tex}.tdx
      fi
      bibtex ${f%.tex}
      pdflatex -interaction=batchmode ${f%.tex}
      exec 1>&4 4>&- # restore stdout
      exec 7>&2 7>&- # restore stderr
      # Now look for latex/bibtex errors and report ...
      echo "==============================
Test file: $f

PDFLaTeX errors/warnings
------------------------"  >> ../example_errs_bibtex.txt
      grep -E -i "(error|warning):" ${f%.tex}.log >> ../example_errs_bibtex.txt
      if [[ $? -eq 0 ]]; then bibtexflag=true; fi
      grep -E -A 3 '^!' ${f%.tex}.log >> ../example_errs_bibtex.txt
      if [[ $? -eq 0 ]]; then bibtexflag=true; fi
      echo >> ../example_errs_bibtex.txt
      echo "BibTeX errors/warnings" >> ../example_errs_bibtex.txt
      echo "---------------------" >> ../example_errs_bibtex.txt
      # Glob as we need to check all .blgs in case of refsections
      grep -E -i -e "(error|warning)[^\$]" ${f%.tex}*.blg >> ../example_errs_bibtex.txt
      if [[ $? -eq 0 ]]; then bibtexflag=true; fi
      echo "==============================" >> ../example_errs_bibtex.txt
      echo >> ../example_errs_bibtex.txt
      if $bibtexflag 
      then
        echo "ERRORS"
      else
        echo "OK"
      fi
    done
  fi

  if [[ "$1" = "testbiber" || "$1" = "test" ]]
  then
    for f in *-biber.tex
    do
      biberflag=false      
      if [[ "$f" < 9* ]] # 9+*.tex examples require biber and we want UTF-8 support
      then
          declare TEXENGINE=pdflatex
          declare BIBEROPTS='--output_safechars --onlylog'
      else
          declare TEXENGINE=lualatex
          declare BIBEROPTS='--onlylog'
      fi
      echo -n "File (biber): $f ... "
      exec 4>&1 7>&2 # save stdout/stderr
      exec 1>/dev/null 2>&1 # redirect them from here
      $TEXENGINE -interaction=batchmode ${f%.tex}
      # using output safechars as we are using fontenc and ascii in the test files
      # so that we can use the same test files with bibtex which only likes ascii
      # biber complains when outputting ascii from it's internal UTF-8
      biber $BIBEROPTS --onlylog ${f%.tex}
      $TEXENGINE -interaction=batchmode ${f%.tex}
      if [[ $f = *-indexing-* ]]
      then
        makeindex -o ${f%.tex}.ind ${f%.tex}.idx
        makeindex -o ${f%.tex}.nnd ${f%.tex}.ndx
        makeindex -o ${f%.tex}.tnd ${f%.tex}.tdx
      fi
      $TEXENGINE -interaction=batchmode ${f%.tex}
      exec 1>&4 4>&- # restore stdout
      exec 7>&2 7>&- # restore stderr
  
      # Now look for latex/biber errors and report ...
      echo "==============================
Test file: $f

PDFLaTeX errors/warnings
------------------------"  >> ../example_errs_biber.txt
      grep -E -i "(error|warning):" ${f%.tex}.log >> ../example_errs_biber.txt
      if [[ $? -eq 0 ]]; then biberflag=true; fi
      grep -E -A 3 '^!' ${f%.tex}.log >> ../example_errs_biber.txt
      if [[ $? -eq 0 ]]; then biberflag=true; fi
      echo >> ../example_errs_biber.txt
      echo "Biber errors/warnings" >> ../example_errs_biber.txt
      echo "---------------------" >> ../example_errs_biber.txt
      grep -E -i "(error|warn)" ${f%.tex}.blg >> ../example_errs_biber.txt
      if [[ $? -eq 0 ]]; then biberflag=true; fi
      echo "==============================" >> ../example_errs_biber.txt
      echo >> ../example_errs_biber.txt
      if $biberflag 
      then
        echo "ERRORS"
      else
        echo "OK"
      fi
    done
  fi
  cd ../../..
fi
