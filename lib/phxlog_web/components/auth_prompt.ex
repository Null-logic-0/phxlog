defmodule PhxlogWeb.Components.AuthPrompt do
  @moduledoc """
  Reusable authentication prompt component.

  Displays a call-to-action encouraging unauthenticated users
  to log in before performing actions such as commenting or liking.
  """

  use PhxlogWeb, :html

  @doc """
  Renders an authentication prompt UI.

  ## Assigns

    * `:current_scope` - current user scope (nil if not logged in)

  ## Behavior

  - Only renders when user is not authenticated (`current_scope == nil`)
  - Provides link to login page

  ## Example

      <.auth_prompt current_scope={@current_scope} />
  """

  attr :current_scope, :any, default: nil

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
