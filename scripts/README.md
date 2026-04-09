# Scripts

Este diretório contém scripts de instalação e validação usados pelo repositório.

- `install.sh` — instalador interativo para copiar um template para um diretório local e (opcionalmente) instalar o DevContainer.
	- Uso interativo: `bash scripts/install.sh`
	- Via curl (pipe): `bash <(curl -fsSL https://raw.githubusercontent.com/PepeuFBV/texacademy/main/scripts/install.sh)`
	- Variáveis úteis (modo pipe / não-interativo): `TEXACADEMY_RAW_BASE`, `TEXACADEMY_REF`, `TEXACADEMY_ARCHIVE_URL`.
- `choose_template.sh` — lê `templates.json` usando `python3` e permite selecionar um template (suporta `fzf` ou busca incremental em bash). Em modo não-interativo retorna o primeiro template.
- `validate_templates.sh` — valida consistência entre `templates.json` e diretórios em `templates/` usando `python3` (execute antes de abrir PRs).

> [!NOTE]
> `python3` é necessário para `choose_template.sh` e `validate_templates.sh`. Está disponível por padrão na maioria dos sistemas Linux/macOS e nos ambientes CI deste repositório.

Exemplos rápidos:

```bash
# Instalar template interativamente
bash scripts/install.sh

# Validar templates localmente (recomendado antes do PR)
bash scripts/validate_templates.sh
```

Mais detalhes e opções estão documentadas nos comentários dos próprios scripts.
