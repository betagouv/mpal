class AgentsProjet < ActiveRecord::Base
  belongs_to :agent
  belongs_to :projet
end

