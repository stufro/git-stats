import { Elm } from './Main.elm'

var app = Elm.Main.init({
  node: document.getElementById('elm-app'),
  flags: process.env.GITHUB_PASSWORD
});