# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# guard :rubocop do
#   watch(%r{.+\.rb$})
#   watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
# end

guard :rspec, cmd: 'bundle exec rspec -fd' do
  require 'guard/rspec/dsl'

  Guard::RSpec::Dsl.new(self)

  watch(%r{^spec/.+_spec\.rb$})
  # watch(%r{^spec\/.*?\/(.+_spec\.)yml$}) { |m| "#{m}.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |_m| 'spec/examples/prime_number_spec.rb' }
  # watch(%r{^lib/(.+)\.rb$}) { |_m| 'spec/examples/logic_checker_spec.rb' }
  # watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
end
