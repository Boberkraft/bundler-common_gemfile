module ColoredStrings
  refine String do
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end
    def yellow;         "\e[93m#{self}\e[0m" end

    def bg_black;       "\e[40m#{self}\e[0m" end
    def bg_red;         "\e[41m#{self}\e[0m" end
    def bg_green;       "\e[42m#{self}\e[0m" end
    def bg_brown;       "\e[43m#{self}\e[0m" end
    def bg_blue;        "\e[44m#{self}\e[0m" end
    def bg_magenta;     "\e[45m#{self}\e[0m" end
    def bg_cyan;        "\e[46m#{self}\e[0m" end
    def bg_gray;        "\e[47m#{self}\e[0m" end

    def bold;           "\e[1m#{self}\e[22m" end
    def italic;         "\e[3m#{self}\e[23m" end
    def underline;      "\e[4m#{self}\e[24m" end
    def blink;          "\e[5m#{self}\e[25m" end
    def reverse_color;  "\e[7m#{self}\e[27m" end
  end
end

module Bundler
  class CommonGemfile
    using ColoredStrings

    def self.load_other(context)
      evaled = []

      while true
        number_of_evaled = evaled.size
        sources = context.instance_variable_get('@sources').all_sources

        sources.select { |s| s.is_a?(::Bundler::Source::Git) || s.is_a?(::Bundler::Source::Path) }.each do |source|
          source.instance_variable_set('@allow_remote', true) # allow git commands

          gem_path = if source.respond_to?('install_path')
                       source.install_path # remote gem
                     else
                       source.expanded_original_path # local gem
                     end
          source.instance_variable_set('@install_path', nil) # unset

          if !File.exist?(gem_path) && source.is_a?(::Bundler::Source::Git)
            puts "Fetching #{source.name.to_s.green.bold} in search of common-gemfile"
            source.specs
          end

          gemfile_common_path = gem_path.join('Gemfile-common.rb')
          if !evaled.include?(gemfile_common_path) && File.exist?(gemfile_common_path)
            evaled << gemfile_common_path
            STDERR.puts "Loading #{gemfile_common_path.to_s.green.bold}"
            content = File.read(gemfile_common_path)
            $stderr.puts content if ENV['DEBUG_GEMFILE_COMMON']
            context.send(:eval, content)
            $stderr.puts 'ok'.green.bold
          end
        end

        break if evaled.size == number_of_evaled
      end
    end
  end
end
