defmodule SubjectManagerWeb.Admin.Subjects do
  use SubjectManagerWeb, :live_view

  import SubjectManagerWeb.Components.CoreComponents.FilterForm
  import SubjectManagerWeb.Components.CoreComponents.Subject

  alias SubjectManager.Subjects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(page_title: "Subjects admin") |> assign(subjects: Subjects.list_subjects)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, socket |> assign(q: Map.get(params, "q", "")) |> assign(position: Map.get(params, "position", "")) |> assign(sort_by: Map.get(params, "sort_by", "")) |> assign(form: to_form(params))}
  end

  @impl true
  def handle_event("validate", %{"q" => q, "position" => position, "sort_by" => sort_by}, socket) do
      {:noreply,
     push_patch(socket, to: ~p"/subjects?q=#{q}&position=#{position}&sort_by=#{sort_by}")}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/admin/subjects/#{id}/edit")}
  end

  @impl true
  def handle_event("delete", %{"id" => _id}, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <.filter_form form={@form} />

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters
        </div>
        <.subject :for={subject <- filter_subjects(@subjects, @q, @position, @sort_by)} subject={subject} dom_id={"subject-#{subject.id}"} can_change?={true} />
      </div>
    </div>
    """
  end

    defp filter_subjects(subjects, name, position, sort_by) do
    subjects
    |> filter_name(name)
    |> filter_position(position)
    |> sort(sort_by)
  end

  defp filter_name(subjects, ""), do: subjects
  defp filter_name(subjects, name), do: Enum.filter(subjects, fn s -> s.name =~ name end)

  defp filter_position(subjects, ""), do: subjects

  defp filter_position(subjects, position),
    do: Enum.filter(subjects, &(get_position(position) == &1.position))

  defp get_position("forward"), do: :forward
  defp get_position("midfielder"), do: :midfielder
  defp get_position("winger"), do: :winger
  defp get_position("defender"), do: :defender
  defp get_position("goalkeeper"), do: :goalkeeper
  defp get_position(_), do: ""

  defp sort(subjects, ""), do: subjects
  defp sort(subjects, sort_by), do: Enum.sort(subjects, &sort_fun(&1, &2, sort_by))

  defp sort_fun(a, b, "name"), do: a.name <= b.name
  defp sort_fun(a, b, "position"), do: a.position <= b.position
  defp sort_fun(a, b, "team"), do: sort_team(a.team, b.team)

  defp sort_team("Retired", _), do: false
  defp sort_team(_, "Retired"), do: true
  defp sort_team(a, b), do: a <= b
end
