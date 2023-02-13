class UrlEntry < ActiveRecord::Base
  scope :pending, -> { where(processing_started_at: nil) }

  mount_uploader :saved_response, ResponseUploader

  def save_response_body(html_source)
    file_name = "#{Time.now.to_i}-#{self.object_id}.html"
    self.saved_response = FileIO.new(html_source, file_name)
    save!
  end

  def html_content
    self.saved_response.file.read
  end
end
