module Twiddler
  class Renderer
    def initialize(template_path)
      @template = File.read(template_path)
    end

    def render(locals_hash)
      @template.dup.tap do |rendered|
        locals_hash.each do |key, value|
          rendered.gsub!(/{{#{key}}}/, value.to_s)
        end
      end
    end

    def render_to_file(locals_hash, filepath)
      File.write(filepath, render(locals_hash))
    end
  end
end
