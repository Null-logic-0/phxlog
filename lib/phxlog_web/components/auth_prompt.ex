defmodule PhxlogWeb.Components.AuthPrompt do
  use PhxlogWeb, :html

  def auth_prompt(assigns) do
    ~H"""
    <div
      :if={!@current_scope}
      class="rounded-box border border-base-300 bg-base-200 p-6 text-center"
    >
      <.icon
        name="hero-chat-bubble-left-ellipsis"
        class="size-8 text-base-content/30 mx-auto mb-2"
      />
      <p class="text-sm text-base-content/60">
        <.link navigate={~p"/users/log-in"} class="font-semibold text-primary hover:underline">
          Log in
        </.link>
        to join the conversation
      </p>
    </div>
    """
  end
end
