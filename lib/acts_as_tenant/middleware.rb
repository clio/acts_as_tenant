module ActsAsTenant
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      old_local_tenant = ActsAsTenant.local_tenant
      ActsAsTenant.local_tenant = nil
      @app.call(env)
    ensure
      ActsAsTenant.local_tenant = old_local_tenant
    end
  end
end
