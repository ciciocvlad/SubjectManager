defmodule SubjectManagerWeb.Components.CoreComponents.Badge do
  @moduledoc false
  use SubjectManagerWeb, :core_component

  attr :status, :atom, required: true
  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <div class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      get_status(@status),
      @class
    ]}>
      {@status}
    </div>
    """
  end

  defp get_status(:forward), do: "text-red-600 border-red-600"
  defp get_status(:midfielder), do: "text-blue-600 border-blue-600"
  defp get_status(:winger), do: "text-yellow-600 border-yellow-600"
  defp get_status(:defender), do: "text-green-600 border-green-600"
  defp get_status(:goalkeeper), do: "text-purple-600 border-purple-600"
end
