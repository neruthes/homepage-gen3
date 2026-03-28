#import "/.data/articles/vol002typ/vol2sty.H.typ": *

#show: docinit.with(is_single: false)


// Cover page
#page[
  #set align(center)
  #set text(font: __fonts_fancy)
  #v(90pt)
  #box(image("/wwwsrc/neruthes-forceCircle-unpadded.png", width: 28mm))
  #v(50pt)
  #set text(size: 22pt)
  #scale(reflow: true, y: 130%)[
    NERUTHES \
    ARTICLES \
    COLLECTION \
    VOLUME 2
  ]
]


#let articles_list = read("/.data/articles/vol002typ/.alist.txt").trim().split("\n")


#let state__page_heap_ptr = state("state__page_heap_ptr", 2)
#let add_article(path) = {
  import "/.data/articles/vol002typ/" + path as article_obj
  make_single_in_vol(
    article_obj.date,
    article_obj.title,
    article_obj.main,
  )
}
#let render_toc_entry(path) = {
  import "/.data/articles/vol002typ/" + path as article_obj
  let pages = article_obj.pages
  state__page_heap_ptr.update(it => it + pages)
  set text(size: 10 * kp)
  context block(spacing: 0mm, grid(
    columns: (8fr, 1fr),
    gutter: 0mm,
    align: (left, right),
    [#article_obj.title], text(font: __fonts_mono1)[#state__page_heap_ptr.get()],
  ))
  linebreak()
}



// =============================================
// TOC
// =============================================
#style__article_title[Table of Contents]
#articles_list.map(render_toc_entry).join()
#pagebreak()




// =============================================
// Articles body
// =============================================
#enable_header_footer()
#articles_list.map(add_article).join(pagebreak(weak: true))





#pagebreak(weak: false)
#v(1fr)
#[
  #set text(size: 9 * kp, font: __fonts_sans, number-width: "tabular")
  Copyright #sym.copyright; 2022-2026 Neruthes. All rights reserved.

  This collection of articles is part of the blog of Neruthes.

  This document may be found online at these locations: \
  #link("https://neruthes.xyz/articles/Neruthes_articles_vol002.pdf")[neruthes.xyz]
  ~/~
  #link("https://neruthes.pages.dev/articles/Neruthes_articles_vol002.pdf")[neruthes.pages.dev]
  ~/~
  #link("https://neruthes.vercel.app/articles/Neruthes_articles_vol002.pdf")[neruthes.vercel.app]
]





// Migration script; no longer needed; remove later
#if false {
  ```sh
    find .data/articles/vol002 -name '202*.TEX' | sort -u | while read -r oldfile; do
      atom="$(cut -d/ -f4- <<< "$oldfile" | cut -d. -f1)"
      newfile=".data/articles/vol002typ/$atom.TYP"
      #echo "fn = $newfile"
      if [[ -e "$newfile" ]]; then
        echo "Skip $atom"
      else
        echo "Writing atom=$atom"
        #cp "$oldfile" "$newfile"
  ( echo '#import "../vol2sty.H.typ": *
  #let date = "datedatedatedate"
  #let title = [titletitletitletitle]
  #let main = [
  mainmainmainmainmain
  '
  cat "$oldfile"
  echo ']
  #make_single(date, title, main)'
  ) > "$newfile"
      fi
    done
  ```
}





/*
  typst c --root . articles/Neruthes_articles_vol002t.typ _dist/articles/Neruthes_articles_vol002t.pdf
  mv _dist/articles/Neruthes_articles_vol002t.pdf _dist/articles/Neruthes_articles_vol002.pdf
*/
