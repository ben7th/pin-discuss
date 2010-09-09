require 'rubygems'
require 'beanstalk-client'
require 'tmail'

message = $stdin.read
mail = TMail::Mail.parse(message)

if !mail.to.nil?
  beanstalk = Beanstalk::Pool.new("localhost:11301")
  mail.to.flatten.each do |to_address|
    if to_address.match("@ben7th.com")
      beanstalk.yput({:type => 'received_email',
          :to => to_address.gsub('@ben7th.com', ''),
          :subject => mail.subject,
          :body => mail.body,
          :from => mail.from.first,
          :message_id=>mail.message_id,
          :in_reply_to=>mail.in_reply_to.first})
    end
  end
end