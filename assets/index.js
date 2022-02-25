import { Elm } from '/src/Main.elm'
import './stylesheets/main.scss'
import '@fortawesome/fontawesome-free/js/fontawesome'
import '@fortawesome/fontawesome-free/js/solid'
import '@fortawesome/fontawesome-free/js/regular'
import '@fortawesome/fontawesome-free/js/brands'

var app = Elm.Main.init({
  node: document.getElementById('elm-app'),
  flags: process.env.GITHUB_PASSWORD
});