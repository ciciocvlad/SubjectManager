defmodule SubjectManager.Utils.FilterSubjects do
  @moduledoc false

  def filter(subjects, name, position) do
    subjects
    |> filter_name(name)
    |> filter_position(position)
  end

  defp filter_name(subjects, ""), do: subjects
  defp filter_name(subjects, name), do: Enum.filter(subjects, fn s -> s.name =~ name end)

  defp filter_position(subjects, ""), do: subjects
  defp filter_position(subjects, position), do: Enum.filter(subjects, &(get_position(position) == &1.position))

  defp get_position("forward"), do: :forward
  defp get_position("midfielder"), do: :midfielder
  defp get_position("winger"), do: :winger
  defp get_position("defender"), do: :defender
  defp get_position("goalkeeper"), do: :goalkeeper
  defp get_position(_), do: ""
end
