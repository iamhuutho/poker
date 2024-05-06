# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Newpokers', type: :request do
  describe 'POST /api/v1/newpokers' do
    context "normal testcase" do
      it 'checkRoyalFlush1' do
        post '/api/v1/newpokers', params: {
          cards: [
            'D13 D10 D12 D1 D11'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Straight Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
      end
  
      it 'checkStraightFlush1' do
        post '/api/v1/newpokers', params: {
          cards: [
            'D13 D10 D11 D9 D12'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Straight Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(13)
      end
  
      it 'checkStraightFlush3' do
        post '/api/v1/newpokers', params: {
          cards: [
            'H8 H10 H11 H9 H12'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Straight Flush')
        expect(json[:successes][0][:Debug][:highest]).to eq(12)
      end
  
      it 'checkFourKind1' do
        post '/api/v1/newpokers', params: {
          cards: [
            'H8 C8 D8 S8 H12'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Four Kind')
        expect(json[:successes][0][:Debug][:highest]).to eq(8)
      end
  
      it 'checkFourKind2' do
        post '/api/v1/newpokers', params: {
          cards: [
            'H1 C1 D1 S1 H13'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:successes][0][:Hand]).to eq('Four Kind')
        expect(json[:successes][0][:Debug][:highest]).to eq(14)
      end
  
      it 'checkFullHouse' do
        post '/api/v1/newpokers', params: {
          cards: [
            'H1 C1 D1 S8 H8',
            'D2 C2 S2 D12 S12'
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
            'H1 H3 H9 H11 H6',
            'C2 C6 C7 C9 C13'
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
            'H1 C2 D3 H4 C5',
            'D2 S5 S6 D4 S3',
            'D10 C13 S12 D11 S1'
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
            'H2 C2 D4 H4 C4',
            'D1 C1 S1 D6 S7',
            'D1 C11 S12 D1 S1'
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
            'H2 C2 D4 H4 C9',
            'D1 C1 S6 D6 S13',
            'D13 S13 H3 C3 S8'
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
            'H2 C2 D4 H5 C9',
            'D1 C1 S6 D7 S13',
            'D13 S13 H3 C7 S8'
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
            'H1 C3 D4 H5 C9',
            'D3 S3 S6 D7 S13'
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
            'C1 H1 D4 H5 C9',
            'D1 S1 S6 D7 S13',
            'D13 S13 C6 C7 S8'
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
            'C6 H6 S6 D6 C9',
            'C7 H7 S7 D7 S12',
            'D13 S13 C13 C4 S4'
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
            'C6 H6 S6 D6 C9'
          ]
        }
        expect(response.status == 200)
      end
      it "invalid card" do
        post '/api/v1/newpokers', params: {
          cards: [
            'C6 H6 S6 A6 C9'
          ]
        }
        expect(response.status == 400)
      end
      it "invalid API end point" do
        post '/api/v1/hello', params: {
          cards: [
            'C6 H6 S6 A6 C9'
          ]
        }
        expect(response.status == 404)
      end
    end
    context "exception test cases" do
      it "invalid input" do
        post '/api/v1/newpokers', params: {
          cards: [
            'C6 H6 S6 A6 F9'
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('The card number 4 is invalid: A6.The card number 5 is invalid: F9.')
      end
      it "more or less than 5 cards" do
        post '/api/v1/newpokers', params: {
          cards: [
            'C6 H6 S6 C9',
            'C7 H7 D7 C8 D10 C12',
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('Please enter 5 cards')
        expect(json[:errors][1][:message]).to eq('Please enter 5 cards')
      end
      it "duplicated cards " do
        post '/api/v1/newpokers', params: {
          cards: [
            'C6 H6 D6 C9 C9',
            'C7 H7 D7 H7 H8',
          ]
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:errors][0][:message]).to eq('The card number 5 is duplicated: C9')
        expect(json[:errors][1][:message]).to eq('The card number 4 is duplicated: H7')
      end
      it "invallid format" do
        post '/api/v1/newpokers', params: {
          cards: 10
        }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:message]).to eq('Invallid input format')
      end
    end
  end
end
