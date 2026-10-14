## Permissions

The JavaScript config targets Hammerspoon 2. Set the desk mode once in the
Hammerspoon 2 console if needed, for example:
```
hs.userdefaults.set("deskSetup", "desk")
```

Window-created automation requires Accessibility permission for Hammerspoon 2.
After granting it in System Settings, reload the config.

If permissions remain stuck, remove and re-add Hammerspoon 2 under System
Settings > Privacy & Security > Accessibility or Automation, as appropriate.

For Reminders, run the following in the Hammerspoon 2 console to trigger its
Automation permission prompt:
```
hs.osascript.applescript('tell application "Reminders" to return default account')
	.then(result => console.log(result.success ? result.result : result.raw))
```
