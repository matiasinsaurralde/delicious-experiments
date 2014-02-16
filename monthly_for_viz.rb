require 'nokogiri'
require 'time'
require 'pp'

OUTPUT_FILE = 'html/data.js'

class Hash
  def fill_empty_hours!( default_value = 0.0 )
    24.times.to_a.each do |hour|
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
  date_str = Time.strptime( month, '%m/%Y' ).strftime('%b_%Y')
  ln = "var #{date_str} = ["
  hours.fill_empty_hours!(0)
  hours = hours.sort_by_hour()
  hours.each do |hour, bookmarks|
    ln += "[#{hour}, #{bookmarks}]"
    if hour != 23
      ln += ', '
    end
  end
  ln += "];"
  open(OUTPUT_FILE, 'a') { |f| f.puts(ln) }
end

open(OUTPUT_FILE, 'a') { |f| f.print( 'var months = [' ) }
months.each do |month, hours|
  open(OUTPUT_FILE, 'a') do |f|
    f.print("#{Time.strptime( month, '%m/%Y' ).strftime('%b_%Y')}")
    if month == months.keys.last
      f.print '];'
    else
      f.print ','
    end
  end
end
