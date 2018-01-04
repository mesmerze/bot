class VersionCheck < OkComputer::Check
  def check
    FatFreeCRM::Application::VERSION
  end
  alias to_text check
end

OkComputer::Registry.register 'version', VersionCheck.new
OkComputer.mount_at = 'health'
OkComputer.require_authentication('vesper', 'not4public', except: %w[default])
