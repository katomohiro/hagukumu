# -*- encoding: utf-8 -*-
# stub: slack-incoming-webhooks 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "slack-incoming-webhooks".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Shohei Yamasaki".freeze]
  s.bindir = "exe".freeze
  s.date = "2015-09-25"
  s.description = "A simple wrapper for posting to slack.".freeze
  s.email = ["s-yamasaki@pepabo.com".freeze]
  s.homepage = "https://github.com/shoyan/slack-incoming-webhooks".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "A simple wrapper for posting to slack.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    else
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
  end
end
