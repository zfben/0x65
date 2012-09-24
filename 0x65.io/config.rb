require "rubygems"
require 'digest/md5'
require "google_drive"

set :haml, :format => :html5
set :sass, :style => :compressed

SESSION = GoogleDrive.login("gurudigger.mail@gmail.com", "password")
WS = SESSION.spreadsheet_by_key("0AhGQsCiSwxabdG5DREZNR1hsczBRaHdCcTEyRUhlX2c").worksheets[0]

configure :build do
  activate :minify_css
end

helpers do
  def get_members

    members = {}
    for row_number in 1..(WS.num_rows - 1)
      row = WS.rows[row_number]
      members[row[1].to_i] = {
        name: row[2],
        say: row[3],
        head: row[4].strip,
        blog: row[5],
        twitter: row[6],
        gurudigger: row[7],
        github: row[8],
      }
    end

    members = members.map do |k, v|
      v = v.inject({}){|memo, (k,v)| memo[k.to_sym] = v; memo}
      [k, v]
    end
    members = Hash[members]

    members = 128.times.map do |ii|
      ss = (ii).to_s(16)
      ss = '0' << ss if ss.length == 1
      ss = '0x' << ss

      id = ii.to_s 2
      id = id.length < 7 ? '0' * (7 - id.length) + id : id

      member = members[ii] || {name: 'Unknown', head: '', say: ''}
      member[:head] ||= ""
      member[:id] = id
      member[:display_id] = ss
      member[:head] = Digest::MD5.hexdigest member[:head] if member[:head].include? '@'

      contact = member.reject{ |k, v| [:name, :head, :say].include? k}.reject{ |k, v| v.strip.empty? }
      member[:contact] = contact.map{ |k, v|
        v = v.to_s
        case k
        when :twitter
          v.slice!(0) if v[0] == '@'
          href = 'http://twitter.com/' + v
          title = '@' + v
        when :sina
          v.slice!(0) if v[0] == '@'
          href = 'http://weibo.com/' + v
          title = '@' + v
        when :gurudigger
          href = 'http://gurudigger.com/users/' + v
          title = member['name']
        when :blog
          v.downcase!
          href = v
          href = 'http://' + href unless href.start_with?('http')
          title = /([^\/\.]+\.[^\/]+)\/?.*$/.match(v)[1] rescue v
        when :github
          href = 'http://github.com/' + v
          title = v
        end
        "<a href='#{href}' title='#{title}' target='_blank' class='#{k}'></a>"
      }.join('')
      
      if member[:head].include? 'images'
        member[:head] = member[:head]
      else
        member[:head] = 'http://www.gravatar.com/avatar/' << member[:head] << '?s=60'
      end

      member
    end
  end
end

