#let __config_main_body_end_page = 99999

// END OF CONFIG ============================================================

#import "@preview/ose-pic:0.1.2": *
#import "@local/cjk-unshrink:0.1.0": *



#let __fonts_fancy = (
  "Old Standard TT",
  "Old Standard",
  "New Computer Modern",
  "Brygada 1918",
  "Noto Serif CJK SC",
)
#let __fonts_serif = ("Brygada 1918", "Noto Serif CJK SC")
#let __fonts_sans = ("Inter", "Inter Tight", "Inter", "Geist", "TeX Gyre Heros", "Noto Sans CJK SC")
#let __fonts_mono1 = (
  "New Heterodox Mono",
  "Xanh Mono",
  "Geist Mono",
  "Inter Tight",
  "Inter",
  "Geist",
  "TeX Gyre Heros",
  "Noto Sans CJK SC",
)

#let kp = 25.4mm / 72.27
#let fontsize = 11 * kp
#let textwidth = 37 * fontsize

// #let state__prepages = state("state__prepages", 0) // Useless?







#let enable_header_footer(page_num_offset: 0) = {
  AddToShipoutBGAll(context {
    let ready_bg = place(bottom + center, dy: -20mm, box(width: textwidth, height: 50mm, {
      v(1fr)
      [
        #set text(font: __fonts_fancy, size: 10 * kp, weight: 400)
        // #set text(font: __fonts_serif, size: 10 * kp, weight: 400)
        #box(scale(reflow: true, x: 100%)[Neruthes Articles Collection~~§~~Volume 2])
        #h(1fr)
        #set text(font: __fonts_mono1)
        #(counter(page).get().at(0) + page_num_offset)
      ]
    }))
    ready_bg
  })
}




#let docinit(doc, is_single: true, page_num_offset: 0) = context {
  show: cjk-unshrink.with(plain-汉字: true, plain-ひらがな: true, plain-カタカナ: true)
  set page(paper: "a4", margin: (210mm - textwidth) / 2, header: {
    // counter(footnote).update(0) // No longer needed?
  })
  set text(size: fontsize)
  // set text(font: __fonts_sans, number-width: "tabular") // tabular?
  set text(font: __fonts_sans)
  set par(justify: true, leading: 0.55em, spacing: 1.3em)
  show: ose-pic-init
  // if not is_single {
  //   enable_header_footer() // Never automatically setup?
  // }
  doc
}






#let style__article_title(title) = (text(font: __fonts_serif, size: 1.3em, weight: 600)[#title] + v(8mm))

#let make_single_in_vol(date, title, main) = [ // For volume only
  #text(font: __fonts_mono1, date)

  #style__article_title[#title]

  #main
]

#let make_single(date, title, main) = [ // For single article PDF builds only
  #show: docinit.with(is_single: true)
  #{
    // ==================================================================
    // If is single, attempt to add total pages before self
    let __got_pages_count = 0
    if true {
      let __placeholder_nonexistent_path = "1453/1453-05-29-null.TYP"
      let self_file_name = sys.inputs.at("article_file_name", default: __placeholder_nonexistent_path)
      // [self_file_name = #self_file_name]
      let articles_list = read("/.data/articles/vol002typ/.alist.txt").trim().split("\n") // Must replace at first or stupid static analysis attempts to import

      // Find all articles that come before the current one
      let before_list = ()
      let __accm__pages = 2 // How many pages including cover, toc, etc?
      let __accm__footnotes = 0 // footnotes
      let __found_self = false
      // Create list
      for itr in range(0, articles_list.len()) {
        let thisfn = articles_list.at(itr)
        if thisfn == self_file_name {
          __found_self = true
        }
        if not __found_self {
          before_list.push(thisfn)
        }
      }
      // Run over list
      for itr in range(0, before_list.len()) {
        let thisfn = before_list.at(itr)
        let fpath = "/.data/articles/vol002typ/" + thisfn
        let rawtxt = read(fpath)
        // Count pages
        let __magic_prefix = "#let pages = "
        let txt_row_arr = rawtxt
          .trim()
          .split("\n")
          .filter(line => line.clusters().len() > __magic_prefix.clusters().len())
          .filter(line => line.clusters().slice(0, __magic_prefix.clusters().len()).join("") == __magic_prefix)
        if txt_row_arr.len() > 0 {
          let txt_row = txt_row_arr.at(0)
          let pages_int = int(txt_row.split(" ").at(3)) // This is fragile!
          __accm__pages += pages_int
        } else {
          page[BIG ERROR FOUND!]
        }
        // Count footnotes
        __accm__footnotes += rawtxt.matches("#footnote").len()
      }
      counter(footnote).update(__accm__footnotes)
      enable_header_footer(page_num_offset: __accm__pages)
    }
    // ==================================================================
    make_single_in_vol(date, title, main)
  }
  // #text(font: __fonts_mono1, date)

  // #style__article_title[#title]

  // #main
]



