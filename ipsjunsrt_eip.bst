% ipsjunsrt_eip.bst 10-Dec-25 by Seiichi Igaya (ver 0.01)
% based on ipsjunsrt.bst 28-Oct-10 by Hiroshi Nakashima (ver 3.00)
% BibTeX standard bibliography style `jplain'
	% version 0.10 for JBibTeX versions 0.10 or later, JLaTeX version 2.09.
	% by Shouichi Matsui, matsui@denken.junet

  ENTRY
  { abstract
    address
    author
    booktitle
    chapter
    date
    doi							% 3.00(1)
    edition
    editor
    entrysubtype
    howpublished
    institution
    journal
    journaltitle
    key
    langid						% Language identifier for name formatting
    month
    note
    number
    organization
    pages
    publisher
    refdate		
    rights% 3.00(1)
    school
    series
    shorttitle
    title
    type
    url
    urldate% 3.00(1)
    volume
    year
    yomi
  }
  {}
  { label }

INTEGERS { output.state before.all mid.sentence after.sentence after.block }

INTEGERS { before.year }

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
  #4 'before.year :=					% 1.00(1)
}

STRINGS { s t }

FUNCTION {is.kanji}
{ is.kanji.str$ }					% 1.00(2), 2.00(1)

FUNCTION {is.kanji.title}				% 3.00(1)
{ title is.kanji.str$ }

FUNCTION {is.japanese}
{ langid empty$
    { #0 }
    { langid "japanese" =
        { #1 }
        { #0 }
      if$
    }
  if$
}


FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { duplicate$ is.kanji				% 2.00(2)
	{ "，" * write$ }
	{ ", " * write$ }
      if$
    }
    { output.state after.block =
	{ add.period$ write$
	  newline$
	  "\newblock " write$
	}
	{ output.state before.all =
	    'write$
	    { output.state before.year =		% 1.00(1)
		{ " " * write$ }
		{ add.period$ " " * write$ }
	      if$
	    }
	  if$
	}
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {required.argument}
{ 't :=
  empty$
    {"Missing required argument " t * " in " * cite$ * warning$}
    'skip$
  if$
}

FUNCTION {required.exclusive.or.argument}
{ 't :=
  empty$
    { 's := 
      empty$
        { t " or " * s * " is missing in " * cite$ * warning$}
        'skip$
      if$
    }
    { 's :=
      empty$
        'skip$
        { "You can use only one of " t * " and " * s * " in " * cite$ * warning$}
      if$
    }
  if$
}

FUNCTION {required.and.or.argument}
{ 't := empty$
     { 's := empty$
         { "there's no " t * " and/or " * s * cite$ * warning$ }
         'skip$
       if$
     }
     { pop$ pop$ }
  if$
}

FUNCTION {optional.series.volume.number.argument}
{ series empty$
    { volume empty$
        { number empty$
            'skip$
            { "there's a number but no series in " cite$ * warning$ }
          if$
        }
        { number empty$
            { "there's a volume but no series in " cite$ * warning$ }
            { "you can use only one of volume and number in " cite$ * warning$}
          if$
        }
     if$
    }
    { volume empty$
        { number empty$
            { "there's a series but neither volume nor number in " cite$ * warning$ }
            'skip$
          if$
        }
        { number empty$
            'skip$
            { "you can use only one of volume and number in " cite$ * warning$ }
          if$
        }
     if$
   }
   if$
}            

FUNCTION {output.bibitem}
{ newline$
  "\bibitem{" write$
  cite$ write$
  "}" write$
  newline$
  before.all 'output.state :=
}

FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
	'skip$
	{ after.sentence 'output.state := }
      if$
    }
  if$
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { duplicate$ is.kanji
        'skip$						% 1.00(3)
        { "{\em " swap$ * "}" * }			% 2.00(3)
      if$
    }
  if$
}

INTEGERS { nameptr namesleft numnames }

FUNCTION {format.names}					% 1.00(4), 2.00(4)
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{ll} {ff}" format.name$ duplicate$ is.kanji
	{ duplicate$ text.length$ #6 >
	    { 't := }
	    { pop$ s nameptr "{ll}{ff}" format.name$ 't := }
	  if$
	}
        { pop$ is.japanese
            { s nameptr "{ll}{ ff}" format.name$ 't := }
            { s nameptr "{ll}{ vv }{ f}{, jj}" format.name$ 't := }
          if$
        }
      if$
      nameptr #1 >
	{ namesleft #1 >
	    { s is.kanji
		{ "，" }
		{ ", " }
	      if$
	      * t * }
	    { t "others" =
		{ s is.kanji
			{"ほか" * }
			{" et al." * }
		      if$
                }
		{ s is.kanji
			{"，" * t * }	% put "," here for Kanji (H.N.)
			{" and " * t * }
	     	      if$
		}
	      if$
	    }
	  if$
	}
	't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.names }
  if$
}

FUNCTION {add.colon}					% 2.00(5)
{ duplicate$ is.kanji
    { "\：" * }						% 2.12(1)
    { ": " * }
  if$
}

FUNCTION {format.editors.inparen}			% 2.00(6)
{ editor empty$
    { "" }
    { editor format.names
      editor num.names$ #1 >
	{ editor is.kanji
		{" 編" * } {", eds." *} if$
	}
	{ editor is.kanji
		{" 編" *}  {", ed." *} if$
	}
      if$
    }
  if$
}

FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.names
      editor num.names$ #1 >
	{ editor is.kanji
		{"（編）" * } {"(eds.)" *} if$		% 2.00(7)
	}
	{ editor is.kanji
		{"（編）" *}  {"(ed.)" *} if$		% 2.00(7)
	}
      if$
    }
  if$
}

FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
	{ t #1 #2 substring$ "--" = not
	    { "--" *
	      t #2 global.max$ substring$ 't :=
	    }
	    {   { t #1 #1 substring$ "-" = }
		{ "-" *
		  t #2 global.max$ substring$ 't :=
		}
	      while$
	    }
	  if$
	}
	{ t #1 #1 substring$ *
	  t #2 global.max$ substring$ 't :=
	}
      if$
    }
  while$
}

FUNCTION {format.date}
{ before.year 'output.state :=				% 1.00(1)
  year empty$
    { month empty$
	{ "" }
	{ "there's a month but no year in " cite$ * warning$
          ""						% 1.00(5)
	}
      if$
    }
    { "(" year ")" * * }				% 1.00(5)
  if$
}

FUNCTION {format.isodate}
{ before.year 'output.state :=
  date empty$
    { "" }
    { "(" date #1 #4 substring$ ")" * * }
  if$
}


FUNCTION {format.ref.date}				% 3.00(1)>>
{ before.year 'output.state :=
  is.kanji.title
    % { "\refdatej{" refdate "}" * *}
    % { "\refdatee{" refdate "}" * *}
    { "\refdatej{" urldate "}" * *}
    { "\refdatee{" urldate "}" * *}
  if$
}							% 3.00(1)<<

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { "\ " }						% 1.00(6)
  if$
  swap$ * *
}

FUNCTION {output.volume}
{ 
  volume empty$
    'skip$
    { "Vol.~" volume * output}
  if$

}

FUNCTION {output.number}
{
  number empty$
    'skip$
    { "No.~" number * output}
  if$
}

FUNCTION {output.series.volume.number}
{ series empty$
    { output.volume
      output.number }
    { series is.kanji
      volume empty$
      number empty$
      or
      and
        { series " " * volume * number * output}
        { series output
          output.volume
          output.number}
      if$
   }
 if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    { output.state mid.sentence =
	{ edition "l" change.case$ " edition" * }
	{ edition "t" change.case$ " edition" * }
      if$
    }
  if$
}

INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
	{ #1 'multiresult := }
	{ t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}

FUNCTION {format.online}				% 3.00(1)>>
{ is.kanji.title
    { "（オンライン）" * }
    { duplicate$ empty$
        { "(online)" * }
        { " (online)" * }
      if$
    }
  if$
}							% 3.00(1)<<

FUNCTION {format.url}					% 3.00(1)>>
{ is.kanji.title
    { "\url{" url "}" * * }
    { "\url{" url "}" * * }
  if$
}							% 3.00(1)<<

FUNCTION {format.pages}					% 1.00(7)
{ pages empty$
    { "" }
    { pages multi.page.check
	{ "pp." pages n.dashify tie.or.space.connect }
	{ "p." pages tie.or.space.connect }
      if$
    }
  if$
}

FUNCTION {format.doi.url}				% 3.00(1)>>
{ doi empty$
    { url empty$
	'skip$
	{ %format.online output.nonnull
	   format.url
      {"\url{" url "}" * *}
	}
	if$
    }
    { %format.online output.nonnull
      "\doi{\url{" doi "}}" * *
    }
  if$							% 3.00(1)<<
}

FUNCTION {format.pages.output}				% 3.00(1)>>
{ format.pages
  format.doi.url output					% 3.00(1)<<
}

FUNCTION {format.vol.num.pages}				% 1.00(8)
{ volume empty$
  { ""}
  { " Vol.~" volume * }
  if$ 
  number empty$
    'skip$
    { volume empty$
	{ "there's a number but no volume in " cite$ * warning$ }
	{ "," *}
      if$
      " No.~" number * *
    }
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
	{ pop$ format.pages }
	{ ", " * format.pages * }
      if$
    }
  if$
  format.doi.url					% 3.00(1)
}

FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
	{ "chapter" chapter tie.or.space.connect }
        { type is.kanji 
             { chapter type tie.or.space.connect }
             { type "l" change.case$ chapter tie.or.space.connect }
          if$
        }
      if$
      pages empty$
	'skip$
	{ ", " * format.pages * }
      if$
    }
  if$
  format.doi.url					% 3.00(1)
}

FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { booktitle emphasize
      editor empty$
	'skip$
	{ booktitle is.kanji
	    { "（" * format.editors.inparen * "）" *}	% 2.00(6,7)
	    { " (" * format.editors.inparen * ")" *}	% 1.00(9), 2.00(6)
	  if$
	}
      if$
    }
  if$
}

FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}

FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}

FUNCTION {format.tr.number}
{ type empty$
    { title empty$
        { "Technical Report" }
        { title is.kanji
            { "技術報告" }
            { "Technical Report" }
          if$
        }
      if$
    }
    {type}
  if$
  number empty$
    { "t" change.case$ }
    { " " number * * }
  if$
}

FUNCTION {format.article.crossref}			% 2.00(8)
{ key empty$
    { journal empty$
	{ "need key or journal for " cite$ * " to crossref " * crossref *
	  warning$
	  ""
	}
	{ journal emphasize }				% 1.00(10)
      if$
    }
    { "In " key * }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {format.crossref.editor}			% 1.00(11)
{ editor #1
  editor is.kanji 
    { "{ff}" }
    { is.japanese
        { "{ll}{ ff}" }
        { "{vv }{ll}" }
      if$
    }
  if$
  format.name$
  editor num.names$ duplicate$
  #2 >
    { editor is.kanji
	  {pop$ "ほか" *} {pop$ " et al." * } if$
    }
    { #2 <
	'skip$
	{ editor #2 "{ff }{vv }{ll}{ jj}" format.name$ "others" =
	    { editor is.kanji
		{"ほか" *} {" et al." * } if$
	    }
	    { editor is.kanji
		{"・" * editor #2 "{ff}" format.name$ * }
		{ is.japanese
		    { " and " * editor #2 "{ll}{ ff}" format.name$ * }
		    { " and " * editor #2 "{vv }{ll}" format.name$ * }
		  if$
		}
	      if$
	    }
	  if$
	}
      if$
    }
  if$
}

FUNCTION {format.book.crossref}				% 2.00(8)
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
	{ series empty$
	    { "need editor, key, or series for " cite$ * " to crossref " *
	      crossref * warning$
	      ""
	    }
	    { series emphasize }			% 1.00(10)
	  if$
	}
	{ "In " key * }
      if$
    }
    { format.crossref.editor }
  if$
  " \cite{" * crossref * "}" *
  volume empty$
    { "empty volume in " cite$ * "'s crossref of " * crossref * warning$ }
    { duplicate$ is.kanji { "，" } { ", "} if$ *
      "Vol." * volume tie.or.space.connect
    }
  if$
}

FUNCTION {format.incoll.inproc.crossref}		% 2.00(8)
{ editor empty$
  editor field.or.null author field.or.null =
  or
    { key empty$
	{ booktitle empty$
	    { "need editor, key, or booktitle for " cite$ * " to crossref " *
	      crossref * warning$
	      ""
	    }
	    { booktitle emphasize }			% 1.00(10)
	  if$
	}
	{ "In " key * }
      if$
    }
    { format.crossref.editor }
  if$
  " \cite{" * crossref * "}" *
}

FUNCTION {article}
{ 
%%%%
  author  "author"  required.argument
  title   "title"   required.argument
  journal "journaltitle" required.argument
  year    "year"
  date      "date"
%%%% jssst
  volume  "volume"  
  number  "number"  
     required.and.or.argument
  pages   "pages"   required.argument
%%%%
  output.bibitem 
  format.authors add.colon				% 2.00(5)
  title output
  crossref missing$
    { journaltitle emphasize output
      format.vol.num.pages output			% 1.00(12)
      format.isodate output
    }
    { format.article.crossref output.nonnull
      format.pages.output				% 3.00(1)
      format.isodate output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {book}
{ 
%%%%
  author  "author"
  editor  "editor"
    required.exclusive.or.argument
  title   "title"  required.argument
  publisher "publisher" required.argument
  % year    "year" required.argument
  date    "date" required.argument
  optional.series.volume.number.argument
%%%%
  output.bibitem
  author empty$
    { format.editors}
    { format.authors}
  if$
  add.colon						% 2.00(5)
  title emphasize output
  % crossref missing$
  %   { output.series.volume.number
  %     publisher output
  %     address output
  %   }
  %   { new.block
  %     format.book.crossref output.nonnull
  %   }
  % if$
  publisher output
  format.edition output
  format.isodate output
  new.block
  note output
  fin.entry
}

FUNCTION {booklet}
{
%%%%
  title   "title"   required.argument
%%%% jssst
  author  "author"  required.argument
%%%%
  output.bibitem
  format.authors add.colon				% 2.00(5)
  title output
  howpublished output
  address output
  format.date output
  new.block
  note output
  fin.entry
}


FUNCTION {conference} { inproceedings }


FUNCTION {inbook}
{ 
%%%%
  author  "author"
  editor  "editor"
     required.exclusive.or.argument
  title   "title"  required.argument
  chapter "chapter"
  pages   "pages"
     required.and.or.argument
  publisher  "publisher" required.argument
  date      "date" required.argument
  optional.series.volume.number.argument
%%%%
  output.bibitem 
  author empty$
    { format.editors}
    { format.authors}
  if$
  add.colon						% 2.00(5)
  title emphasize output
  crossref missing$
    { output.series.volume.number
      format.chapter.pages output
      publisher output
    }
    { format.chapter.pages output
      new.block
      format.book.crossref output.nonnull
    }
  if$
  format.edition output
  format.date output					% 1.00(13)
  new.block
  note output
  fin.entry
}

FUNCTION {incollection}
{
%%%%
  author    "author"    required.argument
  title     "title"     required.argument
  booktitle "booktitle" required.argument
  publisher "publisher" required.argument
  date      "date"      required.argument

  optional.series.volume.number.argument
%%%%
  output.bibitem
  format.authors add.colon				% 2.00(5)
  title output
  crossref missing$
    { format.in.ed.booktitle output
      output.series.volume.number
      publisher output
      address output
      format.edition output
      format.isodate output
      format.chapter.pages output			% 1.00(13)
    }
    { format.incoll.inproc.crossref output.nonnull
      format.chapter.pages output
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {inproceedings}
{
%%%%
  author    "author"    required.argument
  title     "title"     required.argument
  year      "year"      
  date      "date"

  optional.series.volume.number.argument
%%%%
  output.bibitem 
  format.authors add.colon				% 2.00(5)
  title output
  crossref missing$
    { format.in.ed.booktitle output
      booktitle "booktitle" required.argument
      output.series.volume.number
      address output
      organization output
      publisher output
      format.pages.output				% 3.00(1)
      format.isodate output				% 1.00(13)
    }
    { format.incoll.inproc.crossref output.nonnull
      format.pages.output				% 3.00(1)
    }
  if$
  new.block
  note output
  fin.entry
}

FUNCTION {is.case}
{ abstract empty$
    {#0}
    { abstract "case" = 
        {#1}
        {#0}
        if$
    }
    if$
}

FUNCTION {is.jlaw}
{abstrac empty$
    {#0}
    { abstract "Jlaw" = 
        {#1}
        {#0}
        if$
    }
    if$
}


FUNCTION {jurisdiction.japan.case.report} {
    journaltitle empty$
        { url empty$
            { "公刊物未登載（" * number * "）" * }
            { "裁判所等ウェブページ参照（" * number * "）" * }
        if$}
        { volume empty$
            { " （" * journaltitle * pages * "）" * }
            { " " * journaltitle * volume * "号" * pages * "頁" * }
            if$
        }
    if$
}

FUNCTION {case.name} {
    shorttitle empty$
        'skip$
        { "（" * shorttitle * "）" * }
        if$
}

FUNCTION {format.case.number}
{
    number empty$
        'skip$
        { ", 事件番号: " * number * }
        if$
}

FUNCTION {format.case.pages}
{
    pages empty$
        'skip$
        { ", " * pages * }
        if$
}

FUNCTION {jurisdiction.case.japan} {
    title "title" required.argument
    shorttitle "shorttitle" required.argument
%%%%
    output.bibitem
    title output
    jurisdiction.japan.case.report output
    case.name output
    new.block
    note.output
    fin.entry
}


FUNCTION {jurisdiction.case.cjeu}
{
    institution "institution" required.argument
    title   "title"     required.argument
    number  "number"    required.argument
    pages   "pages"     required.argument
    date    "date"      required.argument
%%%%
    output.bibitem
    institution output
    number output
    title output
    format.isodate output
    pages output
    case.name output
    new.block
    note.output
    fin.entry
}

FUNCTION {jurisdiction.case.default}
{
    institution "institution" required.argument
    title   "title"     required.argument
    pages   "pages"     required.argument
    date    "date"      required.argument
%%%%
    output.bibitem
    institution output
    title output
    format.case.number output
    format.case.pages output
    case.name output
    new.block
    note.output
    fin.entry
}

FUNCTION {jurisdiction.parliament.japan}
{
    title   "title"     required.argument
    date    "date"      required.argument
%%%%
    output.bibitem
    title output
    format.isodate output
    new.block
    note.output
    fin.entry
}

FUNCTION {jurisdiction.parliament.default}
{
    title   "title"     required.argument
    date    "date"      required.argument
%%%%
    output.bibitem
    title output
    format.isodate output
    new.block
    note.output
    fin.entry
}

FUNCTION {jurisdiction.default}
{
    title   "title"     required.argument
    institution "institution" required.argument
%%%%
    output.bibitem
    institution output
    title output
    format.isodate output
    format.case.number output
    format.case.pages output
    case.name output
    new.block
    note.output
    fin.entry
}

FUNCTION {switch.case} {
    entrysubtype "Jcase" =
        { jurisdiction.case.japan }
        { entrysubtype "CJEUcase" = 
            { jurisdiction.case.cjeu }
            { jurisdiction.case.default}
            if$
        }
        if$
}

FUNCTION {switch.parliament} {
    entrysubtype "Japan" = 
        { jurisdiction.parliament.japan }
        { jurisdiction.parliament.default}
        if$
}


FUNCTION {switch.jurisdiction} {
    type "case" = 
        { switch.case }
        { type "parliament" =
            { switch.parliament }
            { jurisdiction.default}
            if$
        }
    if$
}



FUNCTION {jurisdiction} {
    switch.jurisdiction
}


FUNCTION {format.legislation.number}
{ number empty$
    'skip$
    { "（" * number * "）" * }
    if$
}

FUNCTION {legislation.japan} {
    title   "title" required.argument
    date    "date"  required.argument
%%%%
    output.bibitem
    title output
    format.legislation.number
    new.block
    note.output
    fin.entry
}

FUNCTION {OJ.entry}
{
    number empty$
    'skip$
    { ", OJ " * format.isodate * " " * number * "/" pages *}
    if$
}

FUNCTION {legislation.eu}
{
    title "title" required.argument
    number "number" required.argument
    date "date" required.argument
    pages "pages" required.argument
%%%%
    output.bibitem
    title output
    OJ.entry output
    new.block
    note.output
    fin.entry
}

FUNCTION {US.entry}
{
    ", " * number * " " * journaltitle * " " * format.isodate *
}

FUNCTION {legislation.usc}
{
    title "title" required.argument
    % journaltitle "journaltitle" required.argument
    % journal "journal" required.argument
    number "number" required.argument
    date "date" required.argument
%%%%
    output.bibitem
    title output
    US.entry output
    new.block
    note.output
    fin.entry
}

FUNCTION {us.state.entry}
{
    ", " * journaltitle * " \S " * pages * " et seq" *
}

FUNCTION {legislation.usstate}
{
    title "title" required.argument
%%%%
    output.bibitem
    title output
    us.state.entry output
    new.block
    note.output
    fin.entry
}

FUNCTION {legislation.default}
{
    title "title" required.argument
    number "number" required.argument
%%%%
    output.bibitem
    title output
    number output
    new.block
    note.output
    fin.entry
}

FUNCTION {switch.legislation}
{
    entrysubtype empty$
    { legislation.default }
    { entrysubtype "Jlaw" = 
        {legislation.japan}
        { entrysubtype "EUlaw" =
            {legislation.eu}
            { entrysubtype "USlaw" =
                {legislation.usc}
                { entrysubtype "USstatelaw" = 
                    {legislation.usstate}
                    {legislation.default}
                    if$
                }
                if$
            }
            if$
        }
        if$
    }
    if$
}

FUNCTION {legislation} {
    switch.legislation
}


FUNCTION {manual}
{	
%%%%
  title   "title"    required.argument
%%%% jssst
  author   "author"
  organization "organazaion"
     required.exclusive.or.argument
%%%%
  output.bibitem
  author empty$
    { organization}
    { format.authors}
  if$
  add.colon						% 2.00(5)
  title emphasize output
  author empty$
    'skip$
    { organization output }
  if$
  address output
  format.edition output
  format.date output
  new.block
  note output
  fin.entry
}

FUNCTION {mastersthesis}
{
%%%%
  author   "author"  required.argument
  title    "title"   required.argument
  school   "school"  required.argument
  year     "year"    required.argument
%%%%
  output.bibitem
  format.authors add.colon				% 2.00(5)
  title output
  author empty$
    { "Master's thesis" }
    { author is.kanji
        { "修士論文" }  
        { "Master's thesis" }
      if$
    }
  if$
  format.thesis.type output.nonnull
  school output
  address output
  format.date output
  new.block
  note output
  fin.entry
}

FUNCTION {misc}
{
%%%%
%%%% jssst
  author "author"
  title  "title"  required.argument
%%%%
  output.bibitem
  format.authors				% 2.00(5)
  title output
  howpublished output
  format.isodate output
  new.block
  note output
  fin.entry
  empty.misc.check
}


FUNCTION {online}					% 3.00(1)>>
{
%%%%
  author       "author"       required.argument
  title        "title"        required.argument
  url          "url"          required.argument
  date          "date"
  refdate      "refdate"      required.argument
%%%%
  output.bibitem
  author empty$
    { format.authors }
    { format.authors add.colon }
  if$
  title output
  format.isodate output
  format.url output
  format.ref.date output
  % new.block
  note output
  fin.entry
}	

FUNCTION {phdthesis}
{
%%%%
  author   "author"  required.argument
  title    "title"   required.argument
  school   "school"  required.argument
  year     "year"    required.argument
%%%%
  output.bibitem 
  format.authors add.colon				% 2.00(5)
  title output						% 2.00(9)
  author empty$
    { "PhD Thesis" }
    { author is.kanji
        { "博士論文" }
        { "PhD Thesis" }
      if$
    }
  if$
  format.thesis.type output.nonnull
  school output
  address output
  format.date output
  new.block
  note output
  fin.entry
}

FUNCTION {proceedings}
{
%%%%
  title  "title"  required.argument
  year   "year"   required.argument

  optional.series.volume.number.argument
%%%% jssst
  editor  "editor"
  organization "organization"
      required.exclusive.or.argument 
%%%%
  output.bibitem 
  editor empty$
    { organization }
    { format.editors }
  if$
  add.colon						% 2.00(5)
  title emphasize output
  output.series.volume.number
  address output
  editor empty$
    'skip$
    { organization output }
  if$
  publisher output
  format.date output
  new.block
  note output
  fin.entry
}

FUNCTION {techreport}
{
%%%%
  author   "author"   required.argument
  title    "title"    required.argument
  institution "institution" required.argument
  year     "year"     required.argument
%%%%
  output.bibitem
  format.authors add.colon				% 2.00(5)
  title output
  format.tr.number output.nonnull
  institution output
  address output
  format.date output
  new.block
  note output
  fin.entry
}

FUNCTION {unpublished}
{
%%%%
  author   "author"   required.argument
  title    "title"    required.argument
  note     "note"     required.argument
%%%%
  output.bibitem
  format.authors add.colon				% 2.00(5)
  title output
  format.date output
  new.block
  note output
  fin.entry
}


FUNCTION {webpage}					% 3.00(1)>>
{
%%%%
  author       "author"       required.argument
  title        "title"        required.argument
  url          "url"          required.argument
  refdate      "refdate"      required.argument
%%%%
  output.bibitem
  format.authors add.colon
  title output
  organization format.doi.url output
  format.ref.date output
  new.block
  note output
  fin.entry
}	

FUNCTION {default.type} { misc }

MACRO {jan} {"January"}

MACRO {feb} {"February"}

MACRO {mar} {"March"}

MACRO {apr} {"April"}

MACRO {may} {"May"}

MACRO {jun} {"June"}

MACRO {jul} {"July"}

MACRO {aug} {"August"}

MACRO {sep} {"September"}

MACRO {oct} {"October"}

MACRO {nov} {"November"}

MACRO {dec} {"December"}

MACRO {acmcs} {"ACM Computing Surveys"}

MACRO {acta} {"Acta Informatica"}

MACRO {cacm} {"Communications of the ACM"}

MACRO {ibmjrd} {"IBM Journal of Research and Development"}

MACRO {ibmsj} {"IBM Systems Journal"}

MACRO {ieeese} {"IEEE Transactions on Software Engineering"}

MACRO {ieeetc} {"IEEE Transactions on Computers"}

MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}

MACRO {ipl} {"Information Processing Letters"}

MACRO {jacm} {"Journal of the ACM"}

MACRO {jcss} {"Journal of Computer and System Sciences"}

MACRO {scp} {"Science of Computer Programming"}

MACRO {sicomp} {"SIAM Journal on Computing"}

MACRO {tocs} {"ACM Transactions on Computer Systems"}

MACRO {tods} {"ACM Transactions on Database Systems"}

MACRO {tog} {"ACM Transactions on Graphics"}

MACRO {toms} {"ACM Transactions on Mathematical Software"}

MACRO {toois} {"ACM Transactions on Office Information Systems"}

MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}

MACRO {tcs} {"Theoretical Computer Science"}

READ

STRINGS { longest.label }

INTEGERS { number.label longest.label.width }

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #1 'number.label :=
  #0 'longest.label.width :=
}

FUNCTION {longest.label.pass}
{ number.label int.to.str$ 'label :=
  number.label #1 + 'number.label :=
  label width$ longest.label.width >
    { label 'longest.label :=
      label width$ 'longest.label.width :=
    }
    'skip$
  if$
}

EXECUTE {initialize.longest.label}

ITERATE {longest.label.pass}

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{"  longest.label  * "}" * write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}


