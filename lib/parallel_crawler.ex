defmodule ParallelCrawler do
@moduledoc """
Expõe funções de inicialização do Crawler de forma paralela

A execução será dividida em duas etapas

- 1) Processo Sincrono: Executará um get na url principal e tratará o retorno, recuperando as urls de receitas e direcionando
  ao processo Assincrono.

- 2) Processo assincrono: Executará cada uma das urls em um processo exclusivo ou em um pool de processos, armazenando o resultado
  obtido em um Agent ( ResultStore ). Os processos serão eliminados após o tempo decorrido, configurado na variável cfg.timeout

"""

  @doc """
  Função responsável por inicializar o crawler criando um novo processo cara cada url de receita encontrada.

  Ao criar um processo para cada função o tempo de espera para o termino do processamento pode ser reduzido, garantindo o máximo
  de IO ( get das urls ) em paralelo. O principal gargalo pode ser o limite de banda onde o programa está rodando.
  O Consumo de CPU e Memória será elevado, já que o processamendo do resultado poderá serializar um volume considerável de texto
  """
  def run_1x1() do
    Web.AllRecipes.get_smoothies_recipe(&ProcessServer.process/1)
  end

  @doc """
  Função responsável por inicializar o crawler criando um novo processo cara cada url de receita encontrada.

  A função é monitorada com o :timer.tc, retornado assim o tempo para completar o processo sincrono.

  Ao criar um processo para cada função o tempo de espera para o termino do processamento pode ser reduzido, garantindo o máximo
  de IO ( get das urls ) em paralelo. O principal gargalo pode ser o limite de banda onde o programa está rodando.
  O Consumo de CPU e Memória será elevado, já que o processamendo do resultado poderá serializar um volume considerável de texto
  """
  def run_1x1_monitor() do
    :timer.tc(fn -> Web.AllRecipes.get_smoothies_recipe(&ProcessServer.process/1) end)
  end

  @doc """
  Função responsável por inicializar o crawler criando um pool pré determinado de processos, e distribuindo o processamento das
  urls encontradas de forma rotativa

  Parameter:

  - pool_count: define a quantidade de processos a serem criadas para o processamento das urls

  Como o processamenento das receitas precisa serializar o conteudo em string, quando mais processos existirem maior será o
  consumo de memoria e processamento.

  Para balancear o consumo de recursos X uso de banda, podemos usar essa função "esquentando" uma quantidade especifica de
  processos e distribuindo as urls para cada processo.

  Quanto menor a quantidade de processos, menor a quantidade de uso de io ( get das urls ) sendo executada em paralelo.
  EX : Se forem iniciados 5 processos, a aplicação requisitará 5 urls e aguardará o retorno antes de seolicitar mais 5.
  Isso causará menos consumo de recursos e aumentará o tempo de processamento

  Se forem iniciados 40 processos, serão 40 get de urls ao mesmo tempo, consumindo mais recursos para tratar a string de conteudo
  e maximizando o consumo de banda.
  """
  def run_pool(pool_count) do
    Web.AllRecipes.get_smoothies_recipe(pool_count, &ProcessServer.process/2)
  end

  @doc """
  Função responsável por inicializar o crawler criando um pool pré determinado de processos, e distribuindo o processamento das
  urls encontradas de forma rotativa

  A função é monitorada com o :timer.tc, retornado assim o tempo para completar o processo sincrono.

  Parameter:

  - pool_count: define a quantidade de processos a serem criadas para o processamento das urls

  Como o processamenento das receitas precisa serializar o conteudo em string, quando mais processos existirem maior será o
  consumo de memoria e processamento.

  Para balancear o consumo de recursos X uso de banda, podemos usar essa função "esquentando" uma quantidade especifica de
  processos e distribuindo as urls para cada processo.

  Quanto menor a quantidade de processos, menor a quantidade de uso de io ( get das urls ) sendo executada em paralelo.
  EX : Se forem iniciados 5 processos, a aplicação requisitará 5 urls e aguardará o retorno antes de seolicitar mais 5.
  Isso causará menos consumo de recursos e aumentará o tempo de processamento

  Se forem iniciados 40 processos, serão 40 get de urls ao mesmo tempo, consumindo mais recursos para tratar a string de conteudo
  e maximizando o consumo de banda.

  """
  def run_pool_monitor(pool_count) do
    # get_smoothies_recipe(max_process)
    :timer.tc(fn ->
      Web.AllRecipes.get_smoothies_recipe(pool_count, &ProcessServer.process/2)
    end)
  end

end
