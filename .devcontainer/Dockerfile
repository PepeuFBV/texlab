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
        latexmk \
        texlive-binaries \
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-fonts-recommended \
        texlive-pictures \
        texlive-bibtex-extra \
        libyaml-perl \
        libfile-which-perl \
        perl \
        texlive-publishers \
        texlive-lang-portuguese \
        xdg-utils \
        zathura \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install cpanminus (cpanm) if not available, then install LaTeX::Indent and deps
RUN if ! command -v cpanm >/dev/null 2>&1; then \
      wget -qO /usr/local/bin/cpanm https://cpanmin.us && chmod +x /usr/local/bin/cpanm; \
    fi \
    && if command -v cpanm >/dev/null 2>&1; then \
      # Try canonical distribution name, a couple of alternates, then install common deps
      cpanm --notest LaTeX::Indent LaTeX-Indent latexindent YAML::Tiny File::Which File::HomeDir || true; \
    fi \
    && if ! command -v latexindent >/dev/null 2>&1 && ! command -v latexindent.pl >/dev/null 2>&1; then \
      # Fallback: fetch the latexindent.pl script from the maintained repository
      wget -qO /usr/local/bin/latexindent https://raw.githubusercontent.com/cmhughes/latexindent.pl/master/latexindent.pl && chmod +x /usr/local/bin/latexindent || true; \
    fi \
    # Also clone the full latexindent repo and install its Perl modules so the
    # script can find LatexIndent::Document and related modules
    && if command -v cpanm >/dev/null 2>&1; then \
      git clone --depth 1 https://github.com/cmhughes/latexindent.pl.git /tmp/latexindent || true; \
      if [ -d /tmp/latexindent ]; then \
        cpanm --notest /tmp/latexindent || true; \
      fi; \
    fi \
    && ln -sf "$(command -v latexindent.pl 2>/dev/null || command -v latexindent 2>/dev/null || true)" /usr/local/bin/latexindent || true
