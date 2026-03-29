# Uso do DevContainer para LaTeX

Este DevContainer inclui uma instalação completa do TeX Live e está configurado para compilar projetos LaTeX em subdiretórios.

## Início rápido após abrir o repositório no VS Code (Dev Container):

- Rebuild do container: Command Palette → "Dev Containers: Rebuild Container".

- Depois que o container iniciar, uma compilação com `latexmk` é executada para o projeto de exemplo e watchers em background são iniciados para cada `main.tex` encontrado no workspace.

Comportamento:

- `postCreateCommand` compila `ufrpe/pibic/final/main.tex` uma vez durante a criação do container.

- `postStartCommand` executa `.devcontainer/start-watchers.sh`, que inicia watchers `latexmk -pvc` para cada `main.tex` encontrado (os logs são gravados em `/tmp`).

- A extensão VS Code LaTeX Workshop é instalada e configurada para compilar automaticamente quando houver alterações nos arquivos.

Logs e inspeção:

- Log de build: `/tmp/devcontainer-latex.log` (postCreate)

- Logs dos watchers: `/tmp/latex-watch-*.log`

- PIDs dos watchers: `/tmp/devcontainer-latex-pids`

> [!NOTE]
> A imagem/container completo tem aproximadamente 2–3 GB, em grande parte devido à instalação do TeX Live. Considere isso se tiver espaço em disco limitado.

Se preferir controle manual, você pode parar os watchers finalizando os PIDs listados em `/tmp/devcontainer-latex-pids` e executar builds manualmente com:

```bash
latexmk -pdf -cd -interaction=nonstopmode -file-line-error path/to/main.tex
```

## Limites de recursos

Este DevContainer usa o arquivo de ambiente `.devcontainer/.env.resources` para fornecer valores conservadores para uso de recursos. Padrões atuais:

- `MEM_LIMIT`: 2G
- `CPU_LIMIT`: 1

Para alterar os limites na sua máquina local, edite [`.devcontainer/.env.resources`](.devcontainer/.env.resources) ou sobrescreva as variáveis no seu `devcontainer.json` local antes de reconstruir.

Após alterar os limites, reconstrua o container pela Command Palette: "Dev Containers: Rebuild Container".

Comando rápido para reconstruir (Command Palette):

```bash
# Abra a Command Palette (Ctrl+Shift+P) → "Dev Containers: Rebuild Container"
```
