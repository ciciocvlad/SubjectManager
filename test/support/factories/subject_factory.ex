defmodule SubjectManager.Factories.SubjectFactory do
  use ExMachina.Ecto, repo: SubjectManager.Repo

  alias SubjectManager.Subjects.Subject

  def subject_factory do
    %Subject{
      id: sequence(:id, &Function.identity/1),
      name: sequence("name"),
      team: sequence(:team, ["Inter Miami CF", "Boca Juniors"]),
      position: sequence(:position, ~w(forward goalkeeper)a),
      bio: sequence(:bio, fn _ -> "This is bio section" end)
    }
  end

  def list_subjects(count) do
    build_list(count, :subject)
  end

  def reset_subject_sequence do
    ExMachina.Sequence.reset()
  end
end
