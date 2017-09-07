import './main.css';

import Elm from './main';
const elmDiv = document.getElementById('root');

var app = Elm.Main.embed(elmDiv, localStorage.session || null);

app.ports.storeSession.subscribe(function(session) {
    localStorage.session = session;
});
window.addEventListener("storage", function(event) {
    if (event.storageArea === localStorage && event.key === "session") {
        app.ports.onSessionChange.send(event.newValue);
    }
}, false);
