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

Os limites são definidos em `.devcontainer/.env.resources` e aplicados via `compose.yaml`:

- `MEM_LIMIT`: 2G
- `CPU_LIMIT`: 1

O `compose.yaml` mapeia essas variáveis para `mem_limit` e `cpus` no serviço Docker, o que cria limites reais de cgroup no kernel — diferentemente do `--env-file` em `runArgs`, que apenas injeta variáveis de ambiente sem restringir recursos.

Para alterar os limites na sua máquina local, edite `.devcontainer/.env.resources` e reconstrua o container.

> [!NOTE]
> No GitHub Codespaces, os limites de recursos são controlados pelo tipo de máquina escolhida (2-core, 4-core etc.) e podem sobrepor os valores definidos aqui.

Após alterar os limites, reconstrua o container pela Command Palette: "Dev Containers: Rebuild Container".
