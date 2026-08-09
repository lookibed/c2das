local script_path = debug.getinfo(1, "S").source:sub(2)
local script_dir = script_path:match("^(.*)[/\\][^/\\]+$") or "."
local generated_module_path = script_dir .. "/generated/secret_reader.lua"
local zip_path = script_dir .. "/fixtures/secretik.zip"

local function as_i32(value)
    if value >= 0x80000000 then
        return value - 0x100000000
    end

    return value
end

local function read_file(path)
    local file = assert(io.open(path, "rb"))
    local data = assert(file:read("*a"))
    assert(file:close())
    return data
end

local function write_bytes(memory, offset, bytes)
    for index = 1, #bytes do
        memory[offset + index] = string.byte(bytes, index)
    end
end

local function read_bytes(memory, offset, length)
    local out = {}
    for index = 1, length do
        out[index] = string.char(memory[offset + index])
    end
    return table.concat(out)
end

local wasm_module_loader = dofile(generated_module_path)
local wasm = wasm_module_loader()
local archive_bytes = read_file(zip_path)

wasm.miniz_secret_reset()

local archive_ptr = wasm.miniz_secret_alloc(#archive_bytes)
assert(archive_ptr ~= 0, "archive allocation failed")

local output_capacity = 256
local output_ptr = wasm.miniz_secret_alloc(output_capacity)
assert(output_ptr ~= 0, "output allocation failed")

local memory = wasm.memory[1]
write_bytes(memory, archive_ptr, archive_bytes)

local extracted_len = as_i32(wasm.miniz_secret_extract_message_iter(archive_ptr, #archive_bytes, output_ptr, output_capacity))
assert(extracted_len >= 0, ("iter extract failed: %d"):format(extracted_len))

local text = read_bytes(memory, output_ptr, extracted_len)
local matches = as_i32(wasm.miniz_secret_matches_expected(output_ptr, extracted_len))

print(("Archive: %s"):format(zip_path))
print(("Text: %s"):format(text))
print(("Matches Expected: %d"):format(matches))
