#import "../vol2sty.H.typ": *

#let pages = 1
#let date = "2022-12-12"
#let title = [Blogging Redefined]
#let main = [
  It has been about 10 years since I started blogging (with a serious attitude).
  Unfortunately, writing blog posts is no longer an enjoyable activity for me,
  because of, not only the cursedness of modern web frontend technology,
  but also the typesetting experience.

  Over the recent months, I have been learning LaTeX,
  the typesetting system known for its long history and its affinity to the KISS φιλοσοφια.
  The LaTeX ecosystem (including TeX Live, CTAN, etc)
  has proven its value for a less sanity-consuming typesetting/publishing experience.
  It is more optimized for multilingual scenarios; it gives better control over final rendering;
  it makes font management less painful; it makes archiving less complicated.

  Therefore, I have made a decision ---
  I would migrate to a LaTeX-based workflow for blogging.
  The previous articles will be collected in _Neruthes Articles Collection Volume 1_,
  and the new ones will be collected in _Neruthes Articles Collection Volume 2_.
  Subsequent volume identifiers will be allocated when a current volume reaches a considerable quantity of pages.

  Also, with a great objection to contemporary web design trends,
  e.g. abusing WebGL and canvas,
  I have made an iteration for my website to embrace a plain and minimalist style.
  In an era when the "pioneers" pursue baroque-level complexity,
  I choose to make things as simple as gravestones.
]
#make_single(date, title, main)
