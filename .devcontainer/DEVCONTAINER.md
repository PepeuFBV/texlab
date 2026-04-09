# Uso do DevContainer para LaTeX

Este DevContainer inclui uma instalação completa do TeX Live e está configurado para compilar projetos LaTeX em subdiretórios.

## Início rápido após abrir o repositório no VS Code (Dev Container):

- Rebuild do container: Command Palette → "Dev Containers: Rebuild Container".

- Depois que o container iniciar, watchers em background são iniciados para cada `main.tex` encontrado no workspace.

Comportamento:

- `postCreateCommand` verifica se `latexindent` está disponível e registra sua versão em `/tmp/devcontainer-latexindent.log`. Nenhuma compilação automática é realizada na criação.

- `postStartCommand` executa `.devcontainer/start-watchers.sh`, que inicia watchers `latexmk -pvc` para cada `main.tex` encontrado (os logs são gravados em `/tmp`).

- A extensão VS Code LaTeX Workshop é instalada e configurada para compilar automaticamente quando houver alterações nos arquivos.

Logs e inspeção:

- Log de verificação do latexindent: `/tmp/devcontainer-latexindent.log` (postCreate)

- Logs dos watchers: `/tmp/latex-watch-*.log`

- PIDs dos watchers: `/tmp/devcontainer-latex-pids`

> [!NOTE]
> A imagem/container completo tem aproximadamente 2–3 GB, em grande parte devido à instalação do TeX Live. Considere isso se tiver espaço em disco limitado.

Se preferir controle manual, você pode parar os watchers finalizando os PIDs listados em `/tmp/devcontainer-latex-pids` e executar builds manualmente com:

```bash
latexmk -pdf -cd -interaction=nonstopmode -file-line-error path/to/main.tex
```

## Limites de recursos

Este DevContainer usa o arquivo `.devcontainer/.env.resources` para definir valores de referência:

- `MEM_LIMIT`: 2G
- `CPU_LIMIT`: 1

> [!WARNING]
> A configuração atual usa `--env-file` via `runArgs`, o que injeta essas variáveis como variáveis de ambiente dentro do container, mas **não cria limites reais de memória ou CPU** no Docker. Para limites executados de verdade, use uma configuração baseada em `docker-compose` que mapeie esses valores para `mem_limit`/`cpus` no serviço.

Após alterar os limites, reconstrua o container pela Command Palette: "Dev Containers: Rebuild Container".
