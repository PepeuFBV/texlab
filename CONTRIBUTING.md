 # Contribuindo

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