begin
  require 'aws-sdk'
rescue LoadError
  raise LoadError.new("Missing required 'aws-sdk'.  Please 'gem install aws-sdk' and require it in your application.")
end

module SitemapGenerator
  class AwsSdkV2Adapter

    def initialize(opts = {})
      @aws_access_key_id = opts[:aws_access_key_id] || ENV['AWS_ACCESS_KEY_ID']
      @aws_secret_access_key = opts[:aws_secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY']
      @aws_s3_bucket = opts[:aws_s3_bucket] || ENV['AWS_BUCKET']
      @aws_s3_region = opts[:aws_s3_region] || ENV['AWS_REGION']
    end

    # Call with a SitemapLocation and string data
    def write(location, raw_data)
      s3 = Aws::S3::Resource.new(region: @aws_s3_region, credentials: Aws::Credentials.new(@aws_access_key_id, @aws_secret_access_key))
      obj = s3.bucket(@aws_s3_bucket).object(location.path_in_public)
      if location.path.to_s =~ /.gz$/
        obj.put( body: gzip(raw_data), acl: 'public-read', content_encoding: 'gzip', content_type: 'application/xml' )
      else
        obj.put( body: raw_data, acl: 'public-read', content_type: 'application/xml' )
      end

    end

    # From http://code-dojo.blogspot.com/2012/10/gzip-compressiondecompression-in-ruby.html
    def gzip(string)
      wio = StringIO.new("w")
      w_gz = Zlib::GzipWriter.new(wio)
      w_gz.write(string)
      w_gz.close
      compressed = wio.string
    end

  end
end
