defmodule Anoma.Client.Examples.EProve do
  @moduledoc """
  I contain functions that test and showcase the Runer module.

  I test and run nock programs and verify their outputs.
  """
  alias Anoma.Client.Runner
  alias Anoma.Tables
  alias Anoma.Node.Transaction.Storage, as: NodeStorage

  require ExUnit.Assertions
  import ExUnit.Assertions

  @doc """
  I run the Juvix program "DivByZero" using the prove function.

  This program fails to run.
  """
  @spec run_div_by_zero() :: {Noun.t(), [binary()]}
  def run_div_by_zero() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/DivByZero.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    assert {:error, :failed_to_prove, {:jet_failed, {:div, _}}, []} =
             Runner.prove(program, [])

    {program, []}
  end

  @doc """
  I run the Juvix program "DivByZero" using the prove function.

  This program returns traces before failing and these traces should be returned.
  """
  @spec run_div_by_zero_with_trace() :: {Noun.t(), [binary()]}
  def run_div_by_zero_with_trace() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/DivByZeroTrace.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    assert {:error, :failed_to_prove, :instruction_match_error, ["A"]} =
             Runner.prove(program, [])

    {program, ["A"]}
  end

  @doc """
  I run the Juvix program "Squared" using the prove function.
  """
  @spec prove_squared() :: Noun.t()
  def prove_squared() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/Squared.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    inputs =
      Enum.map(["3"], &Noun.Format.parse_always/1)

    {:ok, result, _stdio} = Runner.prove(program, inputs)

    assert Noun.equal?(result, 9)

    program
  end

  @spec squared_without_arguments() :: Noun.t()
  def squared_without_arguments() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/Squared.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    inputs = []

    {:ok, result, _stdio} = Runner.prove(program, inputs)

    assert Noun.equal?(result, 0)

    program
  end

  @spec prove_squared_small() :: Noun.t()
  def prove_squared_small() do
    # jammed base64 encoded square function that takes in one parameter
    {:ok, program} =
      square_endpoint_call()
      |> Base.decode64!()
      |> Noun.Jam.cue()

    inputs = Enum.map(["3"], &Noun.Format.parse_always/1)
    {:ok, result, _stdio} = Runner.prove(program, inputs)

    assert Noun.equal?(result, 9)

    program
  end

  @spec prove_with_hints() :: Noun.t()
  def prove_with_hints() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/Tracing.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    inputs = []

    {:ok, result, stdio} = Runner.prove(program, inputs)

    assert Noun.equal?(result, [])
    assert Noun.equal?(stdio, [1, 4, 2, 4])

    program
  end

  @spec prove_with_hint() :: Noun.t()
  def prove_with_hint() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/Identity.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    inputs =
      Enum.map(["3"], &Noun.Format.parse_always/1)

    {:ok, result, stdio} = Runner.prove(program, inputs)

    assert Noun.equal?(result, 3)
    assert Noun.equal?(stdio, ["abc"])

    program
  end

  @spec prove_with_cell_hint() :: Noun.t()
  def prove_with_cell_hint() do
    {:ok, program} =
      :code.priv_dir(:anoma_client)
      |> Path.join("test_juvix/CellHint.nockma")
      |> File.read!()
      |> Noun.Jam.cue()

    inputs =
      Enum.map(["3"], &Noun.Format.parse_always/1)

    {:ok, result, stdio} = Runner.prove(program, inputs)

    assert Noun.equal?(result, [1, 2])

    assert Noun.equal?(stdio, [1, [], [], [1], 1, [1, 2]])

    program
  end

  def prove_with_scry(client \\ Anoma.Client.Examples.EClient.setup()) do
    :ok = Tables.reset_tables_for_client()

    Anoma.Client.subscribe("*")

    val = MapSet.new(["i am a set"])
    key = ["anoma", "blob", "key"]

    NodeStorage.write(
      client.node.node_id,
      {1, [{key, val}]}
    )

    program = [[12, [1], 1 | ["id" | key]]]
    {:ok, result, _stdio} = Runner.prove(program, [])

    noun_value = Noun.Nounable.to_noun(val)

    assert Noun.equal?(noun_value, result)

    :ok
  end

  @spec square_endpoint_call() :: binary()
  defp square_endpoint_call() do
    layer_depth = (Nock.Lib.stdlib_layers() + 2) |> Noun.index_to_offset()

    "[[8 [9 4 0 #{layer_depth}] 9 2 10 [6 [0 14] 0 14] 0 2] 0 0]"
    |> Noun.Format.parse_always()
    |> Noun.Jam.jam()
    |> Base.encode64()
  end
end
