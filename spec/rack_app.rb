class RackApp
  attr_reader :last_value, :store_active

  def call(procedure)
    procedure.call
    [200, {}, ['response']]
  end
end
