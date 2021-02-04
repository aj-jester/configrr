$:.unshift File.join File.dirname(__FILE__), 'configrr'

%w[
cli
config
consul
error
exec
foreman
hosts
log
opts
actions/generate
].each { |m| require m }
