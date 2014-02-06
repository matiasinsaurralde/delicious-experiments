require 'nokogiri'
require 'pp'

hours, bookmarks = {}, Nokogiri::HTML( File.read( 'bookmarks.html' ) ).css('a').map do |bookmark|
    if bookmark.attr('tags')
      { :timestamp => Time.at( bookmark.attr('add_date').to_i ), :url => bookmark.attr('href'),
        :tags => bookmark.attr('tags').split(','), :title => bookmark.inner_text()
      }
    end
end

bookmarks.each do |bookmark|
  if bookmark
    hour = bookmark[:timestamp].strftime('%H').to_i
    hours[ hour ] = 0 if !hours[ hour ]
    hours[ hour ] += 1
  end
end

hours.each { |hour, n| hours[hour] = ( n/bookmarks.size.to_f*100.0 ).round(2) }
pp hours.sort_by { |hour, n| hour }
