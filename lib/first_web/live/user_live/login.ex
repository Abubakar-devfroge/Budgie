defmodule FirstWeb.UserLive.Login do
  use FirstWeb, :live_view

  alias First.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Log in</p>
            <:subtitle>
              <%= if @current_scope do %>
                You need to reauthenticate to perform sensitive actions on your account.
              <% else %>
                Don't have an account? <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-brand hover:underline"
                  phx-no-format
                >Sign up</.link> for an account now.
              <% end %>
            </:subtitle>
          </.header>
        </div>

        <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="size-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <%!-- <.form
          :let={f}
          for={@form}
          id="login_form_magic"
          action={~p"/users/log-in"}
          phx-submit="submit_magic"
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="email"
            required
            phx-mounted={JS.focus()}
          />
          <.button  class="py-2 rounded-md bg-gray-900 text-white w-full">
            Log in with email <span aria-hidden="true">→</span>
          </.button>
        </.form> --%>

        <%!-- <div class="divider">or</div> --%>

        <.form
          :let={f}
          for={@form}
          id="login_form_password"
          action={~p"/users/log-in"}
          phx-submit="submit_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            readonly={!!@current_scope}
            field={f[:email]}
            type="email"
            label="Email*"
            autocomplete="email"
            required
          />
          <.input
            field={@form[:password]}
            type="password"
            label="Password*"
            autocomplete="current-password"
          />

                  <div class="flex flex-col gap-4 w-full">
          <.button
            class="font-medium bg-black text-white rounded-full px-6 py-2 hover:bg-gray-800 transition w-full sm:w-auto flex-1 text-center"
            name={@form[:remember_me].name}
            value="true"
          >
            Log in  <span aria-hidden="true">→</span>
          </.button>

          <%!-- <.button
            class="font-medium bg-white text-black border border-gray-300 rounded-md px-4 py-2 hover:bg-gray-100 transition w-full sm:w-auto flex-1 text-center"
          >
            Log in only this time
          </.button> --%>
        </div>

        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:first, First.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
