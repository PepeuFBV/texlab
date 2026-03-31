 # Contribuindo

 ## Adicionando um novo template

 > [!NOTE]
 > Consulte o [STYLE_GUIDE.md](STYLE_GUIDE.md) para as convenções completas de nomenclatura, estrutura e qualidade esperadas de cada template.

 ### Estrutura de diretórios

 Cada template deve seguir o padrão:

 ```
 templates/<instituicao>/<programa>/<versao>/
 ├── main.tex          # obrigatório
 ├── referencias.bib   # se necessário
 ├── sections/         # subseções do documento
 └── images/           # imagens e figuras
 ```

 ### Registro em `templates.json`

 Todo novo template **precisa** ter uma entrada correspondente em `templates.json`. O CI falhará caso contrário.

 Exemplo de entrada:

 ```json
 {
   "id": "SIGLA_INSTITUICAO",
   "name": "Nome completo da instituição",
   "url": "https://www.instituicao.br/",
   "path": "sigla/",
   "description": "Descrição da instituição.",
   "programs": [
     {
       "id": "SIGLA_PROGRAMA",
       "name": "Nome completo do programa",
       "description": "Descrição do programa.",
       "path": "sigla-programa/",
       "versions": [
         {
           "id": "versao",
           "name": "Nome legível do template",
           "description": "Descrição do template.",
           "path": "versao/"
         }
       ]
     }
   ]
 }
 ```

> [!NOTE]
> O path resultante (concatenação de `path` de cada nível, sem barras duplicadas) deve corresponder exatamente ao diretório em `templates/`.

 ### Checklist para PRs com novos templates

 - [ ] Diretório criado em `templates/<instituicao>/<programa>/<versao>/`.
 - [ ] Arquivo `main.tex` presente no diretório.
 - [ ] Entrada adicionada em `templates.json` apontando para o caminho correto.
 - [ ] `bash scripts/validate_templates.sh` passa localmente.
 - [ ] Documento compila com `latexmk -pdf -cd -interaction=nonstopmode main.tex`.

 ## CI / Pipelines automáticos

 | Pipeline | O que testa |
 |---|---|
 | **Test Install Script** | `scripts/install.sh` e `scripts/choose_template.sh` não-interativos; escolha aleatória de template |
 | **Validate Templates** | Consistência entre `templates.json` e `templates/` |
 | **Devcontainer CI** | Build da imagem Docker e verificação de `latexmk`/`latexindent` |

 ### Validação local (antes do PR)

 ```bash
 bash scripts/validate_templates.sh
 ```

 ## Convenção de Commits

 Use [Conventional Commits](https://www.conventionalcommits.org/):

 - `feat:` nova funcionalidade
 - `fix:` correção de bug
 - `docs:` alterações na documentação
 - `style:` estilo de código (formatação, ponto-e-vírgula faltando)
 - `refactor:` refatoração de código
 - `perf:` melhorias de desempenho
 - `test:` adicionar/atualizar testes
 - `chore:` dependências, configuração de build

 Exemplo: `feat(parser): add support for new LaTeX package`

 > [!NOTE]
 > Mantenha os commits e nome de branches em inglês para consistência, mesmo que o conteúdo seja em português.

 ## Nomeação de Branches

 - Feature: `feature/description`
 - Fix: `fix/description`
 - Docs: `docs/description`

 Exemplo: `feature/latexindent-support`

 ## Processo de Pull Request

 1. Crie a branch de feature a partir de `main`.

 2. Mantenha commits atômicos e descritivos.

 3. Atualize a documentação se necessário.

 4. Garanta que o CI esteja passando.

 5. Solicite revisão antes de fazer o merge.

 ## Estilo de Código

 - Siga as convenções existentes do projeto.
 
 - Use a estrutura de diretórios já existente para novos templates.

 ## Reportando Issues

 - Use títulos claros e descritivos.

 - Inclua detalhes relevantes do ambiente (sistema, versão do TeX Live, comandos usados).

 - Forneça passos mínimos para reproduzir o problema.