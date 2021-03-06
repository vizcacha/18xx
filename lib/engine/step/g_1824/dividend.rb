# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G1824
      class Dividend < Dividend
        def actions(entity)
          return [] if minor_style_dividend?(entity)

          super
        end

        def dividend_options(entity)
          mine_revenue = @game.mine_revenue(routes)
          revenue = @game.routes_revenue(routes) - mine_revenue
          dividend_types.map do |type|
            payout = send(type, entity, revenue, mine_revenue)
            payout[:divs_to_corporation] = 0
            [type, payout.merge(share_price_change(entity, payout[:per_share].positive? ? revenue : 0))]
          end.to_h
        end

        def process_dividend(action)
          entity = action.entity
          mine_revenue = @game.mine_revenue(routes)
          revenue = @game.routes_revenue(routes) - mine_revenue
          kind = action.kind.to_sym
          payout = dividend_options(entity)[kind]

          entity.operating_history[[@game.turn, @round.round_num]] = OperatingInfo.new(
            routes,
            action,
            revenue + mine_revenue
          )

          entity.trains.each { |train| train.operated = true }

          @round.routes = []

          log_run_payout(entity, kind, revenue, mine_revenue, action, payout)

          @game.bank.spend(payout[:corporation], entity) if payout[:corporation].positive?

          payout_shares(entity, revenue) if payout[:per_share].positive?

          change_share_price(entity, payout)

          pass!
        end

        def skip!
          return super unless minor_style_dividend?(current_entity)

          revenue = @game.routes_revenue(routes)

          process_dividend(Action::Dividend.new(
            current_entity,
            kind: revenue.positive? ? 'payout' : 'withhold',
          ))
        end

        def share_price_change(entity, revenue = 0)
          return super unless minor_style_dividend?(entity)

          {}
        end

        def withhold(_entity, revenue, mine_revenue)
          { corporation: revenue + mine_revenue, per_share: 0 }
        end

        def payout(entity, revenue, mine_revenue)
          if minor_style_dividend?(entity)
            fifty_percent = revenue / 2
            { corporation: fifty_percent + mine_revenue, per_share: fifty_percent }
          else
            { corporation: mine_revenue, per_share: payout_per_share(entity, revenue) }
          end
        end

        def payout_shares(entity, revenue)
          return super unless entity.minor?

          @log << "#{entity.owner.name} receives #{@game.format_currency(revenue)}"
          @game.bank.spend(revenue, entity.owner)
        end

        private

        def minor_style_dividend?(entity)
          @game.pre_staatsbahn?(entity) || @game.coal_railway?(entity)
        end

        def log_run_payout(entity, kind, revenue, mine_revenue, action, payout)
          unless Dividend::DIVIDEND_TYPES.include?(kind)
            @log << "#{entity.name} runs for #{@game.format_currency(revenue)} and pays #{action.kind}"
          end

          if payout[:per_share].zero? && payout[:corporation].zero?
            @log << "#{entity.name} does not run"
          elsif payout[:per_share].zero?
            @log << "#{entity.name} withholds #{@game.format_currency(revenue)}"
          end
          @log << "#{entity.name} gets mine income of #{@game.format_currency(mine_revenue)}" if mine_revenue.positive?
        end
      end
    end
  end
end
