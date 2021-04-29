require 'bundler'
Bundler.require

class Scrap
  attr_accessor :page, :url_array, :name_array, :email_array, :new_array 

  def initialize
    @page        = Nokogiri::HTML(URI.open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
    @url_array   = []
    @name_array  = []
    @email_array = []  
    @new_array   = []
  end

  def get_townhall_email
    puts "Veuillez patienter chargement en cours ........"
    @url_array.map do |url|
      page = Nokogiri::HTML(URI.open("#{url}"))
      @email_array<< page.xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').text
    end
  end

  def get_townhall_url
    @url_array = @page.xpath('//*[@class="lientxt"]').map {|town| town="https://www.annuaire-des-mairies.com/95/#{town.text.downcase.tr(' ',"-")}.html"}
  end

  def get_townhall_name
    @name_array = @page.xpath('//*[@class="lientxt"]').map {|name| name.text}
  end

  def array_hash_town_mail
    @name_array.size.times {|i| @new_array<<Hash[@name_array[i],@email_array[i]]}
  end
  def save_as_json
    File.open("db/emails.json","w") do |f|
      f.write(@new_array.to_json)
    end
  end
  def save_as_spreadsheet
    session = GoogleDrive::Session.from_config("config.js")
    ws = session.spreadsheet_by_key("1xpnaB5qcjF18AbmcP94b2cRBggHqVHSwUhKmSzTpxos").worksheets[0]
    @new_array.size.times do |i|
      ws[ i+1 , 1 ] = @new_array[i].keys.join
      ws[ i+1 , 2 ] = @new_array[i].values.join
    end
    ws.save
  end
  def save_as_csv
    CSV.open("db/emails.csv", "wb") do |csv|
      @new_array.each {|hash| csv << hash.flatten}
    end
  end
  def perform
    get_townhall_url()
    get_townhall_email()
    get_townhall_name()
    array_hash_town_mail()
    save_as_json()
    save_as_csv()
    # save_as_spreadsheet()
  end
end
