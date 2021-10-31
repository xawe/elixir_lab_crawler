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


## 1- Execução Sincrona - Sequencial

Para executar o processo sequencialmente:

- Smoothixir.start



{50793062,
 [:ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok,
  :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok,
  :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok, :ok,
  :ok, :ok, :ok, ...]}



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

