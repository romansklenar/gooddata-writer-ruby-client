Dir["#{File.dirname(__FILE__)}/core_ext/*.rb"].sort.each do |path|
  require "keboola/core_ext/#{File.basename(path, '.rb')}"
end
