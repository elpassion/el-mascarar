import {Socket} from "phoenix"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", resp => {
//   console.log("Joined succesffuly!", resp)
// })

let socket = new Socket("/socket", {});

socket.connect();
console.log(socket);
let channel = socket.chan("games:lobby");
let gameChannel = (game_id) => {
  let newChannel = socket.chan(`games:${game_id}`)
  newChannel.on("game", payload => {console.log(payload)});
  return newChannel;
};

channel.join()
  .receive("ok", ({game_id}) => {
    window.gameChannel = gameChannel(game_id);
    window.gameChannel.join();
  })
  .receive("error", resp => { console.log("Unable to join", resp) });

let App = {};

export default App
