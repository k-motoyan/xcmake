require "yaml"
require "thor"
require "xcmake/helpers/log_helper"

module Xcmake
  class Cli < Thor
    include Xcmake::LogHelper

    desc "target [NAME]", "Generate new target."
    method_option :project, aliases: "-p", desc: "Project path. If unspecified, use `*.xcodeproj` in the current directory."
    method_option :type, aliases: "-t", desc: "Target type. Default is 'framework'."
    method_option :delete, aliases: "-d", desc: "Delete target."
    def target(name)
      project_path = options[:project] || default_project!

      g = Xcmake::Generator.new(project_path)

      if options[:delete]
        g.delete_target(name)
      else
        type = options[:type] || "framework"
        g.create_target(name, type.to_sym)
      end
    end

    desc "group [NAME]", "Generate new group."
    method_option :project, aliases: "-p", desc: "Project path. If unspecified, use `*.xcodeproj` in the current directory."
    method_option :delete, aliases: "-d", desc: "Delete group."
    def group(name)
      project_path = options[:project] || default_project!

      g = Xcmake::Generator.new(project_path)

      if options[:delete]
        g.delete_group(name)
      else
        g.create_group(name)
      end
    end

    desc "source [NAME]", "Generate source file."
    method_option :project, aliases: "-p", desc: "Project path. If unspecified, use `*.xcodeproj` in the current directory."
    method_option :delete, aliases: "-d", desc: "Delete source file."
    method_option :template, aliases: "-t", desc: "Custom template file path."
    def source(name)
      project_path = options[:project] || default_project!

      g = Xcmake::Generator.new(project_path)

      if options[:delete]
      else
        g.create_source(name, options[:template])
      end
    end

    desc "scaffold [NAME]", "Generate scaffold files."
    method_option :project, aliases: "-p", desc: "Project path. If unspecified, use `*.xcodeproj` in the current directory."
    def scaffold(name)
      project_path = options[:project] || default_project!

      g = Xcmake::Generator.new(project_path)

      structure = load_scaffold_structure(project_path)

      structure["sources"].each do |s|
        if s["target"]["name"] == s["group"]
          group_path = s["target"]["name"]
        elsif s["group"].to_s.empty?
          group_path = s["target"]["name"]
        else
          group_path = "#{s["target"]["name"]}/#{s["group"]}"
        end

        g.create_target(s["target"]["name"], s["target"]["type"].to_sym)
        g.create_group(group_path) unless s["group"].to_s.empty?
        g.create_source("#{group_path}/#{s['prefix']}#{name}#{s['suffix']}", nil)
      end
    end

    private

    def default_project!
      project_paths = Dir.glob("#{Dir.pwd}/*.xcodeproj")

      if project_paths.empty?
        log_error!("xcodeproj not found. please give option `-p [project path]` and try it.")
      end

      if project_paths.size > 1
        log_error!("found many xcodeproj. please give option `-p [project path]` and try it.")
      end

      project_paths.first
    end

    def load_scaffold_structure(project_path, scaffold_config_file="scaffold.yml")
      scaffold_path = File.join(project_path, "..", scaffold_config_file)
      yaml_data = File.read(scaffold_path)
      YAML.load(yaml_data)
    end
  end
end
