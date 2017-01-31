class MyCasController < Devise::CasSessionsController
  skip_before_action :assert_projet_courant
  skip_before_action :authentifie
end
