module Hisho
  class File
    def initialize
      @added_files = {} of String => String
    end

    def add(path : String, content : String)
      @added_files[path] = content
    end

    def add_directory(dir_path : String)
      Dir.glob("#{dir_path}/**/*").each do |file_path|
        next if should_skip?(file_path)
        add(file_path, ::File.read(file_path))
      end
    end

    def remove(path : String)
      @added_files.delete(path)
    end

    def get(path : String) : String?
      @added_files[path]?
    end

    def list : Array(String)
      @added_files.keys
    end

    def clear
      @added_files.clear
    end

    def get_added_files
      @added_files
    end

    private def should_skip?(file_path : String) : Bool
      ::File.directory?(file_path) ||
      file_path.includes?("__pycache__") ||
      file_path.includes?(".git") ||
      file_path.includes?("node_modules")
    end
  end
end
