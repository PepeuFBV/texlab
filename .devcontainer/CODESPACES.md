# GitHub Codespaces

Este repositório inclui um DevContainer em `.devcontainer` preparado para compilação LaTeX, permitindo usar GitHub Codespaces para compilar e editar projetos LaTeX sem instalar ferramentas localmente.

## Como usar

1. Clique em **"Code"** no GitHub e escolha **"Codespaces"** → **"Create codespace on main"** (ou na branch desejada).

   Alternativamente, use o botão abaixo para abrir um Codespace pré-configurado:
   
   [![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?repository=PepeuFBV/texacademy&ref=main&devcontainer_path=.devcontainer)

2. O DevContainer do repositório configura automaticamente:
   - TeX Live (distribuição LaTeX completa)
   - `latexmk` (gerenciador de compilação)
   - `latexindent` (formatação LaTeX)
   - VS Code LaTeX Workshop (extensão)

3. Após o ambiente estar pronto, a compilação inicial do exemplo (`ufrpe/pibic/final`) ocorre automaticamente.

## Comportamento padrão

- **postCreateCommand**: Compila `ufrpe/pibic/final/main.tex` uma vez durante a criação.
- **postStartCommand**: Inicia watchers `latexmk -pvc` para cada `main.tex` encontrado no workspace.
- **VS Code LaTeX Workshop**: Configurado para auto-build ao salvar arquivos.

## Logs e inspeção

- Build log: `/tmp/devcontainer-latex.log`
- Watcher logs: `/tmp/latex-watch-*.log`
- Watcher PIDs: `/tmp/devcontainer-latex-pids`

## Recursos e limites

O DevContainer usa configurações conservadoras de recursos (ver `.devcontainer/.env.resources`):

- `MEM_LIMIT`: 2G
- `CPU_LIMIT`: 1

> [!NOTE]
> A imagem completa tem aproximadamente 2-3GB de tamanho, principalmente devido à instalação do TeX Live.

Para controle manual, você pode parar os watchers e compilar manualmente com:

```bash
latexmk -pdf -cd -interaction=nonstopmode -file-line-error path/to/main.tex
```

## Mais informações

Veja [DEVCONTAINER.md](DEVCONTAINER.md) para detalhes técnicos sobre a configuração local de DevContainers.
