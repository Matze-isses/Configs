import hyprland
import os
import asyncio
from hyprland import Bind, config

class Config(hyprland.Events):
    def __init__(self):
        self.c = hyprland.Config()
        super().__init__()

    async def terminal(self):
        await hyprland.Dispatch.exec("kitty --single-instance")
    
    async def on_connect(self):
        print("Connected to hyprland")
        
        await self.c.add_binds([
            # general binds
            Bind(["SUPER","m"],hyprland.Dispatch.move_focus("r")),

            # keyboard binds
            Bind(["SUPER","return"],self.terminal),
            Bind(["SUPER","q"],hyprland.Dispatch.kill_active),
        ])

        # workspace binds
        for i in range(1,11):
            await self.c.add_bind(Bind([f"SUPER",str(i) if i!= 10 else str(0)],hyprland.Dispatch.workspace,args=[i]))
        
        for i in range(1,11):
            await self.c.add_bind(Bind([f"ALT",str(i) if i!= 10 else str(0)],hyprland.Dispatch.move_to_workspace,args=[i]))

    async def handle_bind(self):
        print("HI")

    async def start(self):
        ( not os.path.exists("/tmp/hypr_py/") ) and os.mkdir("/tmp/hypr_py/")
        ( not os.path.exists(f"/tmp/hypr_py/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}/") ) and os.mkdir(f"/tmp/hypr_py/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}/")
        os.path.exists(f"/tmp/hypr_py/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}/.socket.sock") and os.remove(f"/tmp/hypr_py/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}/.socket.sock")
        server = await asyncio.start_unix_server(self.handle_bind, f"/tmp/hypr_py/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}/.socket.sock")
        async with server:
            await server.serve_forever()

    
Config().start()
