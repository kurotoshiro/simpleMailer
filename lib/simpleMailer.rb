require 'net/smtp'

class SimpleMailer 
  attr_accessor :host, :port
  attr_accessor :from, :to
  attr_accessor :title, :message
  attr_accessor :files
  
    
  def initialize(host="",port=25)
    @host=host
    @port=port
    @from=""
    @to=""
    @title=""
    @message=""
    @files=Array.new
  end
  
  def to(to)
    raise "Not a proper email address" unless to.match(/.+@.+\..+/)
    @to=to
    self
  end
  
  def from(from)
    raise "Not a proper email address" unless from.match(/.+@.+\..+/)
    @from=from
    self
  end
  
  def with_title(title)
    @title=title
    self
  end
  
  def message(message)
    @message=message
    self
  end
  
  def send()
    Net::SMTP.start(@host,@port) do |smtp|
      body ="From: #{@from}\n"
      body+="To: #{@to}\n"
      body+="Subject: #{@title}\n"
      body+="\n#{@message}"
      begin
        smtp.send_message(body,@from,@to)
        return true
      rescue => e
        e
      end
    end
  end
  
end
