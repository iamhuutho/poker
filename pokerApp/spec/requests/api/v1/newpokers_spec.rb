# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Newpokers', type: :request do
  describe 'POST /api/v1/newpokers' do
    context "normal testcase" do
      it 'checkRoyalFlush1' do
        post '/api/v1/newpokers', params: {
          cards: [
            '13D 10D 12D 1D 11D'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Royal Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
      end
  
      it 'checkStraightFlush1' do
        post '/api/v1/newpokers', params: {
          cards: [
            '13D 10D 11D 9D 12D'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Straight Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(13)
      end
  
      it 'checkStraightFlush3' do
        post '/api/v1/newpokers', params: {
          cards: [
            '8H 10H 11H 9H 12H'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Straight Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(12)
      end
  
      it 'checkFourKind1' do
        post '/api/v1/newpokers', params: {
          cards: [
            '8H 8C 8D 8S 12H'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Four Kind')
        expect(json[:successes][0][:Debug][:highest]).to eq(8)
      end
  
      it 'checkFourKind2' do
        post '/api/v1/newpokers', params: {
          cards: [
            '1H 1C 1D 1S 13H'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Four Kind')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
      end
  
      it 'checkFullHouse' do
        post '/api/v1/newpokers', params: {
          cards: [
            '1H 1C 1D 8S 8H',
            '2D 2C 2S 12D 12S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Full House')
        expect(json[:successes][1][:Hand]).to eq('Full House')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
        expect(json[:successes][1][:Debug][:highest]).to eq(2)
      end
  
      it 'checkFlush' do
        post '/api/v1/newpokers', params: {
          cards: [
            '1H 3H 9H 11H 6H',
            '2C 6C 7C 9C 13C'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Flush')
        expect(json[:successes][1][:Hand]).to eq('Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
        expect(json[:successes][1][:Debug][:highest]).to eq(13)
      end
  
      it 'checkStraight' do
        post '/api/v1/newpokers', params: {
          cards: [
            '1H 2C 3D 4H 5C',
            '2D 5S 6S 4D 3S',
            '10D 13C 12S 11D 1S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Straight')
        expect(json[:successes][1][:Hand]).to eq('Straight')
        expect(json[:successes][2][:Hand]).to eq('Straight')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
        expect(json[:successes][1][:Debug][:highest]).to eq(6)
        expect(json[:successes][2][:Debug][:highest]).to eq(5)
      end
  
      it 'checkThreeKind' do
        post '/api/v1/newpokers', params: {
          cards: [
            '2H 2C 4D 4H 4C',
            '1D 1C 1S 6D 7S',
            '1D 11C 12S 1D 1S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Full House')
        expect(json[:successes][1][:Hand]).to eq('Three Kind')
        expect(json[:successes][0][:Debug][:highest]).to eq(4)
        expect(json[:successes][1][:Debug][:highest]).to eq(14)
        expect(json[:errors].length == 1)
      end
  
      it 'checkTwoPair' do
        post '/api/v1/newpokers', params: {
          cards: [
            '2H 2C 4D 4H 9C',
            '1D 1C 6S 6D 13S',
            '13D 13S 3H 3C 8S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Two Pair')
        expect(json[:successes][1][:Hand]).to eq('Two Pair')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
        expect(json[:successes][1][:Debug][:highest]).to eq(4)
        expect(json[:errors].length == 1)
      end
  
      it 'checkOnePair' do
        post '/api/v1/newpokers', params: {
          cards: [
            '2H 2C 4D 5H 9C',
            '1D 1C 6S 7D 13S',
            '13D 13S 3H 7C 8S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('One Pair')
        expect(json[:successes][1][:Hand]).to eq('One Pair')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
        expect(json[:successes][1][:Debug][:highest]).to eq(2)
        expect(json[:errors].length == 1)
      end
    end
    context "complex testcase" do
      it 'TestCase1' do
        post '/api/v1/newpokers', params: {
          cards: [
            '1H 3C 4D 5H 9C',
            '3D 3S 6S 7D 13S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('One Pair')
        expect(json[:successes][1][:Hand]).to eq('High Card')
        expect(json[:successes][0][:Debug][:highest]).to eq(3)
        expect(json[:successes][1][:Debug][:highest]).to eq(14)
        expect(json[:errors].length == 1)
      end
  
      it 'TestCase2' do
        post '/api/v1/newpokers', params: {
          cards: [
            '1C 1H 4D 5H 9C',
            '1D 1S 6S 7D 13S',
            '13D 13S 6C 7C 8S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('One Pair')
        expect(json[:successes][1][:Hand]).to eq('One Pair')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
        expect(json[:successes][1][:Debug][:highest]).to eq(14)
        expect(json[:errors].length == 1)
      end
      it 'TestCase3' do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 6S 9C',
            '7D 7S 7C 7H 12S',
            '13D 13S 13C 4C 4S'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Four Kind')
        expect(json[:successes][1][:Hand]).to eq('Four Kind')
        expect(json[:successes][2][:Hand]).to eq('Full House')
        expect(json[:successes][0][:Debug][:highest]).to eq(7)
        expect(json[:successes][1][:Debug][:highest]).to eq(6)
        expect(json[:successes][2][:Debug][:highest]).to eq(13)
        expect(json[:errors].length == 1)
      end
    end
    context "test response status" do
      it "valid card" do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 6S 9C'
          ]
        }
        expect(response.status == 200)
      end
      it "invalid card" do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 6A 9C'
          ]
        }
        expect(response.status == 400)
      end
      it "invalid API end point" do
        post '/api/v1/hello', params: {
          cards: [
            '6C 6H 6D 6A 9C'
          ]
        }
        expect(response.status == 404)
      end
    end
    context "exception test cases" do
      it "invalid input" do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 6A 9C'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('The card number 4 is invalid: 6A')
      end
      it "more or less than 5 cards" do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 9C',
            '7C 7H 7D 8C 10D 12C',
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('Please enter 5 cards')
        expect(json[:errors][1][:message]).to eq('Please enter 5 cards')
      end
      it "duplicated cards " do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 9C 9C',
            '7C 7H 7D 7H 8H',
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('The card number 5 is duplicated: 9C')
        expect(json[:errors][1][:message]).to eq('The card number 4 is duplicated: 7H')
      end
      it "complex error cases " do
        post '/api/v1/newpokers', params: {
          cards: [
            '6C 6H 6D 9C 9C',
            '6A 10H 11C',
            '6D 10H 11C 1D 1S',
            '7C 7H 7D 7H 8H',
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('The card number 5 is duplicated: 9C')
        expect(json[:errors][1][:message]).to eq('Please enter 5 cards')
        expect(json[:errors][2][:message]).to eq('The card number 1 is duplicated: 6D')
        expect(json[:errors][3][:message]).to eq('The card number 4 is duplicated: 7H')
      end
    end
  end
end
