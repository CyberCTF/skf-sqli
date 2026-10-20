#!/bin/sh
# >>> isoloom-1.0 secret-from-file shim (auto-added by convert-lab.py) >>>
# Inputs now arrive as files (isoloom.yml `files:`), not environment variables.
# Read each into its old variable when unset, keeping the dev/CI fallback working.
for __p in CTF_FLAG_MAIN:/run/lab/ctf_flag_main; do
  __n=${__p%%:*}; __f=${__p#*:}
  eval "__v=\${$__n:-}"
  if [ -z "$__v" ] && [ -s "$__f" ]; then
    __v=$(tr -d '\r\n' < "$__f"); eval "export $__n=\"\$__v\""
  fi
done
unset __p __n __f __v 2>/dev/null || true
# <<< isoloom-1.0 secret-from-file shim <<<
# Places the player's flag (CTF_FLAG_MAIN, given by the launcher) in a flags table of the lab's
# SQLite database (/home/app/SQLI/config/Database.db, on a volume shared with the app), where the SQL injection reaches it;
# without one (CI, a run by hand) the development flag. Runs as the image's user (app).
dev='FLAG{dev-skf-sqli}'
FLAG="${CTF_FLAG_MAIN:-$dev}" python3 - <<'PY'
import os, sqlite3
con = sqlite3.connect('/home/app/SQLI/config/Database.db')
con.execute('DROP TABLE IF EXISTS flags')
con.execute('CREATE TABLE flags(flag TEXT)')
con.execute('INSERT INTO flags VALUES (?)', (os.environ['FLAG'],))
con.commit()
PY
