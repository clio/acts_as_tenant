module ActsAsTenant
  class TenantResetMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      set_current_tenant = ActsAsTenant.current_tenant
      ActsAsTenant.current_tenant = nil
      @app.call(env)
    ensure
      ActsAsTenant.current_tenant = set_current_tenant
    end
  end
end
