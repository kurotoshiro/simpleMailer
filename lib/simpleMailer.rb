class SimpleMailer 
  require 'base64'
  require 'net/smtp'
  require 'shared-mime-info'

  MARKER="THATSMAMARKER"
    
  def initialize(host="",port=25)
    @host=host
    @port=port
    @from=''
    @to=''
    @title=''
    @message=''
    @body=''
    @files=Array.new
  end
  
  def to(to)
    if to.class==Array then
      to.each do |ad|
        raise "Not a proper email address" unless ad.match(/.+@.+\..+/)
      end
    else
      raise "Not a proper email address" unless to.match(/.+@.+\..+/)
    end
    @from=to
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

  # WARNING : with_files clear @files before adding new ones
  def with_files(files)
    @files=Array.new
    files.each do |file|
      raise "File #{file} doesn't exist" unless File.exists?(file)
      raise "Can't read file #{file}" unless File.readable?(file)
      @files<<file
    end
    self
  end

  def generate_file_part(file)
    b64file=String.new
    filename=File.basename(file)
    part=String.new
    File.open(file) do |f|
      b64file=Base64.b64encode(f.read)
    end
    part =<<EOF
--#{MARKER}
Content-Disposition: attachment; filename="#{filename}"
Content-Type: #{MIME::check(file).to_s}; name="#{filename}"
Content-Transfer-Encoding: base64

#{b64file}


EOF
  end

  # TODO: Get information and format them to create a multipart message
  def generate_body
    @body =<<EOF
From: #{@from}
To: #{@from}
Subject: #{@title}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{MARKER}
--#{MARKER}
Content-Type: text/plain
Content-Transfer-Encoding:8bit

#{@message}

EOF
    # Time to process our files
    @files.each do |file|
      @body+=generate_file_part(file)
    end
    @body+="--#{MARKER}--"
    return true
  end

  def send()
    Net::SMTP.start(@host,@port) do |smtp|
      begin
        generate_body
        smtp.send_message(@body,@from,@from)
        return true
      rescue => e
        e
      end
    end
  end
  
end
