module Hisho
  class File
    private SKIP_PATTERNS = ["__pycache__", ".git", "node_modules"]

    def initialize
      @added_files = {} of String => String
    end

    def add_file(path : String, content : String)
      @added_files[path] = content
    end

    def add_path(path : String) : Symbol
      return :error unless ::File.file?(path) || Dir.exists?(path)
      ::File.file?(path) ? add_file(path, ::File.read(path)) : add_directory(path)
      :info
    end

    def add_directory(dir_path : String)
        Dir.glob("#{dir_path}/**/*").reject { |f| should_skip?(f) }.each { |f| add_file(f, ::File.read(f)) }
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
      ::File.directory?(file_path) || SKIP_PATTERNS.any? { |pattern| file_path.includes?(pattern) }
    end

  end
end
