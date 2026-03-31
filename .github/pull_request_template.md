## Descrição

<!-- Descreva o que essa PR faz e por que. -->

## Tipo de mudança

- [ ] Novo template
- [ ] Correção de bug
- [ ] Documentação
- [ ] Melhoria de script/CI
- [ ] Outro: <!-- descreva -->

---

## Checklist para novos templates

> Preencha apenas se essa PR adiciona ou atualiza um template.

- [ ] Diretório criado em `templates/<instituicao>/<programa>/<versao>/` seguindo as convenções de nomenclatura do [STYLE_GUIDE.md](../STYLE_GUIDE.md).
- [ ] Arquivo `main.tex` presente no diretório do template.
- [ ] Entrada adicionada em `templates.json` com `id`, `name`, `description` e `path` corretos.
- [ ] `bash scripts/validate_templates.sh` passa localmente (sem erros).
- [ ] Documento compila sem erros com `latexmk -pdf -cd -interaction=nonstopmode main.tex`.
- [ ] PDF de exemplo gerado (ou link para versão compilada) incluído/referenciado.
- [ ] Seções de placeholder usam `\lipsum` ou texto de exemplo claro, não conteúdo real de autor.

## Checklist geral

- [ ] Commits seguem [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`, etc.).
- [ ] Branch criada a partir de `main`.
- [ ] CI passa (Validate Templates, Test Install Script).
- [ ] Documentação atualizada se necessário (README, CONTRIBUTING, STYLE_GUIDE).

## Testes realizados

<!-- Descreva brevemente como você testou as mudanças. -->

## Contexto adicional

<!-- Links, referências, screenshots ou qualquer informação extra relevante. -->
