# frozen_string_literal: true

require_relative 'base'
require_relative 'revenue_center'

module Engine
  module Part
    class Town < Base
      include Part::RevenueCenter

      attr_reader :revenue

      def initialize(revenue)
        @revenue = parse_revenue(revenue)
      end

      def town?
        true
      end
    end
  end
end
