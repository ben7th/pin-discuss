module Paperclip
  class Attachment
    def assign uploaded_file
      %w(file_name).each do |field|
        unless @instance.class.column_names.include?("#{name}_#{field}")
          raise PaperclipError.new("#{@instance.class} model does not have required column '#{name}_#{field}'")
        end
      end

      if uploaded_file.is_a?(Paperclip::Attachment)
        uploaded_file = uploaded_file.to_file(:original)
        close_uploaded_file = uploaded_file.respond_to?(:close)
      end

      return nil unless valid_assignment?(uploaded_file)

      uploaded_file.binmode if uploaded_file.respond_to? :binmode
      self.clear

      return nil if uploaded_file.nil?

      @queued_for_write[:original]   = uploaded_file.to_tempfile
      # TODO 给文件随机命名
      kouzhanming = uploaded_file.original_filename.split(".").last
      require 'uuidtools'
      # 11月20日 bugfix 宋亮
      # 不是所有的模型都有title这个字段，只是在FileEntry里有
      # 先判断是不是FileEntry，然后把文件原始名称赋给title
      instance.title = uploaded_file.original_filename.strip.gsub(/[^\w\d\.\-]+/, '_') if instance.instance_of?(FileEntry)

      base_name = UUIDTools::UUID.random_create.to_s
      instance_write(:file_name,       "#{base_name}.#{kouzhanming}"   )
      instance_write(:content_type,    uploaded_file.content_type.to_s.strip)
      instance_write(:file_size,       uploaded_file.size.to_i)
      instance_write(:updated_at,      Time.now)

      @dirty = true

      post_process if valid?

      # Reset the file size if the original file was reprocessed.
      instance_write(:file_size, @queued_for_write[:original].size.to_i)
    ensure
      uploaded_file.close if close_uploaded_file
      validate
    end
  end
end
