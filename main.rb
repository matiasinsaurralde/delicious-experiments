require 'nokogiri'
require 'pp'

hours = {}

c = 0

bookmarks = Nokogiri::HTML( File.read( 'bookmarks.html' ) ).css('a')

bookmarks.each do |bookmark|

  timestamp = Time.at( bookmark.attr('add_date').to_i )
  hour = timestamp.strftime('%H').to_i

  hours.store( hour, 0 ) if !hours[hour]
  hours[ hour ] += 1

end

hours.each { |hour, n| hours[hour] = ( n/bookmarks.size.to_f*100.0 ).round(2) }
pp hours.sort_by { |hour, n| hour }
