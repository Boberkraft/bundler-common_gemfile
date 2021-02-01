module Bundler
  class CommonGemfile
    def self.load_other(context)
      evaled = []

      while true
        number_of_evaled = evaled.size
        sources = context.instance_variable_get('@sources').all_sources
        sources.select { |s| s.is_a?(Bundler::Source::Git) || s.is_a?(Bundler::Source::Path) }.each do |source|

          source.instance_variable_set('@allow_cached', true)
          gem_path = if source.respond_to?('install_path')
                       source.install_path
                     else
                       source.expanded_original_path
                     end

          gemfile_common_path = gem_path.join('Gemfile-common.rb')

          if !File.exist?(gem_path) && source.is_a?(Bundler::Source::Git)
            puts "  fetching \e[1m\e[92m#{source.name}\e[0m is search of common-gemfile"
            source.specs
          end
          if !evaled.include?(gemfile_common_path) && File.exist?(gemfile_common_path)
            evaled << gemfile_common_path
            puts "Evaling \e[1m\e[92m#{gemfile_common_path}\e[0m"
            content = File.read(gemfile_common_path)
            puts content if ENV['DEBUG_GEMFILE_COMMOM']
            context.send(:eval, content)
            puts "Evaling \e[1m\e[92m#{'done'}\e[0m"
          end
        end

        break if evaled.size == number_of_evaled
      end
    end
  end
end
