defmodule SubjectManager.FiltersTest do
  @moduledoc """
  Module to test filters and sort for subjects
  """
  use SubjectManager.DataCase

  import SubjectManager.Factories.SubjectFactory
  import SubjectManager.Utils.FilterSubjects, only: [filter: 3]
  import SubjectManager.Utils.SortSubjects, only: [sort: 2]

  describe "filter and sort subjects" do
    setup do
      subjects = list_subjects(10)
      reset_subject_sequence()
      %{subjects: subjects}
    end

    test "filter subjects", %{subjects: subjects} do
      assert filter(subjects, "name1", "") == [Enum.at(subjects, 1)]
      assert filter(subjects, "", "forward") == Enum.take_every(subjects, 2)

      assert filter(subjects, "name", "goalkeeper") ==
               subjects |> Enum.drop(1) |> Enum.take_every(2)
    end

    test "sort subjects", %{subjects: subjects} do
      forwards = filter(subjects, "", "forward")
      goalkeepers = filter(subjects, "", "goalkeeper")

      inter = Enum.take_every(subjects, 2)
      boca = subjects |> Enum.drop(1) |> Enum.take_every(2)

      assert subjects |> Enum.shuffle() |> sort("name") == subjects
      assert sort(subjects, "position") == forwards ++ goalkeepers
      assert sort(subjects, "team") == boca ++ inter
    end
  end
end
