defmodule FirstWeb.ExpenseComponents do
  @moduledoc """
  UI components used to render and interact with expenses in the web interface.
  """
  use Phoenix.Component

  attr :current_scope, :map, required: true

  def dashboard_cards(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid gap-6 sm:grid-cols-1 md:grid-cols-3">
        <!-- Card 1 -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 ">
          <h3 class="  mb-2 text-gray-600">Card One</h3>
          <p class="text-gray-900 font-bold text-lg">
            Welcome {@current_scope.user.email}
          </p>
        </div>
        
    <!-- Card 2 -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 ">
          <h3 class="mb-2 text-gray-600">Outsstanding invoices</h3>
          <p class="text-gray-900 font-bold text-lg">
            0
          </p>
        </div>
        
    <!-- Card 3 -->
        <div class="bg-white rounded-lg border border-gray-200 p-6 ">
          <h3 class="  mb-2 text-gray-600">Revenue</h3>
          <p class="text-gray-900 font-bold text-lg">
            lorem5
          </p>
        </div>
      </div>
    </div>
    """
  end
end
