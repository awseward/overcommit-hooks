require 'overcommit'

module Overcommit::Hook::PreCommit
  class EatYourDogfood < Base
    def run
      src_hooks = hooks_dirs.map do |dir|
        Dir.chdir dir do
          Dir.glob "**/*.rb"
        end
      end.flatten

      messages = [
        "Source hooks:",
        src_hooks.map{|h| "  #{h}"}.join("\n"),
        "Target dir: #{plugin_dir}",
      ]

      [:warn, messages.join("\n")]
    end

    private

    def plugin_dir
      loaded_plugin_dir = Overcommit::ConfigurationLoader.load_from_file('.overcommit.yml').plugin_directory
      wrong_githooks_workaround loaded_plugin_dir
    end

    # Can get rid of this when this issue is solved
    # https://github.com/brigade/overcommit/pull/234
    def wrong_githooks_workaround(plugin_dir)
      if plugin_dir =~ /.*\.githooks$/
        Dir.exists?(plugin_dir) ? plugin_dir : fix_plugin_dir(plugin_dir)
      else
        plugin_dir
      end
    end

    # Can get rid of this when this issue is solved
    # https://github.com/brigade/overcommit/pull/234
    def fix_plugin_dir(path)
      dir_name = File.dirname(path)
      "#{dir_name}/.git-hooks"
    end

    def hooks_dirs
      config['hooks_dirs'] || ['hooks', 'meta-hooks']
    end
  end
end