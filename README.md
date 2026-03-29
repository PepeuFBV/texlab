# TexAcademy

[![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?repository=PepeuFBV/texacademy&ref=main&devcontainer_path=.devcontainer)
[![Test Install Script](https://github.com/PepeuFBV/texacademy/actions/workflows/test-install-script.yml/badge.svg)](https://github.com/PepeuFBV/texacademy/actions/workflows/test-install-script.yml)
[![Validate Templates](https://github.com/PepeuFBV/texacademy/actions/workflows/validate-templates.yml/badge.svg)](https://github.com/PepeuFBV/texacademy/actions/workflows/validate-templates.yml)
[![Devcontainer CI](https://github.com/PepeuFBV/texacademy/actions/workflows/devcontainer-ci.yml/badge.svg)](https://github.com/PepeuFBV/texacademy/actions/workflows/devcontainer-ci.yml)

TexAcademy é uma coleção de setups reproduzíveis para compilação LaTeX, templates e "modelos" de ambiente direcionados a diferentes universidades e programas (por exemplo: PIBIC, PIC, PIBITI, relatórios de graduação, teses e outros formatos institucionais).

## Objetivo

Fornecer um repositório único onde colaboradores possam adicionar setups prontos para uso (ou com pequena configuração) para instituições e programas específicos. Cada setup inclui scripts de compilação, configurações recomendadas de editor/DevContainer e uma estrutura de exemplo para que alunos e orientadores foquem no conteúdo, não nas ferramentas.

## Destaques

- Vários modelos/setups para projetos LaTeX organizados por instituição e programa.

- Ambientes de desenvolvimento reproduzíveis (DevContainer e configurações recomendadas do VS Code).

- Exemplos contendo imagens, seções e bibliografia para demonstrar fluxos de trabalho comuns.

## Estrutura do repositório

Pastas de nível superior normalmente seguem este padrão:

- `ufrpe/` — exemplo de instituição (contém pastas por programa)
    - `pibic/` — pasta do programa
        - `parcial/` — etapa do projeto
        - `final/` — etapa do projeto

Veja o exemplo existente em `ufrpe/pibic/final` para um projeto funcional.

## Começando

1. Escolha uma pasta de exemplo (por exemplo `ufrpe/pibic/final`).

2. Abra a pasta no VS Code. Para um ambiente reproduzível, consulte [DEVCONTAINER.md](DEVCONTAINER.md).

## Script de instalação

O repositório inclui um script de instalação interativo que permite escolher um template e configurar o ambiente automaticamente.

### Uso básico (via curl)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PepeuFBV/texacademy/main/scripts/install.sh)
```

### Uso local

```bash
bash scripts/install.sh
```

O script:
1. (Opcional) Instala o `fzf` para busca fuzzy interativa.

2. Apresenta a lista de templates disponíveis com busca interativa.

3. Pergunta se deseja instalar a configuração do DevContainer.

## Adicionando novos modelos

Para adicionar um novo modelo para universidade/programa:

1. Crie uma nova pasta com o padrão `templates/<instituicao>/<programa>/<nome-modelo>`.

2. Adicione um `main.tex`, uma pasta mínima `sections/`, `images/` e `references.bib` (se necessário).

3. Registre o template em `templates.json` seguindo a estrutura existente (instituição → programa → versão), incluindo `id`, `name`, `description` e `path`.

4. Siga as orientações em [CONTRIBUTING.md](CONTRIBUTING.md) e abra um pull request.

> [!IMPORTANT]
> Todo template precisa ter uma entrada correspondente em `templates.json`. O CI rejeita automaticamente templates sem registro e entradas JSON sem diretório correspondente.

## Desenvolvimento & DevContainers

Recomendamos usar um DevContainer para garantir ferramentas LaTeX consistentes entre colaboradores. Veja [DEVCONTAINER.md](DEVCONTAINER.md) para uma sugestão de configuração (TeX Live, latexmk e pacotes LaTeX comuns).

## GitHub Codespaces

Este repositório já inclui um DevContainer em `.devcontainer` preparado para compilação LaTeX (veja `.devcontainer/devcontainer.json`).

GitHub Codespaces permite criar ambientes de desenvolvimento na nuvem baseados em DevContainers, tornando possível compilar e editar projetos LaTeX sem instalar ferramentas localmente.

Como usar:

- Clique em "Code" no GitHub e escolha "Codespaces" → "Create codespace on main" (ou na branch desejada), ou use o botão acima para abrir um Codespace pré-configurado.

- O DevContainer do repositório configura TeX Live, `latexmk`, `latexindent` e a extensão LaTeX Workshop automaticamente.

## CI / Pipelines de qualidade

O repositório mantém três pipelines de CI no GitHub Actions:

| Pipeline | Descrição | Gatilho |
|---|---|---|
| **Test Install Script** | Testa `scripts/install.sh` e `scripts/choose_template.sh` de forma não-interativa; escolhe um template aleatório de `templates.json` e verifica que o diretório existe. | Push/PR em `scripts/**`, `templates.json`, `templates/**` |
| **Validate Templates** | Executa `scripts/validate_templates.sh`: verifica que todo path em `templates.json` tem um diretório com `main.tex` e que todo diretório com `main.tex` tem entrada em `templates.json`. | Push/PR em `templates/**`, `templates.json` |
| **Devcontainer CI** | Constrói a imagem Docker do DevContainer e verifica que `latexmk` e `latexindent` funcionam. | Push/PR em `main` |

### Validação local de templates

```bash
bash scripts/validate_templates.sh
```

## Planejamento futuro

- Adicionar mais templates para diferentes instituições e programas.

- ~~CI/CD para validar compilações de templates adicionados e PRs.~~ ✅ Implementado

- Template para mensagens de PRs para garantir que novos templates sigam o formato esperado e seja fácil para revisores entenderem o que está sendo adicionado.

- Versionamento automático para lançamentos de templates estáveis.

- ~~Script para extração de templates.~~ ✅ Implementado (`scripts/install.sh`)

- Guia de estilo para templates (estrutura de pastas, convenções de nomenclatura, etc.) para garantir consistência.

## Contribuindo

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes sobre como adicionar um novo template, testar compilações e expectativas para PRs.

## Contato / Mantenedores

Se precisar de ajuda para adicionar templates para sua instituição/programa, abra uma issue ou PR com o template e um PDF de exemplo.

Obrigado por contribuir!

## Licença

Veja [LICENSE](LICENSE) para detalhes sobre a licença do projeto.
