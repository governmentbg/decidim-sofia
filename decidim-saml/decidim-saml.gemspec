require_relative "lib/decidim/saml/version"

Gem::Specification.new do |spec|
  spec.name        = "decidim-saml"
  spec.version     = Decidim::Saml::VERSION
  spec.authors     = [""]
  spec.email       = [""]
  spec.homepage    = "http://google.com"
  spec.summary     = "Summary of Decidim::Saml."
  # spec.description = "TODO: Description of Decidim::Saml."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.7", ">= 6.1.7.6"
  spec.add_dependency "devise"
  spec.add_dependency "omniauth-saml"
  spec.add_dependency "egn"
end
