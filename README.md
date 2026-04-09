# TexAcademy

[![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?repository=PepeuFBV/texacademy&ref=main&devcontainer_path=.devcontainer)

Uma coleção de **setups reproduzíveis para LaTeX** com templates e ambientes prontos para diferentes universidades e programas (PIBIC, PIC, PIBITI, relatórios de graduação, teses, etc.).

Foco: templates LaTeX estruturados + ambientes de desenvolvimento reproduzíveis (DevContainer) + scripts de instalação automatizados.

## Começando

**1. Script de instalação (recomendado)**

Opção conveniente — instala sempre a versão mais recente do `main`:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PepeuFBV/texacademy/main/scripts/install.sh)
```

Opção com versão fixada — instala a partir de uma tag de release específica (mais segura e reproduzível):

```bash
# Substitua vX.Y.Z pela tag desejada, por exemplo v1.0.0
bash <(curl -fsSL https://raw.githubusercontent.com/PepeuFBV/texacademy/vX.Y.Z/scripts/install.sh)
```

> [!TIP]
> Instalar por uma tag garante que o template e os scripts não mudam entre execuções. Recomendado para ambientes de produção ou documentos formais.

> [!NOTE]
> Atualmente só há suporte para Linux/MacOS. Windows via WSL é possível, mas não testado oficialmente.

**2. Manualmente**

1. Escolha um template em `templates/<instituicao>/<programa>/<versao>/`.

2. Abra a pasta no VS Code.

3. Para ambiente reproduzível, veja [DEVCONTAINER.md](DEVCONTAINER.md) ou [CODESPACES.md](CODESPACES.md).

## Documentação

- **[CONTRIBUTING.md](CONTRIBUTING.md)** — Como adicionar novos templates, convenções de commits e checklist para PRs.
- **[STYLE_GUIDE.md](STYLE_GUIDE.md)** — Estrutura de pastas, convenções de nomenclatura e qualidade mínima para templates.
- **[DEVCONTAINER.md](.devcontainer/DEVCONTAINER.md)** — Configuração e uso de DevContainers para compilação LaTeX local.
- **[CODESPACES.md](.devcontainer/CODESPACES.md)** — Como usar GitHub Codespaces para desenvolvimento na nuvem.
- **[CI.md](.github/workflows/CI.md)** — Pipelines de qualidade (validação de templates, CI/CD).
- **[scripts/README.md](scripts/README.md)** — Detalhes sobre scripts de instalação e automação.

## Planejamento futuro

- ~~Adicionar mais templates para diferentes instituições e programas.
- ~~CI/CD para validar compilações de templates adicionados e PRs.~~ ✅ Implementado
- ~~Template para mensagens de PRs para garantir que novos templates sigam o formato esperado.~~ ✅ Implementado
- ~~Versionamento automático para lançamentos de templates estáveis.~~ ✅ Implementado
- ~~Script para extração de templates.~~ ✅ Implementado (`scripts/install.sh`)
- ~~Guia de estilo para templates (estrutura de pastas, convenções de nomenclatura, etc.).~~ ✅ Implementado (`STYLE_GUIDE.md`)

## Contato / Mantenedores

Se precisar de ajuda para adicionar templates para sua instituição/programa, abra uma issue ou PR com o template e um PDF de exemplo.

Obrigado por contribuir!

## Licença

Veja [LICENSE](LICENSE) para detalhes sobre a licença do projeto.
