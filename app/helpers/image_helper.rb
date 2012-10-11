require 'aws/s3'

module ImageHelper
  def self.put(bucket, file_name, file)
    establish_connection
    AWS::S3::S3Object.store(file_name, file, bucket, :content_type => 'image/jpeg')
  end
  
  def self.profile_photo_bucket
    "smessage_profile_photos"
  end
  
  def self.profile_photo_name(user)
    "ppn" + user.id.to_s + ".jpg"
  end
  
  def self.build_photo_url(user)
    amazon_url + "/" + profile_photo_bucket + "/" + profile_photo_name(user)
  end
  
  def self.amazon_url
    "http://s3.amazonaws.com"
  end
  
  def self.establish_connection
    AWS::S3::Base.establish_connection!(
      :access_key_id     => 'AKIAIOUMC75X54LLXAAQ',
      :secret_access_key => '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'
    )
  end
end
