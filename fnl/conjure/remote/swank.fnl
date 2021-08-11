(module conjure.remote.swank
  {autoload {a conjure.aniseed.core
             net conjure.net
             log conjure.log
             client conjure.client}})

;; TODO:
;; - figure out how what the current package is to replace STUMPWM

;;; encoding/decoding

(defn- encode-integer [int]
  "Encode an integer to a 0-padded 16bit hexadecimal string."
  (string.format "%06x" int))

(defn- decode-integer [str]
  "decode a string representing a 0-padded 16bit hexadecimal string to an integer."
  (string.tonumber str 16))

;;; writing to socket

(defn- write-message-to-socket [conn msg]
  "write 'msg' to the current socket in connection 'conn'
  with length information and line end for swank."
  (let [len (+ 1 (length msg))]
  (print
    (.. (encode-integer len) msg "\n"))))

;; data

(defn decode [chunk]
  (log.dbg chunk)
  chunk)

(defn connect [opts]
  "Connects to a remote swank server.
  * opts.host: The host string.
  * opts.port: Port as a string.
  * opts.name: Name of the client to send post-connection, defaults to `Conjure`.
  * opts.on-failure: Function to call after a failed connection with the error.
  * opts.on-success: Function to call on a successful connection.
  * opts.on-error: Function to call when we receive an error (passed as argument) or a nil response.
  Returns a connection table containing a `destroy` function."

  (var conn
    {:queue []
     :name (or opts.name "Conjure")})

  (fn handle-message [err chunk]
    (if (or err (not chunk))
      (opts.on-error err)
      (decode chunk)))

  (set conn
       (a.merge
         conn
         (net.connect
           {:host opts.host
            :port opts.port
            :cb (client.schedule-wrap
                  (fn [err]
                    (if err
                      (do
                        (log.dbg "failure")
                        (opts.on-failure err))

                      (do
                        (log.dbg "success")
                        (conn.sock:read_start (client.schedule-wrap handle-message))
                        (opts.on-success)))))})))
  ;(send-encoded conn (string.format "(:emacs-rex (swank:connection-info) \"%s\" T 1)" conn.name))
  conn)

;; temp

(defn call-back [t]
  (log.dbg (.. "CALLBACK: " t)))

(defn- add-hex-code [msg]
  (let [len (+ 1 (length msg))]
    (.. (string.format "%06x" len) msg "\n")))

(defn- encode [msg pkg]
  (.. (string.format "(:emacs-rex (swank-repl:listener-eval \"%s\") \"%s\" t 1)" msg pkg)))

(defn- send-encoded [conn msg cb]
  (log.dbg "send" msg)
  (table.insert conn.queue 1 (or cb false))
  (conn.sock:write (add-hex-code msg))
  nil)

(defn send [conn msg cb]
  "Send a message to the given connection, call the callback when a response is received."
  (send-encoded conn (encode msg conn.name) cb))

;; Example:

;(def c (connect
;         {:host "127.0.0.1"
;          :port "5000"
;          :name "STUMPWM"
;          :on-failure (fn [err] (log.dbg "failure: "))
;          :on-success (fn [] (log.dbg "Yay!"))
;          :on-error (fn [err] (log.bg "error: "))}))
;(send c "(notify-send \\\"i\\\")" log.dbg)
;(c.destroy)
