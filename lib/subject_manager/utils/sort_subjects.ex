defmodule SubjectManager.Utils.SortSubjects do
  @moduledoc false

  def sort(subjects, ""), do: subjects
  def sort(subjects, sort_by), do: Enum.sort(subjects, &sort_fun(&1, &2, sort_by))

  defp sort_fun(a, b, "name"), do: a.name <= b.name
  defp sort_fun(a, b, "position"), do: a.position <= b.position
  defp sort_fun(a, b, "team"), do: sort_team(a.team, b.team)

  defp sort_team("Retired", _), do: false
  defp sort_team(_, "Retired"), do: true
  defp sort_team(a, b), do: a <= b
end
