# Scripts

Este diretório contém scripts de instalação e validação usados pelo repositório.

- `install.sh` — instalador interativo para copiar um template para um diretório local e (opcionalmente) instalar o DevContainer.
	- Uso interativo: `bash scripts/install.sh`
	- Via curl (pipe): `bash <(curl -fsSL https://raw.githubusercontent.com/PepeuFBV/texacademy/main/scripts/install.sh)`
	- Variáveis úteis (modo pipe / não-interativo): `TEXACADEMY_RAW_BASE`, `TEXACADEMY_REF`, `TEXACADEMY_ARCHIVE_URL`.
- `choose_template.sh` — lê `templates.json` e permite selecionar um template (suporta `fzf` ou busca incremental em bash). Em modo não-interativo retorna o primeiro template.
- `validate_templates.sh` — valida consistência entre `templates.json` e diretórios em `templates/` (execute antes de abrir PRs).

Exemplos rápidos:

```bash
# Instalar template interativamente
bash scripts/install.sh

# Validar templates localmente (recomendado antes do PR)
bash scripts/validate_templates.sh
```

Mais detalhes e opções estão documentadas nos comentários dos próprios scripts.
