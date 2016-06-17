FactoryGirl.define do
  factory 'evenement' do
    projet
    quand { Time.now }
    label 'creation_projet'
  end
end
