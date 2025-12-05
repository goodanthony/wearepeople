class InfrastructureRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :infrastructure, reading: :infrastructure }
end
