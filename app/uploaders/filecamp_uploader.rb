# encoding: utf-8

class FilecampUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :s3

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    #"public/uploads/userfiles"
  end

  # Override the filename of the uploaded files:
   def filename
     #"something.jpg" if original_filename
     model.random_string + model.id.to_s + File.extname(@filename) if @filename
   end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
   def extension_white_list
     %w(jpg jpeg png)
   end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  version :thumb_small do
    process :resize_to_fill => [50,50]
  end

  version :thumb_medium do
    process :resize_to_fill => [100,100]
  end

  version :thumb_large do
    process :resize_to_fill => [300,300]
  end

  version :scaled_full do
    process :resize_to_limit => [700,700]
  end
end
