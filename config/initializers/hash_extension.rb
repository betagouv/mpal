class Hash
  def deep_reject!(key_to_reject)
    keys.each do |key|
      delete(key) if key == key_to_reject || self[key] == self[key_to_reject]
    end

    values.each do |value|
      value.deep_reject!(key_to_reject) if value.is_a? Hash
    end

    self
  end

  def deep_reject(key_to_reject)
    self.deep_dup.deep_reject!(key_to_reject)
  end
end
