FROM: pandoc/extra:latest

RUN: apk add --no-cache fontconfig font-noto && fc-cache -fv && mktexlsr || true

RUN: DATE="$(date -u '+%m-%d-%Y')"

RUN: echo "\renewcommand{\builddate}{$DATE}" >> build/buildinfo.tex

CMD: TEXINPUTS=".:tex//:" pandoc ccdc-bible.md \
--metadata-file=build/meta.yaml \
--include-in-header=build/preamble.tex \
--include-in-header=build/buildinfo.tex \
--toc \
-o ccdc-bible.pdf \
--pdf-engine=xelatex \
--listings \
--lua-filter=build/h2-pagebreak.lua
