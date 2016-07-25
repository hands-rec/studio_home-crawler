require 'spec_helper'
require 'pp'

describe StudioHome::Crawler do
  it 'has a version number' do
    expect(StudioHome::Crawler::VERSION).not_to be nil
  end
end

describe StudioHome::Crawler::Client do
  describe '#find_bookable_list' do
    it 'success' do
#      client = StudioHome::Crawler::Client.new('鎌倉雪ノ下')
#      list = client.find_bookable_list(weeks: 3)
#      pp list
    end
  end

  describe 'initialize' do
    it '鎌倉雪ノ下' do
      client = StudioHome::Crawler::Client.new('鎌倉雪ノ下')
      expect(client.site_url).to match 'c_type=1'
    end
    it '横須賀西海岸店' do
      client = StudioHome::Crawler::Client.new('横須賀西海岸店')
      expect(client.site_url).to match 'c_type=4'
    end
#    it 'bad argument' do
#      client = StudioHome::Crawler::Client.new('')
#    end
  end
end

describe StudioHome::Crawler::Scraper do
  before :each do
    doc = open('./test/studio_home.htm')
    @scraper = StudioHome::Crawler::Scraper.new(doc)
  end

  describe '#initialize' do
    it 'has a schedule' do
      expect(@scraper.schedule.attr('id').value).to eq 'Schedule'
    end
  end

  describe '#scrape_date' do
    it 'first' do
      date = @scraper.scrape_date(1)
      expect(date).to eq '7/13(水)'
    end
  end
  
  describe '#scrape_value' do
    it '予約期間外' do
      value = @scraper.scrape_value(1, 1)
      expect(value).to eq '予約期間外'
    end

    it '定休日' do
      value = @scraper.scrape_value(2, 1)
      expect(value).to eq '<<定休日>>'
    end

    it '×' do
      value = @scraper.scrape_value(3, 1)
      expect(value).to eq '×'
    end

    it '○' do
      value = @scraper.scrape_value(3, 5)
      expect(value).to eq '○'
    end

    it 'empty' do
      value = @scraper.scrape_value(4, 6)
      expect(value).to eq ''
    end
  end

  describe '#scrape_link' do
    it 'exist' do
      link = @scraper.scrape_link(3, 5)
      expect(link).to eq 'https://www3.revn.jp/studio-home/yoyaku/form?f_tid=15407&symbol=E'
    end
  end

  describe '#execute' do
    it 'count' do
      list = @scraper.execute
      expect(list.length).to eq 42 
    end
  end

  describe '#find_bookable_list' do
    before :each do
      @list = @scraper.find_bookable_list
    end

    it 'count' do
      expect(@list.length).to eq 1 
    end

    it 'content' do
      expect(@list.first.date).to eq '7/15(金)'
    end
  end
end

describe StudioHome::Crawler::ReservationDateTime do
  describe '#available?' do
    it 'false' do
      datetime = StudioHome::Crawler::ReservationDateTime.new(nil, nil, '予約期間外')
      expect(datetime.available?).to be false
    end
    it 'true' do
      datetime = StudioHome::Crawler::ReservationDateTime.new(nil, nil, '○')
      expect(datetime.available?).to be true
    end
  end

  describe '#to_s' do
    it 'exist time_id' do
      datetime = StudioHome::Crawler::ReservationDateTime.new('7/13 (水)', 1, '○')
      expect(datetime.to_s).to eq '7/13 (水) 08時30分 ～ 10時30分'
    end
  end
end
