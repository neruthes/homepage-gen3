# Documentation: Building This Website

This repository is a static website. It requires some building before deployment.
This document may be helpful for the members of my legacy management committee.


## Dependencies

Building this static website requires some dependencies:

- TeX Live
- Certain fonts which are not included in TeX Live
  - JetBrains Mono
  - Source Serif Pro
  - Noto Sans CJK SC
  - Noto Serif CJK SC
- Some scripts from [NDevShellRC](https://github.com/neruthes/NDevShellRC)
  - `ntex`


## Main Workflow

Take a look at `/build.sh`. It explains the workflow of a full build.


## Appendix

This document was last updated in 2023.
If you are reading this document from the future of many years later,
some dependencies may perhaps be incompatible with my code,
i.e. dropping support of deprecated features.
In such a situation,
try using an older version which had been available when this document was last revised.
