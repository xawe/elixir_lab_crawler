# LabCrawler

**LabCrawler é apenas um OTP playground construido em cima de um simples webscraping, onde é possível executar chamadas de forma sequencial, paralela com um processo para cada URL e usando um pool de processos pré determinado, ajudando no entendimento de como usar recursos como GenServers para acelerar ao máximo a execução do scraping**

## Disclaimer

**Este lab foi construido em cima de um tutorial do Julien Corb, onde ele demonstra como fazer um simples WebScraping usando HttpPoison e Floki de forma sequencial. Os modulos Smoothixir e AllRecipes são basicamente as implementações mostradas em seu tutorial publicado em https://medium.com/@Jules_Corb/web-scraping-with-elixir-using-httpoison-and-floki-26ebaa03b076 . A leitura do tutorial original é altamente indicada para melhor entendimento da aplicação. O Código original pode ser encontrato em: https://github.com/JulienCorb/Smoothixir**


## Resumo

**A execução consiste basicamente em acessar o site AllRecipes.com, listar as receitas de smoothies e consultar cada url de receita para buscar os ingredientes e instruções de preparo.**


## Preparação

Execução padrão do Elixir: 

Após ter clonado o diretório:

- mix deps.get - para baixar as dependenxias

- iex -S mix - para iniciar o shell interativo

- :observer.start - para monitorar a execução do programa.


## 1 - Execução Sincrona - Sequencial

Para executar o processo sequencialmente:

- Smoothixir.start

O fluxo de execução será:

- 1) Obter o body da Url Principal

- 2) Encontrar dentro do Body, a url de cada receita de smoothies

- 3) Iterar cada Url, capturando o Nome, Ingredientes e instruções de preparo

- 4) Exibir resultado na tela


## 2 - Execução Assincrona - Pool de processos.

Essa função tem a vantagem de balancear o uso de recursos X tempo de processamento, já que a melhor quantidade de processos vai depender dos recursos da máquina e da largura de banda, tanto da maquina que está executando quanto do site que está sendo mapeado

Para executar usando um pool de processos:

- ParallelCrawler.run_pool(qtde_processos) 

ou 

- ParallelCrawler.run_pool_monitor(qtde_processos) : mesma execução, mas monitorando o tempo da etapa assincrona usando :timer.tc

O Fluxo de execução será: 

- 1) Obter o body da Url Principal - Sincrono

- 2) Encontrar dentro do Body, a url de cada receita de smoothies

- 3) Passar o resultado para o módulo Mediator

- 4) Criar a quantidade de processos definido pela variável `qtde_processos`, gerando um pool de processos

- 5) Iterar cada Url recebida e enviar para o pool de processos. Essa etapa será feita de forma a rotacionar a utilização dos processos

- 6) Finalizar a criação do fluxo e aguardar o termino de execução de cada processo.

- 7) A cada retorno, o resultando contendo o Nome, Ingredientes e Instruções de preparo serão enviados para o ResultStore, um Agent responsável por armazenar os dados processados.


## 3 - Execução Assincrona - Um processo para cada URL.

- ParallelCrawler.run_1x1()

ou 

- ParallelCrawler.run_1x1_monitor() : mesma execução, mas monitorando o tempo da etapa assincrona usando :timer.tc

O Fluxo de execução será: 

- 1) Obter o body da Url Principal - Sincrono

- 2) Encontrar dentro do Body, a url de cada receita de smoothies

- 3) Passar o resultado para o módulo Mediator

- 4) Iterar cada Url recebida, criando um novo processo para cada item e envio da mensagem contendo as informações da url para processamento

- 6) Finalizar a criação do fluxo e aguardar o termino de execução de cada processo.

- 7) A cada retorno, o resultando contendo o Nome, Ingredientes e Instruções de preparo serão enviados para o ResultStore, um Agent responsável por armazenar os dados processados.


### Observações

- Utilize  `:observer.start` para monitorar a execução dos processos, consumo de recurso e tempo de execução do fluxo assincrono.

### Resultados

Assim que cada processo finaliza a chamada de uma URL, ele envia o resultado obtido para um processo Agent supervisionado único chamado ResultStore.

as seguintes funções estão disponiveis:

- 1) `ResultStore.all/0` - Devolve uma lista com todos os itens já processados.

- 2) `ResultStore.clean/0` - Limpa todo o conteudo armazenado no resultStore 

### Insights

Atualmente, ao executar módulo ParallelCrawler para iniciar um processo, estamos apenas utilizando um SintaxSugar para a execução do módulo Web.AllRecipes, responsável pelas chamadas aos links, tratamento do conteudo retornado, etc.

Web.AllRecipes em si, utiliza o Modulo Mediator através das funções Mediator.process/2 e Mediator.process/3, responsável por controlar como os processos serão criados usando o módulo ProcessServer. Ambos os modulos não conhecem os detalhes das chamadas que serão executadas através dos processos. Dessa forma quanto o Mediator é chamado pelo módulo AllRecipes, ele recebe do AllRecipes um parametro que é a função Web.AllRecipes.build_recipe/1, repassada para cada um dos processos a serem criados.

Com esse modelo, os Módulos Mediator e ProcessServer são completamente desacoplados das regras presentes no Web.AllRecipes e, portanto, eles podem ser utilizados para qualquer nova implementação de scraping, bastando para isso criar um novo módulo Seguindo o padrão apresentado no AllRecipes

Os únicos requisitos para isso são:

- 1) Fazer a chamada para as funções &Mediator.process/2 (resonsável por criar um processo para cada URL a ser processada) ou &Mediator.process/3 ( Responsável por distribuir as urls em um pool de processos criados a partir do parametro quantidade da função &Mediator.process/3)

- 2) Mas funções Mediator.process/2 e Mediator.process/3, informar a função de callback que será executada pelos processos criados.


## DOCS

Execute `mix docs` para gerar a documentação no diretório `doc` do projeto

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lab_crawler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lab_crawler, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lab_crawler](https://hexdocs.pm/lab_crawler).

