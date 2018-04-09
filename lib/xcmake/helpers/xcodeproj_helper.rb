module Xcmake
  module XcodeprojHelper
    def project_root
      @project.path.dirname.to_s
    end

    def group_paths
      @project.main_group.recursive_children_groups.map(&:real_path).uniq
    end

    def is_target_path?(path)
      @project.targets.map(&:name).include?(path)
    end

    def find_group_with_path(path)
      @project.main_group.find_subpath(path)
    end

    def find_target_with_path(path)
      target_name = path.split("/").first
      @project.targets.find { |t| t.name == target_name }
    end
  end
end
