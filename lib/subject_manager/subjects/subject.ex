defmodule SubjectManager.Subjects.Subject do
  use Ecto.Schema

  import Ecto.Changeset

  schema "subjects" do
    field :name, :string
    field :team, :string
    field :position, Ecto.Enum, values: [:forward, :midfielder, :winger, :defender, :goalkeeper]
    field :bio, :string
    field :image_path, :string, default: "/images/placeholder.jpg"

    timestamps(type: :utc_datetime)
  end

  @castable ~w(name team position bio image_path)a

  @doc false
  def changeset(incident \\ %__MODULE__{}, attrs \\ %{}) do
    incident
    |> cast(attrs, @castable)
    |> validate_required(@castable)
    |> validate_length(:name, min: 3)
    |> validate_length(:bio, min: 10)
  end
end
