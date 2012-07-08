require 'digest/md5'

set :haml, :format => :html5
set :sass, :style => :compressed

configure :build do
  activate :minify_css
end

helpers do
  def get_members
    members = YAML.load(File.read('source/members.yaml'))
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

      contact = member.select{ |k, v| k != 'name' && k != 'head' && k != 'say' }
      member[:contact] = contact.map{ |k, v|
        v = v.to_s
        case k
        when :twitter
          href = 'http://twitter.com/' + v
          title = '@' + v
        when :sina
          href = 'http://weibo.com/' + v
          title = '@' + v
        when :gurudigger
          href = 'http://gurudigger.com/users/' + v
          title = member['name']
        when :blog
          href = 'http://' + v
          title = /([^\/\.]+\.[^\/]+)\/?.*$/.match(v)[1]
        when :github
          href = 'http://github.com/' + v
          title = v
        end
        "<a href='#{href}' title='#{title}' target='_blank' class='#{k}'></a>"
      }.join('')
      
      if File.exists?(File.join('public', member[:head]))
        member[:head] = member[:head]
      else
        member[:head] = 'http://www.gravatar.com/avatar/' << member[:head] << '?s=60'
      end

      member
    end
  end
end

