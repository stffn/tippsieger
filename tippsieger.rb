# encoding: UTF-8
require "time"
require "net/http"
require "./config"
require "../seriensieger/bot_liga_guesser.rb"

TEAM_MAPPING = {
  "1. FC K'lautern" => "1. FC Kaiserslautern", 
  "1899 Hoffenheim" => "TSG 1899 Hoffenheim",
  "Bay. Leverkusen" => "Bayer Leverkusen",
  "Bayern München" => "FC Bayern München",
  "Bor. Dortmund" => "Borussia Dortmund",
  "Bor. M'gladbach" => "Bor. Mönchengladbach",
  "FC Augsburg" => "FC Augsburg",
  "FSV Mainz 05" => "1. FSV Mainz 05"
}

class Tippsieger < BotLigaGuesser
  attr_accessor :odds

  def initialize
    @odds = {}
  end

  def load_odds
    http = Net::HTTP.new(ODDS_HOST, 443)
    http.use_ssl = true
    store = OpenSSL::X509::Store.new
    store.set_default_paths
    http.cert_store = store
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.verify_depth = 5

    response = http.get ODDS_PATH
    if response.is_a?(Net::HTTPSuccess)
      data = response.body.force_encoding("iso-8859-1").encode("UTF-8")
      @odds = data.split("\n").select {|l| l =~ /^arrGame/}.
          map {|l| l.split('","')}.
          map {|ld| [ld[1][0,8]] + ld[2..7]}.
          select {|ld| ld[1] == "1.BL"}.
          each_with_object({}) {|ld, hash| hash[[TEAM_MAPPING[ld[2]] || ld[2], TEAM_MAPPING[ld[3]] || ld[3], ld[0]]] = [ld[4].to_f, ld[5].to_f, ld[6].to_f]}
    else
      raise "Could not retrieve odds: %{msg}" % {msg: response}
    end
  end

  def generate_guess (match_id)
    name_team1 = by_match_id[match_id][:name_team1]
    name_team2 = by_match_id[match_id][:name_team2]
    date_string = by_match_id[match_id][:match_date_time].strftime("%Y%m%d")

    if odds[[name_team1, name_team2, date_string]]
      odds_home, odds_draw, odds_away = odds[[name_team1, name_team2, date_string]]
      if odds_home > odds_draw and odds_away > odds_draw
        num_goals = rand(3).round
        return [num_goals, num_goals]
      else
        difference = ((odds_home - odds_away).abs / 3.0).round + 1
        num_goals = rand(2).round
        return [
          num_goals + (odds_home < odds_away ? difference : 0),
          num_goals + (odds_home > odds_away ? difference : 0),
        ]
      end
    else
      return [2, 1]
    end
  end
end

# vim: ai sw=2 expandtab smarttab ts=2
