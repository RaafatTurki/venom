-- require("hex.nvim")
-- require("hex")






-- local ffi = require("ffi")
--
-- local libhexutils = ffi.load("/home/potato/sectors/lua/hexutils/build/libhexutils.so")
--
-- ffi.cdef[[
--   typedef struct {
--     size_t len;
--     unsigned char* buffer;
--   } BufRead;
--
--   BufRead read_file_part(const char* filename, size_t offset, size_t len);
-- ]]
--
-- local bufRead = libhexutils.read_file_part("/home/potato/sectors/lua/hexutils/test/test.short.bin", 0, 0)
--
-- print(bufRead.buffer[1])
-- print(bufRead.len == 64)



