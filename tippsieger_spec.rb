require "./tippsieger"
require "time"

def a_match (options = {})
  {
    match_is_finished: false,
    group_id: 1,
    id_team1: 1,
    id_team2: 2,
    league_id: 1,
    name_team1: "Team 1",
    name_team2: "Team 2",
    match_date_time:"2012-01-30T17:30:00+00:00",
  }.merge(options)
end

def finished_match (options = {})
  a_match({
    match_is_finished: true,
    points_team1: 1,
    points_team2: 0,
    match_date_time: "2011-01-30T17:30:00+00:00",
  }.merge(options))
end

def match_data (data)
  cnt = 0
  data.map do |match|
    cnt += 1
    {match_id: cnt}.merge(match)
  end
end

RSpec.configure do |config|
  config.mock_framework = :rspec
end

describe Tippsieger do
  describe "#generate_guess" do
    it "returns 2:1 on first game" do
      sieger = Tippsieger.new
      sieger.match_data = match_data([a_match])
      sieger.generate_guess(sieger.match_data.first[:match_id]).should == [2, 1]
    end

    it "returns draw on [2.0, 1.2, 2.0]" do
      sieger = Tippsieger.new
      sieger.odds[[a_match[:name_team1], a_match[:name_team2], "20120130"]] = [2.0, 1.2, 2.0]
      sieger.match_data = match_data([a_match])
      guess = sieger.generate_guess(sieger.match_data.first[:match_id])
      guess[0].should == guess[1]
    end
  end

  describe "#load_odds" do
    it "sends a load request to odds source and updates odds data" do
      sieger = Tippsieger.new
      #mock_loader = double('loader')
      #mock_loader.should_receive(:get).with(2010).and_return([{match_id: 1}])
      #sieger.load(2010, mock_loader)
      #sieger.match_data.length.should == 1
    end
  end
end

# vim: ai sw=2 expandtab smarttab ts=2
