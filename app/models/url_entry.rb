class UrlEntry < ActiveRecord::Base
  FILE_STORE = './downloads'

  scope :pending, -> { where(processing_started_at: nil) }
  scope :processed, -> { where.not(processed_at: nil) }
  scope :failed, -> { where.not(failed_at: nil) }

  def save_response_body(html_source)
    file_name = "#{Time.now.to_i}-#{self.object_id}.html"
    File.open(File.join(FILE_STORE, file_name), 'w') { |f| f.write(html_source) }
    update!(saved_response_path: file_name)
  end

  def html_content
    return nil unless self.saved_response_path.present?

    File.open(File.join(FILE_STORE, self.saved_response_path)).read
  end
end
