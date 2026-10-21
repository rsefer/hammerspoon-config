## TypeScript and Development

Install the development dependencies and build once before reloading Hammerspoon:

```sh
npm install
npm run build
```

The plain JavaScript entry point loads the compiled TypeScript config from
`compiled/config.js`. Edit `config.ts` and the TypeScript modules in `lib/`, not
the generated files. All library modules are linted and strictly type-checked.
Imports retain `.js` extensions so the compiled CommonJS modules load correctly.

The build compiles the Raycast gap helper separately with `tsconfig.node.json`
to keep Node typings isolated from Hammerspoon globals. The window manager runs
the generated helper under Node. To inspect its output directly after building:

```sh
node compiled/lib/external/raycast-window-gaps.js --json
```

Start development mode with:

```sh
npm start
```

Development mode runs ESLint with auto-fixes, compiles, and requests a Hammerspoon
reload on startup and whenever source files are saved. Remaining lint or
TypeScript errors appear in the terminal and block that build and reload; the
watcher keeps running. Reload Hammerspoon once after the initial build to register
the `hammerspoon2://reload_config` callback, using the existing Cmd+Alt+Ctrl+/
shortcut or its menu. Subsequent successful builds reload automatically without
bringing Hammerspoon to the foreground. Press Ctrl+C to stop development mode.

Standalone checks are available with `npm run lint`, `npm run lint:fix`, and
`npm run typecheck`. Dependencies and compiled output are ignored by Git.

The official `hammerspoon.d.ts` provides ambient Hammerspoon API types. Update it
when upgrading Hammerspoon 2. The updater queries `hs.appinfo.version` through
`hs2 --no-prompt` and downloads the matching published docs; pass a docs version
after `--` to override automatic detection:

```sh
npm run docs:typescript
npm run docs:typescript -- VERSION
```

See the [Hammerspoon TypeScript guide](https://cmsj.github.io/Hammerspoon2/main/js/typescript-guide.html).

## Permissions

The JavaScript config targets Hammerspoon 2. Desk mode is detected at startup
and whenever connected displays change, using the monitor names and IDs in
`lib/defaults.ts` (or their user-default overrides). Studio Display selects Desk,
Studio Display plus a configured side monitor selects Desk with iPad, and DELL
selects Desk (DELL). Without either desk display, the setup is Laptop, with or
without a configured side monitor. A manual selection lasts until the next
display change or reload, for example in the Hammerspoon 2 console:
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
