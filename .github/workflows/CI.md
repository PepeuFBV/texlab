# CI / Pipelines de qualidade

O repositório mantém três pipelines de CI no GitHub Actions que garantem a qualidade e consistência dos templates.

## Pipelines disponíveis

| Pipeline | Descrição | Gatilho |
|---|---|---|
| **Test Install Script** | Testa `scripts/install.sh` e `scripts/choose_template.sh` de forma não-interativa; escolhe um template aleatório de `templates.json` e verifica que o diretório existe. | Push/PR em `scripts/**`, `templates.json`, `templates/**` |
| **Validate Templates** | Executa `scripts/validate_templates.sh`: verifica que todo path em `templates.json` tem um diretório com `main.tex` e que todo diretório com `main.tex` tem entrada em `templates.json`. | Push/PR em `templates/**`, `templates.json` |
| **Devcontainer CI** | Constrói a imagem Docker do DevContainer e verifica que `latexmk` e `latexindent` funcionam. | Push/PR em `main` |
| **Release** | Abre/atualiza um PR de release via release-please com CHANGELOG gerado a partir de Conventional Commits; ao merge cria um GitHub Release e faz upload do arquivo de templates (`templates-<version>.zip` / `.tar.gz`). | Push em `main` |

## Validação local de templates

Antes de fazer um push, valide seus templates localmente:

```bash
bash scripts/validate_templates.sh
```

Este script garante consistência entre `templates.json` e os diretórios reais de templates.

## Mais informações

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes sobre submissão de PRs com novos templates.
