keychain --eval --quiet ...(ls ~/.ssh | where name !~ '.pub$' and name !~ 'known_hosts' and name !~ 'config' and name !~ 'sockets' | get name)
    | lines
    | where not ($it | is-empty)
    | parse "{k}={v}; export {k2};"
    | select k v
    | transpose --header-row
    | into record
   | load-env
