# Monkey patch Hash to allow symbolized keys.
class Hash
  # Destructively convert all keys to symbols, as long as they respond to to_sym.
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end
end
