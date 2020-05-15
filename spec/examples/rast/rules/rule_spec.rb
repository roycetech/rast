require './lib/rast'
require './lib/rast/rules/rule'

# rast Rule do
#   spec '#initialize' do
#     variables(duped: [
#       { true: '' }, # Good
#       {} # Bad
#     ])

#     prepare do |params|
#       allow(subject).to receive(:instance_method) { params }
#     end

#     execute do |duped|
#       params = if duped
#       subject.spec_name
#     end
#   end
# end
