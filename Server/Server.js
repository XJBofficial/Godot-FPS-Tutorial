const Express = require("express");
const Serve = Express();
const App = require("http").createServer(Serve);
const { Server } = require("ws");
const PORT = 5000;


App.listen(PORT, () => {
    console.log("Listening on port: " + PORT)
})


var Websocket = new Server({
    server: App
})


Websocket.addListener("connection", (Client) => {
    Client.on("message", (message) => {
        // Send the packet to all clients
        Websocket.clients.forEach(client => {
            client.send(message);
        });
    })
})
