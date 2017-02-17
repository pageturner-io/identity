{:ok, _} = Application.ensure_all_started(:ex_machina)

hivent = Application.get_env(:identity, :hivent)
hivent.start(nil, nil)

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Identity.Repo, :manual)
