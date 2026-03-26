def "nu-complete pm" [spans: list<string>] {
  let args = ($spans | skip 1)
  let index = (($args | length) - 1)
  ^pm completion query --json --index $index -- ...$args
  | from json
  | each {|it| {value: $it.value description: ($it | get -o description | default "")}}
}

@complete 'nu-complete pm'
export extern "pm" []
