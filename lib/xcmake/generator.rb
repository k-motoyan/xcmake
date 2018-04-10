require "fileutils"
require "pathname"
require "xcodeproj"
require "xcmake/helpers/log_helper"
require "xcmake/helpers/xcodeproj_helper"

module Xcmake
  class Generator
    include Xcmake::LogHelper
    include Xcmake::XcodeprojHelper

    def initialize(project_path)
      @project = Xcodeproj::Project.open(project_path)
    end

    def create_target(name, type, platform=:ios, lang=:swift)
      find_target_with_path(name).tap do |target|
        unless target.nil?
          log_info("Target\t'#{name}' already exists.")
          return
        end
      end

      target = @project.new_target(type, name, platform, nil, nil, lang)

      create_group(name)
      create_source(
        File.join(name, "Info.plist"),
        File.expand_path("../../templates/default.plist.erb", __dir__)
      )

      @project.main_group.find_subpath(name).tap do |group|
        target.add_file_references(group.files)
        target.build_configuration_list.set_setting("INFOPLIST_FILE", "$(SRCROOT)/#{name}/Info.plist")
      end

      log_info("Target\t'#{name}' created!!")
      @project.save
    end

    def delete_target(name)
      log_info("`delete_target` now working...")
    end

    def create_group(name)
      group_dir_path = File.join(project_root, name)

      if group_paths.map(&:to_s).include?(group_dir_path)
        log_info("Group\t'#{name}' already exists.")
        return
      end

      groups = name.split("/")
      base_path = File.join(project_root, @project.main_group.path.to_s)
      create_group_recursive(groups, @project.main_group, base_path)

      FileUtils.mkdir_p(group_dir_path)

      log_info("Group\t'#{name}' created!!")
      @project.save
    end

    def delete_group(name)
      delete_group_recursive(name)
      @project.save
    end

    def create_source(name, template=nil)
      dir_path = File.dirname(name)
      file_name = File.basename(name)

      group = find_group_with_path(dir_path).tap do |r|
        if r.nil?
          log_error!("group path not found. please set NAME to [GROUP_PATH]/[FILE_NAME] and try it!")
        end
      end

      File.join(group.real_path, file_name).tap do |file_path|
        if File.exist?(file_path)
          log_info("Source\t'#{name}' already exists.")
          return
        end
      end

      file_ref = group.new_file(file_name)

      find_target_with_path(dir_path).tap { |r| r&.add_file_references([file_ref]) }

      file_path = file_ref.real_path
      file_ext = File.extname(file_path)

      data =
        case file_ext
        when ".swift" then
          params = parameter_for_swift(file_name, dir_path.split("/").first)
          SwiftBuilder.new(template).build(params)
        when ".plist" then
          params = parameter_for_plist(:framework)
          PlistBuilder.new(template).build(params)
        else
          log_error!("File type `#{file_ext}` is not supported.")
        end

      File.write(file_path, data)

      log_info("Source\t'#{name}' created!!")
      @project.save
    end

    private

    def create_group_recursive(groups, parent_group, path)
      new_group_name = groups.shift
      new_group_path = File.join(path, new_group_name)

      next_group = parent_group.children.find { |g| g.path == new_group_name }

      if next_group.nil?
        next_group = parent_group.new_group(new_group_name, new_group_path)
      end

      if !groups.empty?
        create_group_recursive(groups, next_group, new_group_path)
      end
    end

    def delete_group_recursive(path, main_target=true)
      return if is_target_path?(path)

      target_group = @project.main_group.find_subpath(path)

      return if target_group.nil?

      if main_target || target_group.children.empty?
        FileUtils.rm_rf(target_group.real_path)
        target_group.parent.clear
        log_info("Removed group: #{path}")
      end

      next_path = Pathname.new(path).dirname.to_s
      delete_group_recursive(next_path, false)
    end

    def parameter_for_swift(name, target, organaizer=nil)
      { name: name, target: target, organizer: organaizer }
    end

    def parameter_for_plist(type)
      { type: type }
    end
  end
end
