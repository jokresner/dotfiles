export extern "pm" [
  command?: string@"nu-complete pm-commands"
]

def "nu-complete pm-commands" [] {
  [
    { value: run description: "Render and execute prompt" }
    { value: list description: "List prompts" }
    { value: show description: "Show prompt" }
    { value: new description: "Create prompt" }
    { value: move description: "Rename or move prompt" }
    { value: duplicate description: "Duplicate prompt" }
    { value: edit description: "Edit prompt in $EDITOR" }
    { value: render description: "Render prompt" }
    { value: rm description: "Delete prompt" }
    { value: search description: "Search prompts" }
    { value: tags description: "Manage tags" }
    { value: favorites description: "Manage favorites" }
    { value: recents description: "List recent prompts" }
    { value: export description: "Export prompts" }
    { value: import description: "Import prompts" }
    { value: test description: "Validate prompts" }
    { value: doctor description: "Run setup checks" }
    { value: events description: "Events utilities" }
    { value: ops description: "Operational checks" }
    { value: self-check description: "Run CI self checks" }
    { value: init description: "Initialize library" }
    { value: config description: "Config management" }
    { value: git description: "Git utilities" }
    { value: completion description: "Generate shell completions" }
    { value: tui description: "Start TUI" }
    { value: help description: "Show help" }
  ]
}
