# frozen_string_literal: true

module Api
  module V1
    class NewpokersController < ApplicationController
      def index
        newpokers = Newpoker.all

        if newpokers.present?
          render json: { status: 200, data: newpokers }, status: :ok
        else
          render json: { status: 400, message: 'No poker hands found' }, status: :not_found
        end
      end

      def create
        cardlist = []
        if params.key?(:message)
          message_from_web = params[:message]
          cardlist = message_from_web.split(',')
        # newpoker = Newpoker.new(cards: cardlist)
        # newpoker.save
        # if newpoker.save
        #     redirect_to('/')
        # end
        else
          cardlist = params[:cards]
        end
        items = []
        cardlist.each do |sublist|
          items << sublist.split(' ')
        end
        success_list = []
        error_list = []
        hash_table = {}
        items.each do |each_hand|
          card_hand = each_hand.join(', ')
          if each_hand.size != 5
            error_list.push({ card: card_hand, message: 'Please enter 5 cards' })
            next
          end
          check = check_valid_card_list(each_hand, hash_table)
          hash_table = check[:updated_hash_table]
          unless check[:status]
            error_list.push({ card: card_hand, message: check[:message] })
            next
          end
          check_hand = check_hand(each_hand)
          success_list.push(x: check_hand, y: each_hand)
        end
        new_success_list = success_list.sort do |a, b|
          point_comparison = b[:x][:point] <=> a[:x][:point]
          highest_comparison = point_comparison.zero? ? b[:x][:highest] <=> a[:x][:highest] : point_comparison
          highest_comparison.zero? ? b[:x][:suit] <=> a[:x][:suit] : highest_comparison
        end
        final_sucess_list = []
        new_success_list.each_with_index do |item, index|
          newitem = {}
          newitem[:Result] = if index.zero?
                               'Win'
                             else
                               'Lose'
                             end
          outputMapping = {
            10 => 'Straight Flush',
            9 => 'Straight Flush',
            8 => 'Four Kind',
            7 => 'Full House',
            6 => 'Flush',
            5 => 'Straight',
            4 => 'Three Kind',
            3 => 'Two Pair',
            2 => 'One Pair',
            1 => 'High Card'
          }
          newitem[:Hand] = outputMapping[item[:x][:point]]
          newitem[:Card] = item[:y].join(' ')
          newitem[:Debug] = item[:x]
          final_sucess_list.push(newitem)
        end
        if success_list.empty?
          render json: { successes: final_sucess_list, errors: error_list }, status: 400
        else
          render json: { successes: final_sucess_list, errors: error_list }, status: 200
        end
      end

      def check_valid_card_list(cards, hash_table)
        if cards.length != 5
          return { status: false, message: 'Please enter only 5 cards',
                   updated_hash_table: hash_table }
        end

        cards.each_with_index do |card, index|
          unless check_valid_single_card(card)
            return { status: false, message: "The card number #{index + 1} is invalid: #{card}",
                     updated_hash_table: hash_table }
          end
          if hash_table.key?(card)
            return { status: false, updated_hash_table: hash_table,
                     message: "The card number #{index + 1} is duplicated: #{card}" }
          end

          hash_table[card] = 1
        end
        { status: true, updated_hash_table: hash_table }
      end

      def check_valid_single_card(card)
        return false if (card.length < 2) || (card.length > 3)

        if card.length == 3
          num = card[1].to_i * 10 + card[2].to_i
          return false if (num > 13) || (num < 1)
          return false unless %w[H D C S].include?(card[0])
        end
        if card.length == 2
          return false unless (card[1] > '0') && (card[1] <= '9')
          return false unless %w[H D C S].include?(card[0])
        end
        true
      end

      def check_hand(cards)
        cards = cards.map do |card|
          if card.length == 3
            value = card[1] + card[2]
            suit = card[0]

          else
            value = card[1]
            suit = card[0]

          end
          return -1 if (value.to_i > 13) || (value.to_i < 1)
          return -1 unless %w[H D C S].include?(suit)

          { value:, suit: }
        end
        sorted_cards = cards.sort_by { |card| card[:value].to_i }
        return check_straight_flush(sorted_cards) if (check_straight_flush(sorted_cards)[:point]).positive?
        return check_four_kind(sorted_cards) if (check_four_kind(sorted_cards)[:point]).positive?
        return check_full_house(sorted_cards) if (check_full_house(sorted_cards)[:point]).positive?
        return check_flush(sorted_cards) if (check_flush(sorted_cards)[:point]).positive?
        return check_straight(sorted_cards) if (check_straight(sorted_cards)[:point]).positive?
        return check_three_kind(sorted_cards) if (check_three_kind(sorted_cards)[:point]).positive?
        return check_two_Pair(sorted_cards) if (check_two_Pair(sorted_cards)[:point]).positive?
        return check_one_pair(sorted_cards) if (check_one_pair(sorted_cards)[:point]).positive?

        check_high_card(sorted_cards)
      end

      def check_straight_flush(cards)
        if (check_straight(cards)[:point] == 5) && (check_flush(cards)[:point] == 6)
          suit_values = {
            'H' => 4,
            'D' => 3,
            'C' => 2,
            'S' => 1
          }
          if cards[4][:value].to_i < 13
            return { point: 9, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
          end

          return { point: 9, highest: 13, suit: suit_values[cards[4][:suit]] } if cards[0][:value].to_i == 9

          cards[0][:value].to_i
          return { point: 10, highest: 14, suit: suit_values[cards[0][:suit]] }

        end
        { point: 0, highest: 0, suit: 0 }
      end

      def check_four_kind(cards)
        if (cards[1][:value] == cards[2][:value]) && (cards[2][:value] == cards[3][:value]) && (cards[3][:value] == cards[4][:value])
          suit_values = {
            'H' => 4,
            'D' => 3,
            'C' => 2,
            'S' => 1
          }
          return { point: 8, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
        end
        if (cards[0][:value] == cards[1][:value]) && (cards[1][:value] == cards[2][:value]) && (cards[2][:value] == cards[3][:value])
          suit_values = {
            'H' => 4,
            'D' => 3,
            'C' => 2,
            'S' => 1
          }
          return { point: 8, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

          return { point: 8, highest: cards[0][:value].to_i, suit: suit_values[cards[0][:suit]] }
        end
        { point: 0, highest: 0, suit: 0 }
      end

      def check_full_house(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        if (cards[0][:value] == cards[1][:value]) && (cards[1][:value] == cards[2][:value])
          if cards[3][:value] == cards[4][:value]
            return { point: 7, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

            return { point: 7, highest: cards[0][:value].to_i, suit: suit_values[cards[0][:suit]] }
          end
          return { point: 0, highest: 0, suit: 0 }
        end
        if (cards[2][:value] == cards[3][:value]) && (cards[3][:value] == cards[4][:value])
          if cards[0][:value] == cards[1][:value]
            return { point: 7, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
          end

          return { point: 0, highest: 0, suit: 0 }
        end
        { point: 0, highest: 0, suit: 0 }
      end

      def check_flush(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        if (cards[0][:suit] == cards[1][:suit]) && (cards[1][:suit] == cards[2][:suit]) && (cards[2][:suit] == cards[3][:suit]) && (cards[3][:suit] == cards[4][:suit])
          return { point: 6, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

          return { point: 6, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }

        end
        { point: 0, highest: 0, suit: 0 }
      end

      def check_straight(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        if cards[0][:value].to_i == 1
          if (cards[4][:value].to_i == 13) && (cards[1][:value].to_i + 1 == cards[2][:value].to_i) && (cards[2][:value].to_i + 1 == cards[3][:value].to_i) && (cards[3][:value].to_i + 1 == cards[4][:value].to_i)
            return { point: 5, highest: 14, suit: suit_values[cards[0][:suit]] }
          end
          if (cards[0][:value].to_i + 1 == cards[1][:value].to_i) && (cards[1][:value].to_i + 1 == cards[2][:value].to_i) && (cards[2][:value].to_i + 1 == cards[3][:value].to_i) && (cards[3][:value].to_i + 1 == cards[4][:value].to_i)
            return { point: 5, highest: cards[4][:value].to_i, suit: suit_values[cards[0][:suit]] }
          end

          { point: 0, highest: 0, suit: 0 }
        elsif (cards[0][:value].to_i + 1 == cards[1][:value].to_i) && (cards[1][:value].to_i + 1 == cards[2][:value].to_i) && (cards[2][:value].to_i + 1 == cards[3][:value].to_i) && (cards[3][:value].to_i + 1 == cards[4][:value].to_i)
          { point: 5, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
          # 9 10 11 12 13
          # 1 10 11 12 13
        else
          { point: 0, highest: 0, suit: 0 }
        end
      end

      def check_three_kind(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        if (cards[0][:value] == cards[1][:value]) && (cards[1][:value] == cards[2][:value])
          return { point: 4, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

          return { point: 4, highest: cards[0][:value].to_i, suit: suit_values[cards[0][:suit]] }

        end
        if (cards[1][:value] == cards[2][:value]) && (cards[2][:value] == cards[3][:value])
          return { point: 4, highest: cards[1][:value].to_i, suit: suit_values[cards[1][:suit]] }
        end
        if (cards[2][:value] == cards[3][:value]) && (cards[3][:value] == cards[4][:value])
          return { point: 4, highest: cards[2][:value].to_i, suit: suit_values[cards[2][:suit]] }
        end

        { point: 0, highest: 0, suit: 0 }
      end

      def check_two_Pair(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        values = cards.map { |card| card[:value].to_i }.sort
        value_counts = values.group_by(&:itself).transform_values(&:count)
        two_pairs = value_counts.values.count(2) == 2
        if two_pairs
          pair_values = value_counts.select { |_value, count| count == 2 }.keys.sort.reverse
          value_counts.select { |_value, count| count == 1 }.keys.sort.reverse
          card1, card2 = {}
          flag1, = false
          pair_values[0].to_i
          if pair_values[1].to_i == 1
            cards.each do |check|
              if check[:value].to_i == pair_values[1].to_i
                if !flag1
                  card1 = check
                  flag1 = true
                else
                  card2 = check
                end
              end
            end
            if suit_values[card1[:suit]] > suit_values[card2[:suit]]
              return { point: 3, highest: 14, suit: suit_values[card1[:suit]] }
            end

            return { point: 3, highest: 14, suit: suit_values[card2[:suit]] }
          end
          cards.each do |check|
            if check[:value].to_i == pair_values[0].to_i
              if !flag1
                card1 = check
                flag1 = true
              else
                card2 = check
              end
            end
          end
          if suit_values[card1[:suit]] > suit_values[card2[:suit]]
            return { point: 3, highest: pair_values[0].to_i, suit: suit_values[card1[:suit]] }
          end

          { point: 3, highest: pair_values[0].to_i, suit: suit_values[card2[:suit]] }
        else
          { point: 0, highest: 0, second_highest: 0 }
        end
      end

      def check_one_pair(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        values = cards.map { |card| card[:value].to_i }.sort
        value_counts = values.group_by(&:itself).transform_values(&:count)
        one_pairs = value_counts.values.count(2) == 1
        if one_pairs
          pair_values = value_counts.select { |_value, count| count == 2 }.keys.sort.reverse
          value_counts.select { |_value, count| count == 1 }.keys.sort.reverse
          card1, card2 = {}
          flag1, = false
          pair_values[0].to_i
          if pair_values[0].to_i == 1
            cards.each do |check|
              if check[:value].to_i == pair_values[0].to_i
                if !flag1
                  card1 = check
                  flag1 = true
                else
                  card2 = check
                end
              end
            end
            if suit_values[card1[:suit]] > suit_values[card2[:suit]]
              return { point: 2, highest: 14, suit: suit_values[card1[:suit]] }
            end

            return { point: 2, highest: 14, suit: suit_values[card2[:suit]] }
          end
          cards.each do |check|
            if check[:value].to_i == pair_values[0].to_i
              if !flag1
                card1 = check
                flag1 = true
              else
                card2 = check
              end
            end
          end
          if suit_values[card1[:suit]] > suit_values[card2[:suit]]
            return { point: 2, highest: pair_values[0].to_i, suit: suit_values[card1[:suit]] }
          end

          { point: 2, highest: pair_values[0].to_i, suit: suit_values[card2[:suit]] }
        else
          { point: 0, highest: 0, second_highest: 0 }
        end
      end

      def check_high_card(cards)
        suit_values = {
          'H' => 4,
          'D' => 3,
          'C' => 2,
          'S' => 1
        }
        return { point: 1, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

        { point: 1, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
      end

      private

      def newpoker_params; end
    end
  end
end
