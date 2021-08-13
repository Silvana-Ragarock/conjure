local _2afile_2a = "fnl/conjure/remote/swank.fnl"
local _1_
do
  local name_4_auto = "conjure.remote.swank"
  local module_5_auto
  do
    local x_6_auto = _G.package.loaded[name_4_auto]
    if ("table" == type(x_6_auto)) then
      module_5_auto = x_6_auto
    else
      module_5_auto = {}
    end
  end
  module_5_auto["aniseed/module"] = name_4_auto
  module_5_auto["aniseed/locals"] = ((module_5_auto)["aniseed/locals"] or {})
  do end (module_5_auto)["aniseed/local-fns"] = ((module_5_auto)["aniseed/local-fns"] or {})
  do end (_G.package.loaded)[name_4_auto] = module_5_auto
  _1_ = module_5_auto
end
local autoload
local function _3_(...)
  return (require("conjure.aniseed.autoload")).autoload(...)
end
autoload = _3_
local function _6_(...)
  local ok_3f_21_auto, val_22_auto = nil, nil
  local function _5_()
    return {autoload("conjure.aniseed.core"), autoload("conjure.client"), autoload("conjure.log"), autoload("conjure.net"), autoload("conjure.aniseed.string"), autoload("conjure.text")}
  end
  ok_3f_21_auto, val_22_auto = pcall(_5_)
  if ok_3f_21_auto then
    _1_["aniseed/local-fns"] = {autoload = {a = "conjure.aniseed.core", client = "conjure.client", log = "conjure.log", net = "conjure.net", str = "conjure.aniseed.string", text = "conjure.text"}}
    return val_22_auto
  else
    return print(val_22_auto)
  end
end
local _local_4_ = _6_(...)
local a = _local_4_[1]
local client = _local_4_[2]
local log = _local_4_[3]
local net = _local_4_[4]
local str = _local_4_[5]
local text = _local_4_[6]
local _2amodule_2a = _1_
local _2amodule_name_2a = "conjure.remote.swank"
do local _ = ({nil, _1_, nil, {{}, nil, nil, nil}})[2] end
local encode_integer
do
  local v_23_auto
  local function encode_integer0(int)
    return string.format("%06x", int)
  end
  v_23_auto = encode_integer0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["encode-integer"] = v_23_auto
  encode_integer = v_23_auto
end
local decode_integer
do
  local v_23_auto
  local function decode_integer0(str0)
    return tonumber(str0, 16)
  end
  v_23_auto = decode_integer0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["decode-integer"] = v_23_auto
  decode_integer = v_23_auto
end
local write_message_to_socket
do
  local v_23_auto
  local function write_message_to_socket0(conn, msg)
    local len = (1 + #msg)
    return print((encode_integer(len) .. msg .. "\n"))
  end
  v_23_auto = write_message_to_socket0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["write-message-to-socket"] = v_23_auto
  write_message_to_socket = v_23_auto
end
local presentation_start
do
  local v_23_auto
  do
    local v_25_auto
    local function presentation_start0(msg)
      return log.dbg(msg)
    end
    v_25_auto = presentation_start0
    _1_["presentation-start"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["presentation-start"] = v_23_auto
  presentation_start = v_23_auto
end
local write_string
do
  local v_23_auto
  do
    local v_25_auto
    local function write_string0(msg)
      local m = str.split(msg, "\"")
      return log.dbg(m[2])
    end
    v_25_auto = write_string0
    _1_["write-string"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["write-string"] = v_23_auto
  write_string = v_23_auto
end
__fnl_global__fn_2dtable = {[":presentation-start"] = presentation_start, [":write-string"] = write_string}
local decode_cmd
do
  local v_23_auto
  do
    local v_25_auto
    local function decode_cmd0(cmd)
      log.dbg(cmd)
      local name = string.sub(cmd, string.find(cmd, "%S+", 2))
      local f
      do
        local t_8_ = __fnl_global__fn_2dtable
        if (nil ~= t_8_) then
          t_8_ = (t_8_)[name]
        end
        f = t_8_
      end
      if f then
        return f(cmd)
      else
        return log.dbg(("function: '" .. name .. "' not implemented yet!"))
      end
    end
    v_25_auto = decode_cmd0
    _1_["decode-cmd"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["decode-cmd"] = v_23_auto
  decode_cmd = v_23_auto
end
local decode
do
  local v_23_auto
  do
    local v_25_auto
    local function decode0(msg, pos)
      local len = decode_integer(string.sub(msg, (pos + 1), (pos + 6)))
      if len then
        decode_cmd(string.sub(msg, (pos + 7), (pos + 6 + len)))
        decode0(msg, (pos + 6 + len))
      end
      return msg
    end
    v_25_auto = decode0
    _1_["decode"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["decode"] = v_23_auto
  decode = v_23_auto
end
write_string("00002b(:write-string \"Hello, world\" :repl-result)", 0)
local connect
do
  local v_23_auto
  do
    local v_25_auto
    local function connect0(opts)
      local conn = {name = (opts.name or "Conjure"), queue = {}}
      local function handle_message(err, chunk)
        if (err or not chunk) then
          return opts["on-error"](err)
        else
          return decode(chunk, 0)
        end
      end
      local function _13_(err)
        if err then
          log.dbg("failure")
          return opts["on-failure"](err)
        else
          log.dbg("success")
          do end (conn.sock):read_start(client["schedule-wrap"](handle_message))
          return opts["on-success"]()
        end
      end
      conn = a.merge(conn, net.connect({cb = client["schedule-wrap"](_13_), host = opts.host, port = opts.port}))
      return conn
    end
    v_25_auto = connect0
    _1_["connect"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["connect"] = v_23_auto
  connect = v_23_auto
end
local add_hex_code
do
  local v_23_auto
  local function add_hex_code0(msg)
    local len = (1 + #msg)
    return (string.format("%06x", len) .. msg .. "\n")
  end
  v_23_auto = add_hex_code0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["add-hex-code"] = v_23_auto
  add_hex_code = v_23_auto
end
local encode
do
  local v_23_auto
  local function encode0(msg, pkg)
    return string.format("(:emacs-rex (swank-repl:listener-eval \"%s\") \"%s\" t 1)", string.gsub(msg, "\"", "\\\""), pkg)
  end
  v_23_auto = encode0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["encode"] = v_23_auto
  encode = v_23_auto
end
local send_encoded
do
  local v_23_auto
  local function send_encoded0(conn, msg, cb)
    log.dbg("send", msg)
    table.insert(conn.queue, 1, (cb or false))
    do end (conn.sock):write((encode_integer(#msg) .. msg))
    return nil
  end
  v_23_auto = send_encoded0
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["send-encoded"] = v_23_auto
  send_encoded = v_23_auto
end
local send
do
  local v_23_auto
  do
    local v_25_auto
    local function send0(conn, msg, cb)
      return send_encoded(conn, encode(msg, conn.name), cb)
    end
    v_25_auto = send0
    _1_["send"] = v_25_auto
    v_23_auto = v_25_auto
  end
  local t_24_auto = (_1_)["aniseed/locals"]
  t_24_auto["send"] = v_23_auto
  send = v_23_auto
end
return nil