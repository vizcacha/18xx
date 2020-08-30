# frozen_string_literal: true

require_relative '../base'
require_relative '../auctioner'

module Engine
  module Step
    module G18EU
      class MinorAuction < Base
        include Auctioner
    
        ACTIONS = ["select a minor"].freeze
        POST_SELECTION_ACTIONS = ["open bidding", "pass"].freeze
        AUCTION_ACTIONS = ["bid", "pass"].freeze
        DECLINED_AUCTION_ACTIONS = ["buy", "pass"].freeze

        attr_reader :minors

        def description
          'Auction Minor Companies'
        end

        def setup
          super
          @minors = @game.minors
          @offering = nil
          @auctioning = false
          @active_bidders = []
        end
      
        def available
          @minors
        end

        def actions(entity)
          entity == current_entity ? ACTIONS : []
        end

        def starting_bid(company)
          100
        end

        def active_company_bids
          nil
        end

      end
    end
  end
end
