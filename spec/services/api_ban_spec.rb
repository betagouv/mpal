describe ApiBan do
  subject { ApiBan.new }

  context ".parse_context" do
    it { expect(subject.send(:parse_context, "75, Île-de-France")).to eq "Île-de-France" }
    it { expect(subject.send(:parse_context, "78, Yvelines, Île-de-France")).to eq "Île-de-France" }
    it { expect(subject.send(:parse_context, "60, Oise, Hauts-de-France (Picardie)")).to eq "Hauts-de-France" }
    it { expect(subject.send(:parse_context, "13, Bouches-du-Rhône, Provence-Alpes-Côte d'Azur")).to eq "Provence-Alpes-Côte d'Azur" }
  end
end
