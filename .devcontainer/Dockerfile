FROM mcr.microsoft.com/vscode/devcontainers/base:debian

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        ca-certificates \
        poppler-utils \
        ghostscript \
        fonts-dejavu-core \
        make \
    && apt-get install -y --no-install-recommends \
        latexmk \
        texlive-binaries \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-fonts-recommended \
        texlive-pictures \
        texlive-bibtex-extra \
        texlive-publishers \
        texlive-lang-portuguese \
        xdg-utils \
        zathura \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# prevent interactive prompts from some TeX packages
ENV TZ=UTC

CMD ["/bin/bash"]
