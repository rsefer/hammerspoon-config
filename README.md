## Permissions

If permission issues arise, try:
```
/usr/bin/tccutil reset All org.hammerspoon.Hammerspoon
```

Replace 'All' with the specific service or app.

For Reminders, run the following to trigger permission additions:
```
hs.execute('osascript -e \'tell application "Reminders" to return default account\'')
```
