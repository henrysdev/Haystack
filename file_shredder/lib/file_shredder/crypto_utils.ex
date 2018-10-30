defmodule FileShredder.CryptoUtils do

    # erlang crypto code adapted from: https://stackoverflow.com/a/37660251
    # TODO: Implement legitimate init vector!
    @aes_block_size 16
    @key_size 24
    @zero_iv to_string(:string.chars(0, 16))

    def pad(data, block_size) do
      to_add = block_size - rem(byte_size(data), block_size)
      data <> to_string(:string.chars(to_add, to_add))
    end

    def unpad(data) do
      to_remove = :binary.last(data)
      :binary.part(data, 0, byte_size(data) - to_remove)
    end

    def encrypt(data, key) do
      :crypto.block_encrypt(:aes_cbc, key, @zero_iv, pad(data, @aes_block_size))
    end

    def decrypt(data, key) do
      padded = :crypto.block_decrypt(:aes_cbc128, key, @zero_iv, data)
      unpad(padded)
    end

    def gen_key(password) do
      String.slice(:crypto.hash(:sha256, password), 0..@key_size-1)
    end

    def gen_hmac(key, seq_id) do
      :crypto.hash(:sha256, key <> <<seq_id>>) |> to_string
    end

end