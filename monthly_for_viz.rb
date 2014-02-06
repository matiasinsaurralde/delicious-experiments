require 'nokogiri'
require 'time'
require 'pp'

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

open( 'out.tsv', 'a' ) { |f| f.print("time\t") }

months.each do |month, hours|
  label = Time.strptime( month, '%m/%Y' ).strftime('%b %Y')
  open('out.tsv', 'a') do |f|
    f.print( label )
    f.print( "\t" ) if months.keys.last != month
  end
end

open( 'out.tsv', 'a' ) { |f| f.print("\n") }

24.times do |n|
  open( 'out.tsv', 'a' ) { |f| f.print( "#{n}\t") }
  col_index = 0
  months.each do |month, hours|

    hours.fill_empty_hours!( 0 )
    hours = hours.sort_by_hour()
    open( 'out.tsv', 'a' ) do |f|
      f.print( hours[ n ] )
      f.print( "\t" ) if col_index < 22
      col_index += 1
    end
  end
  open( 'out.tsv', 'a' ) { |f| f.puts() }
end
