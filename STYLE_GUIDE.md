# Guia de Estilo para Templates

Este documento define as convenções de estrutura de pastas, nomenclatura e organização para todos os templates do TexAcademy. Seguir este guia garante consistência entre contribuições e facilita a manutenção do repositório.

## Estrutura de diretórios

```
templates/
└── <instituicao>/          # sigla da instituição, minúsculas, kebab-case
    └── <programa>/         # sigla do programa, minúsculas, kebab-case
        └── <versao>/       # identificador da versão, minúsculas, kebab-case
            ├── main.tex          # obrigatório — ponto de entrada do documento
            ├── referencias.bib   # recomendado — referências bibliográficas
            ├── sections/         # recomendado — subseções do documento
            │   ├── 00-resumo.tex
            │   ├── 01-introducao.tex
            │   └── ...
            └── images/           # recomendado — imagens e figuras
```

> [!NOTE]
> Cada nível deve ter uma entrada correspondente em `templates.json`. A concatenação dos `path` de cada nível deve formar o caminho real do diretório.

## Convenções de nomenclatura

### Diretórios de templates

| Nível | Regra | Exemplo |
|---|---|---|
| Instituição | Sigla oficial, minúsculas, separada por hífen se necessário | `ufrpe`, `ufpe`, `usp`, `ufmg` |
| Programa | Sigla do programa, minúsculas, separada por hífen | `pibic`, `pibiti`, `pic`, `tcc`, `dissertacao` |
| Versão | Identificador descritivo da versão do documento | `final`, `parcial`, `projeto`, `v2` |

### Arquivos

| Arquivo | Regra |
|---|---|
| `main.tex` | Sempre exatamente `main.tex` — é o ponto de entrada esperado pelo CI e pelos scripts |
| `referencias.bib` | Nome recomendado para o arquivo BibTeX principal |
| Seções | `NN-nome-curto.tex` onde `NN` é um número de dois dígitos com zero à esquerda (ex: `01-introducao.tex`) |
| Imagens | `nome-descritivo.{png,pdf,jpg}`, minúsculas, separadas por hífen |

### Identificadores em `templates.json`

| Campo | Regra | Exemplo |
|---|---|---|
| `id` | Sigla em maiúsculas | `"UFRPE"`, `"PIBIC"`, `"final"` |
| `name` | Nome completo legível, em português | `"Template de Relatório final PIBIC"` |
| `description` | Frase completa descrevendo o template | `"Modelo de documento para..."` |
| `path` | Mesmo valor do diretório real, com barra ao final | `"ufrpe/"`, `"pibic/"`, `"final/"` |

## Conteúdo dos templates

### O arquivo `main.tex`

- Deve ser compilável de forma independente com `latexmk -pdf -cd -interaction=nonstopmode main.tex`.
- Deve usar `\input{}` ou `\include{}` para incluir seções de `sections/`.
- Não deve conter conteúdo real de um trabalho específico — use `\lipsum` ou texto de exemplo genérico.
- Deve ter comment header com informações básicas do template (instituição, programa, versão).

Exemplo de header recomendado:

```latex
% Template: <Nome da instituição> — <Nome do programa> — <Versão>
% Repositório: https://github.com/PepeuFBV/texacademy
% Licença: MIT
```

### Seções

- Use a numeração de dois dígitos para garantir ordem alfabética correta.
- Cada arquivo de seção deve conter apenas o conteúdo daquela seção, sem o `\begin{document}` ou `\documentclass`.
- Textos de placeholder devem usar `\lipsum[N]` ou mensagens claras como `% TODO: preencher esta seção`.

### Imagens

- Coloque todas as imagens em `images/`.
- Referencie-as com caminho relativo à pasta do template: `\includegraphics{images/nome.png}`.
- Não inclua imagens com direitos autorais.

## Qualidade mínima dos templates

Antes de submeter um PR com um novo template, verifique:

1. **Compilação**: `latexmk -pdf -cd -interaction=nonstopmode main.tex` sem erros.
2. **Validação**: `bash scripts/validate_templates.sh` sem erros.
3. **Estrutura**: Diretório, `main.tex` e entrada em `templates.json` presentes.
4. **Sem credenciais**: Nenhum dado pessoal real no template (nome, matrícula, orientador real, etc.).
5. **Estilo consistente**: Siga a estrutura dos templates existentes como referência.

## Referência rápida — checklist de nomenclatura

```
✅  templates/ufrpe/pibic/final/
✅  templates/ufpe/tcc/monografia/
✅  sections/01-introducao.tex
✅  images/diagrama-metodologia.png

❌  templates/UFRPE/PIBIC/Final/     (maiúsculas não permitidas)
❌  templates/ufrpe/pibic/           (sem nível de versão)
❌  sections/introducao.tex          (sem numeração)
❌  images/Diagrama Metodologia.png  (espaços não permitidos)
```
