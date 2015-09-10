module Twiddler
  class Renderer
    def initialize(template_path, outfile_path)
      @template_path = template_path
      @outfile_path = outfile_path
    end

    def render(locals_hash)
      template = File.read(@template_path)
      template.tap do |rendered|
        locals_hash.each do |key, value|
          rendered.gsub!(/{{#{key}}}/, value[:value].to_s)
        end
      end
    end

    def render_to_file(locals_hash)
      File.write(@outfile_path, render(locals_hash))
    end
  end
end
