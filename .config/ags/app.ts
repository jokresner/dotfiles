import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import LogoutMenu from "./widget/LogoutMenu"
import Lockscreen, { lock } from "./widget/Lockscreen"

app.start({
  instanceName: "ags",
  css: style,
  main() {
    app.get_monitors().map(Bar)
    app.get_monitors().map((monitor, index) => Lockscreen(monitor, index))
    LogoutMenu()
  },
  requestHandler(argv: string[], res: (response: any) => void) {
    if (argv[0] === "toggle-logout-menu" || argv[0] === "logout") {
      const menu = app.get_window("logout-menu")
      if (menu) {
        menu.visible = !menu.visible
        res("ok")
      } else {
        res("error: logout menu not found")
      }
    } else if (argv[0] === "lock") {
      lock()
      res("ok")
    } else {
      res("unknown command")
    }
  },
})
