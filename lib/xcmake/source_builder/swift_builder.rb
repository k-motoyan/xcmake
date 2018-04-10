require "erb"
require "date"
require "xcmake/helpers/log_helper"

module Xcmake
  class SwiftBuilder
    include Xcmake::LogHelper

    def initialize(template_path=nil)
      template_path = template_path || File.expand_path("../../../templates/default.swift.erb", __dir__)
      log_error!("Template not found: #{template_path}") unless File.exist?(template_path)
      @template = File.read(template_path)
    end

    def build(params={})
      params = params
      ERB.new(@template, nil, "-").result(binding)
    end
  end
end
