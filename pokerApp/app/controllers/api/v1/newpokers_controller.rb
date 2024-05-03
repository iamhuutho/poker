class Api::V1::NewpokersController < ApplicationController
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
    if params.has_key?(:message)
      messageFromWeb = params[:message]
      cardlist = messageFromWeb.split(',')
    # newpoker = Newpoker.new(cards: cardlist)
    # newpoker.save
    # if newpoker.save
    #     redirect_to('/')
    # end
    else
      cardlist = params[:cards]
    end
    items = []
    for sublist in cardlist
      items << sublist.split(' ')
    end
    successList = []
    errorList = []
    hashTable = {}
    for eachHand in items
      cardHand = eachHand.join(', ')
      if eachHand.size != 5
        errorList.push({ card: cardHand, message: 'Please enter 5 cards' })
        next
      end
      check = checkValidCardList(eachHand, hashTable)
      hashTable = check[:updatedHashTable]
      unless check[:status]
        errorList.push({ card: cardHand, message: check[:message] })
        next
      end
      checkHand = check_hand(eachHand)
      successList.push(x: checkHand, y: eachHand)
    end
    newsuccessList = successList.sort do |a, b|
      point_comparison = b[:x][:point] <=> a[:x][:point]
      highest_comparison = point_comparison.zero? ? b[:x][:highest] <=> a[:x][:highest] : point_comparison
      highest_comparison.zero? ? b[:x][:suit] <=> a[:x][:suit] : highest_comparison
    end
    finalSucessList = []
    newsuccessList.each_with_index do |item, index|
      newitem = {}
      newitem[:Result] = if index == 0
                           'Win'
                         else
                           'Lose'
                         end
      outputMapping = {
        10 => 'Royal Flush',
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
      finalSucessList.push(newitem)
    end
    if successList.length == 0
      render json: { successes: finalSucessList, errors: errorList }, status: 400
    else
      render json: { successes: finalSucessList, errors: errorList }, status: 200
    end
  end

  def checkValidCardList(cards, hashTable)
    return { status: false, message: 'Please enter only 5 cards', updatedHashTable: hashTable } if cards.length != 5

    cards.each_with_index do |card, index|
      unless checkValidSingleCard(card)
        return { status: false, message: "The card number #{index + 1} is invalid: #{card}",
                 updatedHashTable: hashTable }
      end
    end
    cards.each_with_index do |card, index|
      if hashTable.has_key?(card)
        return { status: false, updatedHashTable: hashTable,
                 message: "The card number #{index + 1} is duplicated: #{card}" }
      end

      hashTable[card] = 1
    end
    { status: true, updatedHashTable: hashTable }
  end

  def checkValidSingleCard(card)
    return false if card.length < 2 or card.length > 3

    if card.length == 3
      num = card[0].to_i * 10 + card[1].to_i
      return false if num > 13 or num < 1
      return false unless %w[H D C S].include?(card[2])
    end
    if card.length == 2
      return false unless '0' < card[0] and card[0] <= '9'
      return false unless %w[H D C S].include?(card[1])
    end
    true
  end

  def check_hand(cards)
    cards = cards.map do |card|
      if card.length == 3
        value = card[0] + card[1]
        suit = card[2]
        return -1 if value.to_i > 13 or value.to_i < 1
        return -1 unless %w[H D C S].include?(suit)

        { value:, suit: }
      else
        value = card[0]
        suit = card[1]
        return -1 if value.to_i > 13 or value.to_i < 1
        return -1 unless %w[H D C S].include?(suit)

        { value:, suit: }
      end
    end
    sortedCards = cards.sort_by { |card| card[:value].to_i }
    return checkRoyalFlush(sortedCards) if checkRoyalFlush(sortedCards)[:point] > 0
    return checkStraightFlush(sortedCards) if checkStraightFlush(sortedCards)[:point] > 0
    return check4Kind(sortedCards) if check4Kind(sortedCards)[:point] > 0
    return checkFullHouse(sortedCards) if checkFullHouse(sortedCards)[:point] > 0
    return checkFlush(sortedCards) if checkFlush(sortedCards)[:point] > 0
    return checkStraight(sortedCards) if checkStraight(sortedCards)[:point] > 0
    return check3Kind(sortedCards) if check3Kind(sortedCards)[:point] > 0
    return check2Pair(sortedCards) if check2Pair(sortedCards)[:point] > 0
    return check1Pair(sortedCards) if check1Pair(sortedCards)[:point] > 0

    checkHighCard(sortedCards)
  end

  def checkRoyalFlush(cards)
    checkStraightFlush(cards)
  end

  def checkStraightFlush(cards)
    if checkStraight(cards)[:point] == 5 and checkFlush(cards)[:point] == 6
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

  def check4Kind(cards)
    if cards[1][:value] == cards[2][:value] and cards[2][:value] == cards[3][:value] and cards[3][:value] == cards[4][:value]
      suit_values = {
        'H' => 4,
        'D' => 3,
        'C' => 2,
        'S' => 1
      }
      return { point: 8, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
    end
    if cards[0][:value] == cards[1][:value] and cards[1][:value] == cards[2][:value] and cards[2][:value] == cards[3][:value]
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

  def checkFullHouse(cards)
    suit_values = {
      'H' => 4,
      'D' => 3,
      'C' => 2,
      'S' => 1
    }
    if cards[0][:value] == cards[1][:value] and cards[1][:value] == cards[2][:value]
      if cards[3][:value] == cards[4][:value]
        return { point: 7, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

        return { point: 7, highest: cards[0][:value].to_i, suit: suit_values[cards[0][:suit]] }
      end
      return { point: 0, highest: 0, suit: 0 }
    end
    if cards[2][:value] == cards[3][:value] and cards[3][:value] == cards[4][:value]
      if cards[0][:value] == cards[1][:value]
        return { point: 7, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
      end

      return { point: 0, highest: 0, suit: 0 }
    end
    { point: 0, highest: 0, suit: 0 }
  end

  def checkFlush(cards)
    suit_values = {
      'H' => 4,
      'D' => 3,
      'C' => 2,
      'S' => 1
    }
    if cards[0][:suit] == cards[1][:suit] and cards[1][:suit] == cards[2][:suit] and cards[2][:suit] == cards[3][:suit] and cards[3][:suit] == cards[4][:suit]
      return { point: 6, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

      return { point: 6, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }

    end
    { point: 0, highest: 0, suit: 0 }
  end

  def checkStraight(cards)
    suit_values = {
      'H' => 4,
      'D' => 3,
      'C' => 2,
      'S' => 1
    }
    if cards[0][:value].to_i == 1
      if cards[4][:value].to_i == 13 and cards[1][:value].to_i + 1 == cards[2][:value].to_i and cards[2][:value].to_i + 1 == cards[3][:value].to_i and cards[3][:value].to_i + 1 == cards[4][:value].to_i
        return { point: 5, highest: 14, suit: suit_values[cards[0][:suit]] }
      end
      if cards[0][:value].to_i + 1 == cards[1][:value].to_i and cards[1][:value].to_i + 1 == cards[2][:value].to_i and cards[2][:value].to_i + 1 == cards[3][:value].to_i and cards[3][:value].to_i + 1 == cards[4][:value].to_i
        return { point: 5, highest: cards[4][:value].to_i, suit: suit_values[cards[0][:suit]] }
      end

      { point: 0, highest: 0, suit: 0 }
    elsif cards[0][:value].to_i + 1 == cards[1][:value].to_i and cards[1][:value].to_i + 1 == cards[2][:value].to_i and cards[2][:value].to_i + 1 == cards[3][:value].to_i and cards[3][:value].to_i + 1 == cards[4][:value].to_i
      { point: 5, highest: cards[4][:value].to_i, suit: suit_values[cards[4][:suit]] }
      # 9 10 11 12 13
      # 1 10 11 12 13
    else
      { point: 0, highest: 0, suit: 0 }
    end
  end

  def check3Kind(cards)
    suit_values = {
      'H' => 4,
      'D' => 3,
      'C' => 2,
      'S' => 1
    }
    if cards[0][:value] == cards[1][:value] and cards[1][:value] == cards[2][:value]
      return { point: 4, highest: 14, suit: suit_values[cards[0][:suit]] } if cards[0][:value].to_i == 1

      return { point: 4, highest: cards[0][:value].to_i, suit: suit_values[cards[0][:suit]] }

    end
    if cards[1][:value] == cards[2][:value] and cards[2][:value] == cards[3][:value]
      return { point: 4, highest: cards[1][:value].to_i, suit: suit_values[cards[1][:suit]] }
    end
    if cards[2][:value] == cards[3][:value] and cards[3][:value] == cards[4][:value]
      return { point: 4, highest: cards[2][:value].to_i, suit: suit_values[cards[2][:suit]] }
    end

    { point: 0, highest: 0, suit: 0 }
  end

  def check2Pair(cards)
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
      single_values = value_counts.select { |_value, count| count == 1 }.keys.sort.reverse
      card1, card2 = {}
      flag1, flag2 = false
      pillar = pair_values[0].to_i
      if pair_values[1].to_i == 1
        for check in cards
          if check[:value].to_i == pillar = pair_values[1].to_i
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
      for check in cards
        if check[:value].to_i == pillar = pair_values[0].to_i
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

  def check1Pair(cards)
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
      single_values = value_counts.select { |_value, count| count == 1 }.keys.sort.reverse
      card1, card2 = {}
      flag1, flag2 = false
      pillar = pair_values[0].to_i
      if pair_values[0].to_i == 1
        for check in cards
          if check[:value].to_i == pillar = pair_values[0].to_i
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
      for check in cards
        if check[:value].to_i == pillar = pair_values[0].to_i
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

  def checkHighCard(cards)
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
