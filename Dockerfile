FROM pandoc/extra:latest

WORKDIR /data

RUN apk add --no-cache fontconfig font-noto python3 && fc-cache -fv 

ENV TEXINPUTS=".:tex//:"

RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'echo "Setting build date..."' >> /entrypoint.sh && \
    echo 'DATE="$(date -u '+%m-%d-%Y')"' >> /entrypoint.sh && \
    echo 'echo "\renewcommand{\builddate}{$DATE}" >> build/buildinfo.tex' >> /entrypoint.sh && \
    echo 'exec pandoc "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["ccdc-bible.md", \
    "--metadata-file=build/meta.yaml", \
    "--include-in-header=build/preamble.tex", \
    "--include-in-header=build/buildinfo.tex", \
    "--toc", \
    "--listings", \
    "-o", \ 
    "ccdc-bible.pdf", \
    "--pdf-engine=xelatex", \
    "--lua-filter=build/h2-pagebreak.lua", \
    "--lua-filter=build/tipbox.lua"]
