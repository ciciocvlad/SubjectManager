defmodule SubjectManager.Subjects do
  alias SubjectManager.Subjects.Subject
  alias SubjectManager.Repo

  import Ecto.Query, warn: false

  def list_subjects do
    Repo.all(Subject)
  end

  def get_by_id(id) do
    from(subject in Subject, as: :subject)
    |> where([subject: subject], subject.id == ^id)
    |> Repo.one()
  end
end
