require "studio_home/crawler/version"

require 'nokogiri'
require 'date'
require 'open-uri'
require 'pp'

module StudioHome
  module Crawler

    class Client
      MINIMUM_SLEEP = 1
      CRAWLER_UA = 'Mozilla/5.0 (Windows NT 6.3; Win64; x64; Trident/7.0; rv:11.0) like Gecko'
      attr_reader :site_url
      def initialize(place, sleep=3)
        @place = place
        @sleep = MINIMUM_SLEEP < sleep ? sleep : MINIMUM_SLEEP
        @site_url = "https://www3.revn.jp/studio-home/?c_type=#{c_type}&date="
      end

      def find_bookable_list(weeks: 4)
        list = []
        date = Date.today
        weeks.times do |i|
          sleep @sleep
          base_date = date + (i * 7)
          url = @site_url + base_date.strftime("%Y-%m-%d")
          pp url
          source = open(url, 'User-Agent' => CRAWLER_UA)
           
          scraper = StudioHome::Crawler::Scraper.new(source)
          list += scraper.find_bookable_list
        end
        list
      end

      private
      
      def c_type
        if @place == '鎌倉雪ノ下' 
          1
        elsif @place == '横須賀西海岸店'
          4
        else
          raise ArgumentError, "bad argument"
        end
      end

    end

    class Scraper
      attr_accessor :schedule
      def initialize(source)
        @schedule = Nokogiri::HTML(source).css('#Schedule')
        @date_time_list = []
      end

      def execute
        7.times do |i|
          num = i + 1
          date = scrape_date(num)
          6.times do |j|
            time_id = j + 1
            value = scrape_value(num, time_id)
            @date_time_list << ReservationDateTime.new(date, time_id, value)
          end
        end
        @date_time_list
      end

      def find_bookable_list
        execute if @date_time_list.length == 0
        list = []
        @date_time_list.each do |datetime|
          list << datetime if datetime.available?
        end
        list
      end

      def scrape_date(num)
        num = num + 1
        date = @schedule.css("tr:nth-child(2) td.Time:nth-child(#{num})")
        strip(date.text)
      end

      def scrape_value(num, time_id)
        value = scrape_value_cell(num, time_id)
        strip(value.text)
      end

      def scrape_link(num, time_id)
        link = scrape_value_cell(num, time_id)
        link.css('a').attr('href').value
      end

      private

      def scrape_value_cell(row, col)
        row = 1 + row
        col = 2 + col
        value = @schedule.css("tr:nth-child(#{col}) td:nth-child(#{row})")
      end
      
      def strip(str)
        str.gsub("\n", "").strip.gsub(" ", "").gsub(" ", "").gsub(" ", "")
      end
    end

    class ReservationDateTime
      attr_accessor :date, :time_id, :value, :link
      
      def initialize(date, time_id, value)
        @date = date
        @time_id = time_id
        @value = value
        @link = link
      end

      def available?
        @value == "○"
      end

      def to_s
        "#{date} #{time}"
      end

      def time
        if @time_id == 1
          "08時30分 ～ 10時30分"
        elsif @time_id == 2
          "10時00分 ～ 12時00分"
        elsif @time_id == 3
          "11時30分 ～ 13時30分"
        elsif @time_id == 4
          "13時00分 ～ 15時00分"
        elsif @time_id == 5
          "14時30分 ～ 16時30分"
        elsif @time_id == 6
          "15時30分 ～ 17時30分"
        end
      end
    end

    class Aa
      def initialize
      end
    end
  end
end
