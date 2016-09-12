class MyCasController < Devise::CasSessionsController
  skip_before_action :authentifie
end
