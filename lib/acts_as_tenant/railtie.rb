module ActsAsTenant
  class Railtie < ::Rails::Railtie
    initializer 'acts_as_tenant.insert_middleware' do |app|
      puts "hi"
      app.config.middleware.use(
        # RequestStore::Middleware,
        ActsAsTenant::Middleware
      )
    end
  end
end
