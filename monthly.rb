require 'nokogiri'
require 'pp'

class Hash
  def fill_empty_hours!( default_value = 0.0 )
    23.times.to_a.each do |hour|
      if !self[ hour ]
        self.store( hour, default_value )
      end
    end
  end
  def sort_by_hour()
    _hash = {}
    self.sort_by { |k,v| k }.each { |i| _hash.store( i[0], i[1] ) }
    return _hash
  end
end

months, bookmarks = {}, Nokogiri::HTML( File.read( 'bookmarks.html' ) ).css('a').map do |bookmark|
    if bookmark.attr('tags')
      { :timestamp => Time.at( bookmark.attr('add_date').to_i ), :url => bookmark.attr('href'),
        :tags => bookmark.attr('tags').split(','), :title => bookmark.inner_text()
      }
    end
end

bookmarks.each do |bookmark|
  if bookmark
    month = bookmark[ :timestamp ].strftime( '%m/%Y' )
    months.store( month, {} ) if !months[ month ]

    hour = bookmark[ :timestamp ].strftime( '%H' ).to_i
    months[ month ].store( hour, 0 ) if !months[ month ][ hour ]
    months[ month ][ hour ] += 1
  end
end

months.each do |month, hours|

  month_total, _hours = hours.values.inject( :+ ), {}

  hours.each { |hour, n| _hours[ hour ] = ( n/month_total.to_f*100.0 ).round(1) }

  _hours.fill_empty_hours!

  puts "-> Month: #{month}, total: #{month_total}"

  pp _hours.sort_by_hour

end
