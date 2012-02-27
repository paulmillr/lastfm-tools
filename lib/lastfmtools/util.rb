module LastfmTools
  module Util
    def array_to_hash(array)
      array.reduce({}) do |hash, data|
        key, value = data
        hash[key] = value
        hash
      end
    end
  end
end