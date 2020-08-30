# frozen_string_literal: true

require_relative '../config/game/g_18_eu'
require_relative 'base'

module Engine
  module Game
    class G18EU < Base
      load_from_json(Config::Game::G18EU::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Europe'
      GAME_RULES_URL = 'http://www.deepthoughtgames.com/games/18EU/Rules.pdf'
      GAME_DESIGNER = 'David Hecht'

      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :operate
      SELL_BUY_ORDER = :sell_buy

      def setup
        @minors.each do |minor|
          train = @depot.upcoming[0]
          minor.buy_train(train, :free)
        end
      end

      def stock_round
        Round::Stock.new(self, [
          Step::BuySellParShares
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G18EU::Dividend,
          Step::BuyTrain,
          Step::IssueShares,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_round
        Round::Auction.new(self, [
          Step::G18EU::MinorAuction
        ])
      end
    end
  end
end
