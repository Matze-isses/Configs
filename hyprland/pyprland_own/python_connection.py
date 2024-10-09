from pyprland.plugins.interface import Plugin


zoomed = False

class Extension(Plugin):
    " My plugin "

    async def init(self):
        await self.notify("My plugin loaded")

    async def run_togglezoom(self, args):
        """ this doc string will show in `help` to document `togglezoom`
        But this line will not show in the CLI help
        """

        if self.zoomed:
            await self.hyprctl('misc:cursor_zoom_factor 1', 'keyword')
        else:
            await self.hyprctl('misc:cursor_zoom_factor 2', 'keyword')
            self.zoomed = not self.zoomed
