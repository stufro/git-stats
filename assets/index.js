import { Elm } from '/src/Main.elm'
import './stylesheets/main.scss'
import '@fortawesome/fontawesome-free/js/fontawesome.js'
import '@fortawesome/fontawesome-free/js/solid.js'
import '@fortawesome/fontawesome-free/js/regular.js'
import '@fortawesome/fontawesome-free/js/brands.js'
import './index.html'

var app = Elm.Main.init({
  node: document.getElementById('elm-app'),
  flags: process.env.ENVIRONMENT
});