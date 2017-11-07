class FakeRodResponse < RodResponse
  alias pris pris_eie

  def initialize(projet, type)
    case type.to_sym
    when :scheduled_operation
      @pris        = FactoryGirl.create(:pris)
      @instructeur = FactoryGirl.create(:instructeur)
      @operateurs  = [FactoryGirl.create(:operateur)]
      @operations  = [FactoryGirl.create(:operation, code_opal: rand(0..1000))]
    when :false
      @pris        = FactoryGirl.create(:pris)
      @instructeur = FactoryGirl.create(:instructeur)
      @operateurs  = []
      @operations  = []
    end
  end
end
