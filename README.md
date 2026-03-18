# Texlab

Texlab é uma coleção de setups reproduzíveis para compilação LaTeX, templates e "modelos" de ambiente direcionados a diferentes universidades e programas (por exemplo: PIBIC, PIC, PIBITI, relatórios de graduação, teses e outros formatos institucionais).

Objetivo
--------

Fornecer um repositório único onde colaboradores possam adicionar setups prontos para uso (ou com pequena configuração) para instituições e programas específicos. Cada setup inclui scripts de compilação, configurações recomendadas de editor/DevContainer e uma estrutura de exemplo para que alunos e orientadores foquem no conteúdo, não nas ferramentas.

Destaques
--------

- Vários modelos/setups para projetos LaTeX organizados por instituição e programa.
- Ambientes de desenvolvimento reproduzíveis (DevContainer e configurações recomendadas do VS Code).
- Exemplos contendo imagens, seções e bibliografia para demonstrar fluxos de trabalho comuns.
- Diretrizes de contribuição para adicionar novos templates institucionais.

Estrutura do repositório (exemplo)
---------------------------------

Pastas de nível superior normalmente seguem este padrão:

- `ufrpe/` — exemplo de instituição (contém pastas por programa)
	- `pibic/` — pasta do programa
		- `parcial/` — etapa do projeto
        - `final/` — etapa do projeto

Veja o exemplo existente em `ufrpe/pibic/parcial` para um projeto funcional.

Começando
---------

1. Escolha uma pasta de exemplo (por exemplo `ufrpe/pibic/parcial`).
2. Abra a pasta no VS Code. Para um ambiente reproduzível, consulte [DEVCONTAINER.md](DEVCONTAINER.md).
3. Compile com sua ferramenta LaTeX preferida (comandos rápidos estão em [DEVCONTAINER.md](DEVCONTAINER.md)).

Adicionando novos modelos
------------------------

Para adicionar um novo modelo para universidade/programa:

1. Crie uma nova pasta com o padrão `/<instituicao>/<programa>/<nome-modelo>`.
2. Adicione um `main.tex`, uma pasta mínima `sections/`, `images/` e `references.bib` (se necessário).
3. Adicione um `README.md` curto na pasta do modelo descrevendo pacotes LaTeX necessários e passos de compilação.
4. Siga as orientações em [CONTRIBUTING.md](CONTRIBUTING.md) e abra um pull request.

Desenvolvimento & DevContainers
------------------------------

Recomendamos usar um DevContainer para garantir ferramentas LaTeX consistentes entre colaboradores. Veja [DEVCONTAINER.md](DEVCONTAINER.md) para uma sugestão de configuração (TeX Live, latexmk e pacotes LaTeX comuns).

Contribuindo
-----------

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes sobre como adicionar um novo template, testar compilações e expectativas para PRs.

Licença
-------

Este repositório ainda não contém um arquivo de licença — adicione um se desejar publicar templates sob uma licença específica.

Contato / Mantenedores
---------------------

Se precisar de ajuda para adicionar templates para sua instituição/programa, abra uma issue ou PR com o template e um PDF de exemplo.

Obrigado por contribuir! — Mantenedores do Texlab